BINDING_NAME_TBNK_TOGGLE = "Toggle Bank Window";

-- Constants
TBnk_DEBUGMESSAGES = 0;         -- 0 = off, 1 = on
TBnk_SHOWITEMDEBUGINFO = 0;
local TBnk_WIPECONFIGONLOAD = 0;	-- for debugging, test it out on a new config every load

-- Bank switching
TBNK_PLAYERID = "";
TBNK_ATBANK = 0;
local BankFrame_Saved = nil;

-- Graphics Settings
local TBNK_BANKBUTTON_MAX = 28;
TBNK_BUTTON_MAX = 240;
TBNK_PAD_TOP_GFX = 63;
TBNK_PAD_TOP_NORM = 25;
TBNK_BORDER = 2;

TBnkCfg = nil;
TBNK_BARITM = {};
TBnk_hilight_new = 0;
TBnk_edit_mode = 0;
TBnk_edit_hilight = "";         -- when editmode is 1, which items do you want to hilight
TBnk_edit_selected = "";        -- when editmode is 1, this is the class of item you clicked on
TBnk_RightClickMenu_mode = "";
TBnk_RightClickMenu_opts = {};

TBNK_BC_LIST = {};  -- Bar to Class list

local TBNK_BF_X_PAD = 1;
local TBNK_BF_Y_PAD = 1;
local TBNK_BF_WIDTH = 34;
local TBNK_BF_HEIGHT = 34;
local TBNK_BF_PADWIDTH = 36;
local TBNK_BF_PADHEIGHT = 36;
local TBNK_BGF_WIDTH = 38;
local TBNK_BGF_HEIGHT = 38;

-- Param Functions

function TBnk_FrameX(width)
  return (width * (TBNK_BF_PADWIDTH + TBnkCfg["frameXSpace"]))
  + TBnkCfg["frameXSpace"];
end

function TBnk_FrameY(height)
  return (height * (TBNK_BF_PADHEIGHT + TBnkCfg["frameYSpace"]))
  + TBnkCfg["frameYSpace"];
end

function TBnk_SpaceX(space)
  return (space * (TBnkCfg["frameXSpace"]));
end

function TBnk_SpaceY(space)
  return (space * (TBnkCfg["frameYSpace"]));
end

function TBnk_PoolX(space)
  return (space * (TBnkCfg["frameXPool"]));
end

function TBnk_PoolY(space)
  return (space * (TBnkCfg["frameYPool"]));
end


------------------------

function TBnk_CalcButtonSize(newsize, pad)
  local k = "button_size_opts";
  -- constants
  TBNK_BF_X_PAD = pad;
  TBNK_BF_Y_PAD = pad;
  TBNK_BF_WIDTH = newsize;
  TBNK_BF_HEIGHT = newsize;
  TBNK_BF_PADWIDTH = TBNK_BF_WIDTH + (TBNK_BF_X_PAD*2);
  TBNK_BF_PADHEIGHT = TBNK_BF_HEIGHT + (TBNK_BF_Y_PAD*2);
  TBNK_BGF_WIDTH = TBNK_BF_WIDTH * 1.6 + (TBNK_BF_X_PAD*2);
  TBNK_BGF_HEIGHT = TBNK_BF_HEIGHT * 1.6 + (TBNK_BF_Y_PAD*2);

  -- Always ensure a visually appealing fit
  TBNK_BGF_WIDTH = TBag_MakeEven(TBNK_BGF_WIDTH, TBNK_BF_WIDTH);
  TBNK_BGF_HEIGHT = TBag_MakeEven(TBNK_BGF_HEIGHT, TBNK_BF_HEIGHT);
end

function TBnk_InitDefVals(reset)
  local i, key, value;
  local cfg = TBnkCfg;

  TBag_InitDefVals(cfg, TBnk_Bags, 4, reset);

  TBag_SetDef(cfg, "maxColumns", 14, reset, TBag_NumFunc, TBAG_NUMCOL_MIN,TBAG_NUMCOL_MAX);

  TBag_SetDef(cfg, "show_purchase_button", 0, reset, TBag_NumFunc, 0, 1);

  -- Colors
  TBag_SetColor(cfg, "bkgr_"..TBAG_MAIN_BAR, 0.3, 0.1, 0.0, 0.4, reset);
  TBag_SetColor(cfg, "brdr_"..TBAG_MAIN_BAR, 0.7, 0.1, 0.1, 0.3, reset);
  for i = 1, TBAG_BAR_MAX do
    TBag_SetColor(cfg, "bkgr_"..i, 0.3, 0.1, 0.0, 0.4, reset);
    TBag_SetColor(cfg, "brdr_"..i, 0.7, 0.1, 0.1, 0.3, reset);
  end
  TBag_SetDefColors(cfg, reset);

  TBag_SetDef(cfg, "frameLEFT", UIParent:GetRight() * UIParent:GetScale() * 0.294, reset, TBag_NumFunc);
  TBag_SetDef(cfg, "frameRIGHT", UIParent:GetRight() * UIParent:GetScale() * 0.684, reset, TBag_NumFunc);
  TBag_SetDef(cfg, "frameTOP", UIParent:GetTop() * UIParent:GetScale() * 0.83, reset, TBag_NumFunc);
  TBag_SetDef(cfg, "frameBOTTOM", UIParent:GetTop() * UIParent:GetScale() * 0.232, reset, TBag_NumFunc);
  TBag_SetDef(cfg, "frameXRelativeTo", "LEFT", reset, TBag_StrFunc, {"RIGHT","LEFT"} );
  TBag_SetDef(cfg, "frameYRelativeTo", "BOTTOM", reset, TBag_StrFunc, {"TOP","BOTTOM"} );

  TBnk_CalcButtonSize(TBnkCfg["frameButtonSize"], TBnkCfg["framePad"]);
end

function TBnk_SetPlayer(playerid)
  TBNK_PLAYERID = playerid;
end

-- Set reset=1 to restore default values
function TBnk_init(reset)
  TBag_Init();
  TBnkCfg = TBagCfg["Bnk"];

  if ( TBnk_WIPECONFIGONLOAD == 1 ) then
    TBagCfg["Bnk"] = {};
  end

  TBnk_SetPlayer(TBAG_PLAYERID);

  -- Make all the frames
  for _, bag in ipairs(TBnk_Bags) do
    if (bag == -1) then
      TBag_CreateDummyBag(bag, "TBnk_BankItemButtonTemplate");
    else
      TBag_CreateDummyBag(bag, "TBnk_ItemButtonTemplate");
    end
  end

  TBag_CreateFrame("Frame", "TBnkFrame_bar_", getglobal("TBnkFrame"),
    "TBag_BarFrameTemplate", TBAG_BAR_MAX, "");
  TBag_CreateFrame("Button", "TBnkFrame_SlotTarget_", getglobal("TBnkFrame"),
    "TBnk_SlotTargetTemplate", TBAG_BAR_MAX, "");

  -- change imported from auctioneer team..  what does it do?
  UIPanelWindows["TBnkFrame"] = { area = "left", pushable = 6 };

  -- register slash command
  SlashCmdList["TBnk"] = TBnk_cmd;
  SLASH_TBnk1 = "/tbnk";

  -- load default values
  TBnk_InitDefVals(reset);

  local bag;
  for _, bag in ipairs(TBnk_Bags) do
    TBag_GetBagFrame(bag):SetScale(0.7);
    TBag_GetBagNumFrame(bag):SetScale(1.3);
  end
  TBnk_InitBagGfx()

  TBnk_SetReplaceBank();
  
  -- setup hooks
  TBnkHooks_Register(TBAG_HOOK_UNREGISTER);
  TBnkHooks_Register(TBAG_HOOK_REGISTER);

  TBnk_Button_HighlightToggle:SetText(TBag_Loc("TBag_HighlightToggle_off"));
  TBnk_Button_ChangeEditMode:SetText(TBag_Loc("TBag_ChangeEditMode_off"));

  if (TBnkCfg["moveLock"] == 0) then
    TBnk_Button_MoveLockToggle:SetText(TBag_Loc("TBag_MoveLock_locked"));
  else
    TBnk_Button_MoveLockToggle:SetText(TBag_Loc("TBag_MoveLock_unlocked"));
  end

  TBag_BuildBarClassList(TBNK_BC_LIST, TBnkCfg);

  -- Do one sorting to init the baritm array
  TBNK_BARITM = TBag_SortItmCache(TBnkCfg, 
    TBNK_PLAYERID, TBnkItm[TBNK_PLAYERID], TBNK_BARITM, TBnk_Bags);
  TBag_LayoutWindow(TBnkCfg, "TBnkFrame", TBNK_BARITM, TBnkCfg["bar_x"], 
    TBnk_edit_mode, TBNK_BUTTON_MAX, TBnk_AssignButtonsToFrame, 
    TBnk_FrameX, TBnk_FrameY, TBnk_SpaceX, TBnk_SpaceY, TBnk_PoolX, TBnk_PoolY)
end

function TBnk_UpdatePurchaseGfx()
  local numSlots, full = TBag_GetNumBankSlots(TBNK_PLAYERID);
  local cost = GetBankSlotCost(numSlots);
  if (not full) then
    MoneyFrame_Update("TBnk_SlotCostFrame", cost);
  else
    MoneyFrame_Update("TBnk_SlotCostFrame", 0);
  end

  TBag_PrintDEBUG("TBnk_UpdatePurchaseGfx: "..numSlots..", "..cost);
  TBag_PrintDEBUG("TBnk_UpdatePurchaseGfx: "..TBnkCfg["show_purchase_button"]..", "..TBNK_ATBANK..", "..TBnk_edit_mode);

  if ((TBnkCfg["show_purchase_button"] == 1) and (TBNK_ATBANK == 1)
    and (TBnk_edit_mode == 0)) then
    -- Be EXTRA paranoid
    if (TBNK_PLAYERID == TBAG_PLAYERID) then
      TBnk_PurchaseButton:Show();
    end
    TBnk_SlotCostFrame:Show();
  else
    TBnk_SlotCostFrame:Hide();
    TBnk_PurchaseButton:Hide();
  end
end


function TBnk_UpdateBagGfx()
  local i;
  local numSlots, _ = TBag_GetNumBankSlots(TBNK_PLAYERID);
  local free, size = TBag_UpdateSlots(TBNK_PLAYERID, "TBnkNum", -1, TBnkCfg["show_bag_sizes"]);
  local totalfree = free;
  local totalsize = size;
  local bag = -1;

  TBag_UpdateBagColors(bag);
  TBag_SetPlayerBagCfg(TBNK_PLAYERID, bag, TBAG_I_ITEMLINK, nil);

  for i=1, numSlots do
    bag = i + 4;
    local type = TBag_GetBagType(TBNK_PLAYERID, bag); -- needed for cacheing
    TBag_GetBagFrameTexture(bag):SetVertexColor(1.0,1.0,1.0, 1.0);
  end
  for i=numSlots+1, NUM_BANKBAGSLOTS do
    bag = i + 4;
    TBag_SetPlayerBagCfg(TBNK_PLAYERID, bag, TBAG_I_BAGTYPE, "");
    TBag_SetPlayerBagCfg(TBNK_PLAYERID, bag, TBAG_I_BAGFREE, 0);
    TBag_SetPlayerBagCfg(TBNK_PLAYERID, bag, TBAG_I_BAGSIZE, 0);
    TBag_SetPlayerBagCfg(TBNK_PLAYERID, bag, TBAG_I_ITEMLINK, nil);
    TBag_GetBagFrameTexture(bag):SetVertexColor(1.0,0.1,0.1, 1.0);
  end
  for i=1, NUM_BANKBAGSLOTS do
    bag = i + 4;

    TBag_UpdateBagColors(bag);
 
    TBag_GetBagFrameTexture(bag):SetTexture(
      TBag_GetBagTexture(TBNK_PLAYERID, bag));

    local free, size = TBag_UpdateSlots(TBNK_PLAYERID, "TBnkNum", bag, TBnkCfg["show_bag_sizes"]);
    
    totalfree = totalfree + free;
    totalsize = totalsize + size;
  end
  TBag_SetFreeStr(getglobal("TBnkNumTotalText"), totalfree, totalsize, TBnkCfg["show_bag_sizes"]);
end

function TBnk_InitBagGfx()
  local numSlots, _ = TBag_GetNumBankSlots(TBNK_PLAYERID);

  -- Spoof the bank
  local button = getglobal("TBnkFrameBagBank");
  SetItemButtonTextureVertexColor(button, 1.0,1.0,1.0, 1.0);
  button.tooltipText = "The Bank";

  for i=1, NUM_BANKBAGSLOTS do
    button = getglobal("TBnkFrameBag"..i);
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


function TBnk_OnEvent(event)
  -- TBag_Print("TBnk_OnEvent: '"..event.."'");

  if (event == "BANKFRAME_OPENED") then
    TBNK_ATBANK = 1;
    TBnk_Open();
  elseif (event == "BANKFRAME_CLOSED") then
    TBnk_Close();
    TBNK_ATBANK = 0;
  elseif (event == "PLAYERBANKSLOTS_CHANGED") then
    TBnk_UpdateWindow();
  elseif (event == "PLAYERBANKBAGSLOTS_CHANGED") then
    TBnk_UpdateWindow(TBAG_REQ_MUST);
  end

  if ( TBnkFrame:IsVisible() ) then
    if ( event == "BAG_UPDATE" ) then
      -- Stack the bags if we are in a state to
      if (CursorHasItem() == nil and CursorHasMoney() == nil and CursorHasSpell() == nil and TBag_IsStacking() == nil) then
        -- Stack the bags if configured to
        if (TBnkCfg["stack_auto"] == 1) then
          if (TBNK_PLAYERID == TBAG_PLAYERID) then
            -- Send a message to restack
            TBnkCfg["stack_once"] = 1;
          end
        end
      end
      TBnk_UpdateWindow();
    elseif ( event == "BAG_UPDATE_COOLDOWN" ) then
      TBnk_UpdateWindow();
    elseif ( event == "ITEM_LOCK_CHANGED" ) then
      TBnk_UpdateWindow();
    else
      TBag_PrintDEBUG("OnEvent: No event handler found.");
    end
  else
    TBag_PrintDEBUG("Event ignored.");
  end

  TBag_PrintDEBUG("OnEvent: Finished "..event);
end

function TBnk_StartMoving(frame)
  if ( not frame.isMoving ) and ( TBnkCfg["moveLock"] == 1 ) then
    frame:StartMoving();
    frame.isMoving = true;
  end
end

function TBnk_StopMoving(frame)
  if ( frame.isMoving ) then
    frame:StopMovingOrSizing();
    frame.isMoving = false;

    -- save the position
    TBnkCfg["frameLEFT"] = frame:GetLeft() * frame:GetScale();
    TBnkCfg["frameRIGHT"] = frame:GetRight() * frame:GetScale();
    TBnkCfg["frameTOP"] = frame:GetTop() * frame:GetScale();
    TBnkCfg["frameBOTTOM"] = frame:GetBottom() * frame:GetScale();

                TBag_PrintDEBUG("new position:  top="..TBnkCfg["frameTOP"]..", bottom="..TBnkCfg["frameBOTTOM"]..", left="..TBnkCfg["frameLEFT"]..", right="..TBnkCfg["frameRIGHT"] );
        end
end

function TBnk_OnMouseDown(button, frame)

  if ( button == "LeftButton" ) then
    TBnk_StartMoving(frame);
  elseif ( button == "RightButton" ) then
    HideDropDownMenu(1);
    TBnk_RightClickMenu_mode = "mainwindow";
    TBnk_RightClickMenu_opts = {};
    ToggleDropDownMenu(1, nil, TBnkFrame_RightClickMenu, "cursor", 0, 0);
  end
end


function TBnk_ItemButton_OnEnter()
  local itm = TBag_GetItmFromFrame(TBAG_BUTTONS, this:GetName());
  local bar;
  if (itm ~= nil) then
    bar = itm[TBAG_I_BAR];
  end
  if (TBnk_edit_selected == "") then
    TBnk_edit_hilight = itm[TBAG_I_CAT];
  end

  if ( not itm[TBAG_I_ITEMLINK]) then
    if ( TBnk_edit_mode == 1 ) then
      GameTooltip:SetOwner(this, "ANCHOR_LEFT");
      GameTooltip:ClearLines();
      GameTooltip:AddLine("Empty Slot", 1,1,1 );

      GameTooltip:Show();
    else
      GameTooltip:Hide();
    end

    if ( TBnk_edit_mode == 1 ) then
      -- redraw the window to show the hilighting of entire class items
      TBnk_UpdateWindow();
    end
    return;
  end


  -- Tool Tip Anchor: Anchor Right if the frame is on the left side of the screen else Anchor Left.
  if (TBnkCfg["frameLEFT"] < GetScreenWidth()/2) then
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
  else
    GameTooltip:SetOwner(this, "ANCHOR_LEFT");
  end

  hasCooldown, repairCost = TBag_SetInventoryItem(GameTooltip, TBNK_PLAYERID, 
    itm[TBAG_I_ITEMLINK], itm[TBAG_I_BAG], itm[TBAG_I_SLOT]);

  if ( InRepairMode() and (repairCost and repairCost > 0) ) then
    GameTooltip:AddLine(TEXT(REPAIR_COST), 1, 1, 1);
    SetTooltipMoney(GameTooltip, repairCost);
    GameTooltip:Show();
  elseif ( MerchantFrame:IsVisible() ) then
    ShowContainerSellCursor(itm[TBAG_I_BAG], itm[TBAG_I_SLOT]);
--    TBag_RegisterCurrentTooltipSellValue(GameTooltip, itm[TBAG_I_BAG], itm[TBAG_I_SLOT], itm);
  elseif ( this.readable ) then
    ShowInspectCursor();
  end

  if ( IsShiftKeyDown() ) then
    TBag_PrintDEBUG('ShowCompareItem Called');
    GameTooltip_ShowCompareItem();
  end
  
  -- Then do a highlight to show the bag
  if (itm[TBAG_I_BAG] ~= KEYRING_CONTAINER) and (TBnkCfg["spotlight_hover"] == 1) then
    local r, g, b, a = TBag_GetColor(TBnkCfg, "bag_"..itm[TBAG_I_BAG]);
    TBag_GetBagFrameSpotlight(itm[TBAG_I_BAG]):SetVertexColor(r, g, b, a);
    TBag_GetBagFrameSpotlight(itm[TBAG_I_BAG]):Show();
  end

  if ( TBnk_edit_mode == 1 ) then
    -- redraw the window to show the hllighting of entire class items
    TBnk_UpdateWindow();
  end
end

function TBnk_OnUpdate(elapsed)
  if ( not this.updateTooltip ) then
    return;
  end

  this.updateTooltip = this.updateTooltip - elapsed;
  if ( this.updateTooltip > 0 ) then
    return;
  end

  if ( GameTooltip:IsOwned(this) ) then
    TBnk_ItemButton_OnEnter();
  else
    this.updateTooltip = nil;
  end
end

function TBnk_ItemButton_OnLeave()
  local itm = TBag_GetItmFromFrame(TBAG_BUTTONS, this:GetName());

  TBag_PrintDEBUG("EB_button: OnLeave()  this="..this:GetName() );

  if (TBnk_edit_selected == "") then
    TBnk_edit_hilight = "";
  end
  this.updateTooltip = nil;
  if ( GameTooltip:IsOwned(this) ) then
    GameTooltip:Hide();
    ResetCursor();
  end

  -- Then do a highlight to show the bag
  if (itm) and (itm[TBAG_I_BAG] ~= KEYRING_CONTAINER) then
    TBag_GetBagFrameSpotlight(itm[TBAG_I_BAG]):Hide();
  end

  if ( TBnk_edit_mode == 1 ) then
    -- redraw the window to remove the hilighting of entire class items
    TBnk_UpdateWindow();
  end
end

function TBnk_ItemButton_OnClick(button, ignoreShift)
  local itm = TBag_GetItmFromFrame(TBAG_BUTTONS, this:GetName());
  local bar, bag, slot;

  if (itm ~= nil) then
    bar = itm[TBAG_I_BAR];
    bag = itm[TBAG_I_BAG];
    slot = itm[TBAG_I_SLOT];
  end

  if (TBnk_edit_mode == 1) then
    -- don't do normal actions to this button, we're in edit mode
    if ( button == "LeftButton" ) then
      if (TBnk_edit_selected == "") then
        -- you clicked, we selected
        TBnk_edit_selected = itm[TBAG_I_CAT];
        TBnk_edit_hilight = itm[TBAG_I_CAT];
      else
        -- we got a click, and we already had one selected.  let's move the items
        TBag_SetCatBar(TBnkCfg, TBnk_edit_selected, bar, 1);

        TBnk_edit_selected = "";
        TBnk_edit_hilight = itm[TBAG_I_CAT];

        -- resort will force a window update
        TBnk_UpdateWindow();
      end
    elseif ( button == "RightButton" ) then
      HideDropDownMenu(1);
      TBnk_RightClickMenu_mode = "item";
      TBnk_RightClickMenu_opts = {
        [TBAG_I_BAR] = bar,
        [TBAG_I_BAG] = bag,
        [TBAG_I_SLOT] = slot
      };
      ToggleDropDownMenu(1, nil, TBnkFrame_RightClickMenu, this:GetName(), -50, 0);
    end
  else
    -- process normal clicks
    if (itm) then
      if ( button == "LeftButton" ) then
        if ( not IsModifierKeyDown() ) then
          PickupContainerItem(itm[TBAG_I_BAG], itm[TBAG_I_SLOT]);
          StackSplitFrame:Hide();
        end
      elseif ( button == "RightButton" ) then
        if ( MerchantFrame:IsShown() and MerchantFrame.selectedTab == 2 ) then
          -- Don't sell the item if the buyback tab is selected
          return;
        end
        if ( MerchantFrame:IsShown() and IsShiftKeyDown() ) then
          this.SplitStack = function(button, split)
            SplitContainerItem(itm[TBAG_I_BAG], itm[TBAG_I_SLOT], split);
            MerchantItemButton_OnClick("LeftButton");
          end

          OpenStackSplitFrame(this.count, this, "BOTTOMRIGHT", "TOPRIGHT");
        else
          -- Shift-click is used for auto-looting and socketing
          UseContainerItem(itm[TBAG_I_BAG], itm[TBAG_I_SLOT]);
          StackSplitFrame:Hide();
        end
      end
    end
    TBnk_UpdateWindow();
  end
end

function TBnkFrameBagBank_OnClick()
-- We need to find the function that drops into bank on right click
--  local hadItem = PutItemInBag(BankButtonIDToInvSlotID(slot));
  local hadItem;

  if ( not hadItem ) then
    if (TBnkCfg["show_blizzard_frames"] == 0) then
      if (not IsShiftKeyDown()) then
        TBag_UpdateButtonHighlights();
      else
        this:SetChecked(0);
      end
    else
      -- Only open at the bank
      if (TBNK_ATBANK == 1) then
        ToggleBag(-1);
        PlaySound("BAGMENUBUTTONPRESS");
      else 
        if (not IsShiftKeyDown()) then
          TBag_UpdateButtonHighlights();
        else
          this:SetChecked(0);
        end
      end
    end
  end
end


function TBnk_RightClick_PickupItem()
  local bag, slot;

  bag = this.value[TBAG_I_BAG];
  slot = this.value[TBAG_I_SLOT];

  HideDropDownMenu(2);
  HideDropDownMenu(1);

  if ( (bag ~= nil) and (slot ~= nil) ) then
    PickupContainerItem(bag, slot);
  else
  message("Error, value not found.");
  end
end

function TBnk_Button_HighlightToggle_OnClick()
  PlaySound("igMainMenuOptionCheckBoxOn");
  if (TBnk_hilight_new == 0) then
  TBnk_hilight_new = 1;
  TBnk_Button_HighlightToggle:SetText(TBag_Loc("TBag_HighlightToggle_on"));
  else
  TBnk_hilight_new = 0;
  TBnk_Button_HighlightToggle:SetText(TBag_Loc("TBag_HighlightToggle_off"));
  end
  TBnk_UpdateWindow();
end

function TBnk_Button_ChangeEditMode_OnClick()
  PlaySound("igMainMenuOptionCheckBoxOn");
  if (TBnk_edit_mode == 0) then
    TBnk_edit_mode = 1;
    TBnk_Button_ChangeEditMode:SetText(TBag_Loc("TBag_ChangeEditMode_on"));
    -- Always hide the purchase info on edit
    TBnk_UpdatePurchaseGfx();
  else
    TBnk_edit_mode = 0;
    TBnk_Button_ChangeEditMode:SetText(TBag_Loc("TBag_ChangeEditMode_off"));
  end

  -- resort will force a window redraw
  TBnk_UpdateWindow(TBAG_REQ_MUST);
end

function TBnk_Button_Reload_OnClick()
  -- To avoid cleaning the bank cache, you only can reload bags at bank.
  if (TBNK_ATBANK==1) then  
    -- Hell, let's be paranoid
    if (TBNK_PLAYERID == TBAG_PLAYERID) then
      TBag_ClearItmCache(TBnkItm[TBNK_PLAYERID], TBnk_Bags);
      TBag_ClearStackSkip(TBnk_Bags);

      -- Send a message to restack
      if (TBnkCfg["stack_resort"] == 1) then
        TBnkCfg["stack_once"] = 1;
      end
    end
  end

  TBnk_UpdateWindow(TBAG_REQ_MUST);
  TBag_PrintDEBUG("TBnk reloaded.");
end

function TBnk_Button_ShowPurchase_OnClick()
 if (TBnkCfg["show_purchase_button"] == 0) then
   TBnkCfg["show_purchase_button"] = 1;
   TBnk_Button_ShowPurchase:SetText(TBag_Loc("TBag_ShowPurchase_off"));
 else
   TBnkCfg["show_purchase_button"] = 0;
   TBnk_Button_ShowPurchase:SetText(TBag_Loc("TBag_ShowPurchase_on"));
 end
 TBnk_UpdatePurchaseGfx();
end

function TBnk_Button_MoveLockToggle_OnClick()
  PlaySound("igMainMenuOptionCheckBoxOn");
  if (TBnkCfg["moveLock"] == 0) then
  TBnkCfg["moveLock"] = 1;
  TBnk_Button_MoveLockToggle:SetText(TBag_Loc("TBag_MoveLock_unlocked"));
  else
  TBnkCfg["moveLock"] = 0;
  TBnk_Button_MoveLockToggle:SetText(TBag_Loc("TBag_MoveLock_locked"));
  end
end

function TBnk_SlotTargetButton_OnClick(button, ignoreShift)
  local bar, tmp;

  if (TBnk_edit_mode == 1) then
  for tmp in string.gmatch(this:GetName(), "TBnkFrame_SlotTarget_(%d+)") do
    bar = tonumber(tmp);
  end

  if ( (bar == nil) or (bar < 1) or (bar > TBAG_BAR_MAX) ) then
    return;
  end

  if ( button == "LeftButton" ) then
    if (TBnk_edit_selected ~= "") then
  -- we got a click, and we already had one selected.  let's move the items
  TBag_SetCatBar(TBnkCfg, TBnk_edit_selected, bar, 1);

  TBnk_edit_selected = "";
  TBnk_edit_hilight = "";

  TBag_BuildBarClassList(TBNK_BC_LIST, TBnkCfg);

    -- resort will force a window redraw as well
      TBnk_UpdateWindow(TBAG_REQ_MUST);
    end

  elseif ( button == "RightButton" ) then
    HideDropDownMenu(1);
    TBnk_RightClickMenu_mode = "slot_target";
    TBnk_RightClickMenu_opts = {
  [TBAG_I_BAR] = bar
  };
    ToggleDropDownMenu(1, nil, TBnkFrame_RightClickMenu, this:GetName(), -50, 0);

  end
  end
end

function TBnk_SlotTargetButton_OnEnter()
  local bar, tmp, key, value;

  if (TBnk_edit_mode == 1) then
    for tmp in string.gmatch(this:GetName(), "TBnkFrame_SlotTarget_(%d+)") do
      bar = tonumber(tmp);
    end

    GameTooltip:SetOwner(this, "ANCHOR_LEFT");
    GameTooltip:ClearLines();

    if (TBnk_edit_selected ~= "") then
      GameTooltip:AddLine("|c"..TBAG_C_INST.."Left click to move category |r|c"
        ..TBAG_C_CAT..TBnk_edit_selected.."|r|c"..TBAG_C_INST.." to bar |r|c"
        ..TBAG_C_BAR..bar.."|r");
    else
      GameTooltip:AddLine("|c"..TBAG_C_INST.."Bar |r|c"
        ..TBAG_C_BAR..bar.."|r");

      GameTooltip:AddLine(" ");
      for key, value in pairs(TBNK_BC_LIST[bar]) do
        GameTooltip:AddLine("|c"..TBAG_C_CAT..value.."|r");
      end
      GameTooltip:AddLine(" ", 1,0,0 );

      GameTooltip:AddLine("Right click for options", 0.8,0.8,0.8 );
    end

    GameTooltip:Show();
    return;
  end

  if ( GameTooltip:IsOwned(this) ) then
    GameTooltip:Hide();
    ResetCursor();
  end
end

function TBnk_SlotTargetButton_OnLeave()
  this.updateTooltip = nil;
  if ( GameTooltip:IsOwned(this) ) then
    GameTooltip:Hide();
    ResetCursor();
  end
end

function TBnk_SlotTargetButton_OnUpdate(elapsed)
  if ( not this.updateTooltip ) then
    return;
  end

  this.updateTooltip = this.updateTooltip - elapsed;
  if ( this.updateTooltip > 0 ) then
    return;
  end

  if ( GameTooltip:IsOwned(this) ) then
    TBnk_SlotTargetButton_OnEnter();
  else
    this.updateTooltip = nil;
  end
end

function TBnk_BankBagButton_OnEnter()
  local bag = this:GetID();
  local itemlink = TBag_GetPlayerBagCfg(TBNK_PLAYERID, bag, TBAG_I_ITEMLINK);

  GameTooltip:SetOwner(this, "ANCHOR_LEFT");
  GameTooltip:ClearLines();

  if (itemlink) then
    GameTooltip:SetHyperlink(itemlink);
  else
    local numSlots, _ = TBag_GetNumBankSlots(TBNK_PLAYERID);

    if (bag <= numSlots + 4) then
      SetItemButtonTextureVertexColor(this, 1.0,1.0,1.0, 1.0);
      GameTooltip:AddLine(BANK_BAG, 1, 1, 1);
    else
      SetItemButtonTextureVertexColor(this, 1.0,0.1,0.1, 1.0);
      GameTooltip:AddLine(BANK_BAG_PURCHASE);
    end
  end
  
  GameTooltip:Show();
end

function TBnk_BankBagButton_OnUpdate(elapsed)
  if ( GameTooltip:IsOwned(this) ) then
    TBnk_BankBagButton_OnEnter();
  else
    this.updateTooltip = nil;
  end
end

function TBnk_RightClick_DeleteItemOverride()
  local bag, slot, itm;

  bag = this.value[TBAG_I_BAG];
  slot = this.value[TBAG_I_SLOT];

  if ( (bag ~= nil) and (slot ~= nil) ) then
  itm = TBnkItm[TBNK_PLAYERID][bag][slot];

  if ( (itm[TBAG_I_ITEMID] ~= nil) and (TBnkCfg["item_overrides"][itm[TBAG_I_ITEMID]] ~= nil) ) then
    TBnkCfg["item_overrides"] = TBag_Table_RemoveKey(TBnkCfg["item_overrides"], itm[TBAG_I_ITEMID] );
    HideDropDownMenu(1);

    -- resort will force a window redraw as well
    TBnk_UpdateWindow(TBAG_REQ_MUST);
  end
  end
end

function TBnk_RightClick_SetItemOverride()
  local bag, slot, itm, new_barclass;

  bag = this.value[TBAG_I_BAG];
  slot = this.value[TBAG_I_SLOT];
  new_barclass = this.value["barclass"];

  if ( (bag ~= nil) and (slot ~= nil) and (new_barclass ~= nil) ) then
  itm = TBnkItm[TBNK_PLAYERID][bag][slot];

  TBnkCfg["item_overrides"][itm[TBAG_I_ITEMID]] = new_barclass;
  HideDropDownMenu(2);
  HideDropDownMenu(1);

  TBnk_UpdateWindow(TBAG_REQ_MUST);
  end
end

function TBnkFrame_RightClickMenu_populate(level)
  local bar, bag, slot;
  local info, itm, barclass, tmp, checked, i;
  local key, value, key2, value2;


  -------------------------------------------------------------------------------------------------
  ------------------------------- ITEM CONTEXT MENU -----------------------------------------------
  -------------------------------------------------------------------------------------------------
  if (TBnk_RightClickMenu_mode == "item") then
  -- we have a right click on a button

  bar = TBnk_RightClickMenu_opts[TBAG_I_BAR];
  bag = TBnk_RightClickMenu_opts[TBAG_I_BAG];
  slot = TBnk_RightClickMenu_opts[TBAG_I_SLOT];
  itm = TBnkItm[TBNK_PLAYERID][bag][slot];

  if (level == 1) then
    -- top level of menu

    info = { ["text"] = itm[TBAG_I_NAME], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);

    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = { ["text"] = "Current Category: "..itm[TBAG_I_CAT], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);

    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = { ["text"] = "Assign item to category:", ["hasArrow"] = 1, ["value"] = "override_placement" };
    if (TBnkCfg["item_overrides"][itm[TBAG_I_ITEMID]] ~= nil) then
  info["checked"] = 1;
    end
    UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = "Use default category assignment",
  ["value"] = { [TBAG_I_BAG]=bag, [TBAG_I_SLOT]=slot },
  ["func"] = TBnk_RightClick_DeleteItemOverride
  };
    if (TBnkCfg["item_overrides"][itm[TBAG_I_ITEMID]] == nil) then
  info["checked"] = 1;
    end
    UIDropDownMenu_AddButton(info, level);

    if (TBnk_SHOWITEMDEBUGINFO==1) then
  info = { ["disabled"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  info = { ["text"] = "Debug Info: ", ["hasArrow"] = 1, ["value"] = "show_debug" };
  UIDropDownMenu_AddButton(info, level);
    end
  elseif (level == 2) then
    if ( this.value == "override_placement" ) then
  for i = 1, TBAG_BAR_MAX do
  info = {
    ["text"] = "Categories within bar "..i;
    ["value"] = { ["opt"]="override_placement_select", [TBAG_I_BAG]=bag, [TBAG_I_SLOT]=slot, ["select_bar"]=i },
    ["hasArrow"] = 1
    };
  if ( (TBnkCfg["item_overrides"][itm[TBAG_I_ITEMID]] ~=
  nil) and (TBag_GetCat(TBnkCfg, TBnkCfg["item_overrides"][itm[TBAG_I_ITEMID]]) == i) ) then
    info["checked"] = 1;
  end
  UIDropDownMenu_AddButton(info, level);
  end
    elseif ( this.value == "show_debug" ) then
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
    if ( this.value ~= nil ) then
  if ( this.value["opt"] == "override_placement_select" ) then
  for key, barclass in pairs(TBNK_BC_LIST[this.value["select_bar"]]) do
    info = {
  ["text"] = barclass;
  ["value"] = { [TBAG_I_BAG]=bag, [TBAG_I_SLOT]=slot, ["barclass"]=barclass },
  ["func"] = TBnk_RightClick_SetItemOverride
  };
    if (TBnkCfg["item_overrides"][itm[TBAG_I_ITEMID]] == barclass) then
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
  elseif (TBnk_RightClickMenu_mode == "slot_target") then
  -- right click on a slot
  bar = TBnk_RightClickMenu_opts[TBAG_I_BAR];

  info = { ["text"] = "|c"..TBAG_C_INST.."Bar |r|c"
      ..TBAG_C_BAR..bar.."|r", ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
  UIDropDownMenu_AddButton(info, level);

  info = { ["disabled"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  for key, value in pairs(TBNK_BC_LIST[bar]) do
    info = {
    ["text"] = "Move: |c"..TBAG_C_CAT..value.."|r";
    ["value"] = value;
    ["func"] = function()
  TBnk_edit_selected = (this.value);
  TBnk_edit_hilight = (this.value);
  TBnk_UpdateWindow();
    end
    };
    UIDropDownMenu_AddButton(info, level);
  end

  info = { ["disabled"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  info = { ["text"] = "Sort Mode:", ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
  UIDropDownMenu_AddButton(info, level);

  for key, value in pairs({
    [TBAG_SORTBY_NONE] = "No sort",
    [TBAG_SORTBY_NORM] = "Sort by name",
    [TBAG_SORTBY_REV] = "Sort last words first"
    }) do
  
    if (TBag_GetGrp(TBnkCfg, TBAG_G_BAR_SORT, bar) == key) then
      checked = 1;
    else
      checked = nil;
    end
    info = {
  ["text"] = value;
  ["value"] = { [TBAG_I_BAR]=bar, ["sortby"]=key };
  ["func"] = function()
    TBag_SetGrpDef(TBnkCfg, TBAG_G_BAR_SORT, this.value[TBAG_I_BAR], this.value["sortby"], 1);
    TBnk_UpdateWindow(TBAG_REQ_MUST);    
  end,
  ["checked"] = checked
  };
    UIDropDownMenu_AddButton(info, level);
  end

  info = { ["disabled"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  info = { ["text"] = "Hilight new items:", ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
  UIDropDownMenu_AddButton(info, level);

  for key,value in pairs({
    [0] = "Don't tag new items",
    [1] = "Tag new items"
    }) do

    if (TBag_GetGrp(TBnkCfg, TBAG_G_USE_NEW, bar) == key) then
      checked = 1;
    else
      checked = nil;
    end

    info = {
      ["text"] = value;
      ["value"] = { [TBAG_I_BAR]=bar, ["value"]=key };
      ["func"] = function()
        TBag_SetGrpDef(TBnkCfg, TBAG_G_USE_NEW, this.value[TBAG_I_BAR], this.value["value"], 1);
        TBnk_UpdateWindow();
    end,
  ["checked"] = checked
  };
    UIDropDownMenu_AddButton(info, level);
  end

  info = { ["disabled"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  info = { ["text"] = "Color:", ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
  UIDropDownMenu_AddButton(info, level);

  info = TBag_MakeColorPickerInfo(TBnkCfg, "bkgr_", bar,
    "Background Color for Bar "..bar, TBnk_UpdateWindow);
  UIDropDownMenu_AddButton(info, level);

  info = TBag_MakeColorPickerInfo(TBnkCfg, "brdr_", bar,
    "Border Color for Bar "..bar, TBnk_UpdateWindow);
  UIDropDownMenu_AddButton(info, level);

  -------------------------------------------------------------------------------------------------
  ------------------------ MAIN WINDOW CONTEXT MENU -----------------------------------------------
  -------------------------------------------------------------------------------------------------
  elseif (TBnk_RightClickMenu_mode == "mainwindow") then
  if (level == 1) then

    info = { ["text"] = TBag_Loc("TBag_MenuTitle"), ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);


    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = "Edit Mode",
  ["value"] = nil,
  ["func"] = TBnk_Button_ChangeEditMode_OnClick
  };
    if (TBnk_edit_mode == 1) then
      info["checked"] = 1;
    end
    UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = "Lock window",
  ["value"] = nil,
  ["func"] = TBnk_Button_MoveLockToggle_OnClick
  };
    if (TBnkCfg["moveLock"] == 0) then
  info["checked"] = 1;
    end
    UIDropDownMenu_AddButton(info, level);

  info = {
  ["text"] = "Reload bags",
  ["value"] = nil,
  ["func"] = TBnk_Button_Reload_OnClick
  };
  UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = "Show Purchase Info",
  ["value"] = nil,
  ["func"] = TBnk_Button_ShowPurchase_OnClick
  };
  if (TBnkCfg["show_purchase_button"] == 1) then
    info["checked"] = 1;
  end
  UIDropDownMenu_AddButton(info, level);

    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = "Hilight New Items",
  ["value"] = nil,
  ["func"] = TBnk_Button_HighlightToggle_OnClick
  };
    if (TBnk_hilight_new == 1) then
      info["checked"] = 1;
    end
    UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = "Reset NEW tag",
  ["value"] = nil,
  ["func"] = function()
    local bag, slot, index;

    for index, bag in ipairs(TBnk_Bags) do
      if (TBnkCfg["show_Bag"..bag] == 1) then
        if (table.getn(TBnkItm[TBNK_PLAYERID][bag]) > 0) then
          for slot = 1, table.getn(TBnkItm[TBNK_PLAYERID][bag]) do
            TBag_ResetNew(TBnkItm[TBNK_PLAYERID][bag][slot]);
          end
        end
      end
    end

    TBnk_UpdateWindow();
  end
  };
    UIDropDownMenu_AddButton(info, level);

  info = { ["disabled"] = 1 };
  UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = "Advanced Configuration",
  ["value"] = nil,
  ["func"] = function()
    TBnk_OptsFrame:Show();
  end
  };
    UIDropDownMenu_AddButton(info, level);

    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    
    info = {
      ["text"] = "Set Size";
      ["value"] = { ["opt"]="set_scale" },
      ["hasArrow"] = 1
    };
    UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = "Set Colors";
        ["value"] = { ["opt"]="set_colors" },
        ["hasArrow"] = 1
        };
      UIDropDownMenu_AddButton(info, level);

    elseif (level == 2) then
      if (this.value ~= nil) then
        if (this.value["opt"] == "set_scale") then
          for _, value in ipairs(TBAG_A_BUTTONSIZE) do
            info = {
              ["text"] = value.."x"..value;
              ["value"] = value;
              ["func"] = function()
                if ( (type(this.value) == "number") and (this.value >= TBAG_N_BUTTON_MIN) ) then
                    TBnkCfg["frameButtonSize"], TBnkCfg["count_font"], 
                      TBnkCfg["count_font_x"], TBnkCfg["count_font_y"],
                      TBnkCfg["scale"] = TBag_NicePlacement(this.value);
                  TBnk_CalcButtonSize(TBnkCfg["frameButtonSize"], TBnkCfg["framePad"]);
                  TBnk_UpdateWindow(TBAG_REQ_MUST);
                end
              end
            };
            if (tonumber(TBnkCfg["frameButtonSize"]*TBnkCfg["scale"] - value)
      < 1.0) and (tonumber(TBnkCfg["frameButtonSize"]*TBnkCfg["scale"] - value)
      > -1.0) then
              info["checked"] = 1;
            end
            UIDropDownMenu_AddButton(info, level);
          end
        elseif (this.value["opt"] == "set_colors") then
          TBag_MakeColorMenu(TBnkCfg, TBnk_UpdateWindow, level, TBnk_Bags);
        end
      end
    end
  end
end


-- Main "right click menu"
function TBnkFrame_RightClickMenu_OnLoad()
  UIDropDownMenu_Initialize(this, TBnkFrame_RightClickMenu_populate, "MENU");
end


function TBnk_IncreaseColumns()
  if (TBnkCfg["maxColumns"] < TBAG_NUMCOL_MAX) then
    TBnkCfg["maxColumns"] = TBnkCfg["maxColumns"] + 1;
    TBnk_UpdateWindow(TBAG_REQ_MUST);
  end
end

function TBnk_DecreaseColumns()
  if (TBnkCfg["maxColumns"] > TBAG_NUMCOL_MIN) then
    TBnkCfg["maxColumns"] = TBnkCfg["maxColumns"] - 1;
    TBnk_UpdateWindow(TBAG_REQ_MUST);
  end
end

-- bar == current bar
-- frame == name of background frame to be relative to
-- width/height == max number of buttons to place into frame
function TBnk_AssignButtonsToFrame(barnum, frame, width, height)
  local cur_x, cur_y, tmpframe;
  local buttonname;
  local bag, slot;

  cur_x = 0;
  cur_y = 0;

  if (table.getn(TBNK_BARITM[barnum]) > 0) then
    for position = 1, table.getn(TBNK_BARITM[barnum]) do
      bag = TBNK_BARITM[barnum][position][TBAG_I_BAG];
      slot = TBNK_BARITM[barnum][position][TBAG_I_SLOT];
      buttonname = TBag_GetBagItemButtonName(bag, slot);

      TBag_PositionFrame(buttonname, "BOTTOMRIGHT", frame, "BOTTOMRIGHT",
        0-(TBnk_FrameX(cur_x)+TBNK_BF_X_PAD), (TBnk_FrameY(cur_y)+TBNK_BF_Y_PAD),
        TBNK_BF_WIDTH, TBNK_BF_HEIGHT );

      TBag_PositionFrame(buttonname.."_bkgr", "TOPLEFT", buttonname, "TOPLEFT",
        0-TBNK_BF_X_PAD, TBNK_BF_Y_PAD,
        TBNK_BGF_WIDTH, TBNK_BGF_HEIGHT );

      local frame_normaltexture = getglobal(buttonname.."NormalTexture");

      -- resize frame texture (this is the little border)
      frame_normaltexture:SetWidth(TBNK_BGF_WIDTH);
      frame_normaltexture:SetHeight(TBNK_BGF_HEIGHT);

      -- First, relink the button map
      TBAG_BUTTONS[buttonname] = TBnkItm[TBNK_PLAYERID][bag][slot];

      cur_x = cur_x + 1;
      if (cur_x == width) then
        cur_x = 0;
        cur_y = cur_y + 1;
      end
    end
  end

  if (TBnk_edit_mode == 1) then
    buttonname = "TBnkFrame_SlotTarget_"..barnum;

    -- add extra button for targetting
    TBag_PositionFrame(buttonname, "BOTTOMRIGHT", frame, "BOTTOMRIGHT",
      0-(TBnk_FrameX(width-1)+TBNK_BF_X_PAD), (TBnk_FrameY(height-1)+TBNK_BF_Y_PAD),
      TBNK_BF_WIDTH, TBNK_BF_HEIGHT );

    TBag_PositionFrame(buttonname.."_bkgr", "TOPLEFT", buttonname, "TOPLEFT",
      0-TBNK_BF_X_PAD, TBNK_BF_Y_PAD,
      TBNK_BGF_WIDTH, TBNK_BGF_HEIGHT );
  
    local frame_normaltexture = getglobal(buttonname.."NormalTexture");
    frame_normaltexture:SetWidth(TBNK_BGF_WIDTH);
    frame_normaltexture:SetHeight(TBNK_BGF_HEIGHT);

    tmpframe = getglobal(buttonname.."_BigText");
    tmpframe:SetText(barnum);
    tmpframe:Show();
    tmpframe = getglobal(buttonname.."_bkgr");
    tmpframe:SetVertexColor( 1,0,0.25, 0.5 );
    tmpframe:Show();
  end
end


TBnk_WindowIsUpdating = 0;

function TBnk_UpdateWindow(resort_req)
  local frame = getglobal("TBnkFrame");
  local barnum;
  local cur_y;

  TBag_PrintDEBUG("TBnk_UpdateWindow(): WindowIsUpdating="..TBnk_WindowIsUpdating);

  if (TBnk_WindowIsUpdating == 1) then
    return;
  end
  TBnk_WindowIsUpdating = 1;

  if ( not frame:IsVisible() ) then
    TBnk_WindowIsUpdating = 0;
    return;
  end

  -- Set the overall scale
  TBnkFrame:SetScale(TBnkCfg["scale"]);

  if (resort_req == nil) then resort_req = TBAG_REQ_NONE; end

  -- Show some things only when we are at then bank
  if (TBNK_ATBANK == 1) then
    TBnk_UserDropdown:Hide();
  else
    TBnk_UserDropdown:Show();
  end

  -- SORTING

  -- Consume a message from updated craft info
  if (TBagCfg["trades_changed"] == 1) then
    resort_req = TBAG_REQ_MUST;
  end
  TBagCfg["trades_changed"] = 0;

  -- Always set the class cats for this player's class
  TBag_SetClassCats(TBnkCfg, TBNK_PLAYERID, 1);
  local cache_req, stackarr = TBag_UpdateItmCache(TBnkCfg, TBNK_PLAYERID, TBnkItm[TBNK_PLAYERID], TBnk_Bags, TBNK_ATBANK);
  resort_req = resort_req + cache_req;

  -- Consume a message for bag stacking
  if (TBnkCfg["stack_once"] == 1) then
    if (TBNK_PLAYERID == TBAG_PLAYERID) then
      TBag_Stack(TBnkItm[TBNK_PLAYERID], stackarr);
    end
  end
  TBnkCfg["stack_once"] = 0;

  if (resort_req >= TBAG_REQ_MUST) then
    TBNK_BARITM = TBag_SortItmCache(TBnkCfg, 
      TBNK_PLAYERID, TBnkItm[TBNK_PLAYERID], TBNK_BARITM, TBnk_Bags);
    TBag_LayoutWindow(TBnkCfg, "TBnkFrame", TBNK_BARITM, TBnkCfg["bar_x"],
      TBnk_edit_mode, TBNK_BUTTON_MAX, TBnk_AssignButtonsToFrame, 
      TBnk_FrameX, TBnk_FrameY, TBnk_SpaceX, TBnk_SpaceY, TBnk_PoolX, TBnk_PoolY)
  end

  -- Relink the button map
  local position;
  for barnum = 1, TBnkCfg["bar_x"] * TBag_GetBarY(TBnkCfg["bar_x"]) do
    if (table.getn(TBNK_BARITM[barnum]) > 0) then
      for position = 1, table.getn(TBNK_BARITM[barnum]) do
        TBAG_BUTTONS[TBag_GetBagItemButtonName(TBNK_BARITM[barnum][position][TBAG_I_BAG], TBNK_BARITM[barnum][position][TBAG_I_SLOT])] =
          TBnkItm[TBNK_PLAYERID][TBNK_BARITM[barnum][position][TBAG_I_BAG]][TBNK_BARITM[barnum][position][TBAG_I_SLOT]];
      end
    end
  end

  -- BAGS, to get bag sizes below
  TBnk_UpdateBagGfx();

  -- Update all the buttons
  for _, bag in ipairs(TBnk_Bags) do
    local size = TBag_GetPlayerBagCfg(TBNK_PLAYERID, bag, TBAG_I_BAGSIZE);
    if (not size) then size = 0; end
    if (TBnkCfg["show_Bag"..bag] ~= 1) then size = 0; end
    for slot = 1, size do
      TBag_UpdateButton(TBnkCfg, TBNK_PLAYERID,
        TBag_GetBagItemButtonName(bag, slot),
        TBnk_edit_mode, TBnk_edit_hilight, TBnk_hilight_new)
    end
    for slot = size+1, TBAG_BAGSIZE_MAX do
      getglobal(TBag_GetBagItemButtonName(bag, slot)):Hide();
    end
  end

  -- MONEY
  MoneyFrame_Update("TBnk_MoneyViewFrame", TBag_GetMoney(TBNK_PLAYERID));
  if (TBNK_PLAYERID == TBAG_PLAYERID) then
    TBnk_MoneyViewFrame:Hide();
    TBnk_MoneyFrame:Show();
  else
    TBnk_MoneyFrame:Hide();
    TBnk_MoneyViewFrame:Show();
  end
  TBnk_UpdatePurchaseGfx();

  frame:ClearAllPoints();
  frame:SetPoint(TBnkCfg["frameYRelativeTo"]..TBnkCfg["frameXRelativeTo"],
    "UIParent", "BOTTOMLEFT",
    TBnkCfg["frame"..TBnkCfg["frameXRelativeTo"]] / frame:GetScale(),
    TBnkCfg["frame"..TBnkCfg["frameYRelativeTo"]] / frame:GetScale());

  TBag_ColorFrame(TBnkCfg, frame, TBAG_MAIN_BAR);

  if (TBnk_edit_mode == 1) then
    TBnk_Button_ColumnsAdd:SetText(TBag_Loc("TBag_ColumnsAdd_buttontitle"));
    TBnk_Button_ColumnsAdd:Show();
    TBnk_Button_ColumnsDel:SetText(TBag_Loc("TBag_ColumnsDel_buttontitle"));
    TBnk_Button_ColumnsDel:Show();
  else
    TBnk_Button_ColumnsAdd:Hide();
    TBnk_Button_ColumnsDel:Hide();
  end

  if (TBnkCfg["show_top_graphics"] == 1) then
    TBnkFramePortrait:Show();
    TBnkFrameTitleText:Show();

    TBnkFrameTextureTopLeft:Show();
    TBnkFrameTextureTopCenter:Show();
    TBnkFrameTextureTopRight:Show();
    TBnkFrameTextureLeft:Show();
    TBnkFrameTextureRight:Show();
    TBnkFrameTextureBottomLeft:Show();
    TBnkFrameTextureBottomCenter:Show();
    TBnkFrameTextureBottomRight:Show();
  else
    TBnkFramePortrait:Hide();
    TBnkFrameTitleText:Hide();

    TBnkFrameTextureTopLeft:Hide();
    TBnkFrameTextureTopCenter:Hide();
    TBnkFrameTextureTopRight:Hide();
    TBnkFrameTextureLeft:Hide();
    TBnkFrameTextureRight:Hide();
    TBnkFrameTextureBottomLeft:Hide();
    TBnkFrameTextureBottomCenter:Hide();
    TBnkFrameTextureBottomRight:Hide();
  end

  TBnk_WindowIsUpdating = 0;
end


function TBnk_SetReplaceBank()
  if BankFrame_Saved == nil then
    BankFrame_Saved = getglobal("BankFrame");
  end
  if BankFrame_Saved:IsVisible() then
    BankFrame_Saved:Hide();
  end
  BankFrame_Saved:UnregisterEvent("BANKFRAME_OPENED");
  BankFrame_Saved:UnregisterEvent("BANKFRAME_CLOSED");
end


function TBnk_UserDropdown_GetValue()
  if ( TBNK_PLAYERID ) then
    return TBNK_PLAYERID;
  else
    return TBAG_PLAYERID;
  end
end

function TBnk_UserDropdown_OnLoad()
  UIDropDownMenu_Initialize(this, TBnk_UserDropdown_Initialize);
  UIDropDownMenu_SetSelectedValue(this, TBAG_PLAYERID);
  TBnk_UserDropdown.tooltip = "You are viewing this player's bank.";
  UIDropDownMenu_SetWidth(TBAG_USERDD_WIDTH, TBnk_UserDropdown);
--  OptionsFrame_EnableDropDown(TBnk_UserDropdown);
end

function TBnk_UserDropdown_Initialize()
  TBag_UserDropdown_Init(TBnk_UserDropdown_OnClick,
    TBnkItm, TBAG_REALM);
end

function TBnk_UserDropdown_OnClick()
  UIDropDownMenu_SetSelectedValue(TBnk_UserDropdown, this.value);
  if ( this.value ) then
    TBnk_SetPlayer(this.value);
  end
  if ( not TBNK_PLAYERID ) then
    TBag_PrintDEBUG("UserDropdown_OnClick Failed");
    return;
  end
  TBag_PrintDEBUG("Selected Player "..TBNK_PLAYERID);
  -- Show in whatever state the cache was in before
  TBNK_ATBANK = 0;
  TBnk_UpdateWindow(TBAG_REQ_MUST);
end
