-- $Id$

-- Localization support
local L = TBAG_LOCALE;

TBnkHooks_funcs = {
  "BankFrameItemButtonBag_OnClick",
  "BankFrameItemButtonBag_Pickup",
  "BankFrameItemButtonGeneric_OnModifiedClick"
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
    TBnkFrame:Show();

    -- Also open the inventory, if it isn't showing already
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
    local itm = TBag_GetPlayerBag(TBNK_PLAYERID,id);
    local hyperlink = TBag_MakeHyperlink(itm[TBAG_I_ITEMLINK],
                                         itm[TBAG_I_NAME],itm[TBAG_I_RARITY]);
    if (hyperlink and ChatEdit_InsertLink(hyperlink)) then
      return true;
    end
  end
  if (TBNK_ATBANK == 1) then
    TBnkHooks_savedfuncs["BankFrameItemButtonBag_Pickup"](arg1);
  end
end

function TBnkHooks_BankFrameItemButtonGeneric_OnModifiedClick(arg1)
  TInvHooks_ContainerFrameItemButton_OnModifiedClick(arg1);  
end

function TBnkHooks_CloseAllWindows()
  TBag_PrintDEBUG("event: CloseAllWindows()");

  if (TBnkFrame:IsVisible()) then
    TBnk_Close();
  end
end
hooksecurefunc('CloseAllWindows', TBnkHooks_CloseAllWindows);
