-- $Id$

local _G = getfenv(0)

function TFuBag:VARIABLES_LOADED()
  self.Inv:init(0)
  self.Bank:init(0)
  self:RegisterEvent("BAG_UPDATE")
  self:RegisterEvent("BAG_UPDATE_COOLDOWN")
  self:RegisterEvent("ITEM_LOCK_CHANGED")
  self:RegisterEvent("UNIT_INVENTORY_CHANGED")
  self:RegisterEvent("PLAYER_LEAVING_WORLD")
  self:RegisterEvent("MAIL_INBOX_UPDATE")
  self:RegisterEvent("TRADE_SKILL_SHOW")
  self:RegisterEvent("AUCTION_HOUSE_SHOW")
  self:RegisterEvent("MAIL_SHOW")
  self:RegisterEvent("MERCHANT_SHOW")
  self:RegisterEvent("BANKFRAME_OPENED")
  self:RegisterEvent("BANKFRAME_CLOSED")
  self:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
  self:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED")
  self:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
  self:RegisterEvent("PLAYER_LEVEL_UP")
  self:RegisterEvent("SKILL_LINES_CHANGED")
  self:RegisterEvent("QUEST_ACCEPTED")
  self:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
  self:RegisterEvent("PLAYER_ENTERING_WORLD")

  -- Scan equipment on login.
  TFuBag:ScanEquipped()
  TFuBagInfo[TFuBag.PLAYERID][TFuBag.G_BASIC][TFuBag.S_LEVEL] = UnitLevel("player")
  TFuBagInfo[TFuBag.PLAYERID][TFuBag.G_BASIC][TFuBag.S_FACTION] = UnitFactionGroup("player")
end

function TFuBag:SKILL_LINES_CHANGED()
  TFuBag.Professions:ScanAllTradeRanks()
end

function TFuBag:BAG_UPDATE(event, bag)
  local frame, stack
  if bag then
    if TFuBag:Member(TFuInvFrame.bags, bag) then
      frame = TFuInvFrame
      stack = self.STACK_INV
    elseif TFuBag:Member(TFuBnkFrame.bags, bag) then
      frame = TFuBnkFrame
      stack = self.STACK_BNK
    end
  end

  if not frame then return end

  if not self:IsStacking(stack) and frame.cfg.stack_auto == 1 and self:IsLive(frame) then
    frame.cfg.stack_once = 1
  end

  frame:UpdateWindow()
end

function TFuBag:BAG_UPDATE_COOLDOWN(event, bag)
  -- If we're given an argument check if it's a inventory bag and ignore the event
  -- if it isn't.  If not argument is passed we have to update the window
  -- regardless.  /sigh
  if not bag then
    TFuInvFrame:UpdateWindow()
    TFuBnkFrame:UpdateWindow()
  else
    if TFuBag:Member(TFuInvFrame.bags, bag) then
      TFuInvFrame:UpdateWindow()
    elseif TFuBag:Member(TFuBnkFrame.bags, bag) then
      TFuBnkFrame:UpdateWindow()
    end
  end
end

function TFuBag:ITEM_LOCK_CHANGED(event, bag, slot)
  if bag and slot and type(slot) == "number" then
    TFuBag.ItemButton.UpdateLock(_G[TFuBag:GetBagItemButtonName(bag,slot)])
  end
end

function TFuBag:UIFRAME_SHOW()
  TFuInvFrame:Show()
end

function TFuBag:PLAYER_LEAVING_WORLD()
  TFuBagInfo[TFuBag.PLAYERID][TFuBag.G_BASIC][TFuBag.S_HEARTH] = GetBindLocation()
  TFuBagInfo[TFuBag.PLAYERID][TFuBag.G_BASIC][TFuBag.S_LEVEL] = UnitLevel("player")
end

function TFuBag:BANKFRAME_OPENED()
  TFuBnkFrame.atbank = 1
  TFuBnkFrame:Show()
end

function TFuBag:BANKFRAME_CLOSED()
  TFuBnkFrame.atbank = 0
  TFuBnkFrame:Hide()
end

function TFuBag:PLAYERBANKSLOTS_CHANGED()
  TFuBnkFrame:UpdateWindow()
end

function TFuBag:PLAYERBANKBAGSLOTS_CHANGED()
  TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST)
end

function TFuBag:PLAYER_LEVEL_UP(event, level)
  TFuBagInfo[TFuBag.PLAYERID][TFuBag.G_BASIC][TFuBag.S_LEVEL] = level
end

function TFuBag:QUEST_ACCEPTED()
      TFuInvFrame:UpdateWindow()
end

function TFuBag:UNIT_QUEST_LOG_CHANGED(event, unit)
      if unit == "player" then
              TFuInvFrame:UpdateWindow()
      end
end

function TFuBag:PLAYER_ENTERING_WORLD(event)
  -- One time extra scan to avoid bogus data on swapping characters
  TFuBag.Tokens.Scan()
  self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end


local events = {
  ["VARIABLES_LOADED"] = TFuBag.VARIABLES_LOADED,
  ["BAG_UPDATE"] = TFuBag.BAG_UPDATE,
  ["BAG_UPDATE_COOLDOWN"] = TFuBag.BAG_UPDATE_COOLDOWN,
  ["ITEM_LOCK_CHANGED"] = TFuBag.ITEM_LOCK_CHANGED,
  ["AUCTION_HOUSE_SHOW"] = TFuBag.UIFRAME_SHOW,
  ["MAIL_SHOW"] = TFuBag.UIFRAME_SHOW,
  ["MERCHANT_SHOW"] = TFuBag.UIFRAME_SHOW,
  ["TRADE_SKILL_SHOW"] = TFuBag.Professions.ScanRecipes,
  ["UNIT_INVENTORY_CHANGED"] = TFuBag.ScanEquipped,
  ["MAIL_INBOX_UPDATE"] = TFuBag.ScanMail,
  ["PLAYER_LEAVING_WORLD"] = TFuBag.PLAYER_LEAVING_WORLD,
  ["BANKFRAME_OPENED"] = TFuBag.BANKFRAME_OPENED,
  ["BANKFRAME_CLOSED"] = TFuBag.BANKFRAME_CLOSED,
  ["PLAYERBANKSLOTS_CHANGED"] = TFuBag.PLAYERBANKSLOTS_CHANGED,
  ["PLAYERREAGENTBANKSLOTS_CHANGED"] = TFuBag.PLAYERBANKSLOTS_CHANGED,
  ["PLAYERBANKBAGSLOTS_CHANGED"] = TFuBag.PLAYERBANKBAGSLOTS_CHANGED,
  ["PLAYER_LEVEL_UP"] = TFuBag.PLAYER_LEVEL_UP,
  ["SKILL_LINES_CHANGED"] = TFuBag.SKILL_LINES_CHANGED,
  ["QUEST_ACCEPTED"] = TFuBag.QUEST_ACCEPTED,
  ["UNIT_QUEST_LOG_CHANGED"] = TFuBag.UNIT_QUEST_LOG_CHANGED,
  ["PLAYER_ENTERING_WORLD"] = TFuBag.PLAYER_ENTERING_WORLD,
}

function TFuBag:OnEvent(event, ...)
--  TFuBag:Print("OnEvent: "..event)
  if events[event] then
    events[event](TFuBag,event, ...)
  end
end

TFuBag:SetScript("OnEvent",TFuBag.OnEvent)
TFuBag:SetScript("OnUpdate",TFuBag.OnUpdate)
