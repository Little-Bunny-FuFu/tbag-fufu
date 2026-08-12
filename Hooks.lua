-- $Id$

local _G = getfenv(0)
local TFuBag = _G.TFuBag
TFuBag.Hooks = {}
local Hooks = TFuBag.Hooks


Hooks.UNREGISTER = 0
Hooks.REGISTER = 1
Hooks.CHECK = 2

Hooks.funcs = {
  "OpenBag",
  "CloseBag",
  "ToggleBag",
  "OpenBackpack",
  "CloseBackpack",
  "ToggleBackpack",
  "ToggleAllBags",
  -- ContainerFrameItemButton_OnModifiedClick was dropped from this list: the
  -- global was removed in the 10.x mixin rework (modified clicks route through
  -- ContainerFrameItemButtonMixin:OnModifiedClick), so the replacement was
  -- never called on 12.0 -- and installing a fake global whose fall-through
  -- calls a nil saved original was a latent trap for any third-party caller.
}

Hooks.scripts = {
  ["MerchantFrame"] = "OnHide"
}

Hooks.savedfuncs = {}

local inMerchantFrameOnHide = false

function Hooks.Register(reg)
  local funcs = Hooks.funcs
  local scripts = Hooks.scripts
  local savedfuncs = Hooks.savedfuncs

  if (reg == Hooks.REGISTER) then
    for _,funcname in ipairs(funcs) do
      local ourfunc = Hooks[funcname]

      if ourfunc then
        savedfuncs[funcname] = _G[funcname]
        _G[funcname] = ourfunc
        TFuBag:PrintDEBUG("Hook function for '"..funcname.." installed.")
      else
        TFuBag:PrintDEBUG("** Hook function for '"..funcname.." SKIPPED **")
      end
    end
    for framename,script in pairs(scripts) do
      local funcname = framename..'_'..script
      local ourfunc = Hooks[funcname]

      if ourfunc then
        local frame = _G[framename]
        savedfuncs[funcname] = frame:GetScript(script)
        frame:SetScript(script, ourfunc)
        TFuBag:PrintDEBUG("Hook script for '"..funcname.." installed.")
      else
        TFuBag:PrintDEBUG("** Hook script for '"..funcname.." SKIPPED **")
      end
    end
  elseif (reg == Hooks.UNREGISTER) then
    -- unregister hooks
    for _,funcname in ipairs(funcs) do
      local ourfunc = Hooks[funcname]

      if ourfunc and savedfuncs[funcname] then
        _G[funcname] = savedfuncs[funcname]
        savedfuncs[funcname] = nil
        TFuBag:PrintDEBUG("Hook function for '"..funcname.." removed.")
      end
    end
    for framename,script in pairs(scripts) do
      local funcname = framename..'_'..script
      local ourfunc = Hooks[funcname]

      if ourfunc and savedfuncs[funcname] then
        local frame = _G[framename]
        frame:SetScript(script, savedfuncs[funcname])
        savedfuncs[funcname] = nil
        TFuBag:PrintDEBUG("Hook script for '"..funcname.." removed.")
      end
    end
  elseif (reg == Hooks.CHECK) then
    -- check if hooks are registered
    TFuBag:Print( "Hooks:" ,1,1,0.2 )
    for _,funcname in ipairs(funcs) do
      local ourfunc = Hooks[funcname]
      local curfunc = _G[funcname]

      if ourfunc == curfunc then
        TFuBag:Print("  "..funcname.." is hooked properly.", 0, 1, 0.25)
      else
        TFuBag:Print("  "..funcname.." is NOT hooked.", 1, 0.2, 0.2)
      end
    end
    for framename,script in pairs(scripts) do
      local funcname = framename..'_'..script
      local ourfunc = Hooks[funcname]
      local frame = _G[framename]
      local curfunc = frame:GetScript(script)

      if ourfunc == curfunc then
        TFuBag:Print("  "..funcname.." is hooked properly.", 0, 1, 0.25)
      else
        TFuBag:Print("  "..funcname.." is NOT hooked.", 1, 0.2, 0.2)
      end
    end
  end
end

local function CloseAllWindows()
  TFuBag:PrintDEBUG("event: CloseAllWindows()")

  TFuInvFrame:Hide()
  TFuBnkFrame:Hide()
end
hooksecurefunc('CloseAllWindows', CloseAllWindows)

function Hooks.OpenBag(bag)
  TFuBag:PrintDEBUG("event: OpenBag("..bag..")")
  local mainFrame
  if TFuBag:Member(TFuInvFrame.bags,bag) then
    mainFrame = TFuInvFrame
  else
    mainFrame = TFuBnkFrame
  end

  if mainFrame.cfg["show_Bag"..bag] ~= 1 then
    local bagframe = TFuBag:GetBagFrame(bag)
    if bagframe then bagframe:SetChecked(true) end
  end
  mainFrame:Show()
  TFuBag:UpdateButtonHighlights()
end

function Hooks.CloseBag(bag)
  TFuBag:PrintDEBUG("event: CloseBag("..bag..")")
  -- Do NOT hide the combined window on a single-bag close. In the 12.0 UI the
  -- only path that reaches CloseBag(<oneBag>) for our addon is Blizzard's
  -- BAG_CLOSED -> ContainerFrameSettingsManager:OnBagClosed swap-transient
  -- (ContainerFrame.lua): when a bag is swapped/removed the engine fires
  -- BAG_CLOSED, Blizzard closes that bag's frame and only re-opens it if
  -- IsBagOpen() is true -- which is always false once we suppress Blizzard's
  -- container frames, so our window would stay hidden after every bag swap.
  -- Genuine close-all routes through CloseBackpack/CloseAllWindows (hooked
  -- separately); their per-bag CloseBag(i) loops are themselves gated behind
  -- IsBagOpen(i) and so never reach here. The combined window has no notion of
  -- closing one bag's section, so there is nothing to hide -- BAG_UPDATE drives
  -- the contents refresh for the swapped bag.
end

function Hooks.ToggleBag(bag)
  TFuBag:PrintDEBUG("event: ToggleBag("..bag..")")
  local mainFrame
  if TFuBag:Member(TFuInvFrame.bags,bag) then
    mainFrame = TFuInvFrame
  else
    mainFrame = TFuBnkFrame
  end
  local isBagShown = mainFrame.cfg["show_Bag"..bag] == 1
  local isVisible = mainFrame:IsVisible()

  -- If the frame is already visible and the bag is set to
  -- always be shown just hide the frame.
  if isVisible and isBagShown then
    mainFrame:Hide()
    return
  end

  -- Toggle the checked state of the bag frame if the
  -- bag isn't  permanetly set to be shown, this will
  -- toggle the shown state of the Bag.
  if not isBagShown then
    local bagFrame = TFuBag:GetBagFrame(bag)
    if bagFrame then bagFrame:SetChecked(not bagFrame:GetChecked()) end
  end

  -- If the frame was already visible when we started
  -- force an update, otherwise show it which will
  -- force an update for us.
  if isVisible then
    TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST)
  else
    TFuInvFrame:Show()
  end
  TFuBag:UpdateButtonHighlights()
end

function Hooks.OpenBackpack()
  TFuBag:PrintDEBUG("event: OpenBackpack()")
  Hooks.OpenBag(BACKPACK_CONTAINER)
end

function Hooks.CloseBackpack()
  TFuBag:PrintDEBUG("event: CloseBackpack()")
  if not inMerchantFrameOnHide then
    TFuInvFrame:Hide()
  end
end

function Hooks.ToggleBackpack()
  TFuBag:PrintDEBUG("event: ToggleBackpack()")
  Hooks.ToggleBag(BACKPACK_CONTAINER)
end

function Hooks.ToggleAllBags()
  TFuBag:PrintDEBUG("event: OpenAllBags()")
  local inv_bag_toggled  = false
  local inv_shown = false
  local bnk_bag_toggled = false

  for _,bag in ipairs(TFuInvFrame.bags) do
    if TFuInvFrame.cfg["show_Bag"..bag] ~= 1 then
      local bagframe = TFuBag:GetBagFrame(bag)
      if bagframe and not bagframe:GetChecked() then
        bagframe:SetChecked(true)
        TFuInvFrame.CACHE_REQ = TFuBag.REQ_MUST
        inv_bag_toggled = true
      end
    end
  end

  if inv_bag_toggled then
    inv_shown = true
    TFuInvFrame:Show()
    if TFuInvFrame.CACHE_REQ > TFuBag.REQ_NONE then
      TFuInvFrame:UpdateWindow(TFuBag.REQ_PART)
    end
  else
    inv_shown = not TFuInvFrame:Toggle()
  end

  -- Toggle the normally hidden bank bags based on
  -- if the inventory is hidden or shown
  if TFuBnkFrame:IsVisible() then
    for _, bag in ipairs(TFuBnkFrame.bags) do
      if TFuBnkFrame.cfg["show_Bag"..bag] ~= 1 then
        local bagframe = TFuBag:GetBagFrame(bag)
        if bagframe and bagframe:GetChecked() ~= inv_shown then
          bagframe:SetChecked(inv_shown)
          TFuBnkFrame.CACHE_REQ = TFuBag.REQ_MUST
          bnk_bag_toggled = true
        end
      end
    end
  end

  if bnk_bag_toggled then
    TFuBnkFrame:UpdateWindow(TFuBag.REQ_PART)
  end

  TFuBag:UpdateButtonHighlights()
end

function Hooks.MerchantFrame_OnHide(...)
  inMerchantFrameOnHide = true
  Hooks.savedfuncs.MerchantFrame_OnHide(...)
  inMerchantFrameOnHide = false
end

function Hooks.MerchantFrame_OnShow(...)
  if (TFuInvFrame and TFuInvFrame.UpdateWindow) then TFuInvFrame:UpdateWindow() end
  -- The bank is gated off pending its 12.0 rewrite, so Bank:init (which gives
  -- TFuBnkFrame its UpdateWindow via metatable) may not have run; guard the call
  -- so opening a merchant doesn't error.
  if (TFuBnkFrame and TFuBnkFrame.UpdateWindow) then TFuBnkFrame:UpdateWindow() end
end
MerchantFrame:HookScript("OnShow", Hooks.MerchantFrame_OnShow)
