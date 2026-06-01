# TBag-fufu — Improvement Roadmap (Phase 4)

> **Status:** Forward-looking improvement plan, compiled 2026-06-01 at commit
> `b508b7e`, closing the multi-phase code review (Phase 0 architecture map →
> Phase 1 subsystem deep-dives → Phase 2 dead-code audit → Phase 3 correctness
> audit → **Phase 4 this**). This is a *prioritized backlog with effort/risk
> notes*, not a set of changes already made. Nothing here is a known live bug —
> Phase 3 fixed those (BUG-1/2/3, `CloseBankFrame`, the W113 leaks). These are
> maintainability, cleanup, robustness, and distribution items.
>
> **Not shipped:** `docs/` is excluded from both release paths (`.deployignore`
> `[dirs]`, `.pkgmeta` `ignore:`).

Effort: **S** ≈ <1h, **M** ≈ a focused session, **L** ≈ multi-session.
Risk: chance a change introduces a regression / needs in-game gating.

---

## Tier 1 — Maintainability (highest leverage)

### 1.1 Split `TBag.lua` (7,967 lines / 233 methods) — **L / Med-risk**
`TBag.lua` is the dominant file: the data model, container scan, categorization,
both layout engines, search, the item-mover coroutine, and assorted helpers all
live in one file. It is the hardest file to navigate and the riskiest to edit
(every reviewer pass re-reads thousands of lines for context).

Natural seams (already documented per-subsystem in `docs/`), each a candidate
module loaded via a new `<Script>` in `TBag.xml`:

| Proposed file | Contents (current anchors) |
|---|---|
| `TBagConst.lua` | `I_*` cache keys, `REQ_*`, `SORTBY_*`, bag-id sets, color/def tables |
| `TBagScan.lua` | `UpdateItmCache`, `UpdateSlots`, `CreateItm`, `MakeEmptySlot`, cat-stamp memo |
| `TBagCategorize.lua` | `PickBar`, `ResolveBarAlias`, `EquipCat`, `GetBarCategoryName`, `BuildCatLabels`, rule eval |
| `TBagLayoutAuto.lua` | `SortItmCache`, auto-flow `LayoutWindow`, column math |
| `TBagLayoutManual.lua` | Manual-Layout (grid + free) snapshot/edit/reflow |
| `TBagMover.lua` | `ItemMover`, `Stack`, compress, `EmptyBag`, `DepositToFreeSlot`, `FindFreeSlotExcept` |
| `TBagSearch.lua` | search box, `PrintCategoryContents`, diagnostics (`printtypes`/`printcat`/`catdiag`) |

**Constraints / gotchas:**
- Load order is fixed by `TBag.xml`'s `<Script>` order; `compat-12.lua` and
  `stub.lua` (creates `TFuBag`) must stay first. Split files reference `TFuBag`
  and the `self`-as-`TFuBag` file-local alias idiom — preserve it or convert
  consistently (mixed `TFuBag:`/`self:` today).
- This is a pure *move*, but it touches everything; do it in small, individually
  parse-checked + in-game-gated commits (one seam per commit), not a big-bang.
- Re-run the W113 sweep after each split (cross-file globals like `TFuInv_cmd`
  only resolve when the defining file is in the linted set — see `.wowlint-globals`).

**Recommendation:** high value but do it deliberately, one seam at a time, only
when there's appetite for the gating. Start with the cleanest cut (`TBagConst`,
then `TBagMover`) to validate the split mechanics before touching scan/categorize.

### 1.2 Normalize the `self`-as-`TFuBag` alias idiom — **S / Low-risk**
Some functions are `function TFuBag:Foo()`, others `function self:Foo()` (where
`self` is a file-scope alias for `TFuBag`). Harmless but confusing. Pick one
convention per file when splitting (1.1) rather than as a standalone churn pass.

---

## Tier 2 — Dead code & build hygiene (low risk, low effort)

### 2.1 Remove svn-era scripts `dist.sh` + `scrape-wowhead.perl` — **S / Low**
`dist.sh` uses `svnversion` (the project is git + `.pkgmeta` now);
`scrape-wowhead.perl` is a one-off data scraper. Both are dead relative to the
current workflow. Confirm nothing references them, then delete (or move to an
`attic/` if worth keeping as reference). They are NOT in the release (`.pkgmeta`
already ignores `dist.sh` / `scrape-wowhead.perl`), so this is repo tidiness.

### 2.2 Exclude `TBagTest.lua` (~835 lines) from the release build — **S / Low**
It IS loaded (via `TBag.xml`) and backs `/tinv tests`, so it ships in the
packaged addon. Useful in dev, dead weight for end users. Either (a) keep it
loaded but add it to `.pkgmeta ignore` + `.deployignore` (like `docs/`) so
releases drop it — but then the `<Script>` reference must be guarded/removed for
release, which the packager won't do automatically; or (b) move it behind a
dev-only `.toc` / load it only when a dev flag is set. **Decide intent first**
(ship the self-test or not). Low urgency.

### 2.3 Remove classic-bank dead tooltip blocks — **S / Low**
`Buttons.lua` `GetReagentBankCost` (~594) and `GetBankSlotCost` (~628) tooltip
blocks back the permanently-hidden classic bag buttons (the classic-bank
buy-slot UI is gone in 12.0; `b4737cb` already removed the OnClick taint writes).
Left in place last pass only to avoid touching the shared inventory `OnEnter`.
Excise the dead branches; gate in-game (vendor + bank hover) since it edits the
shared tooltip path.

### 2.4 Merge the duplicated "Coalesce high-frequency…" comment in `Events.lua` — **S / Low**
Lines ~5–19 are two overlapping paragraphs describing the same debounce
mechanism. Collapse to one (keep the second, more accurate "sliding debounce with
a hard cap" wording). Comment-only.

### 2.5 Confirm/annotate `localization.template.lua` — **S / Low**
Not in the `.toc` (correct — it's the translator stub). Add a one-line header
note that it is intentionally unloaded so a future maintainer doesn't "fix" it by
adding it to the load list.

---

## Tier 3 — Latent robustness (design before code)

### 3.1 `CleanConfig` GC of stale layout entries — **M / Med-risk**
`CleanConfig` (~TBag.lua:662) never prunes `cat_layout` / `cat_layout_free` /
`subgroup_order` entries keyed by bar number. A reused bar number can inherit the
previous category's saved `gx,gy,cols`. Render-guarded today (no visible bug —
Phase 3), so this is SavedVariables cruft, not a defect. A correct GC needs the
*live* bar set (categories currently in use), which isn't known at `CleanConfig`
time. **Design first:** run the prune after the first full categorization
(`SortItmCache`/`BuildBarClassList`) when the active bar set is known, keyed off
`catGen`. Don't ship a blind prune — it could drop layout a user will want back
when a category reappears.

### 3.2 `SORTBY_NONE` within-bar contiguity — **S / Low (latent)**
When a bar's sort is `SORTBY_NONE`, the within-bar `table.sort` is skipped, so
drag-reorders don't apply and `EquipSubPlan`'s contiguous-run clustering can emit
duplicate sub-headers. Reachable only via an *imported legacy SavedVariable* (no
modern UI sets `NONE`). Either add a guard (treat `NONE` as `NORM` for the
contiguity pass) or document as won't-fix-unless-reproduced. Low value.

### 3.3 Unify empty-slot button-map sentinel (`{}` vs `nil`) — **S / Low**
Bank uses `{}` for empty-slot button-map entries (intentional — keeps the slot in
the `pairs(BUTTONS)` spotlight sweep); inventory uses `nil`. No bug today, but a
future inventory feature that sweeps `pairs(BUTTONS)` would silently skip emptied
inv slots. When such a feature lands, align the conventions (and document why).

---

## Tier 4 — Distribution readiness (only if going public)

> Per the workspace principle, *personal-use ergonomics take precedence over
> public-distribution polish* — hardcoded English + fufu branding are fine for
> now. These items matter ONLY if the fork is ever published. See the upstream
> license / distribution constraints in `tbag-fufu.md` before any public release.

### 4.1 Localization pass — **L / Low-risk**
Hardcoded English user-facing strings exist outside the `L[...]` table: category
header labels ("BoE", "Equipment", "Junk", "Bags"), `EmptyBag` chat messages,
slash-command help/report text, and `TFuBALL_HELP` (explicitly plain strings).
A real localization pass would route these through `L[...]` and seed the
`localization.*.lua` files. Large but mechanical and low-risk.

### 4.2 Pre-release checklist — **M / N/A**
License retention, README, naming/branding sweep, `.pkgmeta` `package-as`
verification. Track against the checklist in `tbag-fufu.md`.

---

## Explicitly NOT on the roadmap (leave alone)

- **Performance plumbing is already well-tuned — do not regress it.** The
  `catGen` per-slot categorization memo, the sliding-debounce update coalescing
  (`Events.lua`), and the `REQ_NONE/PART/MUST` resort discipline exist
  specifically to keep ~1000-slot bank updates cheap. Phase 3 confirmed the REQ
  discipline is correct. Any refactor (esp. the 1.1 split) must preserve these;
  re-gate bank-open / Deposit-All lag in-game after structural changes.
- **`compat-12.lua` mappings** — Phase 3 verified every shim against 12.0 source;
  they are correct. Only revisit when Blizzard moves an API again.
- **The one-way `physAtBank` heal** — deliberate (a two-way heal was the `99db059`
  regression, reverted in `0877d78`). Do not "harden" it to clear on
  `BankFrame:IsShown()`.

---

## Suggested sequencing

1. **Tier 2** cleanup (2.1, 2.4, 2.5) — quick wins, near-zero risk, shrink the repo.
2. **2.3** dead tooltip removal — small, but gate in-game (shared OnEnter).
3. **3.1** CleanConfig GC — design, then implement with a `catGen`-gated prune.
4. **1.1** TBag.lua split — when there's appetite; one seam per gated commit,
   starting with `TBagConst` / `TBagMover`.
5. **Tier 4** only if/when publishing.
