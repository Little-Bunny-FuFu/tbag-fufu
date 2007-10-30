-- $Id $
function TBag_ShowHelp(arr)
  for _, line in ipairs(arr) do
    TBag_Print(line);
  end
end

function TBnk_cmd(msg)
  local cmd, params = TBag_SplitStr(msg," ");
  
  cmd = string.lower(cmd);

  if (cmd == "hide") then
    TBnk_Close();
  elseif (cmd == "show") then
    TBnk_Open();
  elseif (cmd == "update") then
    TBnk_UpdateWindow(TBAG_REQ_MUST);
  elseif (cmd == "debug") then
    if (TBnk_DEBUGMESSAGES == 0) then
      TBnk_DEBUGMESSAGES = 1;
      TBag_Print("TBnk: Debugging messages on.");
    else
      TBnk_DEBUGMESSAGES = 0;
      TBag_Print("TBnk: Debugging messages off.");
    end
  elseif (cmd == "reset") then
    TBagCfg["Bnk"] = {};
    TBnk_init(1);
    TBnkOpt_ResizeUpdate();
  elseif (cmd == "resetsorts") then
    TBag_ResetSorts(TBnkCfg);
    TBnk_UpdateWindow(TBAG_REQ_MUST);
  elseif (cmd == "printchars") then
    TBag_PrintCachedCharacters();
  elseif (cmd == "deletechar") then
    local char, realm = TBag_SplitStr(params," ");
    TBag_DeleteCachedCharacter(char,realm); 
  elseif (cmd == "config") then
    TBnk_OptsFrame:Show();
  else
    TBag_ShowHelp(TBNK_HELP);
  end
end


function TInv_cmd(msg)
  local cmd, params = TBag_SplitStr(msg," ");
  
  cmd = string.lower(cmd);

  if (cmd == "hide") then
    TInv_Close();
  elseif (cmd == "show") then
    TInv_Open();
  elseif (cmd == "update") then
    TInv_UpdateWindow(TBAG_REQ_MUST);
  elseif (cmd == "debug") then
    if (TINV_DEBUGMESSAGES == 0) then
      TINV_DEBUGMESSAGES = 1;
      TBag_Print("TInv: Debugging messages on.");
    else
      TINV_DEBUGMESSAGES = 0;
      TBag_Print("TInv: Debugging messages off.");
    end
  elseif (cmd == "reset") then
    TBagCfg["Inv"] = {};
    TInv_init(1);
    TInvOpt_ResizeUpdate();
  elseif (cmd == "resetsorts") then
    TBag_ResetSorts(TInvCfg);
    TInv_UpdateWindow(TBAG_REQ_MUST);
  elseif (cmd == "printchars") then
    TBag_PrintCachedCharacters();
  elseif (cmd == "deletechar") then
    local char, realm = TBag_SplitStr(params," ");
    TBag_DeleteCachedCharacter(char,realm); 
  elseif (cmd == "config") then
    TInv_OptsFrame:Show();
  else
    TBag_ShowHelp(TINV_HELP);
  end
end
