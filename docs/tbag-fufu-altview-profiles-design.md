# tbag-fufu — Cross-character alt-view profile scoping (design / scope)

> **Status:** Design-of-record. **Phases A + B + C landed** — committed and gated in-game
> 2026-06-05 (alt bank/inv render with the alt's own profile; layout-only default and
> full-geometry mode both verified; warband stays gated to the live character). the view-mode
> toggle is in the Profiles options panel). Only the optional Phase D (polish)
> remains. Extends the
> per-character **profiles** feature (`docs/tbag-fufu-profiles-design.md`) so the
> cross-character bag/bank **viewer** renders an alt with *that alt's* profile
> layout instead of the logged-in character's.
>
> **Not shipped:** `docs/` is excluded from both release paths
> (`.deployignore` `[dirs]`, `.pkgmeta` `ignore:`).
>
> **Product decisions locked (2026-06-05):**
> 1. Ship **both** view modes behind a user toggle — *Layout only* (default) and
>    *Full profile incl. window geometry*.
> 2. When an alt's profile can't be resolved, fall back to the **"default"** profile.

---

## 1. Goal

The inventory (`TFuInvFrame`) and bank (`TFuBnkFrame`) windows can browse
read-only **cached** views of other characters via a player dropdown. Today,
selecting alt **A** while logged in as **B** shows A's *items* but lays them out
with **B's** profile (columns, category arrangement, button size, colors).

Render A's items with **A's** profile.

---

## 2. Root cause

`SetPlayer` swaps the *item source* but not the *config source*:

| Concern | Bound where | Keyed to viewed char? |
|---|---|---|
| Item cache read | `TFuInvItm[self.playerid]` / `TFuBnkItm[self.playerid]` | **Yes** — `SetPlayer` sets `self.playerid` (`TInv.lua:76`, `TBnk.lua:84`) |
| Config (`self.cfg`) | `self.cfg = TFuBag:ActiveCfg(which)` in `init` (`TInv.lua:142`, `TBnk.lua:144`) | **No** — bound once; `ActiveCfg` returns `self.db.profile[which]` = the *logged-in* char's profile (`TBagProfiles.lua:299`) |

`SetPlayer` is the seam: re-resolve `self.cfg` for the viewed character there. It
is already the single choke point — called from `init` (`SetPlayer(PLAYERID)`),
both dropdown `OnClick`s (`TInv.lua:1520`, `TBnk.lua:2514`), and `OnShow`/`OnHide`
(reset to the logged-in player).

---

## 3. The crux — a keying mismatch with no bridge

The profile system and the viewer are keyed differently, and nothing maps
between them:

| System | Key | Available for a cached alt? |
|---|---|---|
| Profiles | `profile_ids[UnitGUID]` -> profile name | **No.** `UnitGUID` can't be queried for a character you are not logged into. |
| Viewer / item cache | `playerid = "Name\|Realm"` | Yes. |

So the viewer cannot currently know which profile alt A uses. **Adding that
bridge is the core of the work**; the rest is small and surgical.

---

## 4. Design

### 4.1 New data: a `playerid -> guid` bridge

Add an account-level map at the **SV root** (deliberately *outside* `profiles` /
`profile_ids`):

```
TFuBagCfg.player_guids = { ["Name|Realm"] = "<UnitGUID string>", ... }
```

Written each login in `TFuBag:Init`, right after `self.PLAYERID` is set
(`TBag.lua:362`) — the one place both the GUID and the playerid are known:

```lua
TFuBagCfg.player_guids = TFuBagCfg.player_guids or {}
TFuBagCfg.player_guids[self.PLAYERID] = UnitGUID("player")
```

Lazily populated (fills as each character logs in), so **no schema bump and no
migration** — it simply starts empty. It is purely additive root data, like the
other account-wide keys (`S_CREATED`, flags, `user_filters`).

> **DF-swap safe.** The profiles engine is intentionally swappable for
> `detailsFramework.SavedVars`, which is GUID-only and has no viewer. Keeping
> `player_guids` at the root (not in DF-owned tables) means the swap leaves it
> untouched, and the resolver below still reads `profiles[name]` (same schema DF
> uses). The bridge is tbag-specific because the feature is.

### 4.2 New resolver: `TFuBag:CfgForPlayer(playerid, which)`

```
playerid == PLAYERID (or nil)  -> ActiveCfg(which)         -- live in-use profile (your unsaved edits show)
otherwise                       -> guid  = player_guids[playerid]
                                   name  = profile_ids[guid]
                                   prof  = profiles[name]
                                   prof and prof[which]      -- alt's persisted profile
unresolved (no guid / deleted)  -> profiles["default"][which]   -- locked fallback (decision 2)
default also missing            -> ActiveCfg(which)         -- ultimate fallback (never nil)
```

The asymmetry is intentional: the **logged-in** char reads the *live* `db.profile`
(includes edits not yet saved); **alts** read the *persisted* `profiles[name]`
snapshot (they are not loaded into `db.profile`).

### 4.3 Wire the seam

`Inv:SetPlayer` / `Bank:SetPlayer` gain one line:

```lua
self.cfg = TFuBag:CfgForPlayer(playerid, "Inv")   -- "Bnk" in the bank
```

Because `init` calls `SetPlayer(PLAYERID)` after the old bind, the self-view path
is unchanged; every dropdown switch now re-resolves. The render pipeline
(`UpdateWindow` -> `SortItmCache`/`PickBar` -> `LayoutWindow`) already threads
`self.cfg`, so nothing downstream changes.

### 4.4 Alt cfg is a transient, defaults-complete COPY

For an alt, `self.cfg` points at a **deep copy** of the alt's profile subtree, not
the live saved table. This single choice buys three things:

1. **Write-safety.** Alt views are read-only by design (item moves, manual-layout
   drag, and window move are gated on `self.playerid == TFuBag.PLAYERID` —
   `MainFrame.lua:93,150`; moves/stack at `TInv.lua:1370,1435`). A copy guarantees
   that even an *un-audited* write path (resize grip, column +/-) cannot corrupt
   another character's saved profile.
2. **The Layout-only vs Full-geometry toggle** (decision 1) is a clean splice on
   the copy — see 4.5.
3. **Defaults completeness.** A saved profile is normally already complete (the
   default template is empty, so `removeduplicate` strips nothing on save and the
   `InitDefVals` defaults persist into `profiles[name]`). For an alt cached
   *before* this feature, the copy can be `deploy`-filled so no key is `nil`.
   > **Caveat (review finding, Phase B).** "Already materialized" holds only for
   > the build an alt last saved under. The runtime defaults live in the windows'
   > `InitDefVals`/`SetDef`, **not** in the copied data or the (empty) template, so a
   > *future* build that adds a cfg key would let a resolved alt return a copy
   > missing it — and the empty-subtree fallback does **not** catch a *partial*
   > subtree. Phase B must therefore run the consuming window's `InitDefVals(0)`
   > against the returned copy (it fills only missing keys); do not rely on the
   > materialization invariant alone.

### 4.5 The view-mode toggle (decision 1)

New account-level setting at the SV root, default = layout-only:

```
TFuBagCfg.altview_apply_geometry = 0   -- 0 = Layout only (default), 1 = Full profile incl. geometry
```

Geometry key set = `{ win_w, win_h, frameLEFT, frameRIGHT, frameTOP, frameBOTTOM }`
(window size + the four scaled edge coords — `MainFrame` DragStop / OnResizeStopped).

- **Layout only (0):** after copying the alt's cfg, overwrite the geometry keys
  with the **logged-in** window's current values, so your window stays put while
  you flip through alts; only columns / category layout / button size / colors
  come from the alt.
- **Full profile (1):** keep the alt's geometry — the window resizes/repositions
  to match the alt.

Surfaced as a checkbox/dropdown in `ModernOpt.lua` (a viewing preference, kept at
the root so it does **not** vary when you switch your own profile). `legacy_sizing`
stays the logged-in value in both modes (it pairs with the physical window's
resize behavior, not the alt's layout).

---

## 5. Seams & call-site inventory

| # | Site | File:line | Change |
|---|---|---|---|
| 1 | `Inv:SetPlayer` | `TInv.lua:76` | re-bind `self.cfg = CfgForPlayer(playerid,"Inv")` |
| 2 | `Bank:SetPlayer` | `TBnk.lua:84` | re-bind `self.cfg = CfgForPlayer(playerid,"Bnk")` |
| 3 | `TFuBag:Init` | `TBag.lua:362` | write `player_guids[PLAYERID]` |
| 4 | `TFuBag:CfgForPlayer` | new (TBagProfiles.lua, beside `ActiveCfg`) | the resolver |
| 5 | view-mode toggle | new root key + `ModernOpt.lua` | the option UI |
| 6 | `TFuBag:GetCfgFromBag` | `TBag.lua:4222` (callers `4208`, `4257`) | **secondary** — bag-highlight color; player-agnostic. Cosmetic; defer (see §7). |

`db.OnProfileChanged` (`TBagProfiles.lua:309`) is untouched: switching your *own*
profile re-inits both windows (which `SetPlayer(PLAYERID)`), correctly snapping the
view back to yourself.

---

## 6. Edge cases

- **OnShow resets to the logged-in player**, so an alt view never persists across
  open/close — this is purely in-session render correctness; nothing new is saved.
- **Shared "default" profile:** two alts both on default correctly show the same
  shared layout. The target scenario (A=Alayout, B=Blayout, distinct) is the clean
  separated case.
- **Profile deleted while an alt pointed at it:** `DeleteProfile` already nils the
  dangling `profile_ids[guid]`, so `profiles[name]` is nil -> default fallback.
- **Manual-layout alts:** fixed (non-`ml_auto`) box positions are width-coupled; an
  alt's manual layout viewed at a different window width may clip. Auto-flow
  (default) reflows cleanly. Note, not a blocker.
- **Same name on different realms:** disambiguated by `playerid` (realm included).
- **Connected realms / transfers / GUID reuse:** out of scope; fallback covers a
  stale/missing map.

---

## 7. Out of scope / deferred

- **`GetCfgFromBag` bag-highlight colors** stay the logged-in char's when viewing
  an alt (it's a `TFuBag` method with no frame/player context). Cosmetic only;
  make it frame-aware in a follow-up if desired.
- Per-tab bank settings (names/icons/deposit flags) are already stored per-player
  in the item cache, so they render correctly per viewed char today — no change.

---

## 8. Phasing

- **A — model + resolver (no behavior change). DONE.** `player_guids` write in `Init`;
  `CfgForPlayer`; the deep-copy + defaults-ensure helper; headless tests. Inert
  until B wires it.
- **B — wire the seam. DONE (gated in-game 2026-06-05).** `SetPlayer` re-bind in both windows. Flips the behavior.
  Run the window's `InitDefVals(0)` against the alt copy so a cfg key added in a
  later build cannot read `nil` (review finding — see §4.4 item 3 caveat). In-game gate.
- **C — the toggle UI. DONE (gated in-game 2026-06-05).** The root-setting read and geometry splice already
  landed in B; C adds the `ModernOpt` control to flip `altview_apply_geometry`
  (full mode is reachable via `/script` until then). In-game gate the UI.
- **D — hardening / polish.** Write-path audit (resize grip, column +/-) to confirm
  the copy is belt-and-suspenders; optional `GetCfgFromBag` color seam.

Core (A+B) is tiny: ~3 lines in `Init`, a ~12-line resolver, two one-line
`SetPlayer` edits, plus the copy/defaults helper. The toggle (C) and the in-game
gate matrix are the bulk of the remaining effort. Estimate: roughly a focused
half-to-full day plus gating.

---

## 9. Test plan

### Headless (extends `addon-tools/tbag-fufu/tests/`)
- `CfgForPlayer`: logged-in -> `ActiveCfg` (live, identity); alt resolved
  `player_guids -> profile_ids -> profiles`; alt with no guid -> `default`; alt with
  deleted profile (`profile_ids[guid]=nil`) -> `default`; `default` missing ->
  `ActiveCfg` ultimate fallback (never nil).
- copy isolation: a write to the returned alt cfg does **not** mutate
  `profiles[name]`.
- partial materialization (Phase B): a resolved alt whose `[which]` subtree is
  non-empty but missing a key is defaults-filled by the seam (not left `nil`).
- geometry splice: mode 0 replaces the six geometry keys with the logged-in
  values and keeps the alt's layout keys; mode 1 keeps the alt's geometry.

### In-game gate (mandatory — SV-schema touch)
Two chars A (Alayout: e.g. 5 columns, custom categories) and B (Blayout: 8 columns):
1. On B, view A -> A's columns/categories render (not B's).
2. Toggle = Full -> window resizes to A's geometry; Toggle = Layout-only -> window
   keeps B's size, A's layout.
3. Switch back to self -> B's layout restored.
4. Resize the window while viewing A, switch to self, relog as A -> **A's saved
   size unchanged** (write-safety).
5. Alt never logged in under the profiles build -> renders the **default** layout.
6. Repeat for the bank, including a warband tab.

---

## 10. DF-swap note

After `TFuBag.Profiles = detailsFramework.SavedVars`: `profile_ids[guid]` becomes
DF-managed; `player_guids` and `altview_apply_geometry` remain ours at the SV root;
`CfgForPlayer` reads `profiles[name]` (DF's own schema). The feature survives the
swap with zero data migration.
