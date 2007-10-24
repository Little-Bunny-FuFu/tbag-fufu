BINDING_NAME_TINV_TOGGLE = "Toggle Inventory Window";

-- Constants
TINV_DEBUGMESSAGES = 0;   -- 0 = off, 1 = on
TINV_SHOWITEMDEBUGINFO = 0;
local TINV_WIPECONFIGONLOAD = 0;  -- for debugging, test it out on a new config every load

-- View switching
TINV_PLAYERID = "";

TINV_BUTTON_MAX = 109;

TINV_PAD_TOP_GFX = 63;
TINV_PAD_TOP_NORM = 25;
TINV_BORDER = 2;

TInvCfg = nil;
TINV_BARITM = {};
TInv_hilight_new = 0;
TInv_edit_mode = 0;
TInv_edit_hilight = "";   -- when editmode is 1, which items do you want to hilight
TInv_edit_selected = "";  -- when editmode is 1, this is the class of item you clicked on
TInv_RightClickMenu_mode = "";
TInv_RightClickMenu_opts = {};

-- These are categories to leave off the right click menu.  just trying to make space

TINV_BC_LIST = {};  -- Bar to Class conversion

local TINV_BF_X_PAD = 1;
local TINV_BF_Y_PAD = 1;
local TINV_BF_WIDTH = 34;
local TINV_BF_HEIGHT = 34;
local TINV_BF_PADWIDTH = 36;
local TINV_BF_PADHEIGHT = 36;
local TINV_BGF_WIDTH = 38;
local TINV_BGF_HEIGHT = 38;

-- Param functions

function TInv_FrameX(width)
  return (width * (TINV_BF_PADWIDTH + TInvCfg["frameXSpace"]))
  + TInvCfg["frameXSpace"];
end

function TInv_FrameY(height)
  return (height * (TINV_BF_PADHEIGHT + TInvCfg["frameYSpace"]))
  + TInvCfg["frameYSpace"];
end

function TInv_SpaceX(space)
  return (space * (TInvCfg["frameXSpace"]));
end

function TInv_SpaceY(space)
  return (space * (TInvCfg["frameYSpace"]));
end

function TInv_PoolX(space)
  return (space * (TInvCfg["frameXPool"]));
end

function TInv_PoolY(space)
  return (space * (TInvCfg["frameYPool"]));
end

------------------------

function TInv_CalcButtonSize(newsize, pad)
  -- constants
  TINV_BF_X_PAD = pad;
  TINV_BF_Y_PAD = pad;
  TINV_BF_WIDTH = newsize;
  TINV_BF_HEIGHT = newsize;
  TINV_BF_PADWIDTH = TINV_BF_WIDTH + (TINV_BF_X_PAD*2);
  TINV_BF_PADHEIGHT = TINV_BF_HEIGHT + (TINV_BF_Y_PAD*2);
  TINV_BGF_WIDTH = TINV_BF_WIDTH * 1.6 + (TINV_BF_X_PAD*2);
  TINV_BGF_HEIGHT = TINV_BF_HEIGHT * 1.6 + (TINV_BF_Y_PAD*2);

  -- Always ensure a visually appealing fit
  TINV_BGF_WIDTH = TBag_MakeEven(TINV_BGF_WIDTH, TINV_BF_WIDTH);
  TINV_BGF_HEIGHT = TBag_MakeEven(TINV_BGF_HEIGHT, TINV_BF_HEIGHT);
end

-- set reset to 1 to restore all default values
function TInv_InitDefVals(reset)
  local i, key, value;
  local cfg = TInvCfg;

  TBag_InitDefVals(cfg, TInv_Bags, 0, reset);

  TBag_SetDef(cfg, "maxColumns", 11, reset, TBag_NumFunc, TBAG_NUMCOL_MIN,TBAG_NUMCOL_MAX);

  TBag_SetDef(cfg, "alt_pickup", 1, reset, TBag_NumFunc, 0, 1);
  TBag_SetDef(cfg, "alt_panel", 1, reset, TBag_NumFunc, 0, 1);

  TBag_SetDef(cfg, "show_keyring_empty_slots", 0, reset, TBag_NumFunc, 0, 1);

  -- Colors
  TBag_SetColor(cfg, "bkgr_"..TBAG_MAIN_BAR, 0.0, 0.2, 0.4, 0.4, reset);
  TBag_SetColor(cfg, "brdr_"..TBAG_MAIN_BAR, 0.2, 0.2, 1.0, 0.3, reset);
  for i = 1, TBAG_BAR_MAX do
    TBag_SetColor(cfg, "bkgr_"..i, 0.0, 0.2, 0.4, 0.4, reset);
    TBag_SetColor(cfg, "brdr_"..i, 0.2, 0.2, 1.0, 0.3, reset);
  end
  TBag_SetDefColors(cfg, reset);

  TBag_SetDef(cfg, "frameLEFT", UIParent:GetRight() * UIParent:GetScale() * 0.73, reset, TBag_NumFunc);
  TBag_SetDef(cfg, "frameRIGHT", UIParent:GetRight() * UIParent:GetScale() * 0.92, reset, TBag_NumFunc);
  TBag_SetDef(cfg, "frameTOP", UIParent:GetTop() * UIParent:GetScale() * 0.83, reset, TBag_NumFunc);
  TBag_SetDef(cfg, "frameBOTTOM", UIParent:GetTop() * UIParent:GetScale() * 0.232, reset, TBag_NumFunc);
  TBag_SetDef(cfg, "frameXRelativeTo", "LEFT", reset, TBag_StrFunc, {"RIGHT","LEFT"} );
  TBag_SetDef(cfg, "frameYRelativeTo", "BOTTOM", reset, TBag_StrFunc, {"TOP","BOTTOM"} );

  TInv_CalcButtonSize(TInvCfg["frameButtonSize"], TInvCfg["framePad"]);
end

function TInv_SetPlayer(playerid)
  TINV_PLAYERID = playerid;
end

local TINV_FRAMENAME = "TInvFrame";
local TINV_SLOTTARGET = TINV_FRAMENAME.."SlotTarget";

-- Set reset = 1 to restore default values
function TInv_init(reset)
  TBag_Init();
  TInvCfg = TBagCfg["Inv"];

  if ( TINV_WIPECONFIGONLOAD == 1 ) then
    TBagCfg["Inv"] = {};
  end

  TInv_SetPlayer(TBAG_PLAYERID);

  -- Make all the frames
  for _, bag in ipairs(TInv_Bags) do
    TBag_CreateDummyBag(bag, "TInv_ItemButtonTemplate");
  end

  TBag_CreateFrame("Frame", "TInvFrame_bar_", getglobal("TInvFrame"),
    "TBag_BarFrameTemplate", TBAG_BAR_MAX, "");
  TBag_CreateFrame("Button", "TInvFrame_SlotTarget_", getglobal("TInvFrame"),
    "TInv_SlotTargetTemplate", TBAG_BAR_MAX, "");

  -- change imported from auctioneer team..  what does it do?
  UIPanelWindows["TInvFrame"] = { area = "left", pushable = 6 };

  -- register slash command
  SlashCmdList["TINV"] = TInv_cmd;
  SLASH_TINV1 = "/tinv";
  SLASH_TINV2 = "/tbag";

  -- load default values
  TInv_InitDefVals(reset);

  for _, bag in ipairs(TInv_Bags) do
    TBag_GetBagFrame(bag):SetScale(0.7);
    TBag_GetBagNumFrame(bag):SetScale(1.3);
  end

  SetPortraitTexture(TInvFramePortrait, "player");

  TInv_SearchBox:SetMaxLetters(25);

  -- setup hooks
  TInvHooks_Register(TBAG_HOOK_UNREGISTER);
  TInvHooks_Register(TBAG_HOOK_REGISTER);

  TInv_Button_HighlightToggle:SetText(TBag_Loc("TBag_HighlightToggle_off"));
  TInv_Button_ChangeEditMode:SetText(TBag_Loc("TBag_ChangeEditMode_off"));

  if (TInvCfg["moveLock"] == 0) then
    TInv_Button_MoveLockToggle:SetText(TBag_Loc("TBag_MoveLock_locked"));
  else
    TInv_Button_MoveLockToggle:SetText(TBag_Loc("TBag_MoveLock_unlocked"));
  end

  TBag_BuildBarClassList(TINV_BC_LIST, TInvCfg);

  -- Force update item cache.
  TBag_ClearItmCache(TInvItm[TINV_PLAYERID], TInv_Bags);
  TBag_UpdateItmCache(TInvCfg, TINV_PLAYERID, TInvItm[TINV_PLAYERID], TInv_Bags);

  TINV_BARITM = TBag_SortItmCache(TInvCfg, 
    TINV_PLAYERID, TInvItm[TINV_PLAYERID], TINV_BARITM, TInv_Bags);
  TBag_LayoutWindow(TInvCfg, "TInvFrame", TINV_BARITM, TInvCfg["bar_x"], 
    TInv_edit_mode, TINV_BUTTON_MAX, TInv_AssignButtonsToFrame, 
    TInv_FrameX, TInv_FrameY, TInv_SpaceX, TInv_SpaceY, TInv_PoolX, TInv_PoolY)
end

function TInv_UpdateBagGfx()
  local bag;
  local totalfree = 0;
  local totalsize = 0;
  for _, bag in ipairs(TInv_Bags) do
    local free, size = TBag_UpdateSlots(TINV_PLAYERID, "TInvNum", bag, TInvCfg["show_bag_sizes"]);
    local type = TBag_GetBagType(TINV_PLAYERID, bag);
    if (type ~= "AMMO") and (type ~= "SOUL") and (type ~= "KEYRING") then
      totalfree = totalfree + free;
      totalsize = totalsize + size;
    end
      
    -- Update the textures as well
    if (bag > 0) then
      TBag_GetBagFrameTexture(bag):SetTexture(
        TBag_GetBagTexture(TINV_PLAYERID, bag));
    end

    TBag_UpdateBagColors(bag);
  end
  TBag_SetFreeStr(getglobal("TInvNumTotalText"), totalfree, totalsize, TInvCfg["show_bag_sizes"]);
end

function TInv_OnEvent(event)
  -- TBag_Print("TInv_Event: '"..event.."'");

  if ( TInvFrame:IsVisible() ) then
    if ( event == "BAG_UPDATE" ) then
      -- Stack the bags if we are in a state to
      if (CursorHasItem() == nil and CursorHasMoney() == nil and CursorHasSpell() == nil and TBag_IsStacking() == nil) then
        -- Stack the bags if configured to
        if (TInvCfg["stack_auto"] == 1) then
          if (TINV_PLAYERID == TBAG_PLAYERID) then
            -- Send a message to restack
            TInvCfg["stack_once"] = 1;
          end
        end
      end
      TInv_UpdateWindow();
    elseif ( event == "BAG_UPDATE_COOLDOWN" ) then
      TInv_UpdateWindow();
    elseif ( event == "ITEM_LOCK_CHANGED" ) then
      TInv_UpdateWindow();
--    elseif ( event == "AUCTION_HOUSE_CLOSED" ) then
--      TInv_Close();
--    elseif ( event == "BANKFRAME_CLOSED" ) then
--      TInv_Close();
--    elseif ( event == "MERCHANT_CLOSED" ) then
--      TInv_Close();
--  elseif ( event == "TRADE_CLOSED" ) then
--    TInv_Close();
    else
      TBag_PrintDEBUG("TInv_Event: Visible dropthru.");
    end
  else
    if ( event == "AUCTION_HOUSE_SHOW" ) then
      TInv_Open();
--    elseif ( event == "BANKFRAME_OPENED" ) then
--      TInv_Open();
    elseif ( event == "MAIL_SHOW" ) then
      TInv_Open();
    elseif ( event == "MERCHANT_SHOW" ) then
      TInv_Open();
--    elseif ( event == "TRADE_SHOW" ) then
--      TInv_Open();
    else
      TBag_PrintDEBUG("TInv_Event: Hidden dropthru.");
    end
  end

  -- Handle these irrespective of window state
  if ( event == "CRAFT_SHOW" ) then
    TBag_Craft();
  elseif ( event == "TRADE_SKILL_SHOW" ) then
    TBag_Trade();
  elseif ( event == "UPDATE_INVENTORY_ALERTS" ) then
    TBag_ScanEquipped();
  elseif ( event == "UNIT_INVENTORY_CHANGED" ) then
    TBag_ScanEquipped();
    TInv_UpdateWindow();
  elseif ( event == "MAIL_INBOX_UPDATE" ) then
    TBag_ScanMail();
  end

  TBag_PrintDEBUG("TInv_Event: Finished "..event);
end

function TInv_StartMoving(frame)
  if ( not frame.isMoving ) and ( TInvCfg["moveLock"] == 1 ) then
    frame:StartMoving();
    frame.isMoving = true;
  end
end

function TInv_StopMoving(frame)
  if ( frame.isMoving ) then
    frame:StopMovingOrSizing();
    frame.isMoving = false;

    -- save the position
    TInvCfg["frameLEFT"] = frame:GetLeft() * frame:GetScale();
    TInvCfg["frameRIGHT"] = frame:GetRight() * frame:GetScale();
    TInvCfg["frameTOP"] = frame:GetTop() * frame:GetScale();
    TInvCfg["frameBOTTOM"] = frame:GetBottom() * frame:GetScale();

    TBag_PrintDEBUG("new position:  top="..TInvCfg["frameTOP"]..", bottom="..TInvCfg["frameBOTTOM"]..", left="..TInvCfg["frameLEFT"]..", right="..TInvCfg["frameRIGHT"] );
  end
end

function TInv_OnMouseDown(button, frame)

  if ( button == "LeftButton" ) then
    TInv_StartMoving(frame);
  elseif ( button == "RightButton" ) then
    HideDropDownMenu(1);
    TInv_RightClickMenu_mode = "mainwindow";
    TInv_RightClickMenu_opts = {};
    ToggleDropDownMenu(1, nil, TInvFrame_RightClickMenu, "cursor", 0, 0);
  end
end


function TInv_SetBarFromClass(itm)
  itm[TBAG_I_BAR] = TBag_GetCat(TInvCfg, itm[TBAG_I_CAT]);
  while (type(itm[TBAG_I_BAR]) ~= "number") do
    itm[TBAG_I_BAR] = TBag_GetCat(TInvCfg, itm[TBAG_I_BAR]);
  end
  return itm[TBAG_I_BAR];
end

function TInv_ItemButton_OnEnter()
  local itm = TBag_GetItmFromFrame(TBAG_BUTTONS, this:GetName());
  local hasCooldown, repairCost;
  local bar;
  if (itm ~= nil) then
    bar = itm[TBAG_I_BAR];
  end

  -- TBag_Print("TInv_ItemButton_OnEnter bag="..itm[TBAG_I_BAG]..", slot="..itm[TBAG_I_SLOT]);

  if (TInv_edit_selected == "") then
    TInv_edit_hilight = itm[TBAG_I_CAT];
  end

  if ( not itm[TBAG_I_ITEMLINK]) then
    if ( TInv_edit_mode == 1 ) then
      GameTooltip:SetOwner(this, "ANCHOR_LEFT");
      GameTooltip:ClearLines();
      GameTooltip:AddLine("Empty Slot", 1,1,1 );

      -- move by class
      if (itm[TBAG_I_CAT] ~= nil) then
        if (TInv_edit_selected ~= "") then
--          GameTooltip:AddLine("|cFF00FF7FLeft click to move category |r"..TInv_edit_selected.."|cFF00FF7F to bar |r"..bar, 1,0.25,0.5 );
        else
--          GameTooltip:AddLine("|cFF00FF7FLeft click to select category to move:|r "..itm[TBAG_I_CAT], 1,0.25,0.5 );
        end
      else
        GameTooltip:AddLine("error: Item has no category", 1,0,0 );
      end

      GameTooltip:Show();
    else
      GameTooltip:Hide();
    end
    if ( TInv_edit_mode == 1 ) then
      -- redraw the window to show the hilighting of entire class items
      TInv_UpdateWindow();
    end
    return;
  end

  -- Tool Tip Anchor: Anchor Right if the frame is on the left side of the screen else Anchor Left.
  if (TInvCfg["frameLEFT"] < GetScreenWidth()/2) then
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
  else
    GameTooltip:SetOwner(this, "ANCHOR_LEFT");
  end

  hasCooldown, repairCost = TBag_SetInventoryItem(GameTooltip, TINV_PLAYERID, 
    itm[TBAG_I_ITEMLINK], itm[TBAG_I_BAG], itm[TBAG_I_SLOT]);

  --[[
  if ( hasCooldown ) then
    this.updateTooltip = 1;
  else
    this.updateTooltip = nil;
  end
  --]]

  if ( InRepairMode() and (repairCost and repairCost > 0) ) then
    GameTooltip:AddLine(TEXT(REPAIR_COST), 1, 1, 1);
    SetTooltipMoney(GameTooltip, repairCost);
    GameTooltip:Show();
  elseif ( MerchantFrame:IsVisible() ) then
    ShowContainerSellCursor(itm[TBAG_I_BAG], itm[TBAG_I_SLOT]);
--    TBag_RegisterCurrentTooltipSellValue(GameTooltip, itm[TBAG_I_BAG], itm[TBAG_I_SLOT], itm);
  elseif ( this.readable or (IsControlKeyDown() and this.hasItem) ) then
    ShowInspectCursor();
  else
    ResetCursor();
  end

  if ( IsShiftKeyDown() ) then
    GameTooltip_ShowCompareItem();
  end

  if ( TInv_edit_mode == 1 ) then
    -- move by class
    if (itm[TBAG_I_CAT] ~= nil) then
      if (TInv_edit_selected ~= "") then
--        GameTooltip:AddLine("|cFF00FF7FLeft click to move category |r"..TInv_edit_selected.."|cFF00FF7F to bar |r"..bar, 1,0.25,0.5 );
      else
--        GameTooltip:AddLine(" ", 0,0,0);
--        GameTooltip:AddLine("|cFF00FF7FLeft click to select category to move:|r "..itm[TBAG_I_CAT], 1,0.25,0.5 );
--        GameTooltip:AddLine("Right click to assign this item to a different category", 1,0,0 );
--        GameTooltip:AddLine(" ", 0,0,0);
      end
    else
      GameTooltip:AddLine("Item has no category", 1,0,0 );
    end
  end

  -- Then do a highlight to show the bag
  if (itm[TBAG_I_BAG] ~= KEYRING_CONTAINER) and (TInvCfg["spotlight_hover"] == 1) then
    local r, g, b, a = TBag_GetColor(TInvCfg, "bag_"..itm[TBAG_I_BAG]);
    TBag_GetBagFrameSpotlight(itm[TBAG_I_BAG]):SetVertexColor(r, g, b, a);
    TBag_GetBagFrameSpotlight(itm[TBAG_I_BAG]):Show();
  end

  if ( TInv_edit_mode == 1 ) then
    -- redraw the window to show the hllighting of entire class items
    TInv_UpdateWindow();
  end
end

function TInv_ItemButton_OnUpdate(elapsed)
  --[[
  if ( not this.updateTooltip ) then
    return;
  end

  this.updateTooltip = this.updateTooltip - elapsed;
  if ( this.updateTooltip > 0 ) then
    return;
  end
  --]]

  if ( GameTooltip:IsOwned(this) ) then
    TInv_ItemButton_OnEnter();
  else
    this.updateTooltip = nil;
  end
end

function TInv_ItemButton_OnLeave()
  local itm = TBag_GetItmFromFrame(TBAG_BUTTONS, this:GetName());

  TBag_PrintDEBUG("TInv_ItemButton_OnLeave() this="..this:GetName().." id="..this:GetID().." parent"..this:GetParent():GetName().." id="..this:GetParent():GetID() );

  if (TInv_edit_selected == "") then
    TInv_edit_hilight = "";
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

  if ( TInv_edit_mode == 1 ) then
    -- redraw the window to remove the hilighting of entire class items
    TInv_UpdateWindow();
  end
end

function TInv_ItemButton_OnClick(button)
  local itm = TBag_GetItmFromFrame(TBAG_BUTTONS, this:GetName());
  local bar, bag, slot;

  if (itm ~= nil) then
    bar = itm[TBAG_I_BAR];
    bag = itm[TBAG_I_BAG];
    slot = itm[TBAG_I_SLOT];
  end

  if (TInv_edit_mode == 1) then
    -- don't do normal actions to this button, we're in edit mode
    if ( button == "LeftButton" ) then
      if (TInv_edit_selected == "") then
        -- you clicked, we selected
        TInv_edit_selected = itm[TBAG_I_CAT];
        TInv_edit_hilight = itm[TBAG_I_CAT];
      else
        -- we got a click, and we already had one selected.  let's move the items
        TBag_SetCatBar(TInvCfg, TInv_edit_selected, bar, 1);

        TInv_edit_selected = "";
        TInv_edit_hilight = itm[TBAG_I_CAT];

        -- resort will force a window update
        TInv_UpdateWindow();
      end
    elseif ( button == "RightButton" ) then
      HideDropDownMenu(1);
      TInv_RightClickMenu_mode = "item";
      TInv_RightClickMenu_opts = {
        [TBAG_I_BAR] = bar,
        [TBAG_I_BAG] = bag,
        [TBAG_I_SLOT] = slot
        };
      ToggleDropDownMenu(1, nil, TInvFrame_RightClickMenu, this:GetName(), -50, 0);
    end
    TInv_UpdateWindow();
  end
end

function TInv_RightClick_PickupItem()
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

function TInv_Button_HighlightToggle_OnClick()
  PlaySound("igMainMenuOptionCheckBoxOn");
  if (TInv_hilight_new == 0) then
    TInv_hilight_new = 1;
    TInv_Button_HighlightToggle:SetText(TBag_Loc("TBag_HighlightToggle_on"));
  else
    TInv_hilight_new = 0;
    TInv_Button_HighlightToggle:SetText(TBag_Loc("TBag_HighlightToggle_off"));
  end
  TInv_UpdateWindow();
end

function TInv_Button_ChangeEditMode_OnClick()
  PlaySound("igMainMenuOptionCheckBoxOn");
  if (TInv_edit_mode == 0) then
    TInv_edit_mode = 1;
    TInv_Button_ChangeEditMode:SetText(TBag_Loc("TBag_ChangeEditMode_on"));
  else
    TInv_edit_mode = 0;
    TInv_Button_ChangeEditMode:SetText(TBag_Loc("TBag_ChangeEditMode_off"));
  end
  -- resort will force a window redraw
  TInv_UpdateWindow(TBAG_REQ_MUST);
end

function TInv_Button_Reload_OnClick()
  -- Never clear another player's cache
  if (TINV_PLAYERID == TBAG_PLAYERID) then
    TBag_ClearItmCache(TInvItm[TINV_PLAYERID], TInv_Bags);
    TBag_ClearStackSkip(TInv_Bags);

    -- Send a message to restack
    if (TInvCfg["stack_resort"] == 1) then
      TInvCfg["stack_once"] = 1;
    end
  end

  TInv_UpdateWindow(TBAG_REQ_MUST);
  TBag_PrintDEBUG("TInv reloaded.");
end

function TInv_SynchShowBank()
  if (TBnkFrame:IsVisible()) then
    TInv_Button_ShowBank:SetText(TBag_Loc("TBag_ShowBank_off"));
  else
    TInv_Button_ShowBank:SetText(TBag_Loc("TBag_ShowBank_on"));
  end
end

function TInv_Button_ShowBank_OnClick()
  if (TBnkFrame:IsVisible()) then
    TBnk_UserDropdown:Hide();
    TBnkFrame:Hide();
  else
    TBnk_edit_mode = 0;
    TBnk_SetPlayer(TINV_PLAYERID);
    TBnk_UserDropdown:Show();
    TBnkFrame:Show();
    TBnk_UpdateWindow();
  end
  TInv_SynchShowBank();
end

function TInv_Button_MoveLockToggle_OnClick()
  PlaySound("igMainMenuOptionCheckBoxOn");
  if (TInvCfg["moveLock"] == 0) then
    TInvCfg["moveLock"] = 1;
    TInv_Button_MoveLockToggle:SetText(TBag_Loc("TBag_MoveLock_unlocked"));
  else
    TInvCfg["moveLock"] = 0;
    TInv_Button_MoveLockToggle:SetText(TBag_Loc("TBag_MoveLock_locked"));
  end
end

function TInv_SlotTargetButton_OnClick(button, ignoreShift)
  local bar, tmp;

  if (TInv_edit_mode == 1) then
    for tmp in string.gmatch(this:GetName(), "TInvFrame_SlotTarget_(%d+)") do
      bar = tonumber(tmp);
    end

    if ( (bar == nil) or (bar < 1) or (bar > TBAG_BAR_MAX) ) then
      return;
    end

    if ( button == "LeftButton" ) then
      if (TInv_edit_selected ~= "") then
      -- we got a click, and we already had one selected.  let's move the items
        TBag_SetCatBar(TInvCfg, TInv_edit_selected, bar, 1);
 
        TInv_edit_selected = "";
        TInv_edit_hilight = "";

        TBag_BuildBarClassList(TINV_BC_LIST, TInvCfg);
  
        TInv_UpdateWindow(TBAG_REQ_MUST);
      end
    elseif ( button == "RightButton" ) then
      HideDropDownMenu(1);
      TInv_RightClickMenu_mode = "slot_target";
      TInv_RightClickMenu_opts = {
        [TBAG_I_BAR] = bar
      };
      ToggleDropDownMenu(1, nil, TInvFrame_RightClickMenu, this:GetName(), -50, 0);
    end
  end
end

function TInv_SlotTargetButton_OnEnter()
  local bar, tmp, key, value;

  if (TInv_edit_mode == 1) then
    for tmp in string.gmatch(this:GetName(), "TInvFrame_SlotTarget_(%d+)") do
      bar = tonumber(tmp);
    end

    GameTooltip:SetOwner(this, "ANCHOR_LEFT");
    GameTooltip:ClearLines();

    if (TInv_edit_selected ~= "") then
      GameTooltip:AddLine("|c"..TBAG_C_INST.."Left click to move category |r|c"
        ..TBAG_C_CAT..TInv_edit_selected.."|r|c"..TBAG_C_INST.." to bar |r|c"
        ..TBAG_C_BAR..bar.."|r");
    else
      GameTooltip:AddLine("|c"..TBAG_C_INST.."Bar |r|c"
        ..TBAG_C_BAR..bar.."|r");

      GameTooltip:AddLine(" ");
      for key, value in pairs(TINV_BC_LIST[bar]) do
        GameTooltip:AddLine("|c"..TBAG_C_CAT..value.."|r");
      end
      GameTooltip:AddLine(" ");

      GameTooltip:AddLine("Right click for options", 0.85,0.85,0.85, 1.0);
    end

    GameTooltip:Show();
    return;
  end
  if ( GameTooltip:IsOwned(this) ) then
    GameTooltip:Hide();
    ResetCursor();
  end
end

function TInv_SlotTargetButton_OnLeave()
  this.updateTooltip = nil;
  if ( GameTooltip:IsOwned(this) ) then
    GameTooltip:Hide();
    ResetCursor();
  end
end

function TInv_SlotTargetButton_OnUpdate(elapsed)
  --[[
  if ( not this.updateTooltip ) then
    return;
  end

  this.updateTooltip = this.updateTooltip - elapsed;
  if ( this.updateTooltip > 0 ) then
    return;
  end
  --]]

  if ( GameTooltip:IsOwned(this) ) then
    TInv_SlotTargetButton_OnEnter();
  else
    this.updateTooltip = nil;
  end
end

function TInv_BagSlotButton_OnEnter()
  local bag = this:GetID() - 19;
  local itemlink = TBag_GetPlayerBagCfg(TINV_PLAYERID, bag, TBAG_I_ITEMLINK);

  GameTooltip:SetOwner(this, "ANCHOR_LEFT");
  GameTooltip:ClearLines();

  if (itemlink) then
    GameTooltip:SetHyperlink(itemlink);
  else
    GameTooltip:AddLine("Equip Container", 1,1,1);
  end
  
  GameTooltip:Show();
end

function TInv_BagSlotButton_OnUpdate(elapsed)
  if ( GameTooltip:IsOwned(this) ) then
    TInv_BagSlotButton_OnEnter();
  else
    this.updateTooltip = nil;
  end
end

function TInv_RightClick_DeleteItemOverride()
  local bag, slot, itm;

  bag = this.value[TBAG_I_BAG];
  slot = this.value[TBAG_I_SLOT];

  if ( (bag ~= nil) and (slot ~= nil) ) then
    itm = TInvItm[TINV_PLAYERID][bag][slot];

    if ( (itm[TBAG_I_ITEMID] ~= nil) and (TInvCfg["item_overrides"][itm[TBAG_I_ITEMID]] ~= nil) ) then
      TInvCfg["item_overrides"] = TBag_Table_RemoveKey(TInvCfg["item_overrides"], itm[TBAG_I_ITEMID] );
      HideDropDownMenu(1);

      -- resort will force a window redraw as well
      TInv_UpdateWindow(TBAG_REQ_MUST);
    end
  end
end

function TInv_RightClick_SetItemOverride()
  local bag, slot, itm, new_barclass;

  bag = this.value[TBAG_I_BAG];
  slot = this.value[TBAG_I_SLOT];
  new_barclass = this.value["barclass"];

  if ( (bag ~= nil) and (slot ~= nil) and (new_barclass ~= nil) ) then
    itm = TInvItm[TINV_PLAYERID][bag][slot];

    TInvCfg["item_overrides"][itm[TBAG_I_ITEMID]] = new_barclass;
    HideDropDownMenu(2);
    HideDropDownMenu(1);
    TInv_UpdateWindow(TBAG_REQ_MUST);
  end
end

function TInvFrame_RightClickMenu_populate(level)
  local bar, bag, slot;
  local info, itm, barclass, tmp, checked, i;
  local key, value, key2, value2;


  -------------------------------------------------------------------------------------------------
  ------------------------------- ITEM CONTEXT MENU -----------------------------------------------
  -------------------------------------------------------------------------------------------------
  if (TInv_RightClickMenu_mode == "item") then
    -- we have a right click on a button

    bar = TInv_RightClickMenu_opts[TBAG_I_BAR];
    bag = TInv_RightClickMenu_opts[TBAG_I_BAG];
    slot = TInv_RightClickMenu_opts[TBAG_I_SLOT];
    itm = TInvItm[TINV_PLAYERID][bag][slot];

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
      if (TInvCfg["item_overrides"][itm[TBAG_I_ITEMID]] ~= nil) then
        info["checked"] = 1;
      end
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = "Use default category assignment",
        ["value"] = { [TBAG_I_BAG]=bag, [TBAG_I_SLOT]=slot },
        ["func"] = TInv_RightClick_DeleteItemOverride
        };
      if (TInvCfg["item_overrides"][itm[TBAG_I_ITEMID]] == nil) then
        info["checked"] = 1;
      end
      UIDropDownMenu_AddButton(info, level);

      if (TINV_SHOWITEMDEBUGINFO==1) then
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
          if (
        (TInvCfg["item_overrides"][itm[TBAG_I_ITEMID]]
        ~= nil) and (TBag_GetCat(TInvCfg, TInvCfg["item_overrides"][itm[TBAG_I_ITEMID]]) == i) ) then
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
          for key,barclass in pairs(TINV_BC_LIST[this.value["select_bar"]]) do
            info = {
              ["text"] = barclass;
              ["value"] = { [TBAG_I_BAG]=bag, [TBAG_I_SLOT]=slot, ["barclass"]=barclass },
              ["func"] = TInv_RightClick_SetItemOverride
              };
            if (TInvCfg["item_overrides"][itm[TBAG_I_ITEMID]] == barclass) then
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
  elseif (TInv_RightClickMenu_mode == "slot_target") then
    -- right click on a slot
    bar = TInv_RightClickMenu_opts[TBAG_I_BAR];

    info = { ["text"] = "|c"..TBAG_C_INST.."Bar |r|c"
      ..TBAG_C_BAR..bar.."|r", ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);

    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    for key, value in pairs(TINV_BC_LIST[bar]) do
      info = {
        ["text"] = "Move: |c"..TBAG_C_CAT..value.."|r";
        ["value"] = value;
        ["func"] = function()
          TInv_edit_selected = (this.value);
          TInv_edit_hilight = (this.value);
          TInv_UpdateWindow();
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

      if (TBag_GetGrp(TInvCfg, TBAG_G_BAR_SORT, bar) == key) then
        checked = 1;
      else
        checked = nil;
      end

      info = {
        ["text"] = value;
        ["value"] = { [TBAG_I_BAR]=bar, ["sortby"]=key };
        ["func"] = function()
            TBag_SetGrpDef(TInvCfg, TBAG_G_BAR_SORT, this.value[TBAG_I_BAR], this.value["sortby"], 1);
            TInv_UpdateWindow(TBAG_REQ_MUST);
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

      if (TBag_GetGrp(TInvCfg, TBAG_G_USE_NEW, bar) == key) then
        checked = 1;
      else
        checked = nil;
      end

      info = {
        ["text"] = value;
        ["value"] = { [TBAG_I_BAR]=bar, ["value"]=key };
        ["func"] = function()
            TBag_SetGrpDef(TInvCfg, TBAG_G_USE_NEW, this.value[TBAG_I_BAR], this.value["value"], 1);
            TInv_UpdateWindow(TBAG_REQ_MUST);
          end,
        ["checked"] = checked
        };
      UIDropDownMenu_AddButton(info, level);
    end

    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = { ["text"] = "Color:", ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);

    info = TBag_MakeColorPickerInfo(TInvCfg, "bkgr_", bar,
        "Background Color for Bar "..bar, TInv_UpdateWindow);
    UIDropDownMenu_AddButton(info, level);

    info = TBag_MakeColorPickerInfo(TInvCfg, "brdr_", bar,
        "Border Color for Bar "..bar, TInv_UpdateWindow);
    UIDropDownMenu_AddButton(info, level);

  -------------------------------------------------------------------------------------------------
  ------------------------ MAIN WINDOW CONTEXT MENU -----------------------------------------------
  -------------------------------------------------------------------------------------------------
  elseif (TInv_RightClickMenu_mode == "mainwindow") then
    if (level == 1) then

      info = { ["text"] = TBag_Loc("TBag_MenuTitle"), ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
      UIDropDownMenu_AddButton(info, level);


      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = "Edit Mode",
        ["value"] = nil,
        ["func"] = TInv_Button_ChangeEditMode_OnClick
        };
      if (TInv_edit_mode == 1) then
        info["checked"] = 1;
      end
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = "Lock window",
        ["value"] = nil,
        ["func"] = TInv_Button_MoveLockToggle_OnClick
        };
      if (TInvCfg["moveLock"] == 0) then
        info["checked"] = 1;
      end
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = "Reload bags",
        ["value"] = nil,
        ["func"] = TInv_Button_Reload_OnClick
        };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = "Show Bank",
        ["value"] = nil,
        ["func"] = TInv_Button_ShowBank_OnClick
        };
      UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = "Hilight New Items",
        ["value"] = nil,
        ["func"] = TInv_Button_HighlightToggle_OnClick
        };
      if (TInv_hilight_new == 1) then
        info["checked"] = 1;
      end
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = "Reset NEW tag",
        ["value"] = nil,
        ["func"] = function()
            local bag, slot;

            for index, bag in ipairs(TInv_Bags) do
              if (TInvCfg["show_Bag"..bag] == 1) then
                if (table.getn(TInvItm[TINV_PLAYERID][bag]) > 0) then
                  for slot = 1, table.getn(TInvItm[TINV_PLAYERID][bag]) do
                    TBag_ResetNew(TInvItm[TINV_PLAYERID][bag][slot]);
                  end
                end
              end
            end

            TInv_UpdateWindow();
          end
        };
      UIDropDownMenu_AddButton(info, level);


      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = "Advanced Configuration",
        ["value"] = nil,
        ["func"] = function()
            TInv_OptsFrame:Show();
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
                    TInvCfg["frameButtonSize"], TInvCfg["count_font"], 
                      TInvCfg["count_font_x"], TInvCfg["count_font_y"],
                      TInvCfg["scale"] = TBag_NicePlacement(this.value);
                    TInv_CalcButtonSize(TInvCfg["frameButtonSize"], TInvCfg["framePad"]);
                    TInv_UpdateWindow(TBAG_REQ_MUST);
                  end
                end
              };
            if (tonumber(TInvCfg["frameButtonSize"]*TInvCfg["scale"] - value)
      < 1.0) and (tonumber(TInvCfg["frameButtonSize"]*TInvCfg["scale"] - value)
      > -1.0) then
              info["checked"] = 1;
            end
            UIDropDownMenu_AddButton(info, level);
          end
        elseif (this.value["opt"] == "set_colors") then
          TBag_MakeColorMenu(TInvCfg, TInv_UpdateWindow, level, TInv_Bags);
        end
      end
    end
  end
end


-- Main "right click menu"
function TInvFrame_RightClickMenu_OnLoad()
  UIDropDownMenu_Initialize(this, TInvFrame_RightClickMenu_populate, "MENU");
end


function TInv_IncreaseColumns()
  if (TInvCfg["maxColumns"] < TBAG_NUMCOL_MAX) then
    TInvCfg["maxColumns"] = TInvCfg["maxColumns"] + 1;
    TInv_UpdateWindow(TBAG_REQ_MUST);
  end
end

function TInv_DecreaseColumns()
  if (TInvCfg["maxColumns"] > TBAG_NUMCOL_MIN) then
    TInvCfg["maxColumns"] = TInvCfg["maxColumns"] - 1;
    TInv_UpdateWindow(TBAG_REQ_MUST);
  end
end


-- bar == current bar
-- frame == name of background frame to be relative to
-- width/height == max number of buttons to place into frame
function TInv_AssignButtonsToFrame(barnum, frame, width, height)
  local cur_x, cur_y, tmpframe;
  local buttonname;
  local bag, slot;

  cur_x = 0;
  cur_y = 0;

  if (table.getn(TINV_BARITM[barnum]) > 0) then
    for position = 1, table.getn(TINV_BARITM[barnum]) do
      bag = TINV_BARITM[barnum][position][TBAG_I_BAG];
      slot = TINV_BARITM[barnum][position][TBAG_I_SLOT];
      buttonname = TBag_GetBagItemButtonName(bag, slot);

      TBag_PositionFrame(buttonname, "BOTTOMRIGHT", frame, "BOTTOMRIGHT",
        0-(TInv_FrameX(cur_x)+TINV_BF_X_PAD), TInv_FrameY(cur_y)+TINV_BF_Y_PAD,
        TINV_BF_WIDTH, TINV_BF_HEIGHT );

      TBag_PositionFrame(buttonname.."_bkgr", "TOPLEFT", buttonname, "TOPLEFT",
        0-TINV_BF_X_PAD, TINV_BF_Y_PAD,
        TINV_BGF_WIDTH, TINV_BGF_HEIGHT );

      local frame_normaltexture = getglobal(buttonname.."NormalTexture");
      
      -- resize frame texture (this is the little border)
      frame_normaltexture:SetWidth(TINV_BGF_WIDTH);
      frame_normaltexture:SetHeight(TINV_BGF_HEIGHT);

      -- Relink the button map
      TBAG_BUTTONS[buttonname] = TInvItm[TINV_PLAYERID][bag][slot];

      cur_x = cur_x + 1;
      if (cur_x == width) then
        cur_x = 0;
        cur_y = cur_y + 1;
      end
    end
  end

  if (TInv_edit_mode == 1) then
    -- add extra button for targetting
    buttonname = "TInvFrame_SlotTarget_"..barnum;
    TBag_PositionFrame(buttonname, "BOTTOMRIGHT", frame, "BOTTOMRIGHT",
      0-( (TInv_FrameX(width-1)+TINV_BF_X_PAD) ),
      (TInv_FrameY(height-1)+TINV_BF_Y_PAD),
      TINV_BF_WIDTH, TINV_BF_HEIGHT);

    TBag_PositionFrame(buttonname.."_bkgr", "TOPLEFT", buttonname, "TOPLEFT",
      0-TINV_BF_X_PAD, TINV_BF_Y_PAD,
      TINV_BGF_WIDTH, TINV_BGF_HEIGHT );

    local frame_normaltexture = getglobal(buttonname.."NormalTexture");
    frame_normaltexture:SetWidth(TINV_BGF_WIDTH);
    frame_normaltexture:SetHeight(TINV_BGF_HEIGHT);
    
    tmpframe = getglobal(buttonname.."_BigText");
    tmpframe:SetText( barnum );
    tmpframe:Show();
    tmpframe = getglobal(buttonname.."_bkgr");
    tmpframe:SetVertexColor( 1,0,0.25, 0.8 );
    tmpframe:Show();
  end
end

TInv_WindowIsUpdating = 0;

function TInv_UpdateWindow(resort_req)
  local frame = getglobal("TInvFrame");
  local barnum;

  TBag_PrintDEBUG("TInv_UpdateWindow:  WindowIsUpdating="..TInv_WindowIsUpdating );

  if (TInv_WindowIsUpdating == 1) then
    return;
  end
  TInv_WindowIsUpdating = 1;

  if ( not frame:IsVisible() ) then
    TInv_WindowIsUpdating = 0;
    return;
  end

  -- Set the overall scale
  TInvFrame:SetScale(TInvCfg["scale"]);

  -- Make the button display the right text
  TInv_SynchShowBank();

  -- Consume a message from updated craft info
  if (TBagCfg["trades_changed"] == 1) then
    resort_req = TBAG_REQ_MUST;
  end
  TBagCfg["trades_changed"] = nil;

  -- Always set the class cats for this player's class
  TBag_SetClassCats(TInvCfg, TINV_PLAYERID, 1);

  -- SORTING and ITEMCACHE
  if (resort_req == nil) then resort_req = TBAG_REQ_NONE; end
  local cache_req, stackarr = TBag_UpdateItmCache(TInvCfg, TINV_PLAYERID, TInvItm[TINV_PLAYERID], TInv_Bags);
  resort_req = resort_req + cache_req;

  -- Consume a message for bag stacking
  if (TInvCfg["stack_once"] == 1) then
    if (TINV_PLAYERID == TBAG_PLAYERID) then
      TBag_Stack(TInvItm[TINV_PLAYERID], stackarr);
    end
  end
  TInvCfg["stack_once"] = nil;

  if (resort_req >= TBAG_REQ_MUST) then
    TINV_BARITM = TBag_SortItmCache(TInvCfg, 
      TINV_PLAYERID, TInvItm[TINV_PLAYERID], TINV_BARITM, TInv_Bags);
    TBag_LayoutWindow(TInvCfg, "TInvFrame", TINV_BARITM, TInvCfg["bar_x"], 
      TInv_edit_mode, TINV_BUTTON_MAX, TInv_AssignButtonsToFrame, 
      TInv_FrameX, TInv_FrameY, TInv_SpaceX, TInv_SpaceY, TInv_PoolX, TInv_PoolY)
  end

  -- Relink the button map
  local position;
  for barnum = 1, TInvCfg["bar_x"] * TBag_GetBarY(TInvCfg["bar_x"]) do
    if (table.getn(TINV_BARITM[barnum]) > 0) then
      for position = 1, table.getn(TINV_BARITM[barnum]) do
        TBAG_BUTTONS[TBag_GetBagItemButtonName(TINV_BARITM[barnum][position][TBAG_I_BAG], TINV_BARITM[barnum][position][TBAG_I_SLOT])] =
          TInvItm[TINV_PLAYERID][TINV_BARITM[barnum][position][TBAG_I_BAG]][TINV_BARITM[barnum][position][TBAG_I_SLOT]];
      end
    end
  end

  -- BAGS, to get bag sizes below
  TInv_UpdateBagGfx();

  -- Update all the buttons
  for _, bag in ipairs(TInv_Bags) do
    local size = TBag_GetPlayerBagCfg(TINV_PLAYERID, bag, TBAG_I_BAGSIZE);
    if (not size) then size = 0; end
    if (TInvCfg["show_Bag"..bag] ~= 1) then size = 0; end
    for slot = 1, size do
      TBag_UpdateButton(TInvCfg, TINV_PLAYERID,
        TBag_GetBagItemButtonName(bag, slot),
        TInv_edit_mode, TInv_edit_hilight, TInv_hilight_new)
    end
    for slot = size+1, TBAG_BAGSIZE_MAX do
      getglobal(TBag_GetBagItemButtonName(bag, slot)):Hide();
    end
  end

  -- MONEY
  MoneyFrame_Update("TInv_MoneyViewFrame", TBag_GetMoney(TINV_PLAYERID));
  if (TINV_PLAYERID == TBAG_PLAYERID) then
    TInv_MoneyViewFrame:Hide();
    TInv_MoneyFrame:Show();
  else
    TInv_MoneyFrame:Hide();
    TInv_MoneyViewFrame:Show();
  end

    frame:ClearAllPoints();
    frame:SetPoint(TInvCfg["frameYRelativeTo"]..TInvCfg["frameXRelativeTo"],
      "UIParent", "BOTTOMLEFT",
      TInvCfg["frame"..TInvCfg["frameXRelativeTo"]] / frame:GetScale(),
      TInvCfg["frame"..TInvCfg["frameYRelativeTo"]] / frame:GetScale());

    
    TBag_ColorFrame(TInvCfg, frame, TBAG_MAIN_BAR);

    if (TInv_edit_mode == 1) then
      TInv_Button_ColumnsAdd:SetText(TBag_Loc("TBag_ColumnsAdd_buttontitle"));
      TInv_Button_ColumnsAdd:Show();
      TInv_Button_ColumnsDel:SetText(TBag_Loc("TBag_ColumnsDel_buttontitle"));
      TInv_Button_ColumnsDel:Show();
    else
      TInv_Button_ColumnsAdd:Hide();
      TInv_Button_ColumnsDel:Hide();
    end

    if (TInvCfg["show_top_graphics"] == 1) then
      TInvFramePortrait:Show();
      TInvFrameTextureTopLeft:Show();
      TInvFrameTextureTopCenter:Show();
      TInvFrameTextureTopRight:Show();
      TInvFrameTextureLeft:Show();
      TInvFrameTextureRight:Show();
      TInvFrameTextureBottomLeft:Show();
      TInvFrameTextureBottomCenter:Show();
      TInvFrameTextureBottomRight:Show();
    else
      TInvFramePortrait:Hide();
      TInvFrameTextureTopLeft:Hide();
      TInvFrameTextureTopCenter:Hide();
      TInvFrameTextureTopRight:Hide();
      TInvFrameTextureLeft:Hide();
      TInvFrameTextureRight:Hide();
      TInvFrameTextureBottomLeft:Hide();
      TInvFrameTextureBottomCenter:Hide();
      TInvFrameTextureBottomRight:Hide();
    end

  TInv_WindowIsUpdating = 0;
end

function TInv_UserDropdown_GetValue()
  if ( TINV_PLAYERID ) then
    return TINV_PLAYERID;
  elseif (TBAG_PLAYERID) then
    return TBAG_PLAYERID;
  end
end

function TInv_UserDropdown_OnLoad()
  UIDropDownMenu_Initialize(this, TInv_UserDropdown_Initialize);
  UIDropDownMenu_SetSelectedValue(this, TBAG_PLAYERID);
  TInv_UserDropdown.tooltip = "You are viewing this player's inventory.";
  UIDropDownMenu_SetWidth(TBAG_USERDD_WIDTH, this);
--  OptionsFrame_EnableDropDown(this);
end

function TInv_UserDropdown_OnClick()
  UIDropDownMenu_SetSelectedValue(TInv_UserDropdown, this.value);
  if ( this.value ) then
    TInv_SetPlayer(this.value);
  end
  if ( not TINV_PLAYERID ) then
    TBag_PrintDEBUG("TInv_UserDropdown_OnClick Failed");
    return;
  end
  TBag_PrintDEBUG("Selected Player "..TINV_PLAYERID);

  TInv_UpdateWindow(TBAG_REQ_MUST);
end

function TInv_UserDropdown_Initialize()
  TBag_UserDropdown_Init(TInv_UserDropdown_OnClick,
    TInvItm, TBAG_REALM);
end

