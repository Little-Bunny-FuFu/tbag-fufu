-- $Id$

local _G = getfenv(0)

-- Coalesce high-frequency, event-driven window updates. A single user action
-- (Deposit All, a bag<->bank move) makes the server emit a *burst* of BAG_UPDATE
-- / bank-slot-changed events; running a full UpdateWindow (slot rescan + a
-- categorizing sort over up to ~1000 bank slots) per event is what caused the
-- heavy lag. Record the highest resort level requested in the burst and run ONE
-- real update a short moment later, collapsing the flood into a single rebuild.
-- Coalesce high-frequency, event-driven window updates. A single user action
-- (Deposit All, a bag<->bank move) makes the server emit a *burst* of BAG_UPDATE
-- / bank-slot-changed events, and a fast stream of right-click moves emits one
-- such burst per item; running a full UpdateWindow (slot rescan + categorizing
-- sort + relayout over up to ~1000 bank slots) for each is what caused the lag.
-- This is a SLIDING debounce with a hard cap: the real update fires once the
-- events stop for UPDATE_DEBOUNCE, but never later than UPDATE_MAX_WAIT after the
-- burst began -- so continuous rapid clicking refreshes a few times per second
-- instead of rebuilding the whole bank on every single click.
local UPDATE_DEBOUNCE = 0.10   -- fire this long after the LAST event in a burst
local UPDATE_MAX_WAIT = 0.30   -- but never defer a pending update longer than this

function TFuBag:RequestUpdate(frame, resort_req)
  -- UpdateWindow no-ops on a hidden frame anyway; skip scheduling so closed
  -- windows don't spawn a timer on every BAG_UPDATE during normal play.
  if not frame or not frame:IsVisible() then return end
  resort_req = resort_req or TFuBag.REQ_NONE
  if (frame.pending_resort_req == nil) or (resort_req > frame.pending_resort_req) then
    frame.pending_resort_req = resort_req
  end

  local now = GetTime()
  if (not frame.update_scheduled) then
    -- First event of a new burst: start the hard-deadline clock.
    frame.update_scheduled = true
    frame.update_deadline = now + UPDATE_MAX_WAIT
  end

  -- Re-arm a trailing timer one debounce period after THIS event, clamped so it
  -- never fires later than the burst's hard deadline. A monotonic token lets the
  -- latest re-arm supersede earlier in-flight timers (C_Timer has no cancel), so
  -- only one real UpdateWindow runs per coalesced burst.
  local fire_at = now + UPDATE_DEBOUNCE
  if (fire_at > frame.update_deadline) then fire_at = frame.update_deadline end
  frame.update_token = (frame.update_token or 0) + 1
  local mytoken = frame.update_token
  local delay = fire_at - now
  if (delay < 0) then delay = 0 end
  C_Timer.After(delay, function()
    if (frame.update_token ~= mytoken) then return end  -- superseded by a later event
    -- Clear guards BEFORE updating so a UpdateWindow error can't wedge the frame.
    frame.update_scheduled = nil
    frame.update_deadline = nil
    local req = frame.pending_resort_req or TFuBag.REQ_NONE
    frame.pending_resort_req = nil
    frame:UpdateWindow(req)
  end)
end

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
  -- TRADE_SKILL_LIST_UPDATE is the data-ready event: TRADE_SKILL_SHOW fires before
  -- the recipe list is populated, so scan on both (ScanRecipes self-gates on
  -- IsDataSourceChanging / IsTradeSkillReady).
  self:RegisterEvent("TRADE_SKILL_LIST_UPDATE")
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
  if C_EventUtils.IsEventValid("BANK_TAB_SETTINGS_UPDATED") then
    self:RegisterEvent("BANK_TAB_SETTINGS_UPDATED")
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
  if C_EventUtils.IsEventValid("GET_ITEM_INFO_RECEIVED") then
    self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
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

  TFuBag:RequestUpdate(frame)
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
    TFuBag:RequestUpdate(TFuInvFrame)
  else
    if TFuBag:Member(TFuInvFrame.bags, bag) then
      TFuBag:RequestUpdate(TFuInvFrame)
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
  TFuBnkFrame.physAtBank = 1
  -- 12.0: rebuild the dynamic tab list (char + warband) before showing/scanning.
  -- Called on the frame so self == TFuBnkFrame (Bank methods bind via metatable).
  TFuBnkFrame:RebuildTabList()
  -- Show() triggers OnShow -> UpdateWindow(REQ_PART), which re-sorts only when
  -- UpdateItmCache detects an actual change. Do NOT also force REQ_MUST here: that
  -- re-categorizes (PickBar + per-item tooltip scan) all ~1000 bank tab slots on
  -- every open even when nothing changed -> the per-open lag. First open still
  -- populates because an empty/stale cache reads as "changed".
  -- BUT Show() only fires OnShow on a hidden->shown transition. If the tbag bank window
  -- was ALREADY open (the user had the cached bank up and then clicked the banker), Show()
  -- is a no-op, so OnShow never runs and the item buttons that RebuildTabList's
  -- HideAllTabButtons just cleared are never re-shown -> every icon vanishes (only the
  -- stale header spacing remains) until a manual resort. Drive the update ourselves when
  -- already shown. REQ_PART keeps it cheap: the always-run per-button pass re-shows the
  -- buttons at their (unchanged) layout positions with no forced recat -- and RebuildTabList
  -- already flags CACHE_REQ=REQ_MUST if the tab set actually changed, which REQ_PART folds in.
  local wasShown = TFuBnkFrame:IsShown()
  TFuBnkFrame:Show()
  if (wasShown) then
    -- Synchronous (not RequestUpdate): RebuildTabList already hid the buttons this frame,
    -- so a deferred/debounced update would let the hidden state render first -> a visible
    -- flash. A direct UpdateWindow re-shows them in the same frame, matching OnShow's path.
    TFuBnkFrame:UpdateWindow(TFuBag.REQ_PART)
  end
  -- Repaint the inventory window so its bag items pick up the bank-deposit eligibility
  -- greying (bag contents didn't change -> a light REQ_NONE repaint, no re-sort).
  TFuBag:RequestUpdate(TFuInvFrame)
end

function TFuBag:BANKFRAME_CLOSED()
  TFuBnkFrame.physAtBank = 0
  TFuBnkFrame.atbank = 0
  TFuBnkFrame:Hide()
  -- Clear the deposit-eligibility greying now that no bank is open.
  TFuBag:RequestUpdate(TFuInvFrame)
end

-- 12.0 bank tab set changed (purchase / settings) -- rebuild and refresh if open.
function TFuBag:BANK_TABS_CHANGED()
  if not TFuBag.BANK_ENABLED then return end
  TFuBnkFrame:RebuildTabList()
  if (TFuBnkFrame.physAtBank == 1) then
    TFuBag:RequestUpdate(TFuBnkFrame, TFuBag.REQ_MUST)
  end
end

-- 12.0 a tab's name/icon/deposit-flag settings changed (our OpenTabSettings dialog
-- or Blizzard's own bank UI) -- rebuild the cached tab data and repaint if open.
function TFuBag:BANK_TAB_SETTINGS_UPDATED()
  if not TFuBag.BANK_ENABLED then return end
  TFuBnkFrame:RebuildTabList()
  if (TFuBnkFrame.physAtBank == 1) then
    TFuBag:RequestUpdate(TFuBnkFrame, TFuBag.REQ_MUST)
  end
end

-- 12.0 warband/account tab slots changed -- refresh if open.
function TFuBag:PLAYER_ACCOUNT_BANK_TAB_SLOTS_CHANGED()
  if not TFuBag.BANK_ENABLED then return end
  if (TFuBnkFrame.physAtBank == 1) then
    -- REQ_NONE (not REQ_MUST): warband item moves are frequent; UpdateItmCache
    -- detects the changed slots and drives the sort, recategorizing only those
    -- slots. Forcing REQ_MUST here would re-run the per-item tooltip scan over the
    -- whole warband bank on every move (the lag). Mirrors PLAYERBANKSLOTS_CHANGED.
    TFuBag:RequestUpdate(TFuBnkFrame)
  end
end

function TFuBag:PLAYERBANKSLOTS_CHANGED()
  TFuBag:RequestUpdate(TFuBnkFrame)
end

function TFuBag:PLAYERBANKBAGSLOTS_CHANGED()
  TFuBag:RequestUpdate(TFuBnkFrame, TFuBag.REQ_MUST)
end

function TFuBag:PLAYER_LEVEL_UP(event, level)
  TFuBagInfo[TFuBag.PLAYERID][TFuBag.G_BASIC][TFuBag.S_LEVEL] = level
end

function TFuBag:QUEST_ACCEPTED()
      TFuBag:RequestUpdate(TFuInvFrame)
end

function TFuBag:UNIT_QUEST_LOG_CHANGED(event, unit)
      if unit == "player" then
              TFuBag:RequestUpdate(TFuInvFrame)
      end
end

function TFuBag:PLAYER_ENTERING_WORLD(event)
  -- One time extra scan to avoid bogus data on swapping characters
  TFuBag.Tokens.Scan()
  self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

-- Item data can arrive AFTER a window is already open -- notably right after a /reload
-- at the bank, when the client item cache is cold. SortItmCache runs PickBar (which
-- needs GetItemInfo + a tooltip scan) on every item, so that first categorizing sort
-- buckets cold items as UNKNOWN -- the "bank opens not fully sorted, switch tabs to fix
-- it" symptom (switching tabs just re-sorts a moment later, once the data has streamed
-- in). As the server delivers item info, re-sort the open window(s) so categories
-- settle on their own. Debounced via a single pending flag + timer so a reload burst of
-- hundreds of these events collapses into one re-sort instead of one sort per item.
function TFuBag:GET_ITEM_INFO_RECEIVED(event, itemID, success)
  if (success == false) then return end
  local invVis = TFuInvFrame and TFuInvFrame:IsVisible()
  local bnkVis = TFuBnkFrame and TFuBnkFrame:IsVisible()
  if (not (invVis or bnkVis)) then return end
  if (self.iteminfo_resort_pending) then return end
  self.iteminfo_resort_pending = true
  C_Timer.After(0.3, function()
    TFuBag.iteminfo_resort_pending = nil
    if (TFuInvFrame and TFuInvFrame:IsVisible()) then
      TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST)
    end
    if (TFuBnkFrame and TFuBnkFrame:IsVisible()) then
      TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST)
    end
  end)
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
  ["TRADE_SKILL_LIST_UPDATE"] = TFuBag.Professions.ScanRecipes,
  ["UNIT_INVENTORY_CHANGED"] = TFuBag.ScanEquipped,
  ["MAIL_INBOX_UPDATE"] = TFuBag.ScanMail,
  ["PLAYER_LEAVING_WORLD"] = TFuBag.PLAYER_LEAVING_WORLD,
  ["BANKFRAME_OPENED"] = TFuBag.BANKFRAME_OPENED,
  ["BANKFRAME_CLOSED"] = TFuBag.BANKFRAME_CLOSED,
  ["BANK_TABS_CHANGED"] = TFuBag.BANK_TABS_CHANGED,
  ["BANK_TAB_SETTINGS_UPDATED"] = TFuBag.BANK_TAB_SETTINGS_UPDATED,
  ["PLAYER_ACCOUNT_BANK_TAB_SLOTS_CHANGED"] = TFuBag.PLAYER_ACCOUNT_BANK_TAB_SLOTS_CHANGED,
  ["PLAYERBANKSLOTS_CHANGED"] = TFuBag.PLAYERBANKSLOTS_CHANGED,
  ["PLAYERREAGENTBANKSLOTS_CHANGED"] = TFuBag.PLAYERBANKSLOTS_CHANGED,
  ["PLAYERBANKBAGSLOTS_CHANGED"] = TFuBag.PLAYERBANKBAGSLOTS_CHANGED,
  ["PLAYER_LEVEL_UP"] = TFuBag.PLAYER_LEVEL_UP,
  ["SKILL_LINES_CHANGED"] = TFuBag.SKILL_LINES_CHANGED,
  ["QUEST_ACCEPTED"] = TFuBag.QUEST_ACCEPTED,
  ["UNIT_QUEST_LOG_CHANGED"] = TFuBag.UNIT_QUEST_LOG_CHANGED,
  ["PLAYER_ENTERING_WORLD"] = TFuBag.PLAYER_ENTERING_WORLD,
  ["GET_ITEM_INFO_RECEIVED"] = TFuBag.GET_ITEM_INFO_RECEIVED,
}

function TFuBag:OnEvent(event, ...)
--  TFuBag:Print("OnEvent: "..event)
  if events[event] then
    events[event](TFuBag,event, ...)
  end
end

TFuBag:SetScript("OnEvent",TFuBag.OnEvent)
TFuBag:SetScript("OnUpdate",TFuBag.OnUpdate)
