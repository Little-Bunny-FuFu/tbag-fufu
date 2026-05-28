-- $Id$

local _G = getfenv(0)

-- Localization Support
local L = TFuBag.LOCALE;

local TFuBnk_CfgOpt = {};

TFuBnk_Options_UPDATE_HAPPENING = 0;

TFuBnk_OptS_SCROLL_LINES = 25; -- max number of lines inside the scroll

TFuBnk_Options_FRAME_WIDTH = 800;
TFuBnk_Options_FRAME_BOTTOMPADDING = 30;
TFuBnk_Options_FRAME_BORDER = 5;
TFuBnk_Options_FRAME_LINE_HEIGHT = 20;
TFuBnk_OptS_SCROLLBARBUTTONWIDTH = 16;
TFuBnk_OptS_SCROLLBARBUTTONHEIGHT = 16;

-- Height of some default controls
TFuBnk_OptS_CONTROL_SLIDER_HEIGHT = 17;

TFuBnk_Options_FRAME_HEIGHT = (TFuBnk_Options_FRAME_LINE_HEIGHT*(TFuBnk_OptS_SCROLL_LINES+1)) +
(TFuBnk_Options_FRAME_BORDER*2) +
TFuBnk_Options_FRAME_BOTTOMPADDING;

TFuBnk_Opts_CurrentPosition = 1;
TFuBnk_Config_MaxScroll = 1;

function TFuBnk_Opts_ControlValueChanged(this,v)
  if ( (TFuBnk_Options_UPDATE_HAPPENING == 0) and (this.change_value_func ~= nil) ) then
    local step = this.GetValueStep and this:GetValueStep() or nil
    if v and step and  step > 0 then
      v = math.ceil(v / step) * step
    end
    -- Debounce the (heavy) change handler so dragging/clicking the slider does
    -- not run a full UpdateWindow on every step (which hangs the game). Coalesce
    -- rapid changes and apply once, shortly after the value stops moving. The
    -- token ensures only the most recently scheduled call runs (trailing edge).
    -- The live value text still updates every step (set by the OnValueChanged).
    this.tfu_pending_value = v
    local token = (this.tfu_change_token or 0) + 1
    this.tfu_change_token = token
    C_Timer.After(0.1, function()
      if this.tfu_change_token == token then
        this.change_value_func(this.tfu_pending_value, this.func_param1, this.func_param2, this.func_param3, this.func_param4);
      end
    end)
  end
  return v
end

function TFuBnkOpt_SwapSearchItems(unused_value, key1, key2)
  local tmp;

  if ( (TFuBnkFrame.cfg["item_search_list"][key1] ~= nil) and (TFuBnkFrame.cfg["item_search_list"][key2] ~= nil) ) then
    tmp = TFuBnkFrame.cfg["item_search_list"][key1];
    TFuBnkFrame.cfg["item_search_list"][key1] = TFuBnkFrame.cfg["item_search_list"][key2];
    TFuBnkFrame.cfg["item_search_list"][key2] = tmp;

    if (key1 > key2) then
      TFuBnk_Opts_CurrentPosition = TFuBnk_Opts_CurrentPosition - 1;
    else
      TFuBnk_Opts_CurrentPosition = TFuBnk_Opts_CurrentPosition + 1;
    end

    TFuBnk_Options_UpdateWindow();
  end
end

function TFuBnkOpt_ResizeUpdate()
  if (TFuBnkFrame.cfg) then
    TFuBnkFrame:CalcButtonSize(TFuBnkFrame.cfg["frameButtonSize"], TFuBnkFrame.cfg["framePad"]);
    TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
  end
end

function TFuBnkOpt_ForceUpdate()
  if (TFuBnkFrame.cfg) then
    TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
  end
end

function TFuBnkOpt_CreateCfgOpt()
  local key,value;

  TFuBnk_CfgOpt = {};

  TFuBag:CreateCfgOpt(TFuBnk_CfgOpt, TFuBnkFrame.cfg, TFuBnkFrame.bags, function () TFuBnkFrame:UpdateWindow() end,
    TFuBnkOpt_ResizeUpdate, TFuBnkOpt_ForceUpdate);

    TFuBag:CreateNewOpt(TFuBnk_CfgOpt, TFuBnkFrame.cfg, function () TFuBnkFrame:UpdateWindow() end);

  TFuBag:MakeItemSearchHeader(TFuBnk_CfgOpt);
  TFuBag:MakeItemSearch(TFuBnk_CfgOpt, TFuBnkFrame.cfg, TFuBnkOpt_SwapSearchItems, TFuBnkOpts_RemoveCat);
end


function TFuBnk_Options_InitWindow()
    TFuBnkOpt_CreateCfgOpt();

    TFuBnk_Config_MaxScroll = math.max( 1, (table.getn(TFuBnk_CfgOpt)-TFuBnk_OptS_SCROLL_LINES)+2 );

    TFuBag:PositionFrame( TFuBnk_OptsFrame_ScrollBar:GetName(), "TOPRIGHT",
    TFuBnk_OptsFrame:GetName(), "TOPRIGHT",
    0-(TFuBnk_Options_FRAME_BORDER),
    0-(TFuBnk_Options_FRAME_BORDER+TFuBnk_OptS_SCROLLBARBUTTONHEIGHT),
    TFuBnk_OptS_SCROLLBARBUTTONWIDTH,
    TFuBnk_Options_FRAME_HEIGHT -( (TFuBnk_Options_FRAME_BORDER*2) + (TFuBnk_OptS_SCROLLBARBUTTONHEIGHT*2) ) );
    --Print(" config Options size: "..table.getn(TFuBnk_CfgOpt) );
    --Print(" TFuBnk_OptS_SCROLL_LINES: "..TFuBnk_OptS_SCROLL_LINES );
    --Print(" Scroll bar max value set to: "..max_scroll );
    TFuBnk_OptsFrame_ScrollBar:SetMinMaxValues(1, TFuBnk_Config_MaxScroll);
    TFuBnk_OptsFrame_ScrollBar:SetValueStep(0.1);
    TFuBnk_OptsFrame_ScrollBar:SetValue(1);

    TFuBnk_OptsFrame:SetWidth( TFuBnk_Options_FRAME_WIDTH );
    TFuBnk_OptsFrame:SetHeight( TFuBnk_Options_FRAME_HEIGHT );

    TFuBnk_OptsFrame:SetBackdropColor(
    --  TFuBag_GetColor(TFuBnkCfg, "bkgr_"..TBAG_MAIN_BAR)
    TFuBnkFrame.cfg["bar_colors_"..TFuBag.MAIN_BAR.."_background_r"],
    TFuBnkFrame.cfg["bar_colors_"..TFuBag.MAIN_BAR.."_background_g"],
    TFuBnkFrame.cfg["bar_colors_"..TFuBag.MAIN_BAR.."_background_b"],
    TFuBnkFrame.cfg["bar_colors_"..TFuBag.MAIN_BAR.."_background_a"] );
    TFuBnk_OptsFrame:SetBackdropBorderColor(
    --  TFuBag_GetColor(TFuBnkCfg, "brdr_"..TBAG_MAIN_BAR)
    TFuBnkFrame.cfg["bar_colors_"..TFuBag.MAIN_BAR.."_border_r"],
    TFuBnkFrame.cfg["bar_colors_"..TFuBag.MAIN_BAR.."_border_g"],
    TFuBnkFrame.cfg["bar_colors_"..TFuBag.MAIN_BAR.."_border_b"],
    TFuBnkFrame.cfg["bar_colors_"..TFuBag.MAIN_BAR.."_border_a"] );

    TFuBnk_Options_UpdateWindow();
end

function TFuBnk_Options_UpdateWindow()
  TFuBnk_Options_UPDATE_HAPPENING = 1;

  if (TFuBnk_Opts_CurrentPosition > TFuBnk_Config_MaxScroll) then
    TFuBnk_Opts_CurrentPosition = TFuBnk_Config_MaxScroll;
  end

  local y, x_start, x_width;
  local current_Opt = math.floor(TFuBnk_Opts_CurrentPosition);
  local fade = 1 - (TFuBnk_Opts_CurrentPosition - current_Opt);
  local use_fade;
  local i;
  local shift_y = (TFuBnk_Opts_CurrentPosition - current_Opt) * TFuBnk_Options_FRAME_LINE_HEIGHT;

  x_start = TFuBnk_Options_FRAME_BORDER;
  x_width = TFuBnk_Options_FRAME_WIDTH -( (TFuBnk_Options_FRAME_BORDER*3) + TFuBnk_OptS_SCROLLBARBUTTONWIDTH );
  y = TFuBnk_Options_FRAME_BORDER + TFuBnk_Options_FRAME_LINE_HEIGHT - shift_y;

  for i = 0, TFuBnk_OptS_SCROLL_LINES-1 do
    if (i==0) then
      use_fade = fade;
    elseif (i==TFuBnk_OptS_SCROLL_LINES-1) then
      use_fade = 1-fade;
    else
      use_fade = 1;
    end
    y = TFuBag:EnableLine(
    _G["TFuBnk_OptsFrame_Line_"..i+1], "TFuBnk_OptsFrame",
    TFuBnk_Options_FRAME_LINE_HEIGHT, TFuBnk_OptS_CONTROL_SLIDER_HEIGHT,
    TFuBnk_CfgOpt[i+current_Opt], y, x_start, x_width, use_fade );
  end

  TFuBnk_Options_UPDATE_HAPPENING = 0;
end

function TFuBnk_Opts_Scroll_Update()

end


function TFuBnkOpts_AddCat()
  -- See TFuInvOpts_AddCat for the rationale on AssignCats here.
  table.insert(TFuBnkFrame.cfg["item_search_list"], {L["UNKNOWN"], "", "", "", ""});
  TFuBag:AssignCats(TFuBnkFrame.cfg, 0);
  TFuBag:BuildBarClassList(TFuBnkFrame.BC_LIST, TFuBnkFrame.cfg);

  -- Refresh the window, scrolling down to last entry
  TFuBnkOpt_CreateCfgOpt();
  TFuBnk_Config_MaxScroll = TFuBnk_Config_MaxScroll + 1;
  TFuBnk_OptsFrame_ScrollBar:SetMinMaxValues(1, TFuBnk_Config_MaxScroll);
  TFuBnk_OptsFrame_ScrollBar:SetValue(TFuBnk_Config_MaxScroll);
  TFuBnk_Options_UpdateWindow();
end

function TFuBnkOpts_RemoveCat(unused_value, key)
  if (key == nil) then return; end
  if (TFuBnkFrame.cfg["item_search_list"][key] == nil) then return; end
  table.remove(TFuBnkFrame.cfg["item_search_list"], key);
  TFuBag:BuildBarClassList(TFuBnkFrame.BC_LIST, TFuBnkFrame.cfg);
  TFuBnkOpt_CreateCfgOpt();
  if (TFuBnk_Config_MaxScroll > 1) then
    TFuBnk_Config_MaxScroll = TFuBnk_Config_MaxScroll - 1;
  end
  TFuBnk_OptsFrame_ScrollBar:SetMinMaxValues(1, TFuBnk_Config_MaxScroll);
  TFuBnk_Options_UpdateWindow();
  TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
end
