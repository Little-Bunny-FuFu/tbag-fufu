-- $Id$

local _G = getfenv(0)
local TFuBag = _G.TFuBag

-- Localization support
local L = TFuBag.LOCALE;

local TFuBNK_HELP = {
    L["TFuBnk Commands:"],
    L[" /tbnk show  -- open window"],
    L[" /tbnk hide  -- hide window"],
    L[" /tbnk update  -- refresh the window"],
    L[" /tbnk config  -- configuration options"],
    L[" /tbnk debug  -- turn debug info on/off"],
    L[" /tbnk reset  -- sets everything back to default values"],
    L[" /tbnk resetpos -- put the bank back to its default position"],
    L[" /tbnk resetsorts -- clears the item search list"],
    L[" /tbnk printchars -- prints a list of all the chars with cached info"],
    L[" /tbnk deletechar CHAR SERVER -- clears all cached info for character "]
};

local TFuINV_HELP = {
    L["TFuInv Commands:"],
    L[" /tinv show  -- open window"],
    L[" /tinv hide  -- hide window"],
    L[" /tinv update  -- refresh the window"],
    L[" /tinv config  -- configuration options"],
    L[" /tinv debug  -- turn debug info on/off"],
    L[" /tinv reset  -- sets everything back to default values"],
    L[" /tinv resetpos -- put the inventory window back to its default position"],
    L[" /tinv resetsorts -- clears the item search list"],
    L[" /tinv printchars -- prints a list of all the chars with cached info"],
    L[" /tinv deletechar CHAR SERVER -- clears all cached info for character "]
};


function TFuBag:ShowHelp(arr)
  for _, line in ipairs(arr) do
    self:Print(line);
  end
end

function TFuBnk_cmd(msg)
  local cmd, params = TFuBag:SplitStr(msg," ");

  cmd = string.lower(cmd);

  if (cmd == L["hide"]) then
    TFuBnkFrame:Hide();
  elseif (cmd == L["show"]) then
    TFuBnkFrame:Show();
  elseif (cmd == L["update"]) then
    TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
  elseif (cmd == L["debug"]) then
    if (TFuBag.DEBUGMESSAGES == 0) then
      TFuBag.DEBUGMESSAGES = 1;
      TFuBag:Print("TFuBnk: Debugging messages on.");
    else
      TFuBag.DEBUGMESSAGES = 0;
      TFuBag:Print("TFuBnk: Debugging messages off.");
    end
  elseif (cmd == L["reset"]) then
    TFuBagCfg["Bnk"] = {};
    TFuBnkFrame:init(1);
    TFuBnkOpt_ResizeUpdate();
  elseif (cmd == L["resetsorts"]) then
    TFuBag:ResetSorts(TFuBnkFrame.cfg);
    TFuBag:AssignCats(TFuBnkFrame.cfg, 0);
    TFuBag:BuildBarClassList(TFuBnkFrame.BC_LIST, TFuBnkFrame.cfg);
    TFuBag:BumpCatGen();  -- rules changed: force a recat (and a re-sort on next open if hidden)
    TFuBag:Print("TFuBnk: Sort rules reset to defaults.");
    TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
  elseif (cmd == L["resetpos"]) then
    TFuBnkFrame:SetDefPos(TFuBnkFrame.cfg,1);
    TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
  elseif (cmd == L["printchars"]) then
    TFuBag:PrintCachedCharacters();
  elseif (cmd == L["deletechar"]) then
    local char, realm = TFuBag:SplitStr(params," ");
    TFuBag:DeleteCachedCharacter(char,realm);
  elseif (cmd == L["config"]) then
    TFuBnk_OptsFrame:Show();
  elseif (cmd == "bank") then
    -- Interim: switch between Character and Warband bank views (clickable per-type
    -- tab buttons are the next stage).
    TFuBnkFrame:ToggleBankType();
  elseif (cmd == "printtypes") then
    -- TEMP diagnostic: dump distinct item class/subclass buckets in the bags.
    TFuBag:PrintItemTypes();
  elseif (cmd == "printcat") then
    -- TEMP diagnostic: dump each item's resolved category/bar (optional filter).
    TFuBag:PrintCategoryContents("bank", params);
  elseif (cmd == L["getcat"] and TFuBag.GetCategory and type(TFuBag.GetCategory) == "function") then
    TFuBag:GetCategory(params);
  elseif (cmd == L["tests"] and TFuBag.RunTests and type(TFuBag.RunTests) == "function") then
    TFuBag:RunTests(params == "verbose");
  else
    TFuBag:ShowHelp(TFuBNK_HELP);
  end
end


function TFuInv_cmd(msg)
  local cmd, params = TFuBag:SplitStr(msg," ");

  cmd = string.lower(cmd);

  if (cmd == L["hide"]) then
    TFuInvFrame:Hide();
  elseif (cmd == L["show"]) then
    TFuInvFrame:Show();
  elseif (cmd == L["update"]) then
    TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST);
  elseif (cmd == L["debug"]) then
    if (TFuBag.DEBUGMESSAGES == 0) then
      TFuBag.DEBUGMESSAGES = 1;
      TFuBag:Print("TFuInv: Debugging messages on.");
    else
      TFuBag.DEBUGMESSAGES = 0;
      TFuBag:Print("TFuInv: Debugging messages off.");
    end
  elseif (cmd == L["reset"]) then
    TFuBagCfg["Inv"] = {};
    TFuInvFrame:init(1);
    TFuInvOpt_ResizeUpdate();
  elseif (cmd == L["resetsorts"]) then
    TFuBag:ResetSorts(TFuInvFrame.cfg);
    TFuBag:AssignCats(TFuInvFrame.cfg, 0);
    TFuBag:BuildBarClassList(TFuInvFrame.BC_LIST, TFuInvFrame.cfg);
    TFuBag:BumpCatGen();  -- rules changed: force a recat (and a re-sort on next open if hidden)
    TFuBag:Print("TFuInv: Sort rules reset to defaults.");
    TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST);
  elseif (cmd == L["resetpos"]) then
    TFuInvFrame:SetDefPos(TFuInvFrame.cfg,1);
    TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST);
  elseif (cmd == L["printchars"]) then
    TFuBag:PrintCachedCharacters();
  elseif (cmd == L["deletechar"]) then
    local char, realm = TFuBag:SplitStr(params," ");
    TFuBag:DeleteCachedCharacter(char,realm);
  elseif (cmd == L["config"]) then
    TFuInv_OptsFrame:Show();
  elseif (cmd == "reseed") then
    -- TEMP: clear BOTH saved Manual Layouts (grid + free) so the active mode
    -- re-snapshots from the current auto-flow on the next enable.
    TFuInvFrame.cfg.cat_layout = {};
    TFuInvFrame.cfg.cat_layout_free = {};
    TFuBag:Print("TFuInv: Manual Layout reset; will re-snapshot from the default layout.");
    TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST);
  elseif (cmd == "printtypes") then
    -- TEMP diagnostic: dump distinct item class/subclass buckets in the bags.
    TFuBag:PrintItemTypes();
  elseif (cmd == "printcat") then
    -- TEMP diagnostic: dump each item's resolved category/bar (optional filter).
    TFuBag:PrintCategoryContents("inv", params);
  elseif (cmd == L["getcat"] and TFuBag.GetCategory and type(TFuBag.GetCategory) == "function") then
    TFuBag:GetCategory(params);
  elseif (cmd == L["tests"] and TFuBag.RunTests and type(TFuBag.RunTests) == "function") then
    TFuBag:RunTests(params == "verbose");
  else
    TFuBag:ShowHelp(TFuINV_HELP);
  end
end

-- Combined command: run the same subcommand on BOTH the inventory and bank windows
-- at once (e.g. /tball resetsorts, /tball show, /tball printcat herb). The separate
-- /tinv and /tbnk commands remain available.
function TFuBag_cmd_both(msg)
  TFuInv_cmd(msg);
  TFuBnk_cmd(msg);
end
SLASH_TFUBALL1 = "/tball";
SLASH_TFUBALL2 = "/tbagboth";
SlashCmdList["TFUBALL"] = TFuBag_cmd_both;
