TBAG_S_TRADES = "trades";
TBAG_S_SECOND = "second";
TBAG_S_SKILLS = "skills";
TBAG_S_CREATED = "created";
TBAG_S_REAGENT = "reagent";

function TBag_SetItemLink(arr, itemlink)
  local itemid = TBag_GetItemID(itemlink);
  if (itemid ~= "") then
    arr[itemid] = 1;
  end
end

function TBag_GetProfessions(playerid)
  if (TBag_GetPlayerInfo(playerid, TBAG_S_TRADES) == nil) then
    TBag_SetPlayerInfo(playerid, TBAG_S_TRADES, {});
  end
  return TBag_GetPlayerInfo(playerid, TBAG_S_TRADES);
end

function TBag_GetTwoProfessions(playerid)
  local TRADE1 = "";
  local TRADE2 = "";

  for k, v in pairs(TBag_GetProfessions(playerid)) do
    TRADE2 = TRADE1;
    TRADE1 = k;
  end

  return TRADE1, TRADE2;
end

function TBag_GetTradeType(trade)
  if (trade == nil) then
    return nil;
  else
--    TBag_PrintDEBUG("TBag_GetTradeType: "..trade);

    if ((trade == TBag_Loc("Cooking")) or (trade == TBag_Loc("First Aid")) 
      or (trade == TBag_Loc("Fishing"))) then
      return TBAG_S_SECOND;
    elseif ((trade == TBag_Loc("Alchemy")) or (trade == TBag_Loc("Blacksmithing")) 
      or (trade == TBag_Loc("Enchanting")) or (trade == TBag_Loc("Engineering")) 
      or (trade == TBag_Loc("Leatherworking")) or (trade == TBag_Loc("Tailoring"))
      or (trade == TBag_Loc("Jewelcrafting"))) then
      return TBAG_S_TRADES;
    else
      return TBAG_S_SKILLS;
    end
  end
end

function TBag_GetTrade(trade)
  local tradetype = TBag_GetTradeType(trade);
  if (TBagCfg[tradetype] == nil) then
    TBagCfg[tradetype] = {};
  end
  if (TBagCfg[tradetype][trade] == nil) then
    TBagCfg[tradetype][trade] = {};
  end
  return TBagCfg[tradetype][trade];
end

function TBag_GetTradeCreated(trade)
  aTrade = TBag_GetTrade(trade);
  if (aTrade[TBAG_S_CREATED] == nil) then
    aTrade[TBAG_S_CREATED] = {};
  end
  return aTrade[TBAG_S_CREATED];
end

function TBag_GetTradeReagent(trade)
  aTrade = TBag_GetTrade(trade);
  if (aTrade[TBAG_S_REAGENT] == nil) then
    aTrade[TBAG_S_REAGENT] = {};
  end
  return aTrade[TBAG_S_REAGENT];
end


function TBag_GetSkillRank(trade)
  for idx = 1, GetNumSkillLines() do
    local skillName, isHeader, isExpanded, skillRank, numTempPoints, skillModifier,
      skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType,
      skillDescription = GetSkillLineInfo(idx)
    if (isHeader == nil) and (trade == skillName) then
      return skillRank;
    end
  end
end

function TBag_SetPlayerTrade(playerid, trade)
  local player = TBag_GetPlayer(playerid);
  local tradetype = TBag_GetTradeType(trade);

  if (player[tradetype] == nil) then
    player[tradetype] = {};
  end
  if (player[tradetype][trade] == nil) then
    -- Pass a message to the inv and bank windows to resort
    TBagCfg["trades_changed"] = 1;
  end
  -- check whether we've learned and relearned too many professions
  if (tradetype == TBAG_S_TRADES) then
    local trades = TBag_GetProfessions(playerid);

    if (table.getn(trades) >= 2) then
      trades = {};  -- sadly, wipe it for now
    end
  end

  -- Add the trade no matter what
  player[tradetype][trade] = TBag_GetSkillRank(trade);
end


function TBag_Craft()
  -- load craft info
  if (GetNumCrafts() > 0) then
    local tradeskillName, currentLevel, maxLevel = GetCraftDisplaySkillLine();
    local craftItemLink;
    local reagentItemLink;
    local created;
    local reagent;

    -- hunter training window shows up as a craft with a nil tradeskillName
    if (tradeskillName ~= nil) then
      TBag_SetPlayerTrade(TBAG_PLAYERID, tradeskillName)

      -- Then save to the global item cache
      created = TBag_GetTradeCreated(tradeskillName);
      reagent = TBag_GetTradeReagent(tradeskillName);

      for i = 1, GetNumCrafts() do
        local craftName, craftSubSpellName, craftType, numAvailable, isExpanded = GetCraftInfo(i);
        craftItemLink = GetCraftItemLink(i);

        -- remember: a craft might just be a skill and not a physical item
        TBag_SetItemLink(created, craftItemLink);

        if (GetCraftNumReagents(i) > 0) then
          for i2 = 1, GetCraftNumReagents(i) do
            reagentItemLink = GetCraftReagentItemLink(i,i2);
            TBag_SetItemLink(reagent, reagentItemLink);
          end
        end
      end
    end
  end
end

function TBag_Trade()
  -- load tradeskill info
  if (GetNumTradeSkills() > 0) then
    local tradeskillName, currentLevel, maxLevel = GetTradeSkillLine();
    local craftItemLink;
    local reagentItemLink;
    local created;
    local reagent;

    if (tradeskillName ~= nil) then
      TBag_SetPlayerTrade(TBAG_PLAYERID, tradeskillName)

      -- Then save to the global item cache
      created = TBag_GetTradeCreated(tradeskillName);
      reagent = TBag_GetTradeReagent(tradeskillName);

      for i = 1, GetNumTradeSkills() do
        local craftName, craftType, numAvailable, isExpanded = GetTradeSkillInfo(i);
        craftItemLink = GetTradeSkillItemLink(i);

        if (craftType ~= "header") then
          TradeSkillFrame_SetSelection(i)
          TradeSkillFrame_Update();

          -- remember: a craft might just be a skill and not a physical item
          TBag_SetItemLink(created, craftItemLink);

          if (GetTradeSkillNumReagents(i) > 0) then
            for i2 = 1, GetTradeSkillNumReagents(i) do
              reagentItemLink = GetTradeSkillReagentItemLink(i,i2);
              TBag_SetItemLink(reagent, reagentItemLink);
            end
          end
        end
      end
    end
  end
end


function TBag_MakeTradeKeyword(itm, trade, cat, docreated)
  if (trade ~= nil and type(trade) == "string"
    and cat ~= nil and type(cat) == "string" 
    and itm ~= nil) then
--    TBag_PrintDEBUG("TBag_MakeTradeKeyword: "..trade..", "..cat);
    if (itm[TBAG_I_ITEMID] ~= nil) then
      local itemid;
      local aTrade = TBag_GetTrade(trade);

      -- disable depending on preferences
      for itemid, _ in pairs(aTrade[TBAG_S_CREATED]) do
        if (itm[TBAG_I_ITEMID] == itemid) then
          if (docreated == 1) then
            itm[TBAG_I_KEYWORD][cat.."_CREATED"] = 1;
          else
            itm[TBAG_I_KEYWORD][cat.."_CREATED"] = nil;
          end
        end
      end
      for itemid, _ in pairs(aTrade[TBAG_S_REAGENT]) do
        if (itm[TBAG_I_ITEMID] == itemid) then
          itm[TBAG_I_KEYWORD][cat] = 1;
        end
      end
    end
  end
end

function TBag_GetAllProfessions()
  if (TBagCfg[TBAG_S_TRADES] == nil) then
    TBagCfg[TBAG_S_TRADES] = {};
  end
  return TBagCfg[TBAG_S_TRADES];
end

function TBag_GetAllSeconds()
  if (TBagCfg[TBAG_S_SECOND] == nil) then
    TBagCfg[TBAG_S_SECOND] = {};
  end
  return TBagCfg[TBAG_S_SECOND];
end

function TBag_GetAllSkills()
  if (TBagCfg[TBAG_S_SKILLS] == nil) then
    TBagCfg[TBAG_S_SKILLS] = {};
  end
  return TBagCfg[TBAG_S_SKILLS];
end

function TBag_MakeAllTradeKeywords(itm, docreated)
  local trade;
  -- setup trade keywords
  for trade, _ in pairs(TBag_GetAllProfessions()) do
--    TBag_PrintDEBUG("profession ="..trade );
    TBag_MakeTradeKeyword(itm, TBag_Loc(trade), TBag_Cat(trade), docreated);
  end
  for trade, _ in pairs(TBag_GetAllSeconds()) do
--    TBag_PrintDEBUG("second ="..trade );
    TBag_MakeTradeKeyword(itm, TBag_Loc(trade), TBag_Cat(trade), docreated);
  end
  for trade, _ in pairs(TBag_GetAllSkills()) do
--    TBag_PrintDEBUG("skill ="..trade );
    TBag_MakeTradeKeyword(itm, TBag_Loc(trade), TBag_Cat(trade), docreated);
  end
end