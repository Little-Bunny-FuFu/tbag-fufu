TInvHooks_funcs = {
  "CloseAllWindows",
  "OpenBackpack",
  "CloseBackpack",
  "ToggleBackpack",
  "OpenAllBags",
  "OpenBag",
  "CloseBag",
  "ToggleBag",
  "ContainerFrame_OnShow", 
  "ContainerFrame_OnHide",
  "BagSlotButton_OnClick",
  "BagSlotButton_OnDrag"
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

  TBagCfg["TInv_RegisterHooks"] = reg;
end

local TINV_KEYBINDCHECK = 1;

function TInv_Open()
  if (not TInvFrame:IsVisible()) then
    -- Always default to the current player
    TInv_SetPlayer(TBAG_PLAYERID);
    TInv_edit_mode = 0;
    SetPortraitTexture(TInvFramePortrait, "player");

    -- Check the keybinding
    if (TINV_KEYBINDCHECK) then
      TBag_ChangeKeybind();
      TINV_KEYBINDCHECK = nil;
    end

    TInvFrame:Show();
    TInv_UpdateWindow(TBAG_REQ_MUST);
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

  local itemsVisible = TInvHooks_savedfuncs["CloseAllWindows"]();
  local engVisible = TInvFrame:IsVisible();
  
  if (engVisible) then
    TInv_Close();
  end
  return (itemsVisible or engVisible);
end

function TInvHooks_OpenAllBags()
  TBag_PrintDEBUG("event: OpenAllBags()");
  TInvHooks_savedfuncs["OpenAllBags"]();

  -- Open the faux bank as well
  if (TBnkFrame:IsVisible()) then
    for _, bag in ipairs(TBnk_Bags) do 
      OpenBag(bag);
    end
  end
end

-- Only allow bag opening if we are the current player
function TInvHooks_OpenBag(bag)
  TBag_PrintDEBUG("event: OpenBag("..bag..")");
  TInvHooks_savedfuncs["OpenBag"](bag);

  -- Update the texture to the candy sack
  if (bag == -1) then
    local contid = IsBagOpen(-1);
    if (contid) then
  	  getglobal("ContainerFrame"..contid.."PortraitButton"):SetID(-1);
 	  getglobal("ContainerFrame"..contid.."Name"):SetText("Your Bank");
	  SetPortraitToTexture("ContainerFrame"..contid.."Portrait", "Interface\\Icons\\INV_ValentinesCandySack");
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

  -- Update the texture to the candy sack
  if (bag == -1) then
    local contid = IsBagOpen(-1);
    if (contid) then
  	  getglobal("ContainerFrame"..contid.."PortraitButton"):SetID(-1);
 	  getglobal("ContainerFrame"..contid.."Name"):SetText("Your Bank");
	  SetPortraitToTexture("ContainerFrame"..contid.."Portrait", "Interface\\Icons\\INV_ValentinesCandySack");
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
  if (TInvFrame:IsVisible()) then
    TInvHooks_savedfuncs["ToggleBackpack"]();
  else
    TInv_Toggle();
  end
end

function TInvHooks_BagSlotButton_OnClick()
  TBag_PrintDEBUG("event: BagSlotButton_OnClick()");
  TInvHooks_savedfuncs["BagSlotButton_OnClick"]();
  TInv_UpdateWindow(TBAG_REQ_MUST);
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

function TInvHooks_ContainerFrame_OnHide()
  TBag_PrintDEBUG("event: ContainerFrame_OnHide()");
  TInvHooks_savedfuncs["ContainerFrame_OnHide"]();
  TInv_UpdateWindow(TBAG_REQ_MUST);

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
