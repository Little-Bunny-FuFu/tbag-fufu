-- $Id$

-- Implementation of the base class for the main frames i.e. the Inventory
-- and Bank Windows.

TFuBag.MainFrame = {}
local MainFrame = TFuBag.MainFrame

function MainFrame:FrameX(width)
  return (width * (self.BF_PADWIDTH + self.cfg.frameXSpace)) + self.cfg.frameXSpace
end

function MainFrame:FrameY(height)
  return (height * (self.BF_PADHEIGHT + self.cfg.frameYSpace)) + self.cfg.frameYSpace
end

function MainFrame:SpaceX(space)
  return space * self.cfg.frameXSpace
end

function MainFrame:SpaceY(space)
  return space * self.cfg.frameYSpace
end

function MainFrame:PoolX(space)
  return space * self.cfg.frameXPool
end

function MainFrame:PoolY(space)
  return space * self.cfg.frameYPool
end

function MainFrame:IncreaseColumns()
  if self.cfg.maxColumns < TFuBag.NUMCOL_MAX then
    self.cfg.maxColumns = self.cfg.maxColumns + 1
    self:UpdateWindow(TFuBag.REQ_MUST)
  end
end

function MainFrame:DecreaseColumns()
  if self.cfg.maxColumns > TFuBag.NUMCOL_MIN then
    self.cfg.maxColumns = self.cfg.maxColumns - 1
    self:UpdateWindow(TFuBag.REQ_MUST)
  end
end

function MainFrame:DragStart()
  if not self.isMoving and self.cfg.moveLock == 1 then
    -- Raise the window and turn off top level while dragging.
    -- This prevents the game from freezing up from constantly
    -- recalculating frame level while dragging.
    self:Raise()
    self:SetToplevel(false)

    self:StartMoving()
    self.isMoving = true
  end
end

function MainFrame:DragStop()
  if self.isMoving then
    -- Done moving so set us back to top level and force a raise
    self:SetToplevel(true)
    self:Raise()

    self:StopMovingOrSizing()
    self:SetUserPlaced(false)
    self.isMoving = false

    -- save the position
    local scale = self:GetScale()
    self.cfg.frameLEFT   = self:GetLeft()   * scale
    self.cfg.frameRIGHT  = self:GetRight()  * scale
    self.cfg.frameTOP    = self:GetTop()    * scale
    self.cfg.frameBOTTOM = self:GetBottom() * scale

    TFuBag:PrintDEBUG("new position: top="..self.cfg.frameTOP..
                    ", bottom="..self.cfg.frameBOTTOM..
                    ", left="..self.cfg.frameLEFT..
                    ", right="..self.cfg.frameRIGHT)
  end
end

function MainFrame:OnMouseDown(button)
  if button == "LeftButton" then
    self:DragStart()
  elseif button == "RightButton" then
    HideDropDownMenu(1)
    self.RightClickMenu_mode = "mainwindow"
    self.RightClickMenu_opts = {}
    ToggleDropDownMenu(1, nil, self.RightClickMenu, "cursor", 0,0)
  end
end

function MainFrame:OnHide()
  PlaySound(PlaySoundKitID and "igBackPackClose" or SOUNDKIT.IG_BACKPACK_CLOSE)
  self:DragStop()

  -- Unhighlight any bags that are still highlighted.
  for _, bag in ipairs(self.bags) do
    local bagframe = TFuBag:GetBagFrame(bag)
    if bagframe and bagframe:GetChecked() then
      self.CACHE_REQ = TFuBag.REQ_MUST
      bagframe:SetChecked(false)
    end
  end
  TFuBag:UpdateButtonHighlights()

  if self.atbank and self.atbank == 1 then
    self.atbank = 0
    CloseBankFrame()
  end

  -- Hide the bank's Character/Warband view-tab buttons (UIParent-parented, so they
  -- don't auto-hide with the bank window).
  if self == TFuBnkFrame then
    if TFuBnkFrame.CharTabButton then TFuBnkFrame.CharTabButton:Hide() end
    if TFuBnkFrame.WarbandTabButton then TFuBnkFrame.WarbandTabButton:Hide() end
  end

  -- Always reset to the global player for event processing
  self:SetPlayer(TFuBag.PLAYERID)
end

function MainFrame:OnShow()
  PlaySound(PlaySoundKitID and "igBackPackOpen" or SOUNDKIT.IG_BACKPACK_OPEN)

  -- Always default to the current player
  self:SetPlayer(TFuBag.PLAYERID)
  self.edit_mode = 0

  if self == TFuBnkFrame then
    TFuInvFrame:Show()
  end

  self:UpdateWindow(TFuBag.REQ_PART)

  -- Bring ourselves to the top
  self:Raise()
end

function MainFrame:Toggle()
  local isVisible = self:IsVisible()
  if isVisible then
    self:Hide()
  else
    self:Show()
  end
  return isVisible
end

