-- $Id$

-- Localization Support
local L = TBAG_LOCALE;

BINDING_NAME_TINV_TOGGLE = L["Toggle Inventory Window"];

-- Constants
TINV_DEBUGMESSAGES = 0;   -- 0 = off, 1 = on
TINV_SHOWITEMDEBUGINFO = 0;
local TINV_WIPECONFIGONLOAD = 0;  -- for debugging, test it out on a new config every load

TINV_BUTTONS = {
  "TInv_Button_Close",
  "TInv_Button_MoveLockToggle",
  "TInv_Button_HighlightToggle",
  "TInv_Button_ChangeEditMode",
  "TInv_Button_ShowBank",
  "TInv_Button_Reload",
}

-- View switching
TINV_PLAYERID = "";

TINV_BUTTON_MAX = 109;

TINV_PAD_TOP_GFX = 63;
TINV_PAD_TOP_NORM = 25;
TINV_BORDER = 2;

TINV_CACHE_REQ = TBAG_REQ_NONE;

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

function TInv_SetDefPos(cfg, reset)
  TBag_SetDef(cfg, "frameLEFT", UIParent:GetRight() * UIParent:GetScale() * 0.73, reset, TBag_NumFunc);
  TBag_SetDef(cfg, "frameRIGHT", UIParent:GetRight() * UIParent:GetScale() * 0.92, reset, TBag_NumFunc);
  TBag_SetDef(cfg, "frameTOP", UIParent:GetTop() * UIParent:GetScale() * 0.83, reset, TBag_NumFunc);
  TBag_SetDef(cfg, "frameBOTTOM", UIParent:GetTop() * UIParent:GetScale() * 0.232, reset, TBag_NumFunc);
  TBag_SetDef(cfg, "frameXRelativeTo", "LEFT", reset, TBag_StrFunc, {"RIGHT","LEFT"} );
  TBag_SetDef(cfg, "frameYRelativeTo", "BOTTOM", reset, TBag_StrFunc, {"TOP","BOTTOM"} );
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
  TBag_SetDef(cfg, "show_soulshard_count", 1, reset, TBag_NumFunc, 0, 1);

  -- Colors
  TBag_SetColor(cfg, "bkgr_"..TBAG_MAIN_BAR, 0.0, 0.2, 0.4, 0.4, reset);
  TBag_SetColor(cfg, "brdr_"..TBAG_MAIN_BAR, 0.2, 0.2, 1.0, 0.3, reset);
  for i = 1, TBAG_BAR_MAX do
    TBag_SetColor(cfg, "bkgr_"..i, 0.0, 0.2, 0.4, 0.4, reset);
    TBag_SetColor(cfg, "brdr_"..i, 0.2, 0.2, 1.0, 0.3, reset);
  end
  TBag_SetDefColors(cfg, reset);

  TInv_SetDefPos(cfg, reset);
  
  TBag_SetDef(cfg, "show_searchbox", 1, reset, TBag_NumFunc, 0, 1);
  TBag_SetDef(cfg, "show_bankbutton", 1, reset, TBag_NumFunc, 0, 1);
  
  TInv_CalcButtonSize(TInvCfg["frameButtonSize"], TInvCfg["framePad"]);
end

function TInv_SetPlayer(playerid)
   -- An ugly hack to get around the fact that we can't hook the
   -- OnClick for the ContainerFrameItemButton.  The Blizzard
   -- code uses the id of the frame to figure out what to pickup.
   -- When we are showing another character's inventory we set
   -- our bag frames id's to 100 to stop Blizzard's code from
   -- actually doing anything.
   if (playerid ~= TBAG_PLAYERID) then
     for _, bag in ipairs(TInv_Bags) do
       getglobal(TBag_GetDummyBagFrameName(bag)):SetID(100);
     end
   else
     for _, bag in ipairs(TInv_Bags) do
       getglobal(TBag_GetDummyBagFrameName(bag)):SetID(bag);
     end
   end
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

  TInv_SearchBox:SetMaxLetters(25);

  -- setup hooks
  TInvHooks_Register(TBAG_HOOK_UNREGISTER);
  TInvHooks_Register(TBAG_HOOK_REGISTER);

  TInv_Button_HighlightToggle:SetText(L["Hilight"]);
  TInv_Button_ChangeEditMode:SetText(L["Edit"]);

  if (TInvCfg["moveLock"] == 0) then
    TInv_Button_MoveLockToggle:SetText(L["L"]);
  else
    TInv_Button_MoveLockToggle:SetText(L["U"]);
  end

  
  if (TInvCfg["show_bagbuttons"] == 0) then
    TInvacterBag0Slot:Hide();
    TInvacterBag1Slot:Hide();
    TInvacterBag2Slot:Hide();
    TInvacterBag3Slot:Hide();
    TInvMenuBarBackpackButton:Hide();
    TInvingButton:Hide();
  end
  if (TInvCfg["show_searchbox"] == 0) then
    TInv_SearchBox:Hide();
  end
  if (TInvCfg["show_userdropdown"] == 0) then
    TInv_UserDropdown:Hide();
    TInv_SearchBox:ClearAllPoints();
    TInv_SearchBox:SetPoint("TOPLEFT",TInvFrame,"TOPLEFT",6,27);
  end
  if (TInvCfg["show_reloadbutton"] == 0) then
    TInv_Button_Reload:Hide();
  end
  if (TInvCfg["show_bankbutton"] == 0) then
    TInv_Button_ShowBank:Hide();
  end
  if (TInvCfg["show_editbutton"] == 0) then
    TInv_Button_ChangeEditMode:Hide();
  end
  if (TInvCfg["show_editbutton"] == 0) then
    TInv_Button_ChangeEditMode:Hide();
  end
  if (TInvCfg["show_hilightbutton"] == 0) then
    TInv_Button_HighlightToggle:Hide();
  end
  if (TInvCfg["show_lockbutton"] == 0) then
    TInv_Button_MoveLockToggle:Hide();
  end
  if (TInvCfg["show_closebutton"] == 0) then
    TInv_Button_Close:Hide();
  end
  if (TInvCfg["show_total"] == 0) then
    TInvNumTotal:Hide();
  end
  if (TInvCfg["show_money"] == 0) then
    TInv_MoneyViewFrame:Hide();
    TInv_MoneyFrame:Hide();
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
    local bagtype = TBag_GetBagType(TINV_PLAYERID, bag);
    -- Don't count ammo, quivers or keyring slots as empty slots 
    -- quivers are type 1, ammo type 2, soul type 4 and keyring 256
    if (bagtype == nil or (type(bagtype) == "number" and  bit.band(263,bagtype) == 0)) then
      totalfree = totalfree + free;
      totalsize = totalsize + size;
    end

    -- Deal with old style string bag types.
    if (bagtype == nil or (type(bagtpe) == "string" and
        bagtype ~= L["AMMO"] and bagtype ~= L["SOUL"] and bagtype ~= L["KEYRING"])) then
      totalfree = totalfree + free;
      totalsize = totalsize + size;
    end
      
    if (bag > 0) then
      -- Update the textures as well
      TBag_GetBagFrameTexture(bag):SetTexture(
        TBag_GetBagTexture(TINV_PLAYERID, bag));

      -- Deal with the count of soulshards in a soulbag.
      if (TInvCfg["show_soulshard_count"] == 1) then
        if (bagtype and type(bagtype) == "number" and bit.band(4,bagtype) ~= 0) then
          SetItemButtonCount(TBag_GetBagFrame(bag), size - free);
	-- Deal with old style string bagtypes.
	elseif (bagtype and type(bagtype) == "string" and bagtype == L["SOUL"]) then
          SetItemButtonCount(TBag_GetBagFrame(bag), size - free);
        else
          SetItemButtonCount(TBag_GetBagFrame(bag), 0);
	end
      else
          SetItemButtonCount(TBag_GetBagFrame(bag), 0);
      end
    end

    TBag_UpdateBagColors(bag);
  end
  TBag_SetFreeStr(getglobal("TInvNumTotalText"), totalfree, totalsize, TInvCfg["show_bag_sizes"]);
end

function TInv_OnEvent(event)
  -- TBag_Print("TInv_Event: '"..event.."'");

  if ( TInvFrame:IsVisible() ) then
    if ( event == "BAG_UPDATE" ) then
      -- Only process events related to the inventory window
      if (arg1 and TBag_Member(TInv_Bags, arg1)) then
        -- Stack the bags if we are in a state to
        if (CursorHasItem() == nil and CursorHasMoney() == nil and CursorHasSpell() == nil and TBag_IsStacking(TBAG_STACK_INV) == nil) then
          -- Stack the bags if configured to
          if (TInvCfg["stack_auto"] == 1) then
            if (TINV_PLAYERID == TBAG_PLAYERID) then
              -- Send a message to restack
              TInvCfg["stack_once"] = 1;
            end
          end
        end
        TInv_UpdateWindow();
      end
    elseif ( event == "BAG_UPDATE_COOLDOWN" ) then
      -- Only process events related to the inventory window
      if (arg1 and TBag_Member(TInv_Bags, arg1)) then
        TInv_UpdateWindow();
      end
    elseif ( event == "ITEM_LOCK_CHANGED" ) then
      -- arg1 = bag, arg2 = slot
      if (arg1 and arg2 and type(arg2) == "number" and TBag_Member(TInv_Bags, arg1)) then
        TBag_UpdateLockedItem(TINV_PLAYERID,getglobal(TBag_GetBagItemButtonName(arg1,arg2)));
      end
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


function TInv_ItemButton_OnEnter(self)
  local itm = TBag_GetItmFromFrame(TBAG_BUTTONS, self);
  local hasCooldown, repairCost;
  local bar;
  if (itm ~= nil) then
    bar = itm[TBAG_I_BAR];
  end

--  TBag_Print("TInv_ItemButton_OnEnter bag="..itm[TBAG_I_BAG]..", slot="..itm[TBAG_I_SLOT]..", name="..itm[TBAG_I_NAME]..", type="..itm[TBAG_I_TYPE]..", subtype="..itm[TBAG_I_SUBTYPE]);

  if (TInv_edit_selected == "") then
    TInv_edit_hilight = itm[TBAG_I_CAT];
  end

  if ( not itm[TBAG_I_ITEMLINK]) then
    if ( TInv_edit_mode == 1 ) then
      GameTooltip:SetOwner(self, "ANCHOR_LEFT");
      GameTooltip:ClearLines();
      GameTooltip:AddLine(L["Empty Slot"], 1,1,1 );

      -- move by class
      if (itm[TBAG_I_CAT] ~= nil) then
        if (TInv_edit_selected ~= "") then
          GameTooltip:AddLine(string.format(L["|c%sLeft click to move category |r|c%s%s|r|c%s to bar |r|c%s%s|r"],TBAG_C_INST,TBAG_C_CAT,TInv_edit_selected,TBAG_C_INST,TBAG_C_BAR,bar));
        else
          GameTooltip:AddLine(string.format(L["|c%sLeft click to select category to move:|r |c%s%s|r"],TBAG_C_INST,TBAG_C_CAT,itm[TBAG_I_CAT]));
        end
      else
        GameTooltip:AddLine(L["Item has no category"], 1,0,0 );
      end

      GameTooltip:Show();
      -- redraw the window to show the hilighting of entire class items
      TInv_UpdateWindow();
    else
      GameTooltip:Hide();
    end
    return;
  end

  -- Tool Tip Anchor: Anchor Right if the frame is on the left side of the screen else Anchor Left.
  if (TInvCfg["frameLEFT"] < GetScreenWidth()/2) then
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
  else
    GameTooltip:SetOwner(self, "ANCHOR_LEFT");
  end

  hasCooldown, repairCost = TBag_SetInventoryItem(GameTooltip, TINV_PLAYERID, 
    itm[TBAG_I_ITEMLINK], itm[TBAG_I_BAG], itm[TBAG_I_SLOT]);

  --[[
  if ( hasCooldown ) then
    self.updateTooltip = 1;
  else
    self.updateTooltip = nil;
  end
  --]]

  if ( InRepairMode() and (repairCost and repairCost > 0) ) then
    GameTooltip:AddLine(TEXT(REPAIR_COST), 1, 1, 1);
    SetTooltipMoney(GameTooltip, repairCost);
    GameTooltip:Show();
  elseif ( MerchantFrame:IsVisible() ) then
    ShowContainerSellCursor(itm[TBAG_I_BAG], itm[TBAG_I_SLOT]);
--    TBag_RegisterCurrentTooltipSellValue(GameTooltip, itm[TBAG_I_BAG], itm[TBAG_I_SLOT], itm);
  elseif ( self.readable or (IsModifiedClick("DRESSUP") and self.hasItem) ) then
    ShowInspectCursor();
  else
    ResetCursor();
  end

  if ( IsModifiedClick("COMPAREITEMS") ) then
    GameTooltip_ShowCompareItem();
  end

  if ( TInv_edit_mode == 1 ) then
    -- move by class
    if (itm[TBAG_I_CAT] ~= nil) then
      if (TInv_edit_selected ~= "") then
        GameTooltip:AddLine(" ", 0,0,0);
        GameTooltip:AddLine(string.format(L["|c%sLeft click to move category |r|c%s%s|r|c%s to bar |r|c%s%s|r"],TBAG_C_INST,TBAG_C_CAT,TInv_edit_selected,TBAG_C_INST,TBAG_C_BAR,bar));
      else
        GameTooltip:AddLine(" ", 0,0,0);
	GameTooltip:AddLine(string.format(L["|c%sLeft click to select category to move:|r |c%s%s|r"],TBAG_C_INST,TBAG_C_CAT,itm[TBAG_I_CAT]));
	GameTooltip:AddLine(L["Right click to assign this item to a different category"], 1,0,0 );
      end
    else
      GameTooltip:AddLine(" ", 0,0,0);
      GameTooltip:AddLine(L["Item has no category"], 1,0,0 );
    end
  end

  -- Then do a highlight to show the bag
  if (itm[TBAG_I_BAG] ~= KEYRING_CONTAINER) and (TInvCfg["spotlight_hover"] == 1) then
    local r, g, b, a = TBag_GetColor(TInvCfg, "bag_"..itm[TBAG_I_BAG]);
    TBag_GetBagFrameSpotlight(itm[TBAG_I_BAG]):SetVertexColor(r, g, b, a);
    TBag_GetBagFrameSpotlight(itm[TBAG_I_BAG]):Show();
  end

  if ( TInv_edit_mode == 1 ) then
    GameTooltip:Show();
    -- redraw the window to show the hllighting of entire class items
    TInv_UpdateWindow();
  end
end

function TInv_ItemButton_OnLeave()
  local itm = TBag_GetItmFromFrame(TBAG_BUTTONS, this);

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
  local itm = TBag_GetItmFromFrame(TBAG_BUTTONS, this);
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
        TInv_UpdateWindow(TBAG_REQ_MUST);
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

function TInv_Button_HighlightToggle_OnClick()
  PlaySound("igMainMenuOptionCheckBoxOn");
  if (TInv_hilight_new == 0) then
    TInv_hilight_new = 1;
    TInv_Button_HighlightToggle:SetText(L["Normal"]);
  else
    TInv_hilight_new = 0;
    TInv_Button_HighlightToggle:SetText(L["Hilight"]);
  end
  TInv_UpdateWindow();
end

function TInv_Button_ChangeEditMode_OnClick()
  PlaySound("igMainMenuOptionCheckBoxOn");
  if (TInv_edit_mode == 0) then
    TInv_edit_mode = 1;
    TInv_Button_ChangeEditMode:SetText(L["View"]);
  else
    TInv_edit_mode = 0;
    TInv_Button_ChangeEditMode:SetText(L["Edit"]);
  end
  -- resort will force a window redraw
  TInv_UpdateWindow(TBAG_REQ_MUST);
end

function TInv_Button_Reload_OnClick()
  -- Never clear another player's cache
  if (TINV_PLAYERID == TBAG_PLAYERID) then
    TBag_ClearItmCache(TInvItm[TINV_PLAYERID], TInv_Bags);
    TBag_ClearStackSkip(TInv_Bags);
    TBag_ClearCompSkip(TInv_Bags);

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
    TInv_Button_ShowBank:SetText(L["Hide Bank"]);
  else
    TInv_Button_ShowBank:SetText(L["Show Bank"]);
  end
end

function TInv_Button_ShowBank_OnClick()
  if (TBnkFrame:IsVisible()) then
    TBnk_UserDropdown:Hide();
    TBnkFrame:Hide();
  else
    TBnk_edit_mode = 0;
    TBnk_SetPlayer(TINV_PLAYERID);
    if (TBnkCfg["show_userdropdown"] == 1) then
      TBnk_UserDropdown:Show();
    end
    TBnkFrame:Show();
  end
  TInv_SynchShowBank();
end

function TInv_Button_MoveLockToggle_OnClick()
  PlaySound("igMainMenuOptionCheckBoxOn");
  if (TInvCfg["moveLock"] == 0) then
    TInvCfg["moveLock"] = 1;
    TInv_Button_MoveLockToggle:SetText(L["U"]);
  else
    TInvCfg["moveLock"] = 0;
    TInv_Button_MoveLockToggle:SetText(L["L"]);
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

function TInv_SlotTargetButton_OnEnter(self)
  local bar, tmp, key, value;

  if (TInv_edit_mode == 1) then
    for tmp in string.gmatch(self:GetName(), "TInvFrame_SlotTarget_(%d+)") do
      bar = tonumber(tmp);
    end

    GameTooltip:SetOwner(self, "ANCHOR_LEFT");
    GameTooltip:ClearLines();

    if (TInv_edit_selected ~= "") then
      GameTooltip:AddLine(string.format("|c%sLeft click to move category |r|c%s%s|r|c%s to bar |r|c%s%s|r",TBAG_C_INST,TBAG_C_CAT,TInv_edit_selected,TBAG_C_INST,TBAG_C_BAR,bar));
    else
      GameTooltip:AddLine(string.format("|c%sBar |r|c%s%s|r",TBAG_C_INST,TBAG_C_BAR,bar));

      GameTooltip:AddLine(" ");
      for key, value in pairs(TINV_BC_LIST[bar]) do
        GameTooltip:AddLine(string.format("|c%s%s|r",TBAG_C_CAT,value));
      end
      GameTooltip:AddLine(" ");

      GameTooltip:AddLine(L["Right click for options"], 0.85,0.85,0.85, 1.0);
    end

    GameTooltip:Show();
    return;
  end
  if ( GameTooltip:IsOwned(self) ) then
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

function TInv_BagSlotButton_OnEnter(self)
  local bag = self:GetID() - 19;
  local itemlink = TBag_GetPlayerBagCfg(TINV_PLAYERID, bag, TBAG_I_ITEMLINK);

  GameTooltip:SetOwner(self, "ANCHOR_LEFT");
  GameTooltip:ClearLines();

  if (itemlink and itemlink ~= "") then
    GameTooltip:SetHyperlink(itemlink);
  else
    GameTooltip:AddLine(L["Equip Container"], 1,1,1);
  end
  
  GameTooltip:Show();
end

function TInv_SetButton_Anchors()
  local button_left = nil;
 
  for _,button_name in ipairs(TINV_BUTTONS) do
    local button = getglobal(button_name);
    if (button) then 
      if (button_left) then
        button:SetPoint("TOPLEFT",button_left,"TOPRIGHT",4,0);
      else
        button:SetPoint("TOPLEFT",TInvFrame,"TOPLEFT",4,-2);
      end
      if (button:IsVisible()) then
        button_left = button;
      end
    end
  end

 
end

function TInv_Toggle_CloseButton()
  if (TInvCfg["show_closebutton"] == 1) then
    TInvCfg["show_closebutton"] = 0;
    TInv_Button_Close:Hide();
    TInv_SetButton_Anchors();
  else
    TInvCfg["show_closebutton"] = 1;
    TInv_Button_Close:Show();
    TInv_SetButton_Anchors();
  end
end

function TInv_Toggle_LockButton()
  if (TInvCfg["show_lockbutton"] == 1) then
    TInvCfg["show_lockbutton"] = 0;
    TInv_Button_MoveLockToggle:Hide();
    TInv_SetButton_Anchors();
  else
    TInvCfg["show_lockbutton"] = 1;
    TInv_Button_MoveLockToggle:Show();
    TInv_SetButton_Anchors();
  end
end

function TInv_Toggle_HighlightButton()
  if (TInvCfg["show_hilightbutton"] == 1) then
    TInvCfg["show_hilightbutton"] = 0;
    TInv_Button_HighlightToggle:Hide();
    TInv_SetButton_Anchors();
  else
    TInvCfg["show_hilightbutton"] = 1;
    TInv_Button_HighlightToggle:Show();
    TInv_SetButton_Anchors();
  end
end

function TInv_Toggle_EditButton()
  if (TInvCfg["show_editbutton"] == 1) then
    TInvCfg["show_editbutton"] = 0;
    TInv_Button_ChangeEditMode:Hide();
    TInv_SetButton_Anchors();
  else
    TInvCfg["show_editbutton"] = 1;
    TInv_Button_ChangeEditMode:Show();
    TInv_SetButton_Anchors();
  end
end

function TInv_Toggle_BankButton()
  if (TInvCfg["show_bankbutton"] == 1) then
    TInvCfg["show_bankbutton"] = 0;
    TInv_Button_ShowBank:Hide();
    TInv_SetButton_Anchors();
  else
    TInvCfg["show_bankbutton"] = 1;
    TInv_Button_ShowBank:Show();
    TInv_SetButton_Anchors();
  end
end

function TInv_Toggle_ReloadButton()
  if (TInvCfg["show_reloadbutton"] == 1) then
    TInvCfg["show_reloadbutton"] = 0;
    TInv_Button_Reload:Hide();
    TInv_SetButton_Anchors();
  else
    TInvCfg["show_reloadbutton"] = 1;
    TInv_Button_Reload:Show();
    TInv_SetButton_Anchors();
  end
end

function TInv_Toggle_SearchBox()
  if (TInvCfg["show_searchbox"] == 1) then
    TInvCfg["show_searchbox"] = 0;
    TInv_SearchBox:Hide();
  else
    TInvCfg["show_searchbox"] = 1;
    TInv_SearchBox:Show();
  end
end

function TInv_Toggle_UserDropdown()
  if (TInvCfg["show_userdropdown"] == 1) then
    TInvCfg["show_userdropdown"] = 0;
    TInv_UserDropdown:Hide();
    TInv_SearchBox:ClearAllPoints();
    TInv_SearchBox:SetPoint("TOPLEFT",TInvFrame,"TOPLEFT",6,27);
  else
    TInvCfg["show_userdropdown"] = 1;
    TInv_UserDropdown:Show();
    TInv_SearchBox:ClearAllPoints();
    TInv_SearchBox:SetPoint("LEFT",TInv_UserDropdown,"RIGHT",5,0);
  end
end

function TInv_Toggle_Money()
  if (TInvCfg["show_money"] == 1) then
    TInvCfg["show_money"] = 0;
    TInv_MoneyViewFrame:Hide();
    TInv_MoneyFrame:Hide();
  else
    TInvCfg["show_money"] = 1;
    TInv_MoneyViewFrame:Show();
    TInv_MoneyFrame:Show();
  end
end

function TInv_Toggle_BagSlotButtons()
  if (TInvCfg["show_bagbuttons"] == 1) then
    TInvCfg["show_bagbuttons"] = 0;
    TInvacterBag0Slot:Hide();
    TInvacterBag1Slot:Hide();
    TInvacterBag2Slot:Hide();
    TInvacterBag3Slot:Hide();
    TInvMenuBarBackpackButton:Hide();
    TInvingButton:Hide();
  else
    TInvCfg["show_bagbuttons"] = 1;
    TInvacterBag0Slot:Show();
    TInvacterBag1Slot:Show();
    TInvacterBag2Slot:Show();
    TInvacterBag3Slot:Show();
    TInvMenuBarBackpackButton:Show();
    TInvingButton:Show();
   end
end

function TInv_Toggle_Total()
  if (TInvCfg["show_total"] == 1) then
    TInvCfg["show_total"] = 0;
    TInvNumTotal:Hide();
  else
    TInvCfg["show_total"] = 1;
    TInvNumTotal:Show();
  end
end

function TInv_RightClick_DeleteItemOverride()
  local bag, slot, itm;

  bag = this.value[TBAG_I_BAG];
  slot = this.value[TBAG_I_SLOT];

  if ( (bag ~= nil) and (slot ~= nil) ) then
    itm = TInvItm[TINV_PLAYERID][bag][slot];
    
    if (itm[TBAG_I_ITEMLINK] ~= nil) then
      local id = TBag_GetItemID(itm[TBAG_I_ITEMLINK]);
      if TInvCfg["item_overrides"][id] ~= nil then
        TInvCfg["item_overrides"][id] = nil;
        HideDropDownMenu(1);

        -- resort will force a window redraw as well
        TInv_UpdateWindow(TBAG_REQ_MUST);
      end
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

    TInvCfg["item_overrides"][TBag_GetItemID(itm[TBAG_I_ITEMLINK])] = new_barclass;
    HideDropDownMenu(2);
    HideDropDownMenu(1);
    TInv_UpdateWindow(TBAG_REQ_MUST);
  end
end

function TInvFrame_RightClickMenu_populate(level)
  local bar, bag, slot;
  local info, itm, id, barclass, tmp, checked, i;
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
    id = TBag_GetItemID(itm[TBAG_I_ITEMLINK]);

    if (level == 1) then
      -- top level of menu

      info = { ["text"] = itm[TBAG_I_NAME], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
      UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = { ["text"] = string.format(L["Current Category: %s"],itm[TBAG_I_CAT]), ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
      UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = { ["text"] = L["Assign item to category:"], ["hasArrow"] = 1, ["value"] = "override_placement" };
      if (TInvCfg["item_overrides"][id] ~= nil) then
        info["checked"] = 1;
      end
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Use default category assignment"],
        ["value"] = { [TBAG_I_BAG]=bag, [TBAG_I_SLOT]=slot },
        ["func"] = TInv_RightClick_DeleteItemOverride
        };
      if (TInvCfg["item_overrides"][id] == nil) then
        info["checked"] = 1;
      end
      UIDropDownMenu_AddButton(info, level);

      if (TINV_SHOWITEMDEBUGINFO==1) then
        info = { ["disabled"] = 1 };
        UIDropDownMenu_AddButton(info, level);

        info = { ["text"] = L["Debug Info: "], ["hasArrow"] = 1, ["value"] = "show_debug" };
        UIDropDownMenu_AddButton(info, level);
      end
    elseif (level == 2) then
      if ( UIDROPDOWNMENU_MENU_VALUE == "override_placement" ) then
        for i = 1, TBAG_BAR_MAX do
          info = {
            ["text"] = string.format(L["Categories within bar %d"],i);
            ["value"] = { ["opt"]="override_placement_select", [TBAG_I_BAG]=bag, [TBAG_I_SLOT]=slot, ["select_bar"]=i },
            ["hasArrow"] = 1
            };
          if (
        (TInvCfg["item_overrides"][id]
        ~= nil) and (TBag_GetCat(TInvCfg, TInvCfg["item_overrides"][id]) == i) ) then
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
          for key,barclass in pairs(TINV_BC_LIST[UIDROPDOWNMENU_MENU_VALUE["select_bar"]]) do
            info = {
              ["text"] = barclass;
              ["value"] = { [TBAG_I_BAG]=bag, [TBAG_I_SLOT]=slot, ["barclass"]=barclass },
              ["func"] = TInv_RightClick_SetItemOverride
              };
            if (TInvCfg["item_overrides"][id] == barclass) then
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

    info = { ["text"] = string.format(L["|c%sBar |r|c%s%s|r"],TBAG_C_INST, TBAG_C_BAR, bar),
      ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);

    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    for key, value in pairs(TINV_BC_LIST[bar]) do
      info = {
        ["text"] = string.format(L["Move: |c%s%s|r"],TBAG_C_CAT,value);
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

    info = { ["text"] = L["Sort Mode:"], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);

    for key, value in pairs({
      [TBAG_SORTBY_NONE] = L["No sort"],
      [TBAG_SORTBY_NORM] = L["Sort by name"],
      [TBAG_SORTBY_REV] = L["Sort last words first"]
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
    
    info = { ["text"] = L["Hide Bar:"], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);
  
    for key,value in pairs({
      [0] = L["Show items assigned to this bar"],
      [1] = L["Hide items assigned to this bar"]
      }) do
    
      if (TBag_GetGrp(TInvCfg, TBAG_G_BAR_HIDE, bar) == key) then
        checked = 1;
      else
        checked = nil;
      end
  
      info = {
        ["text"] = value;
        ["value"] = { [TBAG_I_BAR]=bar, ["value"]=key };
        ["func"] = function()
          TBag_SetGrpDef(TInvCfg, TBAG_G_BAR_HIDE, this.value[TBAG_I_BAR], this.value["value"], 1);
          TBnk_UpdateWindow();
      end,
    ["checked"] = checked
    }; 
      UIDropDownMenu_AddButton(info, level);
    end


    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = { ["text"] = L["Hilight new items:"], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);

    for key,value in pairs({
      [0] = L["Don't tag new items"],
      [1] = L["Tag new items"]
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
        string.format(L["Background Color for Bar %d"],bar), TInv_UpdateWindow);
    UIDropDownMenu_AddButton(info, level);

    info = TBag_MakeColorPickerInfo(TInvCfg, "brdr_", bar,
        string.format(L["Border Color for Bar %d"],bar), TInv_UpdateWindow);
    UIDropDownMenu_AddButton(info, level);

  -------------------------------------------------------------------------------------------------
  ------------------------ MAIN WINDOW CONTEXT MENU -----------------------------------------------
  -------------------------------------------------------------------------------------------------
  elseif (TInv_RightClickMenu_mode == "mainwindow") then
    if (level == 1) then

      info = { ["text"] = string.format(L["TBag v%s"],TBAG_VERSION), ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
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

      info = {
        ["text"] = L["Edit Mode"],
        ["value"] = nil,
        ["func"] = TInv_Button_ChangeEditMode_OnClick
        };
      if (TInv_edit_mode == 1) then
        info["checked"] = 1;
      end
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Lock window"],
        ["value"] = nil,
        ["func"] = TInv_Button_MoveLockToggle_OnClick
        };
      if (TInvCfg["moveLock"] == 0) then
        info["checked"] = 1;
      end
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Reload bags"],
        ["value"] = nil,
        ["func"] = TInv_Button_Reload_OnClick
        };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Show Bank"],
        ["value"] = nil,
        ["func"] = TInv_Button_ShowBank_OnClick
        };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Close Inventory"],
        ["value"] = nil,
        ["func"] = TInv_Close
        };
      UIDropDownMenu_AddButton(info, level);


      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Hilight New Items"],
        ["value"] = nil,
        ["func"] = TInv_Button_HighlightToggle_OnClick
        };
      if (TInv_hilight_new == 1) then
        info["checked"] = 1;
      end
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Reset NEW tag"],
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
        ["text"] = L["Advanced Configuration"],
        ["value"] = nil,
        ["func"] = function()
            TInv_OptsFrame:Show();
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
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "set_colors") then
          TBag_MakeColorMenu(TInvCfg, TInv_UpdateWindow, level, TInv_Bags);
	elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "hide_frames") then
	  info = {
            ["text"] = L["Hide Player Dropdown"];
	    ["func"] = TInv_Toggle_UserDropdown;
	    };
          if (TInvCfg["show_userdropdown"] == 0) then
            info["checked"] = 1;
          end
	  UIDropDownMenu_AddButton(info, level);
	  info = {
            ["text"] = L["Hide Search Box"];
	    ["func"] = TInv_Toggle_SearchBox;
	    };
          if (TInvCfg["show_searchbox"] == 0) then
            info["checked"] = 1;
          end
	  UIDropDownMenu_AddButton(info, level);
	  info = {
            ["text"] = L["Hide Re-sort Button"];
	    ["func"] = TInv_Toggle_ReloadButton;
	    };
          if (TInvCfg["show_reloadbutton"] == 0) then
            info["checked"] = 1;
          end
	  UIDropDownMenu_AddButton(info, level);
	  info = {
            ["text"] = L["Hide Bank Button"];
	    ["func"] = TInv_Toggle_BankButton;
	    };
          if (TInvCfg["show_bankbutton"] == 0) then
            info["checked"] = 1;
          end
	  UIDropDownMenu_AddButton(info, level);
	  info = {
            ["text"] = L["Hide Edit Button"];
	    ["func"] = TInv_Toggle_EditButton;
	    };
          if (TInvCfg["show_editbutton"] == 0) then
            info["checked"] = 1;
          end
	  UIDropDownMenu_AddButton(info, level);
	  info = {
            ["text"] = L["Hide Hilight Button"];
	    ["func"] = TInv_Toggle_HighlightButton;
	    };
          if (TInvCfg["show_hilightbutton"] == 0) then
            info["checked"] = 1;
          end
	  UIDropDownMenu_AddButton(info, level);
	  info = {
            ["text"] = L["Hide Lock Button"];
	    ["func"] = TInv_Toggle_LockButton;
	    };
          if (TInvCfg["show_lockbutton"] == 0) then
            info["checked"] = 1;
          end
	  UIDropDownMenu_AddButton(info, level);
	  info = {
            ["text"] = L["Hide Close Button"];
	    ["func"] = TInv_Toggle_CloseButton;
	    };
          if (TInvCfg["show_closebutton"] == 0) then
            info["checked"] = 1;
          end
	  UIDropDownMenu_AddButton(info, level);
	  info = {
            ["text"] = L["Hide Total"];
	    ["func"] = TInv_Toggle_Total;
	    };
          if (TInvCfg["show_total"] == 0) then
            info["checked"] = 1;
          end
	  UIDropDownMenu_AddButton(info, level);
	  info = {
            ["text"] = L["Hide Bag Buttons"];
	    ["func"] = TInv_Toggle_BagSlotButtons;
	    };
          if (TInvCfg["show_bagbuttons"] == 0) then
            info["checked"] = 1;
          end
	  UIDropDownMenu_AddButton(info, level);
	  info = {
            ["text"] = L["Hide Money"];
	    ["func"] = TInv_Toggle_Money;
	    };
          if (TInvCfg["show_money"] == 0) then
            info["checked"] = 1;
          end
	  UIDropDownMenu_AddButton(info, level);
	elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "select_character") then
	  TInv_UserDropdown_Initialize(level);
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

--  UpdateAddOnMemoryUsage();
--  TBag_PrintDEBUG('TInv_UpdateWindow Start Memory = '..tostring(GetAddOnMemoryUsage("TBag")));
    
  
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

  -- Setup stackarr and comparr
  local stackarr = TBag_CreateStackArr();
  local comparr = TBag_CreateCompArr();
  
  -- SORTING and ITEMCACHE
  if (resort_req == nil) then resort_req = TBAG_REQ_NONE; end
  local cache_req = TBag_UpdateItmCache(TInvCfg, TINV_PLAYERID, TInvItm[TINV_PLAYERID], TInv_Bags,stackarr,comparr);
  if (resort_req == TBAG_REQ_PART) then
    resort_req = resort_req + TINV_CACHE_REQ;
  end
  resort_req = resort_req + cache_req;

  -- Consume a message for bag stacking
  if (TInvCfg["stack_once"] == 1) then
    if (TINV_PLAYERID == TBAG_PLAYERID) then
      TBag_Stack(TBAG_STACK_INV, TInvItm[TINV_PLAYERID], stackarr, comparr);
    end
  end
  TInvCfg["stack_once"] = nil;

  if (resort_req >= TBAG_REQ_MUST) then
    TINV_CACHE_REQ = TBAG_REQ_NONE 
    TINV_BARITM = TBag_SortItmCache(TInvCfg, 
      TINV_PLAYERID, TInvItm[TINV_PLAYERID], TINV_BARITM, TInv_Bags);
    TBag_LayoutWindow(TInvCfg, "TInvFrame", TINV_BARITM, TInvCfg["bar_x"], 
      TInv_edit_mode, TINV_BUTTON_MAX, TInv_AssignButtonsToFrame, 
      TInv_FrameX, TInv_FrameY, TInv_SpaceX, TInv_SpaceY, TInv_PoolX, TInv_PoolY)
  else if (cache_req > TINV_CACHE_REQ) then
      TINV_CACHE_REQ = cache_req
    end
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
    for slot = size+1, MAX_CONTAINER_ITEMS do
      getglobal(TBag_GetBagItemButtonName(bag, slot)):Hide();
    end
  end

  -- MONEY
  if (TInvCfg["show_money"] == 1) then
    MoneyFrame_Update("TInv_MoneyViewFrame", TBag_GetMoney(TINV_PLAYERID));
    if (TINV_PLAYERID == TBAG_PLAYERID) then
      TInv_MoneyViewFrame:Hide();
      TInv_MoneyFrame:Show();
    else
      TInv_MoneyFrame:Hide();
      TInv_MoneyViewFrame:Show();
    end
  end

    frame:ClearAllPoints();
    frame:SetPoint(TInvCfg["frameYRelativeTo"]..TInvCfg["frameXRelativeTo"],
      "UIParent", "BOTTOMLEFT",
      TInvCfg["frame"..TInvCfg["frameXRelativeTo"]] / frame:GetScale(),
      TInvCfg["frame"..TInvCfg["frameYRelativeTo"]] / frame:GetScale());

    
    TBag_ColorFrame(TInvCfg, frame, TBAG_MAIN_BAR);

    if (TInv_edit_mode == 1) then
      TInv_Button_ColumnsAdd:SetText(L["<++>"]);
      TInv_Button_ColumnsAdd:Show();
      TInv_Button_ColumnsDel:SetText(L[">--<"]);
      TInv_Button_ColumnsDel:Show();
    else
      TInv_Button_ColumnsAdd:Hide();
      TInv_Button_ColumnsDel:Hide();
    end

  TInv_SetButton_Anchors();
  
  TInv_WindowIsUpdating = 0;
--  UpdateAddOnMemoryUsage();
--  TBag_PrintDEBUG('TInv_UpdateWindow End Memory = '..tostring(GetAddOnMemoryUsage("TBag")));

end

function TInv_UserDropdown_OnLoad()
  UIDropDownMenu_Initialize(this, TInv_UserDropdown_Initialize);
  UIDropDownMenu_SetSelectedValue(this, TINV_PLAYERID);
  TInv_UserDropdown.tooltip = L["You are viewing this player's inventory."];
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

function TInv_UserDropdown_Initialize(level)
  TBag_UserDropdown_Init(TInv_UserDropdown_OnClick,
    TInvItm, TINV_PLAYERID,TBAG_REALM,level);
end

