-- $Id$

-- Localization support
local L = TBAG_LOCALE;


local TBNK_HELP = {
    L["TBnk Commands:"],
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

local TINV_HELP = {
    L["TInv Commands:"],
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


function TBag_ShowHelp(arr)
  for _, line in ipairs(arr) do
    TBag_Print(line);
  end
end

function TBnk_cmd(msg)
  local cmd, params = TBag_SplitStr(msg," ");
  
  cmd = string.lower(cmd);

  if (cmd == L["hide"]) then
    TBnk_Close();
  elseif (cmd == L["show"]) then
    TBnk_Open();
  elseif (cmd == L["update"]) then
    TBnk_UpdateWindow(TBAG_REQ_MUST);
  elseif (cmd == L["debug"]) then
    if (TBnk_DEBUGMESSAGES == 0) then
      TBnk_DEBUGMESSAGES = 1;
      TBag_Print("TBnk: Debugging messages on.");
    else
      TBnk_DEBUGMESSAGES = 0;
      TBag_Print("TBnk: Debugging messages off.");
    end
  elseif (cmd == L["reset"]) then
    TBagCfg["Bnk"] = {};
    TBnk_init(1);
    TBnkOpt_ResizeUpdate();
  elseif (cmd == L["resetsorts"]) then
    TBag_ResetSorts(TBnkCfg);
    TBnk_UpdateWindow(TBAG_REQ_MUST);
  elseif (cmd == L["resetpos"]) then
    TBnk_SetDefPos(TBnkCfg,1);
    TBnk_UpdateWindow(TBAG_REQ_MUST);
  elseif (cmd == L["printchars"]) then
    TBag_PrintCachedCharacters();
  elseif (cmd == L["deletechar"]) then
    local char, realm = TBag_SplitStr(params," ");
    TBag_DeleteCachedCharacter(char,realm); 
  elseif (cmd == L["config"]) then
    TBnk_OptsFrame:Show();
  else
    TBag_ShowHelp(TBNK_HELP);
  end
end


function TInv_cmd(msg)
  local cmd, params = TBag_SplitStr(msg," ");
  
  cmd = string.lower(cmd);

  if (cmd == L["hide"]) then
    TInv_Close();
  elseif (cmd == L["show"]) then
    TInv_Open();
  elseif (cmd == L["update"]) then
    TInv_UpdateWindow(TBAG_REQ_MUST);
  elseif (cmd == L["debug"]) then
    if (TINV_DEBUGMESSAGES == 0) then
      TINV_DEBUGMESSAGES = 1;
      TBag_Print("TInv: Debugging messages on.");
    else
      TINV_DEBUGMESSAGES = 0;
      TBag_Print("TInv: Debugging messages off.");
    end
  elseif (cmd == L["reset"]) then
    TBagCfg["Inv"] = {};
    TInv_init(1);
    TInvOpt_ResizeUpdate();
  elseif (cmd == L["resetsorts"]) then
    TBag_ResetSorts(TInvCfg);
    TInv_UpdateWindow(TBAG_REQ_MUST);
  elseif (cmd == L["resetpos"]) then
    TInv_SetDefPos(TInvCfg,1);
    TInv_UpdateWindow(TBAG_REQ_MUST);
  elseif (cmd == L["printchars"]) then
    TBag_PrintCachedCharacters();
  elseif (cmd == L["deletechar"]) then
    local char, realm = TBag_SplitStr(params," ");
    TBag_DeleteCachedCharacter(char,realm); 
  elseif (cmd == L["config"]) then
    TInv_OptsFrame:Show();
  else
    TBag_ShowHelp(TINV_HELP);
  end
end
