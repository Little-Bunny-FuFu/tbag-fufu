-- $Id$

local _G = getfenv(0)
local TFuBag = _G.TFuBag
local L = TFuBag.LOCALE

-- Constants used throughout the addon
TFuBag.S_TRADES  = "trades"
TFuBag.S_SECOND  = "second"
TFuBag.S_SKILLS  = "skills"
TFuBag.S_CREATED = "created"
TFuBag.S_REAGENT = "reagent"
TFuBag.S_UPDATE  = "update_reference"
TFuBag.S_VERSION = "version"

TFuBag.Professions = {}
local Professions = TFuBag.Professions

-- Current DB Version
Professions.DB_VERSION = 2

-- 12.0: recipe/reagent keyword scan rewritten against C_TradeSkillUI (the old
-- GetTradeSkill*/SetTradeSkill* frame API it used was removed). Set false to
-- disable the TRADE_SKILL_SHOW scan; the keyword consumers
-- (MakeTradeCreationKeywords / MakeTradeReagentKeywords) then just iterate an
-- empty cache and add no profession keywords.
Professions.RECIPE_SCAN_ENABLED = true

-- Trade type breakdowns
Professions.trades = {
  "Alchemy",
  "Blacksmithing",
  "Enchanting",
  "Engineering",
  "Herbalism",
  "Inscription",
  "Jewelcrafting",
  "Leatherworking",
  "Mining",
  "Skinning",
  "Tailoring",
}
Professions.seconds = {
  "Cooking",
  "Fishing",
  "First Aid",
  "Archaeology",
}
Professions.skills = {
  "Lockpicking",
  "Runeforging",
}

-- Build a reverse locale table to reverse trade
-- names to English for storage.
local RL = {}
for _,v in pairs(Professions.trades) do
  RL[L[v]] = v
end
for _,v in pairs(Professions.seconds) do
  RL[L[v]] = v
end
for _,v in pairs(Professions.skills) do
  RL[L[v]] = v
end


function TFuBag:SetItemLink(arr, itemlink)
  local itemid = TFuBag:GetItemID(itemlink)
  if itemid ~= "" then
    arr[itemid] = 1
  end
end

function Professions:GetProfessions(playerid)
  local trades = TFuBag:GetPlayerInfo(playerid, TFuBag.S_TRADES)
  if not trades then
    trades = {}
    TFuBag:SetPlayerInfo(playerid, TFuBag.S_TRADES, trades)
  end
  return trades
end

function Professions:GetTwoProfessions(playerid)
  local trades = self:GetProfessions(playerid)
  local TRADE1 = ""
  local TRADE2 = ""

  for k, v in pairs(trades) do
    TRADE2 = TRADE1
    TRADE1 = k
  end
  return TRADE1, TRADE2
end

function Professions:GetTradeType(trade)
  if TFuBag:Member(self.trades, trade) then
    return TFuBag.S_SECOND
  elseif TFuBag:Member(self.seconds, trade) then
    return TFuBag.S_TRADES
  else
    return TFuBag.S_SKILLS
  end
end

function Professions:GetTradeCreated(trade)
  if not TFuBagCfg[TFuBag.S_CREATED] then
    TFuBagCfg[TFuBag.S_CREATED] = {}
    TFuBagCfg[TFuBag.S_CREATED][TFuBag.S_VERSION] = self.DB_VERSION
  end
  TFuBagCfg[TFuBag.S_CREATED][trade] = TFuBagCfg[TFuBag.S_CREATED][trade] or {}
  return TFuBagCfg[TFuBag.S_CREATED][trade]
end

function Professions:GetReagents()
  if not TFuBagCfg[TFuBag.S_REAGENT] then
    TFuBagCfg[TFuBag.S_REAGENT] = {}
    TFuBagCfg[TFuBag.S_REAGENT][TFuBag.S_VERSION] = self.DB_VERSION
  end
  return TFuBagCfg[TFuBag.S_REAGENT]
end

local scanningTrades = false
function Professions:GetSkillRank(trade)
  if scanningTrades then return end
  scanningTrades = true
  local skillRankReturn
  -- Localize the trade name to search for since we use English names
  -- for the rest of the trade skill code.
  trade = L[trade]
  for idx = 1, GetNumSkillLines() do
    local skillName, isHeader, isExpanded, skillRank = GetSkillLineInfo(idx)
    if isHeader == 1 and not isExpanded then
      local size = GetNumSkillLines()
      ExpandSkillHeader(idx)
      size = GetNumSkillLines() - size
      for j = idx+1, idx+size do
        skillName, isHeader, isExpanded, skillRank = GetSkillLineInfo(j)
        if not isHeader and trade == skillName then
          CollapseSkillHeader(idx)
          skillRankReturn = skillRank
        end
      end
      CollapseSkillHeader(idx)
    else
      if not isHeader and trade == skillName then
        skillRankReturn = skillRank
      end
    end
  end
  scanningTrades = false
  return skillRankReturn
end

function Professions:ScanAllTradeRanks()
  local player = TFuBag:GetPlayer(TFuBag.PLAYERID)
  local prof1,prof2,arch,fish,cook,firstAid = GetProfessions()
  -- Grab the info for the first two professions and update them
  -- saving the names so we can wipe everything else.
  local prof1_name,prof2_name
  if prof1 then
    local rank, cache, _
    prof1_name,_,rank = GetProfessionInfo(prof1)
    prof1_name = RL[prof1_name]
    cache = player[TFuBag.S_TRADES][prof1_name]
    if cache ~= rank then
      player[TFuBag.S_TRADES][prof1_name] = rank
      TFuBagCfg["trades_changed"] = 1
    end
  end
  if prof2 then
    local rank, cache, _
    prof2_name,_,rank = GetProfessionInfo(prof2)
    prof2_name = RL[prof2_name]
    cache = player[TFuBag.S_TRADES][prof2_name]
    if cache ~= rank then
      player[TFuBag.S_TRADES][prof2_name] = rank
      TFuBagCfg["trades_changed"] = 1
    end
  end
  -- wipe professions that we didn't see this time
  for trade in pairs(player[TFuBag.S_TRADES]) do
    if trade ~= prof1_name and trade ~= prof2_name then
      player[TFuBag.S_TRADES][trade] = nil
      TFuBagCfg["trades_changed"] = 1
    end
  end

  -- Secondary skills
  if arch then
    local name,_,rank = GetProfessionInfo(arch)
    player[TFuBag.S_SECOND][RL[name]] = rank
  end
  if fish then
    local name,_,rank = GetProfessionInfo(fish)
    player[TFuBag.S_SECOND][RL[name]] = rank
  end
  if cook then
    local name,_,rank = GetProfessionInfo(cook)
    player[TFuBag.S_SECOND][RL[name]] = rank
  end
  if firstAid then
    local name,_,rank = GetProfessionInfo(firstAid)
    player[TFuBag.S_SECOND][RL[name]] = rank
  end

  -- We don't do anything with other skills
end


function Professions.ScanRecipes()
  if not Professions.RECIPE_SCAN_ENABLED then return end

  -- 12.0 rewrite: walk the open profession's recipes via C_TradeSkillUI (the old
  -- GetTradeSkill* window-scrape API is gone) and record, keyed by English
  -- profession name: every item the profession creates (created cache) and every
  -- item used as a Basic reagent (reagent cache). The cache shape is unchanged so
  -- MakeTradeCreationKeywords / MakeTradeReagentKeywords stay untouched. Keys are
  -- tostring(itemID) to match TFuBag:GetItemID(), which returns the id as a string.
  local info = C_TradeSkillUI.GetBaseProfessionInfo()
  if not info then return end
  -- GetBaseProfessionInfo().professionName is the base name (e.g. "Tailoring"),
  -- which RL reverses to English. If that ever maps to an expansion-specific name
  -- instead, fall back to the skill line's parentProfessionName (the canonical
  -- base-name field, per C_TradeSkillUI.GetProfessionInfoBySkillLineID).
  local tradeskillName = RL[info.professionName]
  if not tradeskillName and info.professionID then
    local lineInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(info.professionID)
    if lineInfo and lineInfo.parentProfessionName then
      tradeskillName = RL[lineInfo.parentProfessionName]
    end
  end
  if not tradeskillName then return end

  local created = Professions:GetTradeCreated(tradeskillName)
  local reagent = Professions:GetReagents()

  -- GetAllRecipeIDs ignores UI search/category filters; GetFilteredRecipeIDs is
  -- the documented fallback if the former is ever absent.
  local recipeIDs = (C_TradeSkillUI.GetAllRecipeIDs and C_TradeSkillUI.GetAllRecipeIDs())
                    or C_TradeSkillUI.GetFilteredRecipeIDs()
  if not recipeIDs then return end

  for _, recipeID in ipairs(recipeIDs) do
    local ri = C_TradeSkillUI.GetRecipeInfo(recipeID)
    if ri and ri.learned then
      local schematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, false)
      local outputID = schematic and schematic.outputItemID
      if outputID then
        local createdKey = tostring(outputID)
        created[createdKey] = 1

        for _, slot in ipairs(schematic.reagentSlotSchematics) do
          if slot.reagentType == Enum.CraftingReagentType.Basic then
            for _, r in ipairs(slot.reagents) do
              if r.itemID then
                local reagentKey = tostring(r.itemID)
                reagent[reagentKey] = reagent[reagentKey] or {}
                reagent[reagentKey][tradeskillName] = reagent[reagentKey][tradeskillName] or {}
                reagent[reagentKey][tradeskillName][createdKey] = 1
              end
            end
          end
        end
      end
    end
  end
end

function Professions:MakeTradeCreationKeywords(itm, itemid, trade1, trade2, docreated)
  if not itm or not itemid then return end
  if not itm[TFuBag.I_ITEMLINK] then return end
  local created = TFuBagCfg[TFuBag.S_CREATED]

  for trade in pairs(created) do
    if trade ~= TFuBag.S_VERSION and trade ~= TFuBag.S_UPDATE then
      if created[trade][itemid] then
        if docreated == 1 then
          itm[TFuBag.I_KEYWORD][string.format(L["%s_CREATED"],L[TFuBag:Cat(trade)])] = 1
          if trade == trade1 then
            itm[TFuBag.I_KEYWORD][string.format(L["%s_CREATED"],L["TRADE1"])] = 1
          end
          if trade == trade2 then
            itm[TFuBag.I_KEYWORD][string.format(L["%s_CREATED"],L["TRADE2"])] = 1
          end
        else
          itm[TFuBag.I_KEYWORD][string.format(L["%s_CREATED"],L[TFuBag:Cat(trade)])] = nil
        end
      end
    end
  end
end

function Professions:MakeTradeReagentKeywords(itm, itemid, trade1, trade2)
  if not itm or not itemid then return end
  if not itm[TFuBag.I_ITEMLINK] then return end
  local reagents = TFuBagCfg[TFuBag.S_REAGENT]

  if reagents[itemid] then
    local max_count = 0
    local counts = {}
    for trade,ids in pairs(reagents[itemid]) do
      local count = 0
      for _ in pairs(ids) do
        count = count + 1
      end
      counts[count] = counts[count] or {}
      counts[count][trade] = 1
      if count > max_count then
        max_count = count
      end
    end
    for trade in pairs(counts[max_count]) do
      itm[TFuBag.I_KEYWORD][L[TFuBag:Cat(trade)]] = 1
      if trade == trade1 then
        itm[TFuBag.I_KEYWORD][L["TRADE1"]] = 1
      end
      if trade == trade2 then
        itm[TFuBag.I_KEYWORD][L["TRADE2"]] = 1
      end
    end
  end
end

function Professions:MakeAllTradeKeywords(itm, docreated, trade1, trade2)
  local itemid = TFuBag:GetItemID(itm[TFuBag.I_ITEMLINK])
  self:MakeTradeCreationKeywords(itm, itemid, trade1, trade2, docreated)
  self:MakeTradeReagentKeywords(itm, itemid, trade1, trade2)
end
