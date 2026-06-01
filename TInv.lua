-- $Id$

local _G = getfenv(0)
local TFuBag = _G.TFuBag
TFuBag.Inv = {}
local Inv = TFuBag.Inv

-- Localization Support
local L = TFuBag.LOCALE;

BINDING_NAME_TFuINV_TOGGLE = L["Toggle Inventory Window"];

-- Constants
TFuINV_DEBUGMESSAGES = 0;   -- 0 = off, 1 = on
TFuINV_SHOWITEMDEBUGINFO = 0;
local TFuINV_WIPECONFIGONLOAD = 0;  -- for debugging, test it out on a new config every load


------------------------

function Inv:CalcButtonSize(newsize, pad)
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

function Inv:SetDefPos(cfg, reset)
  TFuBag:SetDef(cfg, "frameLEFT", UIParent:GetRight() * UIParent:GetScale() * 0.73, reset, TFuBag.NumFunc);
  TFuBag:SetDef(cfg, "frameRIGHT", UIParent:GetRight() * UIParent:GetScale() * 0.92, reset, TFuBag.NumFunc);
  TFuBag:SetDef(cfg, "frameTOP", UIParent:GetTop() * UIParent:GetScale() * 0.83, reset, TFuBag.NumFunc);
  TFuBag:SetDef(cfg, "frameBOTTOM", UIParent:GetTop() * UIParent:GetScale() * 0.232, reset, TFuBag.NumFunc);
  TFuBag:SetDef(cfg, "frameXRelativeTo", "LEFT", reset, TFuBag.StrFunc, {"RIGHT","LEFT"} );
  TFuBag:SetDef(cfg, "frameYRelativeTo", "BOTTOM", reset, TFuBag.StrFunc, {"TOP","BOTTOM"} );
end

-- set reset to 1 to restore all default values
function Inv:InitDefVals(reset)
  local i, key, value;
  local cfg = self.cfg;

  TFuBag:InitDefVals(cfg, self.bags, 0, reset);

  TFuBag:SetDef(cfg, "maxColumns", 11, reset, TFuBag.NumFunc, TFuBag.NUMCOL_MIN,TFuBag.NUMCOL_MAX);

  TFuBag:SetDef(cfg, "alt_pickup", 1, reset, TFuBag.NumFunc, 0, 1);
  TFuBag:SetDef(cfg, "alt_panel", 1, reset, TFuBag.NumFunc, 0, 1);

  TFuBag:SetDef(cfg, "show_keyring_empty_slots", 0, reset, TFuBag.NumFunc, 0, 1);

  -- Colors
  TFuBag:SetColor(cfg, "bkgr_"..TFuBag.MAIN_BAR, 0.0, 0.2, 0.4, 0.4, reset);
  TFuBag:SetColor(cfg, "brdr_"..TFuBag.MAIN_BAR, 0.2, 0.2, 1.0, 0.3, reset);
  for i = 1, TFuBag.BAR_MAX do
    TFuBag:SetColor(cfg, "bkgr_"..i, 0.0, 0.2, 0.4, 0.4, reset);
    TFuBag:SetColor(cfg, "brdr_"..i, 0.2, 0.2, 1.0, 0.3, reset);
  end
  TFuBag:SetDefColors(cfg, reset);

  self:SetDefPos(cfg, reset);

  TFuBag:SetDef(cfg, "show_searchbox", 1, reset, TFuBag.NumFunc, 0, 1);
  TFuBag:SetDef(cfg, "show_bankbutton", 1, reset, TFuBag.NumFunc, 0, 1);

end

function Inv:SetPlayer(playerid)
   -- An ugly hack to get around the fact that we can't hook the
   -- OnClick for the ContainerFrameItemButton.  The Blizzard
   -- code uses the id of the frame to figure out what to pickup.
   -- When we are showing another character's inventory we set
   -- our bag frames id's to 100 to stop Blizzard's code from
   -- actually doing anything.
   if (playerid ~= TFuBag.PLAYERID) then
     for _, bag in ipairs(self.bags) do
       _G[TFuBag:GetDummyBagFrameName(bag)]:SetID(100);
     end
   else
     for _, bag in ipairs(self.bags) do
       _G[TFuBag:GetDummyBagFrameName(bag)]:SetID(bag);
     end
   end
   if self.playerid ~=  playerid then
     self.CACHE_REQ = TFuBag.REQ_MUST
   end
   self.playerid = playerid;
   TFuBag.Tokens.Update(TFuInvFrame_TokenFrame)
end



-- Set reset = 1 to restore default values
function Inv:init(reset)
  if not Inv.metatabledone then
    setmetatable(TFuBag.MainFrame,getmetatable(TFuInvFrame))
    setmetatable(TFuBag.Inv,{__index=TFuBag.MainFrame})
    setmetatable(TFuInvFrame,{__index=TFuBag.Inv})
    Inv.metatabledone = true
  end
  self = TFuInvFrame
  self:SetUserPlaced(false) -- remove us from layout-cache

  -- View switching
  self.playerid  = "";
  self.bags = TFuBag.Inv_Bags

  self.CACHE_REQ = TFuBag.REQ_NONE;

  self.cfg  = nil;
  self.BARITM = {};
  self.hilight_new = 0;
  self.edit_mode = 0;
  self.ml_edit = 0;         -- Manual Layout edit/unlock: 1 = boxes draggable; manual_layout stays active when this is 0 (layout shown, locked)
  self.edit_hilight = "";   -- when editmode is 1, which items do you want to hilight
  self.edit_selected = "";  -- when editmode is 1, this is the class of item you clicked on
  self.RightClickMenu_mode = "";
  self.RightClickMenu_opts = {};
  self.RightClickMenu = TFuInvFrame_RightClickMenu

  self.BC_LIST = {};  -- Bar to Class conversion

  self.BF_X_PAD = 1;
  self.BF_Y_PAD = 1;
  self.BF_WIDTH = 34;
  self.BF_HEIGHT = 34;
  self.BF_PADWIDTH = 36;
  self.BF_PADHEIGHT = 36;
  self.BGF_WIDTH = 38;
  self.BGF_HEIGHT = 38;


  TFuBag:Init();
  self.cfg = TFuBagCfg["Inv"];
  local cfg = self.cfg

  if ( TFuINV_WIPECONFIGONLOAD == 1 ) then
    cfg = {};
  end

  self:SetPlayer(TFuBag.PLAYERID);

  -- Scroll viewport (WowScrollBox single-content-frame pattern):
  --   TFuInvFrame.Scroll              -- WowScrollBox (clipChildren via template)
  --     TFuInvFrame.Scroll.ScrollChild   -- .scrollable=true, LinearView manages this
  --       TFuInvFrame.Scroll.ScrollChild.Container  -- holds the bars
  -- Bars are children of Container so the clip cascades through ScrollChild ->
  -- ScrollBox. Dummy bag containers are reparented into Container too so
  -- items render INSIDE the scroll viewport rather than at UIParent level --
  -- otherwise icons render past sb's bottom and overlap the chrome (bag
  -- slots, search, money, currency, horizontal scrollbar) because
  -- clipChildren can't catch frames that aren't descendants.
  local invContainer = TFuInvFrame.Scroll
    and TFuInvFrame.Scroll.ScrollChild
    and TFuInvFrame.Scroll.ScrollChild.Container;

  -- Make all the frames
  for _, bag in ipairs(self.bags) do
    TFuBag:CreateDummyBag(bag, "TFuBag_ItemButtonTemplate");
    if (invContainer) then
      local dbag = _G[TFuBag:GetDummyBagFrameName(bag)];
      if (dbag) then dbag:SetParent(invContainer); end
    end
  end

  TFuBag:CreateFrame("Frame", "TFuInvFrame_bar_", invContainer or TFuInvFrame,
    "TFuBag_BarFrameTemplate", TFuBag.BAR_MAX, "");
  TFuBag:CreateFrame("Button", "TFuInvFrame_BarButton_", invContainer or TFuInvFrame,
    "TFuBag_BarButtonTemplate", TFuBag.BAR_MAX, "");

  -- register slash command
  SlashCmdList["TFuINV"] = TFuInv_cmd;
  SLASH_TFuINV1 = "/tinv";
  SLASH_TFuINV2 = "/tbag";

  -- load default values
  self:InitDefVals(reset);

  self:CalcButtonSize(cfg["frameButtonSize"], cfg["framePad"]);

  for _, bag in ipairs(self.bags) do
    TFuBag:GetBagFrame(bag):SetScale(0.7);
  end

  TFuInv_SearchBox:SetMaxLetters(25);

  -- setup hooks
  TFuBag.Hooks.Register(TFuBag.Hooks.UNREGISTER);
  TFuBag.Hooks.Register(TFuBag.Hooks.REGISTER);

  -- Setup the token system
  TFuBag.Tokens.Enable()
  TFuBag.Tokens.Scan()

  if (cfg["moveLock"] == 0) then
    TFuInvLockNorm:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Locked-Up");
    TFuInvLockPush:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Locked-Down");
  else
    TFuInvLockNorm:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Unlocked-Up");
    TFuInvLockPush:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Unlocked-Down");
  end


  if (cfg["show_bagbuttons"] == 0) then
    TFuInvacterBag0Slot:Hide();
    TFuInvacterBag1Slot:Hide();
    TFuInvacterBag2Slot:Hide();
    TFuInvacterBag3Slot:Hide();
    TFuInvacterBag4Slot:Hide();
    TFuInvMenuBarBackpackButton:Hide();
    TFuInvingButton:Hide();
  end
  if (cfg["show_searchbox"] == 0) then
    TFuInv_SearchBox:Hide();
  end
  if (cfg["show_userdropdown"] == 0) then
    TFuInv_UserDropdown:Hide();
  end
  if (cfg["show_reloadbutton"] == 0) then
    TFuInv_Button_Reload:Hide();
  end
  if (cfg["show_bankbutton"] == 0) then
    TFuInv_Button_ShowBank:Hide();
  end
  if (cfg["show_editbutton"] == 0) then
    TFuInv_Button_ChangeEditMode:Hide();
  end
  if (cfg["show_editbutton"] == 0) then
    TFuInv_Button_ChangeEditMode:Hide();
  end
  if (cfg["show_hilightbutton"] == 0) then
    TFuInv_Button_HighlightToggle:Hide();
  end
  if (cfg["show_lockbutton"] == 0) then
    TFuInv_Button_MoveLockToggle:Hide();
  end
  if (cfg["show_closebutton"] == 0) then
    TFuInv_Button_Close:Hide();
  end
  if (cfg["show_total"] == 0) then
    TFuInvFrame_Total:Hide();
  end
  if (cfg["show_money"] == 0) then
    TFuInvFrame_MoneyFrame:Hide();
  end
  if (cfg["show_tokens"] == 0) then
    TFuInvFrame_TokenFrame:Hide();
  end

  TFuBag:BuildBarClassList(self.BC_LIST, cfg);

  -- Force update item cache.
  TFuBag:ClearItmCache(TFuInvItm[self.playerid], self.bags);
  TFuBag:UpdateItmCache(cfg, self.playerid, TFuInvItm[self.playerid], self.bags);

  self.BARITM = TFuBag:SortItmCache(cfg,
    self.playerid, TFuInvItm[self.playerid], self.BARITM, self.bags);
  TFuBag:LayoutWindow(self)
end

function Inv:UpdateBagGfx()
  local bag;
  local totalfree = 0;
  local totalsize = 0;
  local cfg = self.cfg
  for _, bag in ipairs(self.bags) do
    local free, size = TFuBag:UpdateSlots(self.playerid, bag, cfg["show_bag_sizes"]);
    totalfree = totalfree + free;
    totalsize = totalsize + size;

    -- Update the textures as well
    TFuBag:GetBagFrameTexture(bag):SetTexture(
        TFuBag:GetBagTexture(self.playerid, bag));

    TFuBag:UpdateBagColors(bag);
  end
  TFuBag:SetFreeStr(TFuInvFrame_TotalText, totalfree, totalsize, cfg["show_bag_sizes"]);
end

function Inv.Button_HighlightToggle_OnClick(self)
  PlaySound(PlaySoundKitID and "igMainMenuOptioncheckBoxOn" or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
  if (TFuBag.SrchText) then
    TFuBag:ClearSearch();
    if (GameTooltip:GetOwner() == TFuInv_Button_HighlightToggle) then
      if (TFuInvFrame.highlight_new == 1) then
        TFuBag.NewbieTip(self, L["Normal"], 1.0, 1.0, 1.0,
                                 L["Stop highlighting new items."]);
      else
        TFuBag.NewbieTip(self, L["Highlight New"], 1.0, 1.0, 1.0,
                                 L["Highlight items marked as new."]);
      end
    end
    return;
  elseif (TFuInvFrame.hilight_new == 0) then
    TFuInvFrame.hilight_new = 1;
    if (GameTooltip:GetOwner() == TFuInv_Button_HighlightToggle) then
      TFuBag.NewbieTip(self, L["Normal"], 1.0, 1.0, 1.0,
                               L["Stop highlighting new items."]);
    end
  else
    TFuInvFrame.hilight_new = 0;
    if (GameTooltip:GetOwner() == TFuInv_Button_HighlightToggle) then
      TFuBag.NewbieTip(self, L["Highlight New"], 1.0, 1.0, 1.0,
                               L["Highlight items marked as new."]);
    end
  end
  TFuInvFrame:UpdateWindow();
end

-- Edit button. With Legacy Edit ON it toggles the original numbered-bar edit_mode
-- (click an item's category, click a bar to move it). With Legacy Edit OFF it toggles
-- Manual Layout (freeform draggable categories). Name kept to avoid XML/menu churn.
function Inv.Button_ChangeEditMode_OnClick()
  PlaySound(PlaySoundKitID and "igMainMenuOptioncheckBoxOn" or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
  local cfg = TFuInvFrame.cfg;
  if (cfg["legacy_edit"] == 1) then
    TFuInvFrame.edit_mode = (TFuInvFrame.edit_mode == 1) and 0 or 1;
  else
    -- Drag-to-arrange: the gear is a pure lock/UNLOCK for editing the manual layout.
    -- Unlocking also ACTIVATES manual layout; LOCKING keeps the arranged layout shown
    -- (use_ml only checks manual_layout, so placements persist) -- it is not turned off
    -- here. To return to auto-flow, uncheck "Use Manual Layout" in Options.
    TFuInvFrame.edit_mode = 0;  -- classic edit off when using Manual Layout
    TFuInvFrame.ml_edit = (TFuInvFrame.ml_edit == 1) and 0 or 1;
    if (TFuInvFrame.ml_edit == 1) then cfg["manual_layout"] = 1; end
  end
  TFuInvFrame._last_hilight = nil;  -- force the next edit-highlight refresh
  -- resort will force a window redraw
  TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST);
end

function Inv.Button_Reload_OnClick()
  -- Never clear another player's cache
  if (TFuInvFrame.playerid == TFuBag.PLAYERID) then
    TFuBag:ClearItmCache(TFuInvItm[TFuInvFrame.playerid], TFuInvFrame.bags);
    TFuBag:ClearStackSkip(TFuInvFrame.bags);
    TFuBag:ClearCompSkip(TFuInvFrame.bags);

    -- Send a message to restack
    if (TFuInvFrame.cfg["stack_resort"] == 1) then
      TFuInvFrame.cfg["stack_once"] = 1;
    end
  end

  TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST);
  TFuBag:PrintDEBUG("TFuInv reloaded.");
end

function Inv.Button_ShowBank_OnClick()
  TFuBnkFrame:Toggle()
end

function Inv.Button_Filter_OnClick(self)
  TFuBag:OpenFilterMenu(TFuInvFrame, self);
end

-- Glow the filter button while any filter dimension is active, so it is obvious
-- why items are hidden. Glow texture is created lazily (mirrors the ML button).
function Inv:UpdateFilterButton()
  local btn = TFuInv_Button_Filter;
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

function Inv.Button_MoveLockToggle_OnClick(self)
  PlaySound(PlaySoundKitID and "igMainMenuOptioncheckBoxOn" or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
  if (TFuInvFrame.cfg["moveLock"] == 0) then
    TFuInvFrame.cfg["moveLock"] = 1;
    TFuInvLockNorm:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Unlocked-Up");
    TFuInvLockPush:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Unlocked-Down");
    if (GameTooltip:GetOwner() == TFuInv_Button_MoveLockToggle) then
      TFuBag.NewbieTip(self, L["Lock Window"], 1.0, 1.0, 1.0,
                               L["Prevent window from being moved by dragging it."]);
    end
  else
    TFuInvFrame.cfg["moveLock"] = 0;
    TFuInvLockNorm:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Locked-Up");
    TFuInvLockPush:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Locked-Down");
    if (GameTooltip:GetOwner() == TFuInv_Button_MoveLockToggle) then
      TFuBag.NewbieTip(self, L["Unlock Window"], 1.0, 1.0, 1.0,
                               L["Allow window to be moved by dragging it."]);
    end
  end
end

function Inv.BagSlotButton_OnEnter(self)
  local bag = self:GetID() - 19;
  local itemlink = TFuBag:GetPlayerBagCfg(TFuInvFrame.playerid, bag, TFuBag.I_ITEMLINK);

  GameTooltip:SetOwner(self, "ANCHOR_LEFT");
  GameTooltip:ClearLines();

  if (itemlink and itemlink ~= "") then
    GameTooltip:SetHyperlink(itemlink);
  else
    GameTooltip:AddLine(L["Equip Container"], 1,1,1);
  end

  GameTooltip:Show();
end

function Inv:SetTopLeftButton_Anchors()
  local buttons = {
    "TFuInv_Button_HighlightToggle",
    "TFuInv_Button_ChangeEditMode",
    "TFuInv_Button_ShowBank",
    "TFuInv_Button_Reload",
    "TFuInv_Button_Filter",
  };
  local button_left = nil;

  -- Handle user dropdown list separately...
  local dropdown = TFuInv_UserDropdown;
  if (dropdown and dropdown:IsVisible()) then
    dropdown:ClearAllPoints();
    dropdown:SetPoint("TOPLEFT",TFuInvFrame,"TOPLEFT",-10,-5);
    button_left = dropdown;
  end

  for _,button_name in ipairs(buttons) do
    button = _G[button_name];
    if (button) then
      TFuBag:TrimButtonIcon(button);
      button:ClearAllPoints();
      if (button_left) then
        if (button_left == dropdown) then
          -- First button after dropdown
          button:SetPoint("TOPLEFT",button_left,"TOPRIGHT",15,-3);
        else
          -- button following another button
          button:SetPoint("TOPLEFT",button_left,"TOPRIGHT",2,0);
        end
      else
        -- First button if dropdown is hidden
        button:SetPoint("TOPLEFT",TFuInvFrame,"TOPLEFT",9,-8);
      end
      if (button:IsVisible()) then
        button_left = button;
      end
    end
  end
end

function Inv:SetTopRightButton_Anchors()
  local buttons = {
    "TFuInv_Button_Close",
    "TFuInv_Button_MoveLockToggle",
  }
  local button_right = nil;

  for _,button_name in ipairs(buttons) do
    local button = _G[button_name];
    if (button) then
      if (button_right) then
        button:SetPoint("TOPRIGHT",button_right,"TOPLEFT",10,0);
      else
        button:SetPoint("TOPRIGHT",TFuInvFrame,"TOPRIGHT",0,0);
      end
      if (button:IsVisible()) then
        button_right = button;
      end
    end
  end
end

function Inv:SetBottomLeftButton_Anchors()
  local buttons = {
    "TFuInvFrame_Total",
    "TFuInvacterBag4Slot",
  }
  local button_left = nil;

  -- Handle search box separate.
  local search = TFuInv_SearchBox;
  if (search and search:IsVisible()) then
    local y = 4;
    if (TFuInvFrame.edit_mode == 1) then
      y = y + 30;
    end
    search:ClearAllPoints();
    search:SetPoint("BOTTOMLEFT",TFuInvFrame,"BOTTOMLEFT",10,y);
    button_left = search;
  end

  for _,button_name in ipairs(buttons) do
    button = _G[button_name];
    if (button) then
      button:ClearAllPoints();
      if (button_left) then
        if (button_left == search) then
          -- First button after search
          button:SetPoint("BOTTOMLEFT",button_left,"TOPLEFT",0,4);
        else
          -- button following another button (tight spacing). The old extra gap after
          -- the Total to clear the bottom-left free-slots cell is gone -- that cell moved
          -- to the bottom of the item area (the single empty-slot widget).
          button:SetPoint("BOTTOMLEFT",button_left,"BOTTOMRIGHT",3,-1);
        end
      else
        -- First button if dropdown is hidden
        local y = 12;
        if (TFuInvFrame.edit_mode == 1) then
          y = y + 30;
        end
        button:SetPoint("BOTTOMLEFT",TFuInvFrame,"BOTTOMLEFT",10,y);
      end
      if (button:IsVisible()) then
        button_left = button;
      end
    end
  end

end

function Inv:SetBottomRightButton_Anchors()
  local buttons = {
    "TFuInvFrame_MoneyFrame",
    "TFuInvFrame_TokenFrame",
  }
  local button_right = nil

  for _, button_name in ipairs(buttons) do
    button = _G[button_name]
    if button then
      button:ClearAllPoints()
      if button_right then
        button:SetPoint("BOTTOMRIGHT",button_right,"TOPRIGHT",0,-5);
      else
        local y = 5
        if TFuInvFrame.edit_mode == 1 then
          y = y + 30
        end
        button:SetPoint("BOTTOMRIGHT",TFuInvFrame,"BOTTOMRIGHT",5,y)
      end
      if button:IsVisible() then
        button_right = button
      end
    end
  end
end

function Inv:SetButton_Anchors()
  self:SetTopLeftButton_Anchors();
  self:SetTopRightButton_Anchors();
  self:SetBottomLeftButton_Anchors();
  self:SetBottomRightButton_Anchors();
  TFuBag:LayoutWindow(self)
end

function Inv.Toggle_CloseButton()
  if (TFuInvFrame.cfg["show_closebutton"] == 1) then
    TFuInvFrame.cfg["show_closebutton"] = 0;
    TFuInv_Button_Close:Hide();
    TFuInvFrame:SetButton_Anchors();
  else
    TFuInvFrame.cfg["show_closebutton"] = 1;
    TFuInv_Button_Close:Show();
    TFuInvFrame:SetButton_Anchors();
  end
end

function Inv.Toggle_LockButton()
  if (TFuInvFrame.cfg["show_lockbutton"] == 1) then
    TFuInvFrame.cfg["show_lockbutton"] = 0;
    TFuInv_Button_MoveLockToggle:Hide();
    TFuInvFrame:SetButton_Anchors();
  else
    TFuInvFrame.cfg["show_lockbutton"] = 1;
    TFuInv_Button_MoveLockToggle:Show();
    TFuInvFrame:SetButton_Anchors();
  end
end

function Inv.Toggle_HighlightButton()
  if (TFuInvFrame.cfg["show_hilightbutton"] == 1) then
    TFuInvFrame.cfg["show_hilightbutton"] = 0;
    TFuInv_Button_HighlightToggle:Hide();
    TFuInvFrame:SetButton_Anchors();
  else
    TFuInvFrame.cfg["show_hilightbutton"] = 1;
    TFuInv_Button_HighlightToggle:Show();
    TFuInvFrame:SetButton_Anchors();
  end
end

function Inv.Toggle_EditButton()
  if (TFuInvFrame.cfg["show_editbutton"] == 1) then
    TFuInvFrame.cfg["show_editbutton"] = 0;
    TFuInv_Button_ChangeEditMode:Hide();
    TFuInvFrame:SetButton_Anchors();
  else
    TFuInvFrame.cfg["show_editbutton"] = 1;
    TFuInv_Button_ChangeEditMode:Show();
    TFuInvFrame:SetButton_Anchors();
  end
end

function Inv.Toggle_BankButton()
  if (TFuInvFrame.cfg["show_bankbutton"] == 1) then
    TFuInvFrame.cfg["show_bankbutton"] = 0;
    TFuInv_Button_ShowBank:Hide();
    TFuInvFrame:SetButton_Anchors();
  else
    TFuInvFrame.cfg["show_bankbutton"] = 1;
    TFuInv_Button_ShowBank:Show();
    TFuInvFrame:SetButton_Anchors();
  end
end

function Inv.Toggle_ReloadButton()
  if (TFuInvFrame.cfg["show_reloadbutton"] == 1) then
    TFuInvFrame.cfg["show_reloadbutton"] = 0;
    TFuInv_Button_Reload:Hide();
    TFuInvFrame:SetButton_Anchors();
  else
    TFuInvFrame.cfg["show_reloadbutton"] = 1;
    TFuInv_Button_Reload:Show();
    TFuInvFrame:SetButton_Anchors();
  end
end

function Inv.Toggle_SearchBox()
  if (TFuInvFrame.cfg["show_searchbox"] == 1) then
    TFuInvFrame.cfg["show_searchbox"] = 0;
    TFuInv_SearchBox:Hide();
    TFuInvFrame:SetButton_Anchors();
  else
    TFuInvFrame.cfg["show_searchbox"] = 1;
    TFuInv_SearchBox:Show();
    TFuInvFrame:SetButton_Anchors();
  end
end

function Inv.Toggle_UserDropdown()
  if (TFuInvFrame.cfg["show_userdropdown"] == 1) then
    TFuInvFrame.cfg["show_userdropdown"] = 0;
    TFuInv_UserDropdown:Hide();
    TFuInvFrame:SetButton_Anchors();
  else
    TFuInvFrame.cfg["show_userdropdown"] = 1;
    TFuInv_UserDropdown:Show();
    TFuInvFrame:SetButton_Anchors();
  end
end

function Inv.Toggle_Money()
  if (TFuInvFrame.cfg["show_money"] == 1) then
    TFuInvFrame.cfg["show_money"] = 0;
    TFuInvFrame_MoneyFrame:Hide();
    TFuInvFrame:SetButton_Anchors();
  else
    TFuInvFrame.cfg["show_money"] = 1;
    TFuInvFrame_MoneyFrame:Show();
    TFuInvFrame:SetButton_Anchors();
  end
end

function Inv.Toggle_Token()
  if (TFuInvFrame.cfg["show_tokens"] == 1) then
    TFuInvFrame.cfg["show_tokens"] = 0;
    TFuInvFrame_TokenFrame:Hide();
    TFuInvFrame:SetButton_Anchors();
  else
    TFuInvFrame.cfg["show_tokens"] = 1;
    TFuInvFrame_TokenFrame:Show();
    TFuInvFrame:SetButton_Anchors();
  end
end

function Inv.Toggle_BagSlotButtons()
  if (TFuInvFrame.cfg["show_bagbuttons"] == 1) then
    TFuInvFrame.cfg["show_bagbuttons"] = 0;
    TFuInvacterBag0Slot:Hide();
    TFuInvacterBag1Slot:Hide();
    TFuInvacterBag2Slot:Hide();
    TFuInvacterBag3Slot:Hide();
    TFuInvacterBag4Slot:Hide();
    TFuInvMenuBarBackpackButton:Hide();
    TFuInvingButton:Hide();
    TFuInvFrame:SetButton_Anchors();
  else
    TFuInvFrame.cfg["show_bagbuttons"] = 1;
    TFuInvacterBag0Slot:Show();
    TFuInvacterBag1Slot:Show();
    TFuInvacterBag2Slot:Show();
    TFuInvacterBag3Slot:Show();
    TFuInvacterBag4Slot:Show();
    TFuInvMenuBarBackpackButton:Show();
    TFuInvingButton:Show();
    TFuInvFrame:SetButton_Anchors();
   end
end

function Inv.Toggle_Total()
  if (TFuInvFrame.cfg["show_total"] == 1) then
    TFuInvFrame.cfg["show_total"] = 0;
    TFuInvFrame_Total:Hide();
    TFuInvFrame:SetButton_Anchors();
  else
    TFuInvFrame.cfg["show_total"] = 1;
    TFuInvFrame_Total:Show();
    TFuInvFrame:SetButton_Anchors();
  end
end

function Inv.RightClick_DeleteItemOverride(self)
  local bag, slot, itm;
  local this = self or _G.this

  bag = this.value[TFuBag.I_BAG];
  slot = this.value[TFuBag.I_SLOT];

  if ( (bag ~= nil) and (slot ~= nil) ) then
    itm = TFuInvItm[TFuInvFrame.playerid][bag][slot];

    if (itm[TFuBag.I_ITEMLINK] ~= nil) then
      local id = TFuBag:GetItemID(itm[TFuBag.I_ITEMLINK]);
      if TFuInvFrame.cfg["item_overrides"][id] ~= nil then
        TFuInvFrame.cfg["item_overrides"][id] = nil;
        HideDropDownMenu(1);

        -- resort will force a window redraw as well
        TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST);
      end
    end
  end
end

function Inv.RightClick_SetItemOverride(self)
  local bag, slot, itm, new_barclass;
  local this = self or _G.this

  bag = this.value[TFuBag.I_BAG];
  slot = this.value[TFuBag.I_SLOT];
  new_barclass = this.value["barclass"];

  if ( (bag ~= nil) and (slot ~= nil) and (new_barclass ~= nil) ) then
    itm = TFuInvItm[TFuInvFrame.playerid][bag][slot];

    TFuInvFrame.cfg["item_overrides"][TFuBag:GetItemID(itm[TFuBag.I_ITEMLINK])] = new_barclass;
    HideDropDownMenu(2);
    HideDropDownMenu(1);
    TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST);
  end
end

function Inv.RightClickMenu_populate(self, level)
  local bar, bag, slot;
  local info, itm, id, barclass, tmp, checked, i;
  local key, value, key2, value2;


  -------------------------------------------------------------------------------------------------
  ------------------------------- ITEM CONTEXT MENU -----------------------------------------------
  -------------------------------------------------------------------------------------------------
  if (TFuInvFrame.RightClickMenu_mode == "item") then
    -- we have a right click on a button

    bar = TFuInvFrame.RightClickMenu_opts[TFuBag.I_BAR];
    bag = TFuInvFrame.RightClickMenu_opts[TFuBag.I_BAG];
    slot = TFuInvFrame.RightClickMenu_opts[TFuBag.I_SLOT];
    itm = TFuInvItm[TFuInvFrame.playerid][bag][slot];
    id = TFuBag:GetItemID(itm[TFuBag.I_ITEMLINK]);

    if (level == 1) then
      -- top level of menu

      info = { ["text"] = itm[TFuBag.I_NAME], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
      UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = { ["text"] = string.format(L["Current Category: %s"],itm[TFuBag.I_CAT]), ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
      UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = { ["text"] = L["Assign item to category:"], ["hasArrow"] = 1, ["value"] = "override_placement" };
      if (TFuInvFrame.cfg["item_overrides"][id] ~= nil) then
        info["checked"] = 1;
      end
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Use default category assignment"],
        ["value"] = { [TFuBag.I_BAG]=bag, [TFuBag.I_SLOT]=slot },
        ["func"] = TFuInvFrame.RightClick_DeleteItemOverride
        };
      if (TFuInvFrame.cfg["item_overrides"][id] == nil) then
        info["checked"] = 1;
      end
      UIDropDownMenu_AddButton(info, level);

      if (TFuINV_SHOWITEMDEBUGINFO==1) then
        info = { ["disabled"] = 1 };
        UIDropDownMenu_AddButton(info, level);

        info = { ["text"] = L["Debug Info: "], ["hasArrow"] = 1, ["value"] = "show_debug" };
        UIDropDownMenu_AddButton(info, level);
      end
    elseif (level == 2) then
      if ( UIDROPDOWNMENU_MENU_VALUE == "override_placement" ) then
        for i = 1, TFuBag.BAR_MAX do
          info = {
            ["text"] = string.format(L["Categories within bar %d"],i);
            ["value"] = { ["opt"]="override_placement_select", [TFuBag.I_BAG]=bag, [TFuBag.I_SLOT]=slot, ["select_bar"]=i },
            ["hasArrow"] = 1
            };
          if (
        (TFuInvFrame.cfg["item_overrides"][id]
        ~= nil) and (TFuBag:GetCat(TFuInvFrame.cfg, TFuInvFrame.cfg["item_overrides"][id]) == i) ) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
        end
      elseif ( UIDROPDOWNMENU_MENU_VALUE == "show_debug" ) then
        for key, value in pairs(itm) do
          if (value == nil) then
            info = { ["text"] = "|cFFFF7FFF"..key.."|r = |cFF007FFFNil|r", ["notClickable"] = 1 };
            UIDropDownMenu_AddButton(info, level);
          else
            if ( (type(value) == "number") or (type(value) == "string") ) then
              info = { ["text"] = "|cFFFF7FFF"..key.."|r = |cFF007FFF"..value.."|r", ["notClickable"] = 1 };
              UIDropDownMenu_AddButton(info, level);
            else
              info = { ["text"] = "|cFFFF7FFF"..key.."|r|cFF338FFF=>Array()|r", ["notClickable"] = 1 };
              UIDropDownMenu_AddButton(info, level);
              for key2, value2 in pairs(value) do
                info = { ["text"] = "  |cFFFF7FFF["..key2.."]|r = |cFF338FFF"..value2.."|r", ["notClickable"] = 1 };
                UIDropDownMenu_AddButton(info, level);
              end
            end
          end
        end
      end
    elseif (level == 3) then
      if ( UIDROPDOWNMENU_MENU_VALUE ~= nil ) then
        if ( UIDROPDOWNMENU_MENU_VALUE["opt"] == "override_placement_select" ) then
          for key,barclass in pairs(TFuInvFrame.BC_LIST[UIDROPDOWNMENU_MENU_VALUE["select_bar"]]) do
            info = {
              ["text"] = barclass;
              ["value"] = { [TFuBag.I_BAG]=bag, [TFuBag.I_SLOT]=slot, ["barclass"]=barclass },
              ["func"] = TFuInvFrame.RightClick_SetItemOverride
              };
            if (TFuInvFrame.cfg["item_overrides"][id] == barclass) then
              info["checked"] = 1;
            end
            UIDropDownMenu_AddButton(info, level);
          end
        end
      end
    end

  -------------------------------------------------------------------------------------------------
  ------------------------ SLOT TARGET CONTEXT MENU -----------------------------------------------
  -------------------------------------------------------------------------------------------------
  elseif (TFuInvFrame.RightClickMenu_mode == "bar") then
    -- right click on a slot
    bar = TFuInvFrame.RightClickMenu_opts[TFuBag.I_BAR];

    info = { ["text"] = string.format(L["|c%sBar |r|c%s%s|r"],TFuBag.C_INST, TFuBag.C_BAR, bar),
      ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);

    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    for key, value in pairs(TFuInvFrame.BC_LIST[bar]) do
      info = {
        ["text"] = string.format(L["Move: |c%s%s|r"],TFuBag.C_CAT,value);
        ["value"] = value;
        ["func"] = function(self)
          local this = self or _G.this
          TFuInvFrame.edit_selected = (this.value);
          TFuInvFrame.edit_hilight = (this.value);
          TFuInvFrame:UpdateWindow();
        end
      };
      UIDropDownMenu_AddButton(info, level);
    end

    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = { ["text"] = L["Sort Mode:"], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);

    for key, value in pairs({
      [TFuBag.SORTBY_NONE] = L["No sort"],
      [TFuBag.SORTBY_NORM] = L["Sort by name"],
      [TFuBag.SORTBY_REV] = L["Sort last words first"]
      }) do

      if (TFuBag:GetGrp(TFuInvFrame.cfg, TFuBag.G_BAR_SORT, bar) == key) then
        checked = 1;
      else
        checked = nil;
      end

      info = {
        ["text"] = value;
        ["value"] = { [TFuBag.I_BAR]=bar, ["sortby"]=key };
        ["func"] = function(self)
            local this = self or _G.this
            TFuBag:SetGrpDef(TFuInvFrame.cfg, TFuBag.G_BAR_SORT, this.value[TFuBag.I_BAR], this.value["sortby"], 1);
            TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST);
          end,
        ["checked"] = checked
        };
      UIDropDownMenu_AddButton(info, level);
    end

    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = { ["text"] = L["Hide Bar:"], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);

    for key,value in pairs({
      [0] = L["Show items assigned to this bar"],
      [1] = L["Hide items assigned to this bar"]
      }) do

      if (TFuBag:GetGrp(TFuInvFrame.cfg, TFuBag.G_BAR_HIDE, bar) == key) then
        checked = 1;
      else
        checked = nil;
      end

      info = {
        ["text"] = value;
        ["value"] = { [TFuBag.I_BAR]=bar, ["value"]=key };
        ["func"] = function(self)
          local this = self or _G.this
          TFuBag:SetGrpDef(TFuInvFrame.cfg, TFuBag.G_BAR_HIDE, this.value[TFuBag.I_BAR], this.value["value"], 1);
          TFuBnkFrame:UpdateWindow();
      end,
    ["checked"] = checked
    };
      UIDropDownMenu_AddButton(info, level);
    end


    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = { ["text"] = L["Highlight new items:"], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);

    for key,value in pairs({
      [0] = L["Don't tag new items"],
      [1] = L["Tag new items"]
      }) do

      if (TFuBag:GetGrp(TFuInvFrame.cfg, TFuBag.G_USE_NEW, bar) == key) then
        checked = 1;
      else
        checked = nil;
      end

      info = {
        ["text"] = value;
        ["value"] = { [TFuBag.I_BAR]=bar, ["value"]=key };
        ["func"] = function(self)
            local this = self or _G.this
            TFuBag:SetGrpDef(TFuInvFrame.cfg, TFuBag.G_USE_NEW, this.value[TFuBag.I_BAR], this.value["value"], 1);
            TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST);
          end,
        ["checked"] = checked
        };
      UIDropDownMenu_AddButton(info, level);
    end

    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = { ["text"] = "Color:", ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);

    info = TFuBag:MakeColorPickerInfo(TFuInvFrame.cfg, "bkgr_", bar,
        string.format(L["Background Color for Bar %d"],bar), function() TFuBag:RecolorWindow(TFuInvFrame) end);
    UIDropDownMenu_AddButton(info, level);

    info = TFuBag:MakeColorPickerInfo(TFuInvFrame.cfg, "brdr_", bar,
        string.format(L["Border Color for Bar %d"],bar), function() TFuBag:RecolorWindow(TFuInvFrame) end);
    UIDropDownMenu_AddButton(info, level);

  -------------------------------------------------------------------------------------------------
  ------------------------ MAIN WINDOW CONTEXT MENU -----------------------------------------------
  -------------------------------------------------------------------------------------------------
  elseif (TFuInvFrame.RightClickMenu_mode == "mainwindow") then
    if (level == 1) then

      info = { ["text"] = string.format(L["TBag v%s"],TFuBag.VERSION), ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
      UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Select Character"];
        ["value"] = { ["opt"]="select_character" },
        ["hasArrow"] = 1
        };
      UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      -- "Manual Layout" here toggles the MODE on/off (mirrors the Options checkbox);
      -- the gear button enters/exits edit. Turning the mode off also locks (ml_edit=0).
      info = {
        ["text"] = L["Manual Layout"],
        ["value"] = nil,
        ["func"] = function()
          local c = TFuInvFrame.cfg;
          c["manual_layout"] = (c["manual_layout"] == 1) and 0 or 1;
          if (c["manual_layout"] ~= 1) then TFuInvFrame.ml_edit = 0; end
          TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST);
        end
        };
      if (TFuInvFrame.cfg["manual_layout"] == 1) then
        info["checked"] = 1;
      end
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Lock window"],
        ["value"] = nil,
        ["func"] = TFuInvFrame.Button_MoveLockToggle_OnClick
        };
      if (TFuInvFrame.cfg["moveLock"] == 0) then
        info["checked"] = 1;
      end
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Reload and Sort"],
        ["value"] = nil,
        ["func"] = TFuInvFrame.Button_Reload_OnClick
        };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Toggle Bank"],
        ["value"] = nil,
        ["func"] = TFuInvFrame.Button_ShowBank_OnClick
        };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Close Inventory"],
        ["value"] = nil,
        ["func"] = Inv.Close
        };
      UIDropDownMenu_AddButton(info, level);


      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["value"] = nil,
        ["func"] = TFuInvFrame.Button_HighlightToggle_OnClick
        };
      if (TFuBag.SrchText) then
        info["text"] = L["Clear Search"];
      else
        info["text"] = L["Highlight New Items"];
        if (TFuInvFrame.hilight_new == 1) then
          info["checked"] = 1;
        end
      end
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Reset NEW tag"],
        ["value"] = nil,
        ["func"] = function()
            local bag, slot;

            for index, bag in ipairs(TFuInvFrame.bags) do
              if (TFuInvFrame.cfg["show_Bag"..bag] == 1) then
                if (table.getn(TFuInvItm[TFuInvFrame.playerid][bag]) > 0) then
                  for slot = 1, table.getn(TFuInvItm[TFuInvFrame.playerid][bag]) do
                    TFuBag:ResetNew(TFuInvItm[TFuInvFrame.playerid][bag][slot]);
                  end
                end
              end
            end

            TFuInvFrame:UpdateWindow();
          end
        };
      UIDropDownMenu_AddButton(info, level);


      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Options"],
        ["value"] = nil,
        ["func"] = function()
            -- Modern options window, opened to General -> Inventory tab. The legacy
            -- panel (with the rule editor) stays reachable via /tinv config.
            TFuBag.ModernOpt:OpenTo("general", "inv");
          end
        };
      UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);


      info = {
        ["text"] = L["Set Size"];
        ["value"] = { ["opt"]="set_scale" },
        ["hasArrow"] = 1
        };
      UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Set Colors"];
        ["value"] = { ["opt"]="set_colors" },
        ["hasArrow"] = 1
        };
      UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Anchor"];
        ["value"] = { ["opt"]="anchor" },
        ["hasArrow"] = 1
        };
      UIDropDownMenu_AddButton(info, level);


      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Hide"];
        ["value"] = { ["opt"]="hide_frames" },
        ["hasArrow"] = 1
        };
      UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

    elseif (level == 2) then
      if (UIDROPDOWNMENU_MENU_VALUE ~= nil) then
        if (UIDROPDOWNMENU_MENU_VALUE["opt"] == "set_scale") then
          for _, value in ipairs(TFuBag.A_BUTTONSIZE) do
            info = {
              ["text"] = value.."x"..value;
              ["value"] = value;
              ["func"] = function(self)
                  local this = self or _G.this
                  if ( (type(this.value) == "number") and (this.value >= TFuBag.N_BUTTON_MIN) ) then
                    TFuInvFrame.cfg["frameButtonSize"], TFuInvFrame.cfg["count_font"],
                      TFuInvFrame.cfg["count_font_x"], TFuInvFrame.cfg["count_font_y"],
                      TFuInvFrame.cfg["scale"] = TFuBag:NicePlacement(this.value);
                      TFuInvFrame:CalcButtonSize(TFuInvFrame.cfg["frameButtonSize"], TFuInvFrame.cfg["framePad"]);
                      TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST);
                  end
                end
              };
            if (tonumber(TFuInvFrame.cfg["frameButtonSize"]*TFuInvFrame.cfg["scale"] - value)
      < 1.0) and (tonumber(TFuInvFrame.cfg["frameButtonSize"]*TFuInvFrame.cfg["scale"] - value)
      > -1.0) then
              info["checked"] = 1;
            end
            UIDropDownMenu_AddButton(info, level);
          end
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "set_colors") then
          TFuBag:MakeColorMenu(TFuInvFrame.cfg, function () TFuBag:RecolorWindow(TFuInvFrame) end, level, TFuInvFrame.bags);
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "anchor") then
          info = {
            ["text"] = L["TOPLEFT"];
            ["func"] = function ()
                         TFuBag:SetFrameAnchor (TFuInvFrame,TFuInvFrame.cfg,"TOP","LEFT")
                       end;
            };
          if (TFuInvFrame.cfg["frameXRelativeTo"] == "LEFT" and
              TFuInvFrame.cfg["frameYRelativeTo"] == "TOP") then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["TOPRIGHT"];
            ["func"] = function ()
                         TFuBag:SetFrameAnchor (TFuInvFrame,TFuInvFrame.cfg,"TOP","RIGHT")
                       end;
            };
          if (TFuInvFrame.cfg["frameXRelativeTo"] == "RIGHT" and
              TFuInvFrame.cfg["frameYRelativeTo"] == "TOP") then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["BOTTOMLEFT"];
            ["func"] = function ()
                         TFuBag:SetFrameAnchor (TFuInvFrame,TFuInvFrame.cfg,"BOTTOM","LEFT")
                       end;
            };
          if (TFuInvFrame.cfg["frameXRelativeTo"] == "LEFT" and
              TFuInvFrame.cfg["frameYRelativeTo"] == "BOTTOM") then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["BOTTOMRIGHT"];
            ["func"] = function ()
                         TFuBag:SetFrameAnchor (TFuInvFrame,TFuInvFrame.cfg,"BOTTOM","RIGHT")
                       end;
            };
          if (TFuInvFrame.cfg["frameXRelativeTo"] == "RIGHT" and
              TFuInvFrame.cfg["frameYRelativeTo"] == "BOTTOM") then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "hide_frames") then
          info = {
            ["text"] = L["Hide Player Dropdown"];
            ["func"] = TFuInvFrame.Toggle_UserDropdown;
            ["keepShownOnClick"] = 1;
            };
          if (TFuInvFrame.cfg["show_userdropdown"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Highlight Button"];
            ["func"] = TFuInvFrame.Toggle_HighlightButton;
            ["keepShownOnClick"] = 1;
            };
          if (TFuInvFrame.cfg["show_hilightbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Edit Button"];
            ["func"] = TFuInvFrame.Toggle_EditButton;
            ["keepShownOnClick"] = 1;
            };
          if (TFuInvFrame.cfg["show_editbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Bank Button"];
            ["func"] = TFuInvFrame.Toggle_BankButton;
            ["keepShownOnClick"] = 1;
            };
          if (TFuInvFrame.cfg["show_bankbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Re-sort Button"];
            ["func"] = TFuInvFrame.Toggle_ReloadButton;
            ["keepShownOnClick"] = 1;
            };
          if (TFuInvFrame.cfg["show_reloadbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Lock Button"];
            ["func"] = TFuInvFrame.Toggle_LockButton;
            ["keepShownOnClick"] = 1;
            };
          if (TFuInvFrame.cfg["show_lockbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Close Button"];
            ["func"] = TFuInvFrame.Toggle_CloseButton;
            ["keepShownOnClick"] = 1;
            };
          if (TFuInvFrame.cfg["show_closebutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Search Box"];
            ["func"] = TFuInvFrame.Toggle_SearchBox;
            ["keepShownOnClick"] = 1;
            };
          if (TFuInvFrame.cfg["show_searchbox"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Total"];
            ["func"] = TFuInvFrame.Toggle_Total;
            ["keepShownOnClick"] = 1;
            };
          if (TFuInvFrame.cfg["show_total"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Bag Buttons"];
            ["func"] = TFuInvFrame.Toggle_BagSlotButtons;
            ["keepShownOnClick"] = 1;
            };
          if (TFuInvFrame.cfg["show_bagbuttons"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Tokens"];
            ["func"] = TFuInvFrame.Toggle_Token;
            ["keepShownOnClick"] = 1;
            };
          if (TFuInvFrame.cfg["show_tokens"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Money"];
            ["func"] = TFuInvFrame.Toggle_Money;
            ["keepShownOnClick"] = 1;
            };
          if (TFuInvFrame.cfg["show_money"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "select_character") then
          TFuInvFrame.UserDropdown_Initialize(self, level);
        end
      end
    end
  end
  TFuBag:FixMenuFrameLevels()
end


-- Main "right click menu"
function Inv:RightClickMenu_OnLoad()
  UIDropDownMenu_Initialize(self, Inv.RightClickMenu_populate, "MENU");
end


Inv.WindowIsUpdating = 0;

-- Exception-safe reentrancy guard. The body runs under pcall so a Lua error
-- (e.g. a transient nil during a bank<->warband transition) can no longer skip
-- the `WindowIsUpdating = 0` reset and wedge the window -- the old failure where
-- the inventory froze on a stale render (deposit dim / greyscale stuck as a
-- "cached" view) and every later UpdateWindow no-oped until /reload. The error is
-- still surfaced via the standard handler so the underlying cause stays diagnosable.
function Inv:UpdateWindow(resort_req)
  TFuBag:PrintDEBUG("TFuInv_UpdateWindow:  WindowIsUpdating="..Inv.WindowIsUpdating );
  if (Inv.WindowIsUpdating == 1) then
    return;
  end
  Inv.WindowIsUpdating = 1;
  local ok, err = pcall(Inv.UpdateWindowBody, self, resort_req);
  Inv.WindowIsUpdating = 0;
  if (not ok) then geterrorhandler()(err); end
end

function Inv:UpdateWindowBody(resort_req)
  local frame = TFuInvFrame;
  local barnum;

  if ( not frame:IsVisible() ) then
    return;
  end

--  UpdateAddOnMemoryUsage();
--  TFuBag:PrintDEBUG('TFuInv_UpdateWindow Start Memory = '..tostring(GetAddOnMemoryUsage("TFuBag")));

  -- Set the overall scale
  self:SetScale(self.cfg["scale"]);

  -- Consume a message from updated craft info
  if (TFuBagCfg["trades_changed"] == 1) then
    resort_req = TFuBag.REQ_MUST;
  end
  TFuBagCfg["trades_changed"] = nil;

  -- Setup stackarr and comparr
  local stackarr = TFuBag:CreateStackArr();
  local comparr = TFuBag:CreateCompArr();

  -- SORTING and ITEMCACHE
  if (resort_req == nil) then resort_req = TFuBag.REQ_NONE; end
  -- config/category/profession change forced this sort (explicit REQ_MUST):
  -- recategorize everything. An item-move-driven sort (REQ_NONE here, MUST only
  -- after cache_req is added) instead recats just the changed slots.
  local force_full = (resort_req >= TFuBag.REQ_MUST)
  local cache_req = TFuBag:UpdateItmCache(self.cfg, self.playerid, TFuInvItm[self.playerid], self.bags,stackarr,comparr);
  if (resort_req == TFuBag.REQ_PART) then
    resort_req = resort_req + self.CACHE_REQ;
  end
  resort_req = resort_req + cache_req;

  -- Consume a message for bag stacking
  if (self.cfg["stack_once"] == 1) then
    if (self.playerid == TFuBag.PLAYERID) then
      if TFuBag:Stack(TFuBag.STACK_INV, TFuInvItm[self.playerid], stackarr, comparr) then
        self.cfg["stack_once"] = nil
      end
    end
  end

  if (resort_req >= TFuBag.REQ_MUST) then
    if (force_full) then TFuBag:BumpCatGen() end
    self.CACHE_REQ = TFuBag.REQ_NONE
    self.BARITM = TFuBag:SortItmCache(self.cfg,
      self.playerid, TFuInvItm[self.playerid], self.BARITM, self.bags);
    TFuBag:LayoutWindow(self)
    self.sortGen = TFuBag.catGen   -- mark categorization current (OnShow dirty check)
  elseif (self.force_resort) then
    -- Item-filter toggle: rebuild bar placement (so PassesItemFilter is re-applied)
    -- and relayout, but WITHOUT a catGen bump -- the filter reads cached item fields,
    -- so a full per-item tooltip recat is unnecessary and would lag a large view.
    -- SortItmCache still recats any individually-stale slot, so the deferred-resort
    -- debt is paid; clear it like the REQ_MUST branch.
    self.CACHE_REQ = TFuBag.REQ_NONE
    self.BARITM = TFuBag:SortItmCache(self.cfg,
      self.playerid, TFuInvItm[self.playerid], self.BARITM, self.bags);
    TFuBag:LayoutWindow(self)
    self.sortGen = TFuBag.catGen
  else if (cache_req > self.CACHE_REQ) then
      self.CACHE_REQ = cache_req
    end
  end
  self.force_resort = nil

  -- Relink the button map. A cached character (selected from the dropdown) may not
  -- have every bag in its cache, so guard the per-bag table -- otherwise switching
  -- to such a character indexes a nil bag and errors. (SortItmCache above already
  -- tolerates missing bags.)
  local pcache = TFuInvItm[self.playerid];
  for _,bag in ipairs(self.bags) do
    local pbag = pcache and pcache[bag];
    for slot = 1, TFuBag:GetBagMaxItems(bag) do
      TFuBag.BUTTONS[TFuBag:GetBagItemButtonName(bag, slot)] = pbag and pbag[slot] or nil;
    end
  end

  -- BAGS, to get bag sizes below
  self:UpdateBagGfx();

  -- Update all the buttons
  for _, bag in ipairs(self.bags) do
    local size = TFuBag:GetPlayerBagCfg(self.playerid, bag, TFuBag.I_BAGSIZE);
    if (not size) then size = 0; end
    local bagframe = TFuBag:GetBagFrame(bag);
    if (self.cfg["show_Bag"..bag] ~= 1 and not (bagframe and bagframe:GetChecked())) then
      size = 0;
    end
    for slot = 1, size do
      TFuBag.ItemButton.Update(_G[TFuBag:GetBagItemButtonName(bag, slot)])
    end
    for slot = size+1, TFuBag:GetBagMaxItems(bag) do
      _G[TFuBag:GetBagItemButtonName(bag, slot)]:Hide();
    end
  end

  -- MONEY
  if (self.cfg["show_money"] == 1) then
    local type = "STATIC"
    if (self.playerid == TFuBag.PLAYERID) then
      type = "PLAYER"
    end
    MoneyFrame_SetType(TFuInvFrame_MoneyFrame,type)
    MoneyFrame_Update("TFuInvFrame_MoneyFrame", TFuBag:GetMoney(self.playerid));
  end

    -- Don't snap the frame back to its saved cfg corner while the user is
    -- mid-drag (StartMoving is binding it to the cursor). The WowScrollBox's
    -- managed-visibility / size callbacks can fire UpdateWindow while the bag
    -- is being moved -- without this guard, every callback re-anchors the
    -- frame to the OLD position and the bag "snaps back, leaves cursor behind."
    if (not self.isMoving) then
      frame:ClearAllPoints();
      frame:SetPoint(self.cfg["frameYRelativeTo"]..self.cfg["frameXRelativeTo"],
        "UIParent", "BOTTOMLEFT",
        self.cfg["frame"..self.cfg["frameXRelativeTo"]] / frame:GetScale(),
        self.cfg["frame"..self.cfg["frameYRelativeTo"]] / frame:GetScale());
    end


    TFuBag:ColorFrame(self.cfg, frame, TFuBag.MAIN_BAR);

    if (self.edit_mode == 1) then
      TFuInvFrame_ColumnsAdd:Show();
      TFuInvFrame_ColumnsDel:Show();
    else
      TFuInvFrame_ColumnsAdd:Hide();
      TFuInvFrame_ColumnsDel:Hide();
    end

    -- Manual Layout toggle button shows a green glow around it when on.
    local mlbtn = TFuInv_Button_ChangeEditMode;
    if (not mlbtn.MLGlow) then
      mlbtn.MLGlow = mlbtn:CreateTexture(nil, "OVERLAY");
      mlbtn.MLGlow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border");
      mlbtn.MLGlow:SetBlendMode("ADD");
      mlbtn.MLGlow:SetVertexColor(0, 1, 0);  -- green
      mlbtn.MLGlow:SetPoint("CENTER", mlbtn, "CENTER", 0, 0);
      local w, h = mlbtn:GetSize();
      mlbtn.MLGlow:SetSize((w or 20) * 1.7, (h or 20) * 1.7);
    end
    -- Glow reflects whether the gear is in its ACTIVE/editing state: classic edit_mode
    -- under Legacy Edit, else the Manual Layout edit/unlock (ml_edit). Manual layout
    -- being active is persistent and shown via the menu/options checkbox, not the glow.
    local edit_active;
    if (self.cfg["legacy_edit"] == 1) then
      edit_active = (self.edit_mode == 1);
    else
      edit_active = (self.ml_edit == 1);
    end
    if (edit_active) then
      mlbtn.MLGlow:Show();
      mlbtn:SetAlpha(1.0);
    else
      mlbtn.MLGlow:Hide();
      mlbtn:SetAlpha(0.4);  -- faded when off
    end

  self:SetButton_Anchors();

  TFuBag:UpdateFreeSlotsCell(TFuInvFrame);

--  UpdateAddOnMemoryUsage();
--  TFuBag:PrintDEBUG('TFuInv_UpdateWindow End Memory = '..tostring(GetAddOnMemoryUsage("TFuBag")));
end

function Inv.UserDropdown_OnLoad(self)
  UIDropDownMenu_Initialize(self, Inv.UserDropdown_Initialize);
  UIDropDownMenu_SetSelectedValue(self, TFuInvFrame.playerid);
  self.tooltip = L["You are viewing the selected player's inventory."];
  UIDropDownMenu_SetWidth(self,TFuBag.USERDD_WIDTH)
  -- UIDropDownMenu_SetWidth actually adds 50 to our width, we really only want
  -- 25 to avoid the control running into our buttons on the right.
  self:SetWidth(TFuBag.USERDD_WIDTH+25);
--  OptionsFrame_EnableDropDown(self);
end

function Inv.UserDropdown_OnClick(self)
  local this = self or _G.this
  UIDropDownMenu_SetSelectedValue(TFuInv_UserDropdown, this.value);
  if ( this.value ) then
    TFuInvFrame:SetPlayer(this.value);
  end
  if ( not TFuInvFrame.playerid ) then
    TFuBag:PrintDEBUG("TFuInv_UserDropdown_OnClick Failed");
    return;
  end
  TFuBag:PrintDEBUG("Selected Player "..TFuInvFrame.playerid);

  TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST);
end

function Inv.UserDropdown_Initialize(self, level)
  TFuBag:UserDropdown_Init(Inv.UserDropdown_OnClick,
    TFuInvItm, TFuInvFrame.playerid,TFuBag.REALM,level);
end

