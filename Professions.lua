-- $Id$

local _G = getfenv(0)
local TBag = _G.TBag
local L = TBag.LOCALE

-- Constants used throughout the addon
TBag.S_TRADES  = "trades"
TBag.S_SECOND  = "second"
TBag.S_SKILLS  = "skills"
TBag.S_CREATED = "created"
TBag.S_REAGENT = "reagent"
TBag.S_UPDATE  = "update_reference"
TBag.S_VERSION = "version"

TBag.Professions = {}
local Professions = TBag.Professions

-- Current DB Version
Professions.DB_VERSION = 2

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


function TBag:SetItemLink(arr, itemlink)
  local itemid = TBag:GetItemID(itemlink)
  if itemid ~= "" then
    arr[itemid] = 1
  end
end

function Professions:SetReagentLink(arr, itemlink, trade, reagentlink)
  local itemid = TBag:GetItemID(itemlink)
  local reagentid = TBag:GetItemID(reagentlink)

  -- Allow enchant links.  They'll differ in the table by being
  -- prefixed by enchant: rather than just being a numeric id.
  if (itemid == "") then
    local enchantlink = itemlink:match("(enchant:%d+)[:|]")
    if enchantlink then
      itemid = enchantlink
    end
  end

  if itemid ~= "" and reagentid ~= "" and trade ~= "" then
    if not arr then
      arr = {}
      arr[TBag.S_VERSION] = self.DB_VERSION
    end
    arr[reagentid] = arr[reagentid] or {}
    arr[reagentid][trade] = arr[reagentid][trade] or {}
    arr[reagentid][trade][itemid] = 1
  end
end

function Professions:GetProfessions(playerid)
  local trades = TBag:GetPlayerInfo(playerid, TBag.S_TRADES)
  if not trades then
    trades = {}
    TBag:SetPlayerInfo(playerid, TBag.S_TRADES, trades)
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
  if TBag:Member(self.trades, trade) then
    return TBag.S_SECOND
  elseif TBag:Member(self.seconds, trade) then 
    return TBag.S_TRADES
  else
    return TBag.S_SKILLS
  end
end

function Professions:GetTradeCreated(trade)
  if not TBagCfg[TBag.S_CREATED] then	
    TBagCfg[TBag.S_CREATED] = {}
    TBagCfg[TBag.S_CREATED][TBag.S_VERSION] = self.DB_VERSION
  end
  TBagCfg[TBag.S_CREATED][trade] = TBagCfg[TBag.S_CREATED][trade] or {}
  return TBagCfg[TBag.S_CREATED][trade]
end

function Professions:GetReagents()
  if not TBagCfg[TBag.S_REAGENT] then
    TBagCfg[TBag.S_REAGENT] = {}
    TBagCfg[TBag.S_REAGENT][TBag.S_VERSION] = self.DB_VERSION
  end
  return TBagCfg[TBag.S_REAGENT]
end

function Professions:GetSkillRank(trade)
  -- Localize the trade naem to search for since we use English names
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
	  return skillRank
	end
      end
      CollapseSkillHeader(idx)
    else
      if not isHeader and trade == skillName then
        return skillRank
      end
    end
  end
end

function Professions:ScanAllTradeRanks()
  local player = TBag:GetPlayer(TBag.PLAYERID) 
  player[TBag.S_TRADES] = player[TBag.S_TRADES] or {}
  player[TBag.S_SECOND] = player[TBag.S_SECOND] or {}
  for _,v in ipairs(self.trades) do
    local cache = player[TBag.S_TRADES][v]
    player[TBag.S_TRADES][v] = self:GetSkillRank(v)
    if cache ~= player[TBag.S_TRADES][v] then
      TBagCfg["trades_changed"] = 1
    end
  end
  for _,v in ipairs(self.seconds) do
    player[TBag.S_SECOND][v] = self:GetSkillRank(v)
  end
  for _,v in ipairs(self.skills) do
    player[TBag.S_SKILLS][v] = self:GetSkillRank(v)
  end
end

function Professions.ScanRecipes() 
  -- Load the info for the tradeskill currently open
  local numTradeSkills = GetNumTradeSkills()
  if (numTradeSkills > 0) then
    -- Get the name of the tradeskill and reverse it to enUS
    local tradeskillName = RL[GetTradeSkillLine()]

    if tradeskillName then
      -- Then save to the global item cache
      local created = Professions:GetTradeCreated(tradeskillName)
      local reagent = Professions:GetReagents()

      for i = 1, numTradeSkills do
        local craftName, craftType, numAvailable, isExpanded = GetTradeSkillInfo(i)
	local craftItemLink = GetTradeSkillItemLink(i)

	if craftType ~= "header" then
	  TradeSkillFrame_SetSelection(i)
	  TradeSkillFrame_Update()

	  -- remember: a craft might just be a skill and not a physical item
	  TBag:SetItemLink(created, craftItemLink)

	  local numReagents = GetTradeSkillNumReagents(i)
	  if numReagents > 0 then
            for j = 1, numReagents do
              local reagentItemLink = GetTradeSkillReagentItemLink(i,j)
	      Professions:SetReagentLink(reagent, craftItemLink, tradeskillName, reagentItemLink)
	    end
	  end
        end
      end
    end
  end
end

function Professions:MakeTradeCreationKeywords(itm, itemid, docreated)
  if not itm or not itemid then return end
  if not itm[TBag.I_ITEMLINK] then return end
  local created = TBagCfg[TBag.S_CREATED]

  for trade in pairs(created) do
    if trade ~= TBag.S_VERSION and trade ~= TBag.S_UPDATE then
      if created[trade][itemid] then
        if docreated == 1 then
          itm[TBag.I_KEYWORD][string.format(L["%s_CREATED"],L[TBag:Cat(trade)])] = 1
	else
          itm[TBag.I_KEYWORD][string.format(L["%s_CREATED"],L[TBag:Cat(trade)])] = nil
	end
      end
    end
  end
end

function Professions:MakeTradeReagentKeywords(itm, itemid, trade1, trade2)
  if not itm or not itemid then return end
  if not itm[TBag.I_ITEMLINK] then return end
  local reagents = TBagCfg[TBag.S_REAGENT]

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
      itm[TBag.I_KEYWORD][L[TBag:Cat(trade)]] = 1
      if trade == trade1 then
        itm[TBag.I_KEYWORD][L["TRADE1"]] = 1
      end
      if trade == trade2 then
        itm[TBag.I_KEYWORD][L["TRADE2"]] = 1
      end
    end
  end
end

function Professions:MakeAllTradeKeywords(itm, docreated, trade1, trade2)
  local itemid = TBag:GetItemID(itm[TBag.I_ITEMLINK])
  self:MakeTradeCreationKeywords(itm, itemid, docreated)
  self:MakeTradeReagentKeywords(itm, itemid, trade1, trade2)
end
