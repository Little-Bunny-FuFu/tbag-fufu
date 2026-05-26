-- $Id$

local _G = getfenv(0)
local TFuBag = _G.TFuBag
local L = TFuBag.LOCALE

local GetTradeSkillCategoryFilter = C_TradeSkillUI.GetCategories
local SetTradeSkillCategoryFilter = C_TradeSkillUI.SetRecipeCategoryFilter

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

-- 12.0: the recipe/reagent keyword scan (ScanRecipes) is built on the old
-- GetTradeSkill*/SetTradeSkill*/TradeSkillOnlyShowMakeable frame API, which was
-- removed. Gated off until rewritten against C_TradeSkillUI. While off the
-- created/reagent caches just stay empty and the keyword consumers
-- (MakeTradeCreationKeywords / MakeTradeReagentKeywords) iterate nothing.
Professions.RECIPE_SCAN_ENABLED = false

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

function Professions:SetReagentLink(arr, itemlink, trade, reagentlink)
  local itemid = TFuBag:GetItemID(itemlink)
  local reagentid = TFuBag:GetItemID(reagentlink)

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
      arr[TFuBag.S_VERSION] = self.DB_VERSION
    end
    arr[reagentid] = arr[reagentid] or {}
    arr[reagentid][trade] = arr[reagentid][trade] or {}
    arr[reagentid][trade][itemid] = 1
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


local function trade_skill_tooltip_scan(i, j)
  local tt = TFuBag_tt

  if (not tt) then
    tt = CreateFrame("GameTooltip","TFuBag_tt")
    -- Allow tooltip set methods to dynamically add new lines based on these
    tt:AddFontStrings(
      tt:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"),
      tt:CreateFontString("$parentTextRight1", nil, "GameTooltipText")
    )
  end
  tt:SetOwner(UIParent, "ANCHOR_NONE")  -- this makes sure that tooltip.valid = true
  tt:ClearLines()

  tt:SetTradeSkillItem(i, j)
  local _,link = tt:GetItem()
  return link
end

local function add_craft(created, reagent, tradeskillName, i)
  -- Note we can't use GetTradeSkillItemLink() or GetTradeSkillReagentItemLink()
  -- because it will return nil if the item is already cached.  We can use the
  -- tooltip because it'll give us enough of the link to get what we want.
  local craftItemLink = trade_skill_tooltip_scan(i)
  if not craftItemLink then return end
  TFuBag:SetItemLink(created, craftItemLink)

  for j = 1, C_TradeSkillUI.GetRecipeNumReagents(i) do
    local reagentItemLink = trade_skill_tooltip_scan(i, j)
    if reagentItemLink then
      Professions:SetReagentLink(reagent, craftItemLink, tradeskillName, reagentItemLink)
    end
  end
end

local function get_count(...)
  return select('#', ...)
end

local function process_skill_line(i, numTradeSkills, created, reagent, tradeskillName)
  local craftName, craftType, numAvailable, isExpanded = GetTradeSkillInfo(i)
  if craftType == "header" or craftType == "subheader" then
    if not isExpanded then
      ExpandTradeSkillSubClass(i)
      local skillsUnderHeader = GetNumTradeSkills() - numTradeSkills
      for j = i+1, i+skillsUnderHeader do
        process_skill_line(j, numTradeSkills+skillsUnderHeader, created, reagent, tradeskillName)
      end
      CollapseTradeSkillSubClass(i)
    end
  else
    add_craft(created, reagent, tradeskillName, i)
  end
end

function Professions.ScanRecipes()
  -- 12.0: gated off — the old GetTradeSkill* frame API below is gone. See
  -- Professions.RECIPE_SCAN_ENABLED above.
  if not Professions.RECIPE_SCAN_ENABLED then return end

  -- Get the name of the tradeskill and reverse it to enUS
  local tradeskillName = RL[C_TradeSkillUI.GetTradeSkillLine()]

  if tradeskillName then
    -- Then save to the global item cache
    local created = Professions:GetTradeCreated(tradeskillName)
    local reagent = Professions:GetReagents()

    -- Save the current filters
    local numInvFilters = get_count(GetTradeSkillInvSlots())
    local numSubClasses = get_count(GetTradeSkillSubClasses())
    local saveInvFilter, saveClassFilter, saveMakeable
    for i = 0, numInvFilters do
      if GetTradeSkillInvSlotFilter(i) then
        saveInvFilter = i
        break
      end
    end
    for i = 0, numSubClasses do
      if GetTradeSkillCategoryFilter(i) then
        saveClassFilter = i
        break
      end
    end
    local saveNameFilter = GetTradeSkillItemNameFilter()
    local saveMinLevel, saveMaxLevel = GetTradeSkillItemLevelFilter()

    -- Wipe the current filters
    SetTradeSkillInvSlotFilter(0, 1, 1)
    SetTradeSkillCategoryFilter(0, 1, 1)
    SetTradeSkillItemLevelFilter(0, 0)
    SetTradeSkillItemNameFilter("")

    -- Detect if the OnlyShowMakeable flag was set based on the number of
    -- trade skills we get.  Since there's no query function for this we
    -- have to guess if it's there.
    local origNumTradeSkills = GetNumTradeSkills()
    TradeSkillOnlyShowMakeable(false)
    local numTradeSkills = GetNumTradeSkills()
    if numTradeSkills > origNumTradeSkills then
      saveMakeable = true
    else
      saveMakeable = false
    end

    -- Iterate the trade skills
    for i = 1, numTradeSkills do
      process_skill_line(i, numTradeSkills, created, reagent, tradeskillName)
    end

    -- Restore the saved filters
    SetTradeSkillItemNameFilter(saveNameFilter or "")
    SetTradeSkillItemLevelFilter(saveMinLevel, saveMaxLevel)
    SetTradeSkillInvSlotFilter(saveInvFilter, 1, 1)
    SetTradeSkillCategoryFilter(saveClassFilter, 1, 1)
    TradeSkillOnlyShowMakeable(saveMakeable)
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
