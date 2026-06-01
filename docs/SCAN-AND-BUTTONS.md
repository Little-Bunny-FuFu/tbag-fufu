# TBag-fufu — Scan / Cache + Item Buttons (Phase 1 subsystem deep-dive)

> **Status:** Phase 1 per-subsystem reference, built 2026-06-01 from the live
> source. Companion to [`ARCHITECTURE.md`](ARCHITECTURE.md) (Phase 0 map); this
> file uses its vocabulary (`TFuBag`, the `I_*` item-cache key codes, the
> transient `itmcache` / `bar_positions` / `BUTTONS` / `stackarr` / `comparr`
> structures, the event -> `RequestUpdate` -> `UpdateWindow` -> scan -> render
> pipeline). Read Phase 0 sections 6 (Data model) and 7 (Core pipeline) first.
>
> **Scope:** the SCAN/CACHE half (`UpdateItmCache` and friends; alt-view scans)
> and the ITEM BUTTON half (`TFuBag.ItemButton`, the button<->item map, the
> `ItemButton` intrinsic). Every WoW API claim is verified against the pinned
> 12.0 source under `../wow-ui-source` (`version.txt` = `12.0.5.67451`).
>
> **Not shipped:** `docs/` is excluded from both release paths.
>
> All correctness/bug observations are deferred to the Phase 3 FINDINGS list
> (returned with this review) and marked **[→ FINDINGS]** inline. This document
> describes *what the code does*; the FINDINGS list says where it is wrong.

---

## 1. The cache record lifecycle

### 1.1 One record per physical slot

The unit of storage is the **per-slot item record**: a Lua table keyed by the
2-character `I_*` codes (TBag.lua:84-148; full table in Phase 0 §6.2). Records
live in `itmcache[bag][slot]`, where `itmcache` is the per-window persisted
SavedVariable (`TFuInvItm[playerid]` for the inventory window, `TFuBnkItm[playerid]`
for the bank — see `Inv:UpdateWindowBody` TInv.lua:1423 and `Bank:UpdateWindow`
TBnk.lua:2355).

Short string keys keep the persisted cache compact; they are *not* an enum, so
every producer/consumer must agree on the exact code (`I_NOVALUE = "nv"`,
`I_NEWSTR = "nw"`, etc.).

### 1.2 `CreateItm` returns a SHARED scratch table

`TFuBag:CreateItm()` (TBag.lua:4239) does **not** allocate a fresh table — it
wipes and returns the single file-local `Itm` upvalue:

```lua
local Itm = {};
function TFuBag:CreateItm()
  local itm = Itm;
  for k,_ in pairs(itm) do itm[k] = nil; end
  return Itm;
end
```

This is a deliberate allocation-avoidance pattern (the scan touches hundreds of
slots per burst). The consequence is a hard contract: **the `itm` handed back by
`CreateItm` is transient scratch** and must be copied into the persisted cache
before the next `CreateItm` call. `UpdateItmCache` honours this — see §1.4 step
6. Anything that stashed the `CreateItm` return for later would alias the next
scan iteration. `CreateStackArr` (TBag.lua:7491) and `CreateCompArr`
(TBag.lua:7503) use the same wipe-and-return-shared-upvalue pattern for
`stackarr` / `comparr`.

### 1.3 Scan entry / gating (`UpdateItmCache`, TBag.lua:4253)

Signature: `UpdateItmCache(cfg, playerid, itmcache, bagarr, stackarr, comparr, atbank)`.
Two early bail-outs before any slot work:

- `playerid ~= self.PLAYERID` -> return `REQ_NONE` (TBag.lua:4271). A cached
  cross-character view is read-only; never rescanned. The persisted record is
  the only source for an alt.
- `atbank and atbank ~= 1` -> return `REQ_NONE` (TBag.lua:4276). The bank passes
  its `atbank`; the inventory passes nothing (nil), so the inventory is never
  gated out here. (This `0 vs nil vs 1` truthiness is the same family that
  produced BUG-1 on the button side — see §5.)

### 1.4 Per-slot scan -> populate `I_*` -> persist

For each `bag` in `bagarr`, for each `slot` (counted **down**, `size..1`, so
stacking prefers existing stacks — TBag.lua:4301):

1. **Ensure the slot table exists** (`itmcache[bag][slot] = { [I_KEYWORD] = {} }`
   if nil, TBag.lua:4302).
2. **Grab the scratch record** `itm = self:CreateItm()` (§1.2).
3. **Carry-over fields from the OLD record** (TBag.lua:4315-4329): `I_BAR`,
   `I_TIMESTAMP`, `I_NEWSTR`, `I_CAT`, `I_SUBGROUP`, `I_KEYWORD`, `I_SOULBOUND`,
   `I_CHARGES`, `I_ACCTBOUND`, `I_LINKSUFFIX`. These are the fields the scan
   cannot cheaply re-derive every burst; preserving them is what lets a plain
   `BAG_UPDATE` skip the expensive `PickBar` tooltip scan. The `I_SUBGROUP`
   carry-over (TBag.lua:4324) is load-bearing: `PickBar` re-derives it only on a
   stale catGen stamp, so a stamp-current update would otherwise drop it and the
   box would silently flatten its sub-headers.
4. **Read the live slot.** `I_ITEMLINK` from `GetContainerItemLink`
   (TBag.lua:4311). If non-nil:
   - `I_NAME`, `I_ITEMID`/`I_ITEMLINK`/`I_LINKSUFFIX` (via `GetItemID`),
   - `I_TYPE`/`I_SUBTYPE`/`I_RARITY`/`I_BINDTYPE`/`I_EXPANSION` (via the wrapped
     `TFuBag:GetItemInfo`, TBag.lua:618 — returns the 6 classic values plus
     bindType + expansionID for the item filter),
   - `I_COUNT`/`I_RARITY`/`I_READABLE`/`I_NOVALUE` from `GetContainerItemInfo`
     (TBag.lua:4339 — **positional read, see §2**),
   - `I_NEED = stacksize - I_COUNT` (drives `stackarr`),
   - `I_QUEST_ITEM`/`I_QUEST_ID`/`I_QUEST_ACTIVE` from
     `GetContainerItemQuestInfo`.
   If nil: `MakeEmptySlot(itm)` (TBag.lua:4172) blanks the display fields and
   sets `I_COUNT = 0`, `I_NEED = 0`; the slot is also removed from the stack and
   comp skip lists.
5. **Change detection** (TBag.lua:4377): if the new `I_ITEMLINK` differs from the
   stored one, the slot's content changed:
   - clear its categorization stamp (`SetCatStamp(playerid, bag, slot, nil)`) so
     the next sort re-runs `PickBar` for just this slot,
   - if a prior `I_TIMESTAMP` existed AND the bag is shown -> `resort_mandatory = 1`
     (forces `SortItmCache` + `LayoutWindow` on this same burst; the older
     `REQ_PART`-defer path left a moved item invisible under empty-collapse),
   - stamp `I_TIMESTAMP = time()`, `I_NEWSTR = V_NEWON`, add to `FORCED_SHOW`,
   - tooltip-scan for Soulbound / Account Bound / Crafting Reagent -> `I_SOULBOUND`,
     `I_ACCTBOUND`, `I_CRAFTINGREAGENT`; refresh `I_CHARGES`.
   Else (link unchanged) only the count may have changed -> `update_suggested`,
   `I_NEWSTR = V_NEWPLUS/V_NEWMINUS`, bump `I_TIMESTAMP`.
6. **Persist** (TBag.lua:4441-4447): wipe every key of `itmcache[bag][slot]`,
   then copy every key of the scratch `itm` into it. After this point the
   scratch `itm` is dead; the persisted table is the live one.
7. **Index for stacking / special-bag compression** (TBag.lua:4450-4460): pass
   the *persisted* record (not the scratch) to `InsertStackArr`,
   `InsertItemInCompArr` / `InsertEmptyInCompArr`.

### 1.5 Return value: the resort "debt"

`UpdateItmCache` returns one of `REQ_NONE / REQ_PART / REQ_MUST` (it never
returns `REQ_PART` in practice — `resort_suggested` is set nowhere
**[→ FINDINGS]**). The caller adds this to its own `resort_req` plus any carried
`CACHE_REQ` debt (§3).

### 1.6 `ClearItmCache` (TBag.lua:545)

Wipes records in place (preserving the outer `itmcache[bag]` tables) for a bag
list. Handles both the table-per-slot caches and the single-value caches (some
dummy-bag caches store a scalar per slot). Used at `Init` to seed the
`Inv_Bags` / `Bnk_Bags` / dummy-bag caches.

---

## 2. `GetContainerItemInfo` positional read vs the 12.0 struct

In 8.0 Blizzard changed `C_Container.GetContainerItemInfo` to return a single
`ContainerItemInfo` struct instead of positional values. `compat-12.lua:29-34`
re-exposes the **Legion positional order** so the legacy call sites keep working:

```lua
function GetContainerItemInfo(bag, slot)
  local i = C.GetContainerItemInfo(bag, slot)
  if not i then return nil end                       -- empty slot: ALL returns nil
  return i.iconFileID, i.stackCount, i.isLocked, i.quality, i.isReadable,
         i.hasLoot, i.hyperlink, i.isFiltered, i.hasNoValue, i.itemID, i.isBound
end
```

Verified field order against
`wow-ui-source/Interface/AddOns/Blizzard_APIDocumentationGenerated/ContainerDocumentation.lua:761-771`
(`ContainerItemInfo`): `iconFileID, stackCount, isLocked, quality, isReadable,
hasLoot, hyperlink, isFiltered, hasNoValue, itemID, isBound`. The shim is
**correct** — its positional order is exactly the struct order.

The consumers must therefore count positions exactly:

| Call site | Reads | Position correctness |
|-----------|-------|----------------------|
| `UpdateItmCache` TBag.lua:4339 | `_, I_COUNT, _, I_RARITY, I_READABLE, _, _, I_NOVALUE` | `I_NOVALUE` lands on **position 8 = `isFiltered`**, not position 9 = `hasNoValue`. **[→ FINDINGS]** |
| `ItemButton.UpdateLock` Buttons.lua:264 | `_,_,locked,_,_` | position 3 = `isLocked` — correct |
| `GetSlotInfo` TBag.lua:3555 | `_, item` | position 2 = `stackCount`; treated only as "non-nil = filled". Works because the whole shim returns nil for an empty slot, so the test is really "is the struct nil"; the `item` name is misleading but the logic holds |
| `PutItemInBank` TBag.lua:711 | `texture` | position 1 = `iconFileID`; same "non-nil = filled" idiom — correct |
| `Stack` TBag.lua:7756-7757 | `_,_,locked1/2` | position 3 = `isLocked` — correct |

`GetContainerItemQuestInfo` is shimmed the same way (compat-12.lua:36-40,
returning `isQuestItem, questID, isActive` — verified `ItemQuestInfo`
ContainerDocumentation.lua:812-814) and read positionally at TBag.lua:4345 into
`I_QUEST_ITEM`/`I_QUEST_ID`/`I_QUEST_ACTIVE` — correct.

---

## 3. The `cache_req` / `CACHE_REQ` change-detection ("resort debt")

The `REQ_*` ladder (`REQ_NONE=0`, `REQ_PART=1`, `REQ_MUST=2`) is the perf lever:
the costly `SortItmCache` + `LayoutWindow` only run at `>= REQ_MUST`. Because a
burst can deliver a `REQ_PART`-worthy change while the window is hidden (or while
an explicit request is still only `REQ_PART`), the shortfall is **banked** on the
frame as `self.CACHE_REQ` and paid down on a later update.

The accumulation contract (identical shape in `Inv:UpdateWindowBody`
TInv.lua:1418-1459 and `Bank:UpdateWindow` TBnk.lua:2348-2397):

```
force_full = (resort_req >= REQ_MUST)            -- explicit config/category change
cache_req  = UpdateItmCache(...)                 -- this burst's freshly-detected staleness
if resort_req == REQ_PART then
  resort_req = resort_req + self.CACHE_REQ        -- fold in the banked debt
end
resort_req = resort_req + cache_req

if resort_req >= REQ_MUST then
  if force_full then BumpCatGen() end            -- only a real input change recats EVERYTHING
  self.CACHE_REQ = REQ_NONE                       -- debt paid
  SortItmCache(...) ; LayoutWindow(self)
  self.sortGen = catGen                           -- mark categorization current (OnShow dirty check)
elseif self.force_resort then ...                 -- item-filter toggle: resort, no catGen bump
elseif self.force_relayout then LayoutWindow(self)  -- (BANK only) edit-mode toggle
elseif cache_req > self.CACHE_REQ then
  self.CACHE_REQ = cache_req                       -- bank the new debt for next time
end
```

Key sources that *set* `CACHE_REQ = REQ_MUST` directly (debt deposited without an
immediate resort):

- `MainFrame:OnHide` TBnk/Inv shared, MainFrame.lua:224 — unchecking a
  force-shown bag.
- `Bank:RebuildTabList` TBnk.lua:523 / TBnk.lua:86 — the purchased-tab set
  changed (and TBnk.lua:117 resets it).
- `TInv.lua:93` (SetPlayer/init) and `Hooks.ToggleAllBags` (Hooks.lua:211/235) —
  bag visibility toggled.

The `catGen` / per-slot `catStamp` memo (TBag.lua:4496-4515) is the second lever:
`SortItmCache` re-runs `PickBar` (the per-item tooltip scan) only when a slot's
stamp `~= catGen` (TBag.lua:4582), i.e. config changed (catGen bumped) or the
slot's item changed (stamp cleared in §1.4 step 5). `catStamp` is runtime-only
(never persisted) so it can't collide with a stale saved value.

### Inventory vs bank divergence

The inventory branch uses a nested `else if (...)` (TInv.lua:1456 — a *new
block*, balanced with an extra `end`) and has **no `force_relayout` arm**; the
bank has one (TBnk.lua:2390). Parse-clean, but the two pipelines are not a
literal copy — a change to one must be hand-mirrored. **[→ FINDINGS]** (low,
maintainability).

---

## 4. The transient layout structures + the button<->item relink contract

After scan + (optional) sort, `UpdateWindow` rebuilds the live map
`TFuBag.BUTTONS[frame_name] = record`. This is the bridge between the data model
and the on-screen frames; every button handler resolves its item through it via
`GetItmFromFrame` (TBag.lua:4021), which looks up `BUTTONS[frame:GetName()]` and
falls back to the parent's name.

### 4.1 `bar_positions` / `BARITM`

`SortItmCache` (TBag.lua:4517) wipes `baritm[bar]` (the per-frame `BARITM`),
then for each shown bag/slot:

- re-`PickBar`s stale slots (catStamp memo, §3),
- routes the record into `baritm[destbar]` if its `I_BAR` resolved to a real
  number AND it passes the active item filter (TBag.lua:4608-4614),
- empties go to the dedicated `EMPTY_BAR` (drawn as one box at the bottom):
  collapse OFF tiles every empty (TBag.lua:4605); collapse ON inserts a single
  representative after the loop (`frame._emptyRep`, TBag.lua:4631-4638),
- tallies `frame.freeSlots` and the deposit target `frame.dropBag/dropSlot`
  (first free slot in the viewed bank, or in a solo-selected bank tab),
- finally sorts each bar by `I_CAT .. SubSortKey .. ReverseString(name) ..
  count .. slot` (TBag.lua:4652).

`baritm`/`BARITM` is then consumed by the layout engine (Phase 0 §9).

### 4.2 The relink: nil vs `{}` — the two windows differ ON PURPOSE

**Inventory** (TInv.lua:1466-1472):
```lua
local pcache = TFuInvItm[self.playerid];
for _,bag in ipairs(self.bags) do
  local pbag = pcache and pcache[bag];
  for slot = 1, TFuBag:GetBagMaxItems(bag) do
    TFuBag.BUTTONS[GetBagItemButtonName(bag, slot)] = pbag and pbag[slot] or nil;
  end
end
```
An empty/missing slot maps to **nil** -> the key is *dropped* from `BUTTONS`.

**Bank** (TBnk.lua:2405-2410):
```lua
for _,bag in ipairs(self.bags) do
  for slot = 1, TFuBag:GetBagMaxItems(bag) do
    local itm = TFuBnkItm[self.playerid][bag] and TFuBnkItm[self.playerid][bag][slot]
    TFuBag.BUTTONS[GetBagItemButtonName(bag, slot)] = itm or {}   -- EMPTY TABLE, never nil
  end
end
```
The bank deliberately uses `{}` so that `UpdateButtonHighlights`' `pairs(BUTTONS)`
loop still *visits* a now-empty button and can clear a stale spotlight glow left
by an item that moved away (the comment at TBnk.lua:2401-2404 documents the
"glow stacking" bug this fixes). The inventory has no equivalent per-tab
spotlight-stacking surface, so it uses nil. **[→ FINDINGS]** flags the asymmetry
as a staleness risk to keep in mind, not a confirmed inventory bug.

Both downstream readers tolerate both shapes: `ItemButton.Update` bails with
`if not itm or not next(itm) then self:Hide(); return end` (TBag.lua via
Buttons.lua:310), and `RefreshEditHighlight` guards `if (itm and next(itm))`
(Buttons.lua:121). An empty `{}` and a nil are display-equivalent (both "no
item"); the only observable difference is whether the key is *present* for a
`pairs` sweep.

### 4.3 The per-button refresh pass

After the relink, both windows iterate `self.bags` and call
`ItemButton.Update(_G[GetBagItemButtonName(bag,slot)])` for slots `1..size`, then
`:Hide()` for slots `size+1..GetBagMaxItems(bag)` (TInv.lua:1478-1490,
TBnk.lua:2416-2432). This always-run pass is why `Update` must itself decide to
`Hide()` an unmapped or filtered button (§5) — the sort step alone does not hide
ghosts.

`GetBagMaxItems` (TBag.lua:3460): 98 for a bank tab (`IsBankTab`, ids 6-16) and
the reagent bank, else `MAX_CONTAINER_ITEMS` (50, restored in compat-12.lua:46).
Undersizing this would leave high slots with no button frame.

---

## 5. The `ItemButton` intrinsic + IsLive gating of live-only state

### 5.1 The intrinsic: parentKey children, not `$parent` globals

In 12.0 the old `ItemButtonTemplate` is the **`ItemButton` intrinsic**
(`ItemButtonMixin`). `TFuBag_ItemButtonTemplate` (Buttons.xml) is built on it, so
the frames MUST be created as type `"ItemButton"` — `CreateDummyBag`
(TBag.lua:580) does `CreateFrame("ItemButton", buttonname, dbag, template)`. The
intrinsic's children expose **parentKeys** (`self.icon`, `self.Count`,
`self.Stock`) rather than reliable `$parentIconTexture` global names. `Update`
prefers the parentKey, falling back to the legacy global for compatibility
(Buttons.lua:337-340):

```lua
local frame_texture = self.icon  or _G[framename.."IconTexture"]
local frame_font    = self.Count or _G[framename.."Count"]
local frame_stock   = self.Stock or _G[framename.."Stock"]
```

`BarButton:OnLoad` / `BagButton:OnLoad` apply the same fallback for the stock
fontstring (Buttons.lua:482, 560). The intrinsic's own helper methods are used
directly: `SetItemButtonTexture`, `SetItemButtonCount`,
`SetItemButtonDesaturated`, `SetItemCraftingQualityOverlay`,
`self.JunkIcon`, `self.ProfessionQualityOverlay`.

### 5.2 `IsLive` — the live/cached predicate (TBag.lua:738)

```lua
function TFuBag:IsLive(frame)
  if frame.playerid ~= self.PLAYERID then return false end   -- viewing a cached alt
  if frame.atbank and frame.atbank ~= 1 then return false end -- bank flag set but not at bank
  return true
end
```

`atbank == nil` is "live" (the inventory frame keeps it nil); `atbank == 0` is
"not live" (`0` is truthy in Lua and `0 ~= 1`). **This `0 vs nil` distinction is
the BUG-1 mechanism:** the shared `MainFrame:OnHide` used to set `atbank = 0`
unconditionally, clobbering the inventory frame's nil and leaving
`IsLive(TFuInvFrame)` false until `/reload`. The fix scopes the reset to the bank
(MainFrame.lua:241-243, `if self == TFuBnkFrame then self.atbank = 0 end`), with
a long comment recording the failure mode. Any future state written by the shared
OnHide/OnShow must respect that the inventory frame is "live by absence."

### 5.3 The three IsLive-gated button states

Live-only state must be **reset (not skipped)** on the non-live path, or it goes
stale across a dropdown switch to a cached alt — the BUG-1 class. Current state:

**Lock / desaturation / deposit-dim — `ItemButton.UpdateLock` (Buttons.lua:238).**
Three exits, each fully resetting:
- not live (Buttons.lua:248): `SetItemButtonDesaturated(false)` **and**
  `SetDepositDim(false)`, then return. (The desaturation reset was added in the
  BUG-1 hardening — comment Buttons.lua:243-247. `SetItemButtonTexture` in
  `Update` does *not* clear desaturation, so without this a button greyscaled
  while live would keep it on a cached alt.)
- bank tab (Buttons.lua:258): same full reset, then return — bank-tab items are
  reported "locked" when the bank is opened remotely, which would wrongly grey
  already-deposited items.
- live, normal bag (Buttons.lua:264-271): read `isLocked` (position 3, §2) and
  `IsItemBankIneligible`; `SetItemButtonDesaturated(self, locked or ineligible)`
  and `SetDepositDim(ineligible)`.

`IsItemBankIneligible` (TBag.lua:258) is read-only and taint-safe: it guards on a
live bank session (`TFuBnkFrame.atbank == 1` and a `bankType`), builds an
`ItemLocation:CreateFromBagAndSlot`, and `pcall`s
`C_Bank.IsItemAllowedInBankType(bankType, loc)`. Verified in 12.0:
`IsItemAllowedInBankType(bankType, itemLocation)` returns `isItemAllowedInBankType`
(`BankDocumentation.lua:264-277`); `ItemLocation:CreateFromBagAndSlot` exists
(`Blizzard_ObjectAPI/Mainline/Item.lua`). The `pcall` is appropriate because the
function is `SecretArguments = "AllowedWhenUntainted"`.

**Cooldown — `ItemButton.UpdateCooldown` (Buttons.lua:288).** Defaults
`start,duration,enable = 0,0,false`; only overwrites them from
`GetContainerItemCooldown` when `I_ITEMLINK and IsLive(mainFrame)`
(Buttons.lua:296). Always calls `CooldownFrame_Set(cooldownFrame, start, duration,
enable)` — so the non-live path actively **clears** the cooldown rather than
leaving a stale spinner. Correct (reset, not skip). The bank deliberately does
not tick cooldowns at all (perf — Phase 0 §10, Events.lua).

**Crafting-quality badge — `ItemButton.UpdateQualityOverlay` (Buttons.lua:277).**
NOT IsLive-gated (it works off the itemlink, valid for cached alts too). Calls
Blizzard's `SetItemCraftingQualityOverlay(self, itemlink)` (nil link ->
`isProfessionItem = false`) and explicitly hides a stale badge on a
non-profession item so a pooled button can't keep one. Correct.

### 5.4 `ItemButton.Update` — the orchestrator (Buttons.lua:303)

Resolves `mainFrame`/`cfg`/`playerid`, then its item via `GetItmFromFrame`. The
hide ladder (each `Hide(); return`) is what keeps ghosts off-screen given the
always-run refresh pass (§4.3):

1. unmapped button (`not itm or not next(itm)`) -> Hide (Buttons.lua:310),
2. collapsed empty that is not the representative `_emptyRep` -> Hide
   (Buttons.lua:318-323),
3. item excluded by the active filter (`not PassesItemFilter`) -> Hide
   (Buttons.lua:328),
4. bar marked hidden and not force-shown -> Hide (Buttons.lua:346).

Then it sets texture (item icon, battlepet icon, or dimmed bag icon for an empty
slot), quality overlay, quest overlay, junk-coin (uses `I_NOVALUE` — see the §2
finding), count (overridden to `freeSlots` on the collapsed representative,
Buttons.lua:396-398), edit-mode/new-item/search alpha, rarity border, and finally
delegates to `UpdateLock` and `UpdateCooldown`.

`I_TIMESTAMP` is read unconditionally for the new-item age
(`time() - itm[I_TIMESTAMP]`, Buttons.lua:412); the scan guarantees it is always
set (ResetNew at TBag.lua:4436 backfills nil), and persisted alt records carry it
from their own last scan.

---

## 6. Alt-view caches and their `D_BAG` keying

Four read-only caches mirror storage the player is not currently standing at.
They are keyed per `playerid` and use the dummy bag id `D_BAG = 69`
(TBag.lua:289) as a single synthetic container so the existing
`itmcache[bag][slot]` shape is reused without colliding with real bag ids.

| Cache | Writer | Shape | Notes |
|-------|--------|-------|-------|
| `TFuContItm` | `GetPlayerBag` (TBag.lua:486) | `[playerid][D_BAG][bag]` = bag-summary record | Container/bag preview; per-bag summary (free/size/type/link), seeded by `ClearItmCache` over `Inv_Bags` + `Bnk_Bags` at Init (TBag.lua:361-365) |
| `TFuBodyItm` | `ScanEquipped` (TBag.lua:5135) | `[playerid][D_BAG][slotNum]` = item record | Equipped gear; rebuilt fully each scan (`= {}` per slot); keyed by `Body_Slots` value (TBag.lua:268) |
| `TFuMailItm` | `ScanMail` (TBag.lua:5166) | `[playerid][idx][slot]` = item record | Mailbox; `TFuMailItm[S_VERSION]=1` schema guard (TBag.lua:339); fully rebuilt each `MAIL_INBOX_UPDATE` |
| `TFuTknItm` | `Tokens.lua:47-53` | `[playerid][D_BAG]` = token records | Currency; populated by the Tokens module |

These are scanned only for the live player (`ScanEquipped`/`ScanMail` write
`self.PLAYERID`) and read for any selected character. They are **not** routed
through `UpdateItmCache` (which bails on a non-live playerid, §1.3) nor through
the `BUTTONS` map rebuild — they back the search aggregation
(`GatherSearchResults`, TBag.lua:906-909) and the bag/token tooltips
(`BagButton:OnEnter` TBag.lua via Buttons.lua:601, `Tokens.lua:124`), not the
main item grid. `RemovePlayer` (TBag.lua:2930-2933) drops all four for a deleted
character.

`ScanEquipped` (TBag.lua:5159) and `ScanMail` (TBag.lua:5203) both call
`MakeToolTipStr(playerid, ...)` with `playerid` as an *undeclared global* (nil)
and, in `ScanEquipped`, `idx` also nil; the args still land in the correct
`MakeToolTipStr` branch (SetHyperlink / SetInboxItem) because the routing keys
off `mailitem`/`attach`/`bag`/`slot`, and the nil `playerid` is unused there.
**[→ FINDINGS]** (low — confusing, latent if the routing ever changes).

---

## 7. Quick map for future work

| I want to change… | Start in… |
|-------------------|-----------|
| What a scanned slot stores | `UpdateItmCache` (TBag.lua:4253), `CreateItm` (4239), the `I_*` table (84-148) |
| How "did this slot change" is decided | `UpdateItmCache` link-compare (TBag.lua:4377) + `catStamp` (4496-4515) |
| When the window pays its resort debt | `Inv:UpdateWindowBody` (TInv.lua:1418) / `Bank:UpdateWindow` (TBnk.lua:2348) |
| Which button shows which item | the `BUTTONS` relink (TInv.lua:1466 / TBnk.lua:2405) + `GetItmFromFrame` (TBag.lua:4021) |
| A button's per-frame look | `ItemButton.Update` (Buttons.lua:303) and its `UpdateLock`/`UpdateCooldown`/`UpdateQualityOverlay` delegates |
| Live-vs-cached behavior | `IsLive` (TBag.lua:738) + the OnHide `atbank` scoping (MainFrame.lua:241) |
| An alt-view (gear/mail/currency/bags) | `ScanEquipped`/`ScanMail` (TBag.lua:5135/5166), `GetPlayerBag` (486), `Tokens.lua` |
| A moved/removed container API | `compat-12.lua` (the positional `GetContainerItemInfo` shim, lines 29-41) |

See [`ARCHITECTURE.md`](ARCHITECTURE.md) for the whole-addon map and the other
phase pointers.
