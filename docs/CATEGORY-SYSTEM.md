# TBag-fufu — Category & Sort System (Phase 1 deep-dive)

> **Status:** Phase 1 subsystem reference, built 2026-06-01 against the live
> source. Describes the **category + sort** subsystem in depth: how an item is
> assigned to a category (a "bar") and ordered within it. Companion to
> [ARCHITECTURE.md](ARCHITECTURE.md) §8 (overview); read that first for the
> `TFuBag` namespace, the `I_*` item-cache codes, `REQ_*`/`catGen` resort
> discipline, and the scan -> categorize -> sort -> layout pipeline. This file
> does not repeat that vocabulary, only uses it.
>
> **Scope:** the rule engine (`DefaultSearchList`), the two reagent modes,
> `PickBar`, category->bar assignment (`AssignCats`/`SetCatBar`/`GetCat`), the
> categorizing sort (`SortItmCache`) + within-bar comparator (`SubSortKey`), the
> `catGen`/`catStamp` memo, and the producer/consumer contract of the `I_CAT` /
> `I_BAR` / `I_SUBGROUP` fields. Forward-pointers to the bug audit are marked
> **[→ FINDINGS]** (see the review's findings list, not this file).
>
> **Not shipped:** `docs/` is excluded from both release paths.

---

## 1. The two-axis model: category vs. bar

Categorization resolves two related-but-distinct values for every item:

- **Category** (`I_CAT`, code `"c"`) — a **localized display string** (e.g.
  `L["WEAPON"]`, `"Herbs"`, `string.format(L["SOULBOUND_%s"], L["TRINKET"])`).
  It is the box's *identity* and the persisted, user-visible label. It is also
  the key into `cfg.subgroup_order[I_CAT]` (TBag.lua:1213) — which is why a
  localized string, not a stable id, is the key.
- **Bar** (`I_BAR`, code `"r"`) — the **integer slot number** (1..`BAR_MAX-1`)
  the category's box draws in. `BAR_MAX = 48`, `EMPTY_BAR = 48` is the reserved
  bottom "Empty" box (TBag.lua:52/58). Many categories may share one bar (the
  user can collapse several categories into one box).

The map from category-string to bar-number is `cfg[CAT_BAR]` (`CAT_BAR =
"catbar"`, TBag.lua:74), accessed only through `SetCatBar` / `GetCat`
(TBag.lua:2969/2991). `GetCat(cfg, key)` returns whatever `cfg.catbar[key]`
holds — which may itself be **another category string** (an alias), so every
caller resolves it in a `while type(...) ~= "number"` loop (see §5.1).

A third value exists only for equipment:

- **Sub-group** (`I_SUBGROUP`, code `"sg"`) — an armor-slot or weapon-type label
  (e.g. `"Head"`, `"Swords"`) used for the within-box sub-shelves and the
  within-bar sub-sort. Set in `PickBar` only; `nil` for everything else.

---

## 2. Rule input: the schema

### 2.1 `DefaultSearchList` (defaults.lua:12-463)

An **ordered** array. Each rule is a 5- or 6-element array:

```
{ Category, Keywords, TooltipSearch, ItemType, ItemSubType, [tag] }
   [1]        [2]         [3]            [4]        [5]        [6]
```

| Field | Meaning | Matched against |
|------:|---------|-----------------|
| `[1]` | Category to assign (localized string) | — (the result) |
| `[2]` | Keyword token | membership in `itm[I_KEYWORD]` (a set) |
| `[3]` | Tooltip substring (a **Lua pattern**) | `string.find(tooltip, ...)` |
| `[4]` | Item class string | `itm[I_TYPE]` (GetItemInfo 6th return) |
| `[5]` | Item subclass string | `itm[I_SUBTYPE]` (GetItemInfo 7th return) |
| `[6]` | Optional tag: `"psplit"` / `"ci"` | controls matching mode (see §2.3) |

An **empty** field (`L[""]`, which the locale metatable resolves to `""`,
localization.enUS.lua:62) means "don't test this axis." A rule with all of
fields 2-5 empty would match **every** item; such all-empty rules are explicitly
skipped (see §4, the old "UNKNOWN catch-all" bug, defaults.lua:459-462 and the
`allEmpty` guard in PickBar TBag.lua:4843).

### 2.2 Ordering semantics: first-match-wins

`PickBar` walks `cfg.item_search_list` top-to-bottom and `break`s on the first
rule whose every non-empty axis matches **and** whose category resolves to a
real bar number (TBag.lua:4831-4886). Order is therefore load-bearing: a broad
rule placed above a narrow one shadows it. The list is deliberately layered
**specific -> general**: named exceptions (e.g. `"Dwarven Fishing Pole"` ->
WEAPON, defaults.lua:189) precede the generic class rules (`Armor` / `Weapon` /
`Consumable` / `Miscellaneous`, defaults.lua:281-282, 454-455), which precede
the final catch-alls.

The runtime list is `cfg.item_search_list`, a per-window copy seeded from
`DefaultSearchList` and editable in the Categories panel. The editor only ever
touches fields 1-5, so a built-in's `[6]` tag survives user edits/reorders
(defaults.lua:400-401).

### 2.3 The `[6]` tag overload

Field 6 is a single string slot carrying two **mutually exclusive** meanings:

- `"psplit"` — this is an optional per-profession reagent/trade-good split rule;
  skip it unless `cfg.reagent_split == 1` (see §3). Built-in only.
- `"ci"` — case-insensitive tooltip match: lower-case both `tooltip` and
  `value[3]` before `string.find` (TBag.lua:4856-4858). Used by user-added
  categories so a typo'd-case tooltip phrase still matches.

A rule cannot be both psplit and ci. Built-in psplit rules carry an empty
tooltip (field 3), so the ci branch never interacts with them — the overload is
safe in practice. A separate boolean `value.off` (a *named* table field, not
positional) disables a rule from the Categories panel Enabled checkbox
(TBag.lua:1530 writes it, 4844 reads it).

### 2.4 `DefaultItemOverrides` and user `item_overrides`

`DefaultItemOverrides` (defaults.lua:8, currently empty) and the user
`cfg.item_overrides[itemid] = category` table force a specific itemID into a
named category, bypassing the rule loop entirely. Checked **first** in PickBar
(step 1, TBag.lua:4778-4788).

### 2.5 The 12.0 per-material trade-good rules (defaults.lua:347-363)

Twelve rules routing the Trade Goods class by subclass family
(`{ L["Herbs"], "", "", L["Tradeskill"], L["Herb"] }`, etc.). These match on
`I_TYPE == L["Tradeskill"]` + `I_SUBTYPE == <family>`. They sit **above** the
older name/psplit profession rules so materials sort by family by default; the
psplit rules only fire when `reagent_split` is on (PickBar skips psplit
otherwise and falls through to these). `L["Tradeskill"]` resolves to the literal
`"Tradeskill"` in enUS and to the localized class name in deDE/ruRU
(localization.deDE.lua:59, ruRU.lua:61) — i.e. the rule expects the **localized
item-class string** GetItemInfo returns for the Trade Goods class.
**[→ FINDINGS]** this string assumption is the highest-risk Legion->12.0 carry.

### 2.6 The psplit profession rules (defaults.lua:402-435)

Per-profession rules tagged `"psplit"` (Mining/Tailoring/Blacksmithing/...,
plus the dynamic `TRADE1`/`TRADE2` and `%s_CREATED` rules). They match on a
**keyword** (field 2) that `Professions:MakeAllTradeKeywords` stamps into
`itm[I_KEYWORD]` at PickBar time from the account-wide created/reagent DB
(`TBagItemInfo.lua` + live recipe scans). With `reagent_split` on, a character
can show a profession bar it doesn't have — original TBag behavior, kept opt-in
(defaults.lua:389-401).

### 2.7 `TBagItemInfo.lua` — the auto-generated DB (contract only)

A 24k-line **pure-data** file (header: DO NOT EDIT). It defines `TradeCreations`
(itemID -> profession-that-creates-it) and `Reagents` (itemID -> profession ->
created-item set), plus the merge-once installers `RefreshCreations` /
`RefreshReagents` (TBagItemInfo.lua:24305/24342), which `TFuBag:Init` calls once
(TBag.lua:321-322) to seed `TFuBagCfg[S_CREATED]` / `[S_REAGENT]`, then replace
themselves with `do_nothing`. Live recipe scans (`Professions.ScanRecipes`,
Professions.lua:211) **augment** the same two cfg tables at runtime. Consumers:
`Professions:MakeTradeCreationKeywords` / `MakeTradeReagentKeywords`
(Professions.lua:302/326), which read the cfg tables (not the file globals) to
add profession keywords. **Contract:** the file's installer version check and
`Professions.DB_VERSION` must agree — see **[→ FINDINGS]** (they do not: file
checks `~= 3`, code declares `2`).

---

## 3. The two reagent modes (`cfg.reagent_split`)

| Mode | Value | Behavior |
|------|------:|----------|
| **OFF** (default, Baganator-style) | `~= 1` | psplit rules are skipped in the PickBar loop (TBag.lua:4845). Trade goods sort by the per-material subtype rules (§2.5) or fall to the generic `TRADE_GOODS` catch-all (defaults.lua:445). Reagents land in a few generic bars. |
| **ON** ("original TBag look") | `1` | psplit rules also run, splitting reagents/trade goods into Mining/Tailoring/etc. using the account DB (§2.6). |

The gate is a single clause in the rule loop:
`not (value[6] == "psplit" and cfg["reagent_split"] ~= 1)` (TBag.lua:4845). It
does not affect the override / mat_group / equipment fast-paths above the loop.

---

## 4. `PickBar` — the per-item decision flow (TBag.lua:4683-4903)

`PickBar(cfg, playerid, itm, trade1, trade2)` mutates and returns `itm`, setting
`I_CAT`, `I_BAR`, and (equipment only) `I_SUBGROUP`. Flow:

```
0. Empty slot (I_ITEMLINK == nil)
     -> I_CAT = "EMPTY_<bagtypename> SLOTS"  (TBag.lua:4685-4698)
     -> SetBarFromClass; return.   (these route to EMPTY_BAR via SortItmCache, not here)

   Special-bag item, special_bag_sort == 1
     -> I_CAT = "IN_<bagtype> BAG", single synthetic keyword; return. (4710-4725)

   Reset I_KEYWORD set; re-stamp built-in keywords:
     - rarity              -> S_RARITY..rarity          (4733-4735)
     - profession keywords -> MakeAllTradeKeywords      (4737)
     - trade1/trade2 cat bars ensured via SetCatBar     (4739-4756)
     - SOULBOUND / ACCOUNTBOUND / CRAFTINGREAGENT       (4758-4766)
   Build tooltip string (MakeToolTipStr) for field-3 matches. (4771)
   I_CAT = nil; I_SUBGROUP = nil.   (4775-4776)

1. item_overrides[itemid]                                (4778-4788)
1.5 mat_group fast-path: Trade Goods subtype -> group cat (4796-4806)
1.6 armor/weapon fast-path: EquipCat by itemEquipLoc     (4815-4829)
2. the ordered rule loop (first-match-wins)              (4831-4886)
3. UNKNOWN fallback (forced to bar 1 if unresolved)      (4888-4899)
```

### 4.1 Step 1.5 — configurable material grouping

When `cfg.mat_group` maps the item's `I_SUBTYPE` to a non-empty group category,
that wins over the static per-material rules and the psplit split
(TBag.lua:4796-4806). Gated on `itm[I_TYPE] == self.LOCALE["Tradeskill"]` — the
same localized-class-string assumption as §2.5. This is what the Categories
options panel edits (`SetMaterialGroup` -> `OptRefresh`, TBag.lua:1054-1060).

### 4.2 Step 1.6 — configurable armor + weapon grouping (`EquipCat`)

`EquipCat(cfg, itm)` (TBag.lua:1152-1189) resolves equipment by its
**`itemEquipLoc`** (the 4th return of `C_Item.GetItemInfoInstant`,
TBag.lua:1158 — verified against ItemDocumentation.lua:637, locale-independent
`INVTYPE_*`), not by tooltip text:

- Armor: `ARMOR_INVTYPE_SLOT[equipLoc]` -> a per-slot key (`"01_HEAD"`..
  `"13_OFFHAND"`, `"RING"`, `"TRINKET"`, TBag.lua:1085-1103); routed through the
  `cfg.armor_group` merge map (a slot can be merged into another or opted out
  with `""`). Sub-header = the slot's readable label.
- Weapon: `WEAPON_INVTYPE[equipLoc]` -> the single `"WEAPON"` group;
  sub-header = the weapon TYPE (`I_SUBTYPE`).

With `cfg.armor_bind_split == 1` the category is prefixed by bind state
(`SOULBOUND_*` / `ACCOUNTBOUND_*`), so each bind state clusters on its own bar
(TBag.lua:1180-1187). Returns `(category, subLabel)`; PickBar writes `I_CAT` from
the first and `I_SUBGROUP` from the second **only if the category resolves to a
real bar** (TBag.lua:4823-4826). Gated on `cfg.armor_group_enabled == 1`; off,
equipment falls through to the tooltip-line armor/weapon rules in the search list
(defaults.lua:149-282), which still work for backward compatibility.

### 4.3 The rule loop (TBag.lua:4831-4886)

For each enabled, non-all-empty, mode-eligible rule, every non-empty axis is
ANDed: keyword present, tooltip pattern found, `I_TYPE` equal, `I_SUBTYPE` equal.
On full match it resolves the bar (the alias-chasing `while` loop) and `break`s
only if the bar is a number; otherwise it clears `I_CAT` and keeps scanning. The
`allEmpty` guard (TBag.lua:4843) is the fix for the historical "UNKNOWN
catch-all starves later rules" bug.

### 4.4 UNKNOWN fallback (TBag.lua:4888-4899)

Anything unresolved gets `I_CAT = L["UNKNOWN"]`; if even that category has no bar
mapping it is force-pinned to bar 1. So `I_BAR` is **never** left nil for a
real item exiting PickBar — a guarantee `SortItmCache` and the layout rely on.

---

## 5. Category -> bar assignment

### 5.1 The alias-chasing resolver

`GetCat(cfg, key)` (TBag.lua:2991) returns `cfg.catbar[key]`. Because a value may
be another category name (an alias / "collapse into" pointer), every consumer
loops:

```lua
itm[I_BAR] = self:GetCat(cfg, itm[I_CAT]);
while (itm[I_BAR] ~= nil and type(itm[I_BAR]) ~= "number") do
  itm[I_BAR] = self:GetCat(cfg, itm[I_BAR]);
end
```

This pattern is duplicated verbatim at TBag.lua:4781-4784, 4800-4803, 4819-4822,
4874-4877, 4891-4894, and factored into `SetBarFromClass` (TBag.lua:4674-4680).
**[→ FINDINGS]** the loop has no cycle guard — a self-referential or circular
alias map (`catbar[A]=B, catbar[B]=A`) would spin forever.

### 5.2 `AssignCats` (TBag.lua:2903-2912)

Walks `cfg.item_search_list` and, for any rule whose category has **no** bar
mapping yet, assigns it to bar 1 (announcing it in chat) via
`SetCatBar(cfg, cat, 1, reset)`. This is the safety net that guarantees every
rule's category is reachable; it runs from config-init / cleanup paths.

### 5.3 `SetCatBar` (TBag.lua:2969-2980)

Writes `cfg.catbar[cat] = bar`, but **only creates** a mapping if absent unless
`reset == 1`. So existing user assignments survive a defaults refresh; a forced
reassignment passes `reset = 1`.

---

## 6. `SortItmCache` — the categorizing sort (TBag.lua:4517-4671)

One pass per `REQ_MUST` update. Two phases:

### 6.1 Categorize + bucket into bars

```
wipe FORCED_SHOW and every baritm[bar]                     (4530-4541)
resolve the owning frame + (bank) the solo-selected tab     (4551-4559)
for each shown bag, for each non-empty slot:
    if GetCatStamp(playerid,bag,slot) ~= catGen:            (4582)
        itm = PickBar(...); SetCatStamp(..., catGen)        (4583-4585)   <- the memo
    destbar = itm[I_BAR]
    if empty  -> tally freeCount/dropBag; (collapse off) push to EMPTY_BAR
    elseif destbar is a number and passes the item filter -> push to baritm[destbar]
```

Key contracts:

- **Empties never use their PickBar `I_BAR`.** They are detected by
  `I_ITEMLINK` nil/"" (TBag.lua:4588) and routed to `EMPTY_BAR` (one bottom box),
  or collapsed to a single representative (`collapse_empty`, 4631-4638). PickBar's
  empty-slot `I_CAT`/`I_BAR` (step 0) is effectively display metadata only.
- **`PassesItemFilter`** (active search/expansion/BoE filter) can drop an item so
  it gets no slot; the layout reflows survivors with no gaps (4604-4614).
- **Bank view scoping:** `bagarr` spans only the active bankType's bags, so
  `freeCount`/`dropBag` resolve to the viewed bank (char vs warband) automatically.

### 6.2 Within-bar sort (TBag.lua:4642-4667)

For each bar with a sort mode of `SORTBY_NORM` (toggle 1) or `SORTBY_REV`
(toggle 2), `table.sort` compares the **concatenation**:

```
I_CAT .. SubSortKey(cfg,itm) .. ReverseString(I_NAME,toggle)
       .. format("%04s",I_COUNT) .. format("%02s",I_SLOT)
```

compared with `>` (descending string compare). Consequences:

- `I_CAT` leads, so multiple categories sharing one bar stay grouped by category.
- `SubSortKey` (§7) clusters equipment sub-groups next.
- `ReverseString` (TBag.lua:430-450) word-reverses the name when toggle==2
  ("Major Mana Potion" sorts as "Potion Mana Major").
- `%04s`/`%02s` are **string** width-pads, not numeric — count/slot tie-break is
  lexicographic, so counts/slots wider than the pad sort oddly. Pre-existing TBag
  behavior. **[→ FINDINGS]** also: a nil `I_CAT`/`I_NAME`/`I_COUNT` here would
  error the comparator; PickBar's UNKNOWN fallback + UpdateItmCache's `I_NAME=""`
  default (TBag.lua:4375) are what keep that from happening.
- `SORTBY_NONE` (0) leaves bag/slot insertion order (no sort).

---

## 7. `SubSortKey` and sub-group ordering (TBag.lua:1211-1219)

`SubSortKey(cfg, itm)` produces the sub-group fragment of the sort key, honoring
a user drag-reorder stored in `cfg.subgroup_order[I_CAT][subLabel] = rank`:

```lua
local sl = itm[I_SUBGROUP] or "";
local r  = cfg.subgroup_order[itm[I_CAT]] and ...[sl];
if (r) then return "1"..format("%04d", 9999 - r); end  -- ranked: leads "1", rank1 largest
return "0"..sl;                                          -- unranked: leads "0", raw label
```

Because the comparator sorts **descending**, a ranked fragment must be *larger*
to sort earlier: ranked entries lead with `"1"` and encode `9999 - rank` (rank 1
-> largest); unranked entries lead with `"0"` and fall back to the raw label
(preserving alphabetical order for categories never reordered). Same-label items
share a fragment, so a sub-group stays **contiguous** — a property
`EquipSubPlan` (TBag.lua:1279) depends on when it slices contiguous same-label
runs into shelf clusters.

The reorder is persisted by `ApplySubGroupOrder` (TBag.lua:1358-1366), which sets
the rank map and forces a `REQ_MUST` relayout but **does not** bump `catGen` — it
changes the sort, not categorization (so the catStamp memo is preserved and
PickBar is not re-run). `SubHeaderDrop` (TBag.lua:1372) is the drag-drop handler.

---

## 8. The `catGen` / `catStamp` memo (TBag.lua:4497-4515, 4582-4585)

The expensive part of categorization is `PickBar` (it builds a tooltip string and
walks the rule list). The memo avoids re-running it for unchanged slots:

- `TFuBag.catGen` — a global "categorization generation" counter.
  `BumpCatGen()` (TBag.lua:4499) increments it on any change that invalidates
  *all* categorizations (a rule edit, mat_group/armor-group change via
  `OptRefresh` TBag.lua:1040-1044, a new learned recipe via `ScanRecipes`
  Professions.lua:295-296).
- `catStamp[playerid][bag][slot]` — the `catGen` value at which that slot was
  last categorized (`GetCatStamp`/`SetCatStamp`, TBag.lua:4503-4515).
- `SortItmCache` re-runs `PickBar` for a slot **only when**
  `GetCatStamp(...) ~= catGen` (TBag.lua:4582). A matching stamp keeps the
  slot's cached `I_BAR`/`I_CAT`/`I_SUBGROUP`.
- Slot-level invalidation: `UpdateItmCache` clears the stamp
  (`SetCatStamp(..., nil)`, TBag.lua:4381) when a slot's `I_ITEMLINK` changed, so
  a moved/swapped item re-picks while its neighbours don't.

This collapses a full-bank re-sort to just the slots that actually changed, while
a config change (one `BumpCatGen`) cheaply invalidates everything at once.

### 8.1 Sub-group carry across cache rebuilds (TBag.lua:4319-4324)

`UpdateItmCache` builds a fresh `itm` table each scan and explicitly carries
`I_SUBGROUP` (and `I_BAR`/`I_CAT`/`I_KEYWORD`/...) from the prior cache record.
This matters because on a stamp-current `BAG_UPDATE` PickBar is skipped, so
without the carry the fresh `itm` would lose `I_SUBGROUP` and the box would
silently revert to a flat (no sub-header) render even though `I_CAT` still held
the equipment category.

---

## 9. Producer / consumer contract of `I_CAT` / `I_BAR` / `I_SUBGROUP`

| Field | Produced by | Consumed by |
|-------|-------------|-------------|
| `I_CAT` (`"c"`) | `PickBar` (all paths); carried by `UpdateItmCache` (4318) | `SortItmCache` comparator key (4654/4660); `SubSortKey` map key (1213); the per-box `CatName` label (LayoutWindow drawRow); `SubHeaderDrop` catKey (1375); Buttons.lua highlight/dim (Buttons.lua:124,162,407); `PrintCategoryContents` diag (4964) |
| `I_BAR` (`"r"`) | `PickBar` (all paths, via `GetCat` alias chase); carried by `UpdateItmCache` (4315) | `SortItmCache` bucketing `baritm[destbar]` (4608-4613); Buttons.lua bar-level group settings `GetGrp(...,I_BAR)` (Buttons.lua:351,418); `BUTTONS` record (Buttons.lua:183,548) |
| `I_SUBGROUP` (`"sg"`) | `PickBar` step 1.6 **only** (`EquipCat` 2nd return, 4826); else nil; carried by `UpdateItmCache` (4324) | `SubSortKey` (1212); `BarHasSubgroups` (1194-1199); `EquipSubPlan` cluster runs (1289-1295); `SubGroupOrderedLabels` (1344-1352); LayoutWindow sub-header draw (`isSubBar`, 7416-7417) |

Invariants the consumers assume:
1. `I_BAR` is a number for every non-empty item (PickBar UNKNOWN fallback
   guarantees it; `SortItmCache` still guards `type(destbar)=="number"` at 4608).
2. `I_CAT` is non-nil for every item placed in a bar (used unguarded in the
   comparator concat).
3. Same `I_SUBGROUP` label = contiguous after sort (SubSortKey guarantees;
   EquipSubPlan relies on it).
4. `I_SUBGROUP` survives a stamp-current rebuild only because of the explicit
   carry at 4324 — a producer/consumer coupling that is easy to break if the
   carry list and PickBar's outputs drift (e.g. a future new `I_*` field set in
   PickBar but not added to the carry block).

---

## 10. Quick orientation

| I want to change… | Start in… |
|-------------------|-----------|
| Which category an item lands in | `defaults.lua` `DefaultSearchList` (order!) + `PickBar` (TBag.lua:4683) |
| Trade-good family routing | defaults.lua:347-363 + `cfg.mat_group` (PickBar step 1.5, 4796) |
| Armor/weapon grouping | `EquipCat` (1152) + `ARMOR_INVTYPE_SLOT`/`WEAPON_INVTYPE` (1085/1135) |
| Reagent split on/off | `cfg.reagent_split` gate (PickBar 4845) + psplit rules (defaults.lua:402) |
| Within-bar order | `SortItmCache` comparator (4642) + `SubSortKey` (1211) |
| Sub-group order | `cfg.subgroup_order` + `ApplySubGroupOrder` (1358) / `SubHeaderDrop` (1372) |
| Why a slot didn't re-categorize | `catGen`/`catStamp` memo (4497-4515, 4582) |
| Category -> bar mapping | `SetCatBar`/`GetCat`/`AssignCats` (2969/2991/2903) |
