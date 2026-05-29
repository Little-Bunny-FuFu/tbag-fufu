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
  -- 12.0 tab-as-container bank events (guard: only register if the client has them).
  if C_EventUtils.IsEventValid("BANK_TABS_CHANGED") then
    self:RegisterEvent("BANK_TABS_CHANGED")
  end
  if C_EventUtils.IsEventValid("PLAYER_ACCOUNT_BANK_TAB_SLOTS_CHANGED") then
    self:RegisterEvent("PLAYER_ACCOUNT_BANK_TAB_SLOTS_CHANGED")
  end
  -- 12.0: these bank events were removed; register only if still valid.
  if C_EventUtils.IsEventValid("PLAYERREAGENTBANKSLOTS_CHANGED") then
    self:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED")
  end
  if C_EventUtils.IsEventValid("PLAYERBANKBAGSLOTS_CHANGED") then
    self:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
  end
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
  -- if it isn't.  If no argument is passed we update the inventory regardless.
  --
  -- The BANK window is intentionally NOT updated here. In 12.0 the bank is a
  -- tab-as-container model with up to ~1000 slots (6 character + 5 warband tabs of
  -- 98), and a full UpdateWindow rescans every slot (GetItemInfo + tooltip build +
  -- resort + relayout). BAG_UPDATE_COOLDOWN fires ~1/sec (more during ability use),
  -- so doing that per tick caused heavy lag with the bank open. Bank cooldown swipes
  -- are set correctly on open / bag change; they just don't tick live while parked
  -- at the bank, which is fine (you don't use items off cooldown from the bank).
  if not bag then
    TFuInvFrame:UpdateWindow()
  else
    if TFuBag:Member(TFuInvFrame.bags, bag) then
      TFuInvFrame:UpdateWindow()
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
  if not TFuBag.BANK_ENABLED then return end  -- bank gated off; let Blizzard's bank show
  TFuBnkFrame.atbank = 1
  -- 12.0: rebuild the dynamic tab list (char + warband) before showing/scanning.
  -- Called on the frame so self == TFuBnkFrame (Bank methods bind via metatable).
  TFuBnkFrame:RebuildTabList()
  -- Show() triggers OnShow -> UpdateWindow(REQ_PART), which re-sorts only when
  -- UpdateItmCache detects an actual change. Do NOT also force REQ_MUST here: that
  -- re-categorizes (PickBar + per-item tooltip scan) all ~1000 bank tab slots on
  -- every open even when nothing changed -> the per-open lag. First open still
  -- populates because an empty/stale cache reads as "changed".
  TFuBnkFrame:Show()
end

function TFuBag:BANKFRAME_CLOSED()
  TFuBnkFrame.atbank = 0
  TFuBnkFrame:Hide()
end

-- 12.0 bank tab set changed (purchase / settings) -- rebuild and refresh if open.
function TFuBag:BANK_TABS_CHANGED()
  if not TFuBag.BANK_ENABLED then return end
  TFuBnkFrame:RebuildTabList()
  if (TFuBnkFrame.atbank == 1) then
    TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST)
  end
end

-- 12.0 warband/account tab slots changed -- refresh if open.
function TFuBag:PLAYER_ACCOUNT_BANK_TAB_SLOTS_CHANGED()
  if not TFuBag.BANK_ENABLED then return end
  if (TFuBnkFrame.atbank == 1) then
    TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST)
  end
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
  ["BANK_TABS_CHANGED"] = TFuBag.BANK_TABS_CHANGED,
  ["PLAYER_ACCOUNT_BANK_TAB_SLOTS_CHANGED"] = TFuBag.PLAYER_ACCOUNT_BANK_TAB_SLOTS_CHANGED,
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
