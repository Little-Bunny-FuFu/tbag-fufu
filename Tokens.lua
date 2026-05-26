-- $Id$
local _G = getfenv(0)
local TFuBag = _G.TFuBag
local L = TFuBag.LOCALE
TFuBag.Tokens = {}
local Tokens = TFuBag.Tokens

function Tokens.GetItemStringFromCurrencyIndex(index)
  local tt = TFuBag_tt

  if (not tt) then
    -- 12.0: inherit GameTooltipTemplate so the Set* methods exist (see TBag.lua).
    tt = CreateFrame("GameTooltip","TFuBag_tt", nil, "GameTooltipTemplate")
  end
  tt:SetOwner(UIParent, "ANCHOR_NONE")  -- this makes sure that tooltip.valid = true
  tt:ClearLines()

  tt:SetCurrencyToken(index)
  local _,itemlink = tt:GetItem()
  local _,itemstring = TFuBag:GetItemID(itemlink)
  return itemstring
end

function Tokens.SetItmFromCurrencyIndex(index,itm)
  local name, isHeader, isExpand, isUnused, isWatched, count, icon = GetCurrencyListInfo(index)

  if not name then
    return false
  end

  itm[TFuBag.I_NAME] = name
  itm[TFuBag.I_HEADER] = isHeader
  itm[TFuBag.I_EXPAND] = isExpand
  itm[TFuBag.I_UNUSED] = isUnused
  itm[TFuBag.I_WATCH] = isWatched
  itm[TFuBag.I_COUNT] = count
  itm[TFuBag.I_ICON] = icon
  return true
end

local scanning = false
function Tokens.Scan()
  if scanning then return end
  scanning = true

  local n = 0
  if not TFuTknItm[TFuBag.PLAYERID] then
    TFuTknItm[TFuBag.PLAYERID] = {}
  end
  if not TFuTknItm[TFuBag.PLAYERID][TFuBag.D_BAG] then
    TFuTknItm[TFuBag.PLAYERID][TFuBag.D_BAG] = {}
  end
  local dbag = TFuTknItm[TFuBag.PLAYERID][TFuBag.D_BAG]
  table.wipe(dbag)

  for i = 1, GetCurrencyListSize() do
    n = n + 1
    dbag[n] = {}
    if not Tokens.SetItmFromCurrencyIndex(i,dbag[n]) then
      scanning = false
      return
    end
    if dbag[n][TFuBag.I_HEADER] and not dbag[n][TFuBag.I_EXPAND] then
      local size = GetCurrencyListSize()
      ExpandCurrencyList(i,1)
      size = GetCurrencyListSize() - size
      for j = i+1, i+size do
        n = n + 1
        dbag[n] = {}
        if not Tokens.SetItmFromCurrencyIndex(j,dbag[n]) then
          scanning = false
          return
        end
      end
      ExpandCurrencyList(i,0)
    end
  end
  scanning = false
end

function Tokens.UpdateTokenButtonFromItm(button, itm, playerid)
  -- Update watched tokens
  if itm[TFuBag.I_NAME] then
    button.extraCurrencyType = itm[TFuBag.I_TYPE]
    button.itemstring = itm[TFuBag.I_ITEMLINK]
    button.count_val = itm[TFuBag.I_COUNT]
    button.name = itm[TFuBag.I_NAME]
    if itm[TFuBag.I_TYPE]  == 1 then --Arena points
      button.icon:SetTexture("Interface\\PVPFrame\\PVP-ArenaPoints-Icon")
      button.icon:SetTexCoord(0, 1, 0, 1)
    elseif itm[TFuBag.I_TYPE]  == 2 then -- Honor Points
      local factionGroup = TFuBagInfo[playerid][TFuBag.G_BASIC][TFuBag.S_FACTION] or 'FFA'
      if factionGroup then
        button.icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup)
        button.icon:SetTexCoord( 0.03125, 0.59375, 0.03125, 0.59375)
      else
        button.icon:SetTexCoord(0, 1, 0, 1)
      end
    else
      local itemlink = itm[TFuBag.I_ITEMLINK]
      local icon = itemlink and GetItemIcon(itemlink) or itm[TFuBag.I_ICON]
      button.icon:SetTexture(icon)
      button.icon:SetTexCoord(0, 1, 0, 1)
    end
    if itm[TFuBag.I_COUNT] <= 99999 then
      button.count:SetText(itm[TFuBag.I_COUNT])
    else
      button.count:SetText("*")
    end
    button:Show()
  end
end

function Tokens.Update(frame)
  local framename = frame:GetName()
  local mainFrame = frame:GetParent()
  if mainFrame.cfg.show_tokens ~= 1 then return end
  if not (TFuTknItm and TFuTknItm[mainFrame.playerid] and
          TFuTknItm[mainFrame.playerid][TFuBag.D_BAG]) then
    frame:Hide()
    return
  end
  local i = 1
  for _,itm in pairs(TFuTknItm[mainFrame.playerid][TFuBag.D_BAG]) do
    if itm[TFuBag.I_WATCH] then
      local watchButton = _G[framename.."Token"..i]
      Tokens.UpdateTokenButtonFromItm(watchButton,itm, mainFrame.playerid)
      frame:Show()
      i = i + 1
    end
    if i > MAX_WATCHED_TOKENS then return end
  end
  for n = i, MAX_WATCHED_TOKENS do
    _G[framename.."Token"..n]:Hide()
    if n == 1 then
      frame:Hide()
    end
  end
end

function Tokens.Button_OnEnter(self)
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  GameTooltip:SetText(self.name, 1, 1, 1, 1)
end

-- I really hate having to hook to do this but it would be a real mess
-- to do it otherwise since the TokenUI doesn't generate an event when
-- the tracked tokens change.
function Tokens.Hook()
  Tokens.Scan()
  Tokens.Update(TFuInvFrame_TokenFrame)
  Tokens.Update(TFuBnkFrame_TokenFrame)
end

-- Turn on the hook, we have to delay doing this until variables
-- are loaded to avoid problems.
function Tokens.Enable()
  -- BackpackTokenFrame_Update is removed in 12.0 (currency UI reworked); only
  -- hook it if it still exists so Enable() doesn't error.
  if type(BackpackTokenFrame_Update) == "function" then
    hooksecurefunc("BackpackTokenFrame_Update",Tokens.Hook)
  end
end

-- TokenFramePopupBackpackCheckBoxText is gone in 12.0 (currency UI reworked);
-- guard so this load-scope line doesn't error. Token integration TBD in revival.
if TokenFramePopupBackpackCheckBoxText then
  TokenFramePopupBackpackCheckBoxText:SetText(L["Show on TBag"])
end
TOKEN_SHOW_ON_BACKPACK = L["Checking this option will allow you to track this currency type in TBag for this character.\n\nYou can also Shift-click a currency to add or remove it from being tracked in TBag."]
