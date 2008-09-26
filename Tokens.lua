-- $Id$
local _G = _G
local TBag = _G.TBag
TBag.Tokens = {}
local Tokens = TBag.Tokens

-- I really hate having to hook to do this but it would be a real mess
-- to do it otherwise since the TokenUI doesn't generate an event when
-- the tracked tokens change.
function Tokens.Hook()
  Tokens.Update(TInvFrame_TokenFrame)
  Tokens.Update(TBnkFrame_TokenFrame)
end
if TBag.WoTLK then
  hooksecurefunc("BackpackTokenFrame_Update",Tokens.Hook)
end

function Tokens.Update(frame)
  if not TBag.WoTLK then return end
  local framename = frame:GetName()
  for i=1, MAX_WATCHED_TOKENS do
    local watchButton
    local name, count, extraCurrencyType, icon = GetBackpackCurrencyInfo(i)
    -- Update watched tokens
    if name then
      watchButton = getglobal(framename.."Token"..i)
      watchButton.extraCurrencyType = extraCurrencyType
      if extraCurrencyType == 1 then --Arena points
        watchButton.icon:SetTexture("Interface\\PVPFrame\\PVP-ArenaPoints-Icon")
        watchButton.icon:SetTexCoord(0, 1, 0, 1)
      elseif extraCurrencyType == 2 then -- Honor Points
        local factionGroup = UnitFactionGroup("player")
        if factionGroup then
          watchButton.icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup)
          watchButton.icon:SetTexCoord( 0.03125, 0.59375, 0.03125, 0.59375)
        else
          watchButton.icon:SetTexCoord(0, 1, 0, 1)
        end
      else
        watchButton.icon:SetTexture(icon)
        watchButton.icon:SetTexCoord(0, 1, 0, 1)
      end
      if count <= 99999 then
        watchButton.count:SetText(count)
      else
        watchButton.count:SetText("*")
      end
      watchButton:Show()
      frame.shouldShow = 1
      frame.numWatchedTokens = i
    else
      getglobal(framename.."Token"..i):Hide()
      if i == 1 then
        frame.shouldShow = nil
      end
    end
  end
end
