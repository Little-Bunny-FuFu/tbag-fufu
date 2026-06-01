# TBag-fufu — The Bank Subsystem (Phase 1)

> **Status:** Subsystem deep-dive, built 2026-06-01 against the live source. Companion
> to [`ARCHITECTURE.md`](ARCHITECTURE.md) (Phase 0 map) — read that first for the shared
> vocabulary (`TFuBag` global, `I_*` cache keys, SavedVariables, the
> event → `RequestUpdate`(debounce) → `UpdateWindow` → scan → categorize →
> `LayoutWindow` pipeline, `REQ_*`/`catGen`). This file describes *what the 12.0 bank
> rewrite does and why* — not a bug list (those are the review's FINDINGS).
>
> **Scope note:** Part of the multi-phase review. This is the Phase 1 bank deep-dive.
> The bank is the single largest functional rewrite in the Legion→Retail 12.0 revival
> and the highest-risk code.
>
> **Not shipped:** `docs/` is excluded from both release paths (`.deployignore` `[dirs]`
> and `.pkgmeta` `ignore:`).

---

## 0. Why the bank had to be rewritten

The Legion-era bank API the original TBag was written against is **gone** in 12.0:

- `BANK_CONTAINER` (-1), `REAGENTBANK_CONTAINER` (-3), the 7 purchasable bank-bag
  slots, `GetNumBankSlots`, `GetBankSlotCost`, `GetReagentBankCost`,
  `IsReagentBankUnlocked`, `DepositReagentBank`, `BankButtonIDToInvSlotID` — all
  removed or inert. `compat-12.lua:96-103` reduces them to historical constants and
  safe no-op stubs (`return 0`/`false`) purely so the *non-bank* code paths that still
  reference them don't nil-crash.
- The classic fixed bank is replaced by a **tab-as-container model** read with the
  same `C_Container` calls as bags, plus a dedicated `C_Bank` system for
  session/tab/money operations.

The rewrite lives mainly in `TBnk.lua` (2,554 lines), `TBnkTabSettings.lua` (the
tab-settings dialog), their `.xml`, and the bank events in `Events.lua`. The design
note `tbag-fufu-bank-rewrite-design.md` is the historical rationale.

Two **deliberate non-goals**, both for taint-safety (see §8):
- We do **not** hijack Blizzard's `BankFrame` (no `SetReplaceBank`, no event steal).
  It opens normally alongside our window — exactly what Syndicator/Baganator do.
  `Bank:SetReplaceBank` is explicitly removed (`TBnk.lua:2521`).
- We never read or write Blizzard's secure bank objects (`BankPanel`,
  `BankPanelTabSettingsMenu`). All bank state changes go through public
  `AllowedWhenUntainted` `C_Bank.*` calls.

---

## 1. The tab-as-container model

A 12.0 bank is a set of **tabs**, each of which is a container addressed by an
`Enum.BagIndex` id and read with `C_Container.GetContainerItemLink/Info/...` just like
a bag. Verified against `wow-ui-source` `BagIndexConstantsDocumentation.lua`:

| Bank type | `Enum.BankType` | Tabs | `Enum.BagIndex` | ids |
|-----------|-----------------|------|-----------------|-----|
| Character (personal) | `Character` | `CharacterBankTab_1..6` | 6–11 | per-character |
| Warband (account) | `Account` | `AccountBankTab_1..5` | 12–16 | account-wide |

`TBag.lua` constants:
- `BAGMIN = REAGENTBANK_CONTAINER` (-3), `BAGMAX = 16` (raised from 11 so the warband
  tabs 12–16 fit; every bank helper bounds-checks `[BAGMIN, BAGMAX]`) — `TBag.lua:227-232`.
- `MAX_BANKTAB_ITEMS = 98` (tabs hold 98 slots; the 50-slot `MAX_CONTAINER_ITEMS`
  fallback would leave slots 51–98 with no button frames) — `TBag.lua:234`,
  `GetBagMaxItems` `TBag.lua:3460-3470`.
- `TFuBag:IsBankTab(bag)` = `bag >= 6 and bag <= 16` — `TBag.lua:247-249`. This is the
  single predicate that distinguishes the new tab containers from worn bag-items
  throughout the engine (it gates the `ContainerIDToInventoryID` worn-bag lookups,
  the deposit-eligibility lock suppression, the empty-slot category naming, etc.).

`TFuBag.Bnk_Bags` is **not static** — it is the list of *currently-active* tab ids,
rebuilt on every bank open / type switch / character switch (`Bank:RebuildTabList`
sets both `self.bags` and the global `TFuBag.Bnk_Bags`, `TBnk.lua:505-508`). It is
empty until the first `BANKFRAME_OPENED`.

### Tab container frames + buttons (lazy creation)

The tab set isn't known until `BANKFRAME_OPENED`, so the per-tab dummy bag frames and
their 98 item buttons are built lazily in `RebuildTabList` (`TBnk.lua:552-577`):

- Character tabs 6–11 reuse the static XML frames `TFuBnkainerFrame6..11`
  (`GetDummyBagFrameName`, `TBag.lua:3388-3402`); warband tabs 12–16 have no XML frame,
  so they are `CreateFrame`'d under the scroll content frame.
- All tab frames are **reparented** into the WowScrollBox content frame
  (`self.bnkContainer`, cached in `Bank:init`, `TBnk.lua:158-161`). The XML character
  tabs are children of the main frame, not the scroll content, so without the reparent
  an overflowing character bank's items bleed past the scroll viewport over the bottom
  chrome (`TBnk.lua:561-572`). (This depends on the `clipChildren` cascade — see the
  global XML-pitfalls note.)
- `self.tabFramesCreated[bag]` memoizes which tabs' buttons have been built so the
  expensive `CreateDummyBag` runs once per tab id.

---

## 2. The live vs cached-view state machine

This is the heart of the rewrite and the most bug-prone area (the just-fixed BUG-1 was
here). Three pieces of state, each gating different behavior:

### 2.1 `physAtBank` — the physical-banker latch

- Set to 1 on `BANKFRAME_OPENED` (`Events.lua:174`) and in `RefreshLiveFlag` when
  Blizzard's bank panel is shown.
- Cleared to 0 on `BANKFRAME_CLOSED` (`Events.lua:190`) and in `MainFrame:OnHide` when
  the tbag window is hidden (`MainFrame.lua:230-233`).
- Gates the live-only event refreshes in `Events.lua` (`BANK_TABS_CHANGED`,
  `BANK_TAB_SETTINGS_UPDATED`, `PLAYER_ACCOUNT_BANK_TAB_SLOTS_CHANGED` all early-out
  unless `physAtBank == 1`).

### 2.2 `BankFrame:IsShown()` — the authoritative session signal

`Bank:IsBankSessionLive()` (`TBnk.lua:301-303`) reads `BankFrame:IsShown()`. This is
the **authoritative** "a server-side bank session exists right now" signal, and it is
read-only (no taint). Verified against `wow-ui-source`:
`BankFrame_Open` does `ShowUIPanel(BankFrame)` on the session opening, and
`BankFrameMixin:OnHide` calls `C_Bank.CloseBankFrame()` — so the panel being shown ==
an open session (`Blizzard_UIPanels_Game/Mainline/BankFrame.lua:79-99`).

Why not trust `physAtBank` alone? The global `CloseBankFrame()` that `MainFrame:OnHide`
calls is an **intentional no-op** (`compat-12.lua:110`; the real session close is
`C_Bank.CloseBankFrame()`). So closing the *tbag* window clears `physAtBank` but leaves
the server session (and Blizzard's bank) alive. Trusting the latch alone caused the
"Show Bank toggle reopens the CACHED bank instead of the live one while still at the
banker" desync — the documented motivation for consulting `BankFrame:IsShown()`
(`TBnk.lua:288-300`).

### 2.3 `atbank` — the derived "live AND mine" flag

`Bank:RefreshLiveFlag()` (`TBnk.lua:315-329`) is the single recompute point:

```
if IsBankSessionLive() then physAtBank = 1 end          -- heal the latch upward
if physAtBank == 1 and playerid == PLAYERID then
  atbank = 1
else
  atbank = 0
end
```

So `atbank == 1` means **a live session is open AND we are viewing our own
character**. Only then do the `C_Bank` reads return real data and the live controls
(deposit / money transfer / buy tab / tab settings) apply. Viewing another character,
or our own bank away from a banker, is `atbank == 0` — a cache-only read-only view.
Recomputed wherever the player selection or physical state can change: `RebuildTabList`
(`TBnk.lua:406`), which is called from `BANKFRAME_OPENED`, `OnShow`, the dropdown
switch, `SetBankType`, and the bank-tab events.

### 2.4 What each flag gates

| Consumer | Flag | file:line |
|----------|------|-----------|
| Rescan tab/bag slots in `UpdateItmCache` (else read cache) | `atbank` arg | `TBag.lua:4276`, `TBnk.lua:2355` |
| `GetSlotInfo` live size/free refresh | `TFuBnkFrame.atbank == 1` | `TBag.lua:3546` |
| `GetBagType` live worn-bag lookup | `atbank == 1` | `TBag.lua:3305` |
| Deposit-eligibility greying (`IsItemBankIneligible`) | `bnk.atbank == 1` | `TBag.lua:260` |
| Cooldown ticks / lock desaturation (`IsLive`) | `frame.atbank ~= 1` | `TBag.lua:738-747` |
| Deposit button / money controls / tab settings shown | `atbank == 1` | `TBnk.lua:950, 1107, 815` |
| Warband money balance display | `atbank == 1` | `TBnk.lua:2437` |
| "Select Character" menu offered | `atbank == 0` | `TBnk.lua:1947` |

### 2.5 `IsLive` and the BUG-1 invariant

`TFuBag:IsLive(frame)` (`TBag.lua:738-747`):
```
if frame.playerid ~= PLAYERID then return false end
if frame.atbank and frame.atbank ~= 1 then return false end
return true
```
Note the `frame.atbank and ...` short-circuit: a frame whose `atbank` is **nil** is
always live (for the own character). This is the load-bearing invariant behind BUG-1:

> `atbank` is a *bank-session* flag; only the bank window owns it. `MainFrame:OnHide`
> is shared (mixed into both windows), so an unconditional `atbank = 0` there also wrote
> it onto the **inventory** frame — which never sets it back. `IsLive` then treated 0 as
> "not live" (0 is truthy and `0 ~= 1`), so once the inventory window had been hidden
> once, `IsLive(TFuInvFrame)` stayed false and `UpdateLock`/cooldowns bailed until
> `/reload`. The fix scopes the reset to `if self == TFuBnkFrame` (`MainFrame.lua:241-243`),
> keeping the inventory frame's `atbank == nil`. (Confirmed: `TInv.lua` never assigns
> `atbank`.)

---

## 3. The snapshot persistence model

So that a character's bank can be browsed from cache (from another character, or away
from the banker), the **tab layout** (ids + name/icon) is snapshotted separately from
the **item contents** (which live in `TFuBnkItm[playerid][bag][slot]`, per Phase 0 §6.1):

| Snapshot | Stored in | Scope | save / load |
|----------|-----------|-------|-------------|
| Character bank tabs | `TFuBagInfo[playerid].bankTabs_char` | per-character | `SaveCharTabSnapshot` / `LoadCharTabSnapshot` (`TBnk.lua:335-360`) |
| Warband bank tabs | `TFuBagCfg.bankTabs_warband` | account-wide | `SaveWarbandTabSnapshot` / `LoadWarbandTabSnapshot` (`TBnk.lua:364-382`) |

Each snapshot is `{ viewable = bool, tabs = { {ID, name, icon}, ... } }`. `viewable`
mirrors `C_Bank.CanViewBank` so an empty-but-viewable bank still snapshots (stays
reachable to buy a first tab). An empty `tabs` list is normalized to `nil` on load so
the "pick a type that actually has tabs" logic matches the live path.

**Snapshot write happens only when live** (`RebuildTabList`, `TBnk.lua:431-445`): at
our own banker we fetch authoritative `C_Bank.FetchPurchasedBankTabData` AND persist
the snapshot. Otherwise we render from the snapshot.

`DeriveTabsFromCache(playerid, lo, hi)` (`TBnk.lua:391-403`) is the fallback for a
character that has a persisted **item** cache but no tab **snapshot** (cached under an
older build before snapshotting existed): it synthesizes a tab list from whichever bags
in `[lo, hi]` actually hold cached slots, with placeholder names. Used only for the
character range (6, 11); the next live visit overwrites it with the real snapshot.

---

## 4. `RebuildTabList` flow (`TBnk.lua:405-587`)

The dynamic heart of the bank. One pass per open / switch:

1. `RefreshLiveFlag()` → recompute `atbank`; `live = (atbank == 1)`.
2. `HideAllTabButtons()` — clear the currently-shown item buttons before rebuilding.
   Every character reuses character-tab ids 6–11, so a dropdown switch keeps the same
   `self.bags` and the previous character's buttons would linger at stale positions
   otherwise (`TBnk.lua:408-416`).
3. **Tab sources:**
   - *Live:* `FetchTabsFor(Character)` + (if `BANK_INCLUDE_WARBAND` and the warband
     bank is not locked — `C_Bank.FetchBankLockedReason(Account) == nil`)
     `FetchTabsFor(Account)`; then persist both snapshots.
   - *Not live:* **character bank only**. `LoadCharTabSnapshot`, falling back to
     `DeriveTabsFromCache(6, 11)`. Warband is account-wide and only meaningful live, so
     it is never offered in a cached view; `self.bankType` is forced to `Character` when
     not live (`TBnk.lua:480`) so a stale Warband selection can't carry to an alt.
4. **Selectable types** = those `IsBankViewable` (= `C_Bank.CanViewBank`, with
   "has purchased tabs" fallback) — shown even with zero tabs, so an empty Character
   bank is reachable to buy a first tab.
5. **Pick the active type:** keep the current `bankType` if still selectable; else
   auto-pick a selectable type that has tabs, else the first selectable type.
6. Build `ids` + `tabData[id] = {name, icon, bankType}` from the active type's tabs;
   set `self.bags`, `self.tabData`, `self.availableBankTypes`, `TFuBag.Bnk_Bags`.
7. **One-shot full-sort flag:** if the active tab id set changed vs the previous one,
   set `self.CACHE_REQ = REQ_MUST` (`TBnk.lua:517-523`). A warm persisted `TFuBnkItm`
   would otherwise make `UpdateItmCache` report "no change" → `REQ_PART` → skip the
   resort → categories unsorted until something else forced a recat (the "switch tabs
   to make it sort" symptom). An unchanged set (same-session reopen) does **not** set
   it, so there is no per-open re-sort lag.
8. **Per-tab config defaults:** seed `show_Bag<id>`, a cycled default border color
   (`TAB_DEFAULT_COLORS`, chosen to avoid rarity-color confusion), and the per-tab
   `EMPTY_<name>_SLOTS` category → bar 29 so empty tab slots render as drop targets
   (`TBnk.lua:529-549`). These can't be seeded at login because the tab list is empty
   then.
9. Lazily create tab container frames + buttons (§1); `HideInactiveTabButtons()`;
   `RefreshTabStrip()`.

---

## 5. Bank-type switching (Character ↔ Warband)

- `Bank:SetBankType(bankType)` (`TBnk.lua:1038-1056`): no-op if unchanged; else
  `HideAllTabButtons` → set `bankType` → `RebuildTabList` → (if the Manual Layout is
  still the auto-seeded arrangement, wipe its store so it re-seeds for the new type's
  different category set) → `UpdateWindow(REQ_MUST)` → repaint the inventory window
  (deposit-eligibility greying tracks the active bank type).
- `Bank:ToggleBankType` (`TBnk.lua:1060-1075`): the `/tbnk`-driven flip between the two
  available types.
- The selector strip (`BuildTabStrip` / `RefreshTabStrip`, `TBnk.lua:632-1035`) renders
  the Character/Warband view-switch icon buttons (shown only when that type is
  viewable; the active one carries a 2px gold selection border), one selector button
  per active tab, the buy-tab affordance, and the warband money deposit/withdraw
  buttons. Per-tab buttons are `CheckButton`s named `TFuBnkTabBtn<id>` so
  `GetBagFrameName`/`GetBagFrame` resolve to them and the existing spotlight + color
  machinery (`UpdateBagColors`, `TBag.lua:3798`) works unchanged. `self.tabSel[bag]` is
  the authoritative checked state (driven so the engine's built-in checkbox toggle
  can't desync it, `TBnk.lua:918-930`).

---

## 6. Money, deposit, and tab settings (the secure-handler delegations)

All three of these touch protected operations and are routed through Blizzard code so
the protected call never runs from tainted addon code:

- **Buy tab** (`TBnk.lua:704-718`, `1017-1034`): `C_Bank.PurchaseBankTab` is
  `HasRestrictions = true` (verified `BankDocumentation.lua:280-289`). An addon-shown
  `CONFIRM_BUY_BANK_TAB` popup would run its `OnAccept` tainted → silently blocked. So
  the buy button **inherits** Blizzard's secure `BankPanelPurchaseButtonScriptTemplate`
  (its `OnClick` shows the popup untainted) and is told the type via the
  `overrideBankType` attribute. We deliberately do **not** `SetScript("OnClick")` on it.
- **Warband money** (`TBnk.lua:776-798`, `UpdateMoneyControls` `808-856`): the
  deposit/withdraw buttons drive Blizzard's `BANK_MONEY_DEPOSIT` / `BANK_MONEY_WITHDRAW`
  `StaticPopupDialogs`, whose `OnAccept` (Blizzard code) calls `C_Bank.DepositMoney` /
  `WithdrawMoney`. We pass only `{ bankType = Account }` in the dialog data. Shown only
  when the Account view is active, the player is the live own char, and
  `C_Bank.DoesBankTypeSupportMoneyTransfer(Account)`.
- **Auto-deposit** (`Button_DepositReagent_OnClick`, `TBnk.lua:1233-1238`):
  `C_Bank.AutoDepositItemsIntoBank(bankType)` directly — this is `AllowedWhenUntainted`,
  not restricted. The button is shown only when
  `C_Bank.DoesBankTypeSupportAutoDeposit(bankType)` (`UpdateDepositButton`).
- **Tab settings** (`TBnkTabSettings.lua`): a self-owned frame built on Blizzard's
  shared `IconSelectorPopupFrameTemplate` (never the secure `BankPanelTabSettingsMenu`).
  Reads via `C_Bank.FetchPurchasedBankTabData`, applies via public
  `C_Bank.UpdateBankTabSettings(bankType, tabID, name, icon, depositFlags)` (verified
  `BankDocumentation.lua:291-303`). `depositFlags` is assembled with `FlagsUtil.Combine`
  over `Enum.BagSlotFlags` (verified present: `Flags.lua`, `BagConstantsDocumentation.lua`).
  Gated on `atbank == 1` (`Bank:OpenTabSettings`, `TBnk.lua:947-964`).

---

## 7. Performance decisions

The bank can be ~1000 slots (6 character + 5 warband tabs × 98). The throttles from
Phase 0 §7 are applied with bank-specific extras:

- **No cooldown ticks at the bank.** `BAG_UPDATE_COOLDOWN` intentionally never updates
  the bank window (`Events.lua:137-155`). It fires ~1/sec (more during ability use),
  and a full bank `UpdateWindow` rescans every slot — doing that per tick caused heavy
  lag. You don't use items off cooldown from the bank, so swipes set on open/change are
  enough.
- **`REQ_NONE` vs `REQ_MUST` per event:** `PLAYER_ACCOUNT_BANK_TAB_SLOTS_CHANGED` and
  `PLAYERBANKSLOTS_CHANGED` request a plain (`REQ_NONE`) update — `UpdateItmCache`
  detects the changed slots and recategorizes only those — instead of `REQ_MUST` which
  would re-run the per-item tooltip scan over the whole bank on every move
  (`Events.lua:217-230`). `BANK_TABS_CHANGED` / `BANK_TAB_SETTINGS_UPDATED` /
  `PLAYERBANKBAGSLOTS_CHANGED` *do* request `REQ_MUST` (the tab set / settings really
  changed). `BANKFRAME_OPENED` shows the window with the implicit `OnShow` `REQ_PART`
  and deliberately does **not** force `REQ_MUST` (`Events.lua:178-183`).
- **Debounce:** the shared sliding `RequestUpdate` debounce (Phase 0 §7) collapses the
  burst of slot-changed events from a "Deposit All" or a rapid move stream into one
  rebuild.
- **`GET_ITEM_INFO_RECEIVED` settle pass:** after a `/reload` at the bank the item cache
  is cold, so the first categorizing sort buckets items as UNKNOWN; a debounced
  re-sort fires as item data streams in (`Events.lua:264-280`).
- **One-shot `CACHE_REQ`:** §4 step 7 — full sort fires exactly once on a tab-set
  change, then is cleared (`UpdateWindowBody`, `TBnk.lua:2370-2399`) so it doesn't stick
  high and re-sort every later open.
- **`UpdateWindow` reentrancy guard + pcall:** `Bank.WindowIsUpdating` blocks reentry,
  and the body runs inside `pcall` so a transient nil during a tab-set/type transition
  can't skip the `WindowIsUpdating = 0` reset and wedge the window until `/reload`
  (`TBnk.lua:2301-2315`).

---

## 8. The distance-inhibitor / warband-only path, and taint

- **Distance inhibitor (remote warband):** when accessing the warband bank remotely
  (e.g. a distance inhibitor), the character bank is not viewable but the warband bank
  is. `FetchBankLockedReason(Account)` gates whether warband is fetched
  (`TBnk.lua:435-440`); `~= nil` means locked (matches Blizzard's own check at
  `BankFrame.lua:785`; `BankLockedReason.None` is returned as nil, not 0 — verified
  `BankDocumentation.lua:386-397`). In such a remote-warband open the auto-pick in
  `RebuildTabList` lands on whichever type is selectable.
- **Lock-state false-greying:** opened remotely, `C_Container.GetContainerItemInfo`
  reports tab items as "locked", which would grey already-deposited items. The deposit
  branch never lock-desaturates bank-tab items (`Buttons.lua:254-262`), matching the
  at-banker appearance.
- **Taint posture (confirmed read-only against secure objects):**
  - All `C_Bank.*` reads used are `AllowedWhenUntainted` (verified across
    `BankDocumentation.lua`); the only protected call (`PurchaseBankTab`) and all
    money transfers are delegated to Blizzard secure handlers (§6).
  - We read `BankFrame:IsShown()` but never write `BankFrame` from the new code paths,
    and we do not hijack it (§0).
  - One latent exception lives in dead classic-bank code — see FINDINGS
    (`Buttons.lua:670` writes `BankFrame.nextSlotCost`, reachable only via the
    permanently-hidden classic bag-slot buttons).

---

## 9. Quick orientation

| I want to change… | Start in… |
|-------------------|-----------|
| Which tabs are shown / the active set | `Bank:RebuildTabList` (`TBnk.lua:405`) |
| Live vs cached gating | `Bank:RefreshLiveFlag` (`TBnk.lua:315`) + `IsLive` (`TBag.lua:738`) |
| Character ↔ Warband switch | `Bank:SetBankType` (`TBnk.lua:1038`) + `RefreshTabStrip` (`TBnk.lua:968`) |
| Remote/cached rendering of an alt | the snapshot fns (`TBnk.lua:331-403`) |
| Deposit / money / buy-tab buttons | `BuildTabStrip` (`TBnk.lua:632`), `UpdateMoneyControls`/`UpdateDepositButton` |
| Tab name/icon/deposit-flag dialog | `TBnkTabSettings.lua` + `Bank:OpenTabSettings` (`TBnk.lua:947`) |
| The per-frame pipeline | `Bank:UpdateWindow`/`UpdateWindowBody` (`TBnk.lua:2306/2317`) |
| Bank event wiring | `Events.lua` (`BANKFRAME_*`, `BANK_*`, `PLAYER*BANK*`) |

See [`ARCHITECTURE.md`](ARCHITECTURE.md) for the addon-wide map.
