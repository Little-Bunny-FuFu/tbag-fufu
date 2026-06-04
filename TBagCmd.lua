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
    " /tbnk blizzbank  -- toggle hiding Blizzard's default bank UI",
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

-- /tball (both windows) help. Plain strings (these combined-command lines have no
-- localization entries). Without this, a bare /tball delegated to both sub-commands and
-- each printed ITS OWN help -- so only the /tbnk help ended up visible.
local TFuBALL_HELP = {
    "TFuBall (both windows) Commands:",
    " /tball <cmd>  -- run <cmd> on BOTH the inventory and bank windows",
    " /tball show  -- open both windows",
    " /tball hide  -- hide both windows",
    " /tball update  -- refresh both windows",
    " /tball reset  -- reset both windows to default values",
    " /tball resetsorts  -- clear both windows' item search lists",
    " /tball resetpos  -- reset both window positions",
    " (any /tinv or /tbnk subcommand also works here, applied to both)",
};


function TFuBag:ShowHelp(arr)
  -- Brand the header line with the addon prefix (same scheme as the EmptyBag /
  -- search / printchars reports); keep the indented command lines plain so the
  -- block isn't a wall of repeated prefixes.
  for i, line in ipairs(arr) do
    if (i == 1) then
      self:Print(self.SCP..line);
    else
      self:Print(line);
    end
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
      TFuBag:Print(TFuBag.SCP.."Debugging messages on.");
    else
      TFuBag.DEBUGMESSAGES = 0;
      TFuBag:Print(TFuBag.SCP.."Debugging messages off.");
    end
  elseif (cmd == L["reset"]) then
    if (TFuBag.db.profile) then TFuBag.db.profile.Bnk = {}; end
    TFuBnkFrame:init(1);
    TFuBnkFrame:CalcButtonSize(TFuBnkFrame.cfg["frameButtonSize"], TFuBnkFrame.cfg["framePad"]);
    TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
  elseif (cmd == L["resetsorts"]) then
    TFuBag:ResetSorts(TFuBnkFrame.cfg);
    TFuBag:AssignCats(TFuBnkFrame.cfg, 0);
    TFuBag:BuildBarClassList(TFuBnkFrame.BC_LIST, TFuBnkFrame.cfg);
    TFuBag:BumpCatGen();  -- rules changed: force a recat (and a re-sort on next open if hidden)
    TFuBag:Print(TFuBag.SCP.."Bank sort rules reset to defaults.");
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
    TFuBag.ModernOpt:OpenTo("general", "bank");
  elseif (cmd == "reseed") then
    -- Clear BOTH saved Manual Layouts (grid + free) so the active mode re-snapshots
    -- from the current auto-flow on the next layout (mirror of /tinv reseed). The fresh
    -- seed sets cfg.ml_auto, so the bank's Manual Layout then reflows on window resize
    -- like the inventory.
    TFuBnkFrame.cfg.cat_layout = {};
    TFuBnkFrame.cfg.cat_layout_free = {};
    TFuBnkFrame.cfg.ml_auto = true;
    TFuBag:Print(TFuBag.SCP.."Bank Manual Layout reset; will re-snapshot from the default layout.");
    TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
  elseif (cmd == "bank") then
    -- Interim: switch between Character and Warband bank views (clickable per-type
    -- tab buttons are the next stage).
    TFuBnkFrame:ToggleBankType();
  elseif (cmd == "blizzbank") then
    -- Toggle hiding Blizzard's own bank window (tbag replaces it). Account-wide flag;
    -- Bank:ApplyBlizzardBankSuppression neutralizes/reparents (or restores) BankFrame.
    if (TFuBagCfg["hide_blizzard_bank"] == 1) then
      TFuBagCfg["hide_blizzard_bank"] = 0
      TFuBag:Print(TFuBag.SCP.."Blizzard's default bank UI will now SHOW (fully applies on the next bank open).");
    else
      TFuBagCfg["hide_blizzard_bank"] = 1
      TFuBag:Print(TFuBag.SCP.."Blizzard's default bank UI is now HIDDEN.");
    end
    TFuBnkFrame:ApplyBlizzardBankSuppression();
  elseif (cmd == "printtypes") then
    -- TEMP diagnostic: dump distinct item class/subclass buckets in the bags.
    TFuBag:PrintItemTypes();
  elseif (cmd == "printcat") then
    -- TEMP diagnostic: dump each item's resolved category/bar (optional filter).
    TFuBag:PrintCategoryContents("bank", params);
  elseif (cmd == "printnodes") then
    -- STAGE 0 diagnostic: rebuild + dump the category node tree from the legacy tables.
    TFuBag:DumpNodeModel("bank");
  elseif (cmd == "resetnest") then
    -- STAGE 0 transition: wipe legacy cat_nest (the node model owns nesting now). Clears the
    -- corrupt Stage-3 experiment nests so items stop being mis-redirected.
    TFuBnkFrame.cfg.cat_nest = {};
    TFuBag:BumpCatGen();
    TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
    TFuBag:Print(TFuBag.SCP.."Bank category nesting cleared.");
  elseif (cmd == "nodemodel") then
    -- STAGE 1 dev toggle: flip use_node_model for the BANK and force a full recategorize so
    -- every slot re-runs PickBar under the new path. ON = node-driven bar assignment (should
    -- render identical to OFF -- the parity gate).
    local cfg = TFuBnkFrame.cfg;
    if (cfg.use_node_model == 1) then
      cfg.use_node_model = 0;
      TFuBag:Print(TFuBag.SCP.."Bank node model OFF (legacy placement).");
    else
      cfg.use_node_model = 1;
      TFuBag:EnsureNodeModel(cfg);
      TFuBag:Print(TFuBag.SCP.."Bank node model ON (node-driven placement).");
    end
    TFuBag:BumpCatGen();
    TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
  elseif (cmd == "resetnodes") then
    -- STAGE 1 dev: rebuild cfg.cat_nodes from the live legacy tables and force a recategorize.
    -- Run this after changing rules/materials/armour while the node model is on, so node.bar
    -- tracks the current legacy bars.
    local nodes = TFuBag:BuildNodeModelFromLegacy(TFuBnkFrame.cfg);
    local n = 0; for _ in pairs(nodes or {}) do n = n + 1; end
    TFuBag:BumpCatGen();
    TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
    TFuBag:Print(TFuBag.SCP.."Bank node model rebuilt from legacy ("..n.." nodes).");
  elseif (cmd == "nest") then
    -- STAGE 2 dev: nest node <childId> under <parentId> (ids from /tbnk printnodes). The
    -- child's items fold into the root box as an indented sub-group. Needs the node model ON.
    local a, b = TFuBag:SplitStr(params, " ");
    local childId, parentId = tonumber(a), tonumber(b);
    TFuBag:EnsureNodeModel(TFuBnkFrame.cfg);
    if (not childId or not parentId) then
      TFuBag:Print(TFuBag.SCP.."Usage: /tbnk nest <childId> <parentId>  (ids from printnodes)");
    elseif (TFuBag:SetNodeParent(TFuBnkFrame.cfg, childId, parentId)) then
      TFuBag:BumpCatGen();
      TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
      TFuBag:Print(TFuBag.SCP.."Nested node "..childId.." under "..parentId..".");
    else
      TFuBag:Print(TFuBag.SCP.."Nest refused (bad id or would create a cycle).");
    end
  elseif (cmd == "unnest") then
    -- STAGE 2 dev: un-nest node <childId> back to the top level.
    local childId = tonumber(params);
    TFuBag:EnsureNodeModel(TFuBnkFrame.cfg);
    if (not childId) then
      TFuBag:Print(TFuBag.SCP.."Usage: /tbnk unnest <childId>  (id from printnodes)");
    elseif (TFuBag:SetNodeParent(TFuBnkFrame.cfg, childId, nil)) then
      TFuBag:BumpCatGen();
      TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
      TFuBag:Print(TFuBag.SCP.."Un-nested node "..childId..".");
    else
      TFuBag:Print(TFuBag.SCP.."Un-nest refused (bad id).");
    end
  elseif (cmd == "catdiag") then
    -- TEMP diagnostic: dump a category's rules + bar + live tooltip matches.
    TFuBag:CatDiag("bank", params);
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
      TFuBag:Print(TFuBag.SCP.."Debugging messages on.");
    else
      TFuBag.DEBUGMESSAGES = 0;
      TFuBag:Print(TFuBag.SCP.."Debugging messages off.");
    end
  elseif (cmd == L["reset"]) then
    if (TFuBag.db.profile) then TFuBag.db.profile.Inv = {}; end
    TFuInvFrame:init(1);
    TFuInvFrame:CalcButtonSize(TFuInvFrame.cfg["frameButtonSize"], TFuInvFrame.cfg["framePad"]);
    TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST);
  elseif (cmd == L["resetsorts"]) then
    TFuBag:ResetSorts(TFuInvFrame.cfg);
    TFuBag:AssignCats(TFuInvFrame.cfg, 0);
    TFuBag:BuildBarClassList(TFuInvFrame.BC_LIST, TFuInvFrame.cfg);
    TFuBag:BumpCatGen();  -- rules changed: force a recat (and a re-sort on next open if hidden)
    TFuBag:Print(TFuBag.SCP.."Inventory sort rules reset to defaults.");
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
    TFuBag.ModernOpt:OpenTo("general", "inv");
  elseif (cmd == "reseed") then
    -- TEMP: clear BOTH saved Manual Layouts (grid + free) so the active mode
    -- re-snapshots from the current auto-flow on the next enable.
    TFuInvFrame.cfg.cat_layout = {};
    TFuInvFrame.cfg.cat_layout_free = {};
    TFuInvFrame.cfg.ml_auto = true;
    TFuBag:Print(TFuBag.SCP.."Inventory Manual Layout reset; will re-snapshot from the default layout.");
    TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST);
  elseif (cmd == "printtypes") then
    -- TEMP diagnostic: dump distinct item class/subclass buckets in the bags.
    TFuBag:PrintItemTypes();
  elseif (cmd == "printcat") then
    -- TEMP diagnostic: dump each item's resolved category/bar (optional filter).
    TFuBag:PrintCategoryContents("inv", params);
  elseif (cmd == "printnodes") then
    -- STAGE 0 diagnostic: rebuild + dump the category node tree from the legacy tables.
    TFuBag:DumpNodeModel("inv");
  elseif (cmd == "resetnest") then
    -- STAGE 0 transition: wipe legacy cat_nest (the node model owns nesting now). Clears the
    -- corrupt Stage-3 experiment nests so items stop being mis-redirected.
    TFuInvFrame.cfg.cat_nest = {};
    TFuBag:BumpCatGen();
    TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST);
    TFuBag:Print(TFuBag.SCP.."Inventory category nesting cleared.");
  elseif (cmd == "nodemodel") then
    -- STAGE 1 dev toggle: flip use_node_model for the INVENTORY and force a full recategorize
    -- so every slot re-runs PickBar under the new path. ON = node-driven bar assignment (should
    -- render identical to OFF -- the parity gate).
    local cfg = TFuInvFrame.cfg;
    if (cfg.use_node_model == 1) then
      cfg.use_node_model = 0;
      TFuBag:Print(TFuBag.SCP.."Inventory node model OFF (legacy placement).");
    else
      cfg.use_node_model = 1;
      TFuBag:EnsureNodeModel(cfg);
      TFuBag:Print(TFuBag.SCP.."Inventory node model ON (node-driven placement).");
    end
    TFuBag:BumpCatGen();
    TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST);
  elseif (cmd == "resetnodes") then
    -- STAGE 1 dev: rebuild cfg.cat_nodes from the live legacy tables and force a recategorize.
    -- Run this after changing rules/materials/armour while the node model is on, so node.bar
    -- tracks the current legacy bars.
    local nodes = TFuBag:BuildNodeModelFromLegacy(TFuInvFrame.cfg);
    local n = 0; for _ in pairs(nodes or {}) do n = n + 1; end
    TFuBag:BumpCatGen();
    TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST);
    TFuBag:Print(TFuBag.SCP.."Inventory node model rebuilt from legacy ("..n.." nodes).");
  elseif (cmd == "nest") then
    -- STAGE 2 dev: nest node <childId> under <parentId> (ids from /tinv printnodes). The
    -- child's items fold into the root box as an indented sub-group. Needs the node model ON.
    local a, b = TFuBag:SplitStr(params, " ");
    local childId, parentId = tonumber(a), tonumber(b);
    TFuBag:EnsureNodeModel(TFuInvFrame.cfg);
    if (not childId or not parentId) then
      TFuBag:Print(TFuBag.SCP.."Usage: /tinv nest <childId> <parentId>  (ids from printnodes)");
    elseif (TFuBag:SetNodeParent(TFuInvFrame.cfg, childId, parentId)) then
      TFuBag:BumpCatGen();
      TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST);
      TFuBag:Print(TFuBag.SCP.."Nested node "..childId.." under "..parentId..".");
    else
      TFuBag:Print(TFuBag.SCP.."Nest refused (bad id or would create a cycle).");
    end
  elseif (cmd == "unnest") then
    -- STAGE 2 dev: un-nest node <childId> back to the top level.
    local childId = tonumber(params);
    TFuBag:EnsureNodeModel(TFuInvFrame.cfg);
    if (not childId) then
      TFuBag:Print(TFuBag.SCP.."Usage: /tinv unnest <childId>  (id from printnodes)");
    elseif (TFuBag:SetNodeParent(TFuInvFrame.cfg, childId, nil)) then
      TFuBag:BumpCatGen();
      TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST);
      TFuBag:Print(TFuBag.SCP.."Un-nested node "..childId..".");
    else
      TFuBag:Print(TFuBag.SCP.."Un-nest refused (bad id).");
    end
  elseif (cmd == "catdiag") then
    -- TEMP diagnostic: dump a category's rules + bar + live tooltip matches.
    TFuBag:CatDiag("inv", params);
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
  -- No-arg / "help": show the combined helpfile. Otherwise both sub-commands would each
  -- fall through to their own ShowHelp and only the /tbnk help would remain visible.
  local cmd = string.lower((TFuBag:SplitStr(msg, " ")));
  if (cmd == "" or cmd == "help") then
    TFuBag:ShowHelp(TFuBALL_HELP);
    return;
  end
  TFuInv_cmd(msg);
  TFuBnk_cmd(msg);
end
SLASH_TFUBALL1 = "/tball";
SLASH_TFUBALL2 = "/tbagboth";
SlashCmdList["TFUBALL"] = TFuBag_cmd_both;
