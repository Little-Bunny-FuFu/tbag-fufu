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

-- DYNAMIC sizing (Stage 2): bottom-right resize grip. Built on Blizzard's reusable
-- PanelResizeButtonMixin (StartSizing/StopMovingOrSizing + a min/max OnSizeChanged
-- clamp it installs on the target). Shown only when legacy_sizing == 0 AND the layout
-- is auto-flow (Manual Layout sizes the window to its own bounding box). The grip is
-- created lazily the first time LayoutWindow runs for this frame.
TFuBag.RESIZE_MIN_W = 220;
TFuBag.RESIZE_MIN_H = 160;

function MainFrame:EnsureResizeGrip()
  if (self.ResizeGrip) then return; end
  self:SetResizable(true);
  local grip = CreateFrame("Button", self:GetName().."_ResizeGrip", self,
    "PanelResizeButtonTemplate");
  grip:ClearAllPoints();
  grip:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 2);
  grip:SetFrameLevel(self:GetFrameLevel() + 20);
  -- Init wires the StartSizing/StopMovingOrSizing scripts and installs the clamp.
  -- Bounds are (re)applied every layout by UpdateResizeGrip; pass nil maxes here so
  -- the clamp is inert until dynamic mode turns it on.
  grip:Init(self, TFuBag.RESIZE_MIN_W, TFuBag.RESIZE_MIN_H, nil, nil);
  grip:SetOnResizeStoppedCallback(function(target)
    if (target.OnResizeStopped) then target:OnResizeStopped(); end
  end);
  -- The window is normally anchored by a cfg corner (default BOTTOMLEFT) to UIParent,
  -- which would make StartSizing("BOTTOMRIGHT") grow UP-and-right. Re-anchor to a
  -- single TOPLEFT point (same offset convention as SetFrameAnchor: offset == the
  -- frame's own GetLeft()/GetTop()) so sizing keeps the top-left fixed and the grip
  -- follows the cursor naturally. OnResizeStopped re-saves all four edges afterwards.
  self.onResizeStartCallback = function()
    local left, top = self:GetLeft(), self:GetTop();
    self:ClearAllPoints();
    self:SetPoint("TOPLEFT", "UIParent", "BOTTOMLEFT", left, top);
    return true;
  end
  self.ResizeGrip = grip;
end

-- Is this frame currently in DYNAMIC auto-flow mode (resize grip applies)? Manual
-- Layout (drag-placed boxes, logged-in character only) sizes the window itself.
-- AUTO-FLOW dynamic reflow: true only when the auto-flow layout should reflow its
-- columns to the dragged window width. Manual Layout uses stored box coords, so it is
-- NOT auto-flow-dynamic (the seed pass is handled separately in LayoutWindow).
function MainFrame:IsDynamicResize()
  local cfg = self.cfg;
  if (not cfg or cfg.legacy_sizing ~= 0) then return false; end
  local in_ml = (cfg.manual_layout == 1 and cfg.legacy_edit ~= 1
                 and self.playerid == TFuBag.PLAYERID);
  return not in_ml;
end

-- Should the resize GRIP be shown? Dynamic sizing (legacy_sizing == 0) makes the window
-- resizable in EVERY mode: auto-flow (incl. alt views) reflows to the size; Manual Layout
-- (both Free and Grid) treats the window as a canvas the boxes are placed/scrolled within.
function MainFrame:IsResizable()
  local cfg = self.cfg;
  return (cfg ~= nil and cfg.legacy_sizing == 0);
end

function MainFrame:UpdateResizeGrip()
  local grip = self.ResizeGrip;
  if (not grip) then return; end
  if (self:IsResizable()) then
    -- Clamp live drags to the screen cap (frame-space) and a sane minimum. Applies to
    -- auto-flow AND Manual Layout (both treat the dragged size as the window/canvas).
    local cap_w, cap_h = TFuBag:GetWindowCap(self);
    grip.minWidth  = TFuBag.RESIZE_MIN_W;
    grip.minHeight = TFuBag.RESIZE_MIN_H;
    grip.maxWidth  = cap_w;
    grip.maxHeight = cap_h;
    grip:Show();
    grip:Enable();
  else
    -- Legacy sizing: neutralise the clamp so the content-driven layout sizes are
    -- never altered by the mixin's OnSizeChanged.
    grip.minWidth  = 1;
    grip.minHeight = 1;
    grip.maxWidth  = nil;
    grip.maxHeight = nil;
    grip:Hide();
  end
end

function MainFrame:OnResizeStopped()
  -- The mixin clamped the live drag to [min, cap], so the current size is the final
  -- dynamic size. Persist it; the relayout below re-runs UpdateScrollViewport which
  -- reads cfg.win_w/win_h and snaps the viewport + scrollbars to match.
  self.cfg.win_w = self:GetWidth();
  self.cfg.win_h = self:GetHeight();

  -- Re-save the window position from the post-resize geometry (mirror DragStop) so
  -- the saved anchor offsets match the new edges -- otherwise the next SetFrameAnchor
  -- would snap the window back to its pre-resize footprint.
  local scale = self:GetScale();
  self.cfg.frameLEFT   = self:GetLeft()   * scale;
  self.cfg.frameRIGHT  = self:GetRight()  * scale;
  self.cfg.frameTOP    = self:GetTop()    * scale;
  self.cfg.frameBOTTOM = self:GetBottom() * scale;

  -- Manual Layout that is still the AUTO-seeded arrangement (user hasn't dragged a box)
  -- reflows to the new window width: wipe the active store so LayoutWindow re-seeds at
  -- the dragged size. A hand-customized layout (cfg.ml_auto false) is left untouched --
  -- the resize only changes its canvas. (Auto-flow reflows on its own via ComputeDynColumns.)
  local cfg = self.cfg;
  local in_ml = (cfg.manual_layout == 1 and cfg.legacy_edit ~= 1 and self.playerid == TFuBag.PLAYERID);
  if (in_ml and cfg.ml_auto) then
    local store = (cfg.ml_freeplace == 1) and cfg.cat_layout_free or cfg.cat_layout;
    if (store) then for k in pairs(store) do store[k] = nil; end end
  end

  TFuBag:LayoutWindow(self);
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
    -- A cursor-carried item (stack split, right-click pickup, or a drag-release that
    -- landed on the window body rather than a slot) is placed with a plain left-click.
    -- Treat the window body as a drop target in BOTH collapse modes: deposit into a
    -- free slot instead of starting a window move. (DepositToFreeSlot no-ops when the
    -- cursor is empty, so a normal body click still starts a drag-move.)
    if self.cfg and CursorHasItem() then
      TFuBag:DepositToFreeSlot(self)
      return
    end
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

  if self.physAtBank and self.physAtBank == 1 then
    self.physAtBank = 0
    CloseBankFrame()
  end
  self.atbank = 0

  -- Hide the bank's Character/Warband view-tab buttons (UIParent-parented, so they
  -- don't auto-hide with the bank window).
  if self == TFuBnkFrame then
    if TFuBnkFrame.CharTabButton then TFuBnkFrame.CharTabButton:Hide() end
    if TFuBnkFrame.WarbandTabButton then TFuBnkFrame.WarbandTabButton:Hide() end
    -- The tab settings dialog is parented to UIParent (its own window), so it does
    -- not auto-hide with the bank -- close it explicitly.
    if TFuBnk_TabSettingsDialog then TFuBnk_TabSettingsDialog:Hide() end
  end

  -- Always reset to the global player for event processing
  self:SetPlayer(TFuBag.PLAYERID)
end

function MainFrame:OnShow()
  PlaySound(PlaySoundKitID and "igBackPackOpen" or SOUNDKIT.IG_BACKPACK_OPEN)

  -- Always default to the current player
  self:SetPlayer(TFuBag.PLAYERID)
  self.edit_mode = 0
  self.ml_edit = 0   -- reopen LOCKED: show the arranged layout, not in drag-edit

  if self == TFuBnkFrame then
    TFuInvFrame:Show()
    -- Rebuild the bank view for the current player/type on every show path (/tbnk, the
    -- inventory "show bank" toggle, a dropdown switch), not only on BANKFRAME_OPENED, so
    -- the tab strip + tab containers render from cache when away from the bank.
    TFuBnkFrame:RebuildTabList()
  end

  -- Force a full re-sort on show when categorization changed since this window
  -- last sorted (catGen bumps on any rule/grouping/category change) or it was
  -- explicitly flagged. Item categories are persisted in the cache, so without
  -- this a reopened window keeps stale categories until a manual resort.
  local req = TFuBag.REQ_PART
  if (self.needsResort or self.sortGen ~= TFuBag.catGen) then
    req = TFuBag.REQ_MUST; self.needsResort = nil;
  end
  self:UpdateWindow(req)

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

