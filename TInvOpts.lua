-- $Id $
local TInv_CfgOpt = {};

TINVOPT_UPDATE_HAPPENING = 0;

TINVOPT_FRAME_WIDTH = 800;
TINVOPT_FRAME_BOTTOMPADDING = 30;
TINVOPT_FRAME_BORDER = 5;
TINVOPT_FRAME_LINE_HEIGHT = 20;
TINV_OPTS_SCROLLBARBUTTONWIDTH = 16;
TINV_OPTS_SCROLLBARBUTTONHEIGHT = 16;

-- Height of some default controls
TINV_OPTS_CONTROL_SLIDER_HEIGHT = 17;

TINV_OPTS_SCROLL_LINES = 25;	-- max number of lines inside the scroll

TINVOPT_FRAME_HEIGHT = (TINVOPT_FRAME_LINE_HEIGHT*(TINV_OPTS_SCROLL_LINES+1)) +
	(TINVOPT_FRAME_BORDER*2) +
	TINVOPT_FRAME_BOTTOMPADDING;

TInv_Opts_CurrentPosition = 1;
TInv_Config_MaxScroll = 1;


function TInv_Opts_ControlValueChanged(v)
	if ( (TINVOPT_UPDATE_HAPPENING == 0) and (this.change_value_func ~= nil) ) then
		this.change_value_func(v, this.func_param1, this.func_param2, this.func_param3, this.func_param4);
	end
end


function TInvOpt_SwapSearchItems(unused_value, key1, key2)
  local tmp;

  if ( (TInvCfg["item_search_list"][key1] ~= nil) and (TInvCfg["item_search_list"][key2] ~= nil) ) then
    tmp = TInvCfg["item_search_list"][key1];
    TInvCfg["item_search_list"][key1] = TInvCfg["item_search_list"][key2];
    TInvCfg["item_search_list"][key2] = tmp;

    if (key1 > key2) then
      TInv_Opts_CurrentPosition = TInv_Opts_CurrentPosition - 1;
    else
      TInv_Opts_CurrentPosition = TInv_Opts_CurrentPosition + 1;
    end

    TInv_Options_UpdateWindow();
  end
end

function TInvOpt_ResizeUpdate()
  if (TInvCfg) then
    TInv_CalcButtonSize(TInvCfg["frameButtonSize"], TInvCfg["framePad"]);
    TInv_UpdateWindow(TBAG_REQ_MUST);
  end
end

function TInvOpt_ForceUpdate()
  if (TInvCfg) then
    TInv_UpdateWindow(TBAG_REQ_MUST);
  end
end

function TInvOpt_CreateCfgOpt()
  local key,value;

  TInv_CfgOpt = {};

  TBagOpt_CreateCfgOpt(TInv_CfgOpt, TInvCfg, TInv_Bags, TInv_UpdateWindow, 
    TInvOpt_ResizeUpdate, TInvOpt_ForceUpdate);

  TBagOpt_MakeCheck(TInv_CfgOpt, "Alt Key Auto-Pickup:",
    TInvCfg, "alt_pickup", TInvOpt_ResizeUpdate);
  TBagOpt_MakeCheck(TInv_CfgOpt, "Alt Key Auto-Panel:",
    TInvCfg, "alt_panel", TInvOpt_ResizeUpdate);

  TBagOpt_MakeCheck(TInv_CfgOpt, "Show Keyring Empty Slots (Enable Show above):",
    TInvCfg, "show_keyring_empty_slots", TInvOpt_ResizeUpdate);

  TBagOpt_CreateNewOpt(TInv_CfgOpt, TInvCfg, TInv_UpdateWindow);

  TBagOpt_MakeItemSearchHeader(TInv_CfgOpt);
  TBagOpt_MakeItemSearch(TInv_CfgOpt, TInvCfg, TInvOpt_SwapSearchItems);
end

function TInv_Options_InitWindow()
	TInvOpt_CreateCfgOpt();

	TInv_Config_MaxScroll = math.max( 1, (table.getn(TInv_CfgOpt)-TINV_OPTS_SCROLL_LINES)+2 );

	TBag_PositionFrame( TInv_OptsFrame_ScrollBar:GetName(), "TOPRIGHT",
		TInv_OptsFrame:GetName(), "TOPRIGHT",
		0-(TINVOPT_FRAME_BORDER),
		0-(TINVOPT_FRAME_BORDER+TINV_OPTS_SCROLLBARBUTTONHEIGHT),
		TINV_OPTS_SCROLLBARBUTTONWIDTH,
		TINVOPT_FRAME_HEIGHT -( (TINVOPT_FRAME_BORDER*2) + (TINV_OPTS_SCROLLBARBUTTONHEIGHT*2) ) );
	--Print(" config options size: "..table.getn(TInv_CfgOpt) );
	--Print(" TINV_OPTS_SCROLL_LINES: "..TINV_OPTS_SCROLL_LINES );
	--Print(" Scroll bar max value set to: "..max_scroll );
	TInv_OptsFrame_ScrollBar:SetMinMaxValues(1, TInv_Config_MaxScroll);
	TInv_OptsFrame_ScrollBar:SetValueStep(0.1);
	TInv_OptsFrame_ScrollBar:SetValue(1);

	TInv_OptsFrame:SetWidth( TINVOPT_FRAME_WIDTH );
	TInv_OptsFrame:SetHeight( TINVOPT_FRAME_HEIGHT );

	TInv_OptsFrame:SetBackdropColor(
	  TBag_GetColor(TInvCfg, "bkgr_"..TBAG_MAIN_BAR)
	);
	TInv_OptsFrame:SetBackdropBorderColor(
	  TBag_GetColor(TInvCfg, "brdr_"..TBAG_MAIN_BAR)
	);

	TInv_Options_UpdateWindow();
end

function TInv_Options_UpdateWindow()
	TINVOPT_UPDATE_HAPPENING = 1;

	if (TInv_Opts_CurrentPosition > TInv_Config_MaxScroll) then
		TInv_Opts_CurrentPosition = TInv_Config_MaxScroll;
	end
	
	local y, x_start, x_width;
	local current_opt = math.floor(TInv_Opts_CurrentPosition);
	local fade = 1 - (TInv_Opts_CurrentPosition - current_opt);
	local use_fade;
	local i;
	local shift_y = (TInv_Opts_CurrentPosition - current_opt) * TINVOPT_FRAME_LINE_HEIGHT;

	x_start = TINVOPT_FRAME_BORDER;
	x_width = TINVOPT_FRAME_WIDTH -( (TINVOPT_FRAME_BORDER*3) + TINV_OPTS_SCROLLBARBUTTONWIDTH );
	y = TINVOPT_FRAME_BORDER + TINVOPT_FRAME_LINE_HEIGHT - shift_y;

	for i = 0, TINV_OPTS_SCROLL_LINES-1 do
		if (i==0) then
			use_fade = fade;
		elseif (i==TINV_OPTS_SCROLL_LINES-1) then
			use_fade = 1-fade;
		else
			use_fade = 1;
		end
		y = TBagOpt_EnableLine(
		getglobal("TInv_OptsFrame_Line_"..(i+1)), "TInv_OptsFrame", 
          TINVOPT_FRAME_LINE_HEIGHT, TINV_OPTS_CONTROL_SLIDER_HEIGHT, 
          TInv_CfgOpt[i+current_opt], y, x_start, x_width, use_fade );
	end

	TINVOPT_UPDATE_HAPPENING = 0;
end

function TInv_Opts_Scroll_Update()

end

function TInvOpts_AddCat()
  -- Add a blank entry
  table.insert(TInvCfg["item_search_list"], {"UNKNOWN", "", "", "", ""});

  -- Refresh the window, scrolling down to last entry
  TInvOpt_CreateCfgOpt();
  TInv_Config_MaxScroll = TInv_Config_MaxScroll + 1;
  TInv_OptsFrame_ScrollBar:SetMinMaxValues(1, TInv_Config_MaxScroll);
  TInv_OptsFrame_ScrollBar:SetValue(TInv_Config_MaxScroll);
  TInv_Options_UpdateWindow();
end
