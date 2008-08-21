-- $Id$

local TBag = TBag

-- Localization support
local L = TBag.LOCALE;

TBag.S_TRADES = "trades";
TBag.S_SECOND = "second";
TBag.S_SKILLS = "skills";
TBag.S_CREATED = "created";
TBag.S_REAGENT = "reagent";
TBag.S_UPDATE = "update_reference";
TBag.S_VERSION = "version";

function TBag:SetItemLink(arr, itemlink)
  local itemid = self:GetItemID(itemlink);
  if (itemid ~= "") then
    arr[itemid] = 1;
  end
end

function TBag:SetReagentLink(arr, itemlink, trade, reagentlink)
  local itemid = self:GetItemID(itemlink);
  local reagentid = self:GetItemID(reagentlink);
  if (itemid ~= "" and reagentid ~= "" and trade ~= "") then
    if (arr == nil) then
      arr = {};
      arr[self.S_VERSION] = 1;
    end
    if (arr[reagentid] == nil) then
      arr[reagentid] = {};
    end
    if (arr[reagentid][trade] == nil) then
      arr[reagentid][trade] = {};
    end
    arr[reagentid][trade][itemid] = 1;
  end
end

function TBag:GetProfessions(playerid)
  if (self:GetPlayerInfo(playerid, self.S_TRADES) == nil) then
    self:SetPlayerInfo(playerid, self.S_TRADES, {});
  end
  return self:GetPlayerInfo(playerid, self.S_TRADES);
end

function TBag:GetTwoProfessions(playerid)
  local TRADE1 = "";
  local TRADE2 = "";

  for k, v in pairs(self:GetProfessions(playerid)) do
    TRADE2 = TRADE1;
    TRADE1 = k;
  end

  return TRADE1, TRADE2;
end

function TBag:GetTradeType(trade)
  if (trade == nil) then
    return nil;
  else
--    self:PrintDEBUG("TBag:GetTradeType: "..trade);

    if ((trade == "Cooking") or (trade == "First Aid") 
      or (trade == "Fishing")) then
      return self.S_SECOND;
    elseif ((trade == "Alchemy") or (trade == "Blacksmithing") 
      or (trade == "Enchanting") or (trade == "Engineering") 
      or (trade == "Leatherworking") or (trade == "Tailoring")
      or (trade == "Jewelcrafting")) then
      return self.S_TRADES;
    else
      return self.S_SKILLS;
    end
  end
end

function TBag:GetTradeCreated(trade)
  local tradetype = self:GetTradeType(trade);
  if (TBagCfg[tradetype] == nil) then
    TBagCfg[tradetype] = {};
    TBagCfg[tradetype][self.S_VERSION] = 1;
  end
  if (TBagCfg[tradetype][trade] == nil) then
    TBagCfg[tradetype][trade] = {};
  end
  return TBagCfg[tradetype][trade];
end

function TBag:GetReagents()
  if (TBagCfg[self.S_REAGENT] == nil) then
    TBagCfg[self.S_REAGENT] = {};
    TBagCfg[self.S_REAGENT][self.S_VERSION] = 1;
  end
  return TBagCfg[self.S_REAGENT];
end


function TBag:GetSkillRank(trade)
  for idx = 1, GetNumSkillLines() do
    local skillName, isHeader, isExpanded, skillRank, numTempPoints, skillModifier,
      skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType,
      skillDescription = GetSkillLineInfo(idx)
    if (isHeader == nil) and (trade == skillName) then
      return skillRank;
    end
  end
end

function TBag:SetPlayerTrade(playerid, trade)
  local player = self:GetPlayer(playerid);
  local tradetype = self:GetTradeType(trade);

  if (player[tradetype] == nil) then
    player[tradetype] = {};
  end
  if (player[tradetype][trade] == nil) then
    -- Pass a message to the inv and bank windows to resort
    TBagCfg["trades_changed"] = 1;
  end
  -- check whether we've learned and relearned too many professions
  if (tradetype == self.S_TRADES) then
    local trades = self:GetProfessions(playerid);

    if (table.getn(trades) >= 2) then
      trades = {};  -- sadly, wipe it for now
    end
  end

  -- Add the trade no matter what
  player[tradetype][trade] = self:GetSkillRank(trade);
end


function TBag:Craft()
  -- load craft info
  if (GetNumCrafts() > 0) then
    local tradeskillName, currentLevel, maxLevel = GetCraftDisplaySkillLine();
    local craftItemLink;
    local reagentItemLink;
    local created;
    local reagent;

    
    -- hunter training window shows up as a craft with a nil tradeskillName
    if (tradeskillName ~= nil) then
      tradeskillName = L[tradeskillName]; -- reverse for localized to enUS

      self:SetPlayerTrade(self.PLAYERID, tradeskillName)

      -- Then save to the global item cache
      created = self:GetTradeCreated(tradeskillName);
      reagent = self:GetReagents();

      for i = 1, GetNumCrafts() do
        local craftName, craftSubSpellName, craftType, numAvailable, isExpanded = GetCraftInfo(i);
        craftItemLink = GetCraftItemLink(i);

        -- remember: a craft might just be a skill and not a physical item
        self:SetItemLink(created, craftItemLink);

        if (GetCraftNumReagents(i) > 0) then
          for i2 = 1, GetCraftNumReagents(i) do
            reagentItemLink = GetCraftReagentItemLink(i,i2);
	    self:SetReagentLink(reagent, craftItemLink, tradeskillName, reagentItemLink);
          end
        end
      end
    end
  end
end

function TBag:Trade()
  -- load tradeskill info
  if (GetNumTradeSkills() > 0) then
    local tradeskillName, currentLevel, maxLevel = GetTradeSkillLine();
    local craftItemLink;
    local reagentItemLink;
    local created;
    local reagent;

    tradeskillName = L[tradeskillName]; -- reverse for localized to enUS

    if (tradeskillName ~= nil) then
      self:SetPlayerTrade(self.PLAYERID, tradeskillName)

      -- Then save to the global item cache
      created = self:GetTradeCreated(tradeskillName);
      reagent = self:GetReagents();

      for i = 1, GetNumTradeSkills() do
        local craftName, craftType, numAvailable, isExpanded = GetTradeSkillInfo(i);
        craftItemLink = GetTradeSkillItemLink(i);

        if (craftType ~= "header") then
          TradeSkillFrame_SetSelection(i)
          TradeSkillFrame_Update();

          -- remember: a craft might just be a skill and not a physical item
          self:SetItemLink(created, craftItemLink);

          if (GetTradeSkillNumReagents(i) > 0) then
            for i2 = 1, GetTradeSkillNumReagents(i) do
              reagentItemLink = GetTradeSkillReagentItemLink(i,i2);
	      self:SetReagentLink(reagent, craftItemLink, tradeskillName, reagentItemLink);
            end
          end
        end
      end
    end
  end
end


function TBag:MakeTradeCreationKeyword(itm, id, trade, cat, docreated)
  if (trade ~= nil and type(trade) == "string"
    and cat ~= nil and type(cat) == "string" 
    and itm ~= nil) then
--    self:PrintDEBUG("TBag:MakeTradeKeyword: "..trade..", "..cat);
    if (itm[self.I_ITEMLINK] ~= nil) then
      local itemid;
      local aTrade = self:GetTradeCreated(trade);

      -- disable depending on preferences
      for itemid, _ in pairs(aTrade) do
        if (id == itemid) then
          if (docreated == 1) then
            itm[self.I_KEYWORD][string.format(L["%s_CREATED"],cat)] = 1;
          else
            itm[self.I_KEYWORD][string.format(L["%s_CREATED"],cat)] = nil;
          end
        end
      end
    end
  end
--  self:PrintDEBUG("TBag:MakeTradeKeyword done");
end

function TBag:MakeTradeReagentKeywords(itm, id, trade1, trade2)
  if (itm ~= nil and itm[self.I_ITEMLINK] ~= nil) then
    for reagent,_ in pairs(TBagCfg[self.S_REAGENT]) do
      if (reagent == id) then
	local max_count = 0;
	local counts = {};
        for trade,ids in pairs (TBagCfg[self.S_REAGENT][reagent]) do
	  local count = 0;
	  for i,_ in pairs (ids) do
	    count = count + 1;
	  end
	  if (counts[count] == nil) then
	    counts[count] = {};
	  end
	  counts[count][trade] = 1;
	  if (count > max_count) then
	    max_count = count;
	  end
        end
	for trade,_ in pairs (counts[max_count]) do
	    itm[self.I_KEYWORD][L[self:Cat(trade)]] = 1;
	    if (trade == trade1) then
	      itm[self.I_KEYWORD][L["TRADE1"]] = 1;
	    end
	    if (trade == trade2) then
	     itm[self.I_KEYWORD][L["TRADE2"]] = 1;
	    end
	end
      end
    end
  end
end

function TBag:GetAllProfessions()
  if (TBagCfg[self.S_TRADES] == nil) then
    TBagCfg[self.S_TRADES] = {};
  end
  return TBagCfg[self.S_TRADES];
end

function TBag:GetAllSeconds()
  if (TBagCfg[self.S_SECOND] == nil) then
    TBagCfg[self.S_SECOND] = {};
  end
  return TBagCfg[self.S_SECOND];
end

function TBag:GetAllSkills()
  if (TBagCfg[self.S_SKILLS] == nil) then
    TBagCfg[self.S_SKILLS] = {};
  end
  return TBagCfg[self.S_SKILLS];
end

function TBag:MakeAllTradeKeywords(itm, docreated, trade1, trade2)
  local id = self:GetItemID(itm[self.I_ITEMLINK]);
  -- setup trade keywords
  for trade, _ in pairs(self:GetAllProfessions()) do
    if (trade ~= 'version' and trade ~= self.S_UPDATE) then
--    self:PrintDEBUG("profession ="..trade );
      self:MakeTradeCreationKeyword(itm, id, trade, L[self:Cat(trade)], docreated);
    end
  end
  for trade, _ in pairs(self:GetAllSeconds()) do
    if (trade ~= 'version' and trade ~= self.S_UPDATE) then
--    self:PrintDEBUG("second ="..trade );
      self:MakeTradeCreationKeyword(itm, id, trade, L[self:Cat(trade)], docreated);
    end
  end
  for trade, _ in pairs(self:GetAllSkills()) do
    if (trade ~= 'version' and trade ~= self.S_UPDATE) then
--    self:PrintDEBUG("skill ="..trade );
      self:MakeTradeCreationKeyword(itm, id, trade, L[self:Cat(trade)], docreated);
    end
  end
  self:MakeTradeReagentKeywords(itm, id, trade1, trade2);
end
