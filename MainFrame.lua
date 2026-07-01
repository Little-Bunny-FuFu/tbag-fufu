-- $Id$

-- Implementation of the base class for the main frames i.e. the Inventory
-- and Bank Windows.

TFuBag.MainFrame = {}
local MainFrame = TFuBag.MainFrame
local L = TFuBag.LOCALE   -- localization (hoisted button handlers use L)

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
-- After self.cfg is bound to an ALT cfg copy (Inv/Bank:SetPlayer), finish it: fill any
-- defaults that copy predates (InitDefVals at reset=0 only adds MISSING keys, so a
-- complete profile is untouched), then apply the view-mode geometry policy (layout-only
-- keeps the live window where it is; full-profile adopts the alt geometry). Self-views
-- never call this -- their cfg is the live table, edited in place as before.
function MainFrame:CompleteAltCfg(which)
  self:InitDefVals(0);
  TFuBag:ApplyAltGeometry(self.cfg, TFuBag:ActiveCfg(which),
    (TFuBagCfg and TFuBagCfg.altview_apply_geometry or 0) == 1);
end

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
    -- End the live server bank session when the user closes the bank window at a
    -- banker, matching the default UI. The bare CloseBankFrame global was removed in
    -- 12.0; the real call is C_Bank.CloseBankFrame (unrestricted, AllowedWhenUntainted
    -- -- a function call, not a secure-table write, so no taint). Reopening the tbag
    -- bank window without re-clicking the banker then shows the cached (read-only)
    -- view, exactly as the default UI requires a re-open after the session ends.
    if C_Bank and C_Bank.CloseBankFrame then
      C_Bank.CloseBankFrame()
    end
  end
  -- atbank is a BANK-session flag; only the bank window owns it. This OnHide is
  -- shared (TFuBag_MainTemplate), so an unconditional reset also wrote atbank=0
  -- onto the INVENTORY frame -- which never sets it back. IsLive() treats 0 as
  -- "not live" (0 is truthy and 0 ~= 1), so once the inventory had been hidden
  -- once, IsLive(TFuInvFrame) stayed false and UpdateLock bailed before applying
  -- the deposit-eligibility shading (and cooldowns) until /reload. Scope it to the
  -- bank so the inventory frame keeps atbank == nil (= always live for own char).
  if self == TFuBnkFrame then
    self.atbank = 0
  end

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

-- ===== Shared window chrome (Tier 1 hoist from Inv/Bank) =====================
-- These were byte-identical (modulo the TFuInv/TFuBnk token) in TInv.lua and
-- TBnk.lua. self is the window frame; self.PREFIX ("TFuInv"/"TFuBnk") builds the
-- short-prefixed button globals, and self.PREFIX.."Frame" the frame-prefixed ones.

function MainFrame:SetButton_Anchors()
  self:SetTopLeftButton_Anchors();
  self:SetTopRightButton_Anchors();
  self:SetBottomLeftButton_Anchors();
  self:SetBottomRightButton_Anchors();
  TFuBag:LayoutWindow(self)
end

function MainFrame:Toggle_CloseButton()
  local cfg = self.cfg;
  if (cfg["show_closebutton"] == 1) then
    cfg["show_closebutton"] = 0;
    _G[self.PREFIX.."_Button_Close"]:Hide();
  else
    cfg["show_closebutton"] = 1;
    _G[self.PREFIX.."_Button_Close"]:Show();
  end
  self:SetButton_Anchors();
end

function MainFrame:Toggle_EditButton()
  local cfg = self.cfg;
  if (cfg["show_editbutton"] == 1) then
    cfg["show_editbutton"] = 0;
    _G[self.PREFIX.."_Button_ChangeEditMode"]:Hide();
  else
    cfg["show_editbutton"] = 1;
    _G[self.PREFIX.."_Button_ChangeEditMode"]:Show();
  end
  self:SetButton_Anchors();
end

function MainFrame:Toggle_Filter()
  local cfg = self.cfg;
  if (cfg["show_filterbutton"] == 1) then
    cfg["show_filterbutton"] = 0;
    _G[self.PREFIX.."_Button_Filter"]:Hide();
  else
    cfg["show_filterbutton"] = 1;
    _G[self.PREFIX.."_Button_Filter"]:Show();
  end
  self:SetButton_Anchors();
end

function MainFrame:Toggle_HighlightButton()
  local cfg = self.cfg;
  if (cfg["show_hilightbutton"] == 1) then
    cfg["show_hilightbutton"] = 0;
    _G[self.PREFIX.."_Button_HighlightToggle"]:Hide();
  else
    cfg["show_hilightbutton"] = 1;
    _G[self.PREFIX.."_Button_HighlightToggle"]:Show();
  end
  self:SetButton_Anchors();
end

function MainFrame:Toggle_LockButton()
  local cfg = self.cfg;
  if (cfg["show_lockbutton"] == 1) then
    cfg["show_lockbutton"] = 0;
    _G[self.PREFIX.."_Button_MoveLockToggle"]:Hide();
  else
    cfg["show_lockbutton"] = 1;
    _G[self.PREFIX.."_Button_MoveLockToggle"]:Show();
  end
  self:SetButton_Anchors();
end

function MainFrame:Toggle_ReloadButton()
  local cfg = self.cfg;
  if (cfg["show_reloadbutton"] == 1) then
    cfg["show_reloadbutton"] = 0;
    _G[self.PREFIX.."_Button_Reload"]:Hide();
  else
    cfg["show_reloadbutton"] = 1;
    _G[self.PREFIX.."_Button_Reload"]:Show();
  end
  self:SetButton_Anchors();
end

function MainFrame:Toggle_SearchBox()
  local cfg = self.cfg;
  if (cfg["show_searchbox"] == 1) then
    cfg["show_searchbox"] = 0;
    _G[self.PREFIX.."_SearchBox"]:Hide();
  else
    cfg["show_searchbox"] = 1;
    _G[self.PREFIX.."_SearchBox"]:Show();
  end
  self:SetButton_Anchors();
end

function MainFrame:Toggle_Token()
  local cfg = self.cfg;
  if (cfg["show_tokens"] == 1) then
    cfg["show_tokens"] = 0;
    _G[self.PREFIX.."Frame_TokenFrame"]:Hide();
  else
    cfg["show_tokens"] = 1;
    _G[self.PREFIX.."Frame_TokenFrame"]:Show();
  end
  self:SetButton_Anchors();
end

function MainFrame:Toggle_Total()
  local cfg = self.cfg;
  if (cfg["show_total"] == 1) then
    cfg["show_total"] = 0;
    _G[self.PREFIX.."Frame_Total"]:Hide();
  else
    cfg["show_total"] = 1;
    _G[self.PREFIX.."Frame_Total"]:Show();
  end
  self:SetButton_Anchors();
end

function MainFrame:Toggle_UserDropdown()
  local cfg = self.cfg;
  if (cfg["show_userdropdown"] == 1) then
    cfg["show_userdropdown"] = 0;
    TFuBag:HideDropDownSilently(_G[self.PREFIX.."_UserDropdown"]);
  else
    cfg["show_userdropdown"] = 1;
    _G[self.PREFIX.."_UserDropdown"]:Show();
  end
  self:SetButton_Anchors();
end

-- Batch 2a: two more window-chrome helpers hoisted from Inv/Bank (self.PREFIX).

function MainFrame:SetTopRightButton_Anchors()
  local buttons = {
    self.PREFIX.."_Button_Close",
    self.PREFIX.."_Button_MoveLockToggle",
  }
  local button_right = nil;

  for _,button_name in ipairs(buttons) do
    local button = _G[button_name];
    if (button) then
      if (button_right) then
        button:SetPoint("TOPRIGHT",button_right,"TOPLEFT",10,0);
      else
        button:SetPoint("TOPRIGHT",self,"TOPRIGHT",0,0);
      end
      if (button:IsVisible()) then
        button_right = button;
      end
    end
  end
end

function MainFrame:UpdateFilterButton()
  local btn = _G[self.PREFIX.."_Button_Filter"];
  if (not btn) then return; end
  if (not btn.FilterGlow) then
    btn.FilterGlow = btn:CreateTexture(nil, "OVERLAY");
    btn.FilterGlow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border");
    btn.FilterGlow:SetBlendMode("ADD");
    btn.FilterGlow:SetVertexColor(0.2, 0.8, 1);  -- light blue
    btn.FilterGlow:SetPoint("CENTER", btn, "CENTER", 0, 0);
    local w, h = btn:GetSize();
    btn.FilterGlow:SetSize((w or 20) * 1.7, (h or 20) * 1.7);
  end
  local f = self.itemFilter;
  if (f and f.active) then btn.FilterGlow:Show(); else btn.FilterGlow:Hide(); end
end

-- Batch 3: window button OnClick handlers hoisted from Inv/Bank. self is the
-- clicked button; the window frame + short prefix are derived from its name
-- (TFuInv_Button_X / TFuBnk_Button_X). The buttons' XML OnClick wiring is
-- unchanged (still TFu<W>Frame.Button_X_OnClick(self,...), resolving here).

function MainFrame.Button_Filter_OnClick(self)
  local frame = _G[self:GetName():match("^(TFu%a+)_").."Frame"];
  TFuBag:OpenFilterMenu(frame, self);
end

function MainFrame.Button_HighlightToggle_OnClick(self)
  local frame = _G[self:GetName():match("^(TFu%a+)_").."Frame"];
  PlaySound(PlaySoundKitID and "igMainMenuOptioncheckBoxOn" or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
  if (TFuBag.SrchText) then
    TFuBag:ClearSearch();
    if (GameTooltip:GetOwner() == self) then
      if (frame.hilight_new == 1) then
        TFuBag.NewbieTip(self, L["Normal"], 1.0, 1.0, 1.0,
                                 L["Stop highlighting new items."]);
      else
        TFuBag.NewbieTip(self, L["Highlight New"], 1.0, 1.0, 1.0,
                                 L["Highlight items marked as new."]);
      end
    end
    return;
  elseif (frame.hilight_new == 0) then
    frame.hilight_new = 1;
    if (GameTooltip:GetOwner() == self) then
      TFuBag.NewbieTip(self, L["Normal"], 1.0, 1.0, 1.0,
                               L["Stop highlighting new items."]);
    end
  else
    frame.hilight_new = 0;
    if (GameTooltip:GetOwner() == self) then
      TFuBag.NewbieTip(self, L["Highlight New"], 1.0, 1.0, 1.0,
                               L["Highlight items marked as new."]);
    end
  end
  frame:UpdateWindow();
end

function MainFrame.Button_MoveLockToggle_OnClick(self)
  local pfx = self:GetName():match("^(TFu%a+)_");
  local frame = _G[pfx.."Frame"];
  PlaySound(PlaySoundKitID and "igMainMenuOptioncheckBoxOn" or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
  if (frame.cfg["moveLock"] == 0) then
    frame.cfg["moveLock"] = 1;
    _G[pfx.."LockNorm"]:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Unlocked-Up");
    _G[pfx.."LockPush"]:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Unlocked-Down");
    if (GameTooltip:GetOwner() == self) then
      TFuBag.NewbieTip(self, L["Lock Window"], 1.0, 1.0, 1.0,
                               L["Prevent window from being moved by dragging it."]);
    end
  else
    frame.cfg["moveLock"] = 0;
    _G[pfx.."LockNorm"]:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Locked-Up");
    _G[pfx.."LockPush"]:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Locked-Down");
    if (GameTooltip:GetOwner() == self) then
      TFuBag.NewbieTip(self, L["Unlock Window"], 1.0, 1.0, 1.0,
                               L["Allow window to be moved by dragging it."]);
    end
  end
end

-- Batch 4: more near-identical window methods hoisted from Inv/Bank.

function MainFrame:CalcButtonSize(newsize, pad)
  -- constants
  self.BF_X_PAD = pad;
  self.BF_Y_PAD = pad;
  self.BF_WIDTH = newsize;
  self.BF_HEIGHT = newsize;
  self.BF_PADWIDTH = self.BF_WIDTH + (self.BF_X_PAD*2);
  self.BF_PADHEIGHT = self.BF_HEIGHT + (self.BF_Y_PAD*2);
  self.BGF_WIDTH = self.BF_WIDTH * 1.6 + (self.BF_X_PAD*2);
  self.BGF_HEIGHT = self.BF_HEIGHT * 1.6 + (self.BF_Y_PAD*2);

  -- Always ensure a visually appealing fit
  self.BGF_WIDTH = TFuBag:MakeEven(self.BGF_WIDTH, self.BF_WIDTH);
  self.BGF_HEIGHT = TFuBag:MakeEven(self.BGF_HEIGHT, self.BF_HEIGHT);
end

function MainFrame:Toggle_Money()
  local cfg = self.cfg;
  if (cfg["show_money"] == 1) then
    cfg["show_money"] = 0;
    _G[self.PREFIX.."Frame_MoneyFrame"]:Hide();
  else
    cfg["show_money"] = 1;
    _G[self.PREFIX.."Frame_MoneyFrame"]:Show();
  end
  self:SetButton_Anchors();
  -- Bank-only tail (Inv has no UpdateMoneyControls): refresh the deposit/withdraw controls.
  if (self.UpdateMoneyControls) then self:UpdateMoneyControls(); end
end

function MainFrame:SetBottomRightButton_Anchors()
  local buttons = {
    self.PREFIX.."Frame_MoneyFrame",
    self.PREFIX.."Frame_TokenFrame",
  }
  local button_right = nil

  for _, button_name in ipairs(buttons) do
    local button = _G[button_name]
    if button then
      button:ClearAllPoints()
      if button_right then
        button:SetPoint("BOTTOMRIGHT",button_right,"TOPRIGHT",0,-5);
      else
        local y = 5
        if self.edit_mode == 1 then
          y = y + 30
        end
        button:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",5,y)
      end
      if button:IsVisible() then
        button_right = button
      end
    end
  end
end

-- Exception-safe reentrancy guard (self-scoped; was Inv/Bank.WindowIsUpdating). The
-- body runs under pcall so a Lua error (e.g. a transient nil during a bank<->warband
-- transition) can't skip the reset and wedge the window until /reload; the error is
-- still surfaced via the standard handler so the cause stays diagnosable.
function MainFrame:UpdateWindow(resort_req)
  TFuBag:PrintDEBUG("UpdateWindow: WindowIsUpdating="..tostring(self.WindowIsUpdating));
  if (self.WindowIsUpdating == 1) then
    return;
  end
  self.WindowIsUpdating = 1;
  local ok, err = pcall(self.UpdateWindowBody, self, resort_req);
  self.WindowIsUpdating = 0;
  if (not ok) then geterrorhandler()(err); end
end
