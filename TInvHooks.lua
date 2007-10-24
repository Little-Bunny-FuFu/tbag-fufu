TInvHooks_funcs = {
  "CloseAllWindows",
  "OpenBackpack",
  "CloseBackpack",
  "ToggleBackpack",
  "OpenAllBags",
  "OpenBag",
  "CloseBag",
  "ToggleBag",
  "ToggleKeyRing",
  "ContainerFrame_OnShow", 
  "ContainerFrame_OnHide",
  "ContainerFrameItemButton_OnModifiedClick",
  "BagSlotButton_OnClick",
  "BagSlotButton_OnModifiedClick",
  "BagSlotButton_OnDrag",
  "BackpackButton_OnClick",
  "BackpackButton_OnModifiedClick"
};

TInvHooks_savedfuncs = {};

TINV_ALLOWOPENBACKPACK = 0;

function TInvHooks_Register(reg)
  local func, func2;

  if (reg == TBAG_HOOK_REGISTER) then
    for i = 1, table.getn(TInvHooks_funcs) do
      func = getglobal( "TInvHooks_"..TInvHooks_funcs[i] );

      if (func) then
        TInvHooks_savedfuncs[ TInvHooks_funcs[i] ] = getglobal( TInvHooks_funcs[i] );
        setglobal( TInvHooks_funcs[i], func);

        TBag_PrintDEBUG("Hook function for '"..TInvHooks_funcs[i].." installed.");
      else
        TBag_PrintDEBUG("** Hook function for '"..TInvHooks_funcs[i].." SKIPPED **");
      end
    end
  elseif (reg == TBAG_HOOK_UNREGISTER) then
    -- unregister hooks
    for i = 1, table.getn(TInvHooks_funcs) do
      func = getglobal( "TInvHooks_"..TInvHooks_funcs[i] );

      if ( (func) and (TInvHooks_savedfuncs[TInvHooks_funcs[i]]) ) then
        setglobal( TInvHooks_funcs[i], TInvHooks_savedfuncs[TInvHooks_funcs[i]]);
        TInvHooks_savedfuncs[TInvHooks_funcs[i]] = nil;

        TBag_PrintDEBUG("Hook function for '"..TInvHooks_funcs[i].." removed.");
      end
    end
  elseif (reg == TBAG_HOOK_CHECK) then
    -- check if hooks are registered
    TBag_Print( "TInv hooks:" ,1,1,0.2 );
    for i = 1, table.getn(TInvHooks_funcs) do
      func = getglobal( "TInvHooks_"..TInvHooks_funcs[i] );
      func2 = getglobal( TInvHooks_funcs[i] );

      if ( func == func2 ) then
        TBag_Print( "  "..TInvHooks_funcs[i].." is hooked properly." ,0,1,0.25 );
      else
        TBag_Print( "  "..TInvHooks_funcs[i].." is NOT hooked." ,1,0.2,0.2 );
      end
    end
  end
end

local TINV_KEYBINDCHECK = 1;

function TInv_Open()
  if (not TInvFrame:IsVisible()) then
    -- Always default to the current player
    if (TIVN_PLAYERID ~= TBAG_PLAYERID) then
      TInv_SetPlayer(TBAG_PLAYERID)
      TINV_CACHE_REQ = TBAG_REQ_MUST
    end
    TInv_edit_mode = 0;
    TInv_Button_ChangeEditMode:SetText(TBag_Loc("TBag_ChangeEditMode_off"));

    -- Check the keybinding
    if (TINV_KEYBINDCHECK) then
      TBag_ChangeKeybind();
      TINV_KEYBINDCHECK = nil;
    end

    TInvFrame:Show();
  end
  TINV_ALLOWOPENBACKPACK = 0;
end

function TInv_Close()
  if (TInvFrame:IsVisible()) then
    TInvFrame:Hide();
    -- And close all the open bags, too
    CloseBackpack();
    CloseBag(1);
    CloseBag(2);
    CloseBag(3);
    CloseBag(4);
  end

  -- Unhighlight any bags that are still highlighted.
  for _, bag in ipairs(TInv_Bags) do
    TBag_GetBagFrame(bag):SetChecked(0);
  end
  MainMenuBarBackpackButton:SetChecked(0);
  TBag_UpdateButtonHighlights();
  
  -- Always reset to the global player for event processing
  TInv_SetPlayer(TBAG_PLAYERID);
  TINV_ALLOWOPENBACKPACK = 0;
end

function TInv_Toggle()
  if (TInvFrame:IsVisible()) then
    TInv_Close();
  else
    TInv_Open();
  end
end

function TInvHooks_CloseAllWindows()
  TBag_PrintDEBUG("event: CloseAllWindows()");

  local engVisible = TInvFrame:IsVisible();
  if (engVisible) then
    TInv_Close();
  end
 
  local itemsVisible = TInvHooks_savedfuncs["CloseAllWindows"]();
  
  return (itemsVisible or engVisible);
end

function TInvHooks_OpenAllBags()
  TBag_PrintDEBUG("event: OpenAllBags()");

  if (TInvFrame:IsVisible() and TInvCfg["show_blizzard_frames"] == 1) then
    TInvHooks_savedfuncs["OpenAllBags"]();
  else
    TInv_Toggle();
  end

  -- Open the faux bank as well
  if (TBnkFrame:IsVisible() and TBNK_ATBANK==1) then
    for _, bag in ipairs(TBnk_Bags) do 
      OpenBag(bag);
    end
  end
end

-- Only allow bag opening if we are the current player
function TInvHooks_OpenBag(bag)
  TBag_PrintDEBUG("event: OpenBag("..bag..")");
  TInvHooks_savedfuncs["OpenBag"](bag);

  -- Update the texture to the box for the bank bag 
  if (bag == -1) then
    local contid = IsBagOpen(-1);
    if (contid) then
  	  getglobal("ContainerFrame"..contid.."PortraitButton"):SetID(-1);
 	  getglobal("ContainerFrame"..contid.."Name"):SetText("Your Bank");
	  SetPortraitToTexture("ContainerFrame"..contid.."Portrait", "Interface\\Icons\\INV_Box_03");
    end
  end
end

function TInvHooks_CloseBag(bag)
  TBag_PrintDEBUG("event: CloseBag("..bag..")");
  TInvHooks_savedfuncs["CloseBag"](bag);
end

function TInvHooks_ToggleBag(bag)
  TBag_PrintDEBUG("event: ToggleBag("..bag..")");
  TInvHooks_savedfuncs["ToggleBag"](bag);

  -- Update the texture to the box for the bank bag 
  if (bag == -1) then
    local contid = IsBagOpen(-1);
    if (contid) then
  	  getglobal("ContainerFrame"..contid.."PortraitButton"):SetID(-1);
 	  getglobal("ContainerFrame"..contid.."Name"):SetText("Your Bank");
	  SetPortraitToTexture("ContainerFrame"..contid.."Portrait", "Interface\\Icons\\INV_Box_03");
    end
  end
end

function TInvHooks_OpenBackpack()
  TBag_PrintDEBUG("event: OpenBackpack()");
  if (TInvFrame:IsVisible()) and (TINV_ALLOWOPENBACKPACK == 1) then
    TInvHooks_savedfuncs["OpenBackpack"]();
  else
    TInv_Open();
  end
  TINV_ALLOWOPENBACKPACK = 0;
end

function TInvHooks_CloseBackpack()
  TBag_PrintDEBUG("event: CloseBackpack()");
  if (TInvFrame:IsVisible()) then
    TInv_Close();
  else
    TInvHooks_savedfuncs["CloseBackpack"]();
  end
  TINV_ALLOWOPENBACKPACK = 0;
end

function TInvHooks_ToggleBackpack()
  TBag_PrintDEBUG("event: ToggleBackpack()");
  if (TInvCfg["show_Bag0"] == 0) then
    TInvHooks_savedfuncs["ToggleBackpack"]();
  else
    if ((TInvFrame:IsVisible() and TInvCfg["show_blizzard_frames"] == 1)) then
      TInvHooks_savedfuncs["ToggleBackpack"]();
    else
      TInv_Toggle();
      MainMenuBarBackpackButton:SetChecked(0);
    end
  end
end

function TInvHooks_ToggleKeyRing()
  if (TInvCfg["show_Bag"..KEYRING_CONTAINER] == 0) then
    if (TINV_PLAYERID == TBAG_PLAYERID) then
      TInvHooks_savedfuncs["ToggleKeyRing"]();
    else
      this:SetChecked(0);
    end
  else
    if (TInvCfg["show_blizzard_frames"] == 1 and TINV_PLAYERID == TBAG_PLAYERID) then
      if (TInvFrame:IsVisible()) then
        TInvHooks_savedfuncs["ToggleKeyRing"]();
      else
        TInv_Toggle();
	this:SetChecked(0);
      end
    else
      if (this:GetParent() ~= TInvFrame) then
        if (TInvingButton:GetChecked()) then
          TInvingButton:SetChecked(0);
        else
          TInvingButton:SetChecked(1);
        end
      end
      TBag_UpdateButtonHighlights();
    end
  end
end


function TInvHooks_BagSlotButton_OnClick()
  TBag_PrintDEBUG("event: BagSlotButton_OnClick()");
  local bag = this:GetID() - CharacterBag0Slot:GetID() + 1;
  if (TInvCfg["show_Bag"..bag] == 1) then
    if (TInvCfg["show_blizzard_frames"] == 0 or TINV_PLAYERID ~= TBAG_PLAYERID) then
      local id = this:GetID();
      local hadItem = PutItemInBag(id);
      if (not hadItem) then
        TBag_UpdateButtonHighlights();
      end
      if (this:GetParent() ~= TInvFrame) then
        TInv_Toggle();
        this:SetChecked(0);
      end
    else
      if (TInvFrame:IsVisible()) then
        TInvHooks_savedfuncs["BagSlotButton_OnClick"]();
        TInv_UpdateWindow(TBAG_REQ_MUST);
      else 
        TInv_Toggle();
        this:SetChecked(0);
      end
    end
  else
    if (TINV_PLAYERID == TBAG_PLAYERID) then
      TInvHooks_savedfuncs["BagSlotButton_OnClick"]();
    else
      if (this:GetParent() ~= TInvFrame) then
        TInv_Toggle();
      end
      this:SetChecked(0);
    end
  end
end


function TInvHooks_BagSlotButton_OnModifiedClick()
  local bag = this:GetID() - CharacterBag0Slot:GetID() + 1;
  if (IsModifiedClick("CHATLINK")) then
    local bag_itemlink = TBag_GetPlayerBag(TINV_PLAYERID,bag)[TBAG_I_ITEMLINK];
    if (bag_itemlink and ChatEdit_InsertLink(TBag_MakeHyperlink(bag_itemlink))) then
      this:SetChecked(0);
      return true;
    end
  end
  if (TInvCfg["show_Bag"..bag] == 1) then
    if (TInvCfg["show_blizzard_frames"] == 1 and TBAG_PLAYERID == TINV_PLAYERID) then
        if (TInvFrame:IsVisible()) then
          if (IsModifiedClick("OPENALLBAGS")) then
            TInvHooks_savedfuncs["OpenAllBags"]();
          else
            TInvHooks_savedfuncs["BagSlotButton_OnClick"]();
          end
        else
          TInv_Toggle();
  	  this:SetChecked(0);
        end
    else
      if (this:GetParent() ~= TInvFrame) then
        TInv_Toggle();
        this:SetChecked(0);
      else
        TBag_UpdateButtonHighlights();
      end
    end
  else
    if (TINV_PLAYERID == TBAG_PLAYERID) then
      TInvHooks_savedfuncs["BagSlotButton_OnClick"]();
    else
      if (this:GetParent() ~= TInvFrame) then
        TInv_Toggle();
      end
      this:SetChecked(0);
    end
  end
end

function TInvHooks_BagSlotButton_OnDrag()
  TBag_PrintDEBUG("event: BagSlotButton_OnDrag()");
  TInvHooks_savedfuncs["BagSlotButton_OnDrag"]();
  TInv_UpdateWindow(TBAG_REQ_MUST);
end

function TInvHooks_ContainerFrame_OnShow()
  TBag_PrintDEBUG("event: ContainerFrame_OnShow()");
  TInvHooks_savedfuncs["ContainerFrame_OnShow"]();
  -- Update our checked state as well

  TBag_GetBagFrame(this:GetID()):SetChecked(1);
  TBag_UpdateButtonHighlights();
end

function TInvHooks_BackpackButton_OnClick()
  TBag_PrintDEBUG("event: BackpackButton_OnClick()");
  if (TInvCfg["show_Bag0"] == 1) then
    if (TInvCfg["show_blizzard_frames"] == 0 or TINV_PLAYERID ~= TBAG_PLAYERID) then
      if (not PutItemInBackpack()) then
        TBag_UpdateButtonHighlights();
      end
      if (this:GetParent() ~= TInvFrame) then
        TInv_Toggle();
        this:SetChecked(0);
      end
    else
      TInvHooks_savedfuncs["BackpackButton_OnClick"]();
      TInv_UpdateWindow(TBAG_REQ_MUST);
    end
  else
    if (TBAG_PLAYERID == TINV_PLAYERID) then
      TInvHooks_savedfuncs["BackpackButton_OnClick"]();
    else
      if (this:GetParent() ~= TInvFrame) then
        TInv_Toggle();
      end
      this:SetChecked(0);
    end
  end
end

function TInvHooks_BackpackButton_OnModifiedClick()
  if (TInvCfg["show_Bag0"] == 1) then
    if (TInvCfg["show_blizzard_frames"] == 1 and TBAG_PLAYERID == TINV_PLAYERID) then
        if (TInvFrame:IsVisible()) then
            if (IsModifiedClick("OPENALLBAGS")) then
              TInvHooks_savedfuncs["OpenAllBags"]();
            else
              TInvHooks_savedfuncs["BackpackButton_OnClick"]();
            end
        else
          TInv_Toggle();
  	  this:SetChecked(0);
        end
    else
      if (this:GetParent() ~= TInvFrame) then
        TInv_Toggle();
        MainMenuBarBackpackButton:SetChecked(0);
      else
        TBag_UpdateButtonHighlights();
      end
    end
  else
    if (TBAG_PLAYERID == TINV_PLAYERID) then
      TInvHooks_savedfuncs["BackpackButton_OnClick"]();
    else
      if (this:GetParent() ~= TInvFrame) then
        TInv_Toggle();
      end
      this:SetChecked(0);
    end
  end
end

function TInvHooks_ContainerFrame_OnHide()
  TBag_PrintDEBUG("event: ContainerFrame_OnHide()");
  TInvHooks_savedfuncs["ContainerFrame_OnHide"]();
--  TInv_UpdateWindow(TBAG_REQ_MUST);
 
  TBag_GetBagFrame(this:GetID()):SetChecked(0);
  TBag_UpdateButtonHighlights();
end


function TInvHooks_ToggleDropDownMenu(level, value, dropDownFrame, anchorName, xOffset, yOffset)
  TBag_PrintDEBUG("event: ToggleDropDownMenu()");

  TInvHooks_savedfuncs["ToggleDropDownMenu"](level, value, dropDownFrame, anchorName, xOffset, yOffset);

  local frame = getglobal("DropDownList"..UIDROPDOWNMENU_MENU_LEVEL);  

  local adjustX, adjustY;
  
  if ( frame and frame:GetLeft() and frame:GetLeft() * frame:GetScale() < UIParent:GetLeft() * UIParent:GetScale() ) then
    adjustX = ( (UIParent:GetLeft()*UIParent:GetScale()) - (frame:GetLeft()*frame:GetScale()) ) / frame:GetScale();
  elseif ( frame and frame:GetRight() and frame:GetRight()*frame:GetScale() > UIParent:GetRight()*UIParent:GetScale() ) then
    adjustX = ( (UIParent:GetRight()*UIParent:GetScale()) - (frame:GetRight()*frame:GetScale()) ) / frame:GetScale();
  else
    adjustX = 0;
  end

  if ( frame and frame:GetTop() and frame:GetTop()*frame:GetScale() > UIParent:GetTop()*UIParent:GetScale() ) then
    adjustY = ( (UIParent:GetTop()*UIParent:GetScale()) - (frame:GetTop()*frame:GetScale()) ) / frame:GetScale();
  elseif ( frame and frame:GetBottom() and frame:GetBottom() * frame:GetScale() < UIParent:GetBottom() * UIParent:GetScale() ) then
    adjustY = ( (UIParent:GetBottom()*UIParent:GetScale()) - (frame:GetBottom()*frame:GetScale()) ) / frame:GetScale();
  else
    adjustY = 0;
  end

  if ( (adjustY ~= 0) or (adjustX ~= 0) ) then
    TBag_PrintDEBUG("TInvHooks_ToggleDropDownMenu() - adjusting window position by "..adjustX..", "..adjustY);

    adjustX = frame:GetLeft() + adjustX;
    adjustY = frame:GetTop() + adjustY;

    frame:ClearAllPoints();
    frame:SetPoint("TOPLEFT", "UIParent", "BOTTOMLEFT", adjustX, adjustY);
  end
end

function TInvHooks_ContainerFrameItemButton_OnModifiedClick(button)
  local itm = TBag_GetItmFromFrame(TBAG_BUTTONS, this:GetName());
  local alt_pickup = TBagCfg["Inv"]["alt_pickup"];
  local alt_panel = TBagCfg["Inv"]["alt_panel"];
  if (alt_pickup == 0) then alt_pickup = nil; end
  if (alt_panel == 0) then alt_panel = nil; end
  local call_blizzard = true;

  TBag_PrintDEBUG("event: ItemButton_OnModifiedClick this="..this:GetName());

  -- Make sure we are one of our buttons
  if (itm) then
    if (TBag_Member(TInv_Bags,itm[TBAG_I_BAG]) and TBAG_PLAYERID == TINV_PLAYERID) then
      TBag_PrintDEBUG("ItemButton_OnModifiedClick live bag");
      if ( IsAltKeyDown() ) then    -- Manage Alt+Click Auto Trade/Auction
        TBag_PrintDEBUG("ItemButton_OnModifiedClick alt key");
        if (TradeFrame) and (TradeFrame:IsShown()) then
          local tradeslot = TradeFrame_GetAvailableSlot();
          if (tradeslot) and (alt_pickup) then
            PickupContainerItem(itm[TBAG_I_BAG], itm[TBAG_I_SLOT]);
            ClickTradeButton(tradeslot);
            if (CursorHasItem()) then
              PickupContainerItem(itm[TBAG_I_BAG], itm[TBAG_I_SLOT]);
            end
            call_blizzard = false;
          end
        elseif (AuctionFrame) and ( AuctionFrame:IsShown() ) then
          -- Check if we have auctioneer 
          if (AuctionFramePost) and (AuctionFramePost:IsVisible() ) then
            if (alt_pickup) then
              PickupContainerItem(itm[TBAG_I_BAG], itm[TBAG_I_SLOT]);
              AuctionFramePost_AuctionItem_OnClick(AuctionFramePostAuctionItem);
              call_blizzard = false;
            end
          else
            if (alt_panel) then
              AuctionFrameTab_OnClick(3);
            end
            if (PanelTemplates_GetSelectedTab(AuctionFrame) == 3)
              and (alt_pickup) then
              PickupContainerItem(itm[TBAG_I_BAG], itm[TBAG_I_SLOT]);
              ClickAuctionSellItemButton();
              call_blizzard = false;
            end
          end
          if (CursorHasItem()) and (alt_pickup) then
            PickupContainerItem(itm[TBAG_I_BAG], itm[TBAG_I_SLOT]);
            call_blizzard = false;
          end
        elseif (MailFrame) and ( MailFrame:IsShown() ) then
          TBag_PrintDEBUG("ItemButton_OnModifiedClick mailframe");
          -- If we have no CT_MailMod, always send it to the SendMail frame
          if (CT_MailFrame) then
            -- Otherwise, check to see if we have mail already
            if (SendMailFrame:IsVisible()) then
              local itemName = GetSendMailItem();
              if (itemName) then
  -- Disable this until we can figure out how to do it slickly
--                MailFrameTab_OnClick(3);
--                CT_MailButton_OnClick(CT_MailButton2);
--                MailFrameTab_OnClick(2);
--                SendMailPackageButton_OnClick();
--                MailFrameTab_OnClick(3);
--                CT_MailButton_OnClick(CT_MailButton1);
--                CT_Mail_UpdateItemButtons();
              end
            elseif (not CT_MailFrame:IsVisible()) then
              TBag_PrintDEBUG("ItemButton_OnModifiedClick CT_MailFrame:IsVisible yes");
              if (alt_panel) then
                MailFrameTab_OnClick(2);
              end
              if (PanelTemplates_GetSelectedTab(MailFrame) == 2)
                and (alt_pickup) then
                PickupContainerItem(itm[TBAG_I_BAG], itm[TBAG_I_SLOT]);
                ClickSendMailItemButton();
                call_blizzard = false;
              end
            end
          else
            if (alt_panel) then
              MailFrameTab_OnClick(2);
            end
            if (PanelTemplates_GetSelectedTab(MailFrame) == 2)
              and (alt_pickup) then
              PickupContainerItem(itm[TBAG_I_BAG], itm[TBAG_I_SLOT]);
              ClickSendMailItemButton();
              call_blizzard = false;
            end
          end
        end
      end
    elseif (TBNK_ATBANK == 0 or TBAG_PLAYERID ~= TINV_PLAYERID) then
      if (itm[TBAG_I_ITEMLINK] ~= nil) then
        if (IsModifiedClick("CHATLINK")) then
          ChatEdit_InsertLink(TBag_MakeHyperlink(itm[TBAG_I_ITEMLINK]))
          call_blizzard =false;
        elseif (IsModifiedClick("DRESSUP")) then
          DressUpItemLink(TBag_MakeHyperlink(itm[TBAG_I_ITEMLINK]))
          call_blizzard = false;
	elseif (IsModifiedClick("SPLITSTACK")) then
	  call_blizzard = false;
        end
      end
    elseif (TBNK_ATBANK == 1 and itm[TBAG_I_BAG] == -1) then
      TBag_PrintDEBUG('ItemButton_OnModifiedClick At bank click on bank bag');
      BankFrameItemButtonGeneric_OnModifiedClick(button);
      call_blizzard = false;
    end
  end

  if (call_blizzard) then
    TInvHooks_savedfuncs["ContainerFrameItemButton_OnModifiedClick"](button);
  end
end

