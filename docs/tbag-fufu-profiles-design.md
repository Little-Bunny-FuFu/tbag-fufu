# tbag-fufu — Per-character Profiles design (custom layer, DF-drop-in)

> Implementation-ready plan for adding per-character config **profiles** to tbag-fufu via a
> small **custom** saved-variables layer that is **schema- and API-compatible with
> Details-Framework (DF)** from day one, so a later move to DF is a near-literal swap with
> **zero user-data migration**. Reference: `Details-Framework/savedvars.lua` + `addon.lua`
> (clone `661fb6f`); AceDB `Ace3/AceDB-3.0/`. Authored 2026-06-04, on top of the released
> `v12.0.0.06`.

> **STATUS (2026-06-05): IMPLEMENTED.** P0 (migration) + P1 (engine) + P2 (integration) + P3
> (ModernOpt Profiles UI) are built, adversarially reviewed, gated in-game (lossless upgrade,
> multi-character, switch, /reset, logout-persist, cross-character create/copy/load), and
> committed on `master` (`TBagProfiles.lua` + the ModernOpt "Profiles" section). P4 = in-game
> gating (passed). P5 (the literal DF swap) remains optional/future. This is now the design of
> record, not a pending plan.

## TL;DR

- Add named **profiles** to the config; each character points at a profile (GUID-keyed).
- The config already funnels through `self.cfg` (354 reads) + a couple of resolver seams, so
  the mechanism is small: re-point ~6 seams, migrate the flat config once, add a Profiles UI.
- Build it **custom + lib-free now**, but obey **two compatibility rules** so adopting DF
  later is `TFuBag.Profiles = detailsFramework.SavedVars` + delete the engine:
  1. **Schema = DF's shape** (`profiles`/`profile_ids`, GUID keys, account data at SV root).
  2. **API = DF's signatures** on a DF-shaped `addonObject`.
- Account data (profession/reagent DB, flags) stays at the SV root — **not** profiled.

---

## 1. Current architecture (grounded)

- `TFuBagCfg` — the account-wide config SavedVariable. Mixed contents:
  - **Window config** (profile-able): `TFuBagCfg["Inv"]`, `TFuBagCfg["Bnk"]`.
  - **Account data** (NOT profile-able): `S_CREATED` / `S_REAGENT` (profession+reagent DB,
    `Professions.lua` / `TBagItemInfo.lua`), `user_filters` (account-wide saved searches,
    `TBag.lua:2339`), `trades_changed` (transient), `hide_blizzard_bank`, `bankTabs_warband`
    (account-wide warband tab snapshot, `TBnk.lua:442/446`), `catbar_split_v2` (a migration
    flag), `__taxonomy` (a `/`-command debug dump, `TBag.lua:5553`).
  - **Dead root keys** (already purged, NOT live config): `S_SKILLS` / `S_TRADES` / `S_SECOND`
    are nil'd every load by `CleanConfig` (`TBag.lua:676-678`); the live profession data lives
    per-character in `TFuBagInfo[playerid]` (`TBag.lua:469-471`), not at the `TFuBagCfg` root.
    `Body` / `TFuInv_RegisterHooks` are likewise nil'd. Migration leaves all of them alone.
- Each window assigns its cfg **once**: `self.cfg = TFuBagCfg["Inv"]` (`TInv.lua:142`),
  `TFuBagCfg["Bnk"]` (`TBnk.lua:144`). **354** `self.cfg[...]` reads flow through that.
- Config init: `TBag.lua:321-324` (`TFuBagCfg = {}; ["Bnk"]={}; ["Inv"]={}`).
- Defaults are **imperative**: `InitDefVals(cfg, …)` (~69 `SetDef` calls, `TBag.lua:2452` is
  `SetDef`), `SetDefColors(cfg, reset)`, `ResetSorts(cfg)` — all take a `cfg` arg already.
- Bag→config resolver: `GetCfgFromBag(bag)` (`TBag.lua:4203`) returns `Inv`/`Bnk`.
- Config reset: `TBagCmd.lua:87` / `:172` (`TFuBagCfg["Bnk"/"Inv"] = {}`); legacy-key cleanup
  `TBag.lua:668-675`.
- **Item caches are already per-character** (`TFuInvItm`/`TFuBnkItm`… keyed by
  `playerid = UnitName|Realm`, `TBag.lua:353`). They are NOT profiles and do not move.

The **only** places that resolve a window config from `TFuBagCfg` are: `TInv.lua:142`,
`TBnk.lua:144`, `GetCfgFromBag` (`4203`), the init (`321-324`), the resets (`TBagCmd 87/172`),
and the cleanup (`668-675`). That short list is the entire redirect surface.

---

## 2. Target saved-variables schema (DF-shaped)

Reuse the existing `TFuBagCfg` global SV (no `.toc` change). Reshape it to DF's container,
leaving account data at the root (DF's savedvars only ever touches `.profiles`/`.profile_ids`):

```lua
TFuBagCfg = {
  -- DF profile container ------------------------------------------------------
  profiles = {
    ["default"] = { Inv = { … }, Bnk = { … } },   -- per-profile window config
  },
  profile_ids = { [playerGUID] = "default" },       -- char -> profile (GUID, DF style)

  -- account-root data (UNCHANGED location, never profiled) --------------------
  [S_CREATED] = {…}, [S_REAGENT] = {…},   -- profession/reagent DB (S_SKILLS / S_TRADES /
                                          -- S_SECOND roots are DEAD: CleanConfig nils them)
  user_filters = {…}, trades_changed = …, hide_blizzard_bank = …, bankTabs_warband = …,
  catbar_split_v2 = …, __taxonomy = …,

  schema_version = 2,    -- NEW: gates the one-shot flat->profiles migration
}
```

**Compatibility-critical choices (Rule 1):**
- Default profile name is the literal **`"default"`** (DF's `CONST_DEFAULT_PROFILE_NAME`).
- `profile_ids` keyed by **`UnitGUID("player")`** (DF uses GUID; survives rename/realm xfer).
  This is independent of the existing `playerid` (Name|Realm) used by item caches.
- Container fields named **`profiles`** and **`profile_ids`** exactly (DF reads these).
- Account data stays at the root → DF's `GetSavedVariables`/`GetProfile`/`SaveProfile` leave it
  untouched (verified: they only read/write `.profiles[id]` and `.profile_ids`).

---

## 3. The custom API (DF-signature-compatible) — Rule 2

A single addon object, shaped like DF's `df_addon`, plus a `TFuBag.Profiles` namespace whose
functions mirror `detailsFramework.SavedVars` **exactly**:

```lua
TFuBag.db = {
  __savedGlobalVarsName     = "TFuBagCfg",
  __savedVarsDefaultTemplate = { Inv = <Inv defaults>, Bnk = <Bnk defaults> },  -- see §4
  profile = nil,                              -- set on load to the active profile table
  OnProfileChanged = function(self, profile) … end,   -- §7
}

-- signatures identical to detailsFramework.SavedVars.*
TFuBag.Profiles.GetSavedVariables(obj)                                  -- ensure+return TFuBagCfg
TFuBag.Profiles.GetCurrentProfileName(obj)                             -- profile_ids[GUID]
TFuBag.Profiles.GetProfile(obj, bCreateIfNotFound, profileToCopyFrom)  -- resolve + deploy defaults
TFuBag.Profiles.SetProfile(obj, profileName, bCopyFromCurrent)         -- switch + OnProfileChanged
TFuBag.Profiles.SaveProfile(obj)                                       -- strip defaults + persist
TFuBag.Profiles.DeleteProfile(obj, profileName)                        -- refuse current; clear ids
```

Internal helpers must match DF's **semantics** (so the later swap is behavior-identical):
- `deploy(dest, src)` — recursively fill keys **missing** in `dest` from `src` (non-destructive).
- `removeduplicate(t, template)` — strip keys in `t` that equal `template` (only overrides persist).
- `copy(dest, src)` — copy.

(tbag-fufu may already have table helpers — reuse them; only the public API + schema must match DF.)

**The later DF swap becomes:** `TFuBag.Profiles = detailsFramework.SavedVars` and feed the same
`TFuBag.db` object. Nothing else in §5–§7 changes. (See §9.)

---

## 4. Defaults bridge (imperative `SetDef` → DF's declarative template)

DF/AceDB expect a **declarative** defaults table; tbag-fufu builds defaults **imperatively** via
`InitDefVals`/`SetDefColors`. Two acceptable options:

- **(A) Recommended / least churn — keep `SetDef`, empty DF template.** After resolving the
  active profile, run the existing `InitDefVals(profile.Inv,…)` + `SetDefColors(profile.Inv)` (and
  `Bnk`) — exactly as today they run on `TFuBagCfg.Inv/.Bnk`. Give `__savedVarsDefaultTemplate`
  an **empty/minimal** table. DF still works (deploy/removeduplicate become no-ops); the only cost
  is the SV stores full values rather than only-overrides — negligible for a personal addon.
- **(B) Full DF parity — capture the template.** Run `InitDefVals`/`SetDefColors` once against an
  **empty** table to produce a static `{ Inv = <defaults>, Bnk = <defaults> }` and use it as the
  template, so DF's strip-defaults-on-save keeps the SV compact. *Validate that no default is
  runtime-dependent (bag count / locale) before trusting the captured table.*

Either way the `InitDefVals`/`SetDefColors`/`ResetSorts` functions are **unchanged** — they
already take a `cfg`; they just receive `profile.Inv` / `profile.Bnk`. Find their current call
sites and feed them the profile subtree.

---

## 5. Integration seams (the entire redirect surface)

| # | Site | Today | After |
|---|---|---|---|
| 1 | `TInv.lua:142` | `self.cfg = TFuBagCfg["Inv"]` | `self.cfg = TFuBag.db.profile.Inv` |
| 2 | `TBnk.lua:144` | `self.cfg = TFuBagCfg["Bnk"]` | `self.cfg = TFuBag.db.profile.Bnk` |
| 3 | `GetCfgFromBag` `TBag.lua:4206/4208` | `return TFuBagCfg["Inv"/"Bnk"]` | `return TFuBag.db.profile.Inv/.Bnk` |
| 4 | init `TBag.lua:321-324` | create `TFuBagCfg.Inv/.Bnk` | ensure container + **run migration** (§6) + resolve `TFuBag.db.profile` BEFORE any window reads cfg |
| 5 | cleanup `TBag.lua:668-675` | nil legacy keys on `TFuBagCfg.Inv/.Bnk` | run on `profile.Inv/.Bnk` (or fold into the migration) |
| 6 | reset `TBagCmd.lua:87/172` | `TFuBagCfg["Bnk"/"Inv"] = {}` | clear the **active profile's** `Inv`/`Bnk` subtree (then re-`InitDefVals`) |

The **354** `self.cfg[...]` consumers and `InitDefVals`/`SetDefColors`/`ResetSorts` are
**untouched**. A tiny `TFuBag:ActiveCfg("Inv"|"Bnk")` accessor (returns `TFuBag.db.profile[which]`)
can back seams 1–3 so there is one source of truth.

**Load-order invariant:** the profile must be resolved (seam 4) before seams 1–3 fire. Both
windows read their cfg in their init; resolve `TFuBag.db.profile` at `ADDON_LOADED` (where
`TFuBagCfg` is first ensured) so it exists by the time windows initialize.

---

## 6. Migration (flat → profiles) — the careful part

One-shot, version-gated, lossless. At init (seam 4), before resolving the profile:

```lua
TFuBagCfg = TFuBagCfg or {}
if (TFuBagCfg.schema_version == nil or TFuBagCfg.schema_version < 2) then
  TFuBagCfg.profiles    = TFuBagCfg.profiles or {}
  TFuBagCfg.profile_ids = TFuBagCfg.profile_ids or {}
  if (TFuBagCfg.Inv or TFuBagCfg.Bnk) and not TFuBagCfg.profiles["default"] then
    TFuBagCfg.profiles["default"] = { Inv = TFuBagCfg.Inv or {}, Bnk = TFuBagCfg.Bnk or {} }
    TFuBagCfg.Inv = nil          -- MOVE, not copy
    TFuBagCfg.Bnk = nil
  end
  TFuBagCfg.profile_ids[UnitGUID("player")] =
      TFuBagCfg.profile_ids[UnitGUID("player")] or "default"
  TFuBagCfg.schema_version = 2
end
```

**Lossless / no behavior change:** the account-wide config becomes the shared `"default"`
profile. Every character — including alts that log in later (their GUID defaults to `"default"`
at resolve time, exactly as DF's `addon.lua` does) — sees the **same** settings as before, until
someone deliberately creates/switches a profile. Account data (`S_*`, flags) never moves.

**Cleanup/reset (seams 5–6) must come after the move:** since `TFuBagCfg.Inv/.Bnk` no longer
exist at the root, the legacy-key nil-out (`668-675`) and the resets (`TBagCmd 87/172`) must
target the profile subtree, or break with a nil index. Audit those before shipping.

---

## 7. Profile switch (`OnProfileChanged`)

`SetProfile` saves the current profile, repoints this char's `profile_ids[GUID]`, resolves/creates
the new profile (optionally copy-from-current), sets `TFuBag.db.profile`, then fires
`OnProfileChanged(obj, profile)`:

```lua
TFuBag.db.OnProfileChanged = function(obj, profile)
  TFuInvFrame.cfg = profile.Inv;  TFuBag:InitDefVals(profile.Inv, …); TFuBag:SetDefColors(profile.Inv)
  TFuBnkFrame.cfg = profile.Bnk;  TFuBag:InitDefVals(profile.Bnk, …); TFuBag:SetDefColors(profile.Bnk)
  if (TFuInvFrame:IsShown()) then TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST) end
  if (TFuBnkFrame:IsShown()) then TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST) end
end
```

Matches DF's `Dispatch(addonObject.OnProfileChanged, …)` exactly.

---

## 8. Settings taxonomy (SV-root key → scope)

| Key(s) | Scope | Note |
|---|---|---|
| `Inv`, `Bnk` (all window display/layout/behavior, the ~69 `SetDef` keys, per-bar `G_BAR_*`, `cat_layout`/`cat_layout_free`, colors, `manual_layout`/`ml_*`, `frameButtonSize`/`scale`, `show_*`, sorts, `item_overrides`, category overrides) | **Profile** | move under `profiles[name]` |
| `S_CREATED` / `S_REAGENT` | Account root | profession/reagent DB (`Professions.lua`, `TBagItemInfo.lua`); per-account knowledge, not display prefs |
| `S_SKILLS` / `S_TRADES` / `S_SECOND` | Dead root key | nil'd every load by `CleanConfig` (`TBag.lua:676-678`); live data is per-char in `TFuBagInfo[playerid]`. Migration leaves them; do not profile |
| `user_filters` | Account root | account-wide saved searches (`TBag.lua:2339`; comment "available on every character") |
| `trades_changed` | Account root | transient signal flag |
| `hide_blizzard_bank` | Account root | global behavior toggle |
| `catbar_split_v2` | Account root | existing migration flag |
| `bankTabs_warband` | Account root | **resolved**: warband bank is account-wide; read/written directly (`TBnk.lua:442/446`), never via `self.cfg` → not a window pref |
| `__taxonomy` | Account root | `/`-command debug dump (`TBag.lua:5553`) |
| `Body`, `TFuInv_RegisterHooks` | Account root / drop | legacy keys already nil'd in cleanup |
| `profiles`, `profile_ids`, `schema_version` | Account root | the new container itself |

Rule of thumb: **display/layout/behavior preferences → profile; learned data, transient flags,
and migration bookkeeping → account root.** Convenient that the account-data keys are already
accessed *directly* (not via `self.cfg`), so they naturally stay at the root.

---

## 9. The later DF swap (proof of near-drop-in)

When/if DF is adopted (e.g., to modernize ModernOpt's UI):

1. Vendor DF under `libs/DetailsFramework/` (loads via its own `DetailsFrameworkCanLoad` gate).
2. **Engine:** `TFuBag.Profiles = detailsFramework.SavedVars` — delete the custom
   `GetProfile/SetProfile/SaveProfile/DeleteProfile/deploy/removeduplicate` (~150 lines). The
   `TFuBag.db` object already has the fields DF reads (`__savedGlobalVarsName`,
   `__savedVarsDefaultTemplate`, `profile`, `OnProfileChanged`).
3. **Lifecycle:** optional — either keep tbag-fufu's existing init and just call
   `detailsFramework.SavedVars.GetProfile(TFuBag.db)`, or migrate to
   `detailsFramework:CreateNewAddOn("tbag-fufu","TFuBagCfg",template)`.
4. **UI:** optionally replace the ModernOpt panel (§10) with
   `detailsFramework:CreateProfilePanel(TFuBag.db, …)` — or keep the custom panel.
5. **Data:** **zero migration** — the SV is already DF's shape and GUID-keyed.

Seams §5, the migration §6, the taxonomy §8, and the 354 consumers are **all reused**. Only the
~150-line engine (and optionally the panel) is replaced.

---

## 10. ModernOpt "Profiles" panel

Mirror DF's `CreateProfilePanel` layout (so a later swap is cosmetic), built from ModernOpt's
existing widgets: **Current profile** label; **Switch** dropdown (lists other profiles →
`SetProfile`); **Create new** text entry + button (optional "copy from current"); **Delete**
dropdown (excludes current) + button; change/delete notifications. ~150 lines. Refresh on show.

---

## 11. Risks & in-game gate (mandatory)

SV schema change ⇒ **must be gated in-game** (CLAUDE.md: trace producer/consumer; saved-schema
changes are highest-care). Test matrix:

- **Fresh install** (no SV): creates `profiles.default`, char → default, defaults applied.
- **Upgrade from flat `v12.0.0.06`**: migration moves `Inv/Bnk` into `default`, settings preserved
  byte-for-byte; account data (profession DB) intact; runs once (re-login doesn't re-migrate).
- **Multi-character**: alt logs in post-migration → shares `default` (same settings); creating a
  profile on the alt leaves the main's `default` untouched (independence).
- **Switch / create / copy-from / delete**: both windows re-render on switch; can't delete the
  in-use profile; deleting reassigns nothing for the current char.
- **Reset** (`/` reset command) clears only the active profile, not the account data.
- Parse-gate (`luac5.1 -p`) all touched files.

---

## 12. Implementation phases

- **P0 — schema + migration** (§2, §6): the container, version gate, lossless move. Headless-testable.
- **P1 — engine** (§3, §4): `TFuBag.Profiles.*` with DF signatures + `deploy`/`removeduplicate`
  semantics; the `TFuBag.db` object; the defaults bridge (option A first).
- **P2 — integration** (§5, §7): redirect seams 1–6, the `ActiveCfg` accessor, `OnProfileChanged`.
  Verify the load-order invariant.
- **P3 — UI** (§10): the ModernOpt Profiles panel.
- **P4 — in-game gate** (§11): the full matrix, especially the upgrade + multi-char lossless cases.
- **P5 — future, optional** (§9): DF adoption swap.

## Anchors (file:line, on `master` @ v12.0.0.06)

- cfg resolution: `TInv.lua:142`, `TBnk.lua:144`, `GetCfgFromBag` `TBag.lua:4203`.
- init/migration hook: `TBag.lua:321-324`; legacy cleanup `TBag.lua:668-675`.
- resets: `TBagCmd.lua:87`, `TBagCmd.lua:172`.
- defaults: `InitDefVals` (~`TBag.lua:3000+`), `SetDefColors`, `ResetSorts`, `SetDef` `TBag.lua:2452`.
- per-char item key (independent): `playerid` `TBag.lua:353` (Name|Realm) — NOT the profile key.
- DF reference: `Details-Framework/savedvars.lua`, `Details-Framework/addon.lua`; AceDB
  `Ace3/AceDB-3.0/AceDB-3.0.lua`, `Ace3/AceDBOptions-3.0/`.
