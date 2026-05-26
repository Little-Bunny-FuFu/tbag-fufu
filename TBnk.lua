-- $Id$

local _G = getfenv(0)
local TFuBag = _G.TFuBag
TFuBag.Bank = {}
local Bank = TFuBag.Bank

local BankFrame_Saved = nil;

-- Localization Support
local L = TFuBag.LOCALE;

BINDING_NAME_TFuBNK_TOGGLE = L["Toggle Bank Window"];

-- Constants
TFuBnk_SHOWITEMDEBUGINFO = 0;
local TFuBnk_WIPECONFIGONLOAD = 0; -- for debugging, test it out on a new config every load


------------------------

function Bank:CalcButtonSize(newsize, pad)
  local k = "button_size_opts";
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

function Bank:SetDefPos(cfg, reset)
  TFuBag:SetDef(cfg, "frameLEFT", UIParent:GetRight() * UIParent:GetScale() * 0.294, reset, TFuBag.NumFunc);
  TFuBag:SetDef(cfg, "frameRIGHT", UIParent:GetRight() * UIParent:GetScale() * 0.684, reset, TFuBag.NumFunc);
  TFuBag:SetDef(cfg, "frameTOP", UIParent:GetTop() * UIParent:GetScale() * 0.83, reset, TFuBag.NumFunc);
  TFuBag:SetDef(cfg, "frameBOTTOM", UIParent:GetTop() * UIParent:GetScale() * 0.232, reset, TFuBag.NumFunc);
  TFuBag:SetDef(cfg, "frameXRelativeTo", "LEFT", reset, TFuBag.StrFunc, {"RIGHT","LEFT"} );
  TFuBag:SetDef(cfg, "frameYRelativeTo", "BOTTOM", reset, TFuBag.StrFunc, {"TOP","BOTTOM"} );
end

function Bank:InitDefVals(reset)
  local i, key, value;
  local cfg = self.cfg;

  TFuBag:InitDefVals(cfg, self.bags, 4, reset);

  TFuBag:SetDef(cfg, "maxColumns", 14, reset, TFuBag.NumFunc, TFuBag.NUMCOL_MIN,TFuBag.NUMCOL_MAX);

  TFuBag:SetDef(cfg, "show_purchase_button", 0, reset, TFuBag.NumFunc, 0, 1);
  TFuBag:SetDef(cfg, "show_purchasetoggle", 1, reset, TFuBag.NumFunc, 0, 1);

  -- Colors
  TFuBag:SetColor(cfg, "bkgr_"..TFuBag.MAIN_BAR, 0.3, 0.1, 0.0, 0.4, reset);
  TFuBag:SetColor(cfg, "brdr_"..TFuBag.MAIN_BAR, 0.7, 0.1, 0.1, 0.3, reset);
  for i = 1, TFuBag.BAR_MAX do
    TFuBag:SetColor(cfg, "bkgr_"..i, 0.3, 0.1, 0.0, 0.4, reset);
    TFuBag:SetColor(cfg, "brdr_"..i, 0.7, 0.1, 0.1, 0.3, reset);
  end
  TFuBag:SetDefColors(cfg, reset);

  self:SetDefPos(cfg, reset);

end

function Bank:SetPlayer(playerid)
  if self.playerid ~= playerid then
    self.CACHE_REQ = TFuBag.REQ_MUST
  end
  self.playerid = playerid;
  TFuBag.Tokens.Update(TFuBnkFrame_TokenFrame)
end

-- Set reset=1 to restore default values
function Bank:init(reset)
  if not Bank.metatabledone then
    setmetatable(TFuBag.MainFrame, getmetatable(TFuBnkFrame))
    setmetatable(TFuBag.Bank,{__index=TFuBag.MainFrame})
    setmetatable(TFuBnkFrame,{__index=TFuBag.Bank})
    Bank.metatabledone = true
  end
  self = TFuBnkFrame
  self:SetUserPlaced(false) -- remove us from the layout-cache

  -- Bank switching
  self.playerid = "";
  self.atbank = 0;
  self.bags = TFuBag.Bnk_Bags

  self.CACHE_REQ = TFuBag.REQ_NONE

  self.cfg = nil;
  self.BARITM = {};
  self.hilight_new = 0;
  self.edit_mode = 0;
  self.edit_hilight = "";         -- when editmode is 1, which items do you want to hilight
  self.edit_selected = "";        -- when editmode is 1, this is the class of item you clicked on
  self.RightClickMenu_mode = "";
  self.RightClickMenu_opts = {};
  self.RightClickMenu = TFuBnkFrame_RightClickMenu

  self.BC_LIST = {};  -- Bar to Class list

  self.BF_X_PAD = 1;
  self.BF_Y_PAD = 1;
  self.BF_WIDTH = 34;
  self.BF_HEIGHT = 34;
  self.BF_PADWIDTH = 36;
  self.BF_PADHEIGHT = 36;
  self.BGF_WIDTH = 38;
  self.BGF_HEIGHT = 38;


  TFuBag:Init();

  self.cfg = TFuBagCfg["Bnk"]
  local cfg = self.cfg
  self.atbank = 0

  if ( TFuBnk_WIPECONFIGONLOAD == 1 ) then
    cfg = {};
  end

  self:SetPlayer(TFuBag.PLAYERID);

  -- Make all the frames
  for _, bag in ipairs(self.bags) do
--    if (bag == BANK_CONTAINER) then
--      TFuBag:CreateDummyBag(bag, "TFuBnk_BankItemButtonTemplate");
--    else
      TFuBag:CreateDummyBag(bag, "TFuBag_ItemButtonTemplate");
--    end
  end

  TFuBag:CreateFrame("Frame", "TFuBnkFrame_bar_", TFuBnkFrame,
    "TFuBag_BarFrameTemplate", TFuBag.BAR_MAX, "");
  TFuBag:CreateFrame("Button", "TFuBnkFrame_BarButton_", TFuBnkFrame,
    "TFuBag_BarButtonTemplate", TFuBag.BAR_MAX, "");

  -- register slash command
  SlashCmdList["TFuBnk"] = TFuBnk_cmd;
  SLASH_TFuBnk1 = "/tbnk";

  -- load default values
  self:InitDefVals(reset);

  self:CalcButtonSize(cfg["frameButtonSize"], cfg["framePad"]);

  for _, bag in ipairs(self.bags) do
    TFuBag:GetBagFrame(bag):SetScale(0.7);
  end
  self:InitBagGfx()

  self:SetReplaceBank();

  if (cfg["moveLock"] == 0) then
    TFuBnkLockNorm:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Locked-Up");
    TFuBnkLockPush:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Locked-Down");
  else
    TFuBnkLockNorm:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Unlocked-Up");
    TFuBnkLockPush:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Unlocked-Down");
  end

  if (cfg["show_bagbuttons"] == 0) then
    TFuBnkFrameBag1:Hide();
    TFuBnkFrameBag2:Hide();
    TFuBnkFrameBag3:Hide();
    TFuBnkFrameBag4:Hide();
    TFuBnkFrameBag5:Hide();
    TFuBnkFrameBag6:Hide();
    TFuBnkFrameBag7:Hide();
    TFuBnkFrameBagBank:Hide();
    TFuBnkFrameBagReagent:Hide();
  end
  if (cfg["show_userdropdown"] == 0) then
    TFuBnk_UserDropdown:Hide();
  end
  if (cfg["show_reloadbutton"] == 0) then
    TFuBnk_Button_Reload:Hide();
  end
  if (cfg["show_editbutton"] == 0) then
    TFuBnk_Button_ChangeEditMode:Hide();
  end
  if (cfg["show_hilightbutton"] == 0) then
    TFuBnk_Button_HighlightToggle:Hide();
  end
  if (cfg["show_lockbutton"] == 0) then
    TFuBnk_Button_MoveLockToggle:Hide();
  end
  if (cfg["show_closebutton"] == 0) then
    TFuBnk_Button_Close:Hide();
  end
  if (cfg["show_total"] == 0) then
    TFuBnkFrame_Total:Hide();
  end
  if (cfg["show_money"] == 0) then
    TFuBnkFrame_MoneyFrame:Hide();
  end
  if (cfg["show_tokens"] == 0) then
    TFuBnkFrame_TokenFrame:Hide();
  end

  TFuBag:BuildBarClassList(self.BC_LIST, cfg);

  -- Do one sorting to init the baritm array
  self.BARITM = TFuBag:SortItmCache(cfg,
    self.playerid, TFuBnkItm[self.playerid], self.BARITM, self.bags);
  TFuBag:LayoutWindow(self)
end

function Bank:UpdateDepositButton()
  if (self.atbank == 1 and self.cfg["show_depositbutton"] == 1 and TFuBag:IsReagentBankUnlocked(self.playerid)) then
    TFuBnk_Button_DepositReagent:Show()
  else
    TFuBnk_Button_DepositReagent:Hide()
  end
end

function Bank:UpdateBagGfx()
  local i;
  local bag = BANK_CONTAINER;
  local numSlots, _ = TFuBag:GetNumBankSlots(self.playerid);
  local free, size = TFuBag:UpdateSlots(self.playerid, bag, self.cfg["show_bag_sizes"]);
  local totalfree = free;
  local totalsize = size;

  TFuBag:UpdateBagColors(bag);
  TFuBag:SetPlayerBagCfg(self.playerid, bag, TFuBag.I_ITEMLINK, nil);

  bag = REAGENTBANK_CONTAINER;
  if TFuBag:IsReagentBankUnlocked(self.playerid) then
    SetItemButtonTextureVertexColor(TFuBnkFrameBagReagent, 1.0, 1.0, 1.0, 1.0);
  else
    SetItemButtonTextureVertexColor(TFuBnkFrameBagReagent, 1.0, 0.1, 0.1, 1.0);
  end
  free, size = TFuBag:UpdateSlots(self.playerid, bag, self.cfg["show_bag_sizes"]);
  TFuBag:UpdateBagColors(bag);
  totalfree = totalfree + free;
  totalsize = totalsize + size;

  for i=1, numSlots do
    bag = i + 4;
    local type = TFuBag:GetBagType(self.playerid, bag); -- needed for cacheing
    TFuBag:GetBagFrameTexture(bag):SetVertexColor(1.0,1.0,1.0, 1.0);
  end
  for i=numSlots+1, NUM_BANKBAGSLOTS do
    bag = i + 4;
    TFuBag:SetPlayerBagCfg(self.playerid, bag, TFuBag.I_BAGTYPE, 0);
    TFuBag:SetPlayerBagCfg(self.playerid, bag, TFuBag.I_BAGFREE, 0);
    TFuBag:SetPlayerBagCfg(self.playerid, bag, TFuBag.I_BAGSIZE, 0);
    TFuBag:SetPlayerBagCfg(self.playerid, bag, TFuBag.I_ITEMLINK, nil);
    TFuBag:GetBagFrameTexture(bag):SetVertexColor(1.0,0.1,0.1, 1.0);
  end
  for i=1, NUM_BANKBAGSLOTS do
    bag = i + 4;

    TFuBag:UpdateBagColors(bag);

    TFuBag:GetBagFrameTexture(bag):SetTexture(
      TFuBag:GetBagTexture(self.playerid, bag));

    local free, size = TFuBag:UpdateSlots(self.playerid, bag, self.cfg["show_bag_sizes"]);

    totalfree = totalfree + free;
    totalsize = totalsize + size;
  end
  TFuBag:SetFreeStr(TFuBnkFrame_TotalText, totalfree, totalsize, self.cfg["show_bag_sizes"]);
end

function Bank:InitBagGfx()
  local numSlots, _ = TFuBag:GetNumBankSlots(self.playerid);

  -- Spoof the bank
  local button = TFuBnkFrameBagBank;
  SetItemButtonTextureVertexColor(button, 1.0,1.0,1.0, 1.0);
  TFuBag:GetBagFrameTexture(BANK_CONTAINER):SetTexture(
        TFuBag:GetBagTexture(TFuBnkFrame.playerid, BANK_CONTAINER));
  TFuBag:GetBagFrameTexture(REAGENTBANK_CONTAINER):SetTexture(
        TFuBag:GetBagTexture(TFuBnkFrame.playerid, REAGENTBANK_CONTAINER));


  for i=1, NUM_BANKBAGSLOTS do
    button = _G["TFuBnkFrameBag"..i];
    if ( button ) then
      if ( i <= numSlots ) then
        SetItemButtonTextureVertexColor(button, 1.0,1.0,1.0, 1.0);
        button.tooltipText = BANK_BAG;
      else
        SetItemButtonTextureVertexColor(button, 1.0,0.1,0.1, 1.0);
        button.tooltipText = BANK_BAG_PURCHASE;
      end
    end
  end
end


function Bank.Button_HighlightToggle_OnClick(self)
  PlaySound(PlaySoundKitID and "igMainMenuOptioncheckBoxOn" or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
  if (TFuBag.SrchText) then
    TFuBag:ClearSearch();
    if (GameTooltip:GetOwner() == TFuBnk_Button_HighlightToggle) then
      if (TFuBnkFrame.highlight_new == 1) then
        GameTooltip_AddNewbieTip(self, L["Normal"], 1.0, 1.0, 1.0,
                                 L["Stop highlighting new items."]);
      else
        GameTooltip_AddNewbieTip(self, L["Highlight New"], 1.0, 1.0, 1.0,
                                 L["Highlight items marked as new."]);
      end
    end
    return;
  elseif (TFuBnkFrame.hilight_new == 0) then
    TFuBnkFrame.hilight_new = 1;
    if (GameTooltip:GetOwner() == TFuBnk_Button_HighlightToggle) then
      GameTooltip_AddNewbieTip(self, L["Normal"], 1.0, 1.0, 1.0,
                               L["Stop highlighting new items."]);
    end
  else
    TFuBnkFrame.hilight_new = 0;
    if (GameTooltip:GetOwner() == TFuBnk_Button_HighlightToggle) then
      GameTooltip_AddNewbieTip(self, L["Highlight New"], 1.0, 1.0, 1.0,
                               L["Highlight items marked as new."]);
    end
  end
  TFuBnkFrame:UpdateWindow();
end

function Bank.Button_ChangeEditMode_OnClick()
  PlaySound(PlaySoundKitID and "igMainMenuOptioncheckBoxOn" or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
  if (TFuBnkFrame.edit_mode == 0) then
    TFuBnkFrame.edit_mode = 1;
  else
    TFuBnkFrame.edit_mode = 0;
  end

  -- resort will force a window redraw
  TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
end

function Bank.Button_Reload_OnClick()
  -- To avoid cleaning the bank cache, you only can reload bags at bank.
  if (TFuBnkFrame.atbank==1) then
    -- Hell, let's be paranoid
    if (TFuBnkFrame.playerid == TFuBag.PLAYERID) then
      TFuBag:ClearItmCache(TFuBnkItm[TFuBnkFrame.playerid], TFuBnkFrame.bags);
      TFuBag:ClearStackSkip(TFuBnkFrame.bags);
      TFuBag:ClearCompSkip(TFuBnkFrame.bags);

      -- Send a message to restack
      if (TFuBnkFrame.cfg["stack_resort"] == 1) then
        TFuBnkFrame.cfg["stack_once"] = 1;
      end
    end
  end

  TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
  TFuBag:PrintDEBUG("TFuBnk reloaded.");
end

function Bank.Button_DepositReagent_OnClick()
  DepositReagentBank()
end

function Bank.Button_MoveLockToggle_OnClick(self)
  PlaySound(PlaySoundKitID and "igMainMenuOptioncheckBoxOn" or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
  if (TFuBnkFrame.cfg["moveLock"] == 0) then
    TFuBnkFrame.cfg["moveLock"] = 1;
    TFuBnkLockNorm:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Unlocked-Up");
    TFuBnkLockPush:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Unlocked-Down");
    if (GameTooltip:GetOwner() == TFuBnk_Button_MoveLockToggle) then
      GameTooltip_AddNewbieTip(self, L["Lock Window"], 1.0, 1.0, 1.0,
                               L["Prevent window from being moved by dragging it."]);
    end
  else
    TFuBnkFrame.cfg["moveLock"] = 0;
    TFuBnkLockNorm:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Locked-Up");
    TFuBnkLockPush:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Locked-Down");
    if (GameTooltip:GetOwner() == TFuBnk_Button_MoveLockToggle) then
      GameTooltip_AddNewbieTip(self, L["Unlock Window"], 1.0, 1.0, 1.0,
                               L["Allow window to be moved by dragging it."]);
    end
  end
end

function Bank.SlotTargetButton_OnClick(self, button)
  local bar, tmp;

  if (TFuBnkFrame.edit_mode == 1) then
  for tmp in string.gmatch(self:GetName(), "TFuBnkFrame_SlotTarget_(%d+)") do
    bar = tonumber(tmp);
  end

  if ( (bar == nil) or (bar < 1) or (bar > TFuBag.BAR_MAX) ) then
    return;
  end

  if ( button == "LeftButton" ) then
    if (TFuBnkFrame.edit_selected ~= "") then
  -- we got a click, and we already had one selected.  let's move the items
  TFuBag:SetCatBar(TFuBnkFrame.cfg, TFuBnkFrame.edit_selected, bar, 1);

  TFuBnkFrame.edit_selected = "";
  TFuBnkFrame.edit_hilight = "";

  TFuBag:BuildBarClassList(TFuBnkFrame.BC_LIST, TFuBnkFrame.cfg);

    -- resort will force a window redraw as well
      TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
    end

  elseif ( button == "RightButton" ) then
    HideDropDownMenu(1);
    TFuBnkFrame.RightClickMenu_mode = "bar";
    TFuBnkFrame.RightClickMenu_opts = {
  [TFuBag.I_BAR] = bar
  };
    ToggleDropDownMenu(1, nil, TFuBnkFrame_RightClickMenu, self:GetName(), -50, 0);

  end
  end
end

function Bank.RightClick_DeleteItemOverride(self)
  local bag, slot, itm;
  local this = self or _G.this

  bag = this.value[TFuBag.I_BAG];
  slot = this.value[TFuBag.I_SLOT];

  if ( (bag ~= nil) and (slot ~= nil) ) then
  itm = TFuBnkItm[TFuBnkFrame.playerid][bag][slot];

  if (itm[TFuBag.I_ITEMLINK] ~= nil) then
    local id = TFuBag:GetItemID(itm[TFuBag.I_ITEMLINK]);
    if TFuBnkFrame.cfg["item_overrides"][id] ~= nil then
      TFuBnkFrame.cfg["item_overrides"][id] = nil;
      HideDropDownMenu(1);

      -- resort will force a window redraw as well
      TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
    end
  end
  end
end

function Bank.RightClick_SetItemOverride(self)
  local bag, slot, itm, new_barclass;
  local this = self or _G.this

  bag = this.value[TFuBag.I_BAG];
  slot = this.value[TFuBag.I_SLOT];
  new_barclass = this.value["barclass"];

  if ( (bag ~= nil) and (slot ~= nil) and (new_barclass ~= nil) ) then
  itm = TFuBnkItm[TFuBnkFrame.playerid][bag][slot];

  TFuBnkFrame.cfg["item_overrides"][TFuBag:GetItemID(itm[TFuBag.I_ITEMLINK])] = new_barclass;
  HideDropDownMenu(2);
  HideDropDownMenu(1);

  TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
  end
end

function Bank:SetTopLeftButton_Anchors()
  local buttons = {
    "TFuBnk_Button_HighlightToggle",
    "TFuBnk_Button_ChangeEditMode",
    "TFuBnk_Button_Reload",
    "TFuBnk_Button_DepositReagent",
  };
  local button_left = nil;

  -- Handle user dropdown list separately...
  local dropdown = TFuBnk_UserDropdown;
  if (dropdown and dropdown:IsVisible()) then
    dropdown:ClearAllPoints();
    dropdown:SetPoint("TOPLEFT",TFuBnkFrame,"TOPLEFT",-10,-5);
    button_left = dropdown;
  end

  for _,button_name in ipairs(buttons) do
    button = _G[button_name];
    if (button) then
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
        button:SetPoint("TOPLEFT",TFuBnkFrame,"TOPLEFT",9,-8);
      end
      if (button:IsVisible()) then
        button_left = button;
      end
    end
  end
end

function Bank:SetTopRightButton_Anchors()
  local buttons = {
    "TFuBnk_Button_Close",
    "TFuBnk_Button_MoveLockToggle",
  }
  local button_right = nil;

  for _,button_name in ipairs(buttons) do
    local button = _G[button_name];
    if (button) then
      if (button_right) then
        button:SetPoint("TOPRIGHT",button_right,"TOPLEFT",10,0);
      else
        button:SetPoint("TOPRIGHT",TFuBnkFrame,"TOPRIGHT",0,0);
      end
      if (button:IsVisible()) then
        button_right = button;
      end
    end
  end
end

function Bank:SetBottomLeftButton_Anchors()
  local buttons = {
    "TFuBnkFrame_Total",
    "TFuBnkFrameBagBank",
  }
  local button_left = nil;

  for _,button_name in ipairs(buttons) do
    button = _G[button_name];
    if (button) then
      button:ClearAllPoints();
      if (button_left) then
        -- button following another button
        button:SetPoint("BOTTOMLEFT",button_left,"BOTTOMRIGHT",3,-1);
      else
        -- First button
        local y = 12;
        if (self.edit_mode == 1) then
          y = y + 30;
        end
        button:SetPoint("BOTTOMLEFT",TFuBnkFrame,"BOTTOMLEFT",10,y);
      end
      if (button:IsVisible()) then
        button_left = button;
      end
    end
  end

  -- Figure the number of columns needed to require the bag buttons
  -- to be split into two rows
  local bags_row = 0;
  if (TFuBnkFrameBagBank:IsVisible()) then
    bags_row = bags_row + 5;
  end
  if (TFuBnkFrame_Total:IsVisible()) then
    bags_row = bags_row + 1;
  end
  if TFuBnkFrame_MoneyFrame:IsVisible() or TFuBnkFrame_TokenFrame:IsVisible() then
    bags_row = bags_row + 4;
  end

  if (self.cfg["maxColumns"] <= bags_row) then
    TFuBnkFrameBag4:ClearAllPoints()
    TFuBnkFrameBag4:SetPoint("BOTTOMLEFT",TFuBnkFrameBagBank,"TOPLEFT",0,3);
  else
    -- Now separate row required
    TFuBnkFrameBag4:ClearAllPoints()
    TFuBnkFrameBag4:SetPoint("BOTTOMLEFT",TFuBnkFrameBag3,"BOTTOMRIGHT",3,0);
  end

end

function Bank:SetBottomRightButton_Anchors()
  local buttons = {
    "TFuBnkFrame_MoneyFrame",
    "TFuBnkFrame_TokenFrame",
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
        if self.edit_mode == 1 then
          y = y + 30
        end
        button:SetPoint("BOTTOMRIGHT",TFuBnkFrame,"BOTTOMRIGHT",5,y)
      end
      if button:IsVisible() then
        button_right = button
      end
    end
  end
end

function Bank:SetButton_Anchors()
  self:SetTopLeftButton_Anchors();
  self:SetTopRightButton_Anchors();
  self:SetBottomLeftButton_Anchors();
  self:SetBottomRightButton_Anchors();
  TFuBag:LayoutWindow(self)
end


function Bank.Toggle_CloseButton()
  if (TFuBnkFrame.cfg["show_closebutton"] == 1) then
    TFuBnkFrame.cfg["show_closebutton"] = 0;
    TFuBnk_Button_Close:Hide();
    TFuBnkFrame:SetButton_Anchors();
  else
    TFuBnkFrame.cfg["show_closebutton"] = 1;
    TFuBnk_Button_Close:Show();
    TFuBnkFrame:SetButton_Anchors();
  end
end

function Bank.Toggle_LockButton()
  if (TFuBnkFrame.cfg["show_lockbutton"] == 1) then
    TFuBnkFrame.cfg["show_lockbutton"] = 0;
    TFuBnk_Button_MoveLockToggle:Hide();
    TFuBnkFrame:SetButton_Anchors();
  else
    TFuBnkFrame.cfg["show_lockbutton"] = 1;
    TFuBnk_Button_MoveLockToggle:Show();
    TFuBnkFrame:SetButton_Anchors();
  end
end

function Bank.Toggle_HighlightButton()
  if (TFuBnkFrame.cfg["show_hilightbutton"] == 1) then
    TFuBnkFrame.cfg["show_hilightbutton"] = 0;
    TFuBnk_Button_HighlightToggle:Hide();
    TFuBnkFrame:SetButton_Anchors();
  else
    TFuBnkFrame.cfg["show_hilightbutton"] = 1;
    TFuBnk_Button_HighlightToggle:Show();
    TFuBnkFrame:SetButton_Anchors();
  end
end

function Bank.Toggle_EditButton()
  if (TFuBnkFrame.cfg["show_editbutton"] == 1) then
    TFuBnkFrame.cfg["show_editbutton"] = 0;
    TFuBnk_Button_ChangeEditMode:Hide();
    TFuBnkFrame:SetButton_Anchors();
  else
    TFuBnkFrame.cfg["show_editbutton"] = 1;
    TFuBnk_Button_ChangeEditMode:Show();
    TFuBnkFrame:SetButton_Anchors();
  end
end

function Bank.Toggle_ReloadButton()
  if (TFuBnkFrame.cfg["show_reloadbutton"] == 1) then
    TFuBnkFrame.cfg["show_reloadbutton"] = 0;
    TFuBnk_Button_Reload:Hide();
    TFuBnkFrame:SetButton_Anchors();
  else
    TFuBnkFrame.cfg["show_reloadbutton"] = 1;
    TFuBnk_Button_Reload:Show();
    TFuBnkFrame:SetButton_Anchors();
  end
end

function Bank.Toggle_DepositReagentButton()
  if (TFuBnkFrame.cfg["show_depositbutton"] == 1) then
    TFuBnkFrame.cfg["show_depositbutton"] = 0;
    TFuBnk_Button_DepositReagent:Hide();
    TFuBnkFrame:SetButton_Anchors();
  else
    TFuBnkFrame.cfg["show_depositbutton"] = 1;
    if (TFuBnkFrame.atbank == 1 and TFuBag:IsReagentBankUnlocked(TFuBnkFrame.playerid)) then
      TFuBnk_Button_DepositReagent:Show();
      TFuBnkFrame:SetButton_Anchors();
    end
  end
end

function Bank.Toggle_UserDropdown()
  if (TFuBnkFrame.cfg["show_userdropdown"] == 1) then
    TFuBnkFrame.cfg["show_userdropdown"] = 0;
    TFuBnk_UserDropdown:Hide();
    TFuBnkFrame:SetButton_Anchors();
  else
    TFuBnkFrame.cfg["show_userdropdown"] = 1;
    TFuBnk_UserDropdown:Show();
    TFuBnkFrame:SetButton_Anchors();
  end
end

function Bank.Toggle_Money()
  if (TFuBnkFrame.cfg["show_money"] == 1) then
    TFuBnkFrame.cfg["show_money"] = 0;
    TFuBnkFrame_MoneyFrame:Hide();
    TFuBnkFrame:SetButton_Anchors();
  else
    TFuBnkFrame.cfg["show_money"] = 1;
    TFuBnkFrame_MoneyFrame:Show();
    TFuBnkFrame:SetButton_Anchors();
  end
end

function Bank.Toggle_Token()
  if (TFuBnkFrame.cfg["show_tokens"] == 1) then
    TFuBnkFrame.cfg["show_tokens"] = 0;
    TFuBnkFrame_TokenFrame:Hide();
    TFuBnkFrame:SetButton_Anchors();
  else
    TFuBnkFrame.cfg["show_tokens"] = 1;
    TFuBnkFrame_TokenFrame:Show();
    TFuBnkFrame:SetButton_Anchors();
  end
end

function Bank.Toggle_BagSlotButtons()
  if (TFuBnkFrame.cfg["show_bagbuttons"] == 1) then
    TFuBnkFrame.cfg["show_bagbuttons"] = 0;
    TFuBnkFrameBag1:Hide();
    TFuBnkFrameBag2:Hide();
    TFuBnkFrameBag3:Hide();
    TFuBnkFrameBag4:Hide();
    TFuBnkFrameBag5:Hide();
    TFuBnkFrameBag6:Hide();
    TFuBnkFrameBag7:Hide();
    TFuBnkFrameBagBank:Hide();
    TFuBnkFrameBagReagent:Hide();
    TFuBnkFrame:SetButton_Anchors();
  else
    TFuBnkFrame.cfg["show_bagbuttons"] = 1;
    TFuBnkFrameBag1:Show();
    TFuBnkFrameBag2:Show();
    TFuBnkFrameBag3:Show();
    TFuBnkFrameBag4:Show();
    TFuBnkFrameBag5:Show();
    TFuBnkFrameBag6:Show();
    TFuBnkFrameBag7:Show();
    TFuBnkFrameBagBank:Show();
    TFuBnkFrameBagReagent:Show();
    TFuBnkFrame:SetButton_Anchors();
   end
end

function Bank.Toggle_Total()
  if (TFuBnkFrame.cfg["show_total"] == 1) then
    TFuBnkFrame.cfg["show_total"] = 0;
    TFuBnkFrame_Total:Hide();
    TFuBnkFrame:SetButton_Anchors();
  else
    TFuBnkFrame.cfg["show_total"] = 1;
    TFuBnkFrame_Total:Show();
    TFuBnkFrame:SetButton_Anchors();
  end
end


function Bank.RightClickMenu_populate(self, level)
  local bar, bag, slot;
  local info, itm, id, barclass, tmp, checked, i;
  local key, value, key2, value2;


  -------------------------------------------------------------------------------------------------
  ------------------------------- ITEM CONTEXT MENU -----------------------------------------------
  -------------------------------------------------------------------------------------------------
  if (TFuBnkFrame.RightClickMenu_mode == "item") then
  -- we have a right click on a button

  bar = TFuBnkFrame.RightClickMenu_opts[TFuBag.I_BAR];
  bag = TFuBnkFrame.RightClickMenu_opts[TFuBag.I_BAG];
  slot = TFuBnkFrame.RightClickMenu_opts[TFuBag.I_SLOT];
  itm = TFuBnkItm[TFuBnkFrame.playerid][bag][slot];
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
    if (TFuBnkFrame.cfg["item_overrides"][id] ~= nil) then
  info["checked"] = 1;
    end
    UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = L["Use default category assignment"],
  ["value"] = { [TFuBag.I_BAG]=bag, [TFuBag.I_SLOT]=slot },
  ["func"] = TFuBnkFrame.RightClick_DeleteItemOverride
  };
    if (TFuBnkFrame.cfg["item_overrides"][id] == nil) then
  info["checked"] = 1;
    end
    UIDropDownMenu_AddButton(info, level);

    if (TFuBnk_SHOWITEMDEBUGINFO==1) then
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
  if ( (TFuBnkFrame.cfg["item_overrides"][id] ~=
  nil) and (TFuBag:GetCat(TFuBnkFrame.cfg, TFuBnkFrame.cfg["item_overrides"][id]) == i) ) then
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
  for key, barclass in pairs(TFuBnkFrame.BC_LIST[UIDROPDOWNMENU_MENU_VALUE["select_bar"]]) do
    info = {
  ["text"] = barclass;
  ["value"] = { [TFuBag.I_BAG]=bag, [TFuBag.I_SLOT]=slot, ["barclass"]=barclass },
  ["func"] = TFuBnkFrame.RightClick_SetItemOverride
  };
    if (TFuBnkFrame.cfg["item_overrides"][id] == barclass) then
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
  elseif (TFuBnkFrame.RightClickMenu_mode == "bar") then
  -- right click on a slot
  bar = TFuBnkFrame.RightClickMenu_opts[TFuBag.I_BAR];

  info = { ["text"] = string.format(L["|c%sBar |r|c%s%s|r"],TFuBag.C_INST,TFuBag.C_BAR,bar), ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
  UIDropDownMenu_AddButton(info, level);

  info = { ["disabled"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  for key, value in pairs(TFuBnkFrame.BC_LIST[bar]) do
    info = {
    ["text"] = string.format(L["Move: |c%s%s|r"],TFuBag.C_CAT,value);
    ["value"] = value;
    ["func"] = function(self)
  local this = self or _G.this
  TFuBnkFrame.edit_selected = (this.value);
  TFuBnkFrame.edit_hilight = (this.value);
  TFuBnkFrame:UpdateWindow();
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

    if (TFuBag:GetGrp(TFuBnkFrame.cfg, TFuBag.G_BAR_SORT, bar) == key) then
      checked = 1;
    else
      checked = nil;
    end
    info = {
  ["text"] = value;
  ["value"] = { [TFuBag.I_BAR]=bar, ["sortby"]=key };
  ["func"] = function(self)
    local this = self or _G.this
    TFuBag:SetGrpDef(TFuBnkFrame.cfg, TFuBag.G_BAR_SORT, this.value[TFuBag.I_BAR], this.value["sortby"], 1);
    TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
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

    if (TFuBag:GetGrp(TFuBnkFrame.cfg, TFuBag.G_USE_NEW, bar) == key) then
      checked = 1;
    else
      checked = nil;
    end

    info = {
      ["text"] = value;
      ["value"] = { [TFuBag.I_BAR]=bar, ["value"]=key };
      ["func"] = function(self)
        local this = self or _G.this
        TFuBag:SetGrpDef(TFuBnkFrame.cfg, TFuBag.G_USE_NEW, this.value[TFuBag.I_BAR], this.value["value"], 1);
        TFuBnkFrame:UpdateWindow();
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

    if (TFuBag:GetGrp(TFuBnkFrame.cfg, TFuBag.G_BAR_HIDE, bar) == key) then
      checked = 1;
    else
      checked = nil;
    end

    info = {
      ["text"] = value;
      ["value"] = { [TFuBag.I_BAR]=bar, ["value"]=key };
      ["func"] = function(self)
        local this = self or _G.this
        TFuBag:SetGrpDef(TFuBnkFrame.cfg, TFuBag.G_BAR_HIDE, this.value[TFuBag.I_BAR], this.value["value"], 1);
        TFuBnkFrame:UpdateWindow();
    end,
  ["checked"] = checked
  };
    UIDropDownMenu_AddButton(info, level);
  end

  info = { ["disabled"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  info = { ["text"] = L["Color:"], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
  UIDropDownMenu_AddButton(info, level);

  info = TFuBag:MakeColorPickerInfo(TFuBnkFrame.cfg, "bkgr_", bar,
    string.format(L["Background Color for Bar %d"],bar), function () TFuBnkFramer:UpdateWindow() end);
  UIDropDownMenu_AddButton(info, level);

  info = TFuBag:MakeColorPickerInfo(TFuBnkFrame.cfg, "brdr_", bar,
    string.format(L["Border Color for Bar %d"],bar), function () TFuBnkFrame:UpdateWindow() end);
  UIDropDownMenu_AddButton(info, level);

  -------------------------------------------------------------------------------------------------
  ------------------------ MAIN WINDOW CONTEXT MENU -----------------------------------------------
  -------------------------------------------------------------------------------------------------
  elseif (TFuBnkFrame.RightClickMenu_mode == "mainwindow") then
  if (level == 1) then

    info = { ["text"] = string.format(L["TBag v%s"],TFuBag.VERSION), ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);

    if (TFuBnkFrame.atbank == 0) then
      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Select Character"];
        ["value"] = { ["opt"]="select_character" },
        ["hasArrow"] = 1
        };
      UIDropDownMenu_AddButton(info, level);
    end

    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = L["Edit Mode"],
  ["value"] = nil,
  ["func"] = TFuBnkFrame.Button_ChangeEditMode_OnClick
  };
    if (TFuBnkFrame.edit_mode == 1) then
      info["checked"] = 1;
    end
    UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = L["Lock window"],
  ["value"] = nil,
  ["func"] = TFuBnkFrame.Button_MoveLockToggle_OnClick
  };
    if (TFuBnkFrame.cfg["moveLock"] == 0) then
  info["checked"] = 1;
    end
    UIDropDownMenu_AddButton(info, level);

  info = {
  ["text"] = L["Reload and Sort"],
  ["value"] = nil,
  ["func"] = TFuBnkFrame.Button_Reload_OnClick
  };
  UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = REAGENTBANK_DEPOSIT,
  ["value"] = nil,
  ["func"] = TFuBnkFrame.Button_DepositReagent_OnClick
  };
  UIDropDownMenu_AddButton(info, level);

    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = {
  ["value"] = nil,
  ["func"] = TFuBnkFrame.Button_HighlightToggle_OnClick
  };
    if (TFuBag.SrchText) then
      info["text"] = L["Clear Search"];
    else
      info["text"] = L["Highlight New Items"];
      if (TFuBnkFrame.hilight_new == 1) then
        info["checked"] = 1;
      end
    end
    UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = L["Reset NEW tag"],
  ["value"] = nil,
  ["func"] = function()
    local bag, slot, index;

    for index, bag in ipairs(TFuBnkFrame.bags) do
      if (TFuBnkFrame.cfg["show_Bag"..bag] == 1) then
        if (table.getn(TFuBnkItm[TFuBnkFrame.playerid][bag]) > 0) then
          for slot = 1, table.getn(TFuBnkItm[TFuBnkFrame.playerid][bag]) do
            TFuBag:ResetNew(TFuBnkItm[TFuBnkFrame.playerid][bag][slot]);
          end
        end
      end
    end

    TFuBnkFrame:UpdateWindow();
  end
  };
    UIDropDownMenu_AddButton(info, level);

  info = { ["disabled"] = 1 };
  UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = L["Advanced Configuration"],
  ["value"] = nil,
  ["func"] = function()
    TFuBnk_OptsFrame:Show();
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
                    TFuBnkFrame.cfg["frameButtonSize"], TFuBnkFrame.cfg["count_font"],
                      TFuBnkFrame.cfg["count_font_x"], TFuBnkFrame.cfg["count_font_y"],
                      TFuBnkFrame.cfg["scale"] = TFuBag:NicePlacement(this.value);
                  TFuBnkFrame:CalcButtonSize(TFuBnkFrame.cfg["frameButtonSize"], TFuBnkFrame.cfg["framePad"]);
                  TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
                end
              end
            };
            if (tonumber(TFuBnkFrame.cfg["frameButtonSize"]*TFuBnkFrame.cfg["scale"] - value)
      < 1.0) and (tonumber(TFuBnkFrame.cfg["frameButtonSize"]*TFuBnkFrame.cfg["scale"] - value)
      > -1.0) then
              info["checked"] = 1;
            end
            UIDropDownMenu_AddButton(info, level);
          end
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "set_colors") then
          TFuBag:MakeColorMenu(TFuBnkFrame.cfg, function () TFuBnkFrame:UpdateWindow() end, level, TFuBnkFrame.bags);
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "anchor") then
          info = {
            ["text"] = L["TOPLEFT"];
            ["func"] = function ()
                         TFuBag:SetFrameAnchor (TFuBnkFrame,TFuBnkFrame.cfg,"TOP","LEFT")
                       end;
            };
          if (TFuBnkFrame.cfg["frameXRelativeTo"] == "LEFT" and
              TFuBnkFrame.cfg["frameYRelativeTo"] == "TOP") then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["TOPRIGHT"];
            ["func"] = function ()
                         TFuBag:SetFrameAnchor (TFuBnkFrame,TFuBnkFrame.cfg,"TOP","RIGHT")
                       end;
            };
          if (TFuBnkFrame.cfg["frameXRelativeTo"] == "RIGHT" and
              TFuBnkFrame.cfg["frameYRelativeTo"] == "TOP") then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["BOTTOMLEFT"];            ["func"] = function ()
                         TFuBag:SetFrameAnchor (TFuBnkFrame,TFuBnkFrame.cfg,"BOTTOM","LEFT")
                       end;
            };
          if (TFuBnkFrame.cfg["frameXRelativeTo"] == "LEFT" and
              TFuBnkFrame.cfg["frameYRelativeTo"] == "BOTTOM") then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["BOTTOMRIGHT"];
            ["func"] = function ()
                         TFuBag:SetFrameAnchor (TFuBnkFrame,TFuBnkFrame.cfg,"BOTTOM","RIGHT")
                       end;
            };
          if (TFuBnkFrame.cfg["frameXRelativeTo"] == "RIGHT" and
              TFuBnkFrame.cfg["frameYRelativeTo"] == "BOTTOM") then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "hide_frames") then
          info = {
            ["text"] = L["Hide Player Dropdown"];
            ["func"] = TFuBnkFrame.Toggle_UserDropdown;
            ["keepShownOnClick"] = 1;
            };
          if (TFuBnkFrame.cfg["show_userdropdown"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Highlight Button"];
            ["func"] = TFuBnkFrame.Toggle_HighlightButton;
            ["keepShownOnClick"] = 1;
            };
          if (TFuBnkFrame.cfg["show_hilightbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Edit Button"];
            ["func"] = TFuBnkFrame.Toggle_EditButton;
            ["keepShownOnClick"] = 1;
           };
          if (TFuBnkFrame.cfg["show_editbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Re-sort Button"];
            ["func"] = TFuBnkFrame.Toggle_ReloadButton;
            ["keepShownOnClick"] = 1;
            };
          if (TFuBnkFrame.cfg["show_reloadbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Reagent Deposit Button"];
            ["func"] = TFuBnkFrame.Toggle_DepositReagentButton;
            ["keepShownOnClick"] = 1;
            };
          if (TFuBnkFrame.cfg["show_depositbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Lock Button"];
            ["func"] = TFuBnkFrame.Toggle_LockButton;
            ["keepShownOnClick"] = 1;
            };
          if (TFuBnkFrame.cfg["show_lockbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Close Button"];
            ["func"] = TFuBnkFrame.Toggle_CloseButton;
            ["keepShownOnClick"] = 1;
            };
          if (TFuBnkFrame.cfg["show_closebutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Total"];
            ["func"] = TFuBnkFrame.Toggle_Total;
            ["keepShownOnClick"] = 1;
            };
          if (TFuBnkFrame.cfg["show_total"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Bag Buttons"];
            ["func"] = TFuBnkFrame.Toggle_BagSlotButtons;
            ["keepShownOnClick"] = 1;
            };
          if (TFuBnkFrame.cfg["show_bagbuttons"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Tokens"];
            ["func"] = TFuBnkFrame.Toggle_Token;
            ["keepShownOnClick"] = 1;
            };
          if (TFuBnkFrame.cfg["show_tokens"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Money"];
            ["func"] = TFuBnkFrame.Toggle_Money;
            ["keepShownOnClick"] = 1;
            };
          if (TFuBnkFrame.cfg["show_money"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "select_character") then
          Bank.UserDropdown_Initialize(self, level);
        end
      end
    end
  end
  TFuBag:FixMenuFrameLevels()
end


-- Main "right click menu"
function Bank.RightClickMenu_OnLoad(self)
  UIDropDownMenu_Initialize(self, Bank.RightClickMenu_populate, "MENU");
end

Bank.WindowIsUpdating = 0;

function Bank:UpdateWindow(resort_req)
  local frame = TFuBnkFrame;
  local barnum;
  local cur_y;

  TFuBag:PrintDEBUG("Bank:UpdateWindow(): WindowIsUpdating="..Bank.WindowIsUpdating);

  if (Bank.WindowIsUpdating == 1) then
    return;
  end
  Bank.WindowIsUpdating = 1;

  if ( not frame:IsVisible() ) then
    Bank.WindowIsUpdating = 0;
    return;
  end

  -- Set the overall scale
  self:SetScale(self.cfg["scale"]);

  if (resort_req == nil) then resort_req = TFuBag.REQ_NONE; end

  -- Show some things only when we are at then bank
  if (self.atbank == 1 or self.cfg["show_userdropdown"] == 0) then
    TFuBnk_UserDropdown:Hide();
  else
    TFuBnk_UserDropdown:Show();
  end

  -- SORTING

  -- Consume a message from updated craft info
  if (TFuBagCfg["trades_changed"] == 1) then
    resort_req = TFuBag.REQ_MUST;
  end
  TFuBagCfg["trades_changed"] = 0;

  -- Setup stackarr and comparr
  local stackarr = TFuBag:CreateStackArr();
  local comparr = TFuBag:CreateCompArr();

  local cache_req = TFuBag:UpdateItmCache(self.cfg, self.playerid, TFuBnkItm[self.playerid], self.bags, stackarr, comparr, self.atbank);
  if resort_req == TFuBag.REQ_PART then
    resort_req = resort_req + self.CACHE_REQ
  end
  resort_req = resort_req + cache_req;

  -- Consume a message for bag stacking
  if (self.cfg["stack_once"] == 1) then
    if (self.playerid == TFuBag.PLAYERID) then
      if TFuBag:Stack(TFuBag.STACK_BNK,TFuBnkItm[self.playerid], stackarr, comparr) then
        self.cfg["stack_once"] = 0;
      end
    end
  end

  if (resort_req >= TFuBag.REQ_MUST) then
    self.BARITM = TFuBag:SortItmCache(self.cfg,
      self.playerid, TFuBnkItm[self.playerid], self.BARITM, self.bags);
    TFuBag:LayoutWindow(self)
  elseif cache_req > self.CACHE_REQ then
    self.CACHE_REQ = cache_req
  end

  -- Relink the button map
  for _,bag in ipairs(self.bags) do
    for slot = 1, TFuBag:GetBagMaxItems(bag) do
      if TFuBnkItm[self.playerid][bag] then
        TFuBag.BUTTONS[TFuBag:GetBagItemButtonName(bag, slot)] = TFuBnkItm[self.playerid][bag][slot]
      else
        TFuBag.BUTTONS[TFuBag:GetBagItemButtonName(bag, slot)] = {}
      end
    end
  end

  -- BAGS, to get bag sizes below
  TFuBnkFrame:UpdateBagGfx();

  -- Update all the buttons
  for _, bag in ipairs(self.bags) do
    local size = TFuBag:GetPlayerBagCfg(self.playerid, bag, TFuBag.I_BAGSIZE);
    if (not size) then size = 0; end
    if (self.cfg["show_Bag"..bag] ~= 1 and not TFuBag:GetBagFrame(bag):GetChecked()) then
      size = 0
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
    MoneyFrame_SetType(TFuBnkFrame_MoneyFrame,type)
    MoneyFrame_Update("TFuBnkFrame_MoneyFrame", TFuBag:GetMoney(self.playerid));
  end

  frame:UpdateDepositButton();

  frame:ClearAllPoints();
  frame:SetPoint(self.cfg["frameYRelativeTo"]..self.cfg["frameXRelativeTo"],
    "UIParent", "BOTTOMLEFT",
    self.cfg["frame"..self.cfg["frameXRelativeTo"]] / frame:GetScale(),
    self.cfg["frame"..self.cfg["frameYRelativeTo"]] / frame:GetScale());

  TFuBag:ColorFrame(self.cfg, frame, TFuBag.MAIN_BAR);

  if (self.edit_mode == 1) then
    TFuBnkFrame_ColumnsAdd:Show();
    TFuBnkFrame_ColumnsDel:Show();
  else
    TFuBnkFrame_ColumnsAdd:Hide();
    TFuBnkFrame_ColumnsDel:Hide();
  end

  TFuBnkFrame:SetButton_Anchors();

  Bank.WindowIsUpdating = 0;
end


function Bank:SetReplaceBank()
  if BankFrame_Saved == nil then
    BankFrame_Saved = BankFrame;
  end
  if BankFrame_Saved:IsVisible() then
    BankFrame_Saved:Hide();
  end
  BankFrame_Saved:UnregisterEvent("BANKFRAME_OPENED");
  BankFrame_Saved:UnregisterEvent("BANKFRAME_CLOSED");
end


function Bank.UserDropdown_OnLoad(self)
  UIDropDownMenu_Initialize(self, Bank.UserDropdown_Initialize);
  UIDropDownMenu_SetSelectedValue(self, TFuBnkFrame.playerid);
  self.tooltip = L["You are viewing the selected player's bank."];
  UIDropDownMenu_SetWidth(self, TFuBag.USERDD_WIDTH)
  -- UIDropDownMenu_SetWidth actually adds 50 to our width, we really only want
  -- 25 to avoid the control running into our buttons on the right.
  self:SetWidth(TFuBag.USERDD_WIDTH + 25);
--  OptionsFrame_EnableDropDown(self);
end

function Bank.UserDropdown_Initialize(self, level)
  TFuBag:UserDropdown_Init(Bank.UserDropdown_OnClick,
    TFuBnkItm, TFuBnkFrame.playerid, TFuBag.REALM, level);
end

function Bank.UserDropdown_OnClick(self)
  local this = self or _G.this
  UIDropDownMenu_SetSelectedValue(TFuBnk_UserDropdown, this.value);
  if ( this.value ) then
    TFuBnkFrame:SetPlayer(this.value);
  end
  if ( not TFuBnkFrame.playerid ) then
    TFuBag:PrintDEBUG("UserDropdown_OnClick Failed");
    return;
  end
  TFuBag:PrintDEBUG("Selected Player "..TFuBnkFrame.playerid);
  -- Show in whatever state the cache was in before
  TFuBnkFrame.atbank = 0;
  TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
end
