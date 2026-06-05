--[[ TBagProfiles.lua ----------------------------------------------------------
  Per-character configuration PROFILES for tbag-fufu.

  Built as a small, library-free layer that is intentionally schema- and
  API-compatible with Tercioo's Details-Framework (DF) SavedVars module, so a
  later move to DF is a near-literal engine swap with ZERO saved-data migration:

      TFuBag.Profiles = detailsFramework.SavedVars   -- delete this file's engine

  Two compatibility rules are obeyed (see tbag-fufu-profiles-design.md):
    1. Schema == DF's shape: TFuBagCfg.profiles[name] / .profile_ids[GUID], the
       literal default profile name "default", account data left at the SV root.
    2. API == DF's signatures: TFuBag.Profiles.* mirror detailsFramework.SavedVars.*
       and operate on a DF-shaped addon object (TFuBag.db).

  This file defines the schema constants, the one-shot flat->profiles migration,
  the per-character profile resolver, and the profile engine. By itself it does
  NOT repoint the window-config seams or apply defaults to a profile -- that is
  the integration phase. Loading this file only defines functions; they take effect
  when TFuBag:Init() calls the migration/resolver and RecordPlayerGUID (this file is
  loaded via the .toc, before TBag.xml).
--------------------------------------------------------------------------------]]

local TFuBag = _G.TFuBag
if (not TFuBag) then return end   -- TBag.lua defines TFuBag and loads first

--- Saved-variables schema version. Bumped to 2 when the flat per-window config
--- (TFuBagCfg.Inv / .Bnk) was moved under TFuBagCfg.profiles["default"].
TFuBag.SCHEMA_VERSION = 2

--- The default profile name. MUST equal DF's CONST_DEFAULT_PROFILE_NAME so a
--- later DF swap resolves the same profile.
TFuBag.DEFAULT_PROFILE = "default"

-- == table helpers (DF-table semantics; file-local so the DF swap deletes them) ==

--- True if two numbers are within epsilon (default 0.0001). The only caller is
--- removeduplicate, which -- exactly like DF.table.removeduplicate -- passes 0.0001
--- explicitly, so the compare matches DF in the path that matters. (DF:IsNearlyEqual's
--- OWN default is a smaller 1e-6, but that default is never reached here.)
local function nearlyEqual(a, b, epsilon)
  return math.abs(a - b) <= (epsilon or 0.0001)
end

--- Copy into t1 only the keys MISSING from t1 (recursive, non-destructive merge
--- of defaults). Identical semantics to DF.table.deploy: existing values are
--- left untouched, leaf values are copied by value, and subtables are rebuilt
--- (never aliased to t2).
local function deploy(t1, t2)
  for key, value in pairs(t2) do
    if (type(value) == "table") then
      if (t1[key] == nil or type(t1[key]) == "table") then
        t1[key] = t1[key] or {}
        deploy(t1[key], value)
      end
    elseif (t1[key] == nil) then
      t1[key] = value
    end
  end
  return t1
end

--- Remove from t1 every key whose value equals t2's (numbers compared with
--- epsilon; emptied subtables pruned). Identical semantics to
--- DF.table.removeduplicate. Used to keep the saved profile to user-overrides
--- only -- a no-op while the default template is empty (option A).
local function removeduplicate(t1, t2)
  for key, value in pairs(t2) do
    if (type(value) == "table") then
      if (type(t1[key]) == "table") then
        removeduplicate(t1[key], value)
        if (not next(t1[key])) then
          t1[key] = nil
        end
      end
    elseif (type(t1[key]) == "number" and type(value) == "number") then
      if (nearlyEqual(t1[key], value)) then
        t1[key] = nil
      end
    elseif (t1[key] == value) then
      t1[key] = nil
    end
  end
end

--- Safe call of an addon callback (mirrors DF:Dispatch's swallow-and-report).
local function dispatch(func, ...)
  if (type(func) == "function") then
    local ok, err = pcall(func, ...)
    if (not ok and geterrorhandler) then
      geterrorhandler()(err)
    end
  end
end

-- == P0: schema migration + per-character resolver ==============================

--- One-shot, version-gated, lossless reshape of the flat v12.0.0.06 config into
--- the DF-shaped profile container. Operates in place on `sv` (default: the
--- global TFuBagCfg) and returns it.
---
--- The flat per-window config (sv.Inv / sv.Bnk) is MOVED -- not copied -- into
--- the shared "default" profile, so every existing character keeps its exact
--- settings. Account data (S_*, flags) stays at the SV root and is untouched.
--- Per-character profile assignment is intentionally NOT done here (it is the
--- resolver's job, so alts that first log in AFTER this runs still get assigned).
function TFuBag:MigrateConfig(sv)
  sv = sv or _G.TFuBagCfg
  if (type(sv) ~= "table") then
    return sv
  end

  -- Idempotent: once at (or past) the current schema, never re-migrate. The
  -- type() check also means a corrupt non-number schema_version falls through
  -- and is overwritten below, rather than raising on the >= comparison.
  if (type(sv.schema_version) == "number" and sv.schema_version >= self.SCHEMA_VERSION) then
    return sv
  end

  sv.profiles    = sv.profiles or {}
  sv.profile_ids = sv.profile_ids or {}

  if (sv.Inv ~= nil or sv.Bnk ~= nil) then
    -- Fill the "default" profile from the flat root keys. If a default already
    -- exists (an unusual hand-edited / partial pre-state), only add the window
    -- subtrees it is MISSING -- never clobber an existing profile. Either way the
    -- root keys are then cleared and the schema stamped, so root Inv/Bnk can
    -- never be left orphaned (stranded at the root yet marked migrated).
    local default = sv.profiles[self.DEFAULT_PROFILE]
    if (default == nil) then
      sv.profiles[self.DEFAULT_PROFILE] = { Inv = sv.Inv or {}, Bnk = sv.Bnk or {} }
    else
      default.Inv = default.Inv or sv.Inv
      default.Bnk = default.Bnk or sv.Bnk
    end
    sv.Inv = nil   -- MOVE, not copy
    sv.Bnk = nil
  end

  sv.schema_version = self.SCHEMA_VERSION
  return sv
end

--- Resolve (and lazily assign) the profile name for a character. Runs every
--- login, per character -- an unknown character defaults to "default". Mirrors
--- Details-Framework addon.lua's profile_ids assignment exactly.
function TFuBag:ResolveProfileName(sv, guid)
  sv = sv or _G.TFuBagCfg
  if (type(sv) ~= "table") then
    return self.DEFAULT_PROFILE
  end
  guid = guid or (UnitGUID and UnitGUID("player"))
  sv.profile_ids = sv.profile_ids or {}
  if (not guid) then
    return self.DEFAULT_PROFILE
  end
  local id = sv.profile_ids[guid]
  if (id == nil) then
    id = self.DEFAULT_PROFILE
    sv.profile_ids[guid] = id
  end
  return id
end

-- == P1: profile engine (signatures identical to detailsFramework.SavedVars) ====

TFuBag.Profiles = TFuBag.Profiles or {}
local Profiles = TFuBag.Profiles

--- Ensure the global SV table exists and carries the profile container; return it.
function Profiles.GetSavedVariables(addonObject)
  local name = addonObject.__savedGlobalVarsName
  if (not name) then
    return {}
  end

  local savedVariables = _G[name]
  if (not savedVariables) then
    savedVariables = { profiles = {}, profile_ids = {} }
    _G[name] = savedVariables
  end
  if (not savedVariables.profile_ids) then savedVariables.profile_ids = {} end
  if (not savedVariables.profiles) then savedVariables.profiles = {} end

  return savedVariables
end

--- The profile name this character is currently using (nil if unresolved).
function Profiles.GetCurrentProfileName(addonObject)
  local savedVariables = Profiles.GetSavedVariables(addonObject)
  return savedVariables.profile_ids[UnitGUID("player")]
end

--- Resolve this character's profile table; optionally create it (optionally as a
--- copy of another profile) and fill in the default template. Mirrors DF: a newly
--- created profile is returned but NOT written into .profiles until it is saved.
function Profiles.GetProfile(addonObject, bCreateIfNotFound, profileToCopyFrom)
  local playerGUID = UnitGUID("player")
  local savedVariables = Profiles.GetSavedVariables(addonObject)
  local profileId = savedVariables.profile_ids[playerGUID]
  local profileTable = savedVariables.profiles[profileId]

  if (not profileTable and bCreateIfNotFound) then
    profileTable = {}
    if (profileToCopyFrom) then
      profileTable = deploy(profileTable, profileToCopyFrom)
    end
  end

  if (profileTable and not profileTable.__loaded and addonObject.__savedVarsDefaultTemplate) then
    profileTable = deploy(profileTable, addonObject.__savedVarsDefaultTemplate)
    profileTable.__loaded = true   -- removed again when the profile is saved
  end

  return profileTable
end

--- Switch this character to `profileName` (creating it, optionally copying the
--- current profile into it), then fire OnProfileChanged. Saves the outgoing
--- profile first.
function Profiles.SetProfile(addonObject, profileName, bCopyFromCurrentProfile)
  assert(type(profileName) == "string", "SetProfile: profileName must be a string.")
  local currentProfile = Profiles.GetProfile(addonObject)
  if (addonObject.profile) then
    Profiles.SaveProfile(addonObject)
  end

  local savedVariables = Profiles.GetSavedVariables(addonObject)
  savedVariables.profile_ids[UnitGUID("player")] = profileName

  local profileTable = Profiles.GetProfile(addonObject, true, bCopyFromCurrentProfile and currentProfile or nil)
  addonObject.profile = profileTable

  if (addonObject.OnProfileChanged) then
    dispatch(addonObject.OnProfileChanged, addonObject, profileTable)
  end
end

--- Persist the in-use profile: strip values equal to the default template, drop
--- the __loaded marker, and write it back into .profiles under this character's id.
function Profiles.SaveProfile(addonObject)
  local profileTable = rawget(addonObject, "profile")
  if (profileTable and profileTable.__loaded) then
    if (addonObject.__savedVarsDefaultTemplate) then
      removeduplicate(profileTable, addonObject.__savedVarsDefaultTemplate)
    end
    profileTable.__loaded = nil

    -- Precondition (same as DF): profile_ids[guid] is already assigned by
    -- ResolveProfileName at load. If it were not, the write below would raise on a
    -- nil index -- intentionally loud, so a P2 resolve-before-engine wiring mistake
    -- fails in testing rather than silently not persisting.
    local savedVariables = Profiles.GetSavedVariables(addonObject)
    local playerProfileId = savedVariables.profile_ids[UnitGUID("player")]
    savedVariables.profiles[playerProfileId] = profileTable
  end
end

--- Delete `profileName`. Refuses the profile this character is using, and clears
--- any profile_ids entries that pointed at the deleted profile. Returns success.
function Profiles.DeleteProfile(addonObject, profileName)
  assert(type(profileName) == "string", "DeleteProfile: profileName must be a string.")
  local savedVariables = Profiles.GetSavedVariables(addonObject)
  local currentProfileId = savedVariables.profile_ids[UnitGUID("player")]

  if (profileName == currentProfileId) then
    return false
  end
  if (not savedVariables.profiles[profileName]) then
    return false
  end

  savedVariables.profiles[profileName] = nil
  for guid, profileId in pairs(savedVariables.profile_ids) do
    if (profileId == profileName) then
      savedVariables.profile_ids[guid] = nil
    end
  end

  return true
end

-- == The DF-shaped addon object =================================================
-- The integration phase sets `profile` (the active profile table) and wires
-- `OnProfileChanged` (re-point window cfg + redraw). Option A keeps the default
-- template minimal -- just the two window subtrees so profile.Inv / profile.Bnk
-- always exist -- and applies the real defaults imperatively via InitDefVals
-- after the profile is resolved.
TFuBag.db = TFuBag.db or {
  __savedGlobalVarsName      = "TFuBagCfg",
  __savedVarsDefaultTemplate = { Inv = {}, Bnk = {} },
  profile                    = nil,
}

-- == Integration helpers (used by the window-config seams) ======================

--- The active profile's window-config subtree ("Inv" or "Bnk"). One source of
--- truth for the seams that used to read TFuBagCfg["Inv"/"Bnk"] directly. Returns
--- nil only if called before TFuBag:Init() has resolved the profile.
function TFuBag:ActiveCfg(which)
  local profile = self.db and self.db.profile
  return profile and profile[which]
end

--- Runtime profile switch (fired by Profiles.SetProfile). Re-point both windows at
--- the now-active profile and redraw. Re-running each window's init(0) is the same
--- path /reset uses -- reset=0 keeps the profile's own values and fills any missing
--- defaults -- and init resolves its cfg through TFuBag:ActiveCfg, which now returns
--- the new profile's subtree.
TFuBag.db.OnProfileChanged = function(addonObject, profile)
  profile.Inv = profile.Inv or {}
  profile.Bnk = profile.Bnk or {}
  local inv, bnk = _G.TFuInvFrame, _G.TFuBnkFrame
  if (inv) then inv:init(0) end
  if (bnk) then bnk:init(0) end
  if (inv and inv:IsShown()) then inv:UpdateWindow(TFuBag.REQ_MUST) end
  -- The bank's per-tab item buttons are built lazily by RebuildTabList (on bank
  -- open / tab switch), not by init -- so a re-init alone leaves an already-open
  -- bank blank until it is reopened. Mirror BANKFRAME_OPENED's already-shown path:
  -- rebuild the tab content against the new profile, then force a re-sort/relayout
  -- (REQ_MUST, since a profile can change categories / columns / button size).
  if (bnk and bnk:IsShown()) then
    bnk:RebuildTabList()
    bnk:UpdateWindow(TFuBag.REQ_MUST)
  end
end

-- == Alt-view profile bridge (tbag-specific; NOT part of the DF mirror) =========
-- The cross-character bag/bank VIEWER is keyed by playerid ("Name|Realm"); the
-- profile system is keyed by UnitGUID. A character you are not logged into has no
-- queryable GUID, so the viewer cannot map a cached alt to its profile on its own.
-- These helpers add the missing playerid->guid bridge and a viewer-side cfg
-- resolver. They sit OUTSIDE the DF-mirrored engine on purpose: Details-Framework
-- is GUID-only and has no viewer, so the bridge is ours and survives the DF swap
-- (it only READS profile_ids/profiles, which DF maintains in the same schema). The
-- map lives at the SV ROOT (sv.player_guids), never inside the DF-owned profiles /
-- profile_ids tables, and profile ASSIGNMENT stays solely in profile_ids[guid].

--- Record this character's playerid->guid mapping so the viewer can later resolve a
--- cached alt's profile. Lazily populated each login (no schema bump). No-op on bad
--- input. This only adds the reverse lookup DF cannot provide; it never assigns a
--- profile (that remains ResolveProfileName's job, writing profile_ids[guid]).
function TFuBag:RecordPlayerGUID(sv, playerid, guid)
  sv = sv or _G.TFuBagCfg
  if (type(sv) ~= "table" or type(playerid) ~= "string" or playerid == "" or not guid) then
    return
  end
  sv.player_guids = sv.player_guids or {}
  sv.player_guids[playerid] = guid
end

--- The window-config subtree ("Inv"/"Bnk") to render for `playerid`:
---   * the logged-in character (or an unknown/nil id) -> the LIVE in-use profile
---     (ActiveCfg) -- same table identity as today, so the self-view keeps editing
---     its own profile;
---   * a cached alt -> a write-safe DEEP COPY of that alt's persisted profile
---     subtree, so a read-only alt view can never mutate another character's saved
---     profile (Phase C also splices window geometry onto this copy per the
---     view-mode toggle).
--- Resolution: playerid -> player_guids[guid] -> profile_ids[name] -> profiles. An
--- unresolved alt (cached before this feature, or its profile deleted) falls back
--- to the "default" profile (locked decision), then to the live cfg so a render
--- read is never nil. The deep copy reuses the DF-table-semantics `deploy`, so the
--- behavior is identical after a DF swap.
---
--- Defaults caveat: an alt's saved profile carries only the SetDef keys that existed
--- when it last logged out -- the runtime defaults live in the windows' InitDefVals,
--- NOT in the copied data or the (empty) default template. For an alt saved under the
--- current build that is the complete set; if a LATER build adds a new cfg key, a
--- resolved alt can return a copy missing it (the empty-subtree guard below does not
--- catch a PARTIAL subtree). The fix belongs where the seam is wired (Phase B): run
--- the consuming window's InitDefVals(0) against the returned copy -- it only fills
--- missing keys. Until then this resolver has no caller, so there is no live impact.
function TFuBag:CfgForPlayer(playerid, which)
  local live = self:ActiveCfg(which)
  if (not playerid or playerid == self.PLAYERID) then
    return live
  end

  local sv = _G.TFuBagCfg
  local src
  if (type(sv) == "table") then
    local guid = sv.player_guids and sv.player_guids[playerid]
    local name = guid and sv.profile_ids and sv.profile_ids[guid]
    local prof = name and sv.profiles and sv.profiles[name]
    src = prof and prof[which]
    if (not (type(src) == "table" and next(src))) then
      local def = sv.profiles and sv.profiles[self.DEFAULT_PROFILE]
      src = def and def[which]
    end
  end
  if (not (type(src) == "table" and next(src))) then
    src = live   -- ultimate fallback: nothing usable -> a copy of the live cfg
  end

  return deploy({}, src or {})
end
