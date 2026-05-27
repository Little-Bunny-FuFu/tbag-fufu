-- $Id$

local _G = getfenv(0)
local TFuBag = _G.TFuBag

-- Localization Support
local L = TFuBag.LOCALE;



TFuBag.NUMCOL_MIN = 8;
TFuBag.NUMCOL_MAX = 20;

TFuBag.N_BUTTON_MIN = 26;
TFuBag.N_BUTTON_MAX = 50;
TFuBag.A_BUTTONSIZE = { 26, 30, 34, 38, 42, 46, 50 };

TFuBag.N_FONT_MIN = 8;
TFuBag.N_FONT_MAX = 20;
TFuBag.TAG_MAX = 10;

TFuBag.N_SPACE_MAX = 5;
-- Category Spacing has its own, larger range: it is the gap BETWEEN category
-- frames (not item buttons), so it needs more travel than the per-button spaces.
TFuBag.N_CATSPACE_MAX = 30;

-----------------------------------------------------------------------
-- Options
-----------------------------------------------------------------------

local TBAG_HEADER_COLOR = { 1, 1, 1 };
local TBAG_OPT_COLOR = { 1, 1, 0.25 };
local TBAG_OPT_WIDTH = 0.35;
local TBAG_MINMAX_COLOR = { 0, 1, 0.5 };
local TBAG_MINMAX_WIDTH = 0.05;
local TBAG_SPACER_WIDTH = 0.03;

local TBAGOPT_LIST_FRAMES = {
  "Text_1",
  "Text_2",
  "Text_3",
  "Text_4",
  "Text_5",
  "Text_6",
  "Text_7",
  "Text_8",
  "Slider_1",
  "Slider_2",
  "Slider_3",
  "Slider_4",
  "Edit_1",
  "Edit_2",
  "Edit_3",
  "Edit_4",
  "Edit_5",
  "Button_1",
  "Button_2",
  "Button_3",
  "Button_4",
  "UpButton_1",
  "DownButton_1"
};


function TFuBag.NilFunc()
  return nil;
end

function TFuBag.GetCfg(cfg, name)
  return cfg[name];
end
function TFuBag.SetCfg(cfg, name, val)
  cfg[name] = val;
end
function TFuBag.SetCfgUpdate(cfg, name, val, cleanfunc, updatefunc)
  cfg[name] = cleanfunc(val);
--  TFuBag:Print("name="..name..", val="..val);
  updatefunc();
end

function TFuBag:MakeHeader(cfgopt, text)
  table.insert(cfgopt,  {} );
  table.insert(cfgopt,  {
    { ["type"] = "Text", ["ID"] = 1, ["width"] = 1.0, ["color"] = TBAG_HEADER_COLOR, ["align"] = "center",
      ["text"] = text },
  });
end

function TFuBag:MakeCheck(cfgopt, text, cfg, name, updatefunc)
  table.insert(cfgopt,  {
    { ["type"] = "Text", ["ID"] = 1, ["width"] = TBAG_OPT_WIDTH, ["color"] = TBAG_OPT_COLOR, ["text"] = text },
    { ["type"] = "Text", ["ID"] = 2, ["width"] = TBAG_MINMAX_WIDTH, ["color"] = TBAG_MINMAX_COLOR, ["align"] = "right", ["text"] = L["No"] },
    { ["type"] = "Text", ["ID"] = 3, ["width"] = TBAG_SPACER_WIDTH, ["color"] = TBAG_MINMAX_COLOR, ["align"] = "right", [""] = "" },
    { ["type"] = "Slider", ["ID"] = 1, ["width"] = 0.125, ["minValue"] = 0, ["maxValue"] = 1, ["valueStep"] = 1,
      ["defaultValue"] = function()
        return TFuBag.GetCfg(cfg, name);
      end,
      ["func"] = function(v)
        TFuBag.SetCfgUpdate(cfg, name, v, tonumber, updatefunc);
      end
    },
    { ["type"] = "Text", ["ID"] = 3, ["width"] = TBAG_MINMAX_WIDTH, ["color"] = TBAG_MINMAX_COLOR, ["align"] = "left", ["text"] = L["Yes"] }
  });
end

function TFuBag:MakeEdit(cfgopt, text, cfg, name, size, updatefunc)
  table.insert(cfgopt,  {
    { ["type"] = "Text", ["ID"] = 1, ["width"] = TBAG_OPT_WIDTH+TBAG_MINMAX_WIDTH+TBAG_SPACER_WIDTH, ["color"] = TBAG_OPT_COLOR, ["text"] = text },
    { ["type"] = "Edit", ["ID"] = 1, ["width"] = 0.125, ["letters"] = size,
      ["defaultValue"] = function()
        return TFuBag.GetCfg(cfg, name);
      end,
      ["func"] = function(v)
        TFuBag.SetCfgUpdate(cfg, name, v, tostring, updatefunc);
      end
    },
  });
end

function TFuBag:MakeSlider(cfgopt, text, cfg, name, min, max, step, updatefunc)
  table.insert(cfgopt,  {
    { ["type"] = "Text", ["ID"] = 1, ["width"] = TBAG_OPT_WIDTH, ["color"] = TBAG_OPT_COLOR, ["text"] = text },
    { ["type"] = "Text", ["ID"] = 2, ["width"] = TBAG_MINMAX_WIDTH, ["color"] = TBAG_MINMAX_COLOR, ["align"] = "right", ["text"] = min },
    { ["type"] = "Text", ["ID"] = 3, ["width"] = TBAG_SPACER_WIDTH, ["color"] = TBAG_MINMAX_COLOR, ["align"] = "right", [""] = "" },
    { ["type"] = "Slider", ["ID"] = 1, ["width"] = 0.475, ["minValue"] = min, ["maxValue"] = max, ["valueStep"] = step,
      ["defaultValue"] = function()
        return TFuBag.GetCfg(cfg, name);
      end,
      ["func"] = function(v)
        TFuBag.SetCfgUpdate(cfg, name, v, tonumber, updatefunc);
      end
    },
    { ["type"] = "Text", ["ID"] = 3, ["width"] = TBAG_MINMAX_WIDTH, ["color"] = TBAG_MINMAX_COLOR, ["align"] = "left", ["text"] = max }
  });
end



function TFuBag.GetItemSearch(cfg, key, idx)
  return TFuBag:EscapeNL(cfg["item_search_list"][key][idx])
end

function TFuBag.AssignItemSearch(v, cfg, key, idx)
  if (key ~= nil) then
    cfg["item_search_list"][key][idx] = TFuBag:UnEscapeNL(v);
  end
end

function TFuBag.GetItemSearchUpper(cfg, key, idx)
  return string.upper(cfg["item_search_list"][key][idx]);
end

function TFuBag.AssignItemSearchUpper(v, cfg, key, idx)
  if (key ~= nil) then
    cfg["item_search_list"][key][idx] = string.upper(v);
  end
end

function TFuBag:MakeItemSearchHeader(cfgopt)
  table.insert(cfgopt,  {});
  table.insert(cfgopt,  {
    { ["type"] = "Text", ["ID"] = 1, ["width"] = 0.035+0.025+0.025+0.005, ["color"] = TBAG_HEADER_COLOR, ["text"] = "" },
    { ["type"] = "Text", ["ID"] = 2, ["width"] = 0.20, ["color"] = TBAG_HEADER_COLOR, ["text"] = L["Category"] },
    { ["type"] = "Text", ["ID"] = 3, ["width"] = 0.18, ["color"] = TBAG_HEADER_COLOR, ["text"] = L["Keywords"] },
    { ["type"] = "Text", ["ID"] = 4, ["width"] = 0.32, ["color"] = TBAG_HEADER_COLOR, ["text"] = L["Tooltip Search"] },
    { ["type"] = "Text", ["ID"] = 5, ["width"] = 0.12, ["color"] = TBAG_HEADER_COLOR, ["text"] = L["Type"] },
    { ["type"] = "Text", ["ID"] = 6, ["width"] = 0.08, ["color"] = TBAG_HEADER_COLOR, ["text"] = L["SubType"] }
  });
end

function TFuBag:MakeItemSearch(cfgopt, cfg, swapfunc)
  for key = 1, table.getn(cfg["item_search_list"]) do
    local value = cfg["item_search_list"][key];
    table.insert(cfgopt,  {
      { ["type"] = "Text", ["ID"] = 1, ["width"] = 0.035, ["color"] = { 1,0,1 }, ["text"] = key.."." },
      { ["type"] = "UpButton", ["ID"] = 1, ["width"] = 0.025,
        ["param1"] = key, ["param2"] = key-1,
        ["func"] = swapfunc
      },
      { ["type"] = "DownButton", ["ID"] = 1, ["width"] = 0.025,
        ["param1"] = key, ["param2"] = key+1,
        ["func"] = swapfunc
      },
      { ["type"] = "Edit", ["ID"] = 1, ["width"] = 0.20, ["letters"]=25, ["param1"] = cfg, ["param2"] = key, ["param3"] = 1,
      ["defaultValue"] = TFuBag.GetItemSearchUpper, ["func"] = TFuBag.AssignItemSearchUpper
      },
      { ["type"] = "Edit", ["ID"] = 2, ["width"] = 0.18, ["letters"]=25, ["param1"] = cfg, ["param2"] = key, ["param3"] = 2,
      ["defaultValue"] = TFuBag.GetItemSearchUpper, ["func"] = TFuBag.AssignItemSearchUpper
      },
      { ["type"] = "Edit", ["ID"] = 3, ["width"] = 0.32, ["letters"]=50, ["param1"] = cfg, ["param2"] = key, ["param3"] = 3,
      ["defaultValue"] = TFuBag.GetItemSearch, ["func"] = TFuBag.AssignItemSearch
},
      { ["type"] = "Edit", ["ID"] = 4, ["width"] = 0.12, ["letters"]=25, ["param1"] = cfg, ["param2"] = key, ["param3"] = 4,
      ["defaultValue"] = TFuBag.GetItemSearch, ["func"] = TFuBag.AssignItemSearch
      },
      { ["type"] = "Edit", ["ID"] = 5, ["width"] = 0.08, ["letters"]=25, ["param1"] = cfg, ["param2"] = key, ["param3"] = 5,
      ["defaultValue"] = TFuBag.GetItemSearch, ["func"] = TFuBag.AssignItemSearch
      }
      });
  end
end

function TFuBag:CreateCfgOpt(cfgopt, cfg, bagarr, updatefunc, resizefunc, forcefunc)
  self:MakeHeader(cfgopt, L["Main Sizing Preferences"]);
  self:MakeSlider(cfgopt, L["Number of Item Columns:"],
    cfg, "maxColumns", self.NUMCOL_MIN, self.NUMCOL_MAX, 1,
    forcefunc);
  self:MakeSlider(cfgopt, L["Number of Horizontal Bars:"],
    cfg, "bar_x", 1, cfg["maxColumns"], 1,
    forcefunc);
  self:MakeSlider(cfgopt, L["Window Scale:"],
    cfg, "scale", 0.1, 1.0, 0.05,
    forcefunc);
  self:MakeSlider(cfgopt, L["Item Button Size:"],
    cfg, "frameButtonSize", self.N_BUTTON_MIN, self.N_BUTTON_MAX, 1,
    resizefunc);
  self:MakeSlider(cfgopt, L["Item Button Padding:"],
    cfg, "framePad", 0, self.N_SPACE_MAX, 1,
    resizefunc);
  self:MakeSlider(cfgopt, L["Spacing - X Button:"],
    cfg, "frameXSpace", 0, self.N_SPACE_MAX, 1,
    resizefunc);
  self:MakeSlider(cfgopt, L["Spacing - Y Button:"],
    cfg, "frameYSpace", 0, self.N_SPACE_MAX, 1,
    resizefunc);
  self:MakeSlider(cfgopt, L["Spacing - X Pool:"],
    cfg, "frameXPool", 0, self.N_SPACE_MAX, 1,
    resizefunc);
  self:MakeSlider(cfgopt, L["Spacing - Y Pool:"],
    cfg, "frameYPool", 0, self.N_SPACE_MAX, 1,
    resizefunc);
  self:MakeSlider(cfgopt, L["Category Spacing:"],
    cfg, "cat_spacing", 0, self.N_CATSPACE_MAX, 1,
    resizefunc);
  self:MakeSlider(cfgopt, L["Count Font Size:"],
    cfg, "count_font", self.N_FONT_MIN, self.N_FONT_MAX, 1,
    resizefunc);
  self:MakeSlider(cfgopt, L["Count Placement - X:"],
    cfg, "count_font_x", 0, self.N_BUTTON_MAX, 1,
    resizefunc);
  self:MakeSlider(cfgopt, L["Count Placement - Y:"],
    cfg, "count_font_y", 0, self.N_BUTTON_MAX, 1,
    resizefunc);
  self:MakeSlider(cfgopt, L["New Tag Font Size:"],
    cfg, "new_font", self.N_FONT_MIN, self.N_FONT_MAX, 1,
    resizefunc);

  local bag;

  self:MakeHeader(cfgopt, L["Bag Contents Show"]);
  for _, bag in ipairs(bagarr) do
    self:MakeCheck(cfgopt, string.format(L["Show %s:"],self:GetBagDispName(bag)),
      cfg, "show_Bag"..bag, forcefunc);
  end

  self:MakeHeader(cfgopt, L["General Display Preferences"]);
  self:MakeCheck(cfgopt, L["Show Size on Bag Count:"],
    cfg, "show_bag_sizes", updatefunc);
  self:MakeCheck(cfgopt, L["Show Bag Icons on Empty Slots:"],
    cfg, "show_bag_icons", forcefunc);
  self:MakeCheck(cfgopt, L["Spotlight Open or Selected Bags:"],
    cfg, "spotlight_open", updatefunc);
  self:MakeCheck(cfgopt, L["Spotlight Mouseover:"],
    cfg, "spotlight_hover", updatefunc);
  self:MakeCheck(cfgopt, L["Show Item Rarity Color:"],
    cfg, "show_rarity_color", updatefunc);
  self:MakeCheck(cfgopt, L["Show Category Names:"],
    cfg, "show_cat_names", forcefunc);

  self:MakeCheck(cfgopt, L["Auto Stack:"],
    cfg, "stack_auto", updatefunc);
  self:MakeCheck(cfgopt, L["Stack on Re-sort:"],
    cfg, "stack_resort", updatefunc);

  self:MakeCheck(cfgopt, L["Profession Bags precede Sorting:"],
    cfg, "special_bag_sort", updatefunc);
  self:MakeCheck(cfgopt, L["Trade Creation precedes Sorting (Reopen Window):"],
    cfg, "trade_created_sort", forcefunc);
end


function TFuBag:CreateNewOpt(cfgopt, cfg, updatefunc)
  self:MakeHeader(cfgopt, L["New Tag Options"]);
  self:MakeEdit(cfgopt, L["New Tag Text:"],
    cfg, self.V_NEWON, self.TAG_MAX, updatefunc);
  self:MakeEdit(cfgopt, L["Increased Tag Text:"],
    cfg, self.V_NEWPLUS, self.TAG_MAX, updatefunc);
  self:MakeEdit(cfgopt, L["Decreased Tag Text:"],
    cfg, self.V_NEWMINUS, self.TAG_MAX, updatefunc);

  self:MakeSlider(cfgopt, L["New Tag Timeout (minutes):"],
    cfg, "newItemTimeout", 0, 24*60, 15, updatefunc);
  self:MakeSlider(cfgopt, L["Recent Tag Timeout (minutes):"],
    cfg, "recentTimeout", 0, 60, 5, updatefunc);
end


function TFuBag:EnableLine(frame, optsframename, lineheight, sliderheight, elements, y, x_start, available_width, fade )
  local value, e, width_start, width;
  local tmpframe, tmpframe_name;
  local tmpframe_text, tmpframe_text2, tmpframe_text3;
  local used_frames = {};

  self:PositionFrame( frame:GetName(), "TOPLEFT",
  optsframename, "TOPLEFT",
  x_start, 0-y,
  available_width, lineheight );
  y = y + lineheight;
  frame:Show()

  if ((elements ~= nil) and (table.getn(elements) > 0)) then
    width_start = 0;
    for _, e in ipairs(elements) do
      width = e["width"] * available_width;

      tmpframe_name = frame:GetName().."_"..e["type"].."_"..e["ID"];
      tmpframe = _G[tmpframe_name];

      tmpframe.change_value_func = e["func"];
      tmpframe.func_param1 = e["param1"];
      tmpframe.func_param2 = e["param2"];
      tmpframe.func_param3 = e["param3"];
      tmpframe.func_param4 = e["param4"];

      if (e["type"] == "Slider") then
        tmpframe_text = _G[tmpframe:GetName().."_disp_text"];
        tmpframe:SetMinMaxValues(e["minValue"], e["maxValue"]);
        tmpframe:SetValueStep(e["valueStep"]);
        -- Snap drags to the step. Without this, dragging fires OnValueChanged on
        -- every pixel (each doing a full UpdateWindow -> hang), the thumb desyncs
        -- from the stepped value, and binary (0/1) sliders rest at fractions.
        tmpframe:SetObeyStepOnDrag(true);
        tmpframe:SetValue( e["defaultValue"](e["param1"], e["param2"], e["param3"], e["param4"]) );
        tmpframe_text:SetText( tmpframe:GetValue() );
        tmpframe_text:SetJustifyH("LEFT");

        self:PositionFrame( tmpframe_name, "TOPLEFT",
        frame:GetName(), "TOPLEFT",
        width_start+5, 0-((lineheight-sliderheight)/2),
        (width-5)-30, sliderheight );
        tmpframe:Show()
        self:PositionFrame( tmpframe_text:GetName(), "LEFT",
        tmpframe_name.."Thumb", "RIGHT",
        -10, 0,
        55, 20);
        tmpframe_text:Show()
      elseif (e["type"] == "Edit") then
        tmpframe:SetMaxLetters(e["letters"]);
        tmpframe:SetText( e["defaultValue"](e["param1"], e["param2"], e["param3"], e["param4"]) );

        self:PositionFrame( tmpframe_name, "TOPLEFT",
        frame:GetName(), "TOPLEFT",
        width_start+10, 0,
        width, lineheight );
        tmpframe:Show()
      elseif (e["type"] == "Text") then
        tmpframe:SetText(e["text"]);
        if (e["align"] ~= nil) then
          tmpframe:SetJustifyH(e["align"]); -- valid values: LEFT, RIGHT,  CENTER?
        else
          tmpframe:SetJustifyH("LEFT");
        end
        if (e["alignv"] ~= nil) then
          local alignv = e["alignv"]
          -- 12.0: SetJustifyV rejects "CENTER" (vertical justify uses MIDDLE).
          if alignv == "CENTER" then alignv = "MIDDLE" end
          tmpframe:SetJustifyV(alignv); -- valid values: TOP, BOTTOM, MIDDLE
        else
          tmpframe:SetJustifyV("MIDDLE");
        end
        if (e["color"] ~= nil) then
          --tmpframe:SetVertexColor(e["color"][1], e["color"][2], e["color"][3], fade);
          tmpframe:SetTextColor(e["color"][1], e["color"][2], e["color"][3]);
        else
          --tmpframe:SetVertexColor(1,1,0,fade); - yellow, default text
          tmpframe:SetTextColor(1,1,0); -- yellow, default text
        end

        self:PositionFrame( tmpframe_name, "TOPLEFT",
        frame:GetName(), "TOPLEFT",
        width_start, 0,
        width, lineheight );
        tmpframe:Show()
      elseif (e["type"] == "Button") then
        tmpframe:SetText(e["text"]);

        self:PositionFrame( tmpframe_name, "TOPLEFT",
        frame:GetName(), "TOPLEFT",
        width_start, 0,
        width, lineheight );
        tmpframe:Show()
      elseif (e["type"] == "UpButton") then
        self:PositionFrame( tmpframe_name, "TOPLEFT",
        frame:GetName(), "TOPLEFT",
        width_start, 0,
        width, lineheight );
        tmpframe:Show()
      elseif (e["type"] == "DownButton") then
        self:PositionFrame( tmpframe_name, "TOPLEFT",
        frame:GetName(), "TOPLEFT",
        width_start, 0,
        width, lineheight );
        tmpframe:Show()
      end

      tmpframe:SetAlpha(fade);
      used_frames[e["type"].."_"..e["ID"]] = 1;

      width_start = width_start + width;
    end
  end

  for _, value in ipairs(TBAGOPT_LIST_FRAMES) do
    if ( used_frames[value] == nil ) then
      tmpframe = _G[frame:GetName().."_"..value];
      tmpframe:Hide();
    end
  end

  return y;
end
