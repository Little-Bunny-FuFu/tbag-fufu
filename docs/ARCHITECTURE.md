# TBag-fufu — Architecture Map (Phase 0)

> **Status:** Foundation reference, built 2026-06-01 from the live source at commit
> `b974039`. Describes *what the code does and how it fits together* — not a bug
> list. Forward-pointers to later review phases are marked **[→ Phase N]**.
>
> **Scope note:** This is part of a multi-phase code review of the Legion→Retail
> 12.0 revival. Phase 0 = this map. Phase 1 = per-subsystem deep dives. Phase 2 =
> dead/legacy-code audit. Phase 3 = correctness/bug audit. Phase 4 = improvement
> roadmap. This file is the shared vocabulary the other phases lean on.
>
> **Not shipped:** `docs/` is excluded from both release paths
> (`.deployignore` `[dirs]` for `deploy.ps1`, `.pkgmeta` `ignore:` for the
> BigWigs/CurseForge packager).

---

## 1. What this addon is

TBag-fufu is a single-window, auto-categorizing **bag and bank replacement**. It
scans the player's containers, assigns every item to a **category** (a "bar"),
sorts items within each bar, and lays the bars out as boxes in a resizable
window. It is a revival of the abandoned CurseForge `tbag-shefki` (itself a fork
of Talos's TBag), rebranded `-fufu` and brought forward from Legion 7.3
(`Interface 70300`) to Retail 12.0 (`Interface 120005/120007`).

Two live windows exist: the **inventory** window (`TFuInvFrame`) and the **bank**
window (`TFuBnkFrame`). Both are built on one shared base "class". The addon also
keeps **cached, read-only views** of other characters and of mail / equipped
gear / currency, browsable from a character dropdown without being at that
character or that storage.

---

## 2. File inventory

Load order is fixed by `tbag-fufu.toc` (and the nested `*.xml` `<Script>` tags).
Order matters: `compat-12.lua` must run before anything touches a moved API, and
`stub.lua` must create the `TFuBag` global before any file references it.

| # | File | Lines | Responsibility |
|---|------|------:|----------------|
| 1 | `compat-12.lua` | 110 | Re-expose Legion-era globals that 12.0 moved into `C_*` namespaces (Container API, bank, etc.) so the thousands of legacy call sites keep working without per-site edits. **[→ Phase 2/3]** audit which shims are still load-bearing. |
| 2 | `stub.lua` | 3 | Creates the global `TFuBag = CreateFrame("Frame",...)` and registers `VARIABLES_LOADED`. Everything hangs off this frame. |
| 3-5 | `localization.{enUS,deDE,ruRU}.lua` | ~860 ea | `TFuBag.LOCALE` (alias `L`) string tables. `localization.template.lua` is the translation stub (not loaded). |
| 6 | `defaults.lua` | 463 | Default config + the **category rule engine input** (`DefaultSearchList`), `DefaultItemOverrides`, per-material trade-good rules, `psplit` profession rules. |
| 7 | `Tokens.lua` / `.xml` | 172 / 78 | Currency/token tracking (`TFuBag.Tokens`). |
| 8 | `TBag.lua` | **7,858** | **The engine.** Constants, the item-cache data model, scan (`UpdateItmCache`), categorize (`SortItmCache` + `PickBar`), **both layout engines** (auto-flow `LayoutWindow`, Manual-Layout `LayoutWindowFree` + ~15 `ML*` drag fns), equipment sub-groups, search, money, options callbacks. 232 named `TFuBag` methods. **[→ Phase 4]** prime split candidate. |
|  | `TBagCmd.lua` | 194 | Slash commands (`/tbag`, `/tinv`, `/tbnk`, …). |
|  | `Hooks.lua` | 339 | Hooks into Blizzard UI (`TFuBag.Hooks`) — open-bag overrides, etc. |
|  | `Professions.lua` | 361 | Trade-skill scan (`TFuBag.Professions`) feeding the `psplit` category rules. |
|  | `TBagItemInfo.lua` | **24,354** | Auto-generated item→trade/category default data. **DO NOT EDIT** (header says so). Pure data, no logic beyond a `do_nothing` stub. |
|  | `Events.lua` | 320 | Event registration + the **debounced `RequestUpdate`** dispatcher + `OnEvent`. |
|  | `TBagTest.lua` | 835 | Test/dev harness. **[→ Phase 2]** confirm relevance / exclude from ship. |
| 9 | `Buttons.lua` / `.xml` | 788 / 232 | The item-button mixin (`TFuBag.ItemButton`): icon, count, cooldown, lock, tooltip, click handling. |
| 10 | `MainFrame.lua` / `.xml` | 289 / 224 | The shared window base class (`TFuBag.MainFrame`) mixed into both windows: move/drag, dynamic resize grip, OnShow/OnHide, column +/-. |
| 11 | `TInv.lua` / `.xml` | 1,585 / 322 | Inventory window controller (`TFuBag.Inv`, frame `TFuInvFrame`): `init`, `SetPlayer`, `UpdateWindow`, item moves, alt-view scans. |
| 12 | `TBnk.lua` / `.xml` | 2,554 / 337 | Bank window controller (`TFuBag.Bank`, frame `TFuBnkFrame`): the **12.0 tab-as-container bank rewrite**, tab strip, warband tabs, deposit. |
| 13 | `TBnkTabSettings.lua` / `.xml` | 332 / 18 | Per-tab settings dialog (name/icon/deposit flag). |
| 14 | `ModernOpt.lua` | 1,200 | The modern settings UI (`Settings.*` API panels) driving the option callbacks in TBag.lua. |

Non-shipped / tooling: `dist.sh` (svn-era zip script, **[→ Phase 2]** likely
dead — uses `svnversion`), `scrape-wowhead.perl`, `Changelog.txt`, `ToDo.txt`,
`README.md`, `LICENSE`, `bug-reports/` (gitignored), `docs/` (this).

---

## 3. The `TFuBag` namespace

There is **one global**: `TFuBag`, a `Frame`. It is simultaneously:

- the **event sink** (`SetScript("OnEvent", …)`, `OnUpdate`),
- the **constant namespace** (`TFuBag.I_*`, `TFuBag.REQ_*`, `TFuBag.BAR_MAX`, …),
- the **method namespace** (the 232 `TFuBag:Method()` engine functions), and
- the **root of the sub-controllers**, each defined in its own file:

| Sub-table | File | Role |
|-----------|------|------|
| `TFuBag.MainFrame` | MainFrame.lua | Base class for the two windows |
| `TFuBag.Inv` | TInv.lua | Inventory window controller |
| `TFuBag.Bank` | TBnk.lua | Bank window controller |
| `TFuBag.ItemButton` | Buttons.lua | Item-button behavior |
| `TFuBag.Hooks` | Hooks.lua | Blizzard UI hooks |
| `TFuBag.Professions` | Professions.lua | Trade-skill scanning |
| `TFuBag.Tokens` | Tokens.lua | Currency tracking |
| `TFuBag.LOCALE` (`L`) | localization.*.lua | Strings |

The window **frames** (`TFuInvFrame`, `TFuBnkFrame`) are created in XML and have
the `MainFrame` + controller methods mixed onto them, so `frame:UpdateWindow()`
resolves to `Inv:UpdateWindow` / `Bank:UpdateWindow`, while `frame:DragStart()`
resolves to the shared `MainFrame:DragStart`.

---

## 4. Initialization sequence

```
.toc load order (files run top-to-bottom)
  compat-12.lua      -- remap moved APIs onto old global names
  stub.lua           -- TFuBag = CreateFrame(...) ; RegisterEvent("VARIABLES_LOADED")
  localization.*     -- L tables
  defaults.lua       -- DefaultSearchList, DefaultItemOverrides, default cfg
  Tokens / TBag.xml / Buttons / MainFrame / TInv / TBnk / TBnkTabSettings / ModernOpt
                     -- define all the methods + sub-controllers; create frames
        |
        v
VARIABLES_LOADED  (TFuBag:VARIABLES_LOADED, Events.lua:60)
  -> Inv:init(0) ; Bank:init(0)           -- window controllers wire themselves up
  -> RegisterEvent(... ~30 events ...)    -- 12.0 bank events guarded by C_EventUtils.IsEventValid
  -> ScanEquipped()                       -- seed equipped-gear alt view
        |
        v
TFuBag:Init()  (TBag.lua:312)  -- called from the init path
  -> create SavedVariables tables if nil (TFuBagCfg, TFuBagInfo, TFu*Itm)
  -> RefreshCreations / RefreshReagents   -- merge TBagItemInfo defaults into cfg
  -> PLAYERID = UnitName.."|"..REALM
  -> per-player cache init (ClearItmCache for Inv_Bags / Bnk_Bags / dummy bags)
  -> fix negative-id dummy bag frames (BANK_CONTAINER, REAGENTBANK_CONTAINER)
  -> CleanConfig()                        -- migrate/strip stale cfg keys
```

`TFuBag:Init` is the only place the SavedVariables are guaranteed allocated; all
later code assumes `TFuBagCfg` etc. exist.

---

## 5. The window model

`MainFrame` (MainFrame.lua) is the shared base. Key shared behavior:

- **Move/drag:** `DragStart`/`DragStop` save the four edge coords (scaled) into
  `cfg.frameLEFT/RIGHT/TOP/BOTTOM`.
- **Dynamic resize** (Stage 2): a lazily-created `PanelResizeButtonTemplate`
  grip (`EnsureResizeGrip`). Shown whenever `cfg.legacy_sizing == 0`
  (`IsResizable`). `OnResizeStopped` persists `cfg.win_w/win_h` and, in
  auto-seeded Manual Layout, wipes the layout store so the boxes reflow to the
  new width.
- **Show/Hide:** `OnShow` resets to the logged-in player, locks Manual-Layout
  edit (`ml_edit = 0`), and forces `REQ_MUST` if categorization is stale
  (`sortGen ~= catGen`); `OnHide` closes the bank session and resets the player.
- **Body click:** a left-click on the window body with a cursor-carried item
  deposits to a free slot; otherwise it starts a window move.

Each controller (`Inv`, `Bank`) adds the storage-specific parts: which `bags` it
covers, `SetPlayer` (switch to a cached character), `UpdateWindow` (the per-frame
pipeline entry), and item-move plumbing.

**Dummy bag frames:** negative/virtual container ids (e.g. `BANK_CONTAINER`,
`REAGENTBANK_CONTAINER`, and `D_BAG = 69` for the alt views) can't be set from
XML, so `Init` assigns their `SetID` at runtime. The alt-view caches store their
items under `[D_BAG]`.

---

## 6. Data model

### 6.1 SavedVariables (`.toc`)

| Var | Keyed by | Holds |
|-----|----------|-------|
| `TFuBagCfg` | — (+ `["Bnk"]`, `["Inv"]` sub-cfgs) | All config: layout, colors, columns, category rules, overrides, per-window `cat_layout`/`cat_layout_free`/`subgroup_order`, `manual_layout`, `legacy_sizing`, etc. |
| `TFuBagInfo` | `playerid` | Per-character info: trades/skills, class, hearth, level, faction, money. |
| `TFuInvItm` | `playerid → bag → slot` | Cached **inventory** item cache. |
| `TFuBnkItm` | `playerid → bag → slot` | Cached **bank** item cache (incl. 12.0 tab containers). |
| `TFuContItm` | `playerid → D_BAG → …` | Alt view: container/bag preview. |
| `TFuBodyItm` | `playerid → D_BAG → slot` | Alt view: equipped gear. |
| `TFuMailItm` | `playerid → idx → slot` | Alt view: mailbox contents. |
| `TFuTknItm` | `playerid` | Alt view: currency tokens. |

`playerid = "Name|Realm"`. Multi-character browsing reads these caches for a
character you're not currently logged into.

### 6.2 The item-cache record (`I_*` keys)

Every scanned slot is a Lua table keyed by **2-character string codes** (defined
TBag.lua:84-148). Short keys keep the (large, persisted) cache compact. Grouped
by purpose:

| Key | Code | Meaning |
|-----|------|---------|
| `I_BAG` / `I_SLOT` | `b` / `s` | Physical bag id + slot index |
| `I_BAGTYPE`/`I_BAGFREE`/`I_BAGSIZE` | `bt`/`bf`/`bz` | Bag classification, free count, size |
| `I_CAT` | `c` | **Localized category name** (the bar's identity; also the `subgroup_order` key) |
| `I_KEYWORD` / `I_BAR` | `k` / `r` | Matched keyword / assigned bar number |
| `I_ITEMLINK`/`I_ITEMID`/`I_NAME` | `il`/`id`/`in` | Item link, id, name |
| `I_TYPE`/`I_SUBTYPE` | `it`/`is` | Item class / subclass |
| `I_RARITY`/`I_COUNT` | `ir`/`ic` | Quality, stack count |
| `I_SOULBOUND`/`I_ACCTBOUND` | `sb`/`ab` | Bind state |
| `I_CHARGES`/`I_LINKSUFFIX` | `ch`/`ls` | Charges, link suffix |
| `I_EXPANSION`/`I_BINDTYPE` | `xp`/`bd` | expansionID + bindType (captured for the Expansion / BoE filters, incl. cached cross-char views) |
| `I_SUBGROUP` | `sg` | **Equipment sub-group label** (armor slot / weapon type) — drives sub-headers and within-bar sub-sort. Set in `PickBar`; nil otherwise. |
| `I_NOVALUE`/`I_READABLE`/`I_CRAFTINGREAGENT` | `nv`/`rd`/`cr` | Flags |
| `I_QUEST_ITEM`/`I_QUEST_ID`/`I_QUEST_ACTIVE` | `qi`/`qd`/`qa` | Quest-item info |
| `I_HEADER`/`I_EXPAND`/`I_UNUSED`/`I_WATCH`/`I_ICON` | `hd`/`ex`/`un`/`wa`/`io` | Compression / display flags |
| `I_TIMESTAMP`/`I_NEWSTR` | `ts`/`nw` | "New item" tracking (`V_NEWON/OFF/PLUS/MINUS`) |

> Removed-feature marker: `I_REFORGE` is left commented out (reforging died in
> 6.0) as a deliberate "this code used `rf`" reminder.

### 6.3 The transient layout structures (TBag.lua:291-310)

```
itmcache[bag][slot]              -- the per-slot records above (persisted)
bar_positions[bar][position]     -- final placement after sort: {I_BAG=bag, I_SLOT=slot}
TFuBag.BUTTONS[frame_name]       -- live map: button frame name -> itmcache record
stackarr[itemid] = { itms… }     -- itemid -> array of its slot records (stacking)
comparr = { [COMP_EMPTY]={…}, [COMP_ITEM]={…} }  -- special-bag empty/eligible split
```

`BARITM` (per-frame) is the sorted bar→items structure produced by
`SortItmCache` and consumed by `LayoutWindow`.

---

## 7. The core pipeline

A single user action emits a *burst* of events; the addon collapses them.

```
Blizzard event (BAG_UPDATE, BANK_*_CHANGED, ITEM_LOCK_CHANGED, quest, …)
        |
        v
TFuBag:OnEvent  ->  events[event](TFuBag, …)        (Events.lua dispatch table)
        |
        v
TFuBag:RequestUpdate(frame, resort_req)             (Events.lua:23 — DEBOUNCE)
   - no-op if frame hidden
   - record max resort_req of the burst
   - sliding 0.10s debounce, hard cap 0.30s, monotonic token (C_Timer has no cancel)
        |
        v   (one real update per burst)
frame:UpdateWindow(req)        -> Inv:UpdateWindow / Bank:UpdateWindow
        |
        +--> UpdateItmCache(cfg, playerid, itmcache, bags, stackarr, comparr, atbank)
        |       rescan changed slots; returns cache_req (how stale categories are)
        |
        +--> [if resort_req >= REQ_MUST]
        |       BumpCatGen() if force_full
        |       BARITM = SortItmCache(cfg, playerid, itmcache, BARITM, bags)
        |                 -> per item: PickBar(...) assigns I_CAT / I_BAR / I_SUBGROUP
        |                 -> within-bar comparator uses SubSortKey (sub-group order)
        |       LayoutWindow(frame)              -- auto-flow OR Manual Layout
        |       sortGen = catGen                 -- mark categorization current
        |
        +--> rebuild TFuBag.BUTTONS[name] = itmcache record  (per bag/slot)
        +--> UpdateBagGfx + per-button refresh (icon/count/cooldown/lock)
```

### Resort discipline — `REQ_*`

```
REQ_NONE = 0   counts changed only; no re-sort needed
REQ_PART = 1   items moved but a prior sort is still valid enough
REQ_MUST = 2   never sorted / unstable / config changed -> MUST re-sort
```

`UpdateWindow` accumulates `resort_req + cache_req (+ CACHE_REQ debt)` and only
runs the expensive `SortItmCache + LayoutWindow` at `>= REQ_MUST`. This is the
core performance lever: item moves recategorize *only changed slots*, while
explicit config changes pay for a full recat.

### `catGen` — global categorization generation

`TFuBag.catGen` is a global counter; `BumpCatGen()` increments it on any
rule/grouping/category/override change. Each frame stores `sortGen`; `OnShow`
forces `REQ_MUST` when `sortGen ~= catGen`, so a window reopened after a config
change re-sorts its persisted (now-stale) categories. Individual slots also carry
a generation stamp so `SortItmCache` re-runs `PickBar` only on stale slots.

---

## 8. The category system (overview)

Categorization answers: *which bar does this item go in?* It is the most
data-heavy subsystem and the source of most "wrong category" reports.

Inputs:
1. **`DefaultSearchList`** (defaults.lua) — ordered rules of
   `{Category, Keywords, TooltipSearch, ItemType, ItemSubType, [tag]}`. Order is
   significant (first match wins).
2. **`DefaultItemOverrides`** + user `item_overrides` — per-item forced category.
3. **`TBagItemInfo.lua`** — account-wide created-by / reagent DB used by the
   profession (`psplit`) rules.
4. **Live trade ranks** (Professions.lua) when `reagent_split` is on.

`PickBar` (TBag.lua:4683) runs the rules for one item and returns its category,
bar, and (for armor/weapons) sub-group. Two modes via `cfg.reagent_split`:
- **OFF** (default, Baganator-style): item sorts by its own name/tooltip/class;
  reagents land in a few generic bars. `psplit`-tagged rules are skipped.
- **ON** (original TBag look): per-profession rules split reagents into
  Mining/Tailoring/etc., using the account DB (can show a profession bar a
  character doesn't have — original behavior, kept opt-in).

`AssignCats` (TBag.lua:2903) maps categories to bar numbers. Bars are display
boxes; `BAR_MAX = 48`, `EMPTY_BAR = 48` is the dedicated bottom "Empty" box.
**[→ Phase 1]** full category deep-dive.

---

## 9. The layout engine (overview)

Two distinct engines, selected by config. **[→ Phase 1]** is dedicated to this —
it is the largest and most intricate part of TBag.lua.

- **Auto-flow** (`LayoutWindow`, TBag.lua:7029): packs category boxes
  left-to-right / top-to-bottom into the available width; reflows on resize
  (`ComputeDynColumns`). Default mode.
- **Manual Layout** (`LayoutWindowFree` + `LayoutWindowFreePlace`, ~6592/6850):
  user drags category boxes to fixed grid (or free) positions. State in
  `cfg.cat_layout` (grid) / `cfg.cat_layout_free` (free). ~15 `ML*` helpers do
  drag, snap, neighbor-push, ghost rendering, seed and snapshot.
  - `cfg.ml_auto` = true means the layout is still the auto-seeded arrangement
    (reflows with the window); set false on the first real box drag.
  - **Equipment sub-groups** (`EquipSubPlan`, `BarHasSubgroups`, `SubSortKey`,
    `MakeSubHeaderHandle`, `SubHeaderDrop`): armor/weapon bars render
    drag-reorderable sub-shelves; `MLBarDims` is the single source of truth for a
    bar's footprint (so reserved space ≥ drawn space, no overlap).

Per-bar boxes are `TFuBag_BarFrameTemplate` frames (TBag.xml) with a `CatName`
overlay label and a `BackdropTemplate` background.

---

## 10. The bank (overview)

The 12.0 bank is the biggest functional rewrite. **[→ Phase 1]** for detail.

- **Tab-as-container model:** character bank tabs are
  `Enum.BagIndex.CharacterBankTab_1..6` (ids 6-11), warband/account tabs
  `AccountBankTab_1..5` (12-16). `BAGMAX = 16` so all fit. `Bnk_Bags` is built
  **dynamically** on bank open from the player's purchased tabs
  (`Bank:RebuildTabList`) — empty until the first `BANKFRAME_OPENED`.
- **Gating:** `TFuBag.BANK_ENABLED`. When off, Blizzard's own bank shows.
- **Session signal:** `physAtBank` (set on `BANKFRAME_OPENED`, cleared on
  `BANKFRAME_CLOSED`/`OnHide`). The global `CloseBankFrame()` is an *intentional*
  compat no-op (compat-12.lua:110); the real session close is
  `C_Bank.CloseBankFrame()`, handled where appropriate in TBnk.lua. Cooldown
  ticks are deliberately not run for the bank (perf — see Events.lua:137).
- **Tab settings dialog:** TBnkTabSettings.lua (name/icon/deposit flag).

---

## 11. Cross-cutting concerns

- **12.0 API compat:** `compat-12.lua` is the chokepoint for all moved APIs. New
  code should prefer the real `C_*` call; legacy call sites rely on the shims.
  **[→ Phase 3]** verify each mapping against `wow-ui-source`.
- **Performance:** the `RequestUpdate` debounce (Events.lua), the `REQ_*`/`catGen`
  resort discipline, and bank cooldown suppression are the three deliberate
  throttles. Any change that bypasses them risks the original "open bank → lag"
  regression.
- **Localization:** all user-facing strings via `L[...]`. Category names are
  localized (`I_CAT`), which is why `subgroup_order` is keyed by the localized
  string.
- **Taint:** the addon owns its frames; the bank rewrite is careful to read
  Blizzard state (`BankFrame:IsShown()`) rather than write secure objects.
  **[→ Phase 3]** confirm no insecure writes crept in.

---

## 12. Quick orientation for future work

| I want to change… | Start in… |
|-------------------|-----------|
| Which category an item lands in | `defaults.lua` `DefaultSearchList` + `PickBar` (TBag.lua:4683) |
| How boxes are arranged | `LayoutWindow` (7029) / `LayoutWindowFree` (6592) + `ML*` fns |
| Equipment sub-shelves / reorder | `EquipSubPlan` (1279), `MLBarDims` (1238), `SubHeaderDrop` (1372) |
| Bank tabs / warband | `TBnk.lua` `Bank:RebuildTabList`, `Bank:UpdateWindow` |
| When/whether a window rebuilds | `Events.lua` `RequestUpdate` + `Inv/Bank:UpdateWindow` |
| An item button's look/behavior | `Buttons.lua` `TFuBag.ItemButton` |
| Options UI | `ModernOpt.lua` + the `*Func` callbacks in TBag.lua |
| A moved/removed Blizzard API | `compat-12.lua` |

---

## Forward-pointers collected during Phase 0 (for later phases)

- **[Phase 2]** `Events.lua:5-19` — the "Coalesce high-frequency…" comment block
  appears **twice** (duplicate paragraph).
- **[Phase 2]** `dist.sh` uses `svnversion` (svn-era); almost certainly dead given
  the git + `.pkgmeta` workflow. `scrape-wowhead.perl` likewise.
- **[Phase 2]** `TBagTest.lua` (835 lines) — confirm it's still exercised / decide
  ship vs. dev-only.
- **[Phase 2]** `localization.template.lua` is not in the `.toc` (translation stub)
  — confirm intentional.
- **[Phase 3]** Audit every `compat-12.lua` mapping against `wow-ui-source` 12.0;
  confirm `CloseBankFrame` no-op is still the right contract.
- **[Phase 4]** TBag.lua at 7,858 lines / 232 methods is the dominant split
  candidate (natural seams: constants, scan, categorize, layout-auto, layout-ML,
  options-callbacks, search).
