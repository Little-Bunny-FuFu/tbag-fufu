# TBag-fufu — The Layout Engine (Phase 1)

> **Status:** Subsystem deep-dive, built 2026-06-01 from the live source. Companion
> to [ARCHITECTURE.md](ARCHITECTURE.md); it owns the shared vocabulary (the global
> `TFuBag`, the `I_*` item-cache keys, `BARITM`, `REQ_*`/`catGen`, the
> event -> `RequestUpdate` -> `UpdateWindow` -> `SortItmCache` -> `LayoutWindow`
> pipeline). This file does **not** re-explain those; it documents *how boxes are
> placed on screen* once `SortItmCache` has produced `BARITM`.
>
> **Scope:** `LayoutWindow` (auto-flow), `LayoutWindowFree` / `LayoutWindowFreePlace`
> (Manual Layout grid / free), the `ML*` drag-snap-seed helpers, the equipment
> sub-shelf flow (`EquipSubPlan` and friends), the WowScrollBox viewport, and the
> dynamic-vs-legacy window sizing in `MainFrame.lua`. File:line anchors are against
> the live tree. **Not shipped** (`docs/` excluded from both release paths).
>
> Forward-pointers to the bug audit are marked **[→ FINDINGS]** (see the review's
> FINDINGS section, not this file).

---

## 1. Where the engine sits

`SortItmCache` (TBag.lua:4517) is the **producer**: it wipes and refills
`frame.BARITM[1..BAR_MAX]` — one Lua array per bar, each holding the item-cache
records (`I_*` tables) that resolved to that bar, in sorted order. `BAR_MAX = 48`
(TBag.lua:52); `EMPTY_BAR = 48` (TBag.lua:58) is the dedicated bottom "Empty" box.

`LayoutWindow` (TBag.lua:7029) is the **consumer/entry point**, called only on a
`>= REQ_MUST` (or filter-toggle) pass right after `SortItmCache`
(TInv.lua:1443/1454; the bank mirrors this). Contract worth stating because the
whole engine leans on it:

- `SortItmCache` runs `baritm[bar] = baritm[bar] or {}` for **every** bar 1..48
  *before* its early-out on a missing bag cache (TBag.lua:4535-4541, 4566). So
  **every `frame.BARITM[bn]` is always a table**, never nil — which is why the
  hundreds of `table.getn(baritm[bn])` calls in the layout code carry no nil guard.
- A bar with no items is the **empty table** (`table.getn == 0`); every layout/ML
  helper treats "item-bearing" as `table.getn(...) > 0`.

`LayoutWindow` is reached only when `SortItmCache` ran first, so `BARITM` is always
current when any placement code executes. A cheap (`< REQ_MUST`) update path skips
`LayoutWindow` entirely and only re-runs per-button `ItemButton.Update`
(TInv.lua:1478-1490) — boxes keep their last positions. **[→ FINDINGS]** the cheap
path can leave a moved item drawn against a stale box.

---

## 2. Coordinate systems

Three spaces are in play; mixing them is the single richest source of layout bugs,
so the engine is deliberate about which it uses where.

| Space | Origin / direction | Used by |
|-------|--------------------|---------|
| **Pixels (frame-local)** | WoW screen px, scaled by the frame | `PositionFrame`, `GetLeft/Top/Bottom`, `MLGridPitch` deltas |
| **Cells (grid units)** | one item-button pitch; `gx`/`gy` (grid), `fx`/`fy` (free) | `cat_layout` / `cat_layout_free`, `MLBarDims`, all `ML*` collision math |
| **Container space** | inside the WowScrollChild, origin at the chrome interior (no leading BORDER) | Manual-Layout box anchors (`scname`) |

The pixel<->cell conversions:

- `MainFrame:FrameX(n)` / `FrameY(n)` (MainFrame.lua:9-15) = the px span of `n`
  cells **plus one trailing `frameXSpace`** (the box outer size for `n` buttons).
- The bare **cell pitch** is `BF_PADWIDTH + frameXSpace` (X) / `BF_PADHEIGHT +
  frameYSpace` (Y) — i.e. `FrameX(1) - FrameX(0)`. `MLGridPitch` (TBag.lua:5605)
  and `MLGapCells` (TBag.lua:5799) both compute exactly this so seed, snapshot,
  draw and drag share **one grid**.

**Anchoring asymmetry (load-bearing):**

- **Auto-flow boxes** are anchored **BOTTOMRIGHT** (TBag.lua:7331-7336): a category
  shorter than its row's tallest neighbour rises from the row's shared bottom, so
  its title drops level with the items instead of floating.
- **Item buttons** inside a box are anchored **BOTTOMLEFT**, filling
  left-to-right, bottom-up (`PlaceItemButton` TBag.lua:5286, `PlaceItemButtonAtCell`
  TBag.lua:5315). `cur_y` counts rows **from the bottom**.
- **Manual-Layout boxes** are anchored **TOPLEFT** into the Container
  (`LayoutWindowFree` TBag.lua:6706, `LayoutWindowFreePlace` TBag.lua:6921): a grid
  coord `(gx,gy)` becomes `px = gx*pitchX`, `py = top_reserve + gy*pitchY + band`,
  positioned at `(px, -py)`.

So inside a box, "row 0" is the bottom; but a box's grid `gy` grows **downward**.
`EquipSubPlan` returns `ytop` as "cells from the TOP"; `AssignButtonsToFrame` flips
it to a from-bottom row with `H - p.ytop - 1` (TBag.lua:5410). Getting that flip
right is why `EquipSubPlan` and the draw pass must agree on `H`.

---

## 3. The dispatcher: which layout runs

`LayoutWindow` (TBag.lua:7029) is the single dispatcher. The decision is made in two
stages so the column budget can be borrowed by the first-enable seed.

### 3.1 Mode flags (computed up front, TBag.lua:7065-7072)

```
use_ml    = manual_layout==1 AND legacy_edit~=1 AND frame.playerid == PLAYERID
ml_free   = ml_freeplace == 1
ml_seeded = any store[bn] exists   (store = ml_free ? cat_layout_free : cat_layout)
will_seed = use_ml AND (not ml_seeded OR ml_auto == true)
```

- **`use_ml`** gates Manual Layout to the *logged-in* character only: `cat_layout`
  is account-wide and tailored to your own bag/category set, so applying it to an
  alt's different bars would stack boxes. Alts always fall through to auto-flow.
- **`ml_auto`** = the saved arrangement is the auto-seeded mirror of auto-flow (not
  hand-dragged). Set `true` by the seed tail (TBag.lua:7471); set `false` the moment
  the user drags a box (`MLDragStop` TBag.lua:5996). While `ml_auto` is true the
  arrangement is re-seeded every pass so it tracks the auto-flow.

### 3.2 The branch (TBag.lua:7210-7219)

```
if use_ml then
  if ml_seeded and ml_auto ~= true then           -- HAND-PLACED layout: draw saved coords
    return ml_free and LayoutWindowFreePlace(...) or LayoutWindowFree(...)
  end
  ml_seed = true                                   -- AUTO/never-seeded: fall through, snapshot at the tail
end
... run the auto-flow body ...
if ml_seed then                                    -- tail: snapshot the just-rendered auto-flow, re-lay-out as ML
  cfg.ml_auto = true
  wipe(store); SnapshotCatLayout[Free](frame)
  return LayoutWindowFree[Place](...)
end
return cur_y                                        -- pure auto-flow
```

So there are exactly three outcomes:
1. **Auto-flow** (ML off, or viewing an alt): the body runs and returns.
2. **Hand-placed Manual Layout**: short-circuits to `LayoutWindowFree(Place)`,
   drawing the saved `gx,gy`/`fx,fy`.
3. **Auto-seeded Manual Layout (`will_seed`)**: the auto-flow body runs to position
   every box, then the tail reads those rendered positions back
   (`SnapshotCatLayout[Free]`), `wipe`s the store, stores them as grid/free coords,
   and re-lays-out via the Manual path. Net effect: turning Manual Layout on (or
   resizing while still auto) reproduces the ML-off picture exactly.

`will_seed` is computed but the actual seed gate used at the branch is `ml_seed`
(set inside the `use_ml` block). They encode the same condition; `will_seed` exists
earlier only so the **dynamic column budget** can be applied to the seed pass.

### 3.3 Dynamic budget for the seed (TBag.lua:7082-7088)

```
want_dynamic = frame:IsDynamicResize()  OR  (will_seed AND legacy_sizing==0)
if want_dynamic and cfg.win_w>0 then
  density = colmax / bar_x               -- preserve the user's columns-per-bar feel
  colmax, bar_x = ComputeDynColumns(frame, cfg.win_w, density)
```

Manual Layout makes `IsDynamicResize()` false (MainFrame.lua:89-95), so without the
`will_seed` clause the seed would lay out at the cramped *legacy* slider budget and
the snapshotted boxes would overlap. The clause forces the seed onto the same
dynamic budget the auto-flow uses, so the snapshot matches.

---

## 4. `MLBarDims` — the footprint single source of truth (TBag.lua:1238)

Every place that needs "how many cells does this bar occupy" routes through
`MLBarDims(frame, items, rec, colmax) -> cols, rows, isSub`. This is the engine's
central invariant: **what is drawn equals what is reserved**. The historical
overlap bug was a footprint site that recomputed rows as `ceil(n/cols)`
independently while the box actually drew at a sub-shelf height.

- **Normal category:** flat `cols x rows`. `cols = clamp(rec.cols or 1, 1, colmax)`;
  `rows = ceil(n / cols)`.
- **Equipment (sub-grouped) category** (`BarHasSubgroups` true *and* not legacy-edit):
  a **full-width shelf block**. `cols = rec.cols or colmax` (the *captured content
  width* so equipment reflows with the window; **not** clamped to colmax, so a
  window dragged wider renders equipment wider). `rows = ceil(EquipSubPlan(items,
  cols))` — the shelf plan's fractional height CEIL'd to whole cells so the band
  math and footprints stay integer. `isSub = true` drives the shelf draw.

Routed through `MLBarDims`: the seed (`SeedCatLayout` 5549/5569, `SeedCatLayoutFree`
6825/6838), the snapshot (`SnapshotCatLayout` 5636), the bands and width passes in
both Manual draws (6653/6672/6696, 6898/6915), collision (`MLCatFootprint` 5708),
snap (`MLSnapFree` 5827), push (`MLPushNeighbors` 5863, `MLResolveFree` 5926), and
the drag-drop footprints (`MLDragStop` 6008/6038). The auto-flow body computes
equipment height directly from `EquipSubPlan` (7264, 7319) rather than through
`MLBarDims`, because auto-flow boxes are not a grid — but it uses the *same*
`EquipSubPlan`, so the values agree.

`BarHasSubgroups` (TBag.lua:1194) just scans for any non-empty `I_SUBGROUP`
(`sg`) on the bar; it is the gate for the whole shelf path. It relies on
`SortItmCache` having made same-label items contiguous via `SubSortKey`
(see §6). **[→ FINDINGS]** that contiguity is only guaranteed when the bar is
actually sorted.

---

## 5. The seed / snapshot lifecycle

Two ways an arrangement is born; both produce store records keyed by **bar number**
(`store[barnum] = {gx,gy,cols}` grid, `{fx,fy,cols}` free).

### 5.1 Snapshot (first-enable / re-seed, auto path)

`SnapshotCatLayout` (TBag.lua:5612, grid) / `SnapshotCatLayoutFree` (TBag.lua:6777,
free) run at the dispatcher tail after the auto-flow body has positioned every box.
They read each visible item-bearing box's rendered `GetLeft/Bottom/Width/Height`,
convert to cells via `MLGridPitch` / `cellX,cellY`, and store:

- **cols** from the rendered width through the **cell** pitch
  (`(w - frameXSpace)/cellX`); equipment keeps the measured cols and takes only its
  row count from `EquipSubPlan` at that width (TBag.lua:5636).
- **grid rows** (grid only) detected by **shared bottom edge** (`abs(bottom - b) <
  pitchY/2`); rows sorted top-first, `gy` accumulated per band, and each box
  **bottom-aligned within its row** (`gy + (r.maxrows - bx.rows)`, TBag.lua:5676) so
  short boxes' titles drop to their items.
- **gx** is **fractional** (`(l - minLeft)/pitchX`) on purpose, to preserve the
  exact inter-category spacing; a later *drag* snaps it to a whole cell. Free mode
  stores `fx/fy` fractional from the top-left-most box.

The store is `wipe`d before each snapshot (TBag.lua:7473/7477) so a category
removed or resized since the last pass leaves no stale coords.

### 5.2 Seed (a new category appears later)

`SeedCatLayout` (TBag.lua:5535) / `SeedCatLayoutFree` (TBag.lua:6814) run at the
*head* of the Manual draw and give any item-bearing bar with **no record yet** a
position. They compute where existing content ends (max occupied row/bottom via
`MLBarDims`) and append the new category below in reading order, wrapping at
`colmax`. So an alt-tab that produces a brand-new category does not overlap the
hand-placed boxes.

### 5.3 Re-seed on resize (MainFrame.lua:145-154)

`OnResizeStopped` persists `win_w/win_h`, then — if the layout is still `ml_auto` —
wipes the active store so the next `LayoutWindow` re-seeds at the dragged width. A
hand-customized layout (`ml_auto == false`) is left untouched; only its canvas
changes.

---

## 6. Equipment sub-shelves

Armor/weapon bars render as Baganator-style **shelf blocks**: one box per category,
with the sub-groups (armor slot / weapon type) packed across the width under small
per-sub-group headers.

### 6.1 The plan (`EquipSubPlan`, TBag.lua:1279)

Pure function of `(items, colmax)` -> `height, headers, placements`, all in **cell
units**, deterministic so the size pass and draw pass agree:

1. **Cluster** the pre-sorted items into contiguous same-`I_SUBGROUP` runs
   (TBag.lua:1288-1295). A nil/"" label = a header-less cluster.
2. **Shelf-pack** clusters left-to-right (TBag.lua:1308-1331): each cluster spreads
   up to `SUBGROUP_MAX_COLS` (5) then wraps into a multi-row block; a fractional
   `SUBGROUP_GAP` (0.125 cell) sits between clusters; a shelf wraps to a new band
   when `cx + gap + w > colmax`. Each shelf reserves only a short
   `SUBGROUP_HEADER_H` (0.5 cell) band for titles. `ytop` is cells-from-top,
   `xcell` is the fractional column from left.

Because shelf heights are half-integer (header bands + integer item rows),
`MLBarDims` CEILs the total to whole cells so the *footprint* stays integer while
the *content* is exact — the reserved >= drawn invariant.

### 6.2 The draw (`AssignButtonsToFrame`, sub path, TBag.lua:5403-5480)

Re-runs `EquipSubPlan` at the box's column budget, places each item with
`PlaceItemButtonAtCell` at its `xcell` and the flipped row `H - ytop - 1`, then
positions a `GameFontNormalSmall` header centered over each cluster's first item
button (honoring the `show_cat_names` toggle, TBag.lua:5432) clamped to the cluster
width so a long title truncates instead of bleeding into a neighbour. Leftover
sub-headers / drag-handles from a previous (larger) layout are hidden
(TBag.lua:5394-5399, 5473-5477).

### 6.3 Sub-group drag-reorder (TBag.lua:1336-1419)

While Manual Layout is unlocked (`ml_edit == 1`), each shown header gets a
transparent drag handle (`MakeSubHeaderHandle`, TBag.lua:5339), created lazily and
reused. On drop, `SubHeaderDrop` (TBag.lua:1372) finds the header nearest the cursor
(screen-pixel distance, scale-corrected via `GetCenter * GetEffectiveScale` vs
`GetCursorPosition`), reorders the label list, and persists via
`ApplySubGroupOrder` (TBag.lua:1358) into `cfg.subgroup_order[catKey][label] =
rank`.

The order is consumed **only** through the sort, not the layout: `SubSortKey`
(TBag.lua:1211) builds a sort-key fragment — ranked sub-groups lead with `"1"` and
encode `9999-rank` (descending sort, so rank 1 is largest = first); unranked lead
with `"0"..label` to preserve alphabetical order. `ApplySubGroupOrder` triggers a
`REQ_MUST` relayout but deliberately does **not** bump `catGen`: it changes the
*within-bar order*, not categorization, and `SortItmCache` re-sorts every bar on
every `REQ_MUST` regardless of per-slot stamps. **[→ FINDINGS]** the sort (and thus
the reorder, and sub-group contiguity) is skipped for any bar whose `G_BAR_SORT` is
`SORTBY_NONE`.

---

## 7. Manual-Layout drag, snap, push (Stage 2)

The bar `_bar_N` frame is the grab region (its colored backdrop;
`SetBarDraggable`/`MLInitBarDrag`, TBag.lua:6160/6135), plus a transparent title
handle when names are shown. The box itself is **not** moved during a drag — the
item buttons only *anchor* to it, so `StartMoving` the box would drag them under the
cursor and a release would pick up an item. Instead a single per-window translucent
**ghost** (`MLGetGhost`, TBag.lua:5735) follows the cursor; the box and items stay
put. During the drag, every item button is made mouse-inert (`MLSetItemMouse`,
TBag.lua:5757) so the inherited container button can't grab an item under the
crossing cursor.

On drop (`MLDragStop`, TBag.lua:5983):

- **Free mode** (TBag.lua:6002-6022): convert the ghost's *pixel delta* (not its
  absolute drop, which carries band offsets) to a fractional cell delta, add to the
  saved `fx,fy`, then `MLSnapFree` (magnetic edge snap within a 0.45-cell threshold,
  TBag.lua:5817) and `MLResolveFree` (TBag.lua:5913): if the drop is clear, nothing
  moves; if it overlaps one bar, slide out the shortest way; if wedged between two,
  `MLPushNeighbors` (TBag.lua:5853) cascades the neighbours apart (guard-bounded at
  `12 * BAR_MAX` iterations).
- **Grid mode** (TBag.lua:6024-6126): snap the ghost left to the nearest grid column
  relative to the Container; snap vertically by aligning the dragged box's top *or*
  bottom (whichever the drop landed nearest) to a neighbour's **rendered** edge
  (not an inferred pitch, so the variable title/Pool band gap can't slip the snap a
  button). Reject a drop that creates a **new** overlap (`MLOverlaps`, TBag.lua:5714)
  — unless the box was already overlapping (so a stale layout can always be dragged
  free). A drop past the left/top edge grows the grid origin by shifting every other
  box (TBag.lua:6112-6124).

Both modes set `cfg.ml_auto = false` (TBag.lua:5996) and finish with
`frame:UpdateWindow(REQ_MUST)`.

**Origin normalization:** both Manual draws begin by shifting the whole layout so
the left/top-most occupied cell sits at the origin (grid 6609-6631, free 6867-6884),
so the left/top reclaim space symmetrically with the auto-growing right/bottom.

**Collision footprints include the title strip:** `MLPushNeighbors` /
`MLResolveFree` extend a box's top by `titlec` (`MLGapCells`, TBag.lua:5799) so a
vertical neighbour leaves room for the lower box's title without double-counting it
in the inter-row gap.

---

## 8. Auto-flow internals (`LayoutWindow` body)

For each *row* of up to `bar_x` consecutive bars, `drawRow` (TBag.lua:7242):

1. `CalcBarLayout` (TBag.lua:5216) packs the row: for each candidate total height it
   sums each bar's `ceil(n/height)` width and grows `height` until the row fits in
   `colmax` (`repeat ... until tmpcalc <= colmax`). It writes `calc_dat["height"]`
   (shared row height) and per-bar `iBar.."_width"`.
2. Equipment bars are **peeled out and drawn solo full-width** (the main loop
   detects `isSubBar` and calls `drawRow(bn,1)`, TBag.lua:7416-7433); `drawRow`
   overrides the optimizer for them with `EquipSubPlan` height (TBag.lua:7261-7265).
3. Each box is anchored BOTTOMRIGHT, wrapped to its **own** occupied rows (a sparse
   category gets a short box hugging its items, TBag.lua:7306-7324), colored, and
   filled via `AssignButtonsToFrame(..., useSub=true)`.
4. The category-name label is centered over the box when it fits, else edge-justified
   toward the window interior so it never runs off-viewport (TBag.lua:7360-7396).

`EMPTY_BAR` is drawn **first** (bottom-up) as one box at the very bottom
(TBag.lua:7411); with no empties `CalcBarLayout` reports height 0 and it is hidden.
The window is then sized to `available_width` x `new_height` (TBag.lua:7447-7448)
and the viewport is updated.

`ComputeDynColumns` (TBag.lua:7004) is the Stage-3 inverse: given the dragged
`win_w` and a desired density (columns per bar), solve for the largest `colmax`
whose resulting `available_width` still fits the content area (two passes: estimate
ignoring per-row gaps, derive `bar_x`, re-solve charging the gaps). `density` is
floored to >= 1 to avoid div-by-zero.

---

## 9. The scroll viewport (`UpdateScrollViewport`, TBag.lua:6307)

Follows Baganator's single-content-frame WowScrollBox recipe exactly (deviating from
the "magic" offsets is what kept clipping broken historically):

- **ScrollBox** (`frame.Scroll`) is the viewport, `clipChildren` via the
  `ScrollBoxBaseTemplate` cascade — which only works because the **main window
  template** also sets `clipChildren="true"` (MainFrame.xml:134; see the XML-pitfalls
  note about the cascade needing every ancestor).
- **ScrollChild** (`.scrollable=true`) is the single managed child;
  **Container** (`sc.Container`) is anchored 2px inside it and is what the bars
  anchor to (`scname = framename.."_Scroll_ScrollChild_Container"`).
- One-time wiring (TBag.lua:6324-6401): `ScrollUtil.InitScrollBoxWithScrollBar` +
  `AddManagedScrollBarVisibilityBehavior` + `CreateScrollBoxLinearView`; NIL the
  framework `OnSizeChanged` on both ScrollBox and ScrollChild so its reentrant
  resize doesn't fight the explicit `SetSize`; `SetPanExtent`; push the scrollbar
  subtree (`bar.Track.Thumb`, `bar.Back`, `bar.Forward`) above dummy-bag items.
- **Horizontal axis is manual**: LinearView is vertical-only, so `HScrollBar`'s
  `OnScroll` callback shifts the Container's TOPLEFT X by `2 - percent * overflow`
  (TBag.lua:6364-6369); Shift+wheel routes to it (TBag.lua:6376-6383). The HScrollBar
  shows IFF the viewport is narrower than content; when shown it reserves
  `HSCROLL_H = 21` (TBag.lua:6305) at the bottom so content can't render behind it.
- **Sizing** (TBag.lua:6408-6480): `container = (content_w, content_h)`,
  `scrollChild = +4`, `scrollBox = content+ (4,5)` clamped to `GetWindowCap`
  (85% of UIParent / scale, TBag.lua:6251). The window width is
  `sb_w + 2*BORDER + optional SB_COL`; height is `PAD_TOP + sb_h + bottom_pad
  (+ HSCROLL_H if the hbar shows)`.

**Auto-flow vs Manual viewport use:** in auto-flow, bars stay anchored to the main
frame BOTTOMRIGHT (not the Container) unless `scroll_cap` is on (`frame ==
TFuBnkFrame` or `legacy_sizing == 0`, TBag.lua:7044) — the ScrollFrame is sized to
the content but does not actually scroll plain auto-flow. Manual Layout always
anchors to the Container and lets the framework clip + scroll. The
`scroll_cap`/`bar_anchor` switch adds `BORDER` back to the x offset
(TBag.lua:7333) and subtracts `bottom_chrome` from y (TBag.lua:7334) because the
Container is the content area (no border), mirror-correcting the window-coord cur_x.

Footer/header separator rules are positioned here too: the footer line hugs the
highest visible bottom control via `FooterChromeTop` + `INV/BNK_FOOTER_WIDGETS`
(TBag.lua:6263-6291) rather than the over-reserved `PAD_BOTTOM` band.

---

## 10. Dynamic vs legacy sizing (`MainFrame.lua`)

`cfg.legacy_sizing` (default **1** = legacy, per `SetDef` TBag.lua:2770) chooses:

- **Legacy (1):** the window is sized to its content; the column/bar sliders drive
  layout; the resize grip is hidden and its mixin clamp neutralized
  (`UpdateResizeGrip` else-branch, MainFrame.lua:119-126).
- **Dynamic (0):** the window is resizable in *every* mode (`IsResizable`,
  MainFrame.lua:100). Auto-flow reflows columns to the dragged width via
  `ComputeDynColumns`; Manual Layout treats the window as a fixed canvas the boxes
  float/scroll within (`canvas = win_w>0 and win_h>0`, TBag.lua:6759/6989).

The grip is a lazily-created `PanelResizeButtonTemplate`
(`EnsureResizeGrip`, MainFrame.lua:55), `Init`'d with min sizes and nil maxes; the
maxes (screen cap) are (re)applied each layout by `UpdateResizeGrip`. Verified
against wow-ui-source: `PanelResizeButtonMixin:Init(target, minW, minH, maxW, maxH,
rotationDegrees)` and the live clamp reads `self.minWidth/minHeight/maxWidth/
maxHeight` directly (SharedUIPanelTemplates.lua:1506-1543), so the per-layout field
mutation is the supported pattern. `OnResizeStopped` (MainFrame.lua:129) persists
`win_w/win_h`, re-saves all four edge coords (so the next `SetFrameAnchor` doesn't
snap the window back), and re-seeds an `ml_auto` layout at the new width.

`IsDynamicResize()` (MainFrame.lua:89) is **narrower** than `IsResizable()`: it is
true only for the *auto-flow reflow* case (dynamic AND not in Manual Layout), which
is exactly the `want_dynamic` first term in §3.3.

---

## 11. Frame templates

- `TFuBag_BarFrameTemplate` (TBag.xml:23) — the per-category box: a
  `BackdropTemplate` `Frame`, `enableMouse="false"` by default (drag enables it per
  bar), `hidden`, with a `parentKey="CatName"` `GameFontNormalSmall` title. Mouse is
  toggled by `SetBarDraggable`; the drag handle and right-click "print category"
  button (`WireCatTitleClick`, TBag.lua:3170) are overlaid lazily.
- `TFuBag_MainTemplate` (MainFrame.xml:134) — the shared window, `clipChildren="true"`
  (the cascade root), with the `Scroll` / `ScrollChild` / `Container` subtree and the
  `MinimalScrollBar` widgets.
- `TInv.xml` / `TBnk.xml` build the two concrete windows on the main + scroll
  templates.

---

## 12. Invariants the engine guarantees (and where)

| Invariant | Enforced by |
|-----------|-------------|
| `BARITM[bn]` is always a table for 1..BAR_MAX | `SortItmCache` wipe loop runs before any early-out (TBag.lua:4535) |
| Reserved footprint >= drawn content | `MLBarDims` CEILs equipment height; flat `ceil(n/cols)` (TBag.lua:1238) |
| Footprint == what is drawn (no independent recompute) | every footprint site routes through `MLBarDims` (§4) |
| Seed/snapshot/draw/drag share one cell grid | `MLGridPitch` / `MLGapCells` give the identical pitch (TBag.lua:5605/5799) |
| Band math stays integer | shelf height CEIL'd; row bands keyed by integer bottom cell (TBag.lua:6646-6660) |
| Same sub-group label contiguous | `SortItmCache` sort + `SubSortKey` (only when the bar is sorted — §6.3) |
| Drag never picks up an item | `MLSetItemMouse(false)` for the drag duration (TBag.lua:5757) |
| A reverted/short drop doesn't click an item | the mouse-enabled ghost shields the slot under the cursor (TBag.lua:5731) |
| Origin reclaims left/top symmetrically | both Manual draws normalize to the min occupied cell (§7) |
| Push cascade terminates | `guard < 12 * BAR_MAX` (TBag.lua:5869) |

---

## 13. Quick orientation

| I want to change… | Start in… |
|-------------------|-----------|
| How auto-flow packs a row | `CalcBarLayout` (5216), `drawRow` inside `LayoutWindow` (7242) |
| A box's reserved size | `MLBarDims` (1238) — and nothing else |
| Which layout mode runs | the dispatcher branch in `LayoutWindow` (7210) |
| First-enable / resize reproduction | `SnapshotCatLayout[Free]` (5612/6777) + the seed tail (7468) |
| Equipment shelf packing | `EquipSubPlan` (1279) + `AssignButtonsToFrame` sub path (5403) |
| Sub-group order | `SubSortKey` (1211), `SubHeaderDrop` (1372) |
| Drag / snap / push | `MLDragStop` (5983), `MLSnapFree` (5817), `MLResolveFree` (5913) |
| Scroll / clipping | `UpdateScrollViewport` (6307) + `clipChildren` on the main template |
| Resize grip / dynamic sizing | `MainFrame.lua` `EnsureResizeGrip` (55), `OnResizeStopped` (129) |
| Window width from a drag | `ComputeDynColumns` (7004) |
