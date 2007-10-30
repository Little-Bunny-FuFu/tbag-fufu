-- $Id $

local TBnk_CfgOpt = {};

TBnk_Options_UPDATE_HAPPENING = 0;

TBnk_OptS_SCROLL_LINES = 25;	-- max number of lines inside the scroll

TBnk_Options_FRAME_WIDTH = 800;
TBnk_Options_FRAME_BOTTOMPADDING = 30;
TBnk_Options_FRAME_BORDER = 5;
TBnk_Options_FRAME_LINE_HEIGHT = 20;
TBnk_OptS_SCROLLBARBUTTONWIDTH = 16;
TBnk_OptS_SCROLLBARBUTTONHEIGHT = 16;

-- Height of some default controls
TBnk_OptS_CONTROL_SLIDER_HEIGHT = 17;

TBnk_Options_FRAME_HEIGHT = (TBnk_Options_FRAME_LINE_HEIGHT*(TBnk_OptS_SCROLL_LINES+1)) +
	(TBnk_Options_FRAME_BORDER*2) +
	TBnk_Options_FRAME_BOTTOMPADDING;

TBnk_Opts_CurrentPosition = 1;
TBnk_Config_MaxScroll = 1;

function TBnk_Opts_ControlValueChanged(v)
	if ( (TBnk_Options_UPDATE_HAPPENING == 0) and (this.change_value_func ~= nil) ) then
		this.change_value_func(v, this.func_param1, this.func_param2, this.func_param3, this.func_param4);
	end
end

function TBnkOpt_SwapSearchItems(unused_value, key1, key2)
  local tmp;

  if ( (TBnkCfg["item_search_list"][key1] ~= nil) and (TBnkCfg["item_search_list"][key2] ~= nil) ) then
    tmp = TBnkCfg["item_search_list"][key1];
    TBnkCfg["item_search_list"][key1] = TBnkCfg["item_search_list"][key2];
    TBnkCfg["item_search_list"][key2] = tmp;

    if (key1 > key2) then
      TBnk_Opts_CurrentPosition = TBnk_Opts_CurrentPosition - 1;
    else
      TBnk_Opts_CurrentPosition = TBnk_Opts_CurrentPosition + 1;
    end

    TBnk_Options_UpdateWindow();
  end
end

function TBnkOpt_ResizeUpdate()
  if (TBnkCfg) then
    TBnk_CalcButtonSize(TBnkCfg["frameButtonSize"], TBnkCfg["framePad"]);
    TBnk_UpdateWindow(TBAG_REQ_MUST);
  end
end

function TBnkOpt_ForceUpdate()
  if (TBnkCfg) then
    TBnk_UpdateWindow(TBAG_REQ_MUST);
  end
end

function TBnkOpt_CreateCfgOpt()
  local key,value;

  TBnk_CfgOpt = {};

  TBagOpt_CreateCfgOpt(TBnk_CfgOpt, TBnkCfg, TBnk_Bags, TBnk_UpdateWindow, 
    TBnkOpt_ResizeUpdate, TBnkOpt_ForceUpdate);

  TBagOpt_CreateNewOpt(TBnk_CfgOpt, TBnkCfg, TBnk_UpdateWindow);

  TBagOpt_MakeItemSearchHeader(TBnk_CfgOpt);
  TBagOpt_MakeItemSearch(TBnk_CfgOpt, TBnkCfg, TBnkOpt_SwapSearchItems);
end


function TBnk_Options_InitWindow()
    TBnkOpt_CreateCfgOpt();

	TBnk_Config_MaxScroll = math.max( 1, (table.getn(TBnk_CfgOpt)-TBnk_OptS_SCROLL_LINES)+2 );

	TBag_PositionFrame( TBnk_OptsFrame_ScrollBar:GetName(), "TOPRIGHT",
		TBnk_OptsFrame:GetName(), "TOPRIGHT",
		0-(TBnk_Options_FRAME_BORDER),
		0-(TBnk_Options_FRAME_BORDER+TBnk_OptS_SCROLLBARBUTTONHEIGHT),
		TBnk_OptS_SCROLLBARBUTTONWIDTH,
		TBnk_Options_FRAME_HEIGHT -( (TBnk_Options_FRAME_BORDER*2) + (TBnk_OptS_SCROLLBARBUTTONHEIGHT*2) ) );
	--Print(" config Options size: "..table.getn(TBnk_CfgOpt) );
	--Print(" TBnk_OptS_SCROLL_LINES: "..TBnk_OptS_SCROLL_LINES );
	--Print(" Scroll bar max value set to: "..max_scroll );
	TBnk_OptsFrame_ScrollBar:SetMinMaxValues(1, TBnk_Config_MaxScroll);
	TBnk_OptsFrame_ScrollBar:SetValueStep(0.1);
	TBnk_OptsFrame_ScrollBar:SetValue(1);

	TBnk_OptsFrame:SetWidth( TBnk_Options_FRAME_WIDTH );
	TBnk_OptsFrame:SetHeight( TBnk_Options_FRAME_HEIGHT );

	TBnk_OptsFrame:SetBackdropColor(
--	  TBag_GetColor(TBnkCfg, "bkgr_"..TBAG_MAIN_BAR)
		TBagCfg["bar_colors_"..TBAG_MAIN_BAR.."_background_r"],
		TBagCfg["bar_colors_"..TBAG_MAIN_BAR.."_background_g"],
		TBagCfg["bar_colors_"..TBAG_MAIN_BAR.."_background_b"],
		TBagCfg["bar_colors_"..TBAG_MAIN_BAR.."_background_a"] );
	TBnk_OptsFrame:SetBackdropBorderColor(
--	  TBag_GetColor(TBnkCfg, "brdr_"..TBAG_MAIN_BAR)
		TBagCfg["bar_colors_"..TBAG_MAIN_BAR.."_border_r"],
		TBagCfg["bar_colors_"..TBAG_MAIN_BAR.."_border_g"],
		TBagCfg["bar_colors_"..TBAG_MAIN_BAR.."_border_b"],
		TBagCfg["bar_colors_"..TBAG_MAIN_BAR.."_border_a"] );

	TBnk_Options_UpdateWindow();
end

function TBnk_Options_UpdateWindow()
	TBnk_Options_UPDATE_HAPPENING = 1;

	if (TBnk_Opts_CurrentPosition > TBnk_Config_MaxScroll) then
		TBnk_Opts_CurrentPosition = TBnk_Config_MaxScroll;
	end
	
	local y, x_start, x_width;
	local current_Opt = math.floor(TBnk_Opts_CurrentPosition);
	local fade = 1 - (TBnk_Opts_CurrentPosition - current_Opt);
	local use_fade;
	local i;
	local shift_y = (TBnk_Opts_CurrentPosition - current_Opt) * TBnk_Options_FRAME_LINE_HEIGHT;

	x_start = TBnk_Options_FRAME_BORDER;
	x_width = TBnk_Options_FRAME_WIDTH -( (TBnk_Options_FRAME_BORDER*3) + TBnk_OptS_SCROLLBARBUTTONWIDTH );
	y = TBnk_Options_FRAME_BORDER + TBnk_Options_FRAME_LINE_HEIGHT - shift_y;

	for i = 0, TBnk_OptS_SCROLL_LINES-1 do
		if (i==0) then
			use_fade = fade;
		elseif (i==TBnk_OptS_SCROLL_LINES-1) then
			use_fade = 1-fade;
		else
			use_fade = 1;
		end
		y = TBagOpt_EnableLine(
		getglobal("TBnk_OptsFrame_Line_"..(i+1)), "TBnk_OptsFrame", 
          TBnk_Options_FRAME_LINE_HEIGHT, TBnk_OptS_CONTROL_SLIDER_HEIGHT,
          TBnk_CfgOpt[i+current_Opt], y, x_start, x_width, use_fade );
	end

	TBnk_Options_UPDATE_HAPPENING = 0;
end

function TBnk_Opts_Scroll_Update()

end


function TBnkOpts_AddCat()
  -- Add a blank entry
  table.insert(TBnkCfg["item_search_list"], {"UNKNOWN", "", "", "", ""});

  -- Refresh the window, scrolling down to last entry
  TBnkOpt_CreateCfgOpt();
  TBnk_Config_MaxScroll = TBnk_Config_MaxScroll + 1;
  TBnk_OptsFrame_ScrollBar:SetMinMaxValues(1, TBnk_Config_MaxScroll);
  TBnk_OptsFrame_ScrollBar:SetValue(TBnk_Config_MaxScroll);
  TBnk_Options_UpdateWindow();
end
