-- $Id$

local _G = getfenv(0)

-- Localization Support
local L = TFuBag.LOCALE;

local TFuInv_CfgOpt = {};

TFuINVOPT_UPDATE_HAPPENING = 0;

TFuINVOPT_FRAME_WIDTH = 800;
TFuINVOPT_FRAME_BOTTOMPADDING = 30;
TFuINVOPT_FRAME_BORDER = 5;
TFuINVOPT_FRAME_LINE_HEIGHT = 20;
TFuINV_OPTS_SCROLLBARBUTTONWIDTH = 16;
TFuINV_OPTS_SCROLLBARBUTTONHEIGHT = 16;

-- Height of some default controls
TFuINV_OPTS_CONTROL_SLIDER_HEIGHT = 17;

TFuINV_OPTS_SCROLL_LINES = 25; -- max number of lines inside the scroll

TFuINVOPT_FRAME_HEIGHT = (TFuINVOPT_FRAME_LINE_HEIGHT*(TFuINV_OPTS_SCROLL_LINES+1)) +
                       (TFuINVOPT_FRAME_BORDER*2) +
                       TFuINVOPT_FRAME_BOTTOMPADDING;

TFuInv_Opts_CurrentPosition = 1;
TFuInv_Config_MaxScroll = 1;


function TFuInv_Opts_ControlValueChanged(this,v)
  if ( (TFuINVOPT_UPDATE_HAPPENING == 0) and (this.change_value_func ~= nil) ) then
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


function TFuInvOpt_SwapSearchItems(unused_value, key1, key2)
  local tmp;

  if ( (TFuInvFrame.cfg["item_search_list"][key1] ~= nil) and (TFuInvFrame.cfg["item_search_list"][key2] ~= nil) ) then
    tmp = TFuInvFrame.cfg["item_search_list"][key1];
    TFuInvFrame.cfg["item_search_list"][key1] = TFuInvFrame.cfg["item_search_list"][key2];
    TFuInvFrame.cfg["item_search_list"][key2] = tmp;

    if (key1 > key2) then
      TFuInv_Opts_CurrentPosition = TFuInv_Opts_CurrentPosition - 1;
    else
      TFuInv_Opts_CurrentPosition = TFuInv_Opts_CurrentPosition + 1;
    end

    TFuInv_Options_UpdateWindow();
  end
end

function TFuInvOpt_ResizeUpdate()
  if (TFuInvFrame.cfg) then
    TFuInvFrame:CalcButtonSize(TFuInvFrame.cfg["frameButtonSize"], TFuInvFrame.cfg["framePad"]);
    TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST);
  end
end

function TFuInvOpt_ForceUpdate()
  if (TFuInvFrame.cfg) then
    TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST);
  end
end

function TFuInvOpt_CreateCfgOpt()
  local key,value;

  TFuInv_CfgOpt = {};

  TFuBag:CreateCfgOpt(TFuInv_CfgOpt, TFuInvFrame.cfg, TFuInvFrame.bags, function ()
    TFuInvFrame:UpdateWindow() end,
    TFuInvOpt_ResizeUpdate, TFuInvOpt_ForceUpdate);

  TFuBag:MakeCheck(TFuInv_CfgOpt, L["Alt Key Auto-Pickup:"],
    TFuInvFrame.cfg, "alt_pickup", TFuInvOpt_ResizeUpdate);
  TFuBag:MakeCheck(TFuInv_CfgOpt, L["Alt Key Auto-Panel:"],
    TFuInvFrame.cfg, "alt_panel", TFuInvOpt_ResizeUpdate);

    TFuBag:CreateNewOpt(TFuInv_CfgOpt, TFuInvFrame.cfg, function () TFuInvFrame:UpdateWindow() end);

  TFuBag:MakeItemSearchHeader(TFuInv_CfgOpt);
  TFuBag:MakeItemSearch(TFuInv_CfgOpt, TFuInvFrame.cfg, TFuInvOpt_SwapSearchItems);
end

function TFuInv_Options_InitWindow()
  TFuInvOpt_CreateCfgOpt();

  TFuInv_Config_MaxScroll = math.max( 1, (table.getn(TFuInv_CfgOpt)-TFuINV_OPTS_SCROLL_LINES)+2 );

  TFuBag:PositionFrame( TFuInv_OptsFrame_ScrollBar:GetName(), "TOPRIGHT",
  TFuInv_OptsFrame:GetName(), "TOPRIGHT",
  0-(TFuINVOPT_FRAME_BORDER),
  0-(TFuINVOPT_FRAME_BORDER+TFuINV_OPTS_SCROLLBARBUTTONHEIGHT),
  TFuINV_OPTS_SCROLLBARBUTTONWIDTH,
  TFuINVOPT_FRAME_HEIGHT -( (TFuINVOPT_FRAME_BORDER*2) + (TFuINV_OPTS_SCROLLBARBUTTONHEIGHT*2) ) );
  --Print(" config options size: "..table.getn(TFuInv_CfgOpt) );
  --Print(" TFuINV_OPTS_SCROLL_LINES: "..TFuINV_OPTS_SCROLL_LINES );
  --Print(" Scroll bar max value set to: "..max_scroll );
  TFuInv_OptsFrame_ScrollBar:SetMinMaxValues(1, TFuInv_Config_MaxScroll);
  TFuInv_OptsFrame_ScrollBar:SetValueStep(0.1);
  TFuInv_OptsFrame_ScrollBar:SetValue(1);

  TFuInv_OptsFrame:SetWidth( TFuINVOPT_FRAME_WIDTH );
  TFuInv_OptsFrame:SetHeight( TFuINVOPT_FRAME_HEIGHT );

  TFuInv_OptsFrame:SetBackdropColor(
  TFuBag:GetColor(TFuInvFrame.cfg, "bkgr_"..TFuBag.MAIN_BAR)
  );
  TFuInv_OptsFrame:SetBackdropBorderColor(
  TFuBag:GetColor(TFuInvFrame.cfg, "brdr_"..TFuBag.MAIN_BAR)
  );

  TFuInv_Options_UpdateWindow();
end

function TFuInv_Options_UpdateWindow()
  TFuINVOPT_UPDATE_HAPPENING = 1;

  if (TFuInv_Opts_CurrentPosition > TFuInv_Config_MaxScroll) then
    TFuInv_Opts_CurrentPosition = TFuInv_Config_MaxScroll;
  end

  local y, x_start, x_width;
  local current_opt = math.floor(TFuInv_Opts_CurrentPosition);
  local fade = 1 - (TFuInv_Opts_CurrentPosition - current_opt);
  local use_fade;
  local i;
  local shift_y = (TFuInv_Opts_CurrentPosition - current_opt) * TFuINVOPT_FRAME_LINE_HEIGHT;

  x_start = TFuINVOPT_FRAME_BORDER;
  x_width = TFuINVOPT_FRAME_WIDTH -( (TFuINVOPT_FRAME_BORDER*3) + TFuINV_OPTS_SCROLLBARBUTTONWIDTH );
  y = TFuINVOPT_FRAME_BORDER + TFuINVOPT_FRAME_LINE_HEIGHT - shift_y;

  for i = 0, TFuINV_OPTS_SCROLL_LINES-1 do
    if (i==0) then
      use_fade = fade;
    elseif (i==TFuINV_OPTS_SCROLL_LINES-1) then
      use_fade = 1-fade;
    else
      use_fade = 1;
    end
    y = TFuBag:EnableLine(
    _G["TFuInv_OptsFrame_Line_"..i+1], "TFuInv_OptsFrame",
    TFuINVOPT_FRAME_LINE_HEIGHT, TFuINV_OPTS_CONTROL_SLIDER_HEIGHT,
    TFuInv_CfgOpt[i+current_opt], y, x_start, x_width, use_fade );
  end

  TFuINVOPT_UPDATE_HAPPENING = 0;
end

function TFuInv_Opts_Scroll_Update()

end

function TFuInvOpts_AddCat()
  -- Add a blank entry
  table.insert(TFuInvFrame.cfg["item_search_list"], {L["UNKNOWN"], "", "", "", ""});

  -- Refresh the window, scrolling down to last entry
  TFuInvOpt_CreateCfgOpt();
  TFuInv_Config_MaxScroll = TFuInv_Config_MaxScroll + 1;
  TFuInv_OptsFrame_ScrollBar:SetMinMaxValues(1, TFuInv_Config_MaxScroll);
  TFuInv_OptsFrame_ScrollBar:SetValue(TFuInv_Config_MaxScroll);
  TFuInv_Options_UpdateWindow();
end
