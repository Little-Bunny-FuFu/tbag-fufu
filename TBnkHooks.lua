-- $Id$
TBnkHooks_funcs = {
  "BankFrameItemButtonBag_OnClick",
  "BankFrameItemButtonBag_Pickup",
  "CloseAllWindows"
};

TBnkHooks_savedfuncs = {};

function TBnkHooks_Register(reg)
  local func, func2;

  if (reg == 1) then
    for i = 1, table.getn(TBnkHooks_funcs) do
      func = getglobal( "TBnkHooks_"..TBnkHooks_funcs[i] );

      if (func) then
        TBnkHooks_savedfuncs[ TBnkHooks_funcs[i] ] = getglobal( TBnkHooks_funcs[i] );
        setglobal( TBnkHooks_funcs[i], func);

        TBag_PrintDEBUG("Hook function for '"..TBnkHooks_funcs[i].." installed.");
      else
        TBag_PrintDEBUG("** Hook function for '"..TBnkHooks_funcs[i].." SKIPPED **");
      end
    end
  elseif (reg == 0) then
    -- unregister hooks
    for i = 1, table.getn(TBnkHooks_funcs) do
      func = getglobal( "TBnkHooks_"..TBnkHooks_funcs[i] );

      if ( (func) and (TBnkHooks_savedfuncs[TBnkHooks_funcs[i]]) ) then
        setglobal( TBnkHooks_funcs[i], TBnkHooks_savedfuncs[TBnkHooks_funcs[i]]);
        TBnkHooks_savedfuncs[TBnkHooks_funcs[i]] = nil;

        TBag_PrintDEBUG("Hook function for '"..TBnkHooks_funcs[i].." removed.");
      end
    end
  elseif (reg == 2) then
    -- check if hooks are registered
    TBag_Print( "TBnk hooks:" ,1,1,0.2 );
    for i = 1, table.getn(TBnkHooks_funcs) do
      func = getglobal( "TBnkHooks_"..TBnkHooks_funcs[i] );
      func2 = getglobal( TBnkHooks_funcs[i] );

      if ( func == func2 ) then
--        TBag_Print( "  "..TBnkHooks_funcs[i].." is hooked properly." ,0,1,0.25 );
      else
--        TBag_Print( "  "..TBnkHooks_funcs[i].." is NOT hooked." ,1,0.2,0.2 );
      end
    end
  end
end

function TBnk_Open()
  if (not TBnkFrame:IsVisible()) then
    -- Always default to the current player
    TBnk_SetPlayer(TBAG_PLAYERID);
    TBnk_edit_mode = 0;
    TBnk_Button_ChangeEditMode:SetText(TBag_Loc("TBag_ChangeEditMode_off"));
    TBnkFrame:Show();

    -- Also open the inventory, if it isn't showing already
    TInv_SynchShowBank();
    if (not TInvFrame:IsVisible()) then
      TInv_Open();
    end
  else
    TBnk_UpdateWindow(TBAG_REQ_MUST);
  end
end

function TBnk_Close()
  TBag_PrintDEBUG("event: TBnk_Close()");
  if (TBnkFrame:IsVisible()) then
    TBnkFrame:Hide();

    TInv_SynchShowBank();
  end
  if (TBNK_ATBANK == 1) then
    TBNK_ATBANK = 0;
    CloseBankFrame();
  end

  CloseBag(5);
  CloseBag(6);
  CloseBag(7);
  CloseBag(8);
  CloseBag(9);
  CloseBag(10);

  -- Unhighlight any bags that are still highlighted.
  for _, bag in ipairs(TBnk_Bags) do
    TBag_GetBagFrame(bag):SetChecked(0);
  end
  TBag_UpdateButtonHighlights();

  -- Always reset to the global player for event processing
  TBnk_SetPlayer(TBAG_PLAYERID);
end

function TBnk_Toggle()
  if (TBnkFrame:IsVisible()) then
    TBnk_Close();
  else
    TBnk_Open();
  end
end


function TBnkHooks_BankFrameItemButtonBag_OnClick(arg1)
  TBag_PrintDEBUG("event: BankFrameItemButtonBag_OnClick()");
  local inventoryID = this:GetInventorySlot();
  local id = this:GetID();
  local hadItem = PutItemInBag(inventoryID);
  if (TBnkCfg["show_blizzard_frames"] == 1 or TBnkCfg["show_Bag"..id] == 0) then
    if (not hadItem and TBNK_ATBANK == 1) then
      -- open bag
      ToggleBag(id);
      PlaySound("BAGMENUBUTTONPRESS");
    end
  end
  if (hadItem or (TBNK_ATBANK == 0 and TBnkCfg["show_Bag"..id] == 0)) then
    this:SetChecked(0);
  end
  TBag_UpdateButtonHighlights();
end

function TBnkHooks_BankFrameItemButtonBag_Pickup(arg1)
  this:SetChecked(0);
  local id = this:GetID();
  if (IsModifiedClick("CHATLINK")) then
    local bag_itemlink = TBag_GetPlayerBag(TBNK_PLAYERID,id)[TBAG_I_ITEMLINK];
    if (bag_itemlink and ChatEdit_InsertLink(TBag_MakeHyperlink(bag_itemlink))) then
      return true;
    end
  end
  if (TBNK_ATBANK == 1) then
    TBnkHooks_savedfuncs["BankFrameItemButtonBag_Pickup"](arg1);
  end
end

function TBnkHooks_CloseAllWindows()
  TBag_PrintDEBUG("event: CloseAllWindows()");

  local itemsVisible = TBnkHooks_savedfuncs["CloseAllWindows"]();
  local engVisible = TBnkFrame:IsVisible();

  if (engVisible) then
    TBnk_Close();
  end

  return (itemsVisible or engVisible);
end

function TBnkHooks_ToggleDropDownMenu(level, value, dropDownFrame, anchorName, xOffset, yOffset)
  TBag_PrintDEBUG("event: ToggleDropDownMenu()");

  TBnkHooks_savedfuncs["ToggleDropDownMenu"](level, value, dropDownFrame, anchorName, xOffset, yOffset);

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
    TBag_PrintDEBUG("ToggleDropDownMenu() - adjusting window position by "..adjustX..", "..adjustY);

    adjustX = frame:GetLeft() + adjustX;
    adjustY = frame:GetTop() + adjustY;

    frame:ClearAllPoints();
    frame:SetPoint("TOPLEFT", "UIParent", "BOTTOMLEFT", adjustX, adjustY);
  end
end
