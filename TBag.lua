-- $Id$

local _G = getfenv(0)
local TFuBag = _G.TFuBag
local self = TFuBag


TFuBag.VERSION = '@project-version@'
if TFuBag.VERSION  == "\64project-version\64" then
  -- Unpackaged source build: the old SVN $Date$/$Rev$ keywords are no longer
  -- substituted in this git fork, so parsing them errored (string.find -> nil
  -- -> string.sub bad argument), aborting the whole TBag.lua chunk at load.
  -- Use a static dev version instead.
  TFuBag.VERSION = "fufu-dev"
end


BINDING_HEADER_TFuBag = "TBag-fufu";

-- 12.0: GameTooltip_AddNewbieTip is now a no-op stub (Blizzard kept the symbol
-- only for Glue support), so every button OnEnter that relied on it silently
-- showed nothing. Fork-local replacement with the SAME (frame, normal, r,g,b,
-- newbie) arg order, so the call sites are a pure rename. Shows the title in the
-- given color with the description wrapped beneath it.
function TFuBag.NewbieTip(frame, normal, r, g, b, newbie)
  GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
  GameTooltip:SetText(normal, r, g, b);
  if newbie then
    GameTooltip:AddLine(newbie, 1, 1, 1, true);
  end
  GameTooltip:Show();
end

-----------------------------------------------------------------------
-- General Constants
-----------------------------------------------------------------------

TFuBag.DEBUGMESSAGES = 0

-- View switching
TFuBag.PLAYERID = "";
TFuBag.REALM = GetRealmName();

-- Main mapping array
TFuBag.BUTTONS = {};

-- GFX settings
-- 48 (was 32): the category uplift gives each per-material trade-goods category and
-- each new 12.0 item class its OWN bar (a bar is one display box; sharing a bar merges
-- categories into one box). Bar frames are created dynamically from BAR_MAX and empty
-- bars don't render, so the higher cap costs nothing until those categories are used.
TFuBag.BAR_MAX = 48;
-- Dedicated bar for empty slots: SortItmCache collects every empty slot here and
-- LayoutWindow draws it as ONE box at the very BOTTOM of the window (below all
-- categories), so empties are a single "Empty" category instead of tiling mid-window.
-- It is the top bar index (BAR_MAX); the normal category rows iterate 1..BAR_MAX-1 and
-- skip it. Category defaults (SetDefLayout) use up to 46, so this reserves no in-use bar.
TFuBag.EMPTY_BAR = 48;
TFuBag.MAIN_BAR = 0;

TFuBag.USERDD_WIDTH = 90;

TFuBag.SORTBY_MIN = 0;
TFuBag.SORTBY_NONE = 0;
TFuBag.SORTBY_NORM = 1;
TFuBag.SORTBY_REV = 2; -- reverses the name then sorts it:  ie:   "Potion Mana Major" vs "Major Mana Potion"
TFuBag.SORTBY_MAX = 2;

TFuBag.REQ_NONE = 0; -- when items haven't changed, or only item counts
TFuBag.REQ_PART = 1; -- when items have changed location, but it's been sorted once and won't break if we don't sort again
TFuBag.REQ_MUST = 2; -- it's never been sorted, the window is in an unstable state, you MUST sort.

-- String constants
TFuBag.CAT_BAR = "catbar";
TFuBag.COLORS = "colors";
TFuBag.CONTAINERS = "containers";

-- Groups
TFuBag.G_BAR_SORT = "bar_sort";
TFuBag.G_USE_NEW  = "use_new";
TFuBag.G_BAR_HIDE = "bar_hide";

-- Used for indexing - MUST BE DISTINCT
TFuBag.I_BAG       = "b";
TFuBag.I_SLOT      = "s";
TFuBag.I_BAGTYPE   = "bt";
TFuBag.I_BAGFREE   = "bf";
TFuBag.I_BAGSIZE   = "bz";

TFuBag.I_CAT       = "c";
TFuBag.I_KEYWORD   = "k";
TFuBag.I_BAR       = "r";

TFuBag.I_ITEMLINK  = "il";
TFuBag.I_ITEMID    = "id";
TFuBag.I_NAME      = "in";
TFuBag.I_TYPE      = "it";
TFuBag.I_SUBTYPE   = "is";

TFuBag.I_RARITY    = "ir";
TFuBag.I_COUNT     = "ic";
TFuBag.I_NEED      = "sn";
TFuBag.I_SOULBOUND = "sb";
TFuBag.I_ACCTBOUND = "ab";
TFuBag.I_CHARGES         = "ch";
TFuBag.I_LINKSUFFIX = "ls"
-- Cached for the item filter (captured from GetItemInfo at scan time so the
-- Expansion / Bind-on-Equip filters work for cached cross-character views too):
TFuBag.I_EXPANSION = "xp";  -- expansionID (15th GetItemInfo return)
TFuBag.I_BINDTYPE  = "bd";  -- bindType (14th GetItemInfo return; 2 = Bind on Equip)
-- Reforging was removed in 6.0,
-- entry left here commented out to remember that
-- rf has been used
--TFuBag.I_REFORGE   = "rf";
TFuBag.I_NOVALUE = "nv";
TFuBag.I_READABLE = "rd";
TFuBag.I_CRAFTINGREAGENT = "cr";

-- Quest item info
TFuBag.I_QUEST_ITEM = "qi";
TFuBag.I_QUEST_ID = "qd";
TFuBag.I_QUEST_ACTIVE = "qa";

-- Tokens
TFuBag.I_HEADER = "hd";
TFuBag.I_EXPAND = "ex";
TFuBag.I_UNUSED = "un";
TFuBag.I_WATCH  = "wa";
TFuBag.I_ICON   = "io";


-- Used in the item compression routines
TFuBag.COMP_EMPTY = "e";
TFuBag.COMP_ITEM = "i";

-- Used in the New mechanism
TFuBag.I_TIMESTAMP = "ts";
TFuBag.I_NEWSTR    = "nw";
TFuBag.V_NEWON     = "newY";
TFuBag.V_NEWOFF    = "newN";
TFuBag.V_NEWPLUS   = "newP";
TFuBag.V_NEWMINUS  = "newM";

-- Used to track slots that can't be hidden until the next resort
TFuBag.FORCED_SHOW = {}

TFuBag.STACK_BNK = 1;
TFuBag.STACK_INV = 2;

-- Local graphics settings
TFuBag.PAD_BOTTOM_EDIT = 30;
TFuBag.PAD_BOTTOM_NORM = 30;
TFuBag.PAD_BOTTOM_SEARCH = 30;
TFuBag.PAD_BOTTOM_SPACER = 5;
TFuBag.PAD_TOP_GFX = 63;
TFuBag.PAD_TOP_NORM = 25;
TFuBag.BORDER = 8;
-- Reserved column on the right of mainFrame for the scrollbar widget. The
-- ScrollBox stops short of this column so bars never lay out behind the
-- scrollbar. MinimalScrollBar's 8px frame has 17px arrow textures; 20px gives
-- the visible widget room with a couple px breathing space on each side.
TFuBag.SB_COL = 20;

TFuBag.COOLDOWN_SCALE = 0.8;

TFuBag.DBC = {  -- Default Bag Colors
  { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 },
  { ["r"] = 1, ["g"] = 0, ["b"] = 0, ["a"] = 1 },
  { ["r"] = 0, ["g"] = 1, ["b"] = 0, ["a"] = 1 },
  { ["r"] = 1, ["g"] = 0.65, ["b"] = 0.05, ["a"] = 1 },
  { ["r"] = 0.8, ["g"] = 0.15, ["b"] = 1, ["a"] = 1 },
  { ["r"] = 0.2, ["g"] = 1, ["b"] = 1, ["a"] = 1 },
  { ["r"] = 0, ["g"] = 0, ["b"] = 1, ["a"] = 1 },
  { ["r"] = 1, ["g"] = 0.2, ["b"] = 0.8, ["a"] = 1 },
  { ["r"] = 0.4, ["g"] = 0.8, ["b"] = 1, ["a"] = 1 }
};

TFuBag.C_CAT  = "ffcc55ee";
TFuBag.C_BAR  = "ffff3366";
TFuBag.C_INST = "ff00ff7f";

TFuBag.SCP  = "|cffcc33ccTBag-fufu: |r";

-- Assorted player info constants
TFuBag.S_MONEY     = "money";
TFuBag.S_BANKSLOTS = "bankS";
TFuBag.S_BANKFULL  = "bankF";
TFuBag.S_EQUIPPED  = "equip";

TFuBag.G_BASIC     = "basic";
TFuBag.S_CLASS     = "class";
TFuBag.S_HEARTH    = "hearth";
TFuBag.S_LEVEL     = "level";
TFuBag.S_FACTION   = "faction";

-- Localization Support
local L = TFuBag.LOCALE;

-----------------------------------------------------------------------
-- Main Bag and Item arrays
-----------------------------------------------------------------------

TFuBag.BAGMIN = REAGENTBANK_CONTAINER;
-- BAGMAX raised from 11 to 16 for the 12.0 bank rewrite: character bank tabs are
-- Enum.BagIndex.CharacterBankTab_1..6 (6-11) and warband/account tabs are
-- AccountBankTab_1..5 (12-16). Every bank helper bounds-checks against BAGMAX,
-- so warband tab ids must be inside it.
TFuBag.BAGMAX = 16;
TFuBag.MAX_REAGENTBANK_ITEMS = 98 -- has to be a constant since game can't tell us in time
TFuBag.MAX_BANKTAB_ITEMS = 98 -- 12.0 bank tabs hold 98 slots; CreateDummyBag/GetBagMaxItems need this (not the 50-slot bag cap)
-- Reagent bag (Enum.BagIndex.ReagentBag = 5, added 10.0) appended last so the
-- existing bag layout order is unchanged; GetContainerNumSlots(5) is 0 when no
-- reagent bag is equipped, so the section degrades to empty/hidden cleanly.
TFuBag.Inv_Bags = { BACKPACK_CONTAINER, 4, 3, 2, 1, 5 };

-- 12.0: the classic fixed bank model (BANK_CONTAINER, REAGENTBANK_CONTAINER, 7
-- purchasable bag slots) is gone. Bnk_Bags is now built dynamically on bank open
-- from the player's purchased tab ids (see TBnk.lua Bank:RebuildTabList). Empty
-- until then so nothing routes to dead classic ids before the first BANKFRAME_OPENED.
TFuBag.Bnk_Bags = {};

-- A bank tab is any container id in the character (6-11) or warband (12-16) range.
function TFuBag:IsBankTab(bag)
  return bag and bag >= 6 and bag <= 16;
end
TFuBag.Body_Slots = {
  ["HeadSlot"] = 1,
  ["NeckSlot"] = 2,
  ["ShoulderSlot"] = 3,
  ["ShirtSlot"] = 4,
  ["ChestSlot"] = 5,
  ["WaistSlot"] = 6,
  ["LegsSlot"] = 7,
  ["FeetSlot"] = 8,
  ["WristSlot"] = 9,
  ["HandsSlot"] = 10,
  ["Finger0Slot"] = 11,
  ["Finger1Slot"] = 12,
  ["Trinket0Slot"] = 13,
  ["Trinket1Slot"] = 14,
  ["BackSlot"] = 15,
  ["MainHandSlot"] = 16,
  ["SecondaryHandSlot"] = 17,
  ["TabardSlot"] = 19
};

TFuBag.D_BAG = 69;    -- A dummy bag number for search format

--[[ New data layout:

  bar, position = refers to the virtual locations
  bag, slot = refers to physical bag/slot

  itmcache[ bag ][ slot ]
    - Contains all the data we collect from the items in the bags.
    - We collect this data before sorting!
  bar_positions[ bar_number ][ position ] = { [TFuBag.I_BAG]=bag, [TFuBag.I_SLOT]=slot }
    - Contains the final locations in my window after sorting
  TFuBag.BUTTONS[ frame_name ] = itmcache[bag][slot]

  stackarr[itemid] = { table of itms ]
    -- has the entry to the itemcach in an array for each itemid.

  comparr = { [TFuBag.COMP_EMPTY] = { empties }, [TFuBag.COMP_ITEM] = { items } }
    -- Contains two arrays.  One containing all the itm entries for empty
    -- slots in special bags and one contain all the itm entries for items
    -- that can go into one of those slots.
--]]

function TFuBag:Init()
  local bag;

  -- Set up the main arrays
  if (TFuBagCfg == nil) then
    TFuBagCfg = {};
    TFuBagCfg["Bnk"] = {};
    TFuBagCfg["Inv"] = {};
  end
  self:RefreshCreations(TFuBagCfg);
  self:RefreshReagents(TFuBagCfg);

  if (TFuBagInfo == nil) then
    TFuBagInfo = {};
  end
  if (TFuInvItm == nil) then
    TFuInvItm = {};
  end
  if (TFuBnkItm == nil) then
    TFuBnkItm = {};
  end
  if (TFuContItm == nil) then
    TFuContItm = {};
  end
  if (TFuBodyItm == nil) then
    TFuBodyItm = {};
  end
  if (TFuMailItm == nil or TFuMailItm[self.S_VERSION] ~= 1) then
    TFuMailItm = {};
    TFuMailItm[self.S_VERSION] = 1;
  end
  if (TFuTknItm == nil) then
    TFuTknItm = {};
  end

  -- Set up the main player arrays
  self.PLAYERID = UnitName("player").."|"..self.REALM;

  if (TFuBagInfo[self.PLAYERID] == nil) then
    self:InitPlayerInfo(self.PLAYERID);
  end
  if (TFuInvItm[self.PLAYERID] == nil) then
    TFuInvItm[self.PLAYERID] = {};
    self:ClearItmCache(TFuInvItm[self.PLAYERID], self.Inv_Bags);
  end
  if (TFuBnkItm[self.PLAYERID] == nil) then
    TFuBnkItm[self.PLAYERID] = {};
    self:ClearItmCache(TFuBnkItm[self.PLAYERID], self.Bnk_Bags);
  end
  if (TFuContItm[self.PLAYERID] == nil) then
    TFuContItm[self.PLAYERID] = {};
    TFuContItm[self.PLAYERID][self.D_BAG] = {};
    self:ClearItmCache(TFuContItm[self.PLAYERID][self.D_BAG], self.Inv_Bags);
    self:ClearItmCache(TFuContItm[self.PLAYERID][self.D_BAG], self.Bnk_Bags);
  end
  if (TFuBodyItm[self.PLAYERID] == nil) then
    TFuBodyItm[self.PLAYERID] = {};
    TFuBodyItm[self.PLAYERID][self.D_BAG] = {};
    self:ClearItmCache(TFuBodyItm[self.PLAYERID][self.D_BAG], self.Body_Slots);
  end
  if (TFuMailItm[self.PLAYERID] == nil) then
    TFuMailItm[self.PLAYERID] = {};
  end
  if (TFuTknItm[self.PLAYERID] == nil) then
    TFuTknItm[self.PLAYERID] = {};
  end

  -- Force the frame with negative ids to the proper value.
  -- Can't set frames to negative values from XML. :(
  _G[self:GetDummyBagFrameName(BANK_CONTAINER)]:SetID(BANK_CONTAINER);
  _G[self:GetDummyBagFrameName(REAGENTBANK_CONTAINER)]:SetID(REAGENTBANK_CONTAINER);

  -- Initialize any player related info
  local group,_;
  group = TFuBagInfo[self.PLAYERID][self.G_BASIC];
  _, group[self.S_CLASS] = UnitClass("player");
  group[self.S_HEARTH] = GetBindLocation();

  -- Cleanout old trash
  self:CleanConfig();

  -- And reset the keybinding, if need be
  LoadAddOn("Blizzard_BindingUI");
end

-----------------------------------------------------------------------
-- UTILITY Funcs
-----------------------------------------------------------------------

function TFuBag:PrintDEBUG(msg,r,g,b,frame,id,unknown4th)
  if ((self.DEBUGMESSAGES) == 1) then
    self:Print(msg,r,g,b,frame,id,unknown4th)
  end
end

function TFuBag:Print(msg,r,g,b,frame,id,unknown4th)
  if (not r) then r = 1.0; end
  if (not g) then g = 1.0; end
  if (not b) then b = 0.0; end
  if ( Print ) then
    Print(msg, r, g, b, frame, id, unknown4th);
    return;
  end
  if(unknown4th) then
    local temp = id;
    id = unknown4th;
    unknown4th = id;
  end

  if ( frame ) then
    frame:AddMessage(msg,r,g,b,id,unknown4th);
  else
    if ( DEFAULT_CHAT_FRAME ) then
      DEFAULT_CHAT_FRAME:AddMessage(msg, r, g, b,id,unknown4th);
    end
  end
end

function TFuBag:ReverseString(strtorev,toggle)
  local out = "", s1, s2;

  s2 = strtorev;

  if toggle==2 then
  repeat
    s1, s2 = self:SplitStr(s2," ");
    if out == "" then
      out = s1..out;
    else
      out = s1.." "..out;
    end

  until s2 == "";
  else
  out = strtorev;
  end

  return(out);
end

function TFuBag:GetSafeVal(arr, idx, val)
  if (arr == nil) then
    return val;
  elseif (arr[idx] == nil) then
    return val;
  else
    return arr[idx];
  end
end

function TFuBag:InitPlayerInfo(playerid)
  TFuBagInfo[playerid] = {};
  TFuBagInfo[playerid][self.S_TRADES] = {};
  TFuBagInfo[playerid][self.S_SECOND] = {};
  TFuBagInfo[playerid][self.S_SKILLS] = {};

  TFuBagInfo[playerid][self.G_BASIC] = {};
end

function TFuBag:GetPlayer(playerid)
  if (TFuBagInfo[playerid] == nil) then
    self:InitPlayerInfo(playerid);
  end
  return TFuBagInfo[playerid];
end

function TFuBag:GetPlayerInfo(playerid, name)
  return self:GetPlayer(playerid)[name];
end

function TFuBag:SetPlayerInfo(playerid, name, val)
  self:GetPlayer(playerid)[name] = val;
end

function TFuBag:GetPlayerBag(playerid, bag)
  if (TFuContItm[playerid] == nil) then
    TFuContItm[playerid] = {};
  end
  if (TFuContItm[playerid][self.D_BAG] == nil) then
    TFuContItm[playerid][self.D_BAG] = {};
  end

  local bags = TFuContItm[playerid][self.D_BAG];
  if (bags[bag] == nil) then
    bags[bag] = {
      [self.I_BAGFREE] = 0,
      [self.I_BAGSIZE] = 0,
      [self.I_BAGTYPE] = 0,
      [self.I_ITEMLINK] = nil,
      [self.I_ITEMID] = nil,
      [self.I_NAME] = nil,
      [self.I_COUNT] = nil,
      [self.I_NEED] = nil
    };
  end
  return bags[bag];
end

function TFuBag:GetPlayerBagCfg(playerid, bag, name)
  return self:GetPlayerBag(playerid, bag)[name];
end

function TFuBag:SetPlayerBagCfg(playerid, bag, name, val)
--  self:Print(playerid..", bag ="..bag..", name ="..name);
  self:GetPlayerBag(playerid, bag)[name] = val;
end

function TFuBag:IsReagentBankUnlocked(playerid)
  if (playerid == self.PLAYERID) then
    return IsReagentBankUnlocked(playerid)
  else
    local size = self:GetPlayerBagCfg(playerid, REAGENTBANK_CONTAINER, self.I_BAGSIZE);
    return size and size > 0
  end
end

function TFuBag:SplitStr(strtosplit,splitchar)
  if (strtosplit) then
    local str1 = strtosplit;
    local str2 = "";
    local idx = strfind(strtosplit, splitchar, 1, true);

    if ( idx ) then
      str1 = strsub(strtosplit, 1, idx-1);
      str2 = strsub(strtosplit, idx+1);
    end

    return str1, str2;
  else
    return "", "";
  end
end

function TFuBag:ClearItmCache(itmcache, bagarr)
  local bag;

  for _, bag in pairs(bagarr) do
    itmcache[bag] = itmcache[bag] or {};
    local bagtab = itmcache[bag];
    for slot,slottab in pairs(itmcache[bag]) do
      if type(slottab) == "table" then
        for k,_ in pairs(slottab) do
          slottab[k] = nil;
        end
      else
        -- Isn't a table so just nil it.  Some of the itmcache's
        -- just store a single value for a slot.
        bagtab[slot] = nil;
      end
    end
  end

  return itmcache;
end

function TFuBag:CreateDummyBag(bag, template)
  local dbag = _G[self:GetDummyBagFrameName(bag)];

  if (dbag) then
    local buttonname;
    local level = dbag:GetFrameLevel() + 1

    for slot = 1, self:GetBagMaxItems(bag) do
      buttonname = self:GetBagItemButtonName(bag, slot);
      if not (_G[buttonname]) then
        -- 12.0: TFuBag_ItemButtonTemplate is the ItemButton intrinsic, so the
        -- frame must be created as type "ItemButton" (not "Button") for the
        -- ItemButtonMixin + icon/Count/Stock children to apply.
        local button = CreateFrame("ItemButton", buttonname, dbag, template);
        button:SetID(slot);
        button:Hide();
        button:SetFrameLevel(level)
      end
    end
  end
end

function TFuBag:CreateFrame(type, name, parent, template, num, append)
  local idx;
  local level = parent:GetFrameLevel() + 1
  if (num) then
    for idx = 1, num do
      local full_name = name..idx..append
      local frame = _G[full_name]
      if not (frame) then
        frame = CreateFrame(type, full_name, parent, template);
      end
      frame:SetID(idx)
      frame:SetFrameLevel(level)
    end
  else
    local frame = _G[name]
    if not (name) then
      frame = CreateFrame(type, name, parent, template);
    end
    frame:SetFrameLevel(level)
  end
end

function TFuBag:ResetNew(itm)
  if (itm) then
    itm[self.I_TIMESTAMP] = 1;
    itm[self.I_NEWSTR] = self.V_NEWOFF;
  end
end

function TFuBag:GetItemInfo(itemid)
  if itemid then
    if tostring(itemid):sub(1,10) ~= "battlepet:" then
      local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, iconFileDataID, sellPrice, classID, subclassID, bindType, expacID = GetItemInfo(itemid);
      -- bindType / expacID appended for the item filter; existing callers that
      -- capture only the first six returns are unaffected.
      return itemName, itemType, itemSubType, itemRarity, itemLink, itemStackCount, bindType, expacID;
    else
      local _,species,_,quality = strsplit(":", itemid)
      local itemName = C_PetJournal.GetPetInfoBySpeciesID(species)
      return itemName, "Miscellaneous", "Companion Pets", quality, itemid, 1, nil, nil
    end
  else
    return;
  end
end

function TFuBag:GetItemID(itemlink)
  if itemlink and type(itemlink) == "string" then
    local a,b,c,d,e,f,g,h,i,j =
          itemlink:match("item:(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):(%-?%d*):(%-?%d*):?(%d*):?([^|]*)")
    if a then
      local itemstring = string.join(":","item",a,b,c,d,e,f,g,h)
      return a, itemstring, j
    end
    a,b,c,d,e,f,g =
          itemlink:match("battlepet:(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)")
    if a then
      local itemstring = string.join(":","battlepet",a,b,c,d,e,f,g)
      return -1, itemstring, nil, a
    end
  end

  return "", ""
end

function TFuBag:GetItemName(itemlink)
  if itemlink and type(itemlink) == "string" then
    local name = itemlink:match("|h%[([^%]]+)%]|h")
    return name
  end
  return ""
end

function TFuBag:CleanConfig()
  TFuBagCfg["Body"] = nil;
  TFuBagCfg["TFuInv_RegisterHooks"] = nil;
  TFuBagCfg["Inv"]["show_top_gfx"] = nil;
  TFuBagCfg["Inv"]["show_blizzard_frames"] = nil;
  TFuBagCfg["Inv"]["show_top_graphics"] = nil;
  TFuBagCfg["Bnk"]["show_top_gfx"] = nil;
  TFuBagCfg["Bnk"]["show_top_graphics"] = nil;
  TFuBagCfg["Bnk"]["show_blizzard_frames"] = nil;
  TFuBagCfg[TFuBag.S_SKILLS] = nil;
  TFuBagCfg[TFuBag.S_TRADES] = nil;
  TFuBagCfg[TFuBag.S_SECOND] = nil;
  for player,_ in pairs(TFuBagInfo) do
    TFuBagInfo[player]["spell"] = nil;
    TFuBagInfo[player]["combat"] = nil;
    TFuBagInfo[player]["xp"] = nil;
    TFuBagInfo[player]["resist"] = nil;
    TFuBagInfo[player]["range"] = nil;
    TFuBagInfo[player]["melee"] = nil;
    TFuBagInfo[player]["stat"] = nil;
    TFuBagInfo[player]["pvp"] = nil;
  end
end

function TFuBag:BagSlotToString(bag,slot)
  return bag..":"..slot
end

function TFuBag:StringToBagSlot(string)
  local bag,slot = strsplit(':',string)
  return tonumber(bag),tonumber(slot)
end

function TFuBag:EscapeNL(str)
  str = string.gsub(str, "\n", "\\n");
  return str
end

function TFuBag:UnEscapeNL(str)
  str = string.gsub(str, "\\n", "\n");
  return str
end

-- Helper function to put an item in the generic bank bags
-- since Blizzard doesn't provide this.
local function PutItemInBank(reagent)
  local bag = reagent and REAGENTBANK_CONTAINER or BANK_CONTAINER
  local texture, emptyBankSlot
  for slot=1, GetContainerNumSlots(bag) do
    texture = GetContainerItemInfo(bag, slot)
    if not texture then
      emptyBankSlot = slot
      break
    end
  end
  if emptyBankSlot then
    PickupContainerItem(bag, emptyBankSlot)
  else
    ClearCursor()
    UIErrorsFrame:AddMessage(ERR_BAG_FULL, 1.0, 0.1, 0.1, 1.0)
  end
end

function TFuBag:PutItemInBag(bag)
  if not CursorHasItem() then return end
  if bag == BACKPACK_CONTAINER then
    return PutItemInBackpack()
  elseif bag == BANK_CONTAINER then
    return PutItemInBank()
  elseif bag == REAGENTBANK_CONTAINER then
    return PutItemInBank(true)
  else
    return PutItemInBag(ContainerIDToInventoryID(bag))
  end
end

function TFuBag:IsLive(frame)
  if frame.playerid ~= self.PLAYERID then
    return false
  end
  if frame.atbank and frame.atbank ~= 1 then
    return false
  end

  return true
end

-----------------------------------------------------------------------
-- Searching
-----------------------------------------------------------------------

TFuBag.SrchText = nil;
local SrchResults = {};
local SC_NONE   = "|cffff1111";
local SC_PLAYER = "|cff11ccee";
local SC_TOTAL  = "|cffeeff11";
local SC_WHITE  = "|cffffffff";

function TFuBag:PlacePrep(playername,place)
  if (place == "body") then
    return string.format(" on %s's %s",playername,place);
  elseif (place == "container") then
    return string.format(" as %s's %s",playername,place);
  else
    return string.format(" in %s's %s",playername,place);
  end
end

function TFuBag:AddSearchResult(itm, playername, place, playerid)
  -- Strip the unique id
  local itemstring = string.gsub(itm[self.I_ITEMLINK],
    "(item:%d+:%d+:%d+:%d+:%d+:%d+:%-?%d+):%-?%d+","%1:0",1);
  local count = itm[self.I_COUNT];
  local level = UnitLevel("player")
  if itm[self.I_ACCTBOUND] then
    level = TFuBag:GetPlayerInfo(playerid,TFuBag.G_BASIC)[TFuBag.S_LEVEL]
  end
  local itemlink = self:MakeHyperlink(itemstring,itm[self.I_NAME],itm[self.I_RARITY],level,itm[self.I_LINKSUFFIX]);

  if (itemlink) then
    self:PrintDEBUG("TFuBag:AddSearchResult "..count.." "..itemlink
      ..self:PlacePrep(playername,place));

    -- First see if this result has been added before
    if (SrchResults[itemlink] == nil) then
      SrchResults[itemlink] = {};
    end
    if (SrchResults[itemlink][playername] == nil) then
      SrchResults[itemlink][playername] = {};
    end
    if (SrchResults[itemlink][playername][place] == nil) then
      SrchResults[itemlink][playername][place] = count;
    else
      SrchResults[itemlink][playername][place] = SrchResults[itemlink][playername][place] + count;
    end
  end
end

function TFuBag:GatherSearchResults(itmcache, place)
  local playername, realm

  for playerid, bagarr in pairs(itmcache) do
    playername, realm = strsplit("|", playerid)

    -- Only include results from this realm
    if (realm == self.REALM) then
      self:PrintDEBUG("TFuBag:GatherSearchResults for "..playername.."'s "..place);
      for _, slotarr in pairs(bagarr) do
        for _, itm in pairs(slotarr) do
          -- Exclude empty slots
          if (itm[self.I_ITEMLINK]) and (itm[self.I_NAME]) then
            -- Do case insensitive searches
            if (string.find(string.lower(itm[self.I_NAME]), self.SrchText)) then
              self:AddSearchResult(itm, playername, place, playerid);
            end
          end
        end
      end
    end
  end
end

function TFuBag:JustifyStr(str, width, color)
  local length = strlen(tostring(str));
  local result = "";
  while (length < width) do
    result = result.."  ";
    length = length + 1;
  end
  return result..color..str.."|r";
end

function TFuBag:DisplaySearchResult(aResult, itemlink)
  local chatframe = DEFAULT_CHAT_FRAME;
  local total = 0;
  local lines = 0;

  -- Do a quick alphabetic sort
  table.sort(aResult);

  -- First tally up the total across all players
  for playername, places in pairs(aResult) do
    for place, count in pairs(places) do
      total = total + count;
      lines = lines + 1;
    end
  end

  -- Write out a short summary total if we have multiple lines
  if (lines > 1) then
    chatframe:AddMessage(self:JustifyStr(total, 3, SC_TOTAL).." "..itemlink..L[" found:"], .7, .7, .7);
  end

  -- Then write out a line for each of the place results
  for playername, places in pairs(aResult) do
    for place, count in pairs(places) do
      if (lines == 1) then
        chatframe:AddMessage(self:JustifyStr(count, 3, SC_TOTAL).." "..itemlink..self:PlacePrep(SC_PLAYER..playername.."|r",place), .7, .7, .7);
      elseif (lines > 1) then
        chatframe:AddMessage(self:JustifyStr(count, 6, SC_WHITE)..self:PlacePrep(SC_PLAYER..playername.."|r",place), .7, .7, .7);
      end
    end
  end
end

function TFuBag:DoSearch(srch)
  SrchResults = {};

  if (srch) then
    local found;

    self.SrchText = string.lower(srch);
    -- Treat the search box text as a literal substring, not a Lua pattern:
    -- escape magic chars so e.g. "void-t" matches "Void-Touched" instead of being
    -- read as the pattern "d-t" (- is a quantifier, so "void-" matched only "voi"
    -- and any following letter then failed). SrchText is consumed by string.find /
    -- string.match in GatherSearchResults and the item-highlight alpha pass.
    self.SrchText = self.SrchText:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1");

    -- Gather all the search info
    self:GatherSearchResults(TFuInvItm, L["bags"]);
    self:GatherSearchResults(TFuBnkItm, L["bank"]);
    self:GatherSearchResults(TFuContItm, L["container"]);
    self:GatherSearchResults(TFuBodyItm, L["body"]);
    self:GatherSearchResults(TFuMailItm, L["mail"]);
    self:GatherSearchResults(TFuTknItm, L["tokens"]);

    -- Sort it alphabetically
    table.sort(SrchResults);
    for _, playerarr in pairs(SrchResults) do
      table.sort(playerarr);
    end

    -- Display all the search results
    for itemlink, aResult in pairs(SrchResults) do
      if (not found) then
        DEFAULT_CHAT_FRAME:AddMessage(self.SCP..string.format(L["Search results for %q:"],srch), 1, 1, 1);
      end
      self:DisplaySearchResult(aResult, itemlink);
      found = 1;
    end

    -- If there's no results, say so
    if (not found) then
      DEFAULT_CHAT_FRAME:AddMessage(self.SCP..SC_NONE..string.format(L["No results|r for %q"],srch));
    end

    TFuInvFrame:UpdateWindow();
    TFuBnkFrame:UpdateWindow();
  end
end

function TFuBag:ClearSearch()
  if (self.SrchText) then
    self.SrchText = nil;
    TFuInvFrame:UpdateWindow();
    TFuBnkFrame:UpdateWindow();
  end
  TFuInv_SearchBox:SetText(SEARCH);
  TFuBnk_SearchBox:SetText(SEARCH);
end

-----------------------------------------------------------------------
-- Item filter (Blizzard-style: hide non-matching items, reflow the rest)
-----------------------------------------------------------------------
-- Unlike the search box (which only DIMS non-matches), the filter hides them
-- completely: SortItmCache skips placing a non-matching item into a bar, so
-- LayoutWindow reflows the survivors with no gaps. State is per-window and held
-- in memory only (resets on /reload, same as the search box).
--
-- Rarity / item-type test cached item fields, so they work for cross-character
-- (cached) views. "Usable Only" / "Current Expansion Only" use live APIs that
-- only know the logged-in character, and an item not yet in the client cache has
-- no expansion info -- both degrade to "do not hide" rather than wrongly hiding.

-- Profession -> trade-goods material subtype(s), from the in-game taxonomy dump
-- (12.0 / enUS localized subtype strings, matched against itm[I_SUBTYPE]). Shared
-- by the Profession filter and (later) the per-material category uplift. Professions
-- that share a material family overlap by design (Mining & Blacksmithing -> Metal &
-- Stone; Herbalism & Alchemy -> Herb; Skinning & Leatherworking -> Leather).
TFuBag.PROFESSION_SUBTYPES = {
  Alchemy        = { "Herb", "Elemental" },
  Blacksmithing  = { "Metal & Stone" },
  Cooking        = { "Cooking" },
  Enchanting     = { "Enchanting" },
  Engineering    = { "Parts", "Metal & Stone" },
  Herbalism      = { "Herb" },
  Inscription    = { "Inscription" },
  Jewelcrafting  = { "Jewelcrafting" },
  Leatherworking = { "Leather" },
  Mining         = { "Metal & Stone" },
  Skinning       = { "Leather" },
  Tailoring      = { "Cloth" },
};
-- Menu order for the Profession filter submenu.
TFuBag.FILTER_PROFESSIONS = {
  "Alchemy", "Blacksmithing", "Cooking", "Enchanting", "Engineering", "Herbalism",
  "Inscription", "Jewelcrafting", "Leatherworking", "Mining", "Skinning", "Tailoring",
};

-----------------------------------------------------------------------
-- Material grouping (Categories panel). Each trade-goods subtype routes to a
-- group CATEGORY (cfg.mat_group[subtype]); pointing several subtypes at the same
-- category merges them onto one bar. sub = the game subtype string (matched
-- against I_SUBTYPE); cat = the default per-material category. Order = menu order.
-----------------------------------------------------------------------
TFuBag.MATERIAL_SUBTYPES = {
  { sub = "Herb",              cat = "Herbs" },
  { sub = "Metal & Stone",     cat = "Ore & Stone" },
  { sub = "Cloth",             cat = "CLOTH" },
  { sub = "Leather",           cat = "Leather" },
  { sub = "Cooking",           cat = "Cooking Mats" },
  { sub = "Enchanting",        cat = "Enchanting Mats" },
  { sub = "Inscription",       cat = "Inscription Mats" },
  { sub = "Jewelcrafting",     cat = "Jewelcrafting Mats" },
  { sub = "Elemental",         cat = "Elemental" },
  { sub = "Parts",             cat = "Engineering Parts" },
  { sub = "Optional Reagents", cat = "Optional Reagents" },
  { sub = "Finishing Reagents",cat = "Finishing Reagents" },
};

-- Read the current group target for a subtype (from the inventory cfg).
function TFuBag:GetMaterialGroup(subtype)
  local cfg = TFuInvFrame and TFuInvFrame.cfg;
  return cfg and cfg.mat_group and cfg.mat_group[subtype];
end

-- Route a subtype to a target group category in BOTH windows. defer = skip the
-- (heavy) recat+relayout so a preset can batch many changes into one refresh.
function TFuBag:SetMaterialGroup(subtype, target, defer)
  for _, frame in ipairs({ TFuInvFrame, TFuBnkFrame }) do
    if (frame and frame.cfg) then
      frame.cfg.mat_group = frame.cfg.mat_group or {};
      frame.cfg.mat_group[subtype] = target;
    end
  end
  if (not defer) then
    self:BumpCatGen();
    if (TFuInvFrame) then TFuInvFrame:UpdateWindow(self.REQ_MUST); end
    if (TFuBnkFrame) then TFuBnkFrame:UpdateWindow(self.REQ_MUST); end
  end
end

-- Apply a grouping preset: "separate" = each subtype to its own category;
-- "onebar" = all subtypes into the single Trade Goods category.
function TFuBag:ApplyGroupPreset(preset)
  for _, m in ipairs(self.MATERIAL_SUBTYPES) do
    local target = (preset == "onebar") and self.LOCALE["TRADE_GOODS"] or m.cat;
    self:SetMaterialGroup(m.sub, target, true);
  end
  self:BumpCatGen();
  if (TFuInvFrame) then TFuInvFrame:UpdateWindow(self.REQ_MUST); end
  if (TFuBnkFrame) then TFuBnkFrame:UpdateWindow(self.REQ_MUST); end
end

-- ===== Category enable/disable (Categories options panel) =====
-- item_search_list is a flat list of MATCH RULES; each row is
-- {name, keyword, tooltip, type, subtype, [special]} with an optional .off flag.
-- Many rows share one user-facing category name (rule[1]). PickBar skips rows with
-- .off set (TBag.lua), so disabling a category = setting .off on all of its rules; its
-- items then fall through to the normal type/subtype categorization (or UNKNOWN).

-- Distinct category names in first-occurrence order, each with its current enabled
-- state. enabled = at least one of the category's rules is active (.off unset). Reads
-- the inventory list (both windows are kept in sync by SetCategoryEnabled); falls back
-- to the bank list when the inventory window is not initialised yet.
function TFuBag:GetCategoryList()
  local cfg = (TFuInvFrame and TFuInvFrame.cfg) or (TFuBnkFrame and TFuBnkFrame.cfg);
  local list = cfg and cfg["item_search_list"];
  local out, seen = {}, {};
  if (not list) then return out; end
  for _, rule in ipairs(list) do
    local name = rule[1];
    if (name and name ~= "") then
      local e = seen[name];
      if (not e) then
        e = { name = name, enabled = false };
        seen[name] = e;
        out[#out + 1] = e;
      end
      if (not rule.off) then e.enabled = true; end
    end
  end
  return out;
end

function TFuBag:IsCategoryEnabled(name)
  local cfg = (TFuInvFrame and TFuInvFrame.cfg) or (TFuBnkFrame and TFuBnkFrame.cfg);
  local list = cfg and cfg["item_search_list"];
  if (not list) then return true; end
  for _, rule in ipairs(list) do
    if (rule[1] == name and not rule.off) then return true; end
  end
  return false;
end

-- Enable/disable an entire category: set .off (true / nil) on every rule whose name
-- matches, in BOTH windows' rule lists (kept in sync like mat_group). The .off key
-- persists in SavedVariables (only /reset's ResetSorts copy drops it). Triggers a
-- recat + relayout unless deferred.
function TFuBag:SetCategoryEnabled(name, enabled, defer)
  local off = (not enabled) or nil;
  for _, frame in ipairs({ TFuInvFrame, TFuBnkFrame }) do
    local list = frame and frame.cfg and frame.cfg["item_search_list"];
    if (list) then
      for _, rule in ipairs(list) do
        if (rule[1] == name) then rule.off = off; end
      end
    end
  end
  if (not defer) then
    self:BumpCatGen();
    if (TFuInvFrame) then TFuInvFrame:UpdateWindow(self.REQ_MUST); end
    if (TFuBnkFrame) then TFuBnkFrame:UpdateWindow(self.REQ_MUST); end
  end
end

function TFuBag:GetItemFilter(frame)
  if (not frame.itemFilter) then
    frame.itemFilter = {
      rarity = {},      -- keyed by quality number
      itype = {},       -- keyed by localized item type
      isubtype = {},    -- keyed by localized item subtype
      expansion = {},   -- keyed by expansionID
      profession = {},  -- keyed by English profession name (matched via PROFESSION_SUBTYPES)
      bound = {},       -- keyed by "soulbound" / "warbound" / "boe"
      usable = false,
      curExp = false,
      active = false,
    };
  end
  return frame.itemFilter;
end

-- True when at least one filter dimension is set. Cached on f.active so the
-- per-item PassesItemFilter hot path can early-out with a single boolean read.
function TFuBag:ItemFilterActive(f)
  if (not f) then return false; end
  return (next(f.rarity) ~= nil) or (next(f.itype) ~= nil)
    or (next(f.isubtype) ~= nil) or (next(f.expansion) ~= nil)
    or (next(f.profession) ~= nil) or (next(f.bound) ~= nil)
    or f.usable or f.curExp;
end

function TFuBag:PassesItemFilter(frame, itm)
  local f = frame and frame.itemFilter;
  if (not f or not f.active) then return true; end   -- no active filter: show everything

  local link = itm[self.I_ITEMLINK];
  -- An active filter shows only matching ITEMS, so empty slots are always hidden.
  if (not link or link == "") then return false; end

  if (next(f.rarity) ~= nil) then
    local q = itm[self.I_RARITY];
    if (q == nil or not f.rarity[q]) then return false; end
  end

  if (next(f.itype) ~= nil) then
    local t = itm[self.I_TYPE];
    if (t == nil or not f.itype[t]) then return false; end
  end

  if (next(f.isubtype) ~= nil) then
    local st = itm[self.I_SUBTYPE];
    if (st == nil or not f.isubtype[st]) then return false; end
  end

  if (next(f.expansion) ~= nil) then
    local xp = itm[self.I_EXPANSION];
    -- nil = unknown (item not cached with expansion yet, e.g. an alt last scanned
    -- under an older build): leave it visible rather than wrongly hiding it.
    if (xp ~= nil and not f.expansion[xp]) then return false; end
  end

  if (next(f.profession) ~= nil) then
    -- Match the item's material subtype against the selected professions' families,
    -- but ONLY for crafting materials (trade goods). Some subtype strings ("Cloth",
    -- "Leather") are shared with Armor, so without the type guard cloth/leather
    -- armor (incl. BoE) would wrongly match Tailoring/Leatherworking.
    local st = itm[self.I_SUBTYPE];
    local hit = false;
    if (st and itm[self.I_TYPE] == self.LOCALE["Tradeskill"]) then
      for trade in pairs(f.profession) do
        local subs = self.PROFESSION_SUBTYPES[trade];
        if (subs) then
          for _, s in ipairs(subs) do
            if (st == s) then hit = true; break; end
          end
        end
        if (hit) then break; end
      end
    end
    if (not hit) then return false; end
  end

  if (next(f.bound) ~= nil) then
    local hit = false;
    if (f.bound.soulbound and itm[self.I_SOULBOUND] == 1) then hit = true; end
    if (f.bound.warbound and itm[self.I_ACCTBOUND]) then hit = true; end
    if (f.bound.boe and itm[self.I_BINDTYPE] == 2) then hit = true; end  -- 2 = Bind on Equip
    if (not hit) then return false; end
  end

  if (f.usable) then
    -- C_Item.IsUsableItem (returns usable, noMana) can only judge an item whose data
    -- is loaded client-side. Inventory items are always loaded; BANK items often are
    -- not (a remote/cached bank view, or freshly-opened tabs), and IsUsableItem then
    -- returns falsy -- which previously hid usable items (e.g. food) in the bank.
    -- Only hide when the item is LOADED and positively not usable; treat unknown
    -- (uncached) as "do not hide", same as the Expansion / Current-Expansion checks.
    local iid = link and link:match("^item:(%d+)");
    iid = iid and tonumber(iid);
    if (iid and GetItemInfo(iid) and not C_Item.IsUsableItem(iid)) then
      return false;
    end
  end

  if (f.curExp) then
    -- 15th return of GetItemInfo = expansionID; nil when the item is not yet in
    -- the client cache -- treat unknown as "do not hide".
    local exp = select(15, GetItemInfo(link));
    if (exp ~= nil and exp ~= LE_EXPANSION_LEVEL_CURRENT) then return false; end
  end

  return true;
end

-- Called whenever a filter checkbox toggles: recompute the active flag, then ask
-- the window to rebuild its item placement and relayout WITHOUT a full category
-- rescan (force_resort, handled in Inv/Bank:UpdateWindow).
function TFuBag:OnFilterChanged(frame)
  local f = self:GetItemFilter(frame);
  f.active = self:ItemFilterActive(f);
  frame.force_resort = true;
  if (frame.UpdateFilterButton) then frame:UpdateFilterButton(); end
  frame:UpdateWindow();
end

-- The set of item classes offered in the "Item Type" submenu is built from the
-- types actually present in the view (so labels exactly match the stored
-- I_TYPE string and no empty categories are listed). Returns a sorted array.
-- Distinct values of a cached item field (I_TYPE / I_SUBTYPE) present in the
-- view, sorted. Used to build the Item Type / Item Subtype submenus from what is
-- actually in the bags so labels exactly match the stored string (no empty rows).
function TFuBag:CollectItemField(frame, field)
  local cache = (frame == TFuBnkFrame) and TFuBnkItm or TFuInvItm;
  local pcache = frame.playerid and cache and cache[frame.playerid];
  local seen, names = {}, {};
  if (pcache and frame.bags) then
    for _, bag in ipairs(frame.bags) do
      local b = pcache[bag];
      if (b) then
        for _, slot in pairs(b) do
          local t = slot[field];
          if (t and t ~= "" and not seen[t]) then
            seen[t] = true;
            names[#names + 1] = t;
          end
        end
      end
    end
  end
  table.sort(names);
  return names;
end

function TFuBag:CollectItemTypes(frame)
  return self:CollectItemField(frame, self.I_TYPE);
end

function TFuBag:CollectItemSubtypes(frame)
  return self:CollectItemField(frame, self.I_SUBTYPE);
end

-- Populate a Blizzard menu (rootDescription from MenuUtil.CreateContextMenu) with
-- the filter controls. Mirrors the auction-house filter layout: titles + checkboxes.
function TFuBag:BuildFilterMenu(frame, rootDescription)
  local f = self:GetItemFilter(frame);
  local L = self.LOCALE;

  -- Toggle a key in a filter set (e.g. f.rarity[q]) from a checkbox, then refresh.
  local function setCheckbox(parent, label, set, key)
    parent:CreateCheckbox(label,
      function() return set[key] == true; end,
      function()
        if (set[key]) then set[key] = nil; else set[key] = true; end
        self:OnFilterChanged(frame);
      end);
  end

  -- Submenu that lists checkboxes from a sorted array of values (matched by the
  -- value itself), with a disabled "(none)" row when the view has none of them.
  local function valueSubmenu(titleKey, values, set)
    local sub = rootDescription:CreateButton(titleKey);
    if (#values == 0) then
      sub:CreateButton(L["(none)"]):SetEnabled(false);
    else
      for _, v in ipairs(values) do setCheckbox(sub, v, set, v); end
    end
    return sub;
  end

  rootDescription:CreateTitle(L["Filter Items"]);

  rootDescription:CreateButton(L["Clear All Filters"], function()
    wipe(f.rarity); wipe(f.itype); wipe(f.isubtype);
    wipe(f.expansion); wipe(f.profession); wipe(f.bound);
    f.usable = false;
    f.curExp = false;
    self:OnFilterChanged(frame);
  end);

  rootDescription:CreateCheckbox(L["Usable Only"],
    function() return f.usable; end,
    function() f.usable = not f.usable; self:OnFilterChanged(frame); end);

  rootDescription:CreateCheckbox(L["Current Expansion Only"],
    function() return f.curExp; end,
    function() f.curExp = not f.curExp; self:OnFilterChanged(frame); end);

  -- Rarity submenu (Poor .. Heirloom), each label tinted with its quality color.
  local rarity = rootDescription:CreateButton(L["Rarity"]);
  for q = Enum.ItemQuality.Poor, Enum.ItemQuality.Heirloom do
    local name = _G["ITEM_QUALITY"..q.."_DESC"];
    if (name) then
      local col = ITEM_QUALITY_COLORS[q];
      setCheckbox(rarity, (col and col.hex or "")..name.."|r", f.rarity, q);
    end
  end

  -- Item Type / Item Subtype submenus, built from values present in this view.
  valueSubmenu(L["Item Type"], self:CollectItemTypes(frame), f.itype);
  valueSubmenu(L["Item Subtype"], self:CollectItemSubtypes(frame), f.isubtype);

  -- Expansion submenu (Classic .. current), matched on the item's expansionID.
  local expSub = rootDescription:CreateButton(L["Expansion"]);
  local maxExp = LE_EXPANSION_LEVEL_CURRENT or GetExpansionLevel() or 0;
  for i = 0, maxExp do
    local name = _G["EXPANSION_NAME"..i];
    if (name) then setCheckbox(expSub, name, f.expansion, i); end
  end

  -- Profession submenu: matches an item's material subtype against the profession's
  -- family (PROFESSION_SUBTYPES), e.g. Herbalism -> Herb, Mining -> Metal & Stone.
  local profSub = rootDescription:CreateButton(L["Profession"]);
  for _, trade in ipairs(self.FILTER_PROFESSIONS) do
    setCheckbox(profSub, L[trade], f.profession, trade);
  end

  -- Bound status.
  local boundSub = rootDescription:CreateButton(L["Bound"]);
  setCheckbox(boundSub, L["Soulbound"], f.bound, "soulbound");
  setCheckbox(boundSub, L["Account Bound"], f.bound, "warbound");
  setCheckbox(boundSub, L["Bind on Equip"], f.bound, "boe");

  -- User-defined saved filters (account-wide, TFuBagCfg.user_filters). Clicking a
  -- saved entry loads its spec as the active filter; "Save current filter as..."
  -- snapshots the current selection (name-entry popup); "Delete saved filter" removes one.
  local saved = self:GetUserFilters();
  local userSub = rootDescription:CreateButton(L["User Filters"]);
  if (#saved == 0) then
    userSub:CreateButton(L["(none saved)"]):SetEnabled(false);
  else
    for _, entry in ipairs(saved) do
      local e = entry;
      userSub:CreateButton(e.name, function() self:ApplyUserFilter(frame, e); end);
    end
  end
  userSub:CreateDivider();
  userSub:CreateButton(L["Save current filter as..."], function()
    StaticPopup_Show("TBAG_SAVE_FILTER", nil, nil, frame);
  end);
  if (#saved > 0) then
    local del = userSub:CreateButton(L["Delete saved filter"]);
    for _, entry in ipairs(saved) do
      local e = entry;
      del:CreateButton(e.name, function() self:DeleteUserFilter(e.name); end);
    end
  end
end

-- Shared OnClick for a window's filter button: opens the menu anchored to it.
function TFuBag:OpenFilterMenu(frame, button)
  MenuUtil.CreateContextMenu(button, function(owner, rootDescription)
    TFuBag:BuildFilterMenu(frame, rootDescription);
  end);
end

-----------------------------------------------------------------------
-- User-defined saved filters (account-wide, in TFuBagCfg.user_filters)
-----------------------------------------------------------------------
-- A saved filter is a named snapshot of the live filter spec. Stored in TFuBagCfg
-- so the same named filters are available on every character and in both windows.

-- Deep-copy a filter spec (sets are copied so a saved filter can't be mutated by
-- later edits to the live filter, and vice versa).
function TFuBag:CopyFilterSpec(src)
  local function copyset(s)
    local t = {};
    if (s) then for k, v in pairs(s) do t[k] = v; end end
    return t;
  end
  return {
    rarity     = copyset(src.rarity),
    itype      = copyset(src.itype),
    isubtype   = copyset(src.isubtype),
    expansion  = copyset(src.expansion),
    profession = copyset(src.profession),
    bound      = copyset(src.bound),
    usable     = src.usable and true or false,
    curExp     = src.curExp and true or false,
  };
end

function TFuBag:GetUserFilters()
  if (not TFuBagCfg) then return {}; end
  TFuBagCfg.user_filters = TFuBagCfg.user_filters or {};
  return TFuBagCfg.user_filters;
end

-- Snapshot the window's current filter selection under a name (overwrites an
-- existing entry with the same name). Kept sorted by name for a stable menu.
function TFuBag:SaveCurrentFilter(frame, name)
  if (not name) then return; end
  name = strtrim(name);
  if (name == "") then return; end
  local spec = self:CopyFilterSpec(self:GetItemFilter(frame));
  local list = self:GetUserFilters();
  for _, e in ipairs(list) do
    if (e.name == name) then e.spec = spec; return; end
  end
  list[#list + 1] = { name = name, spec = spec };
  table.sort(list, function(a, b) return a.name < b.name; end);
end

function TFuBag:UserFilterExists(name)
  for _, e in ipairs(self:GetUserFilters()) do
    if (e.name == name) then return true; end
  end
  return false;
end

-- Save entry point used by the menu: confirm before overwriting an existing
-- same-named filter; otherwise save directly.
function TFuBag:SaveCurrentFilterPrompt(frame, name)
  if (not name) then return; end
  name = strtrim(name);
  if (name == "") then return; end
  if (self:UserFilterExists(name)) then
    StaticPopup_Show("TBAG_CONFIRM_OVERWRITE_FILTER", name, nil, { frame = frame, name = name });
  else
    self:SaveCurrentFilter(frame, name);
  end
end

-- Load a saved filter's spec as the window's active filter, then reflow.
function TFuBag:ApplyUserFilter(frame, entry)
  if (not entry or not entry.spec) then return; end
  local f = self:GetItemFilter(frame);
  local c = self:CopyFilterSpec(entry.spec);
  f.rarity, f.itype, f.isubtype = c.rarity, c.itype, c.isubtype;
  f.expansion, f.profession, f.bound = c.expansion, c.profession, c.bound;
  f.usable, f.curExp = c.usable, c.curExp;
  self:OnFilterChanged(frame);
end

function TFuBag:DeleteUserFilter(name)
  local list = self:GetUserFilters();
  for i, e in ipairs(list) do
    if (e.name == name) then table.remove(list, i); return; end
  end
end

-- Name-entry popup for "Save current filter as...". data = the window frame.
StaticPopupDialogs["TBAG_SAVE_FILTER"] = {
  text = TFuBag.LOCALE["Name this filter:"],
  button1 = SAVE,
  button2 = CANCEL,
  hasEditBox = true,
  maxLetters = 32,
  OnAccept = function(dialog, data)
    local eb = dialog.GetEditBox and dialog:GetEditBox();
    TFuBag:SaveCurrentFilterPrompt(data, eb and eb:GetText() or "");
  end,
  EditBoxOnEnterPressed = function(editBox, data)
    editBox:GetParent():Hide();
    TFuBag:SaveCurrentFilterPrompt(data, editBox:GetText());
  end,
  EditBoxOnEscapePressed = function(editBox)
    editBox:GetParent():Hide();
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
};

-- Confirm before overwriting an existing same-named saved filter.
-- data = { frame = <window>, name = <filter name> }.
StaticPopupDialogs["TBAG_CONFIRM_OVERWRITE_FILTER"] = {
  text = TFuBag.LOCALE["A filter named \"%s\" already exists. Overwrite it?"],
  button1 = YES,
  button2 = NO,
  OnAccept = function(dialog, data)
    if (data) then TFuBag:SaveCurrentFilter(data.frame, data.name); end
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
};

-- Trim the dark 1-2px border baked into every Interface\Icons\ texture, so the
-- 20x20 title-bar icon buttons show a clean icon to their edges instead of a hard
-- inner border ("edge issues around the icon"). Idempotent (cached on the button)
-- and applied to Normal/Pushed/Highlight so the look stays consistent on press/hover.
function TFuBag:TrimButtonIcon(button)
  if (not button or button.iconTrimmed) then return; end
  button.iconTrimmed = true;
  local function trim(tex)
    if (tex) then tex:SetTexCoord(0.07, 0.93, 0.07, 0.93); end
  end
  trim(button:GetNormalTexture());
  trim(button:GetPushedTexture());
  trim(button:GetHighlightTexture());
end

-----------------------------------------------------------------------
-- Configuration
-----------------------------------------------------------------------

function TFuBag:SetDef(cfg, var, defval, reset, cleanfunc, param1, param2)
  if (reset == nil) then
    reset = 1;
  end

  if (cleanfunc ~= nil) then
    cfg[var] = cleanfunc(cfg[var], param1, param2);
  end

  if (cfg[var] == nil) then
    cfg[var] = defval;
  elseif (reset == 1) then
    cfg[var] = defval;
  end
end

function TFuBag:SetGrpDef(cfg, grp, var, defval, reset, cleanfunc, param1, param2)
  if (reset == nil) then
    reset = 1;
  end

  if (grp) and (cfg[grp] == nil) then
    cfg[grp] = {};
  end

  if (cleanfunc) then
    cfg[grp][var] = cleanfunc(cfg[grp][var], param1, param2);
  end

  if (cfg[grp][var] == nil) then
    cfg[grp][var] = defval;
  elseif (reset == 1) then
    cfg[grp][var] = defval;
  end
end

function TFuBag:GetGrp(cfg, grp, var)
  if (cfg) and (grp) then
    if (cfg[grp] == nil) then
      cfg[grp] = {};
      return nil;
    end
    return cfg[grp][var];
  end
end

function TFuBag.NumFunc(value, lowest, highest)
  if (value == nil) then return nil; end

  if (type(value) ~= "number") then
    value = tonumber(value);
  end

  if ( (value ~= nil) and (lowest ~= nil) and (value < lowest) ) then
    value = nil;
  end
  if ( (value ~= nil) and (highest ~= nil) and (value > highest) ) then
    value = nil;
  end

  return value;
end

function TFuBag.StrFunc(value, choices_array)
  local found = 0;

  if (value == nil) then
    return nil;
  end

  for key,cvalue in pairs(choices_array) do
    if (value == cvalue) then
      found = 1;
    end
  end

  if (found == 0) then
    return nil;
  else
    return value;
  end
end

function TFuBag:NicePlacement(buttonsize)
  if (buttonsize > 46) then
    return 50, 16, 4, 3, 1.0;
  elseif (buttonsize > 44) then
    return 46, 16, 4, 3, 1.0;
  elseif (buttonsize > 40) then
    return 42, 14, 3, 2, 1.0;
  elseif (buttonsize > 36) then
    return 38, 14, 3, 2, 1.0;
  elseif (buttonsize > 32) then
    return 34, 14, 3, 2, 1.0;
  elseif (buttonsize > 28) then
    return 38, 14, 3, 2, 0.7894737;
  elseif (buttonsize > 24) then
    return 38, 14, 3, 2, 0.6842105;
  else
    return 38, 14, 3, 2, 0.5789474;
  end
end

-- default bar locations for items
function TFuBag:SetDefLayout(cfg, bagarr, row1offset, reset)
  -- wipe the array if we are resetting
  if (reset == 1) and (cfg) then cfg[self.CAT_BAR] = {}; end

-- Eighth default line (top) - Empty and Act Ons
  self:SetCatBar(cfg, L["MISC"], 31, reset);
  self:SetCatBar(cfg, L["UNKNOWN"], 31, reset);

  self:SetCatBar(cfg, L["FIREWORKS"], 30, reset);
  self:SetCatBar(cfg, L["CONSUMABLE"], 30, reset);

  self:SetCatBar(cfg, L["ACT_ON"], 29, reset);
  self:SetCatBar(cfg, L["ACT_OPEN"], 29, reset);
  self:SetCatBar(cfg, L["ACT_SELL"], 29, reset);
  self:SetCatBar(cfg, L["BAG"], 29, reset);
  self:SetCatBar(cfg, L["GRAY_ITEMS"], 29, reset);

  local bag;
  for _, bag in ipairs(bagarr) do
    self:SetCatBar(cfg, string.format(L["EMPTY_%s_SLOTS"],self:GetBagPosName(bag)), 29, reset);
  end

-- Seventh default line - Quests and Factions
  self:SetCatBar(cfg, L["QUEST"], 28, reset);
  self:SetCatBar(cfg, string.format(L["SOULBOUND_%s"],L["OTHER"]), 28, reset);

  self:SetCatBar(cfg, L["FOLLOWERS"], 27, reset);
  self:SetCatBar(cfg, L["TIMBERMAW"], 27, reset);
  self:SetCatBar(cfg, L["KEY_QUEST"], 27, reset);
  self:SetCatBar(cfg, L["CENARION_EXPEDITION"], 27, reset);
  self:SetCatBar(cfg, L["SPOREGGAR"], 27, reset);

  self:SetCatBar(cfg, L["ARCHAEOLOGY"], 26, reset);
  self:SetCatBar(cfg, L["PVP"], 26, reset);

  self:SetCatBar(cfg, L["ENCHANTS"], 25, reset);
  self:SetCatBar(cfg, L["GLYPHS"], 25, reset);
  self:SetCatBar(cfg, L["BOOK"], 25, reset);
  self:SetCatBar(cfg, L["DESIGN"], 25, reset);
  self:SetCatBar(cfg, L["FORMULA"], 25, reset);
  self:SetCatBar(cfg, L["RECIPE"], 25, reset);
  self:SetCatBar(cfg, L["PATTERN"], 25, reset);
  self:SetCatBar(cfg, L["PLANS"], 25, reset);
  self:SetCatBar(cfg, L["SCHEMATIC"], 25, reset);
  self:SetCatBar(cfg, L["BLUEPRINTS"], 25, reset);
  self:SetCatBar(cfg, L["RECIPE_OTHER"], 25, reset);

-- Sixth default line - Collectibles
  self:SetCatBar(cfg, L["ALDOR"], 24, reset);
  self:SetCatBar(cfg, L["SCRYER"], 24, reset);
  self:SetCatBar(cfg, L["LOWER_CITY"], 24, reset);
  self:SetCatBar(cfg, L["ARTIFACTPOWER"], 24, reset);

  self:SetCatBar(cfg, L["AHN_QIRAJ"], 23, reset);
  self:SetCatBar(cfg, L["NETHERWING"], 23, reset);
  self:SetCatBar(cfg, L["ARTIFACTRELIC"], 23, reset);

  self:SetCatBar(cfg, L["BLACKWING_LAIR"], 22, reset);
  self:SetCatBar(cfg, L["DARKMOON_FAIRE"], 22, reset);
  self:SetCatBar(cfg, L["OGRI'LA"], 22, reset);

  self:SetCatBar(cfg, L["MOLTEN_CORE"], 21, reset);
  self:SetCatBar(cfg, L["CONSORTIUM"], 21, reset);
  self:SetCatBar(cfg, L["HALAA"], 21, reset);

-- Fifth default line - To Sell
  self:SetCatBar(cfg, L["REAGENT"], 20, reset);

  -- Trade Goods catch-all on its OWN bar (32), not shared with the vestigial
  -- profession categories below (which kept it visually merged into an "Alchemy"
  -- box). Unclassified "Other"-subtype reagents land here in a clean Trade Goods box.
  self:SetCatBar(cfg, L["TRADE_GOODS"], 32, reset);
  self:SetCatBar(cfg, L["ALCHEMY"], 19, reset);
  self:SetCatBar(cfg, L["BLACKSMITHING"], 19, reset);
  self:SetCatBar(cfg, L["ENCHANTING"], 19, reset);
  self:SetCatBar(cfg, L["ENGINEERING"], 19, reset);
  self:SetCatBar(cfg, L["JEWELCRAFTING"], 19, reset);
  self:SetCatBar(cfg, L["LEATHERWORKING"], 19, reset);
  self:SetCatBar(cfg, L["MINING"], 19, reset);
  self:SetCatBar(cfg, L["TAILORING"], 19, reset);
  self:SetCatBar(cfg, L["INSCRIPTION"], 19, reset);

-- Category uplift: each per-material trade-goods category and each new 12.0 class
-- gets its OWN bar (33-46) so they render as separate boxes instead of merging into
-- one. (A bar is a single box; categories sharing a bar are drawn together with a
-- joined label.) Placed in the high range; rearrange to taste in-game.
  self:SetCatBar(cfg, L["Herbs"], 46, reset);
  self:SetCatBar(cfg, L["Ore & Stone"], 45, reset);
  self:SetCatBar(cfg, L["Leather"], 44, reset);
  self:SetCatBar(cfg, L["Cooking Mats"], 43, reset);
  self:SetCatBar(cfg, L["Enchanting Mats"], 42, reset);
  self:SetCatBar(cfg, L["Inscription Mats"], 41, reset);
  self:SetCatBar(cfg, L["Jewelcrafting Mats"], 40, reset);
  self:SetCatBar(cfg, L["Elemental"], 39, reset);
  self:SetCatBar(cfg, L["Engineering Parts"], 38, reset);
  self:SetCatBar(cfg, L["Optional Reagents"], 37, reset);
  self:SetCatBar(cfg, L["Finishing Reagents"], 36, reset);
  self:SetCatBar(cfg, L["Gems"], 35, reset);
  self:SetCatBar(cfg, L["Housing"], 34, reset);
  self:SetCatBar(cfg, L["Mount Equipment"], 33, reset);

  self:SetCatBar(cfg, L["RING"], 18, reset);
  self:SetCatBar(cfg, L["TRINKET"], 18, reset);

  self:SetCatBar(cfg, L["01_HEAD"], 17, reset);
  self:SetCatBar(cfg, L["02_NECK"], 17, reset);
  self:SetCatBar(cfg, L["03_SHOULDER"], 17, reset);
  self:SetCatBar(cfg, L["04_BACK"], 17, reset);
  self:SetCatBar(cfg, L["05_CHEST"], 17, reset);
  self:SetCatBar(cfg, L["06_SHIRT"], 17, reset);
  self:SetCatBar(cfg, L["07_TABARD"], 17, reset);
  self:SetCatBar(cfg, L["08_WRIST"], 17, reset);
  self:SetCatBar(cfg, L["09_HANDS"], 17, reset);
  self:SetCatBar(cfg, L["10_WAIST"], 17, reset);
  self:SetCatBar(cfg, L["11_LEGS"], 17, reset);
  self:SetCatBar(cfg, L["12_FEET"], 17, reset);
  self:SetCatBar(cfg, L["13_OFFHAND"], 17, reset);
  self:SetCatBar(cfg, L["ARMOR"], 17, reset);
  self:SetCatBar(cfg, L["WEAPON"], 17, reset);

-- Fourth default line - To Use or Sell
  self:SetCatBar(cfg, L["TRADE1"], 16, reset);
  self:SetCatBar(cfg, L["TRADE2"], 16, reset);
  self:SetCatBar(cfg, string.format(L["IN_%s_BAG"],L["ENCH"]), 16, reset);
  self:SetCatBar(cfg, string.format(L["IN_%s_BAG"],L["ENG"]), 16, reset);
  self:SetCatBar(cfg, string.format(L["IN_%s_BAG"],L["GEM"]), 16, reset);
  self:SetCatBar(cfg, string.format(L["IN_%s_BAG"],L["HERB"]), 16, reset);
  self:SetCatBar(cfg, string.format(L["IN_%s_BAG"],L["MINE"]), 16, reset);
  self:SetCatBar(cfg, string.format(L["IN_%s_BAG"],L["LTHR"]), 16, reset);
  self:SetCatBar(cfg, string.format(L["IN_%s_BAG"],L["INSC"]), 16, reset);
  self:SetCatBar(cfg, string.format(L["IN_%s_BAG"],L["TACKLE"]), 16, reset);
  self:SetCatBar(cfg, string.format(L["IN_%s_BAG"],L["REAG"]), 16, reset);
  self:SetCatBar(cfg, string.format(L["IN_%s_BAG"],L["FRIDGE"]), 16, reset);
  self:SetCatBar(cfg, string.format(L["IN_%s_BAG"],L["UNKNOWN"]), 16, reset);
  self:SetCatBar(cfg, string.format(L["EMPTY_%s_SLOTS"],L["ENCH"]), 16, reset);
  self:SetCatBar(cfg, string.format(L["EMPTY_%s_SLOTS"],L["ENG"]), 16, reset);
  self:SetCatBar(cfg, string.format(L["EMPTY_%s_SLOTS"],L["GEM"]), 16, reset);
  self:SetCatBar(cfg, string.format(L["EMPTY_%s_SLOTS"],L["HERB"]), 16, reset);
  self:SetCatBar(cfg, string.format(L["EMPTY_%s_SLOTS"],L["MINE"]), 16, reset);
  self:SetCatBar(cfg, string.format(L["EMPTY_%s_SLOTS"],L["LTHR"]), 16, reset);
  self:SetCatBar(cfg, string.format(L["EMPTY_%s_SLOTS"],L["INSC"]), 16, reset);
  self:SetCatBar(cfg, string.format(L["EMPTY_%s_SLOTS"],L["TACKLE"]), 16, reset);
  self:SetCatBar(cfg, string.format(L["EMPTY_%s_SLOTS"],L["REAG"]), 16, reset);
  self:SetCatBar(cfg, string.format(L["EMPTY_%s_SLOTS"],L["FRIDGE"]), 16, reset);
  self:SetCatBar(cfg, string.format(L["EMPTY_%s_SLOTS"],L["UNKNOWN"]), 16, reset);

  self:SetCatBar(cfg, L["CLOTH"], 15, reset);
  self:SetCatBar(cfg, L["FIRST_AID"], 15, reset);

  self:SetCatBar(cfg, L["COOKING"], 14, reset);
  self:SetCatBar(cfg, string.format(L["SOULBOUND_%s"],L["RING"]), 14, reset);
  self:SetCatBar(cfg, string.format(L["SOULBOUND_%s"],L["TRINKET"]), 14, reset);

  self:SetCatBar(cfg, string.format(L["SOULBOUND_%s"],L["01_HEAD"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["SOULBOUND_%s"],L["02_NECK"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["SOULBOUND_%s"],L["03_SHOULDER"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["SOULBOUND_%s"],L["04_BACK"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["SOULBOUND_%s"],L["05_CHEST"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["SOULBOUND_%s"],L["06_SHIRT"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["SOULBOUND_%s"],L["07_TABARD"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["SOULBOUND_%s"],L["08_WRIST"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["SOULBOUND_%s"],L["09_HANDS"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["SOULBOUND_%s"],L["10_WAIST"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["SOULBOUND_%s"],L["11_LEGS"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["SOULBOUND_%s"],L["12_FEET"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["SOULBOUND_%s"],L["13_OFFHAND"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["SOULBOUND_%s"],L["ARMOR"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["SOULBOUND_%s"],L["WEAPON"]), 13, reset);

  self:SetCatBar(cfg, string.format(L["ACCOUNTBOUND_%s"],L["RING"]), 14, reset);
  self:SetCatBar(cfg, string.format(L["ACCOUNTBOUND_%s"],L["TRINKET"]), 14, reset);

  self:SetCatBar(cfg, string.format(L["ACCOUNTBOUND_%s"],L["01_HEAD"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["ACCOUNTBOUND_%s"],L["02_NECK"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["ACCOUNTBOUND_%s"],L["03_SHOULDER"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["ACCOUNTBOUND_%s"],L["04_BACK"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["ACCOUNTBOUND_%s"],L["05_CHEST"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["ACCOUNTBOUND_%s"],L["06_SHIRT"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["ACCOUNTBOUND_%s"],L["07_TABARD"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["ACCOUNTBOUND_%s"],L["08_WRIST"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["ACCOUNTBOUND_%s"],L["09_HANDS"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["ACCOUNTBOUND_%s"],L["10_WAIST"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["ACCOUNTBOUND_%s"],L["11_LEGS"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["ACCOUNTBOUND_%s"],L["12_FEET"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["ACCOUNTBOUND_%s"],L["13_OFFHAND"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["ACCOUNTBOUND_%s"],L["ARMOR"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["ACCOUNTBOUND_%s"],L["WEAPON"]), 13, reset);

  self:SetCatBar(cfg, string.format(L["%s_CREATED"],L["TRADE1"]), 13, reset);
  self:SetCatBar(cfg, string.format(L["%s_CREATED"],L["TRADE2"]), 13, reset);

-- Third default line - Swappables
  self:SetCatBar(cfg, L["MINIPET"], 12, reset);
  self:SetCatBar(cfg, L["COMBATPETS"], 12, reset);
  self:SetCatBar(cfg, L["COSTUMES"], 12, reset);
  self:SetCatBar(cfg, L["TOYS"], 12, reset);
  self:SetCatBar(cfg, L["MOUNT"], 12, reset);

  self:SetCatBar(cfg, L["FISHING"], 11, reset);
  self:SetCatBar(cfg, L["TRADE_TOOL"], 11, reset);

-- (Bars 9 and 10 were the EQUIPPED_* category zone -- removed; the category
-- collected bag duplicates of currently-equipped gear, which in practice
-- only fired when the player had a same-itemID, same-ilvl spare item. Empty
-- for ~everyone and shadowed by the bind-state categories anyway.)

-- Second default line - Out of Combat Stocks
  self:SetCatBar(cfg, L["FOOD"], 8, reset);
  self:SetCatBar(cfg, L["FOOD_BUFF"], 8, reset);

  self:SetCatBar(cfg, L["DRINK"], 7, reset);
  self:SetCatBar(cfg, L["COMBO"], 7, reset);

  self:SetCatBar(cfg, L["BUFF"], 6, reset);

  self:SetCatBar(cfg, L["CLASS_REAGENT"], 5, reset);
  self:SetCatBar(cfg, L["DUMMY"], 5, reset);

-- First default line - In Combat Stocks
  self:SetCatBar(cfg, L["BANDAGE"], 4+row1offset, reset);
  self:SetCatBar(cfg, L["HEALTH_RESTORE"], 4+row1offset, reset);
  self:SetCatBar(cfg, L["HEALTHSTONE"], 4+row1offset, reset);

  self:SetCatBar(cfg, L["MANA_RESTORE"], 3+row1offset, reset);
  self:SetCatBar(cfg, L["COMBO_RESTORE"], 3+row1offset, reset);
  self:SetCatBar(cfg, L["RAGE_RESTORE"], 3+row1offset, reset);
  self:SetCatBar(cfg, L["ENERGY_RESTORE"], 3+row1offset, reset);

  self:SetCatBar(cfg, L["CURE"], 2+row1offset, reset);
  self:SetCatBar(cfg, L["EXPLOSIVES"], 2+row1offset, reset);

  self:SetCatBar(cfg, L["HEARTH"], 1+row1offset, reset);

  table.sort(self:GetCatBar(cfg));
end


local BKGR_A = 0.4;
local BRDR_A = 0.5;

function TFuBag:SetDefColors(cfg, reset)
  self:SetColor(cfg, "newitem", 0.9, 0.9, 0.25, 1.0, reset);
  self:SetColor(cfg, "recentitem", 0.0, 1.0, 0.4, 1.0, reset);

  -- Red healing
  self:SetColor(cfg, "bkgr_4", 0.8, 0.1, 0.1, BKGR_A, reset);
  self:SetColor(cfg, "brdr_4", 0.8, 0.1, 0.1, BRDR_A, reset);

  self:SetColor(cfg, "bkgr_8", 0.8, 0.1, 0.1, BKGR_A, reset);
  self:SetColor(cfg, "brdr_8", 0.8, 0.1, 0.1, BRDR_A, reset);

  -- Blue mana
  self:SetColor(cfg, "bkgr_3", 0.1, 0.1, 1.0, BKGR_A, reset);
  self:SetColor(cfg, "brdr_3", 0.1, 0.1, 1.0, BRDR_A, reset);

  self:SetColor(cfg, "bkgr_7", 0.1, 0.1, 1.0, BKGR_A, reset);
  self:SetColor(cfg, "brdr_7", 0.1, 0.1, 1.0, BRDR_A, reset);

  -- Green Buffs
  self:SetColor(cfg, "bkgr_2", 0.1, 0.8, 0.1, BKGR_A, reset);
  self:SetColor(cfg, "brdr_2", 0.1, 0.8, 0.1, BRDR_A, reset);

  self:SetColor(cfg, "bkgr_6", 0.1, 0.8, 0.1, BKGR_A, reset);
  self:SetColor(cfg, "brdr_6", 0.1, 0.8, 0.1, BRDR_A, reset);

  -- Yellow trade
  self:SetColor(cfg, "bkgr_15", 0.9, 0.9, 0.1, BKGR_A, reset);
  self:SetColor(cfg, "brdr_15", 0.9, 0.9, 0.1, BRDR_A, reset);

  self:SetColor(cfg, "bkgr_16", 0.9, 0.9, 0.1, BKGR_A, reset);
  self:SetColor(cfg, "brdr_16", 0.9, 0.9, 0.1, BRDR_A, reset);

  self:SetColor(cfg, "bkgr_19", 0.9, 0.9, 0.1, BKGR_A, reset);
  self:SetColor(cfg, "brdr_19", 0.9, 0.9, 0.1, BRDR_A, reset);

  self:SetColor(cfg, "bkgr_20", 0.9, 0.9, 0.1, BKGR_A, reset);
  self:SetColor(cfg, "brdr_20", 0.9, 0.9, 0.1, BRDR_A, reset);

  -- White equipment
  self:SetColor(cfg, "bkgr_9", 0.65, 0.7, 0.75, BKGR_A, reset);
  self:SetColor(cfg, "brdr_9", 0.65, 0.7, 0.75, BRDR_A, reset);

  self:SetColor(cfg, "bkgr_10", 0.65, 0.7, 0.75, BKGR_A, reset);
  self:SetColor(cfg, "brdr_10", 0.65, 0.7, 0.75, BRDR_A, reset);

  self:SetColor(cfg, "bkgr_13", 0.65, 0.7, 0.75, BKGR_A, reset);
  self:SetColor(cfg, "brdr_13", 0.65, 0.7, 0.75, BRDR_A, reset);

  self:SetColor(cfg, "bkgr_17", 0.65, 0.7, 0.75, BKGR_A, reset);
  self:SetColor(cfg, "brdr_17", 0.65, 0.7, 0.75, BRDR_A, reset);

  self:SetColor(cfg, "bkgr_18", 0.65, 0.7, 0.75, BKGR_A, reset);
  self:SetColor(cfg, "brdr_18", 0.65, 0.7, 0.75, BRDR_A, reset);

  -- purple ammo / shards
  self:SetColor(cfg, "bkgr_28", 0.8, 0.3, 0.9, BKGR_A, reset);
  self:SetColor(cfg, "brdr_28", 0.8, 0.3, 0.9, BRDR_A, reset);
end

function TFuBag:ResetSorts(cfg)
  cfg["item_overrides"] = {};
  -- Deep-copy DefaultSearchList. The old code assigned by reference, which
  -- meant every cfg this session was the same table as the global
  -- DefaultSearchList; any user edit (Add Cat / Remove Cat / typed field)
  -- mutated the global in place. Once corrupted in-session, /reset just
  -- re-pointed cfg back at the same already-mutated table, so Reset never
  -- actually restored defaults until the addon was reloaded. The copy
  -- guarantees independence: future edits never reach back to the source.
  local copy = {};
  for i, row in ipairs(self.DefaultSearchList) do
    local r = {};
    for j = 1, table.getn(row) do
      r[j] = row[j];
    end
    copy[i] = r;
  end
  cfg["item_search_list"] = copy;
end

-- set reset to 1 to restore all default values
function TFuBag:InitDefVals(cfg, bagarr, row1offset, reset)
  local i, key, value;

  self:SetDef(cfg, "moveLock", 1, reset, self.NumFunc, 0,1);
  self:SetDef(cfg, "show_bag_icons", 0, reset, self.NumFunc, 0, 1);
  -- Collapse all empty slots into a single cell that shows the free-slot count
  -- (Baganator style) instead of one cell per empty slot. Cleaner, and the one cell
  -- is a real free slot so dropping an item onto it deposits. Default on.
  self:SetDef(cfg, "collapse_empty", 1, reset, self.NumFunc, 0, 1);
  self:SetDef(cfg, "spotlight_open", 1, reset, self.NumFunc, 0, 1);
  self:SetDef(cfg, "spotlight_hover", 1, reset, self.NumFunc, 0, 1);
  self:SetDef(cfg, "show_rarity_color", 1, reset, self.NumFunc, 0, 1);
  self:SetDef(cfg, "show_cat_names", 0, reset, self.NumFunc, 0, 1);
  -- Reagent split: off = generic Reagent/Trade Goods bars (Baganator-style);
  -- on = original TBag per-profession reagent/trade-good split (the "psplit"
  -- rules in DefaultSearchList, gated in PickBar).
  self:SetDef(cfg, "reagent_split", 0, reset, self.NumFunc, 0, 1);
  -- Material grouping (Categories panel): subtype -> group category. Default maps
  -- each trade-goods subtype to its own per-material category; the user can point
  -- several subtypes at the same category to merge them onto one bar. Seeded when
  -- absent (or on reset); user edits persist.
  if (reset == 1 or cfg.mat_group == nil) then
    cfg.mat_group = {
      [L["Herb"]]              = L["Herbs"],
      [L["Metal & Stone"]]     = L["Ore & Stone"],
      [L["Cloth"]]             = L["CLOTH"],
      [L["Leather"]]           = L["Leather"],
      [L["Cooking"]]           = L["Cooking Mats"],
      [L["Enchanting"]]        = L["Enchanting Mats"],
      [L["Inscription"]]       = L["Inscription Mats"],
      [L["Jewelcrafting"]]     = L["Jewelcrafting Mats"],
      [L["Elemental"]]         = L["Elemental"],
      [L["Parts"]]             = L["Engineering Parts"],
      [L["Optional Reagents"]] = L["Optional Reagents"],
      [L["Finishing Reagents"]]= L["Finishing Reagents"],
    };
  end
  self:SetDef(cfg, "manual_layout", 0, reset, self.NumFunc, 0, 1);
  -- Legacy Edit: when 1, force the original TBag edit experience (auto-flow layout +
  -- the classic Change-Edit-Mode click-to-assign category editing) and DISABLE the
  -- Manual Layout mouse drag/placement, regardless of the manual_layout toggle.
  self:SetDef(cfg, "legacy_edit", 0, reset, self.NumFunc, 0, 1);
  -- Manual Layout placement mode: 0 = grid (snap to button cells, bottom-aligned
  -- rows), 1 = free placement (drag anywhere, snap/dock by the spacing settings,
  -- per-box titles). Each mode keeps its OWN saved positions (cat_layout vs
  -- cat_layout_free) so toggling between them doesn't clobber either arrangement.
  self:SetDef(cfg, "ml_freeplace", 0, reset, self.NumFunc, 0, 1);
  -- GRID positions. Keyed by bar index: cat_layout[barnum] = { gx, gy, cols }.
  -- Integer GRID COORDS (cells) so placements scale with button size/window scale.
  -- Per-window (Inv vs Bnk each get their own). Preserved across loads; wiped only
  -- on a full defaults reset.
  if (cfg["cat_layout"] == nil or reset == 1) then
    cfg["cat_layout"] = {};
  end
  -- FREE-PLACEMENT positions: cat_layout_free[barnum] = { fx, fy, cols }. fx/fy are
  -- FRACTIONAL cell coords (pixels / button size) so they rescale too, but are not
  -- snapped to whole cells. Same per-window / preserve / reset rules.
  if (cfg["cat_layout_free"] == nil or reset == 1) then
    cfg["cat_layout_free"] = {};
  end

  self:SetDef(cfg, "stack_auto", 1, reset, self.NumFunc, 0, 1);
  self:SetDef(cfg, "stack_resort", 1, reset, self.NumFunc, 0, 1);

  self:SetDef(cfg, "bar_x", 4, reset, self.NumFunc, 1, self.NUMCOL_MAX);
  self:SetDef(cfg, "scale", 1, reset, self.NumFunc, 0.1, 1.0);
  self:SetDef(cfg, "frameButtonSize", 34, reset, self.NumFunc, self.N_BUTTON_MIN, self.N_BUTTON_MAX);

  self:SetDef(cfg, "framePad", 1, reset, self.NumFunc, 0, self.N_SPACE_MAX);
  self:SetDef(cfg, "frameXSpace", 1, reset, self.NumFunc, 0, self.N_SPACE_MAX);
  self:SetDef(cfg, "frameYSpace", 1, reset, self.NumFunc, 0, self.N_SPACE_MAX);
  self:SetDef(cfg, "frameXPool", 1, reset, self.NumFunc, 0, self.N_SPACE_MAX);
  self:SetDef(cfg, "frameYPool", 2, reset, self.NumFunc, 0, self.N_SPACE_MAX);
  self:SetDef(cfg, "cat_spacing", 0, reset, self.NumFunc, 0, self.N_CATSPACE_MAX);
  self:SetDef(cfg, "count_font", 14, reset, self.NumFunc, self.N_FONT_MIN, self.N_FONT_MAX);
  self:SetDef(cfg, "count_font_x", 2, reset, self.NumFunc, 0, self.N_BUTTON_MAX);
  self:SetDef(cfg, "count_font_y", 2, reset, self.NumFunc, 0, self.N_BUTTON_MAX);
  self:SetDef(cfg, "new_font", 12, reset, self.NumFunc, self.N_FONT_MIN, self.N_FONT_MAX);

  self:SetDef(cfg, "show_bag_sizes", 0, reset, self.NumFunc, 0, 1);
  self:SetDef(cfg, "special_bag_sort", 1, reset, self.NumFunc, 0, 1);
  self:SetDef(cfg, "trade_created_sort", 0, reset, self.NumFunc, 0, 1);

  self:SetDef(cfg, self.V_NEWON, "**", reset);
  self:SetDef(cfg, self.V_NEWPLUS, "++", reset);
  self:SetDef(cfg, self.V_NEWMINUS, "--", reset);
  self:SetDef(cfg, self.V_NEWOFF, "", reset);
  self:SetDef(cfg, "newItemTimeout", 60*3 , reset, self.NumFunc);   -- 3 hours for an item to lose "new" status
  self:SetDef(cfg, "recentTimeout", 10 , reset, self.NumFunc);  -- 10 minutes

  self:SetDef(cfg, "show_userdropdown", 1, reset, self.NumFunc, 0, 1);
  self:SetDef(cfg, "show_reloadbutton", 1, reset, self.NumFunc, 0, 1);
  self:SetDef(cfg, "show_editbutton", 1, reset, self.NumFunc, 0, 1);
  self:SetDef(cfg, "show_hilightbutton", 1, reset, self.NumFunc, 0, 1);
  self:SetDef(cfg, "show_depositbutton", 1, reset, self.NumFunc, 0, 1);
  self:SetDef(cfg, "show_lockbutton", 1, reset, self.NumFunc, 0, 1);
  self:SetDef(cfg, "show_closebutton", 1, reset, self.NumFunc, 0, 1);
  self:SetDef(cfg, "show_total", 1, reset, self.NumFunc, 0, 1);
  self:SetDef(cfg, "show_bagbuttons", 1, reset, self.NumFunc, 0, 1);
  self:SetDef(cfg, "show_money", 1, reset, self.NumFunc, 0, 1);
  self:SetDef(cfg, "show_tokens", 1, reset, self.NumFunc, 0, 1);

  -- Category-uplift bar migration: an earlier build placed these categories on
  -- shared bars (so they merged into one box). Clear their saved slots so the
  -- SetDefLayout call below reassigns them to their new per-category bars without
  -- needing a full /reset. Bump UPLIFT_BAR_V whenever these default bars change again.
  local UPLIFT_BAR_V = 2;
  if (reset ~= 1 and cfg[self.CAT_BAR] and cfg.catbar_uplift_v ~= UPLIFT_BAR_V) then
    local cb = cfg[self.CAT_BAR];
    local moved = {
      L["Herbs"], L["Ore & Stone"], L["Leather"], L["Cooking Mats"],
      L["Enchanting Mats"], L["Inscription Mats"], L["Jewelcrafting Mats"],
      L["Elemental"], L["Engineering Parts"], L["Optional Reagents"],
      L["Finishing Reagents"], L["Gems"], L["Housing"], L["Mount Equipment"],
      L["TRADE_GOODS"],  -- v2: relocate the catch-all off the merged bar 19
    };
    for _, c in ipairs(moved) do cb[c] = nil; end
    cfg.catbar_uplift_v = UPLIFT_BAR_V;
  end

  -- Do the layout
  self:SetDefLayout(cfg, bagarr, row1offset, reset);

  local bag, idx;
  for idx, bag in ipairs(bagarr) do
    if (bag == REAGENTBANK_CONTAINER) then
      self:SetDef(cfg, "show_Bag"..bag, 0, reset, self.NumFunc, 0, 1);
    else
      self:SetDef(cfg, "show_Bag"..bag, 1, reset, self.NumFunc, 0, 1);
    end
    self:SetColor(cfg, "bag_"..bag,
      self.DBC[idx]["r"], self.DBC[idx]["g"], self.DBC[idx]["b"], self.DBC[idx]["a"], reset);
  end

  -- default item overrides
  self:SetDef(cfg, "itemoverride_loaddefaults", 1, reset, self.NumFunc, 0, 1);
  if (cfg["itemoverride_loaddefaults"] == 1) then
    self:ResetSorts(cfg);
    cfg["itemoverride_loaddefaults"] = 0;
  end

  -- default sort views / default "allow new items in bar" settings
  if (reset ~= 1) then
    self:SetGrpDef(cfg, self.G_BAR_SORT, 16, self.SORTBY_REV, reset, self.NumFunc, self.SORTBY_MIN, self.SORTBY_MAX);
    for i = 19, 24 do
      self:SetGrpDef(cfg, self.G_BAR_SORT, i, self.SORTBY_REV, reset, self.NumFunc, self.SORTBY_MIN, self.SORTBY_MAX);
    end
  end

  for i = 1, self.BAR_MAX do
    self:SetGrpDef(cfg, self.G_BAR_SORT, i, self.SORTBY_NORM, reset, self.NumFunc, self.SORTBY_MIN, self.SORTBY_MAX);
    self:SetGrpDef(cfg, self.G_USE_NEW, i, 1, reset, self.NumFunc, 0, 1);
    self:SetGrpDef(cfg, self.G_BAR_HIDE, i, 0, reset, self.NumFunc, 0, 1);
  end

  if (reset == 1) then
    self:SetGrpDef(cfg, self.G_BAR_SORT, 16, self.SORTBY_REV, reset, self.NumFunc, self.SORTBY_MIN, self.SORTBY_MAX);
    for i = 19, 24 do
      self:SetGrpDef(cfg, self.G_BAR_SORT, i, self.SORTBY_REV, reset, self.NumFunc, self.SORTBY_MIN, self.SORTBY_MAX);
    end
  end

  self:AssignCats(cfg, reset);
end

function TFuBag:AssignCats(cfg, reset)
  -- find matching categories that are not assigned
  for _ ,value in ipairs(cfg["item_search_list"]) do
    if (self:GetCat(cfg, value[1]) == nil) then
      DEFAULT_CHAT_FRAME:AddMessage(self.SCP..
        string.format(L["Unassigned category %s has been assigned to slot 1"],value[1]));
      self:SetCatBar(cfg, value[1], 1, reset);
    end
  end
end

function TFuBag:PrintCachedCharacters()
  DEFAULT_CHAT_FRAME:AddMessage(self.SCP..L["Character data cached for:"], 1, 1, 1);
  for key, value in pairs(TFuInvItm) do
    local player,realm = strsplit("|",key)
    DEFAULT_CHAT_FRAME:AddMessage(player.." "..realm);
  end
end

function TFuBag:DeleteCachedCharacter(char,realm)
  local playerid = char.."|"..realm;
  local found = 0;
  if (TFuInvItm[playerid]) then
    found = 1;
  end
  TFuInvItm[playerid] = nil;
  TFuBnkItm[playerid] = nil;
  TFuContItm[playerid] = nil;
  TFuBodyItm[playerid] = nil;
  TFuMailItm[playerid] = nil;
  TFuTknItm[playerid] = nil;
  TFuBagInfo[playerid] = nil;
  if (found == 1 and TFuInvItm[playerid] == nil) then
    DEFAULT_CHAT_FRAME:AddMessage(self.SCP..
       string.format(L["Removed cache for %q"],playerid),
       1, 1, 1);
  else
    DEFAULT_CHAT_FRAME:AddMessage(self.SCP..
       string.format(L["Couldn't find and remove cache for %q"],playerid),
       1, 1, 1);
  end
end

function TFuBag:SetFrameAnchor (frame,cfg,y,x)
    -- Set the config
    cfg["frameYRelativeTo"] = y;
    cfg["frameXRelativeTo"] = x;

    -- Set the anchor on the actual frame.
    frame:ClearAllPoints();
    frame:SetPoint(cfg["frameYRelativeTo"]..cfg["frameXRelativeTo"],
      "UIParent", "BOTTOMLEFT",
      cfg["frame"..cfg["frameXRelativeTo"]] / frame:GetScale(),
      cfg["frame"..cfg["frameYRelativeTo"]] / frame:GetScale());
end

-----------------------------------------------------------------------
-- Categories and Bars
-----------------------------------------------------------------------

function TFuBag:Cat(str)
  -- Uppercase, and replace spaces
  local cat = string.upper(str);
  return string.gsub(cat, " ", "_");
end

function TFuBag:SetCatBar(cfg, cat, bar, reset)
  if ((cfg ~= nil) and (cat ~= nil)) then
    if (cfg[self.CAT_BAR] == nil) then
      cfg[self.CAT_BAR] = {};
      cfg[self.CAT_BAR][cat] = bar;
    elseif (cfg[self.CAT_BAR][cat] == nil) then
      cfg[self.CAT_BAR][cat] = bar;
    else
      if (reset == 1) then cfg[self.CAT_BAR][cat] = bar; end
    end
  end
end

function TFuBag:GetCatBar(cfg)
  if (cfg ~= nil) then
    if (cfg[self.CAT_BAR] == nil) then
      cfg[self.CAT_BAR] = {};
    end
    return cfg[self.CAT_BAR];
  end
end

function TFuBag:GetCat(cfg, bar)
  if (cfg ~= nil) then
    if (cfg[self.CAT_BAR] == nil) then
      cfg[self.CAT_BAR] = {};
      return nil;
    end
    return cfg[self.CAT_BAR][bar];
  end
end

-- Walk up the parent chain until we find a frame carrying the addon's `cfg` --
-- that's the bag window (TFuInvFrame / TFuBnkFrame). Previously item-button code
-- did `self:GetParent():GetParent()`, baking in the Item->DummyBag->MainFrame
-- depth. The scroll viewport inserts ScrollChild + ScrollFrame between the
-- DummyBag and MainFrame, so a fixed step-count is wrong; this helper makes the
-- depth flexible (and tolerates the EditButton variant that was one level deeper).
function TFuBag:GetButtonMainFrame(btn)
  local f = btn and btn:GetParent();
  while (f) do
    if (f.cfg) then return f; end
    f = f:GetParent();
  end
  return nil;
end

function TFuBag:PositionFrame(frameName, childAttachPoint, parentFrameName, parentAttachPoint, xoffset, yoffset, width, height)
  local frame = _G[frameName];

  if (frame) then
    frame:ClearAllPoints();
    frame:SetPoint(childAttachPoint, parentFrameName, parentAttachPoint, xoffset, yoffset);
    frame:SetWidth(width);
    frame:SetHeight(height);
--    frame:Show();
  else
    self:PrintDEBUG("Attempt to find frame '"..frameName.."' failed.");
  end
end


function TFuBag:BuildBarClassList(bclist, cfg)
  local bar, barclass;
  local key, val;

  -- First wipe the old bar class lists
  for bar = 1, self.BAR_MAX do
    bclist[bar] = bclist[bar] or {};
    for k,_ in pairs(bclist[bar]) do
      bclist[bar][k] = nil;
    end
  end

  -- Build up the list
  for barclass, value in pairs(self:GetCatBar(cfg)) do
    if ( (type(value) == "number") ) then
      table.insert(bclist[value], barclass);
    end
  end

  -- Then sort the new bar class lists
  for bar = 1, self.BAR_MAX do
    table.sort(bclist[bar]);
  end
end

-- Builds (once) a DISPLAY-only label map: category identity -> condensed label.
-- This is keyed on the real category string (itm[I_CAT]) and only affects what
-- the "Show Category Names" header prints. It deliberately does NOT touch the
-- category identities, so item->bar matching, keyword matching, and the within-
-- bar sort (which groups same-type items, e.g. helms with helms) are unchanged.
-- The slot-based families (equipped / soulbound / account-bound / carried armor)
-- collapse to one label each for the header, while their per-slot identities are
-- preserved so sorting still groups by slot.
function TFuBag:BuildCatLabels()
  if (self.CatLabel) then return self.CatLabel; end
  local C = {};

  -- Direct one-to-one condensed names.
  local direct = {
    CONSUMABLE = "Consumables", ACT_ON = "Quest Starter", ACT_OPEN = "Openable",
    ACT_SELL = "Sellable", BAG = "Bags", GRAY_ITEMS = "Junk", QUEST = "Quest Items",
    KEY_QUEST = "Keys", ENCHANTS = "Enchants", GLYPHS = "Glyphs", BOOK = "Books",
    DESIGN = "Designs", FORMULA = "Formulas", RECIPE = "Recipes", PATTERN = "Patterns",
    PLANS = "Plans", SCHEMATIC = "Schematics", RECIPE_OTHER = "Recipes",
    BLUEPRINTS = "Blueprints", PVP = "PvP", REAGENT = "Reagents",
    TRADE_GOODS = "Trade Goods", CLOTH = "Cloth", FOLLOWERS = "Followers",
    MINIPET = "Companion Pets", COMBATPETS = "Combat Pets", COSTUMES = "Costumes",
    FIREWORKS = "Fireworks", TOYS = "Toys", MOUNT = "Mounts", FOOD = "Food",
    FOOD_BUFF = "Food Buffs", DRINK = "Drink", COMBO = "Refreshment", BUFF = "Buffs",
    DUMMY = "Target Dummy", BANDAGE = "Bandages", HEALTH_RESTORE = "Health",
    HEALTHSTONE = "Healthstone", MANA_RESTORE = "Mana", COMBO_RESTORE = "Health & Mana",
    RAGE_RESTORE = "Rage", ENERGY_RESTORE = "Energy", CURE = "Cures",
    EXPLOSIVES = "Explosives", HEARTH = "Hearthstone", MISC = "Miscellaneous",
    ARTIFACTPOWER = "Artifact Power", ARTIFACTRELIC = "Artifact Relics",
    UNKNOWN = "Unsorted",
    TIMBERMAW = "Timbermaw Hold", CENARION_EXPEDITION = "Cenarion Expedition",
    SPOREGGAR = "Sporeggar", ALDOR = "The Aldor", SCRYER = "The Scryers",
    LOWER_CITY = "Lower City", AHN_QIRAJ = "Ahn'Qiraj", NETHERWING = "Netherwing",
    BLACKWING_LAIR = "Blackwing Lair", DARKMOON_FAIRE = "Darkmoon Faire",
    ["OGRI'LA"] = "Ogri'la", MOLTEN_CORE = "Molten Core", CONSORTIUM = "The Consortium",
    HALAA = "Halaa",
    ALCHEMY = "Alchemy", BLACKSMITHING = "Blacksmithing", ENCHANTING = "Enchanting",
    ENGINEERING = "Engineering", JEWELCRAFTING = "Jewelcrafting",
    LEATHERWORKING = "Leatherworking", MINING = "Mining", TAILORING = "Tailoring",
    INSCRIPTION = "Inscription", FIRST_AID = "First Aid", COOKING = "Cooking",
    FISHING = "Fishing", ARCHAEOLOGY = "Archaeology", RUNEFORGING = "Runeforging",
    TRADE_TOOL = "Profession Tools",
    RING = "Ring", TRINKET = "Trinket", WEAPON = "BoE", OTHER = "Other",
    DRUID = "Druid", WARLOCK = "Warlock", ROGUE = "Rogue", MAGE = "Mage",
    PALADIN = "Paladin", PRIEST = "Priest", SHAMAN = "Shaman", WARRIOR = "Warrior",
    HUNTER = "Hunter", DEATHKNIGHT = "Death Knight", MONK = "Monk",
    DEMONHUNTER = "Demon Hunter", CLASS_REAGENT = "Class Reagents",
  };
  for k, v in pairs(direct) do
    C[L[k]] = v;
  end

  -- Slot families: collapse the per-slot soulbound/account-bound categories
  -- to a single header label each (identities stay per-slot). The EQUIPPED_*
  -- family was removed -- it served no real purpose in practice (matched
  -- only true bag-copies of currently-equipped gear at the same effective
  -- ilvl, which was empty for the typical inventory).
  local slots = { "01_HEAD","02_NECK","03_SHOULDER","04_BACK","05_CHEST","06_SHIRT",
    "07_TABARD","08_WRIST","09_HANDS","10_WAIST","11_LEGS","12_FEET","13_OFFHAND",
    "RING","TRINKET","ARMOR","WEAPON","OTHER" };
  for _, s in ipairs(slots) do
    C[string.format(L["SOULBOUND_%s"], L[s])]    = "Soulbound";
    C[string.format(L["ACCOUNTBOUND_%s"], L[s])] = "Account-Bound";
  end

  -- Carried (un-equipped, un-bound) gear collapses to "BoE" for the header
  -- because the bar 17 default groups un-bound armor + weapon (typically
  -- Bind-on-Equip drops). Per-slot identities remain so the within-bar sort
  -- still groups by slot. The plain WEAPON label is set to "BoE" in the
  -- direct map above for the same reason -- so the bar dedupes to a single
  -- "BoE" header instead of "Weapon / Armor".
  local armorslots = { "01_HEAD","02_NECK","03_SHOULDER","04_BACK","05_CHEST",
    "06_SHIRT","07_TABARD","08_WRIST","09_HANDS","10_WAIST","11_LEGS","12_FEET",
    "13_OFFHAND","ARMOR" };
  for _, s in ipairs(armorslots) do
    C[L[s]] = "BoE";
  end

  self.CatLabel = C;
  return C;
end

-- Returns the displayed name for a bar: the distinct condensed labels of the
-- items actually present in it. Items are already sorted by their (per-slot)
-- category, so the collapsed labels appear grouped. Used by "Show Category Names".
function TFuBag:GetBarCategoryName(baritmbar)
  local labels = self:BuildCatLabels();
  local seen = {};
  local names = {};
  for _, itm in ipairs(baritmbar) do
    local cat;
    -- Empty slots carry an internal "EMPTY_<pos>_SLOTS" category; collapse all of
    -- those into a single clean "Empty" label instead of the raw token.
    if (not itm[self.I_ITEMLINK] or itm[self.I_ITEMLINK] == "") then
      cat = L["Empty"];
    else
      cat = itm[self.I_CAT];
      cat = labels[cat] or cat;
    end
    if (cat and cat ~= "" and not seen[cat]) then
      seen[cat] = true;
      table.insert(names, cat);
    end
  end
  return table.concat(names, " / ");
end

-- Right-click a category title label to dump that category's contents to chat (same as
-- /printcat <name>). The titles are FontStrings (non-interactive), so we overlay a
-- transparent button sized to JUST the title text. It registers only for right-click, so
-- it ignores (does not error on) left-clicks; because it covers only the text and not the
-- full-width Manual-Layout drag handle beneath, the handle stays grabbable on either side
-- of the text. One button per bar frame, created once and reused; call with show=false to
-- hide it when titles are off.
function TFuBag:WireCatTitleClick(frame, bf, baritmbar, show)
  if (not bf) then return; end
  local label = bf.CatName;
  if (not label) then return; end
  local btn = bf.CatTitleBtn;
  if (not show) then
    if (btn) then btn:Hide(); end
    return;
  end
  if (not btn) then
    btn = CreateFrame("Button", nil, bf);
    btn:RegisterForClicks("RightButtonUp");
    btn:SetScript("OnClick", function(self, mouseButton)
      if (mouseButton ~= "RightButton") then return; end
      local names = self.catNames;
      if (not names) then return; end
      for _, nm in ipairs(names) do
        TFuBag:PrintCategoryContents(self.which, nm);
      end
    end);
    btn:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
      GameTooltip:SetText("Right-click: print this category to chat", 1, 1, 1, 1, true);
      GameTooltip:Show();
    end);
    btn:SetScript("OnLeave", function() GameTooltip:Hide(); end);
    bf.CatTitleBtn = btn;
  end
  -- Re-cover the title text every layout (the label re-anchors center/left/right).
  btn:ClearAllPoints();
  btn:SetAllPoints(label);
  btn:SetFrameLevel(bf:GetFrameLevel() + 12);
  btn.which = (frame == TFuBnkFrame) and "bank" or "inv";
  -- Split a merged-bar title ("A / B") so each category is dumped separately.
  local names = {};
  for piece in string.gmatch(self:GetBarCategoryName(baritmbar), "[^/]+") do
    local t = strtrim(piece);
    if (t ~= "") then names[#names + 1] = t; end
  end
  btn.catNames = names;
  btn:Show();
end

-- Used for options strings
function TFuBag:GetBagDispName(bag)
  if ( bag < self.BAGMIN ) or ( bag > self.BAGMAX ) then return ""; end
  if (bag == BANK_CONTAINER) then return L["Bank"]; end
  if (bag == REAGENTBANK_CONTAINER) then return REAGENT_BANK; end
  if (bag == BACKPACK_CONTAINER) then return L["Backpack"]; end
  if (bag == 1) then return L["Fourth Bag"]; end
  if (bag == 2) then return L["Third Bag"]; end
  if (bag == 3) then return L["Second Bag"]; end
  if (bag == 4) then return L["First Bag"]; end
  -- Bag 5 is the live reagent bag (Enum.BagIndex.ReagentBag).
  if (bag == 5) then return L["Reagent Bag"]; end
  -- 12.0 bank tabs (6-16): use the live tab name from C_Bank (cached in
  -- Bank.tabData by Bank:RebuildTabList); fall back to a generic label.
  if (self:IsBankTab(bag)) then
    local td = TFuBnkFrame and TFuBnkFrame.tabData and TFuBnkFrame.tabData[bag];
    if (td and td.name and td.name ~= "") then return td.name; end
    if (bag <= 11) then return L["Bank"].." "..(bag - 5); end
    return L["Warband"].." "..(bag - 11);
  end
end

-- Used for EMPTY_X_SLOTS
function TFuBag:GetBagPosName(bag)
  if ( bag < self.BAGMIN ) or ( bag > self.BAGMAX ) then return ""; end
  if (bag == BANK_CONTAINER) then return L["BANK"]; end
  if (bag == REAGENTBANK_CONTAINER) then return L["REAGENTBANK"]; end
  if (bag == BACKPACK_CONTAINER) then return L["BACKPACK"]; end
  if (bag == 1) then return L["BAG1"]; end
  if (bag == 2) then return L["BAG2"]; end
  if (bag == 3) then return L["BAG3"]; end
  if (bag == 4) then return L["BAG4"]; end
  -- Bag 5 = reagent bag (live). See GetBagDispName for the bank-bag-1 collision
  -- note; RBAG keeps the reagent bag's empty-slot category distinct.
  if (bag == 5) then return L["RBAG"]; end
  -- 12.0 bank tabs (6-16): empty-slot category fragment per tab. Use the live tab
  -- name when available, else a stable per-tab token.
  if (self:IsBankTab(bag)) then
    local td = TFuBnkFrame and TFuBnkFrame.tabData and TFuBnkFrame.tabData[bag];
    if (td and td.name and td.name ~= "") then return td.name; end
    return "BTAB"..bag;
  end
end

function TFuBag:GetBagTypeName(bagType)
  if (bagType == 0) then
    return L["BAG"];
  elseif (bagType == 8) then
    return L["LTHR"];
  elseif (bagType == 16) then
    return L["INSC"];
  elseif (bagType == 32) then
    return L["HERB"];
  elseif (bagType == 64) then
    return L["ENCH"];
  elseif (bagType == 128) then
    return L["ENG"];
  elseif (bagType == 512) then
    return L["GEM"];
  elseif (bagType == 1024) then
    return L["MINE"];
  elseif (bagType == 4096) then
    return L["PET"];
  elseif (bagType == 2048) then
    return L["REAG"];
  elseif (bagType == 32768) then
    return L["TACKLE"];
  elseif (bagType == 65536) then
    return L["FRIDGE"];
  else
    return L["UNKNOWN"];
  end
end

-- Used for EMPTY_X_SLOTS and IN_X_BAG
-- Redo this using system calls to the actual frame
function TFuBag:GetBagType(playerid, bag)
  local type = 0;
  local _;

  if ( bag < self.BAGMIN ) or ( bag > self.BAGMAX ) then return nil; end

  -- get the live info if we are the current player, and at the bank
  if (playerid == self.PLAYERID and (TFuBnkFrame.atbank == 1 or self:Member(TFuBag.Inv_Bags, bag))) then
    local itemlink,id,name,itemType,subType,quality;
    -- 12.0 bank tabs (6-16) are containers, not equipped bag items: they have no
    -- ContainerIDToInventoryID slot, so skip the worn-bag-item lookup for them.
    if (bag > BACKPACK_CONTAINER and not self:IsBankTab(bag)) then
      itemlink = GetInventoryItemLink("player", ContainerIDToInventoryID(bag));
      id, itemlink = self:GetItemID(itemlink);
      name, itemType, subType, quality = self:GetItemInfo(id);
    end
    self:SetPlayerBagCfg(playerid, bag, self.I_ITEMLINK, itemlink);
    -- ITEMID is obsolete since it's included in ITEMLINK so always set it to nil.
    self:SetPlayerBagCfg(playerid, bag, self.I_ITEMID, nil);
    self:SetPlayerBagCfg(playerid, bag, self.I_NAME, name);
    self:SetPlayerBagCfg(playerid, bag, self.I_RARITY, quality);
    _,type = GetContainerNumFreeSlots(bag);

    -- GetContainerNumFreeSlots doesn't return the bag type for the REAGENTBANK.
    if (bag == REAGENTBANK_CONTAINER) then
      type = 2048; -- This is an unused id and we're squating on it since the
                   -- reagent bank doesn't have a real id
    end

    if (id) then
      self:SetPlayerBagCfg(playerid, bag, self.I_COUNT, 1);
    else
      self:SetPlayerBagCfg(playerid, bag, self.I_COUNT, nil);
    end

    -- Save the type to cache
    self:SetPlayerBagCfg(playerid, bag, self.I_BAGTYPE, type);
  else
    -- Fetch cached info if we can't get live info.
    type = self:GetPlayerBagCfg(playerid, bag, self.I_BAGTYPE);
  end

  return type;
end


function TFuBag:GetBagTexture(playerid, bag)
  local texture;


  -- Special bag textures are always fixed
  if (bag == BACKPACK_CONTAINER) then
    texture = "Interface\\Buttons\\Button-Backpack-Up";
  elseif (bag == BANK_CONTAINER) then
    texture = "Interface\\Icons\\INV_Box_03";
  elseif (bag == REAGENTBANK_CONTAINER) then
    texture = "Interface\\Icons\\INV_Misc_Bag_SatchelofCenarius.blp";
  else
    local itemlink = self:GetPlayerBagCfg(playerid, bag, self.I_ITEMLINK);
    if (itemlink) then
      texture = GetItemIcon(itemlink);
    else
      texture = "interface\\paperdoll\\UI-PaperDoll-Slot-Bag";
    end
  end

  return texture;
end


function TFuBag:GetBagFrameName(bag)
  if (bag == BANK_CONTAINER) then
    return "TFuBnkFrameBagBank";
  elseif (bag == REAGENTBANK_CONTAINER) then
    return "TFuBnkFrameBagReagent";
  elseif (bag == BACKPACK_CONTAINER) then
    return "TFuInvMenuBarBackpackButton";
  elseif self:Member(self.Inv_Bags, bag) then
    return "TFuInvacterBag"..(bag-1).."Slot";
  elseif self:Member(self.Bnk_Bags, bag) then
    -- 12.0 Stage 2: bank tabs use dynamic per-tab selector buttons (built in
    -- Bank:RefreshTabStrip), NOT the static XML TFuBnkFrameBag1-7 row. Each button
    -- IS the bag-selector frame for its tab, so GetBagFrame/GetChecked/
    -- GetCheckedTexture drive the existing spotlight + color machinery unchanged.
    return "TFuBnkTabBtn"..bag;
  else
    return "INVALID";
  end
end

function TFuBag:GetDummyBagFrameName(bag)
  if (bag == BACKPACK_CONTAINER) then
    return "TFuInvainerFrame12";
  elseif (bag == BANK_CONTAINER) then
    return "TFuBnkainerFrame4";
  elseif (bag == REAGENTBANK_CONTAINER) then
    return "TFuBnkainerFrame3";
  elseif self:Member(self.Inv_Bags, bag) then
    return "TFuInvainerFrame"..(bag);
  elseif self:Member(self.Bnk_Bags, bag) then
    return "TFuBnkainerFrame"..(bag);
  else
    return "INVALID";
  end
end

function TFuBag:GetBagItemButtonName(bag, slot)
  return self:GetDummyBagFrameName(bag).."Item"..slot;
end

function TFuBag:GetBagIdxName(bag)
  if (bag == BANK_CONTAINER) then
    return "Bank";
  elseif (bag == REAGENTBANK_CONTAINER) then
    return "ReagentBank";
  else
    return tostring(bag);
  end
end

function TFuBag:GetBagNumName(bag)
  -- Use the stock frame for the counts on the bag buttons
  return self:GetBagFrameName(bag).."Stock"
end

function TFuBag:GetBagFrameTexture(bag)
  if (bag >= self.BAGMIN) and (bag <= self.BAGMAX) then
    return _G[self:GetBagFrameName(bag).."IconTexture"];
  else
    return nil;
  end
end

function TFuBag:GetBagFrameSpotlight(bag)
  if (bag >= self.BAGMIN) and (bag <= self.BAGMAX) then
    return _G[self:GetBagFrameName(bag).."SpotlightTexture"];
  else
    return nil;
  end
end

--function TFuBag:GetBagFrameHighlight(bag)
--  if (bag >= self.BAGMIN) and (bag <= self.BAGMAX) then
--    return _G[self:GetBagFrameName(bag).."HighlightFrameTexture"];
--  else
--    return nil;
--  end
--end


function TFuBag:GetBagFrame(bag)
  if (bag >= self.BAGMIN) and (bag <= self.BAGMAX) then
    return _G[self:GetBagFrameName(bag)];
  else
    return nil;
  end
end

function TFuBag:GetBagNumFrame(bag)
  return _G[self:GetBagNumName(bag)];
end

function TFuBag:GetBagMaxItems(bag)
  if bag == REAGENTBANK_CONTAINER then
    return self.MAX_REAGENTBANK_ITEMS
  end
  -- 12.0 bank tabs hold 98 slots; the 50-slot MAX_CONTAINER_ITEMS cap would
  -- leave slots 51-98 with no item-button frames (items there never render).
  if self:IsBankTab(bag) then
    return self.MAX_BANKTAB_ITEMS
  end
  return MAX_CONTAINER_ITEMS
end

function TFuBag:MakeHyperlink(itemstring,name,quality,level,suffix)
  local itemlink;
  -- First try to generate the itemlink off TFuBag's cached data.
  -- If we don't have the info to do it then fall back on GetItemInfo().
  -- GetItemInfo() can still fail but it's better than nothing.
  if (name) and (itemstring) and (quality) then
    quality = tonumber(quality);
    local _,_,_,color = GetItemQualityColor(quality);

    if itemstring:sub(1,5) == "item:" then
      -- item links now include the level of the linker in Wrath.
      if level then
        itemstring = itemstring..":"..level
      else
        -- failsafe in case level isn't passed through.
        itemstring = itemstring..":"..UnitLevel("player")
      end
      if suffix then
        itemstring = itemstring..":"..suffix
      end
    end
    itemlink = "|c"..color.."|H"..itemstring.."|h["..name.."]|h|r";
  elseif (itemstring) then
    _,itemlink = GetItemInfo(itemstring);
  end
  return itemlink;
end


function TFuBag:SetRarityColor(rarity, name)
  local bkgr = _G[name.."_bkgr"];
  local normal = _G[name.."NormalTexture"];
  if (rarity) then
    local r, g, b = GetItemQualityColor(rarity);

    bkgr:SetVertexColor(r, g, b, 1);
    normal:SetVertexColor(r, g, b, 0.5);
  else
    bkgr:SetVertexColor(0.05,0.05,0.05,1);
    normal:SetVertexColor(0.05,0.05,0.05, 0.5);
  end
end

function TFuBag:MakeEven(bkgr, bf)
  bkgr = math.floor(bkgr);
  if ((bkgr - bf)/2) ~= ((bkgr - bf)/2) then
    bkgr = bkgr-1;
  end
  return bkgr;
end

function TFuBag:Member(arr, ele)
  local val;
  if (arr) then
    for _, val in ipairs(arr) do
      if (val == ele) then return 1; end
    end
  else
     self:Print("ele = "..ele);
  end
  return nil;
end

-----------------------------------------------------------------------
-- Bag Counts
-----------------------------------------------------------------------

function TFuBag:GetSlotInfo(playerid, bag)
  local size = 0;
  local free = 0;
  local item;

  -- Refresh the cache if we are the current player, or at a bank
  if (playerid == self.PLAYERID) then
    if (TFuBnkFrame.atbank == 1) or self:Member(self.Inv_Bags, bag) then
      size = GetContainerNumSlots(bag);
      if bag == REAGENTBANK_CONTAINER and not IsReagentBankUnlocked() then
        -- Game always shows the full size of the ReagentBank even if not unlocked
        size = 0
      end
--    self:Print("b="..bag..", size="..size);
      for i=1, size do
        local _
        _, item = GetContainerItemInfo(bag, i);
        if (not item) then
          free = free + 1;
        end
      end
      -- Save the info to the cache
      self:SetPlayerBagCfg(playerid, bag, self.I_BAGFREE, free);
      self:SetPlayerBagCfg(playerid, bag, self.I_BAGSIZE, size);
    end
  end
  -- Get the info from the cache always
  free = self:GetPlayerBagCfg(playerid, bag, self.I_BAGFREE);
  size = self:GetPlayerBagCfg(playerid, bag, self.I_BAGSIZE);

  if (free == nil) then free = 0; end
  if (size == nil) then size = 0; end

  return free, size;
end


function TFuBag:GetNumBankSlots(playerid)
  local numSlots, full = GetNumBankSlots();
  if (playerid == self.PLAYERID) and (TFuBnkFrame.atbank == 1) then
    self:SetPlayerInfo(playerid, self.S_BANKSLOTS, numSlots);
    if (full) then
      self:SetPlayerInfo(playerid, self.S_BANKFULL, 1);
    else
      self:SetPlayerInfo(playerid, self.S_BANKFULL, 0);
    end
  end
  -- Always fetch from the cache
  numSlots = self:GetPlayerInfo(playerid, self.S_BANKSLOTS);
  full = self:GetPlayerInfo(playerid, self.S_BANKFULL);

  -- Make safe values, just in case
  if (numSlots == nil) then numSlots = 0; end
  if (full ~= nil) and (full == 0) then
    full = nil;
  end

  return numSlots, full;
end

function TFuBag:GetMoney(playerid)
  local money;
  if (playerid == self.PLAYERID) then
    money = GetMoney();
    -- Update the cache.
    self:SetPlayerInfo(playerid, self.S_MONEY, money);
  else
    -- Not the current player so fetch from the cache.
    money = self:GetPlayerInfo(playerid, self.S_MONEY);
  end

  if (money == nil) then money = 0; end
  return money;
end

function TFuBag:MakeFreeString(free, size, showsize)
  if (size <= 0) then return ""; end
  if (showsize == 1) then
    return tostring(free).."|n"..tostring(size);
  else
    return tostring(free);
  end
end

function TFuBag:SetFreeStr(obj, free, size, showsize)
  -- 12.0 bank: warband tabs have no per-tab selector/count frame yet (Stage 2),
  -- so the count target can be nil -- skip silently.
  if (not obj) then return; end
  obj:SetText(self:MakeFreeString(free, size, showsize));
  if (size <= 0) then
    obj:SetTextColor(1,1,1,1);
  else
    local c = free/size;
    if (c <= 0.5) then
      obj:SetTextColor(1,4*c^2,0,1);
    else
      obj:SetTextColor(4*(1-c)^2,1,0,1);
    end
  end
end

function TFuBag:UpdateSlots(playerid, bag, showsize)
  local free, size = self:GetSlotInfo(playerid, bag);
--  self:Print(playerid..", b="..bag..", "..free.."/"..size..", AT="..TFuBnkFrame.atbank);

  self:SetFreeStr(self:GetBagNumFrame(bag), free, size, showsize);

  return free, size;
end


-----------------------------------------------------------------------
-- Colors
-----------------------------------------------------------------------

function TFuBag:ColorArr(r, g, b, a)
  local c = {};
  c["r"] = r;
  c["g"] = g;
  c["b"] = b;
  c["a"] = a;
  return c;
end

function TFuBag:SplitColor(c)
  local r, g, b, a;
  r = self:GetSafeVal(c, "r", 0);
  g = self:GetSafeVal(c, "g", 0);
  b = self:GetSafeVal(c, "b", 0);
  a = self:GetSafeVal(c, "a", 0);
  return r, g, b, a;
end


function TFuBag:SetColor(cfg, colorname, r, g, b, a, reset)
  if ((cfg ~= nil) and (colorname ~= nil)) then
    if (cfg[self.COLORS] == nil) then
      cfg[self.COLORS] = {};
      cfg[self.COLORS][colorname] = self:ColorArr(r, g, b, a);
    elseif (cfg[self.COLORS][colorname] == nil) then
      cfg[self.COLORS][colorname] = self:ColorArr(r, g, b, a);
    else
      if (reset == 1) then
        cfg[self.COLORS][colorname] = self:ColorArr(r, g, b, a);
      end
    end
  end
end

function TFuBag:GetColor(cfg, colorname)
  if ((cfg ~= nil) and (colorname ~= nil)) then
    if (cfg[self.COLORS] == nil) then
      cfg[self.COLORS] = {};
      return 0, 0, 0, 0;
    end
    return self:SplitColor(cfg[self.COLORS][colorname]);
  end
  return 0, 0, 0, 0;
end


function TFuBag:ColorFrame(cfg, barframe, bar)
  local r, g, b, a = self:GetColor(cfg, "bkgr_"..bar)
  barframe:SetBackdropColor(r, g, b, a);
  r, g, b, a = self:GetColor(cfg, "brdr_"..bar)
  barframe:SetBackdropBorderColor(r, g, b, a);
end

function TFuBag:ColorFont(cfg, stock, font, colorname)
  local r, g, b, a = self:GetColor(cfg, colorname)

  stock:SetTextColor(r, g, b);
  font:SetVertexColor(r, g, b, a);
end

function TFuBag.SetColorFunc(prev)
  local r, g, b, opacity

  if prev then
    -- cancelFunc receives ColorPickerFrame.previousValues = {r,g,b,a} (12.0 uses
    -- the key "a", not "opacity").
    r, g, b, opacity = prev.r, prev.g, prev.b, (prev.a or prev.opacity)
  else
    -- 12.0: OpacitySliderFrame was removed in the ColorPickerFrame rework; alpha
    -- now comes from ColorPickerFrame:GetColorAlpha().
    r, g, b = ColorPickerFrame:GetColorRGB()
    opacity = ColorPickerFrame:GetColorAlpha()
  end

  local value = UIDROPDOWNMENU_MENU_VALUE
  if value then
    if r and g and b and opacity then
      TFuBag:SetColor(value.cfg, value.colorname, r, g, b, opacity, 1)
      value.updatefunc()
    end
  end
end

function TFuBag:MakeColorPickerInfo(cfg, colorkind, bar, titletext, updatefunc)
  local r, g, b, a = self:GetColor(cfg, colorkind..bar);
  return {
      ["text"] = titletext,
      ["hasColorSwatch"] = 1,
      ["hasOpacity"] = 1,
      ["r"] = r,
      ["g"] = g,
      ["b"] = b,
      ["opacity"] = a,
      ["notClickable"] = 1,
      ["value"] = {
        [self.I_BAR] = bar, ["colorname"] = colorkind..bar, ["cfg"] = cfg,
        ["updatefunc"] = updatefunc
      },
      ["swatchFunc"] = TFuBag.SetColorFunc,
      ["cancelFunc"] = TFuBag.SetColorFunc,
      ["opacityFunc"] = TFuBag.SetColorFunc
  };
end

function TFuBag:ResetBarColors(cfg)
  local r, g, b, a = self:GetColor(cfg, "bkgr_"..self.MAIN_BAR);
  local rr, rg, rb, ra = self:GetColor(cfg, "brdr_"..self.MAIN_BAR);

  for i = 1, self.BAR_MAX do
    self:SetColor(cfg, "bkgr_"..i, r, g, b, a, 1);
    self:SetColor(cfg, "brdr_"..i, rr, rg, rb, ra, 1);
  end
end

-- Lightweight bar recolor: re-apply background/border colors to the already-laid-out
-- bar frames (and bag spotlight colors) WITHOUT a full UpdateWindow (no rescan /
-- resort / relayout). Used as the color picker's live callback so dragging the color
-- or opacity slider doesn't rebuild the whole (large) bank window on every tick.
function TFuBag:RecolorWindow(frame)
  if (not frame) then return; end
  local cfg = frame.cfg;
  local framename = frame:GetName();
  for bar = 1, self.BAR_MAX do
    local bf = _G[framename.."_bar_"..bar];
    if (bf and bf.SetBackdropColor) then
      self:ColorFrame(cfg, bf, bar);
    end
  end
  self:UpdateButtonHighlights();
end

function TFuBag:UpdateBagColors(bag)
  -- 12.0 bank: a bank tab may have no selector button frame yet (Stage 2) -- skip.
  local frame = self:GetBagFrame(bag);
  if (not frame) then return; end
  local r, g, b, a = self:GetColor(self:GetCfgFromBag(bag), "bag_"..bag);
  -- 12.0 bank tab selector buttons paint a crisp solid edge frame (full alpha) when
  -- selected, cleared when not -- not a soft checked-texture fill. See Bank:GetTabButton.
  if (frame.tfuEdges) then
    local on = frame:GetChecked();
    for _, e in ipairs(frame.tfuEdges) do
      if (on) then e:SetColorTexture(r, g, b, 1); else e:SetColorTexture(0, 0, 0, 0); end
    end
    return;
  end
  local chk = frame.GetCheckedTexture and frame:GetCheckedTexture();
  if (chk) then chk:SetVertexColor(r, g, b, a); end
end

function TFuBag:GetCfgFromBag(bag)
  -- Find the right config
  if (self:Member(self.Inv_Bags, bag)) then
    return TFuBagCfg["Inv"];
  elseif (self:Member(self.Bnk_Bags, bag)) then
    return TFuBagCfg["Bnk"];
  else
    return nil;
  end
end

function TFuBag:UpdateButtonHighlights()
  local isopen = {};
  local bag, buttonname, itm;
  local texture;

  -- Record each bag's physical open state (used below to auto-show highlights
  -- for bags that are open). The highlight COLOR is resolved per-button from the
  -- bag's owning window cfg (GetCfgFromBag), not a shared bag-indexed table: bag 5
  -- (the reagent bag) is a member of BOTH Inv_Bags and Bnk_Bags, so a single
  -- bag->color table would let the bank's bag_5 color clobber the inventory's
  -- (and vice versa), painting the wrong highlight color.
  for _, bag in ipairs(TFuBag.Inv_Bags) do
    isopen[bag] = IsBagOpen(bag);
  end
  for _, bag in ipairs(TFuBag.Bnk_Bags) do
    isopen[bag] = IsBagOpen(bag);
  end

  -- Then cycle through all the buttons
  for buttonname, itm in pairs(self.BUTTONS) do
    texture = _G[buttonname.."HighlightFrameTexture"];
    if (texture) then
      if (itm and next(itm)) then
        bag = itm[self.I_BAG];
        local cfg = self:GetCfgFromBag(bag);
        local cr, cg, cb, ca = self:GetColor(cfg, "bag_"..bag);
        texture:SetVertexColor(cr, cg, cb, ca);

        local bagframe = self:GetBagFrame(bag)
        if (((bagframe and bagframe:GetChecked()) or isopen[bag]) and (cfg)
          and (cfg["spotlight_open"] == 1)) then
          --and (cfg["show_Bag"..bag] == 1) then
          texture:Show();
        else
          texture:Hide();
        end
      else
        -- Empty button (item moved away / slot cleared): never leave a stale glow.
        -- Previously this branch was skipped, so the spotlight from the departed
        -- item lingered and appeared to "stack".
        texture:Hide();
      end
    end
  end
end

-----------------------------------------------------------------------
-- Collapsed empty-slots indicator + whole-window deposit drop target
-----------------------------------------------------------------------
-- Deposit the held item into a free slot of this window's bags. SortItmCache records
-- the target (frame.dropBag/dropSlot) -- the focused bank tab's first free slot if a
-- single tab is selected, else the first free slot anywhere. Live player only.
-- Deposit the held item into this window's first free slot (for the bank, the focused
-- tab when exactly one is selected). NOT gated on collapse_empty: it backs the
-- whole-window drop, the right-click deposit, and the click-place, all of which must
-- work in BOTH collapse modes. dropBag/dropSlot are set by SortItmCache from this
-- window's (active bank type's) bags, so the destination always matches the view --
-- fixing right-click/drag landing in the wrong bank and the collapse-off "only an
-- empty slot accepts the drop" gap.
function TFuBag:DepositToFreeSlot(frame)
  if (not CursorHasItem()) then return; end
  if (not (frame and frame.cfg)) then return; end
  if (not self:IsLive(frame)) then ClearCursor(); return; end
  if (frame.dropBag and frame.dropSlot) then
    PickupContainerItem(frame.dropBag, frame.dropSlot);
    -- A stack split sets STACKSPLIT, so the PickupContainerItem hook (which just ran,
    -- synchronously) blacklisted this destination slot from auto-stacking -- that skip
    -- otherwise persists until a reload, leaving a deposited split portion un-merged.
    -- Clear it here so the BAG_UPDATE that follows this deposit can auto-stack the slot
    -- with a matching partial stack. (The split SOURCE keeps its skip, so a split kept
    -- in the same bag still won't immediately re-merge.)
    self:SetStackSkip(frame.dropBag, frame.dropSlot, nil);
    self:SetCompSkip(frame.dropBag, frame.dropSlot, nil);
  else
    ClearCursor();
    UIErrorsFrame:AddMessage(ERR_BAG_FULL, 1.0, 0.1, 0.1, 1.0);
  end
end

-- Hidden drop-target holder: wires the WHOLE window (main frame + scroll content) as a
-- deposit drop target so an item dragged onto empty window space deposits into a free
-- slot. The cell itself is never shown -- empty slots are tiled in the dedicated "Empty"
-- box at the bottom of the window, and the bottom-left Total number shows the free count.
function TFuBag:GetFreeSlotsCell(frame)
  if (frame.FreeCell) then return frame.FreeCell; end
  local name = frame:GetName().."_FreeCell";
  local c = CreateFrame("Button", name, frame, "BackdropTemplate");
  c:Hide();

  -- Whole-window drop. OnReceiveDrag fires on the frame under the cursor, so wire the
  -- main frame AND the scroll content frame (which spans the item area). Item buttons
  -- keep their own drop handling. Wired once.
  --
  -- Two drop gestures, two events: a DRAG-and-release fires OnReceiveDrag, but a
  -- CURSOR-carried item (from a stack split, or a right-click pickup) is placed with a
  -- plain LEFT-CLICK -> OnMouseDown, never OnReceiveDrag. Wire OnMouseDown too so split
  -- portions can be deposited onto empty window space (under empty-collapse there are no
  -- empty item buttons to click). DepositToFreeSlot no-ops when the cursor is empty, so
  -- a normal click in the item area is harmless.
  if (not frame.tfuDropWired) then
    -- A drag-release fires OnReceiveDrag; a cursor-carried item (stack split, right-click
    -- pickup) is placed with a plain click -> OnMouseDown. The scroll content covers the
    -- item area and is mouse-enabled (for OnReceiveDrag); a frame with NO OnMouseDown
    -- handler lets a click fall through to the main frame underneath (that is how the
    -- window stays draggable by its body), but adding a handler would swallow it. So
    -- FORWARD the content's mouse to the main frame's own OnMouseDown/DragStop, which
    -- already does deposit-on-cursor-else-drag. Keep OnReceiveDrag on the content for
    -- drag-deposits. DepositToFreeSlot self-guards (no cursor / collapse off -> no-op).
    local function dropHook() TFuBag:DepositToFreeSlot(frame); end
    local function bodyDown(_, button) frame:OnMouseDown(button); end
    local function bodyUp() frame:DragStop(); end
    frame:SetScript("OnReceiveDrag", dropHook);
    local sb = frame.Scroll;
    local sc = sb and sb.ScrollChild;
    local cont = sc and sc.Container;
    -- The ScrollChild / Container hold the bars + item buttons and span the whole item
    -- area. They must be EnableMouse(true) for OnReceiveDrag to fire on the gaps between
    -- item buttons (a SetScript alone is inert on a mouse-disabled frame) -- without this
    -- a drag-release that lands on empty bar space (or anywhere over the inventory, whose
    -- bars sit inside the same content frames) was swallowed, so the deposit only worked
    -- when the cursor happened to be over a real empty item button. Item buttons are
    -- descendants at a higher level, so they still capture their own slot (swap/place).
    if (cont) then
      cont:EnableMouse(true);
      cont:SetScript("OnReceiveDrag", dropHook);
      cont:SetScript("OnMouseDown", bodyDown);
      cont:SetScript("OnMouseUp", bodyUp);
    end
    if (sc) then
      sc:EnableMouse(true);
      sc:SetScript("OnReceiveDrag", dropHook);
      sc:SetScript("OnMouseDown", bodyDown);
      sc:SetScript("OnMouseUp", bodyUp);
    end
    -- The WowScrollBox is the outermost content frame and already handles mouse (wheel /
    -- click propagation). Add a drag-receive so a drop over the viewport (not on a child)
    -- deposits too; leave its OnMouseDown to the framework -- SetPropagateMouseClicks(true)
    -- forwards a body click to the main frame's OnMouseDown (deposit-on-cursor-else-drag).
    if (sb) then
      sb:SetScript("OnReceiveDrag", dropHook);
    end
    frame.tfuDropWired = true;
  end

  frame.FreeCell = c;
  return c;
end

function TFuBag:UpdateFreeSlotsCell(frame)
  if (not frame or not frame.cfg) then return; end
  -- Ensure the whole-window drop target is wired (lives in GetFreeSlotsCell). The cell
  -- itself stays hidden: empty slots are tiled in the dedicated "Empty" box at the bottom
  -- of the window, and the bottom-left Total number shows the free count.
  self:GetFreeSlotsCell(frame):Hide();
end

function TFuBag:MakeColorMenu(cfg, updatefunc, level, bagarr)
  local info, bag;

  info = self:MakeColorPickerInfo(cfg, "bkgr_",
    self.MAIN_BAR, L["Main Background Color"], updatefunc);
  UIDropDownMenu_AddButton(info, level);

  info = self:MakeColorPickerInfo(cfg, "brdr_",
    self.MAIN_BAR, L["Main Border Color"], updatefunc);
  UIDropDownMenu_AddButton(info, level);

  info = { ["disabled"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  info = {
    ["text"] = L["Set Bar Colors to Main Colors"],
    ["value"] = {  },
    ["func"] = function()
      self:ResetBarColors(cfg);
      updatefunc();
    end
  };
  UIDropDownMenu_AddButton(info, level);

  info = { ["disabled"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  for _, bag in ipairs(bagarr) do
    info = self:MakeColorPickerInfo(cfg, "bag_",
      bag, string.format(L["Spotlight for %s"],self:GetBagDispName(bag)), updatefunc);
    UIDropDownMenu_AddButton(info, level);
  end
end

-----------------------------------------------------------------------
-- Tooltip
-----------------------------------------------------------------------

function TFuBag:GetItmFromFrame(butitmmap, frm)
  if frm and type(frm) == "table" then
    if (butitmmap[frm:GetName()] ~= nil) then
      return butitmmap[frm:GetName()];
    elseif (butitmmap[frm:GetParent():GetName()] ~= nil) then
      return butitmmap[frm:GetParent():GetName()];
    end
  end
  return nil;
end

function TFuBag:GetInvSlotID(bag, slot)
  local id;
  if (bag == BANK_CONTAINER) then
    id = BankButtonIDToInvSlotID(slot);
  elseif (bag == REAGENTBANK_CONTAINER) then
    id = ReagentBankButtonIDToInvSlotID(slot);
  elseif (bag >= BACKPACK_CONTAINER) and (bag <= self.BAGMAX) then
    id = 100*bag + slot;  -- ???
  end

--  self:Print("TFuBag:GetInvSlotID = "..id.." for "..bag..", "..slot);
  return id;
end

function TFuBag:UpdateHearth(tt, itemlink, playerid)
  -- Make sure we're looking at a hearthstone on another player if not
  -- we end up doing nothing.  Ruby Slippers count as a hearthstone
  -- as well.
  if (playerid ~= self.PLAYERID and
      (string.match(itemlink,"item:6948:") or
      string.match(itemlink,"item:28585:"))) then
    local hearth;
    if (TFuBagInfo[playerid] and TFuBagInfo[playerid][self.G_BASIC]) then
      hearth = TFuBagInfo[playerid][self.G_BASIC][self.S_HEARTH];
    end
    if (not hearth) then
      hearth = L["<home location>"];
    end
    local repl = string.format(L["%%1%s%%3"],hearth);    local ttname = tt:GetName();

    for i=1, tt:NumLines() do
      local ttleft = _G[ttname.."TextLeft"..i];
      if (ttleft) then        local line = ttleft:GetText();        if (line) then
          local sub,match = string.gsub(line, L["(Use: Returns you to )([^%.]*)(%.)"],repl,1);          if (match == 1) then
            ttleft:SetText(sub);
            tt:Show()
            break;
          end
        end
      end
    end
  end
end

function TFuBag:SetInventoryItem(tt, playerid, itemlink, bag, slot, suffix)
  local hasCooldown, repairCost;

  if itemlink and itemlink:sub(1,10) == "battlepet:" then
    local _, speciesID, level, breedQuality, maxHealth, power, speed, battlePetID = strsplit(":",itemlink)
    BattlePetToolTip_Show(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed))
    return
  end

  -- If we are the current player, it might be safe to set inventory directly
  if (playerid == self.PLAYERID) then
    -- Inventory and being at the bank is always safe
    if (self:Member(self.Inv_Bags, bag) or TFuBnkFrame.atbank == 1) then
      if (bag == BANK_CONTAINER) or (bag == REAGENTBANK_CONTAINER) then
        hasCooldown, repairCost = tt:SetInventoryItem("player", self:GetInvSlotID(bag, slot));
      else
        hasCooldown, repairCost = tt:SetBagItem(bag, slot);
      end
    else
      -- otherwise, just set a link.  Not as good, but safe
      if itemlink and itemlink ~= "" then
        local level = TFuBag:GetPlayerInfo(playerid,TFuBag.G_BASIC)[TFuBag.S_LEVEL] or
                    UnitLevel("player")

        itemlink = itemlink..":"..level..(suffix and ":" or "")..(suffix or "")
      end
      tt:SetHyperlink(itemlink);
      self:UpdateHearth(tt, itemlink, playerid);
    end
  else
    -- Always just set links for other players
    if itemlink and itemlink ~= "" then
      local level = TFuBag:GetPlayerInfo(playerid,TFuBag.G_BASIC)[TFuBag.S_LEVEL] or
                    UnitLevel("player")
      itemlink = itemlink..":"..level..(suffix and ":" or "")..(suffix or "")
    end
    tt:SetHyperlink(itemlink);
    self:UpdateHearth(tt, itemlink, playerid);
  end

  return hasCooldown, repairCost;
end

function TFuBag:MakeToolTipStr(playerid, itemlink, bag, slot, mailitem, attach, suffix)
  local ttname = "TFuBag_tt";
  local tt = TFuBag_tt
  local tooltip = "";
  local hasCooldown, repairCost;

  if itemlink and itemlink:sub(1,10) == "battlepet:" then
    return ""
  end

  if (not tt) then
    -- 12.0: inherit GameTooltipTemplate so the Set* item methods (SetBagItem,
    -- SetInventoryItem, ...) exist on this scanning tooltip. The manual
    -- AddFontStrings is then unnecessary (the template provides the lines).
    tt = CreateFrame("GameTooltip","TFuBag_tt", nil, "GameTooltipTemplate");
  end
  tt:SetOwner(UIParent, "ANCHOR_NONE");  -- this makes sure that tooltip.valid = true
  tt:ClearLines();

  -- Set as much information as we have
  if (itemlink) and (bag) and (slot) then
    hasCooldown, repairCost = self:SetInventoryItem(tt, playerid, itemlink, bag, slot, suffix);
  elseif (itemlink) and (bag) then
    -- Just a bag id means it's a slotid used for scanning inventory items.
    local slotid = bag;
    local _
    _, hasCooldown, repairCost = tt:SetInventoryItem("player", slotid);
  elseif (itemlink) and (mailitem) and (attach) then
    tt:SetInboxItem(mailitem, attach);
  elseif (itemlink) then
    local level = UnitLevel("player")
    itemlink = itemlink..":"..level..(suffix and ":" or "")..(suffix and suffix or "")
    tt:SetHyperlink(itemlink);
  end

  for i=1, tt:NumLines() do
    local ttleft = _G[ttname.."TextLeft"..i];
    if (ttleft) then
      local line = ttleft:GetText();

      if (line) then
        tooltip = tooltip.."\n"..line;
      end
    end
  end

  return tooltip, hasCooldown, repairCost;
end

-----------------------------------------------------------------------
-- Main Sorting
-----------------------------------------------------------------------

function TFuBag:MakeEmptySlot(itm)
  if (itm) then
    itm[self.I_NAME] = L["Empty Slot"];
    itm[self.I_ITEMID] = nil;
    itm[self.I_RARITY] = nil;
    itm[self.I_TYPE] = "";
    itm[self.I_SUBTYPE] = "";
    itm[self.I_EXPANSION] = nil;
    itm[self.I_BINDTYPE] = nil;
    itm[self.I_COUNT] = 0;
    itm[self.I_NEED] = 0;
  end
end

function TFuBag:InsertEmptyInCompArr(ca,itm)
  if (itm == nil or type(itm) ~= "table" or ca == nil) then
    return;
  end
  -- Note that while we aren't told we're working on the current
  -- player it's true since we only update the itmcache and stack
  -- when on the current player.
  local bagtype = self:GetBagType(self.PLAYERID, itm[self.I_BAG]);
  if (bagtype and bagtype > 0) then
    table.insert(ca[self.COMP_EMPTY], itm);
  end
end

function TFuBag:InsertItemInCompArr(ca,itm,id)
  if (itm == nil or type(itm) ~= "table" or ca == nil) then
    return;
  end
  -- Note that while we aren't told we're working on the current
  -- player it's true since we only update the itmcache and stack
  -- when on the current player.
  local bagtype = self:GetBagType(self.PLAYERID, itm[self.I_BAG]);
  if (bagtype == nil or bagtype == 0) then
    local itmfam = 0;
    if (itm[self.I_TYPE] ~= L["Container"]) then
      itmfam = GetItemFamily(itm[self.I_ITEMLINK]);
    end
    -- It's possible to be receiving an item we've never seen before
    -- as a result the itemfamily will not be cached and will end
    -- up being nil.  Assume the item can not go in any special
    -- bags if it's nil then.
    if (itmfam and itmfam > 0) then
      table.insert(ca[self.COMP_ITEM], itm);
    end
  end
end

function TFuBag:InsertStackArr(stackarr,itm,id)
  if (itm == nil or type(itm) ~= "table" or stackarr == nil) then
    return;
  end
  if (itm[self.I_NEED] > 0) then
    -- Check that we aren't on the skip list
    if (self:GetStackSkip(itm[self.I_BAG], itm[self.I_SLOT]) == nil) then
        self:PrintDEBUG("Stack inserting ("..itm[self.I_BAG]..", "
        ..itm[self.I_SLOT]..") with need="..itm[self.I_NEED]);
      stackarr[id] = stackarr[id] or {};
      table.insert(stackarr[id],itm);
    end
  end
end

local Itm = {};

function TFuBag:CreateItm()
  local itm = Itm;

  for k,_ in pairs(itm) do
    itm[k] = nil;
  end

  return Itm;
end

function TFuBag:GetItmCharges(tooltip)
  return string.match(tooltip, L["(%d+) Charges?"]);
end

function TFuBag:UpdateItmCache(cfg, playerid, itmcache, bagarr, stackarr, comparr, atbank)
--  UpdateAddOnMemoryUsage();
--  self:PrintDEBUG('UpdateItmCache Start Memory = '..tostring(GetAddOnMemoryUsage("TFuBag")));
  local bag, slot;  -- used as "for loop" counters
  local itm;    -- entry that will be written to the cache
  local id;
  local update_suggested = 0;
  local resort_suggested = 0;
  local resort_mandatory = 0;

  -- variables used in outer loop, bag:
  local size;
  local bagtype;

  -- variables used in inner loop, slots:
  local a,b,c,d;

  -- Never update if we are viewing another player's contents
  if (playerid ~= self.PLAYERID) then
    return self.REQ_NONE;
  end

  -- Don't update if we aren't at the bank
  if (atbank) and (atbank ~= 1) then
    return self.REQ_NONE;
  end

  for index, bag in ipairs(bagarr) do
--    if (cfg["show_Bag"..bag] == 1) then
      if (itmcache[bag] == nil) then
        itmcache[bag] = {};
      end

      local _
      _, size = self:GetSlotInfo(playerid, bag);

      -- If a bag decreases in size wipe the keys for the
      -- slots, TFuBag:ClearItmCache() can't do this for us
      -- becuase it doesn't know enough to do it.
      if (size < #itmcache[bag]) then
        resort_mandatory = 1
        for slot = size +1, #itmcache[bag] do
          itmcache[bag][slot] = nil;
        end
      end

      if (size > 0) then
        -- Counting down makes stacking prefer existing stacks
        for slot = size, 1, -1 do
          if (itmcache[bag][slot] == nil) then
            itmcache[bag][slot] = { [self.I_KEYWORD] = {} };
          end
          local tooltip = nil;

          itm = self:CreateItm();

          id = nil; -- Clear our local id that we use to cache the id to avoid extra
                    -- calls to TFuBag:GetItemID().
          itm[self.I_ITEMLINK] = GetContainerItemLink(bag, slot);
          itm[self.I_BAG] = bag;
          itm[self.I_SLOT] = slot;
          -- take items from old position
          itm[self.I_BAR] = itmcache[bag][slot][self.I_BAR];
          itm[self.I_TIMESTAMP] = itmcache[bag][slot][self.I_TIMESTAMP];
          itm[self.I_NEWSTR] = itmcache[bag][slot][self.I_NEWSTR];
          itm[self.I_CAT] = itmcache[bag][slot][self.I_CAT];
          itm[self.I_KEYWORD] = itmcache[bag][slot][self.I_KEYWORD];
          itm[self.I_SOULBOUND] = itmcache[bag][slot][self.I_SOULBOUND];
          itm[self.I_CHARGES] = itmcache[bag][slot][self.I_CHARGES];
          itm[self.I_ACCTBOUND] = itmcache[bag][slot][self.I_ACCTBOUND];
          itm[self.I_LINKSUFFIX] = itmcache[bag][slot][self.I_LINKSUFFIX];

          if (itm[self.I_ITEMLINK] ~= nil) then
            -- there's an item in the bag, let's find out more about it
            itm[self.I_NAME] = self:GetItemName(itm[self.I_ITEMLINK]);
            id, itm[self.I_ITEMLINK], itm[self.I_LINKSUFFIX] = self:GetItemID(itm[self.I_ITEMLINK]);


            local stacksize;
            _, itm[self.I_TYPE], itm[self.I_SUBTYPE], _, _, stacksize, itm[self.I_BINDTYPE], itm[self.I_EXPANSION] = self:GetItemInfo(itm[self.I_ITEMLINK]);
            _, itm[self.I_COUNT], _, itm[self.I_RARITY], itm[self.I_READABLE], _, _, itm[self.I_NOVALUE] = GetContainerItemInfo(bag, slot);
            if (stacksize) then
              itm[self.I_NEED] = stacksize - itm[self.I_COUNT];
            else
              itm[self.I_NEED] = 0;
            end
            itm[self.I_QUEST_ITEM],itm[self.I_QUEST_ID],itm[self.I_QUEST_ACTIVE] = GetContainerItemQuestInfo(bag, slot);

            if (itm[self.I_CHARGES]) then
              -- If the item has cached charges scan the tooltip again.
              -- This is slow so we don't do it unless we've got cached charges
              -- Down below we check the tooltip on every item the first time we
              -- see it.  Since items can't just get charges this allows us
              -- to still update charges without eating a huge performance hit.
              tooltip = self:MakeToolTipStr(playerid, itm[self.I_ITEMLINK], bag, slot, itm[self.I_LINKSUFFIX]);
              itm[self.I_CHARGES] = self:GetItmCharges(tooltip);
            end

          else
            -- no item in bag, set it as empty
            self:MakeEmptySlot(itm);

            -- And always remove it from the stack skip list
            self:SetStackSkip(itm[self.I_BAG], itm[self.I_SLOT], nil);
            self:SetCompSkip(itm[self.I_BAG], itm[self.I_SLOT], nil);

          end


          local showbag = (cfg["show_Bag"..bag] == 1) or TFuBag:IsBankTab(bag)
            or (TFuBag:GetBagFrame(bag) and TFuBag:GetBagFrame(bag):GetChecked());
          if (itm[self.I_BAR] == nil and showbag) then
            resort_mandatory = 1;
          end

          if (itm[self.I_SUBTYPE] == nil) then itm[self.I_SUBTYPE] = ""; end
          if (itm[self.I_NAME] == nil) then itm[self.I_NAME] = ""; end

          if (itm[self.I_ITEMLINK] ~= itmcache[bag][slot][self.I_ITEMLINK]) then
            -- the item changed
            -- The slot's content changed: drop its categorization stamp so the
            -- next sort re-runs PickBar for just this slot (see catGen memo above).
            self:SetCatStamp(playerid, bag, slot, nil)
            if (itm[self.I_TIMESTAMP] ~= nil) then
              if (cfg["show_Bag"..bag] == 1 or TFuBag:IsBankTab(bag)
                  or (TFuBag:GetBagFrame(bag) and TFuBag:GetBagFrame(bag):GetChecked())) then
                -- A real item move into/out of (or swap within) a shown slot must
                -- re-categorize NOW: REQ_MUST forces SortItmCache + LayoutWindow on
                -- this same BAG_UPDATE. The old REQ_PART ("suggested") only stashed
                -- CACHE_REQ and deferred the resort, so under empty-collapse the moved
                -- item landed in a slot the layout still treated as empty (pulled out
                -- of the bars) and stayed invisible until a full reopen. This branch
                -- only fires when the link actually changed AND a prior timestamp
                -- existed (an observed move), so warm-cache reopens stay REQ_NONE -- no
                -- return of the per-open bank lag.
                resort_mandatory = 1;
              end
              itm[self.I_TIMESTAMP] = time();
              itm[self.I_NEWSTR] = self.V_NEWON;
              self.FORCED_SHOW[self:BagSlotToString(itm[self.I_BAG],itm[self.I_SLOT])] = true
            end
            if (not tooltip) then
              -- Haven't already made it so make it now.
              tooltip = self:MakeToolTipStr(playerid, itm[self.I_ITEMLINK], bag, slot, itm[self.I_LINKSUFFIX]);
            end
            if (string.find(tooltip, L["Soulbound"])) then
              itm[self.I_SOULBOUND] = 1;
            else
              itm[self.I_SOULBOUND] = 0
            end
            if (string.find(tooltip, L["Account Bound"])) then
              itm[self.I_ACCTBOUND] = true
            else
              itm[self.I_ACCTBOUND] = false
            end
            -- PROFESSIONS_USED_IN_COOKING resolves to "Crafting Reagent" in English
            -- It's a strange name for the constant but it used to be "Cooking Ingredenient" and
            -- they broadended it without changing the constant name.
            if (string.find(tooltip, PROFESSIONS_USED_IN_COOKING)) then
              itm[self.I_CRAFTINGREAGENT] = true
            else
              itm[self.I_CRAFTINGREAGENT] = false
            end
            itm[self.I_CHARGES] = self:GetItmCharges(tooltip);
          else
            -- item has not changed, maybe the count did?
            if ( (itm[self.I_COUNT] ~= itmcache[bag][slot][self.I_COUNT]) and (itmcache[bag][slot][self.I_COUNT] ~= nil) ) then
              update_suggested = 1;
              if (itm[self.I_COUNT] < itmcache[bag][slot][self.I_COUNT]) then
                itm[self.I_NEWSTR] = self.V_NEWMINUS;
              else
                itm[self.I_NEWSTR] = self.V_NEWPLUS;
              end
              itm[self.I_TIMESTAMP] = time();
            end
          end

          if (itm[self.I_TIMESTAMP] == nil) then
            self:ResetNew(itm);
          end

          -- wipe old keys first
          for k,_ in pairs(itmcache[bag][slot]) do
            itmcache[bag][slot][k] = nil;
          end
          -- copy the new data over
          for k,v in pairs(itm) do
            itmcache[bag][slot][k] = v;
          end

          -- Put on the stack array if we need more to stack
          self:InsertStackArr(stackarr,itmcache[bag][slot],id);

          if (itm[self.I_ITEMLINK] ~= nil) then
            -- Items not in a special bag but that can go into one need to be
            -- added to the specitems table.
            self:InsertItemInCompArr(comparr,itmcache[bag][slot],id);
          else
            -- Empty slots in special bags need to be added to the
            -- compress arg.
            self:InsertEmptyInCompArr(comparr,itmcache[bag][slot]);
          end
        end
      else
        -- size = 0, make sure you wipe the cache entry
        if (table.getn(itmcache[bag]) ~= 0) then
          resort_mandatory = 1;
        end
        for k,_ in pairs(itmcache[bag]) do
          itmcache[bag][k] = nil;
        end
      end
  end

--  UpdateAddOnMemoryUsage();
--  self:PrintDEBUG('UpdateItmCache End Memory = '..tostring(GetAddOnMemoryUsage("TFuBag")));
  if (resort_mandatory == 1) then
    return self.REQ_MUST;
  elseif (resort_suggested == 1) then
    return self.REQ_PART;
  else
    return self.REQ_NONE;
  end
end


-- Categorization memo (perf). PickBar runs a per-item tooltip scan, the dominant
-- cost of a re-sort; over a full bank (hundreds of items) doing it for every item
-- on every BAG_UPDATE is what made item moves / Deposit All lag. catGen is a
-- generation counter bumped only when categorization INPUTS change (category
-- config, search list, professions -- every such path forces an explicit
-- UpdateWindow(REQ_MUST); see Inv/Bank:UpdateWindow). Each slot is stamped with
-- the gen it was categorized at; SortItmCache re-runs PickBar only when the stamp
-- is stale (config changed) or the slot's item changed (stamp cleared in
-- UpdateItmCache on a link change). A plain item move thus re-categorizes only the
-- slots that actually changed, not the whole bank. The stamp table is runtime-only
-- (NOT saved) so it can never collide with a value persisted from a past session.
TFuBag.catGen = TFuBag.catGen or 0
TFuBag.catStamp = TFuBag.catStamp or {}

function TFuBag:BumpCatGen()
  self.catGen = (self.catGen or 0) + 1
end

function TFuBag:GetCatStamp(playerid, bag, slot)
  local p = self.catStamp[playerid]; if (not p) then return nil end
  local b = p[bag]; if (not b) then return nil end
  return b[slot]
end

function TFuBag:SetCatStamp(playerid, bag, slot, gen)
  local p = self.catStamp[playerid]
  if (not p) then p = {}; self.catStamp[playerid] = p end
  local b = p[bag]
  if (not b) then b = {}; p[bag] = b end
  b[slot] = gen
end

function TFuBag:SortItmCache(cfg, playerid, itmcache, baritm, bagarr)
--  UpdateAddOnMemoryUsage();
--  self:PrintDEBUG('SortItmCache Start Memory = '..tostring(GetAddOnMemoryUsage("TFuBag")));

  local i;
  local bag, slot;  -- variables used in outer loop
  local size;
  -- variables used in inner loop
  ----- 2nd loop
  local barnum;
  local trade1, trade2 = self.Professions:GetTwoProfessions(playerid);

  -- wipe the forced show table
  for key,_ in pairs (self.FORCED_SHOW) do
    self.FORCED_SHOW[key] = nil
  end

  -- wipe the current bar positions table
  for bar = 1, self.BAR_MAX do
    baritm[bar] = baritm[bar] or {};
    local bartab = baritm[bar];
    for pos,_ in pairs(bartab) do
      bartab[pos] = nil;
    end
  end

  -- Empty slots are their own category: collected into the dedicated EMPTY_BAR, which
  -- LayoutWindow draws as ONE box at the very BOTTOM of the window (instead of tiling
  -- mid-window in their per-bag category). We also tally the free-slot count and a
  -- deposit target for the whole-window drop (TFuBag:DepositToFreeSlot); in the bank, a
  -- single selected tab routes deposits straight into that tab. (collapse_empty is now
  -- inert -- empties always use the dedicated box.) The owning frame is resolved from cfg.
  -- collapse_empty ON collapses the box to ONE representative empty button (+ free count);
  -- OFF tiles every empty slot. Either way the box is drawn at the bottom by LayoutWindow.
  local collapse = (cfg["collapse_empty"] == 1)
  local frame = (TFuBnkFrame and cfg == TFuBnkFrame.cfg) and TFuBnkFrame
    or ((TFuInvFrame and cfg == TFuInvFrame.cfg) and TFuInvFrame or nil)
  local soloTab = nil
  if (frame == TFuBnkFrame and TFuBnkFrame.tabSel) then
    local n, only = 0, nil
    for b, v in pairs(TFuBnkFrame.tabSel) do if (v) then n = n + 1; only = b; end end
    if (n == 1) then soloTab = only; end
  end
  local freeCount = 0
  local firstBag, firstSlot = nil, nil   -- first free slot anywhere in the view
  local soloBag, soloSlot = nil, nil     -- first free slot in the focused bank tab

  for _, bag in ipairs(bagarr) do
--    self:PrintDEBUG("TFuBag:MakeBarItm: bag ="..bag);
    if itmcache[bag] == nil then
      return baritm;
    end

    if (cfg["show_Bag"..bag] == 1 or TFuBag:IsBankTab(bag)
        or (TFuBag:GetBagFrame(bag) and TFuBag:GetBagFrame(bag):GetChecked())) then
      size = table.getn(itmcache[bag]);
      if (size > 0) then
--        self:PrintDEBUG("Show bag "..bag);
        for slot = 1, size do
          if next(itmcache[bag][slot]) then
            local itm = itmcache[bag][slot];
            -- Only re-categorize (the expensive tooltip scan) when this slot's
            -- stamp is stale: config changed (catGen bumped) or the item changed
            -- (stamp cleared in UpdateItmCache). Unchanged items keep their cached
            -- I_BAR/I_CAT, collapsing a full-bank re-sort to just the moved slots.
            if (self:GetCatStamp(playerid, bag, slot) ~= self.catGen) then
              itm = self:PickBar(cfg, playerid, itm, trade1, trade2);
              self:SetCatStamp(playerid, bag, slot, self.catGen);
              itmcache[bag][slot] = itm;
            end
            local destbar = itm[self.I_BAR];
            local isEmpty = (not itm[self.I_ITEMLINK] or itm[self.I_ITEMLINK] == "");
            if (isEmpty) then
              -- Tally + remember free slots for the empty-slot widget and the deposit
              -- target. The target follows the currently-VIEWED bank (bagarr only spans
              -- the active bankType's bags, so firstBag/soloBag resolve to that bank --
              -- char vs warband -- automatically).
              freeCount = freeCount + 1;
              if (not firstBag) then firstBag = bag; firstSlot = itm[self.I_SLOT]; end
              if (soloTab and bag == soloTab and not soloBag) then
                soloBag = bag; soloSlot = itm[self.I_SLOT];
              end
            end
            if (isEmpty) then
              -- Empties go to the dedicated EMPTY_BAR (one box, drawn at the bottom).
              -- collapse_empty OFF: tile every empty here. ON: insert nothing now -- a
              -- single representative is added after the loop (collapse-to-one-button).
              -- An active item filter hides empties (PassesItemFilter is false then).
              if (not collapse and self:PassesItemFilter(frame, itm)) then
                table.insert(baritm[self.EMPTY_BAR], itm);
              end
            elseif (type(destbar) == "number" and baritm[destbar]) then
              -- Only place items whose category resolved to a real bar, and that
              -- pass the active item filter. A filtered-out item gets no slot, so
              -- LayoutWindow reflows the survivors with no gaps.
              if (self:PassesItemFilter(frame, itm)) then
                table.insert(baritm[destbar], itm);
              end
            end
          end
        end
      end
    end
  end

  if (frame) then
    frame.freeSlots = freeCount;
    -- Deposit target: the focused tab's first free slot when exactly one tab is
    -- selected, else the first free slot anywhere in the view.
    frame.dropBag  = soloBag or firstBag;
    frame.dropSlot = soloSlot or firstSlot;
    -- Collapse-to-one-button: put a SINGLE representative empty (the deposit-target slot)
    -- into the bottom Empty box; ItemButton.Update hides all other empties and shows the
    -- free count on this one. Tiled mode (collapse off) added them in the loop above.
    frame._emptyRep = nil;
    if (collapse and frame.dropBag and itmcache[frame.dropBag]) then
      local repItm = itmcache[frame.dropBag][frame.dropSlot];
      if (repItm and self:PassesItemFilter(frame, repItm)) then
        table.insert(baritm[self.EMPTY_BAR], repItm);
        frame._emptyRep = { bag = frame.dropBag, slot = frame.dropSlot };
      end
    end
  end

  -- sort the cache now
  for barnum = 1, self.BAR_MAX do
    local toggle;

    if (self:GetGrp(cfg, self.G_BAR_SORT, barnum) == self.SORTBY_NORM) then
      toggle=1;
    elseif (self:GetGrp(cfg, self.G_BAR_SORT, barnum) == self.SORTBY_REV) then
      toggle=2;
    end

    if (toggle==1 or toggle==2) then
      table.sort(baritm[barnum],
        function(a,b) return
          a[TFuBag.I_CAT]..
          TFuBag:ReverseString(a[TFuBag.I_NAME],toggle)..
          string.format("%04s",a[TFuBag.I_COUNT])..string.format("%02s",a[TFuBag.I_SLOT])

          >
          b[TFuBag.I_CAT]..
          TFuBag:ReverseString(b[TFuBag.I_NAME],toggle)..
          string.format("%04s",b[TFuBag.I_COUNT])..string.format("%02s",b[TFuBag.I_SLOT])
        end
      );
    end
  end
--  UpdateAddOnMemoryUsage();
--  self:PrintDEBUG('SortItmCache End Memory = '..tostring(GetAddOnMemoryUsage("TFuBag")));
  return baritm;
end


function TFuBag:SetBarFromClass(cfg, itm)
  itm[self.I_BAR] = self:GetCat(cfg, itm[self.I_CAT]);
  while ((itm[self.I_BAR] ~= nil) and type(itm[self.I_BAR]) ~= "number") do
    itm[self.I_BAR] = self:GetCat(cfg, itm[self.I_BAR]);
  end
  return itm[self.I_BAR];
end


function TFuBag:PickBar(cfg, playerid, itm, trade1, trade2)
  local bagtype = self:GetBagType(playerid, itm[self.I_BAG]);
  if (itm[self.I_ITEMLINK] == nil) then
    if (bagtype and type(bagtype) == "number" and bagtype > 0) then
      itm[self.I_CAT] = string.format(L["EMPTY_%s_SLOTS"],self:GetBagTypeName(bagtype));
    elseif (bagtype and type(bagtype) == "string" and bagtype ~= "") then
      -- Support old style string bagtypes since our cache may still have some.
      itm[self.I_CAT] = string.format(L["EMPTY_%s_SLOTS"],bagtype);
    elseif (bagtype and type(bagtype) == "string" and bagtype ~= "") then

    else
      itm[self.I_CAT] = string.format(L["EMPTY_%s_SLOTS"],
                                      self:GetBagPosName(itm[self.I_BAG]));
    end
    self:SetBarFromClass(cfg, itm);
    return itm;
  else
  -- vars used in tooltip creation
  local tooltip;
  -- vars used in array loops
  local key, value;
  local found;

  -- Fetch the items id
  local itemid = self:GetItemID(itm[self.I_ITEMLINK]);

  -- reset item keywords
  if (bagtype and ((type(bagtype) == number and bagtype > 0) or
      (type(bagtype) == "string" and bagtype ~= ""))) then
    if (cfg["special_bag_sort"] == 1) then
      if (type(bagtype) == "number") then
        itm[self.I_CAT] = string.format(L["IN_%s_BAG"],self:GetBagTypeName(bagtype));
      else
        -- Support for old style string bag types.
        itm[self.I_CAT] = string.format(L["IN_%s_BAG"],bagtype);
      end

      itm[self.I_KEYWORD] = {
        [itm[self.I_CAT]] = 1,  -- this indicates that the special bag isn't empty
      };
      self:SetBarFromClass(cfg, itm);
      return itm;
    end
  end

  itm[self.I_KEYWORD] = itm[self.I_KEYWORD] or {};
  for k,_ in pairs(itm[self.I_KEYWORD]) do
    itm[self.I_KEYWORD][k] = nil;
  end

  if (itm[self.I_RARITY] ~= nil) then
    itm[self.I_KEYWORD][self.S_RARITY..itm[self.I_RARITY]] = 1;
  end

  self.Professions:MakeAllTradeKeywords(itm, cfg["trade_created_sort"], trade1, trade2);

  if (trade1 ~= "") then
    self:SetCatBar(cfg, self:Cat(trade1), L["TRADE1"], 1);
    if (cfg["trade_created_sort"] == 1) then
      self:SetCatBar(cfg, string.format(L["%s_CREATED"],self:Cat(trade1)),
                     string.format(L["%s_CREATED"],L["TRADE1"]), 1);
    else
      self:SetCatBar(cfg, string.format(L["%s_CREATED"],self:Cat(trade1)), nil, 1);
    end
  end
  if (trade2 ~= "") then
    self:SetCatBar(cfg, self:Cat(trade2), L["TRADE2"], 1);
    if (cfg["trade_created_sort"] == 1) then
      self:SetCatBar(cfg, string.format(L["%s_CREATED"],self:Cat(trade2)),
                     string.format(L["%s_CREATED"],L["TRADE2"]), 1);
    else
      self:SetCatBar(cfg, string.format(L["%s_CREATED"],self:Cat(trade2)), nil, 1);
    end
  end

  if (itm[self.I_SOULBOUND] == 1) then
    itm[self.I_KEYWORD][L["SOULBOUND"]] = 1;
  elseif (itm[self.I_ACCTBOUND]) then
    itm[self.I_KEYWORD][L["ACCOUNTBOUND"]] = 1;
  end

  if (itm[self.I_CRAFTINGREAGENT] == 1) then
    itm[self.I_KEYWORD][L["CRAFTINGREAGENT"]] = 1;
  end

  -- (EQUIPPED keyword wiring removed with the EQUIPPED_* categories.)

  -- Load tooltip
  tooltip = self:MakeToolTipStr(playerid, itm[self.I_ITEMLINK], itm[self.I_BAG], itm[self.I_SLOT], itm[self.I_LINKSUFFIX]);

  -- self:PrintDEBUG("Tooltip Text: "..tooltip);

  itm[self.I_CAT] = nil;

  -- step 1, check item overrides
  itm[self.I_CAT] = cfg["item_overrides"][itemid];
  if (itm[self.I_CAT] ~= nil) then
    itm[self.I_BAR] = self:GetCat(cfg, itm[self.I_CAT]);
    while ( (itm[self.I_BAR] ~= nil) and (type(itm[self.I_BAR]) ~= "number") ) do
    itm[self.I_BAR] = self:GetCat(cfg, itm[self.I_BAR]);
    end
    if (type(itm[self.I_BAR]) ~= "number") then
    itm[self.I_CAT] = nil;
    end
  end

  -- step 1.5, configurable material grouping. Trade goods route to the group
  -- category assigned to their subtype in cfg.mat_group (default: each subtype to
  -- its own per-material category). This supersedes the static per-material rules
  -- and the psplit profession split for trade goods, and is what the Categories
  -- options panel edits. Subtypes with no mapping (or whose group has no bar yet)
  -- fall through to the search list / Trade Goods catch-all below.
  if (itm[self.I_CAT] == nil and cfg.mat_group and itm[self.I_TYPE] == self.LOCALE["Tradeskill"]) then
    local grp = cfg.mat_group[itm[self.I_SUBTYPE]];
    if (grp and grp ~= "") then
      itm[self.I_CAT] = grp;
      itm[self.I_BAR] = self:GetCat(cfg, grp);
      while ((itm[self.I_BAR] ~= nil) and (type(itm[self.I_BAR]) ~= "number")) do
        itm[self.I_BAR] = self:GetCat(cfg, itm[self.I_BAR]);
      end
      if (type(itm[self.I_BAR]) ~= "number") then itm[self.I_CAT] = nil; end
    end
  end

  if (itm[self.I_CAT] == nil) then
    for i = 1, table.getn(cfg["item_search_list"]) do
      local value = cfg["item_search_list"][i];
      -- "psplit" rules are the optional per-profession reagent/trade-good split;
      -- skip them unless reagent_split is enabled (see DefaultSearchList).
      -- value.off = the rule is disabled (Categories panel Enabled checkbox);
      -- skip it so its items fall through to the next matching rule.
      if (value[1] ~= "" and not value.off and not (value[6] == "psplit" and cfg["reagent_split"] ~= 1)) then
        local found = 1;

        -- value[1] == category to place it in

        -- check keywords
        if ( (value[2] ~= "") and (itm[self.I_KEYWORD][value[2]] == nil) ) then
          found = nil;
        end
        -- check tooltip
        if ( (value[3] ~= "") and (not (string.find(tooltip, value[3]))) ) then
          found = nil;
        end
        -- check itemType
        if ( (value[4] ~= "") and (itm[self.I_TYPE] ~= value[4]) ) then
          found = nil;
        end
        -- check itemSubType
        if ( (value[5] ~= "") and (itm[self.I_SUBTYPE] ~= value[5]) ) then
          found = nil;
        end

        if (found) then
          itm[self.I_CAT] = value[1];
          itm[self.I_BAR] = self:GetCat(cfg, itm[self.I_CAT]);
          while ( (itm[self.I_BAR] ~= nil) and (type(itm[self.I_BAR]) ~= "number") ) do
            itm[self.I_BAR] = self:GetCat(cfg, itm[self.I_BAR]);
          end
          if (type(itm[self.I_BAR]) == "number") then
            break;
          else
            itm[self.I_CAT] = nil;
          end
        end
      end
    end
  end

  if (itm[self.I_CAT] == nil) then
    itm[self.I_CAT] = L["UNKNOWN"];

    itm[self.I_BAR] = self:GetCat(cfg, itm[self.I_CAT]);
    while ( (itm[self.I_BAR] ~= nil) and (type(itm[self.I_BAR]) ~= "number") ) do
    itm[self.I_BAR] = self:GetCat(cfg, itm[self.I_BAR]);
    end
    if (type(itm[self.I_BAR]) ~= "number") then
    itm[self.I_CAT] = L["UNKNOWN"];
    itm[self.I_BAR] = 1;
    end
  end

  end
  return itm;
end


-- DIAGNOSTIC (temporary): dump the distinct item class/subclass buckets present
-- in the player's bags. One line per unique (classID, subClassID) pair, with the
-- localized type/subtype strings GetItemInfo would match against (field 4/5 of
-- DefaultSearchList), the numeric enum IDs, a count, and one example item name.
-- Used to author the 12.0 reagent-family category rules against ground truth
-- (the trade-goods subclass enum + localized strings aren't in wow-ui-source).
-- Ground-truth taxonomy dump for the category uplift. Walks EVERY cached item
-- store (all characters) and records, per distinct (classID, subClassID):
--   * the stored I_TYPE / I_SUBTYPE strings -- the exact text the DefaultSearchList
--     rules match against (PickBar: value[4]==I_TYPE, value[5]==I_SUBTYPE)
--   * the canonical GetItemClassInfo / GetItemSubClassInfo strings for that class
--   * which expansionIDs appear, a count, and an example item name
-- The result is both printed (summary) and PERSISTED to TFuBagCfg.__taxonomy so it
-- can be read straight off the SavedVariables file after a /reload or logout. This
-- is the data the uplift needs: it reveals which Legion-era type strings (e.g.
-- "Tradeskill") no longer match what 12.0 returns (e.g. "Trade Goods").
-- Diagnostic: dump each cached item's resolved category + bar, with its type/
-- subtype, so we can see exactly WHERE an item sorts and WHY. Optional arg filters
-- to items whose category OR name contains the (case-insensitive) substring.
-- Invoke with /tinv printcat [filter] (inventory) or /tbnk printcat [filter] (bank).
function TFuBag:PrintCategoryContents(which, filter)
  local cache = (which == "bank") and TFuBnkItm or TFuInvItm;
  local pcache = cache and cache[self.PLAYERID];
  if (not pcache) then self:Print("No "..(which or "inventory").." cache for this character."); return; end
  local frame = (which == "bank") and TFuBnkFrame or TFuInvFrame;
  local cb = frame and frame.cfg and frame.cfg[self.CAT_BAR] or {};
  -- Show which bags the CURRENT view actually renders (the dump itself scans the
  -- whole cache). For the bank this reveals whether the active Character/Warband
  -- view even includes the bag an item lives in.
  if (frame and frame.bags) then
    local bl = {};
    for _, b in ipairs(frame.bags) do bl[#bl + 1] = tostring(b); end
    self:Print("Current view bags: { "..table.concat(bl, ", ").." }"
      ..(frame.bankType and ("  bankType="..tostring(frame.bankType)) or ""));
  end
  -- What the view ACTUALLY placed for rendering (BARITM), vs the cache above.
  if (frame and frame.BARITM) then
    local br = {};
    for bar = 1, self.BAR_MAX do
      local list = frame.BARITM[bar];
      if (list and #list > 0) then br[#br + 1] = bar..":"..#list; end
    end
    self:Print("Rendered bars (bar:count): "..(#br > 0 and table.concat(br, "  ") or "(none)"));
  end
  filter = filter and strtrim(filter);
  if (filter == "") then filter = nil; end
  -- Normalize for matching: lowercase + strip anything non-alphanumeric, so
  -- "Trade Goods", "TRADE_GOODS", and quoted forms all match the same category.
  local function norm(s) return (string.gsub(string.lower(tostring(s)), "[^%a%d]", "")); end
  local fl = filter and norm(filter) or nil;

  -- Bucket every cached item by its resolved category.
  local byCat = {};
  for bag, slots in pairs(pcache) do
    if (type(slots) == "table") then
      for slot, itm in pairs(slots) do
        local link = type(itm) == "table" and itm[self.I_ITEMLINK];
        if (link and link ~= "") then
          local cat = tostring(itm[self.I_CAT]);
          byCat[cat] = byCat[cat] or {};
          local id = tostring(link):match("item:(%d+)") or "?";
          table.insert(byCat[cat], string.format("    %s  [%s / %s]  id=%s bag=%s bar=%s",
            tostring(itm[self.I_NAME]), tostring(itm[self.I_TYPE]),
            tostring(itm[self.I_SUBTYPE]), id, tostring(bag), tostring(itm[self.I_BAR])));
        end
      end
    end
  end

  if (fl) then
    -- Detailed: every item in each category whose NAME contains the filter.
    local hits = 0;
    for cat, list in pairs(byCat) do
      if (string.find(norm(cat), fl, 1, true)) then
        table.sort(list);
        self:Print(string.format("%s  (bar=%s, %d items):", cat, tostring(cb[cat]), #list));
        for _, l in ipairs(list) do self:Print(l); hits = hits + 1; end
      end
    end
    if (hits == 0) then self:Print("No items in a category matching '"..filter.."'. (Run with no filter for the full per-category summary.)"); end
  else
    -- Summary: every known category with its bar + item count (0 = empty, so a
    -- category that is configured but receiving nothing is visible too).
    local seen, names = {}, {};
    for cat in pairs(cb) do if (not seen[cat]) then seen[cat] = true; names[#names + 1] = cat; end end
    for cat in pairs(byCat) do if (not seen[cat]) then seen[cat] = true; names[#names + 1] = cat; end end
    table.sort(names);
    self:Print(string.format("Category summary (%s) -- name : bar : item count:", which or "inventory"));
    for _, cat in ipairs(names) do
      local n = byCat[cat] and #byCat[cat] or 0;
      self:Print(string.format("  %s : bar=%s : %d", cat, tostring(cb[cat]), n));
    end
  end
end

-- Invoke with /tinv printtypes or /tbnk printtypes.
function TFuBag:PrintItemTypes()
  -- 12.0: these live in C_Item (the bare globals are gone).
  local function classInfo(cid)
    if (cid == nil or not C_Item.GetItemClassInfo) then return "?"; end
    return C_Item.GetItemClassInfo(cid) or "?";
  end
  local function subInfo(cid, sid)
    if (cid == nil or sid == nil or not C_Item.GetItemSubClassInfo) then return "?"; end
    return C_Item.GetItemSubClassInfo(cid, sid) or "?";
  end

  local buckets, order = {}, {};
  local function note(link, itype, isubtype, expansion)
    if (not link or link == "") then return; end
    local _, giType, giSub, _, _, classID, subClassID = GetItemInfoInstant(link);
    local key = tostring(classID).."|"..tostring(subClassID);
    local b = buckets[key];
    if (not b) then
      b = { c = classID, s = subClassID,
            t = itype or giType, st = isubtype or giSub,
            cls = classInfo(classID), scls = subInfo(classID, subClassID),
            n = 0, ex = nil, exps = {} };
      buckets[key] = b;
      order[#order + 1] = key;
    end
    b.n = b.n + 1;
    b.ex = (GetItemInfo(link)) or (link:match("%[(.-)%]")) or b.ex or "?";
    if (expansion ~= nil) then b.exps[expansion] = true; end
  end

  -- Walk every cached store so the dump covers all characters, not just open bags.
  local caches = { TFuInvItm, TFuBnkItm, TFuContItm, TFuBodyItm, TFuMailItm };
  for _, cache in ipairs(caches) do
    if (type(cache) == "table") then
      for _, byplayer in pairs(cache) do
        if (type(byplayer) == "table") then
          for _, bag in pairs(byplayer) do
            if (type(bag) == "table") then
              for _, slot in pairs(bag) do
                if (type(slot) == "table") then
                  note(slot[self.I_ITEMLINK], slot[self.I_TYPE], slot[self.I_SUBTYPE], slot[self.I_EXPANSION]);
                end
              end
            end
          end
        end
      end
    end
  end

  table.sort(order, function(a, b)
    local ba, bb = buckets[a], buckets[b];
    local ka = (ba.c or -1) * 1000 + (ba.s or -1);
    local kb = (bb.c or -1) * 1000 + (bb.s or -1);
    return ka < kb;
  end);

  local lines = {};
  lines[#lines + 1] = "tbag taxonomy  (classID:subID  storedType/storedSub | classInfo/subClassInfo  exp=[..]  xN  e.g.)";
  for _, key in ipairs(order) do
    local b = buckets[key];
    local exps = {};
    for e in pairs(b.exps) do exps[#exps + 1] = tostring(e); end
    table.sort(exps);
    lines[#lines + 1] = string.format("%s:%s  %s / %s | %s / %s  exp=[%s]  x%d  e.g. %s",
      tostring(b.c), tostring(b.s), tostring(b.t), tostring(b.st),
      tostring(b.cls), tostring(b.scls), table.concat(exps, ","), b.n, tostring(b.ex));
  end

  if (TFuBagCfg) then TFuBagCfg.__taxonomy = lines; end
  self:Print(string.format(
    "TBag taxonomy: %d class/subclass buckets saved to TFuBagCfg.__taxonomy. /reload (or logout) to flush, then it can be read from the SavedVariables file.",
    #order));
end


function TFuBag:ScanEquipped()
  local itemLink;

--  self:Print( "Scanning Equipment: ");

  -- The legacy S_EQUIPPED set powered the EQUIPPED_* category, which was
  -- removed. Clearing it on every scan so nothing reads the stale data.
  self:SetPlayerInfo(self.PLAYERID, self.S_EQUIPPED, {});

  -- Arrange by itemlink (for equipped) and player (for TFuBody)
  for key, value in pairs(self.Body_Slots) do
--    self:Print("Equipped ID="..GetInventorySlotInfo(key).." for "..key);
    local slot = GetInventorySlotInfo(key);
    itemLink = GetInventoryItemLink("player", slot);

    TFuBodyItm[self.PLAYERID][self.D_BAG][value] = {};
    local dbag = TFuBodyItm[self.PLAYERID][self.D_BAG][value];
    if (itemLink) then
      local _
      _, dbag[self.I_ITEMLINK], dbag[self.I_LINKSUFFIX] = self:GetItemID(itemLink);

      dbag[self.I_NAME],_,dbag[self.I_RARITY] = GetItemInfo(dbag[self.I_ITEMLINK]);
      dbag[self.I_COUNT] = 1;

      local tooltip = self:MakeToolTipStr(playerid, dbag[self.I_ITEMLINK], nil, nil, idx, slot);
      dbag[self.I_CHARGES] = self:GetItmCharges(tooltip);
    end
  end
end


function TFuBag:ScanMail()
  local itemLink, idx;

--  self:Print( "Scanning Mail: ");

  -- Arrange by player (for TFuMail)
  TFuMailItm[self.PLAYERID] = {};
  for idx = 1, GetInboxNumItems() do
    local _,_,_,_,_,_,_,itemCount,_,_,_,_,_ = GetInboxHeaderInfo(idx);
    -- Only scan mail with attachments.
    if (itemCount) then
      TFuMailItm[self.PLAYERID][idx] = {};
      for slot = 1, itemCount do
        TFuMailItm[self.PLAYERID][idx][slot] = {};
        local itm = TFuMailItm[self.PLAYERID][idx][slot];
        local name, itemTexture, count, quality, canUse = GetInboxItem(idx,slot);
        local _,itemlink = self:GetItemID(GetInboxItemLink(idx,slot));
        if itemlink and itemlink:sub(1,11)  == "item:82800:" then
          -- Deal with Pet Cages *sigh*
          local _, speciesID, level, breedQuality, maxHealth, power, speed, petname = GameTooltip:SetInboxItem(idx, slot)
          if speciesID and speciesID > 0 then
            itemlink = string.format("battlepet:%d:%d:%d:%d:%d:%d:0",speciesID, level, breedQuality, maxHealth, power, speed)
            name = petname
            quality = breedQuality
          end
        end

        -- GetInboxItem is currently bugged and returns -1 for the quality
        -- so try and get the correct quality from GetItemInfo
        if (quality == -1) then
          _,_,quality = GetItemInfo(itemlink);
        end

        itm[self.I_NAME] = name;
        itm[self.I_COUNT] = count;
        itm[self.I_ITEMLINK] = itemlink;
        itm[self.I_RARITY] = quality;
        local tooltip = self:MakeToolTipStr(playerid, itm[self.I_ITEMLINK], nil, nil,
                                            idx, slot);
        itm[self.I_CHARGES] = self:GetItmCharges(tooltip);
      end
    end
  end
end


-----------------------------------------------------------------------
-- Main Display
-----------------------------------------------------------------------

function TFuBag:CalcBarLayout(calc_dat, baritm, barnum, numbars, colmax, edit_mode)
  local iBar;

  -- First set the total bar sizes
  calc_dat = calc_dat or {};
  for k,_ in pairs(calc_dat) do
    calc_dat[k] = nil;
  end
  for iBar = 0, numbars-1 do
    if (edit_mode == 1) then
      calc_dat[iBar] = table.getn(baritm[barnum+iBar]) + 1;
    else
      calc_dat[iBar] = table.getn(baritm[barnum+iBar]);
    end
  end

  -- Make the rectangles for each possible width
  for iBar = 0, numbars-1 do
    calc_dat[iBar.."_heights"] = {};
    if calc_dat[iBar] > 0 then
      for tmpcalc = 1, calc_dat[iBar] do
        calc_dat[iBar.."_heights"][tmpcalc] = math.ceil( calc_dat[iBar] / tmpcalc );
      end
    end
  end

  calc_dat["height"] = 0;
  repeat
    calc_dat["height"] = calc_dat["height"] + 1;
    tmpcalc = 0;

    for iBar = 0, numbars-1 do
      if (calc_dat[iBar] > 0) then
        if (calc_dat[iBar.."_heights"][calc_dat["height"]]) then
          tmpcalc = tmpcalc + calc_dat[iBar.."_heights"][calc_dat["height"]];
        else
          tmpcalc = tmpcalc + 1;
        end
      end
    end
  until tmpcalc <= colmax;

  if tmpcalc == 0 then
    calc_dat["height"] = 0;
  else
    -- at calc_dat["height"], everything fits
    for iBar = 0, numbars-1 do
      if calc_dat[iBar] > 0 then
        if (calc_dat[iBar.."_heights"][calc_dat["height"]]) then
          calc_dat[iBar.."_width"] = calc_dat[iBar.."_heights"][calc_dat["height"]];
        else
          calc_dat[iBar.."_width"] = 1;
        end
      else
       calc_dat[iBar.."_width"] = 0;
      end
    end
  end
end

-- mainFrame = The parent frame of everything
-- barnum == current bar
-- frame == name of background frame to be relative to
-- width/height == max number of buttons to place into frame
function TFuBag:AssignButtonsToFrame(mainFrame, barnum, frame, width, height)
  local cur_x, cur_y = 0, 0

  for position, itm in pairs(mainFrame.BARITM[barnum]) do
    local buttonname = TFuBag:GetBagItemButtonName(itm[TFuBag.I_BAG], itm[TFuBag.I_SLOT])

    -- -BF_X_PAD (instead of +) centers the button cluster in the box: the frame
    -- is 2*BF_X_PAD wider than the buttons need, so this splits that slack evenly
    -- left/right (a slight edge on both sides) rather than leaving the rightmost
    -- button flush against the box edge.
    self:PositionFrame(buttonname, "BOTTOMRIGHT", frame, "BOTTOMRIGHT",
      0-mainFrame:FrameX(cur_x)-mainFrame.BF_X_PAD,
      mainFrame:FrameY(cur_y)+mainFrame.BF_Y_PAD,
      mainFrame.BF_WIDTH, mainFrame.BF_HEIGHT)

    self:PositionFrame(buttonname.."_bkgr", "TOPLEFT", buttonname, "TOPLEFT",
      0-mainFrame.BF_X_PAD, mainFrame.BF_Y_PAD,
      mainFrame.BGF_WIDTH, mainFrame.BGF_HEIGHT)

    -- resize frame texture (this is the little border)
    -- 12.0: intrinsic ItemButton children have no $parent global name; get the
    -- NormalTexture via the button method instead of _G[name.."NormalTexture"].
    local frame_normaltexture = _G[buttonname] and _G[buttonname]:GetNormalTexture()
    if frame_normaltexture then
      frame_normaltexture:SetWidth(mainFrame.BGF_WIDTH)
      frame_normaltexture:SetHeight(mainFrame.BGF_HEIGHT)
    end

    -- Relink the button map
    self.BUTTONS[buttonname] = itm
    cur_x = cur_x + 1
    if cur_x == width then
      cur_x = 0
      cur_y = cur_y + 1
    end
  end

  if mainFrame.edit_mode == 1 then
    -- add extra button for the bar
    local buttonname = mainFrame:GetName().."_BarButton_"..barnum

    self:PositionFrame(buttonname, "BOTTOMRIGHT", frame, "BOTTOMRIGHT",
      0-mainFrame:FrameX(width-1)-mainFrame.BF_X_PAD,
      mainFrame:FrameY(height-1)+mainFrame.BF_Y_PAD,
      mainFrame.BF_WIDTH, mainFrame.BF_HEIGHT)

    self:PositionFrame(buttonname.."_bkgr", "TOPLEFT", buttonname, "TOPLEFT",
      0-mainFrame.BF_X_PAD, mainFrame.BF_Y_PAD,
      mainFrame.BGF_WIDTH, mainFrame.BGF_HEIGHT)

    -- 12.0: intrinsic ItemButton children have no $parent global name; get the
    -- NormalTexture via the button method instead of _G[name.."NormalTexture"].
    local frame_normaltexture = _G[buttonname] and _G[buttonname]:GetNormalTexture()
    if frame_normaltexture then
      frame_normaltexture:SetWidth(mainFrame.BGF_WIDTH)
      frame_normaltexture:SetHeight(mainFrame.BGF_HEIGHT)
    end

    local tmpframe = _G[buttonname] and _G[buttonname].Stock  -- intrinsic parentKey, not a global name
    if tmpframe then tmpframe:SetText(barnum) end
    tmpframe = _G[buttonname.."_bkgr"]
    tmpframe:SetVertexColor(1,0,0.25,0.8)
    tmpframe:Show()
  end
end

function TFuBag:GetBarY(bar_x)
  return math.floor(self.BAR_MAX / bar_x);
end

-- fx = Tqqq_FrameX
-- sx = Tqqq_SpaceX

-- Manual Layout seed: give any item-bearing bar that has no cat_layout record
-- yet a stable freeform position (grid coords gx,gy + width cols). The bulk
-- first-enable case lays categories out in reading order on a clean packed grid
-- mirroring the auto-flow rows; a lone new category appearing later is appended
-- below the already-occupied area. Coords are in CELLS (one item button each),
-- so placements scale with button size / window scale.
function TFuBag:SeedCatLayout(frame, calc_dat)
  local cfg = frame.cfg;
  local baritm = frame.BARITM;
  local bar_x = cfg.bar_x;
  local cat_layout = cfg.cat_layout;
  local colmax = cfg["maxColumns"];

  -- Where does already-placed content end (so new categories append below)?
  local any_placed = false;
  local max_row = 0;
  for bn = 1, self.BAR_MAX do
    local rec = cat_layout[bn];
    if (rec) then
      any_placed = true;
      local n = table.getn(baritm[bn]);
      local cols = rec.cols or 1; if (cols < 1) then cols = 1; end
      local rows = math.ceil((n > 0 and n or 1) / cols);
      if ((rec.gy or 0) + rows > max_row) then max_row = (rec.gy or 0) + rows; end
    end
  end

  local gx, gy = 0, (any_placed and max_row or 0);
  for barnum = 1, self.BAR_MAX, bar_x do
    local nbars = math.min(bar_x, self.BAR_MAX - barnum + 1);
    self:CalcBarLayout(calc_dat, baritm, barnum, nbars, colmax, 0);
    if (calc_dat["height"] and calc_dat["height"] > 0) then
      local row_h = 0;
      local placed_in_row = false;
      for iBar = 0, nbars - 1 do
        local bn = barnum + iBar;
        local n = table.getn(baritm[bn]);
        if (n > 0 and not cat_layout[bn]) then
          local cols = calc_dat[iBar.."_width"];
          if (not cols or cols < 1) then cols = 1; end
          local rows = math.ceil(n / cols);
          if (gx + cols > colmax) then gx = 0; gy = gy + row_h; row_h = 0; end
          cat_layout[bn] = { gx = gx, gy = gy, cols = cols };
          gx = gx + cols;
          if (rows > row_h) then row_h = rows; end
          placed_in_row = true;
        end
      end
      if (placed_in_row) then gx = 0; gy = gy + row_h; end
    end
  end
end

-- Manual Layout first-enable snapshot: the normal auto-flow has just positioned
-- every category box, so read each box's rendered geometry back and convert it
-- to grid coords. This makes turning Manual Layout on the first time reproduce
-- the current (ML-off) layout instead of re-packing it. Rows are detected by
-- shared bottom edge (the auto-flow bottom-anchors each row) and gy is the
-- cumulative content-row height above, so the per-row label gap (band gap in
-- LayoutWindowFree) is reserved cleanly rather than baked into pixel positions.
-- Manual Layout grid metrics. The grid is TIGHT: pitchX/pitchY are exactly one
-- item-button cell, the same unit FrameX/FrameY use to size a box, so a box's
-- grid footprint (in cells) equals its rendered size -- collision and drops line
-- up with what's drawn. Horizontal category spacing is NOT folded into the pitch:
-- the first-enable snapshot already captures ML-off's between-box spacing in the
-- grid coords (a box further right gets a larger gx), and a per-cell gap both
-- balloons the window vs ML-off and inflates the collision rect past the visual
-- box (rejecting valid drops). Vertical category spacing is added once PER ROW
-- BAND in LayoutWindowFree (never per cell). Returns pitchX, pitchY, cellX (cellX
-- == pitchX; returned for call-site clarity). Shared by SnapshotCatLayout,
-- LayoutWindowFree, and MLDragStop so they stay on one grid.
function TFuBag:MLGridPitch(frame)
  local cfg = frame.cfg;
  local cellX = frame.BF_PADWIDTH + cfg.frameXSpace;
  local cellY = frame.BF_PADHEIGHT + cfg.frameYSpace;
  return cellX, cellY, cellX;
end

function TFuBag:SnapshotCatLayout(frame)
  local framename = frame:GetName();
  local cfg = frame.cfg;
  local baritm = frame.BARITM;
  local cat_layout = cfg.cat_layout;
  local pitchX, pitchY, cellX = self:MLGridPitch(frame);

  local boxes = {};
  local minLeft;
  for bn = 1, self.BAR_MAX do
    local bf = _G[framename.."_bar_"..bn];
    if (bf and bf:IsShown() and table.getn(baritm[bn]) > 0) then
      local l, b, w, h = bf:GetLeft(), bf:GetBottom(), bf:GetWidth(), bf:GetHeight();
      if (l and b and w and h) then
        -- column count comes from the rendered width via the CELL pitch; the grid
        -- column (gx, below) uses the gap-aware pitchX.
        local cols = math.floor((w - cfg.frameXSpace) / cellX + 0.5);
        if (cols < 1) then cols = 1; end
        local rows = math.floor((h - cfg.frameYSpace) / pitchY + 0.5);
        if (rows < 1) then rows = 1; end
        table.insert(boxes, { bn = bn, l = l, b = b, cols = cols, rows = rows });
        if (not minLeft or l < minLeft) then minLeft = l; end
      end
    end
  end
  if (not minLeft) then return; end

  -- Group boxes into rows by shared bottom edge.
  local rows_list = {};
  for _, bx in ipairs(boxes) do
    local row;
    for _, r in ipairs(rows_list) do
      if (math.abs(r.bottom - bx.b) < pitchY / 2) then row = r; break; end
    end
    if (not row) then
      row = { bottom = bx.b, maxrows = 0, items = {} };
      table.insert(rows_list, row);
    end
    table.insert(row.items, bx);
    if (bx.rows > row.maxrows) then row.maxrows = bx.rows; end
  end
  -- Top row first (highest bottom).
  table.sort(rows_list, function(a, b) return a.bottom > b.bottom; end);

  local gy = 0;
  for _, r in ipairs(rows_list) do
    for _, bx in ipairs(r.items) do
      local gx = math.floor((bx.l - minLeft) / pitchX + 0.5);
      if (gx < 0) then gx = 0; end
      -- Bottom-align within the row (like the auto-flow): a box shorter than the
      -- row's tallest sits at the row's bottom, so its title drops below the
      -- taller neighbour's title instead of colliding with it horizontally.
      cat_layout[bx.bn] = { gx = gx, gy = gy + (r.maxrows - bx.rows), cols = bx.cols };
    end
    gy = gy + r.maxrows;
  end
end

-- ===== Manual Layout: drag-to-reposition (Stage 2) =====
-- A category box (the _bar_N frame) is draggable in Manual Layout mode. The grab
-- region is the box's own background -- mouse is enabled on the bar frame, so a
-- click on the colored backdrop around/between item buttons starts a drag, while
-- the item buttons sit on top and keep their own clicks -- plus, when category
-- names are shown, a transparent handle over the name label above the box (the
-- label is a FontString and can't take mouse itself).
--
-- We do NOT move the box itself: the item buttons are only anchored to it (not
-- children), so StartMoving the box made them trail a frame behind and slide under
-- the cursor, where the release would pick up an item. Instead a translucent
-- "ghost" rectangle (one per window, mouse-transparent) follows the cursor; the
-- box and items stay put. On drop we convert the ghost's movement to a whole-cell
-- grid delta, add it to the saved gx,gy, and re-layout (which re-snaps onto the
-- grid and re-applies per-band label headroom). Measuring the delta -- not the
-- absolute drop position -- keeps the snap immune to band-gap offsets baked into
-- on-screen y. A drop that would overlap another category is reverted.
TFuBag.MLDrag = TFuBag.MLDrag or { active = false };

-- The grid footprint [gx, gx+cols) x [gy, gy+rows) a category occupies, given a
-- candidate top-left (gx,gy). cols/rows mirror the layout's own clamping.
function TFuBag:MLCatFootprint(frame, barnum, gx, gy)
  local cfg = frame.cfg;
  local rec = cfg.cat_layout[barnum];
  local n = table.getn(frame.BARITM[barnum]);
  local colmax = cfg.maxColumns;
  local cols = (rec and rec.cols) or 1;
  if (cols < 1) then cols = 1; end
  if (cols > colmax) then cols = colmax; end
  local rows = math.ceil((n > 0 and n or 1) / cols);
  if (rows < 1) then rows = 1; end
  return gx, gy, gx + cols, gy + rows;
end

-- Would placing barnum at (gx,gy) overlap any other item-bearing category? Pure
-- half-open rectangle intersection on grid cells.
function TFuBag:MLOverlaps(frame, barnum, gx, gy)
  local ax1, ay1, ax2, ay2 = self:MLCatFootprint(frame, barnum, gx, gy);
  local cfg = frame.cfg;
  for bn = 1, self.BAR_MAX do
    if (bn ~= barnum and cfg.cat_layout[bn] and table.getn(frame.BARITM[bn]) > 0) then
      local r = cfg.cat_layout[bn];
      local bx1, by1, bx2, by2 = self:MLCatFootprint(frame, bn, r.gx or 0, r.gy or 0);
      if (ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1) then
        return true;
      end
    end
  end
  return false;
end

-- The drag ghost (one per window): a translucent rectangle that follows the
-- cursor during a drag. High strata so it floats above the boxes and items, and
-- mouse-ENABLED so that on release it shields the item button under the cursor --
-- otherwise a reverted/short drop lands a click on that item and picks it up. The
-- frame-drag itself is owned by the bar frame's RegisterForDrag, so OnDragStop
-- still fires regardless of the ghost being moused.
function TFuBag:MLGetGhost(frame)
  local g = frame.MLGhost;
  if (not g) then
    g = CreateFrame("Frame", nil, frame);
    g:SetFrameStrata("DIALOG");
    g:EnableMouse(true);
    g:SetMovable(true);
    g:SetClampedToScreen(true);
    local tex = g:CreateTexture(nil, "BACKGROUND");
    tex:SetAllPoints(g);
    tex:SetColorTexture(0.2, 0.9, 0.2, 0.25);
    g.tex = tex;
    g:Hide();
    frame.MLGhost = g;
  end
  return g;
end

-- Toggle mouse on every item button for the duration of a bar drag. While a bar is
-- being dragged, item buttons must be inert: otherwise, as the drag crosses another
-- bar's buttons, the inherited container button can grab the item under the cursor
-- (it has RegisterForDrag("LeftButton")). Disabled on drag start, restored on stop.
function TFuBag:MLSetItemMouse(frame, enabled)
  for _, bag in ipairs(frame.bags) do
    for slot = 1, self:GetBagMaxItems(bag) do
      local btn = _G[self:GetBagItemButtonName(bag, slot)];
      if (btn) then btn:EnableMouse(enabled); end
    end
  end
end

function TFuBag:MLDragStart(frame, barnum, bf)
  local cfg = frame.cfg;
  if (cfg.manual_layout ~= 1 or cfg.legacy_edit == 1) then return; end
  local free = (cfg.ml_freeplace == 1);
  local rec = (free and cfg.cat_layout_free or cfg.cat_layout)[barnum];
  if (not rec) then return; end
  local l, t = bf:GetLeft(), bf:GetTop();
  if (not l or not t) then return; end

  local g = self:MLGetGhost(frame);
  g:ClearAllPoints();
  g:SetWidth(bf:GetWidth());
  g:SetHeight(bf:GetHeight());
  g:SetPoint("TOPLEFT", bf, "TOPLEFT", 0, 0);
  g:Show();

  self.MLDrag.active = true;
  self.MLDrag.frame  = frame;
  self.MLDrag.barnum = barnum;
  self.MLDrag.free   = free;
  self.MLDrag.gx0    = rec.gx or rec.fx or 0;
  self.MLDrag.gy0    = rec.gy or rec.fy or 0;
  self.MLDrag.left0  = l;   -- ghost starts anchored over the box, so box L/T == ghost L/T
  self.MLDrag.top0   = t;
  self:MLSetItemMouse(frame, false);  -- items inert until the drag ends
  g:StartMoving();
end

-- Cell gaps from the spacing settings (X/Y Pool + Category Spacing), and the title
-- height in cells (titlec) when names are shown. The title is kept SEPARATE from
-- the gap and is instead folded into each bar's collision footprint (a bar's title
-- sits in the strip directly above its box), so vertical neighbours leave room for
-- the lower bar's title without double-counting it in the gap.
function TFuBag:MLGapCells(frame)
  local cfg = frame.cfg;
  local cellX = frame.BF_PADWIDTH + cfg.frameXSpace;
  local cellY = frame.BF_PADHEIGHT + cfg.frameYSpace;
  local sp = cfg.cat_spacing or 0;
  local gapXc = (frame:PoolX(1) + sp) / cellX;
  local gapYc = (frame:PoolY(1) + sp) / cellY;
  local titlec = (cfg.show_cat_names == 1) and (14 / cellY) or 0;  -- CATNAME_H
  return gapXc, gapYc, titlec;
end

-- Magnetic edge snap (free placement). The box was dropped at (afx,afy); nudge each
-- axis onto the nearest alignment line from another bar -- its left/top edge (line
-- bars up) or the spacing-gap position just past its right/bottom or before its
-- left/top (dock flush beside it) -- but only within a small threshold, so a drop
-- in open space stays where you put it. Each axis snaps independently. Returns the
-- snapped afx,afy. This gives clean alignment WITHOUT forcing the box into any
-- bar's slot, so it never yanks the dropped box onto a neighbour.
function TFuBag:MLSnapFree(frame, barnum, afx, afy, dcols, drows)
  local cfg = frame.cfg;
  local store = cfg.cat_layout_free;
  local gapXc, gapYc, titlec = self:MLGapCells(frame);
  local THRESH = 0.45;  -- cells
  local bestX, bestXd, bestY, bestYd;
  for bn = 1, self.BAR_MAX do
    if (bn ~= barnum and store[bn] and table.getn(frame.BARITM[bn]) > 0) then
      local r = store[bn];
      local bc = r.cols or 1; if (bc < 1) then bc = 1; end
      local m = table.getn(frame.BARITM[bn]);
      local br = math.ceil(m / bc); if (br < 1) then br = 1; end
      local bfx, bfy = r.fx or 0, r.fy or 0;
      local cx = { bfx, bfx + bc + gapXc, bfx - dcols - gapXc };
      for _, v in ipairs(cx) do
        local d = math.abs(afx - v);
        if (d < THRESH and (not bestXd or d < bestXd)) then bestXd = d; bestX = v; end
      end
      -- below/above candidates include the title height (vertical neighbours leave
      -- room for the lower bar's title).
      local cy = { bfy, bfy + br + gapYc + titlec, bfy - drows - gapYc - titlec };
      for _, v in ipairs(cy) do
        local d = math.abs(afy - v);
        if (d < THRESH and (not bestYd or d < bestYd)) then bestYd = d; bestY = v; end
      end
    end
  end
  if (bestX) then afx = bestX; end
  if (bestY) then afy = bestY; end
  return afx, afy;
end

-- Push every OTHER bar the dropped box overlaps away from it (anchor stays put),
-- along the axis of shallower penetration, toward whichever side the bar leans,
-- flush + the spacing gap. A pushed bar that then overlaps more bars propagates the
-- push (cascade). Used for the "tight" case where the dropped box has no adjacent
-- free space and must make room. Guard-bounded.
function TFuBag:MLPushNeighbors(frame, anchorbar, acols, arows)
  local store = frame.cfg.cat_layout_free;
  local gapXc, gapYc, titlec = self:MLGapCells(frame);
  -- rect returns the collision footprint: the box plus the title strip directly
  -- above it (top extended by titlec), so a vertical push leaves room for the
  -- pushed bar's title.
  local function rect(bn)
    local r = store[bn];
    if (not r) then return nil; end
    local m = table.getn(frame.BARITM[bn]);
    if (m <= 0) then return nil; end
    local c = r.cols or 1; if (c < 1) then c = 1; end
    local rr = math.ceil(m / c); if (rr < 1) then rr = 1; end
    local x1, y1 = r.fx or 0, r.fy or 0;
    return x1, y1 - titlec, x1 + c, y1 + rr, c, rr;
  end
  local frontier = { anchorbar };
  local guard = 0;
  while (table.getn(frontier) > 0 and guard < 12 * self.BAR_MAX) do
    guard = guard + 1;
    local cur = table.remove(frontier);
    local cx1, cy1, cx2, cy2 = rect(cur);
    if (cx1) then
      local ccx, ccy = (cx1 + cx2) / 2, (cy1 + cy2) / 2;
      for bn = 1, self.BAR_MAX do
        if (bn ~= cur and bn ~= anchorbar) then
          local bx1, by1, bx2, by2, bc, br = rect(bn);
          -- within-gap collision (see MLResolveFree): keeps spacing between bars.
          if (bx1 and cx1 < bx2 + gapXc and cx2 + gapXc > bx1 and cy1 < by2 + gapYc and cy2 + gapYc > by1) then
            local penX = math.min(cx2, bx2) - math.max(cx1, bx1);
            local penY = math.min(cy2, by2) - math.max(cy1, by1);
            local r = store[bn];
            local moved = false;
            -- r.fx/r.fy are BOX coords; cy2 is cur's box bottom, cy1 its footprint
            -- top (already title-extended). Pushing DOWN adds the moved bar's own
            -- title; pushing UP gets cur's title via cy1.
            if (penX <= penY) then
              if ((bx1 + bx2) / 2 >= ccx) then
                local t = cx2 + gapXc;                 if (t > (r.fx or 0)) then r.fx = t; moved = true; end
              else
                local t = cx1 - gapXc - bc;            if (t < (r.fx or 0)) then r.fx = t; moved = true; end
              end
            else
              if ((by1 + by2) / 2 >= ccy) then
                local t = cy2 + gapYc + titlec;        if (t > (r.fy or 0)) then r.fy = t; moved = true; end
              else
                local t = cy1 - gapYc - br;            if (t < (r.fy or 0)) then r.fy = t; moved = true; end
              end
            end
            if (moved) then table.insert(frontier, bn); end
          end
        end
      end
    end
  end
end

-- Resolve overlaps after a free drop. Prefer EXISTING free space: slide the dropped
-- box out past the bar it landed on (shortest way, toward its lean). If that lands
-- it in the clear, keep it there and leave every other bar untouched. If it's still
-- blocked (a tight/packed spot with no adjacent room), put the box back where it was
-- dropped and PUSH the neighbours apart to make room instead.
function TFuBag:MLResolveFree(frame, barnum, acols, arows)
  local cfg = frame.cfg;
  local store = cfg.cat_layout_free;
  local rec = store[barnum];
  if (not rec) then return; end
  local gapXc, gapYc, titlec = self:MLGapCells(frame);
  if (not acols or acols < 1) then acols = 1; end
  if (not arows or arows < 1) then arows = 1; end
  -- rect = collision footprint (box + title strip above it).
  local function rect(bn)
    local r = store[bn];
    if (not r) then return nil; end
    local m = table.getn(frame.BARITM[bn]);
    if (m <= 0) then return nil; end
    local c = r.cols or 1; if (c < 1) then c = 1; end
    local rr = math.ceil(m / c); if (rr < 1) then rr = 1; end
    local x1, y1 = r.fx or 0, r.fy or 0;
    return x1, y1 - titlec, x1 + c, y1 + rr;
  end
  local function hits()
    -- returns count of overlapped bars, and the first one's footprint. The dropped
    -- box's own footprint includes its title strip too.
    local ax1, ay1 = rec.fx or 0, (rec.fy or 0) - titlec;
    local ax2, ay2 = (rec.fx or 0) + acols, (rec.fy or 0) + arows;
    local n, fx1, fy1, fx2, fy2 = 0;
    for bn = 1, self.BAR_MAX do
      if (bn ~= barnum) then
        local bx1, by1, bx2, by2 = rect(bn);
        -- "collide" = within the spacing gap, not just box-on-box, so a bar dropped
        -- with too little room to keep Category Spacing still counts as needing room.
        if (bx1 and ax1 < bx2 + gapXc and ax2 + gapXc > bx1 and ay1 < by2 + gapYc and ay2 + gapYc > by1) then
          n = n + 1;
          if (not fx1) then fx1, fy1, fx2, fy2 = bx1, by1, bx2, by2; end
        end
      end
    end
    return n, fx1, fy1, fx2, fy2;
  end

  local nhit, hx1, hy1, hx2, hy2 = hits();
  if (nhit == 0) then return; end        -- dropped in the clear: nothing to do

  local sx, sy = rec.fx or 0, rec.fy or 0;  -- remember the drop for the tight fallback

  -- Overlapping two or more bars means the box was wedged BETWEEN them: make room on
  -- both sides (push them apart) rather than sliding it next to just one.
  if (nhit >= 2) then
    self:MLPushNeighbors(frame, barnum, acols, arows);
    return;
  end
  -- Slide the box out past that bar (shortest way, toward the side it leans). Use
  -- the box's footprint (title strip on top) so it clears the bar's title too; a
  -- downward slide adds the box's own title height.
  local ax1, ay1 = sx, sy - titlec;
  local ax2, ay2 = sx + acols, sy + arows;
  local ox = math.min(ax2, hx2) - math.max(ax1, hx1);
  local oy = math.min(ay2, hy2) - math.max(ay1, hy1);
  if (ox <= oy) then
    if ((ax1 + ax2) / 2 < (hx1 + hx2) / 2) then rec.fx = hx1 - gapXc - acols;
    else rec.fx = hx2 + gapXc; end
  else
    if ((ay1 + ay2) / 2 < (hy1 + hy2) / 2) then rec.fy = hy1 - gapYc - arows;
    else rec.fy = hy2 + gapYc + titlec; end
  end

  if (hits() == 0) then return; end      -- slid into free space: keep it, others stay

  -- Tight: no adjacent room. Restore the drop position and make room by pushing.
  rec.fx, rec.fy = sx, sy;
  self:MLPushNeighbors(frame, barnum, acols, arows);
end

function TFuBag:MLDragStop(frame, barnum, bf)
  local g = frame.MLGhost;
  if (g) then g:StopMovingOrSizing(); end
  self:MLSetItemMouse(frame, true);  -- restore item mouse (always, any drag path)
  if (not self.MLDrag.active or self.MLDrag.barnum ~= barnum) then
    if (g) then g:Hide(); end
    return;
  end
  self.MLDrag.active = false;

  local cfg = frame.cfg;

  -- FREE PLACEMENT (Stage 2): drop the box where it was released, magnet-snap its
  -- edges to nearby bars for clean alignment, then push only the bars it actually
  -- overlaps (shortest way out). Dropping into free space moves nothing; the box
  -- itself is never yanked onto a neighbour. The layout then normalizes the origin.
  if (cfg.ml_freeplace == 1) then
    local rec = cfg.cat_layout_free[barnum];
    if (rec and g) then
      local cellX = frame.BF_PADWIDTH + cfg.frameXSpace;
      local cellY = frame.BF_PADHEIGHT + cfg.frameYSpace;
      local n = table.getn(frame.BARITM[barnum]);
      local dcols = rec.cols or 1; if (dcols < 1) then dcols = 1; end
      local drows = math.ceil((n > 0 and n or 1) / dcols); if (drows < 1) then drows = 1; end
      local gl, gt = g:GetLeft(), g:GetTop();
      if (gl and gt and self.MLDrag.left0 and self.MLDrag.top0 and cellX > 0 and cellY > 0) then
        local afx = (self.MLDrag.gx0 or 0) + (gl - self.MLDrag.left0) / cellX;
        local afy = (self.MLDrag.gy0 or 0) + (self.MLDrag.top0 - gt) / cellY;
        afx, afy = self:MLSnapFree(frame, barnum, afx, afy, dcols, drows);
        rec.fx = afx;
        rec.fy = afy;
        self:MLResolveFree(frame, barnum, dcols, drows);
      end
    end
    if (g) then g:Hide(); end
    frame:UpdateWindow(TFuBag.REQ_MUST);
    return;
  end

  local cat_layout = cfg.cat_layout;
  local rec = cat_layout[barnum];
  if (rec and g) then
    local framename = frame:GetName();
    local pitchX, pitchY = self:MLGridPitch(frame);
    -- Container is the bars' anchor parent; its screen position already moves
    -- with the WowScrollBox scroll, so (gl - container.left) is the bar's
    -- saved-coord px regardless of scroll position.
    local container = frame.Scroll and frame.Scroll.ScrollChild
                      and frame.Scroll.ScrollChild.Container;
    local cl = container and container:GetLeft();
    local gl, gt, gb = g:GetLeft(), g:GetTop(), g:GetBottom();

    -- dragged box height in cells (footprint at origin: 4th return == rows)
    local _, _, _, drows = self:MLCatFootprint(frame, barnum, 0, 0);

    -- Horizontal: snap the ghost's left to the nearest grid column. px = gx*pitchX
    -- relative to Container, so saved gx = (gl - container.left) / pitchX.
    local ngx = self.MLDrag.gx0 or 0;
    if (gl and cl and pitchX > 0) then
      ngx = math.floor((gl - cl) / pitchX + 0.5);
    end
    -- ngx may be negative (dropped past the left edge); handled by the origin
    -- shift below so the grid can grow leftward, mirroring rightward growth.

    -- Vertical: rows are rendered with a variable title/Pool gap between them, so a
    -- uniform-pitch snap lands off by that gap (the box snaps just above/below a
    -- side neighbour instead of level with it). Instead align the dragged box's
    -- BOTTOM row to the nearest existing box's rendered bottom (boxes in a row are
    -- bottom-aligned). Fall back to a cell-delta only when no box is near -- i.e.
    -- dropping into empty space to start a fresh row.
    local ngy;
    -- Snap vertically by aligning EITHER the dragged box's top OR its bottom to a
    -- neighbour's corresponding edge -- whichever edge the drop landed nearest. Top
    -- edge = the title row, bottom edge = the last item row. Both are valid align
    -- points, so a tall box can line up its title with a neighbour's title or its
    -- bottom with a neighbour's bottom. We measure neighbours' actual rendered
    -- edges (not an inferred pitch) so the title/Pool band gap can't slip the snap
    -- a button, and snap to whole-cell offsets so it always lands on a clean row.
    local best;  -- { diff, edge = "top"|"bottom", cell, pos }
    if (gt and gb) then
      for bn = 1, self.BAR_MAX do
        if (bn ~= barnum and cat_layout[bn] and table.getn(frame.BARITM[bn]) > 0) then
          local obf = _G[framename.."_bar_"..bn];
          if (obf and obf:IsShown()) then
            local ot, ob = obf:GetTop(), obf:GetBottom();
            local orec = cat_layout[bn];
            local _, otopcell, _, obotcell = self:MLCatFootprint(frame, bn, orec.gx or 0, orec.gy or 0);
            if (ot) then
              local d = math.abs(ot - gt);
              if (not best or d < best.diff) then best = { diff = d, edge = "top", cell = otopcell, pos = ot }; end
            end
            if (ob) then
              local d = math.abs(ob - gb);
              if (not best or d < best.diff) then best = { diff = d, edge = "bottom", cell = obotcell, pos = ob }; end
            end
          end
        end
      end
    end
    if (best and pitchY > 0) then
      if (best.edge == "top") then
        -- align dragged TOP (gy) to a whole-cell offset from the neighbour's top
        local cellsDown = math.floor((best.pos - gt) / pitchY + 0.5);
        ngy = best.cell + cellsDown;
      else
        -- align dragged BOTTOM (gy + rows) to a whole-cell offset from the bottom
        local cellsDown = math.floor((best.pos - gb) / pitchY + 0.5);
        ngy = (best.cell + cellsDown) - drows;
      end
    elseif (gt and self.MLDrag.top0 and pitchY > 0) then
      local dcy = math.floor((self.MLDrag.top0 - gt) / pitchY + 0.5);
      ngy = (self.MLDrag.gy0 or 0) + dcy;            -- no other boxes: cell-delta
    else
      ngy = self.MLDrag.gy0 or 0;
    end
    -- ngy may be negative (dropped past the top edge); origin shift below handles it.

    -- Collision (v1): block drops that create a NEW overlap, but never trap a box.
    -- If the box is already overlapping (stale/changed layout), allow any move so
    -- it can be dragged free. Overlap is tested at the pre-shift coords (every box
    -- shifts by the same amount, so the relative result is identical).
    local stuck = self:MLOverlaps(frame, barnum, self.MLDrag.gx0 or 0, self.MLDrag.gy0 or 0);
    if (stuck or not self:MLOverlaps(frame, barnum, ngx, ngy)) then
      -- Grow the grid origin when dropped past the left/top edge: shift every other
      -- box right/down so the dropped box can take the new edge cell, and the window
      -- auto-grows on that side (mirrors how dropping past the right/bottom grows it
      -- there). With no shift this is a plain move.
      local shiftX = (ngx < 0) and -ngx or 0;
      local shiftY = (ngy < 0) and -ngy or 0;
      if (shiftX > 0 or shiftY > 0) then
        for bn = 1, self.BAR_MAX do
          local r = cat_layout[bn];
          if (r and bn ~= barnum) then
            r.gx = (r.gx or 0) + shiftX;
            r.gy = (r.gy or 0) + shiftY;
          end
        end
      end
      rec.gx = ngx + shiftX;   -- == max(ngx, 0)
      rec.gy = ngy + shiftY;
    end
  end
  if (g) then g:Hide(); end
  frame:UpdateWindow(TFuBag.REQ_MUST);
end

-- Wire the drag/right-click scripts onto a bar frame exactly once. barnum and
-- frame are stable for a given _bar_N frame (it always belongs to one window and
-- one bar index), so the closures may capture them. A right-click is forwarded to
-- the main window's menu so enabling box mouse does not swallow it.
function TFuBag:MLInitBarDrag(frame, barnum, bf)
  if (bf.mlDragInit) then return; end
  bf:RegisterForDrag("LeftButton");
  bf:SetScript("OnDragStart", function(s) TFuBag:MLDragStart(frame, barnum, s); end);
  bf:SetScript("OnDragStop",  function(s) TFuBag:MLDragStop(frame, barnum, s); end);
  bf:SetScript("OnMouseUp", function(_, button)
    if (button == "RightButton") then frame:OnMouseDown("RightButton"); end
  end);

  local h = CreateFrame("Frame", nil, bf);
  h:EnableMouse(true);
  h:RegisterForDrag("LeftButton");
  h:SetScript("OnDragStart", function() TFuBag:MLDragStart(frame, barnum, bf); end);
  h:SetScript("OnDragStop",  function() TFuBag:MLDragStop(frame, barnum, bf); end);
  h:SetScript("OnMouseUp", function(_, button)
    if (button == "RightButton") then frame:OnMouseDown("RightButton"); end
  end);
  bf.MLTitleHandle = h;

  bf.mlDragInit = true;
end

-- Toggle dragging for a bar frame. Called per-bar by the layout: enabled in the
-- freeform path (with a title handle when names are shown), disabled in the
-- auto-flow path so boxes are inert when Manual Layout is off.
function TFuBag:SetBarDraggable(frame, barnum, bf, enabled, show_title_handle, label_gap)
  if (enabled) then
    self:MLInitBarDrag(frame, barnum, bf);
    bf:EnableMouse(true);
    local h = bf.MLTitleHandle;
    if (h) then
      if (show_title_handle and label_gap and label_gap > 0) then
        h:ClearAllPoints();
        h:SetPoint("BOTTOMLEFT", bf, "TOPLEFT", 0, 0);
        h:SetPoint("TOPRIGHT", bf, "TOPRIGHT", 0, label_gap);
        h:SetFrameLevel(bf:GetFrameLevel() + 10);
        h:Show();
      else
        h:Hide();
      end
    end
  else
    if (bf.mlDragInit) then
      bf:EnableMouse(false);
      if (bf.MLTitleHandle) then bf.MLTitleHandle:Hide(); end
    end
  end
end

-- Manual Layout placement: draw each category box at its saved grid coords and
-- auto-grow the window to fit. Boxes are drag-repositionable (Stage 2); cols come
-- from the seed/snapshot width (per-category options are a later stage).
-- Hide bars whose visual rectangle is ENTIRELY outside the ScrollBox bounds
-- (any overlap keeps the bar shown). WoW's frame-level clipping doesn't
-- deep-clip the framework's child frames, so bars near the viewport edges
-- would render past the bag window -- but full-fit hide was too aggressive
-- (hid bars the user was actively dragging to an edge). This overlap-based
-- check keeps grabbable, partially-visible bars on screen at the cost of a
-- few pixels of overhang past the ScrollBox edges.
function TFuBag:UpdateBarVisibilityForScroll(frame)
  local sb = frame.Scroll;
  if (not sb) then return; end
  local sb_top, sb_bot = sb:GetTop(), sb:GetBottom();
  local sb_left, sb_right = sb:GetLeft(), sb:GetRight();
  if (not (sb_top and sb_bot and sb_left and sb_right)) then return; end
  for barnum = 1, self.BAR_MAX do
    local bf = _G[frame:GetName().."_bar_"..barnum];
    if (bf) then
      local bt, bb = bf:GetTop(), bf:GetBottom();
      local bl, br = bf:GetLeft(), bf:GetRight();
      if (bt and bb and bl and br) then
        -- Standard 2D AABB overlap (WoW Y axis is inverted: GetTop > GetBottom).
        local overlaps = (bt > sb_bot and bb < sb_top
                          and br > sb_left and bl < sb_right);
        if (overlaps) then bf:Show(); else bf:Hide(); end
      end
    end
  end
end

-- Cheap item-visibility refresh used by the scroll callback. Mirrors the
-- (bar_visible AND not bar_hide_cfg) logic from ItemButton.Update without the
-- per-item tooltip / cooldown / rarity work.
function TFuBag:RefreshItemVisibility(frame)
  local cfg = frame.cfg;
  if (not cfg) then return; end
  for barnum = 1, self.BAR_MAX do
    local bf = _G[frame:GetName().."_bar_"..barnum];
    local bar_visible = bf and bf:IsShown();
    local bar_hide = self:GetGrp(cfg, self.G_BAR_HIDE, barnum) == 1;
    local items = frame.BARITM and frame.BARITM[barnum];
    if (items) then
      for _, itm in pairs(items) do
        local bag, slot = itm[self.I_BAG], itm[self.I_SLOT];
        local btn = _G[self:GetBagItemButtonName(bag, slot)];
        if (btn) then
          local forced = self.FORCED_SHOW[self:BagSlotToString(bag, slot)];
          if ((bar_hide and not forced) or not bar_visible) then
            btn:Hide();
          else
            btn:Show();
          end
        end
      end
    end
  end
end

-- (Custom wheel handler removed: WowScrollBox handles wheel + scrollbar drag
-- natively via the LinearView + MinimalScrollBar wiring in UpdateScrollViewport.)

-- Pre-cap dims (frame-local units), so layout code can decide which bars to
-- hide because they fall outside the viewport. Computed up-front so callers can
-- both clamp the window AND decide visibility from a single source of truth.
function TFuBag:GetWindowCap(frame)
  local scale = frame:GetScale();
  if (scale <= 0) then scale = 1; end
  return UIParent:GetWidth()  * 0.85 / scale,
         UIParent:GetHeight() * 0.85 / scale;
end

-- Position + size the WowScrollBox viewport. Pattern follows Baganator's
-- single-content-frame model: ScrollBox is the viewport (with clipChildren via
-- ScrollBoxBaseTemplate inheritance), ScrollChild is the one .scrollable=true
-- child the LinearView manages, Container is anchored inside ScrollChild and
-- holds the actual bars (their PositionFrame anchors target the Container).
-- Bars at arbitrary px/py positions get clipped at the ScrollBox edge by the
-- framework -- no manual hide / scroll-offset math needed.
-- Height reserved at the bottom for the horizontal scrollbar (17px bar with
-- arrow steppers + 4px breathing room before the bottom chrome). The 17px
-- matches the vertical bar's stepper height so the two orthogonal bars look
-- like rotated siblings. Used in two places below.
TFuBag.HSCROLL_H = 21;

function TFuBag:UpdateScrollViewport(frame, PAD_TOP, PAD_BOTTOM, content_w, content_h, cap_enabled)
  local sb = frame.Scroll;        -- ScrollBox (WowScrollBox)
  if (not sb) then return; end
  local sc = sb.ScrollChild;
  if (not sc) then return; end
  local container = sc.Container;
  if (not container) then return; end
  local bar = frame.ScrollBar;
  local hbar = frame.HScrollBar;

  -- One-time wiring: matches Baganator's working WowScrollBox setup exactly.
  -- The Baganator pattern reliably engages the framework's clipChildren cascade
  -- (which our previous custom-anchored attempts did not). Key parts:
  -- - InitScrollBoxWithScrollBar + AddManagedScrollBarVisibilityBehavior
  -- - SetPanExtent for wheel/scroll step
  -- - NIL OnSizeChanged on both ScrollBox and ScrollChild so the framework's
  --   reentrant size updates don't fight our explicit SetSize calls
  if (not frame.scrollInitDone) then
    if (ScrollUtil and ScrollUtil.InitScrollBoxWithScrollBar and CreateScrollBoxLinearView) then
      ScrollUtil.InitScrollBoxWithScrollBar(sb, bar, CreateScrollBoxLinearView());
      if (ScrollUtil.AddManagedScrollBarVisibilityBehavior) then
        ScrollUtil.AddManagedScrollBarVisibilityBehavior(sb, bar);
      end
    end
    sc:SetScript("OnSizeChanged", nil);
    sb:SetScript("OnSizeChanged", nil);
    if (sb.SetPanExtent) then sb:SetPanExtent(frame.BF_PADHEIGHT or 36); end
    if (sb.SetPropagateMouseClicks) then sb:SetPropagateMouseClicks(true); end
    if (sb.SetPropagateMouseMotion) then sb:SetPropagateMouseMotion(true); end
    sb:EnableMouseWheel(true);

    -- Both scroll bars draw above any dummy-bag items. Bumping just the bar
    -- frame is not enough -- ScrollBarMixin:OnLoad set the Track / Thumb /
    -- stepper levels relative to hbar's INITIAL level (before this bump),
    -- so they stay at low absolute levels and disappear behind dbag items
    -- (which now sit inside Container thanks to the reparenting). Push the
    -- whole subtree explicitly.
    local mf_level = frame:GetFrameLevel();
    if (bar) then
      bar:SetFrameLevel(mf_level + 10);
      if (bar.Track) then bar.Track:SetFrameLevel(mf_level + 12); end
      if (bar.Track and bar.Track.Thumb) then bar.Track.Thumb:SetFrameLevel(mf_level + 13); end
      if (bar.Back)    then bar.Back:SetFrameLevel(mf_level + 13);    end
      if (bar.Forward) then bar.Forward:SetFrameLevel(mf_level + 13); end
    end
    if (hbar) then
      hbar:SetFrameLevel(mf_level + 10);
      if (hbar.Track) then hbar.Track:SetFrameLevel(mf_level + 12); end
      if (hbar.Track and hbar.Track.Thumb) then hbar.Track.Thumb:SetFrameLevel(mf_level + 13); end
      if (hbar.Back)    then hbar.Back:SetFrameLevel(mf_level + 13);    end
      if (hbar.Forward) then hbar.Forward:SetFrameLevel(mf_level + 13); end
    end

    -- Horizontal scroll wiring. LinearView is vertical-only, so we drive the
    -- horizontal axis manually: HScrollBar's OnScroll callback shifts
    -- Container's TOPLEFT X anchor inside ScrollChild. The clipChildren
    -- cascade established by MainTemplate clips the shifted overflow.
    if (hbar) then
      hbar:RegisterCallback("OnScroll", function(_, percent)
        local overflow = frame.hScrollOverflow or 0;
        container:ClearAllPoints();
        container:SetPoint("TOPLEFT", sc, "TOPLEFT", 2 - percent * overflow, -2);
      end, frame);
    end

    -- Shift+mousewheel routes to the horizontal bar; plain wheel keeps the
    -- framework's vertical handler. We wrap (not replace) the framework's
    -- OnMouseWheel so InitScrollBoxWithScrollBar's wiring still runs for the
    -- non-shift case.
    local origWheel = sb:GetScript("OnMouseWheel");
    sb:SetScript("OnMouseWheel", function(self, delta)
      if (IsShiftKeyDown() and hbar and hbar:IsShown()) then
        hbar:OnMouseWheel(delta);
      elseif (origWheel) then
        origWheel(self, delta);
      end
    end);

    frame.scrollInitDone = true;
  end

  -- Baganator-pattern sizing. The 2px Container inset (XML TOPLEFT(2,-2)) +
  -- ScrollChild.size = Container.size+4 + ScrollBox.size = (Container.w+4,
  -- min(Container.h+5, cap)) is the exact recipe that engages the framework's
  -- clipChildren cascade for arbitrary-positioned content. Deviating from
  -- these magic offsets is what kept our clipping broken.
  local bottom_pad = PAD_BOTTOM + self.BORDER + frame:PoolY(1);
  local sb_w = content_w + 4;
  local sb_h = content_h + 5;
  if (cap_enabled) then
    local cap_w, cap_h = self:GetWindowCap(frame);
    -- Available horizontal area: chrome eats 2*BORDER plus the reserved
    -- scrollbar column. Capping sb_w creates horizontal overflow which the
    -- HScrollBar (below) lets the user pan through.
    local viewport_w_cap = cap_w - 2 * self.BORDER - self.SB_COL;
    if (sb_w > viewport_w_cap) then sb_w = viewport_w_cap; end
    -- The HScrollBar appears IFF the width cap took effect. When visible,
    -- it reserves HSCROLL_H at the bottom of the viewport so content (e.g.
    -- dummy bag items parented to mainFrame, which clipChildren clips at
    -- mainFrame's edge only) cannot render behind it.
    local hbar_will_show = (sb_w < content_w + 4);
    local h_reserve = hbar_will_show and self.HSCROLL_H or 0;
    -- Available vertical area inside the bag chrome (minus the HScrollBar
    -- reservation, so items can't scroll behind the bar).
    local viewport_h_cap = cap_h - PAD_TOP - bottom_pad - h_reserve;
    if (sb_h > viewport_h_cap) then sb_h = viewport_h_cap; end
  end
  container:SetSize(content_w, content_h);
  sc:SetSize(content_w + 4, content_h + 4);
  sb:SetSize(sb_w, sb_h);
  -- ScrollBox anchored TOPLEFT ONLY -- size is set explicitly above. The
  -- BOTTOMRIGHT anchor we used to have was fighting the framework's internal
  -- SetFrameExtent calls on the ScrollTarget.
  sb:ClearAllPoints();
  sb:SetPoint("TOPLEFT", frame, "TOPLEFT", self.BORDER, -PAD_TOP);

  -- Horizontal overflow drives whether the HScrollBar shows and how much it
  -- pans. Compare ScrollChild width (content_w + 4) against viewport width
  -- (sb_w); the difference is the panning range, stored on the frame so the
  -- bar's OnScroll callback can read it without recomputing.
  local h_overflow = (content_w + 4) - sb_w;
  if (h_overflow < 0) then h_overflow = 0; end
  frame.hScrollOverflow = h_overflow;
  local hbar_visible = (h_overflow > 0);

  -- mainFrame width = ScrollBox (sb_w) + 2 BORDERs + optional SB_COL.
  -- SB_COL reserves space for the vertical scrollbar in cap mode; in
  -- auto-flow there is no cap (and no vertical scrollbar can appear), so
  -- skip the reservation -- otherwise bars anchored to mainFrame's
  -- BOTTOMRIGHT extend into that empty gap and get clipped at sb's right
  -- edge by the framework's clipChildren cascade.
  local sb_col_reserve = cap_enabled and self.SB_COL or 0;
  frame:SetWidth(sb_w + 2 * self.BORDER + sb_col_reserve);
  frame:SetHeight(PAD_TOP + sb_h + bottom_pad + (hbar_visible and self.HSCROLL_H or 0));

  if (sb.FullUpdate and ScrollBoxConstants) then
    sb:FullUpdate(ScrollBoxConstants.UpdateImmediately);
  end

  -- Vertical scrollbar sits centered in its reserved column, below the close
  -- button. The column spans (mainFrame.right - BORDER - SB_COL) to
  -- (mainFrame.right - BORDER). Anchoring both TOPRIGHT and BOTTOMRIGHT to
  -- mainFrame at the same X (-col_inset) keeps the bar vertical (anchoring
  -- one to sb and one to frame would skew it because their right edges no
  -- longer align). When the horizontal bar is visible the vertical bar
  -- shortens by HSCROLL_H so the two don't overlap in the corner.
  if (bar) then
    local col_inset = self.BORDER + (self.SB_COL - 8) / 2;
    bar:ClearAllPoints();
    bar:SetPoint("TOPRIGHT",    frame, "TOPRIGHT",    -col_inset, -36);
    bar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -col_inset,
      bottom_pad + (hbar_visible and self.HSCROLL_H or 0));
  end

  -- Horizontal scrollbar: anchor to sb's BOTTOMLEFT/BOTTOMRIGHT so it spans
  -- exactly the viewport width and tracks any future width changes. Init
  -- with visibleExtentPercentage = sb_w / total_w so the thumb is sized
  -- proportionally (ScrollBarMixin handles the rest).
  if (hbar) then
    -- The bar frame is 8 tall (mirror of vertical's 8 wide). The 17-tall
    -- stepper buttons extend 4 px above and below the bar frame, so we
    -- anchor TOP 8 px below sb's BOTTOM: stepper top sits at sb's BOTTOM
    -- minus 4 (a clean 4 px gap), bar BOTTOM is 16 below sb, stepper
    -- BOTTOM is 20 below sb. Total reserved (HSCROLL_H) = 21 covers this
    -- with a little breathing room before the chrome.
    hbar:ClearAllPoints();
    hbar:SetPoint("TOPLEFT",  sb, "BOTTOMLEFT",  0, -8);
    hbar:SetPoint("TOPRIGHT", sb, "BOTTOMRIGHT", 0, -8);
    if (hbar_visible) then
      -- Show BEFORE SetVisibleExtentPercentage so the track has a measured
      -- width when ScrollBarMixin:Update computes the proportional thumb
      -- extent. If track width is 0 at compute time, the framework clamps
      -- the thumb to the track and HIDES it ( showThumb = not clamped ).
      hbar:Show();
      local total_w = content_w + 4;
      local visible_pct = (total_w > 0) and (sb_w / total_w) or 1;
      if (hbar.SetVisibleExtentPercentage) then
        hbar:SetVisibleExtentPercentage(visible_pct);
      end
      -- Re-apply current scroll percent so Container's anchor X matches the
      -- bar position after a resize (the OnScroll callback reads the new
      -- hScrollOverflow). Clamp to 0..1 since the previous percent may have
      -- corresponded to a larger overflow that no longer exists.
      local p = (hbar.GetScrollPercentage and hbar:GetScrollPercentage()) or 0;
      if (p > 1) then p = 1; end
      if (p < 0) then p = 0; end
      container:ClearAllPoints();
      container:SetPoint("TOPLEFT", sc, "TOPLEFT", 2 - p * h_overflow, -2);
    else
      hbar:Hide();
      -- No horizontal overflow: reset Container to its default TOPLEFT(2,-2)
      -- so it isn't stuck shifted from a previous (capped) layout.
      container:ClearAllPoints();
      container:SetPoint("TOPLEFT", sc, "TOPLEFT", 2, -2);
    end
  end

  sb:Show();
end

function TFuBag:LayoutWindowFree(frame, PAD_TOP, PAD_BOTTOM, show_cat_names, CATNAME_H)
  local framename = frame:GetName();
  local cfg = frame.cfg;
  local baritm = frame.BARITM;
  local calc_dat = {};
  local colmax = cfg["maxColumns"];

  self:SeedCatLayout(frame, calc_dat);

  local cat_layout = cfg.cat_layout;

  -- Trim leading empty columns/rows: shift the whole layout so the left-most and
  -- top-most occupied cells sit at the origin. The window already shrinks to the
  -- right/bottom edges (via the rightmost cell), so without this, dragging a box
  -- past the left edge -- which pushes every other box right -- would leave that
  -- empty space on the left permanently when the box is moved back. Normalising
  -- every layout makes the left/top reclaim space symmetrically with right/bottom.
  do
    local minX, minY;
    for barnum = 1, self.BAR_MAX do
      local rec = cat_layout[barnum];
      if (rec and table.getn(baritm[barnum]) > 0) then
        local gx = rec.gx or 0;
        local gy = rec.gy or 0;
        if (not minX or gx < minX) then minX = gx; end
        if (not minY or gy < minY) then minY = gy; end
      end
    end
    local sx = (minX and minX > 0) and minX or 0;
    local sy = (minY and minY > 0) and minY or 0;
    if (sx > 0 or sy > 0) then
      for barnum = 1, self.BAR_MAX do
        local rec = cat_layout[barnum];
        if (rec) then
          rec.gx = (rec.gx or 0) - sx;
          rec.gy = (rec.gy or 0) - sy;
        end
      end
    end
  end

  local pitchX, pitchY = self:MLGridPitch(frame);
  local label_gap = (show_cat_names and CATNAME_H or 0);
  -- Per-row vertical spacing, applied once per band (NOT per cell): the name-label
  -- headroom plus the same Y Pool + Category Spacing the auto-flow puts between
  -- rows. Applied per band so it never accumulates with box height -- this is what
  -- keeps ML-on row spacing equal to ML-off instead of ballooning.
  local row_gap = label_gap + frame:PoolY(1) + (cfg.cat_spacing or 0);

  -- Rows are "bands" keyed by their shared BOTTOM cell (gy + rows); boxes that
  -- bottom-align in the same row share a band even though their tops differ. The
  -- name label sits ~CATNAME_H above its box and the auto-flow leaves a Pool/
  -- Category-Spacing gap between rows, so push a box in the Nth band (0-based, top
  -- first) down by N*row_gap. (Mirrors the auto-flow's per-row spacing.)
  local band_rank = {};
  do
    local bottoms, seen = {}, {};
    for barnum = 1, self.BAR_MAX do
      local rec = cat_layout[barnum];
      local n = table.getn(baritm[barnum]);
      if (rec and n > 0) then
        local cols = rec.cols or 1;
        if (cols < 1) then cols = 1; end
        if (cols > colmax) then cols = colmax; end
        local rows = math.ceil(n / cols);
        if (rows < 1) then rows = 1; end
        local bottom = (rec.gy or 0) + rows;
        if (not seen[bottom]) then seen[bottom] = true; table.insert(bottoms, bottom); end
      end
    end
    table.sort(bottoms);
    for i = 1, table.getn(bottoms) do band_rank[bottoms[i]] = i - 1; end
  end

  -- Window/content width: rightmost box's right edge in Container coords (which
  -- has its origin at the inside of the chrome, so the leading BORDER is on the
  -- ScrollBox's offset, NOT in px). Outer window width still adds 2*BORDER.
  -- Bars are positioned against the Container (which lives inside ScrollChild,
  -- which lives inside the WowScrollBox); the framework clips at the ScrollBox.
  local scname = framename.."_Scroll_ScrollChild_Container";
  local max_right_sc = 0;
  for barnum = 1, self.BAR_MAX do
    local rec = cat_layout[barnum];
    if (rec and table.getn(baritm[barnum]) > 0) then
      local cols = rec.cols or 1;
      if (cols < 1) then cols = 1; end
      if (cols > colmax) then cols = colmax; end
      local gx = rec.gx or 0; if (gx < 0) then gx = 0; end
      local right = gx * pitchX + frame:FrameX(cols);
      if (right > max_right_sc) then max_right_sc = right; end
    end
  end
  if (max_right_sc < 1) then max_right_sc = frame:FrameX(1); end
  local window_width = max_right_sc + 2 * self.BORDER + self.SB_COL;

  -- Headroom at the top for the topmost band's name labels. PAD_TOP is the chrome
  -- inset (handled by the ScrollBox's TOPLEFT offset), so top_reserve carries
  -- only the BORDER + label-row headroom inside the Container.
  local top_reserve = self.BORDER + label_gap;
  local max_bottom = 0;

  for barnum = 1, self.BAR_MAX do
    local barname = framename.."_bar_"..barnum;
    local bf = _G[barname];
    local bb = _G[framename.."_BarButton_"..barnum];
    if (bb) then bb:Hide(); end

    local n = table.getn(baritm[barnum]);
    local rec = cat_layout[barnum];
    if (bf and n > 0 and rec) then
      local cols = rec.cols or 1;
      if (cols < 1) then cols = 1; end
      if (cols > colmax) then cols = colmax; end
      local rows = math.ceil(n / cols);
      if (rows < 1) then rows = 1; end
      local gx = rec.gx or 0; if (gx < 0) then gx = 0; end
      local gy = rec.gy or 0; if (gy < 0) then gy = 0; end

      local px = gx * pitchX;
      local py = top_reserve + gy * pitchY + (band_rank[gy + rows] or 0) * row_gap;

      -- Position bars at raw Container coords. The WowScrollBox + ScrollChild
      -- (.scrollable=true) framework handles scrolling and pixel-clips bars
      -- past the ScrollBox edge -- no manual scroll offset or visibility hide.
      self:PositionFrame(barname, "TOPLEFT", scname, "TOPLEFT",
        px, 0 - py, frame:FrameX(cols), frame:FrameY(rows));

      self:ColorFrame(cfg, bf, barnum);

      TFuBag:AssignButtonsToFrame(frame, barnum, barname, cols, rows);
      bf:Show();
      self:SetBarDraggable(frame, barnum, bf, true, show_cat_names, label_gap);

      -- Name label: center over the box when it fits the box columns; when it is
      -- wider, justify toward the ScrollChild interior at an edge (so it never runs
      -- off-viewport), else center with symmetric overhang. Coordinates are in
      -- ScrollChild space here, so the edges are 0 and max_right_sc.
      local label = bf.CatName;
      if (label) then
        if (show_cat_names) then
          label:SetWordWrap(false);
          label:SetWidth(0);
          label:SetText(self:GetBarCategoryName(baritm[barnum]));
          label:ClearAllPoints();
          local box_w = frame:FrameX(cols);
          local title_w = label:GetStringWidth();
          local edge_margin = frame:FrameX(0) + frame.BF_X_PAD;
          if (title_w <= box_w) then
            label:SetJustifyH("CENTER");
            label:SetPoint("BOTTOM", bf, "TOP", 0, 1);
          else
            local box_center = px + box_w / 2;
            if (box_center - title_w / 2 < 0) then
              label:SetJustifyH("LEFT");
              label:SetPoint("BOTTOMLEFT", bf, "TOPLEFT", edge_margin, 1);
            elseif (box_center + title_w / 2 > max_right_sc) then
              label:SetJustifyH("RIGHT");
              label:SetPoint("BOTTOMRIGHT", bf, "TOPRIGHT", -edge_margin, 1);
            else
              label:SetJustifyH("CENTER");
              label:SetPoint("BOTTOM", bf, "TOP", 0, 1);
            end
          end
          label:Show();
          self:WireCatTitleClick(frame, bf, baritm[barnum], true);
        else
          label:Hide();
          self:WireCatTitleClick(frame, bf, nil, false);
        end
      end

      local box_bottom = py + frame:FrameY(rows);
      if (box_bottom > max_bottom) then max_bottom = box_bottom; end
    elseif (bf) then
      bf:Hide();
      self:SetBarDraggable(frame, barnum, bf, false);
      local label = bf.CatName;
      if (label) then label:Hide(); end
      self:WireCatTitleClick(frame, bf, nil, false);
    end
  end

  if (max_bottom < 1) then max_bottom = top_reserve + frame:FrameY(1); end

  frame:SetWidth(window_width);
  frame:SetHeight(PAD_TOP + max_bottom + PAD_BOTTOM + self.BORDER + frame:PoolY(1));
  self:UpdateScrollViewport(frame, PAD_TOP, PAD_BOTTOM, max_right_sc, max_bottom, true);
  return frame:GetHeight();
end

-- ===== Manual Layout: FREE PLACEMENT mode (Stage 1) =====
-- Parallel to the grid path, selected by cfg.ml_freeplace. Positions live in
-- cat_layout_free as FRACTIONAL cell coords {fx, fy, cols} -- pixels/button-size,
-- so they rescale, but are NOT snapped to whole cells. No bottom-align bands: each
-- box is positioned by its own top-left and its title sits directly above it, so a
-- box can line up by title (top) or by bottom freely. Edge-dock + spacing-based
-- snap come in Stage 2; Stage 1 is free movement with the window growing to fit.

-- First-enable snapshot: read the auto-flow's rendered box positions and store them
-- as fractional coords relative to the top-left-most box, so enabling free mode the
-- first time looks like the ML-off layout.
function TFuBag:SnapshotCatLayoutFree(frame)
  local framename = frame:GetName();
  local cfg = frame.cfg;
  local baritm = frame.BARITM;
  local store = cfg.cat_layout_free;
  local cellX = frame.BF_PADWIDTH + cfg.frameXSpace;
  local cellY = frame.BF_PADHEIGHT + cfg.frameYSpace;

  local boxes = {};
  local minLeft, maxTop;
  for bn = 1, self.BAR_MAX do
    local bf = _G[framename.."_bar_"..bn];
    if (bf and bf:IsShown() and table.getn(baritm[bn]) > 0) then
      local l, tp, w = bf:GetLeft(), bf:GetTop(), bf:GetWidth();
      if (l and tp and w) then
        local cols = math.floor((w - cfg.frameXSpace) / cellX + 0.5);
        if (cols < 1) then cols = 1; end
        table.insert(boxes, { bn = bn, l = l, tp = tp, cols = cols });
        if (not minLeft or l < minLeft) then minLeft = l; end
        if (not maxTop or tp > maxTop) then maxTop = tp; end
      end
    end
  end
  if (not minLeft) then return; end
  for _, b in ipairs(boxes) do
    store[b.bn] = {
      fx = (b.l - minLeft) / cellX,
      fy = (maxTop - b.tp) / cellY,   -- screen-down is +fy
      cols = b.cols,
    };
  end
end

-- Give any item-bearing bar that has no free record yet (a category that appeared
-- after the snapshot) a position below the occupied area.
function TFuBag:SeedCatLayoutFree(frame)
  local cfg = frame.cfg;
  local baritm = frame.BARITM;
  local store = cfg.cat_layout_free;
  local colmax = cfg.maxColumns;

  local maxBottom, any = 0, false;
  for bn = 1, self.BAR_MAX do
    local rec = store[bn];
    if (rec and table.getn(baritm[bn]) > 0) then
      any = true;
      local cols = rec.cols or 1; if (cols < 1) then cols = 1; end
      local rows = math.ceil(table.getn(baritm[bn]) / cols); if (rows < 1) then rows = 1; end
      local b = (rec.fy or 0) + rows;
      if (b > maxBottom) then maxBottom = b; end
    end
  end

  local fx, fy = 0, (any and maxBottom or 0);
  for bn = 1, self.BAR_MAX do
    local n = table.getn(baritm[bn]);
    if (n > 0 and not store[bn]) then
      local cols = math.min(n, colmax); if (cols < 1) then cols = 1; end
      store[bn] = { fx = fx, fy = fy, cols = cols };
      fx = fx + cols;
      if (fx >= colmax) then fx = 0; fy = fy + math.ceil(n / cols); end
    end
  end
end

function TFuBag:LayoutWindowFreePlace(frame, PAD_TOP, PAD_BOTTOM, show_cat_names, CATNAME_H)
  local framename = frame:GetName();
  local cfg = frame.cfg;
  local baritm = frame.BARITM;
  local colmax = cfg["maxColumns"];
  local store = cfg.cat_layout_free;
  local cellX = frame.BF_PADWIDTH + cfg.frameXSpace;
  local cellY = frame.BF_PADHEIGHT + cfg.frameYSpace;
  local label_gap = (show_cat_names and CATNAME_H or 0);

  self:SeedCatLayoutFree(frame);

  -- Re-anchor the origin to the left/top-most occupied box (shift by the minimum,
  -- whatever its sign). A NEGATIVE min means a box was dragged past the left/top
  -- edge: shifting everything right/down by -min grows the layout on that side and
  -- lands the dragged box at the new edge. A POSITIVE min means leading empty space:
  -- the same shift reclaims it. So both edges grow and shrink symmetrically.
  do
    local minX, minY;
    for bn = 1, self.BAR_MAX do
      local rec = store[bn];
      if (rec and table.getn(baritm[bn]) > 0) then
        if (not minX or (rec.fx or 0) < minX) then minX = rec.fx or 0; end
        if (not minY or (rec.fy or 0) < minY) then minY = rec.fy or 0; end
      end
    end
    local sx = minX or 0;
    local sy = minY or 0;
    if (sx ~= 0 or sy ~= 0) then
      for bn = 1, self.BAR_MAX do
        local rec = store[bn];
        if (rec) then rec.fx = (rec.fx or 0) - sx; rec.fy = (rec.fy or 0) - sy; end
      end
    end
  end

  -- top_reserve in Container coords: only BORDER + label-row headroom; the
  -- chrome inset (PAD_TOP) lives on the ScrollBox's TOPLEFT offset.
  local top_reserve = self.BORDER + label_gap;
  local scname = framename.."_Scroll_ScrollChild_Container";
  local max_right, max_bottom = 0, 0;

  -- Content width up front (rightmost box edge) in ScrollChild coords, so the
  -- title edge-justify below can tell when a centered title would run off-viewport.
  local content_w = 0;
  for barnum = 1, self.BAR_MAX do
    local rec = store[barnum];
    if (rec and table.getn(baritm[barnum]) > 0) then
      local cols = rec.cols or 1;
      if (cols < 1) then cols = 1; end
      if (cols > colmax) then cols = colmax; end
      local fx = rec.fx or 0; if (fx < 0) then fx = 0; end
      local right = fx * cellX + frame:FrameX(cols);
      if (right > content_w) then content_w = right; end
    end
  end
  if (content_w < frame:FrameX(1)) then content_w = frame:FrameX(1); end

  for barnum = 1, self.BAR_MAX do
    local barname = framename.."_bar_"..barnum;
    local bf = _G[barname];
    local bb = _G[framename.."_BarButton_"..barnum];
    if (bb) then bb:Hide(); end

    local n = table.getn(baritm[barnum]);
    local rec = store[barnum];
    if (bf and n > 0 and rec) then
      local cols = rec.cols or 1;
      if (cols < 1) then cols = 1; end
      if (cols > colmax) then cols = colmax; end
      local rows = math.ceil(n / cols);
      if (rows < 1) then rows = 1; end
      local fx = rec.fx or 0; if (fx < 0) then fx = 0; end
      local fy = rec.fy or 0; if (fy < 0) then fy = 0; end

      local px = fx * cellX;
      local py = top_reserve + fy * cellY;
      self:PositionFrame(barname, "TOPLEFT", scname, "TOPLEFT",
        px, 0 - py, frame:FrameX(cols), frame:FrameY(rows));

      self:ColorFrame(cfg, bf, barnum);
      TFuBag:AssignButtonsToFrame(frame, barnum, barname, cols, rows);
      bf:Show();
      self:SetBarDraggable(frame, barnum, bf, true, show_cat_names, label_gap);

      local label = bf.CatName;
      if (label) then
        if (show_cat_names) then
          label:SetWordWrap(false);
          label:SetWidth(0);
          label:SetText(self:GetBarCategoryName(baritm[barnum]));
          label:ClearAllPoints();
          -- Same center / edge-justify rule as the grid and auto-flow: center over
          -- the box when the title fits; otherwise justify toward the interior at
          -- the ScrollChild edge so it never runs off-viewport.
          local box_w = frame:FrameX(cols);
          local title_w = label:GetStringWidth();
          local edge_margin = frame:FrameX(0) + frame.BF_X_PAD;
          if (title_w <= box_w) then
            label:SetJustifyH("CENTER");
            label:SetPoint("BOTTOM", bf, "TOP", 0, 1);
          else
            local box_center = px + box_w / 2;
            if (box_center - title_w / 2 < 0) then
              label:SetJustifyH("LEFT");
              label:SetPoint("BOTTOMLEFT", bf, "TOPLEFT", edge_margin, 1);
            elseif (box_center + title_w / 2 > content_w) then
              label:SetJustifyH("RIGHT");
              label:SetPoint("BOTTOMRIGHT", bf, "TOPRIGHT", -edge_margin, 1);
            else
              label:SetJustifyH("CENTER");
              label:SetPoint("BOTTOM", bf, "TOP", 0, 1);
            end
          end
          label:Show();
          self:WireCatTitleClick(frame, bf, baritm[barnum], true);
        else
          label:Hide();
          self:WireCatTitleClick(frame, bf, nil, false);
        end
      end

      local right = px + frame:FrameX(cols);
      if (right > max_right) then max_right = right; end
      local bottom = py + frame:FrameY(rows);
      if (bottom > max_bottom) then max_bottom = bottom; end
    elseif (bf) then
      bf:Hide();
      self:SetBarDraggable(frame, barnum, bf, false);
      local label = bf.CatName;
      if (label) then label:Hide(); end
      self:WireCatTitleClick(frame, bf, nil, false);
    end
  end

  if (max_right < 1) then max_right = frame:FrameX(1); end
  if (max_bottom < 1) then max_bottom = top_reserve + frame:FrameY(1); end

  frame:SetWidth(max_right + 2 * self.BORDER + self.SB_COL);
  frame:SetHeight(PAD_TOP + max_bottom + PAD_BOTTOM + self.BORDER + frame:PoolY(1));
  self:UpdateScrollViewport(frame, PAD_TOP, PAD_BOTTOM, max_right, max_bottom, true);
  return frame:GetHeight();
end

function TFuBag:LayoutWindow(frame)
  local framename = frame:GetName()
  -- Cap-to-screen + scroll for the bank: anchor the category bars into the scroll
  -- Container (content-sized) instead of the main window frame, and cap the window
  -- height (UpdateScrollViewport cap), so the WowScrollBox scrolls the overflow
  -- (same machinery Manual Layout uses). Bank-only for now to avoid regressing the
  -- inventory; extend once verified. scname is the Container's global name.
  local scroll_cap = (frame == TFuBnkFrame)
  local scname = framename.."_Scroll_ScrollChild_Container"
  local bar_anchor = scroll_cap and scname or framename
  local cfg = frame.cfg
  local baritm = frame.BARITM
  local bar_x = cfg.bar_x
  local edit_mode = frame.edit_mode
  local assignfunc = frame.AssignButtonsToFrame
  -- Category Spacing: extra hard gap between adjacent category bars (both axes),
  -- on top of the existing Space/Pool budgets. Default 0 leaves layout unchanged.
  local cat_spacing = cfg.cat_spacing or 0
  -- Category Names: when on, each drawn bar shows its category name in a label
  -- above it. We reserve CATNAME_H of vertical room per bar (in the inter-row gap
  -- and the window top) so the labels never overlap the bar above.
  local show_cat_names = (cfg.show_cat_names == 1)
  local CATNAME_H = 14
  local PAD_BOTTOM = 0;
  local PAD_TOP = 0;
  local calc_dat = {}
  local barnum, slot;
  local barframe = {};
  local tmpframe;
  local iBar;
  local drew_row = false;
  -- Grow the window by the horizontal gaps a full row needs (bar_x-1 gaps); the
  -- bars below are shifted left by the same total, so the left border is kept.
  local available_width = frame:FrameX(cfg["maxColumns"])
      + frame:SpaceX(bar_x-1) + frame:PoolX(bar_x+1) + (2 * self.BORDER)
      + ((bar_x - 1) * cat_spacing);
  local width_in_between;

  if (framename == "TFuInvFrame") then
    if (TFuInv_SearchBox:IsVisible() or TFuInvFrame_Total:IsVisible() or
        TFuInvacterBag3Slot:IsVisible() or TFuInvFrame_MoneyFrame:IsVisible()) then
        PAD_BOTTOM = PAD_BOTTOM + self.PAD_BOTTOM_NORM;
    end
    if (edit_mode == 1) then
      PAD_BOTTOM = PAD_BOTTOM + self.PAD_BOTTOM_EDIT;
    end
     -- If we need the extra row...  add it in.
    if ((TFuInv_SearchBox:IsVisible()
        and (TFuInvFrame_Total:IsVisible() or TFuInvacterBag3Slot:IsVisible())) or
        TFuInvFrame_MoneyFrame:IsVisible() and TFuInvFrame_TokenFrame:IsVisible()) then
      PAD_BOTTOM = PAD_BOTTOM + self.PAD_BOTTOM_SEARCH;
    end
    if (PAD_BOTTOM > 0) then
      -- If there's anything at the bottom add the spacer
      PAD_BOTTOM = PAD_BOTTOM + self.PAD_BOTTOM_SPACER;
    end
    if (TFuInv_UserDropdown:IsVisible() or TFuInv_Button_HighlightToggle:IsVisible() or
        TFuInv_Button_ChangeEditMode:IsVisible() or TFuInv_Button_ShowBank:IsVisible() or
        TFuInv_Button_Reload:IsVisible() or TFuInv_Button_Close:IsVisible() or
        TFuInv_Button_MoveLockToggle:IsVisible()) then
       PAD_TOP = self.PAD_TOP_NORM;
     end
 else
    -- TFuBnkFrame
    -- Stage 2: the per-tab selector strip shares the bottom Total row (the classic
    -- bag-slot grid is gone), so reserving the normal bottom row covers it. Trigger
    -- the reservation on the strip too, so the row is kept even if Total is hidden.
    local strip_shown = TFuBnkFrame.TabStrip and TFuBnkFrame.TabStrip:IsShown();
    if (TFuBnkFrame_Total:IsVisible() or TFuBnkFrameBagBank:IsVisible() or strip_shown or
        TFuBnkFrame_MoneyFrame:IsVisible() or TFuBnkFrame_TokenFrame:IsVisible()) then
      PAD_BOTTOM = PAD_BOTTOM + self.PAD_BOTTOM_NORM;
    end
    if (edit_mode == 1) then
      PAD_BOTTOM = PAD_BOTTOM + self.PAD_BOTTOM_EDIT;
    end

    -- Search box adds a row below the Total/strip row (same logic as inventory).
    if (TFuBnk_SearchBox:IsVisible() and
        (TFuBnkFrame_Total:IsVisible() or strip_shown)) then
      PAD_BOTTOM = PAD_BOTTOM + self.PAD_BOTTOM_SEARCH;
    end

    -- Do we need an extra row
    local bags_row = 0;
    if (TFuBnkFrameBagBank:IsVisible()) then
      bags_row = bags_row + 5;
    end
    if (TFuBnkFrame_Total:IsVisible()) then
      bags_row = bags_row + 1;
    end
    if TFuBnkFrame_MoneyFrame:IsVisible() or TFuBnkFrame_TokenFrame:IsVisible() then
      bags_row = bags_row + 4;
    end
    if (cfg["maxColumns"] <= bags_row or
       (TFuBnkFrame_MoneyFrame:IsVisible() and TFuBnkFrame_TokenFrame:IsVisible())) then
      PAD_BOTTOM = PAD_BOTTOM + self.PAD_BOTTOM_NORM;
    end

    if (PAD_BOTTOM > 0) then
      -- If there's anything at the bottom add the spacer
      PAD_BOTTOM = PAD_BOTTOM + self.PAD_BOTTOM_SPACER;
    end

    if (TFuBnk_UserDropdown:IsVisible() or TFuBnk_Button_HighlightToggle:IsVisible() or
        TFuBnk_Button_ChangeEditMode:IsVisible() or
        TFuBnk_Button_Reload:IsVisible() or TFuBnk_Button_DepositReagent:IsVisible() or
        TFuBnk_Button_Close:IsVisible() or TFuBnk_Button_MoveLockToggle:IsVisible()) then
      PAD_TOP = self.PAD_TOP_NORM;
    end
  end

  -- Manual Layout: freeform, drag-placed category containers. Only applies when
  -- viewing the LOGGED-IN character: cat_layout is account-wide and tailored to
  -- your own inventory (category set + box sizes), so applying it to an alt's
  -- different bags overlaps/stacks boxes. Viewing an alt falls through to the
  -- normal auto-flow. When already seeded, draw at the saved coords; on the first
  -- enable (no saved layout) run the auto-flow once below, then the tail snapshots
  -- it and re-lays-out freeform so enabling looks identical to ML-off.
  -- Legacy Edit forces the original auto-flow + classic edit path (no drag/placement).
  local use_ml = (cfg.manual_layout == 1 and cfg.legacy_edit ~= 1 and frame.playerid == TFuBag.PLAYERID);
  local ml_free = (cfg.ml_freeplace == 1);
  local ml_seed = false;
  if (use_ml) then
    local store = ml_free and cfg.cat_layout_free or cfg.cat_layout;
    local seeded = false;
    for bn = 1, self.BAR_MAX do
      if (store[bn]) then seeded = true; break; end
    end
    if (seeded) then
      if (ml_free) then
        return self:LayoutWindowFreePlace(frame, PAD_TOP, PAD_BOTTOM, show_cat_names, CATNAME_H);
      end
      return self:LayoutWindowFree(frame, PAD_TOP, PAD_BOTTOM, show_cat_names, CATNAME_H);
    end
    ml_seed = true;
  end

  -- Auto-flow path (ML off, or viewing an alt): make sure no category box is left
  -- mouse-grabbable from a previous freeform session, so the boxes stay inert --
  -- the whole window drags normally and item clicks are unobstructed.
  if (not use_ml) then
    for bn = 1, self.BAR_MAX do
      local bf = _G[framename.."_bar_"..bn];
      if (bf and bf.mlDragInit) then self:SetBarDraggable(frame, bn, bf, false); end
    end
  end

  -- ITEM BUTTONS
  local cur_y = frame:PoolY(1) + self.BORDER + PAD_BOTTOM;
  -- When anchoring bars to the scroll Container (scroll_cap) instead of the window,
  -- subtract the window's bottom chrome (== cur_y's initial value, the same value
  -- UpdateScrollViewport uses as bottom_pad): the Container spans only the content
  -- area, so bars must be measured from the content bottom, not the window bottom.
  local bottom_chrome = frame:PoolY(1) + self.BORDER + PAD_BOTTOM;

  -- Draw one row of up to bar_x consecutive bars starting at `barnum`. Reads/writes the
  -- cur_y / drew_row upvalues, so it serves both the dedicated bottom Empty row and the
  -- normal category rows below.
  local function drawRow(barnum, nbars)
    for iBar = 0, nbars - 1 do
      barframe[iBar] = _G[framename.."_bar_"..(barnum+iBar)];
      tmpframe = _G[framename.."_BarButton_"..(barnum+iBar)];
      if (edit_mode ~= 1) then
        -- we're not in edit mode, make sure the SlotTarget button and texture is hidden
        tmpframe:Hide();
      else
        tmpframe:Show();
      end
    end

    self:CalcBarLayout(calc_dat, baritm, barnum, nbars,
      cfg["maxColumns"], edit_mode);

    --- now we know the size and height of all bars for this line

    if (calc_dat["height"] == 0) then
      for iBar = 0, nbars - 1 do
        barframe[iBar]:Hide();
      end
    else
      -- Category Spacing: hard vertical gap above this row, but only between
      -- drawn rows (no leading gap before the first, none after empty rows).
      -- This gap also holds the name label of the row below it (CATNAME_H).
      if (drew_row) then
        cur_y = cur_y + cat_spacing + (show_cat_names and CATNAME_H or 0);
      end
      local cur_x = frame:PoolX(1) + (self.BORDER);
      local cur_width = 0;

      -- Find the space left over
      width_in_between = frame:FrameX(cfg["maxColumns"])
        + frame:SpaceX(bar_x-1) + frame:PoolX(bar_x-1);
      for iBar = 0, nbars - 1 do
        width_in_between = width_in_between - frame:FrameX(calc_dat[iBar.."_width"]);
      end

      -- Then position the frames appropriately
      for iBar = 0, nbars - 1 do
        if (calc_dat[iBar.."_width"] >= 0 and
            (table.getn(baritm[barnum+iBar]) > 0 or edit_mode == 1)) then
          -- Keep width separate to get roundoff staggering
          if (bar_x == 1) then
            cur_width = 0;
          else
            cur_width = math.floor(iBar * width_in_between / (bar_x - 1));
          end

          -- Distance from this bar's RIGHT edge in to the window's right border,
          -- captured now because cur_x is incremented below before the category
          -- name label (which needs it to decide if its text fits to the right).
          local bar_right_inset = cur_x + cur_width;

          -- Wrap this category's coloured box to its OWN occupied rows instead of
          -- the row's shared (tallest) height, so a sparse category (e.g. a single
          -- item next to a big one) gets a small box hugging its items rather than
          -- a tall box with the item stranded at the bottom. The box is anchored
          -- BOTTOMRIGHT, so a shorter height just brings its top (and its title)
          -- down to the items. Edit mode keeps the shared height: it places a bar
          -- button on the shared-height top row, which a shrunk box would clip.
          local bar_w = calc_dat[iBar.."_width"];
          if (bar_w < 1) then bar_w = 1; end
          local bar_rows = math.ceil(calc_dat[iBar] / bar_w);
          if (bar_rows < 1) then bar_rows = 1; end
          local bar_h = (edit_mode == 1) and calc_dat["height"] or bar_rows;

          -- When anchoring to the scroll Container (scroll_cap), the cur_x offset
          -- bakes in the window's right BORDER chrome, but the Container is the
          -- content area (no border) -- so add BORDER back to avoid shifting every
          -- bar left by that much (which clips the leftmost column). Mirror of the
          -- bottom_chrome subtraction on the vertical axis.
          self:PositionFrame(framename.."_bar_"..(barnum+iBar),
            "BOTTOMRIGHT", bar_anchor, "BOTTOMRIGHT",
            scroll_cap and (0-cur_x-cur_width + self.BORDER) or (0-cur_x-cur_width),
            scroll_cap and (cur_y - bottom_chrome) or cur_y,
            frame:FrameX(calc_dat[iBar.."_width"]),
            frame:FrameY(bar_h));

          -- Category Spacing: hard horizontal gap between adjacent category bars.
          cur_x = cur_x + frame:FrameX(calc_dat[iBar.."_width"]) + cat_spacing;

          -- Color the frame and assign buttons
          self:ColorFrame(cfg, barframe[iBar], (barnum+iBar));

          TFuBag:AssignButtonsToFrame(frame,(barnum+iBar), framename.."_bar_"..(barnum+iBar),
            calc_dat[iBar.."_width"], calc_dat["height"] );
            barframe[iBar]:Show();

          -- Category name label, in the reserved gap above the box. Buttons are
          -- centered in the box, so the box's top-center is also the items'
          -- center. Alignment rule:
          --   * title fits within the box columns        -> center over the box
          --   * wider than the box, at the RIGHT edge     -> right-justify (right
          --     edge over the items, text extends left, stays on-window)
          --   * wider than the box, at the LEFT edge      -> left-justify (mirror)
          --   * wider than the box, interior              -> center, overhanging
          --     into the empty gap on both sides
          -- "At an edge" = a centered title would cross that window border.
          -- Insets are from the window's right border (the box anchors
          -- BOTTOMRIGHT). GetStringWidth is valid right after SetText.
          local label = barframe[iBar].CatName;
          if (label) then
            if (show_cat_names) then
              label:SetWordWrap(false);
              label:SetWidth(0);   -- auto-size to full text (no truncation)
              label:SetText(self:GetBarCategoryName(baritm[barnum+iBar]));
              label:ClearAllPoints();
              local box_w = frame:FrameX(calc_dat[iBar.."_width"]);
              local title_w = label:GetStringWidth();
              -- A button's edge sits this far in from the box edge (buttons are
              -- centered in the box); justify titles to the items, not the box.
              local edge_margin = frame:FrameX(0) + frame.BF_X_PAD;
              if (title_w <= box_w) then
                label:SetJustifyH("CENTER");
                label:SetPoint("BOTTOM", barframe[iBar], "TOP", 0, 1);
              else
                local box_center = bar_right_inset + box_w/2;
                if (box_center - title_w/2 < self.BORDER) then
                  label:SetJustifyH("RIGHT");
                  label:SetPoint("BOTTOMRIGHT", barframe[iBar], "TOPRIGHT",
                    -edge_margin, 1);
                elseif (box_center + title_w/2 > available_width - self.BORDER) then
                  label:SetJustifyH("LEFT");
                  label:SetPoint("BOTTOMLEFT", barframe[iBar], "TOPLEFT",
                    edge_margin, 1);
                else
                  label:SetJustifyH("CENTER");
                  label:SetPoint("BOTTOM", barframe[iBar], "TOP", 0, 1);
                end
              end
              label:Show();
              self:WireCatTitleClick(frame, barframe[iBar], baritm[barnum+iBar], true);
            else
              label:Hide();
              self:WireCatTitleClick(frame, barframe[iBar], nil, false);
            end
          end
        else
          barframe[iBar]:Hide();
          self:WireCatTitleClick(frame, barframe[iBar], nil, false);
        end
      end

      cur_y = cur_y + frame:FrameY(calc_dat["height"]) + frame:PoolY(1);
      drew_row = true;
    end
  end

  -- Empty slots are one category drawn as a single box at the VERY bottom (below all
  -- categories). Draw it FIRST in the bottom-up flow; with no empties (and not in edit
  -- mode) CalcBarLayout reports height 0 and it is hidden, adding no bottom gap.
  drawRow(self.EMPTY_BAR, 1);

  -- Normal category rows (excludes EMPTY_BAR = BAR_MAX, which was drawn above).
  for barnum = 1, self.BAR_MAX - 1, bar_x do
    -- last row is partial when bar_x does not divide evenly; only existing bars touched.
    drawRow(barnum, math.min(bar_x, (self.BAR_MAX - 1) - barnum + 1));
  end

  -- (No leftover frames to hide: the rows above lay out every bar, including EMPTY_BAR
  -- and a partial final row when bar_x does not divide evenly.)

  local new_height;
  new_height = cur_y + PAD_TOP + frame:SpaceY(1) + frame:PoolY(1) + self.BORDER;

  -- Headroom for the topmost row's category name label (the inter-row gaps cover
  -- all the lower rows' labels; the top row's label sits above everything).
  if (show_cat_names and drew_row) then
    new_height = new_height + CATNAME_H;
  end

  frame:SetWidth( available_width );
  frame:SetHeight( new_height );

  -- Scroll viewport in auto-flow: bars here stay anchored to mainFrame BOTTOMRIGHT
  -- (not the ScrollChild), so the ScrollFrame doesn't actually scroll auto-flow
  -- content — it just needs to be sized to the content area so the reparented
  -- bars/items render unclipped. Window cap (step 4) applies only when ML is on.
  local af_content_w = available_width - 2 * self.BORDER;
  local af_content_h = new_height - PAD_TOP - PAD_BOTTOM - self.BORDER - frame:PoolY(1);
  if (af_content_w < 1) then af_content_w = 1; end
  if (af_content_h < 1) then af_content_h = 1; end
  self:UpdateScrollViewport(frame, PAD_TOP, PAD_BOTTOM, af_content_w, af_content_h, scroll_cap);

  -- Manual Layout first enable: the auto-flow above has positioned every box, so
  -- capture those positions and re-lay-out in the chosen Manual Layout mode.
  if (ml_seed) then
    if (ml_free) then
      self:SnapshotCatLayoutFree(frame);
      return self:LayoutWindowFreePlace(frame, PAD_TOP, PAD_BOTTOM, show_cat_names, CATNAME_H);
    end
    self:SnapshotCatLayout(frame);
    return self:LayoutWindowFree(frame, PAD_TOP, PAD_BOTTOM, show_cat_names, CATNAME_H);
  end

  return cur_y;
end

-----------------------------------------------------------------------
-- Stacking
-----------------------------------------------------------------------

local StackArr = {};

function TFuBag:CreateStackArr()
  local sa = StackArr;

  for k,_ in pairs(sa) do
    sa[k] = nil;
  end

  return StackArr;
end

local CompArr = { [self.COMP_EMPTY] = {}, [self.COMP_ITEM] = {} };

function TFuBag:CreateCompArr()
  local ca = CompArr;

  local epts = ca[self.COMP_EMPTY];
  local itms = ca[self.COMP_ITEM];

  for k,_ in pairs(epts) do
    epts[k] = nil;
  end

  for k,_ in pairs(itms) do
    itms[k] = nil;
  end

  return CompArr;
end

TFuBag.ISSTACKING = {
  [self.STACK_BNK] = nil,
  [self.STACK_INV] = nil,
};

function self:IsStacking(where)
  return self.ISSTACKING[where];
end

-- sa = stackarr, shortened to make the code manageable
-- ca = comparr
function TFuBag:Stack(where, itmcache, sa, ca)
--  UpdateAddOnMemoryUsage();
--  TFuBag:PrintDEBUG('Stack Start Memory = '..tostring(GetAddOnMemoryUsage("TFuBag")));

  -- Defer the stack if the cursor has an item on it.
  if GetCursorInfo() then return false end


  -- Set the mutex
  TFuBag.ISSTACKING[where] = 1;

  -- Iterate the list of items that can be stacked
  for itemid,itms in pairs(sa) do
    -- Sort the list of slots with the item in it by how
    -- big the stack is in descending order give
    -- precedence to items in special bags.
    table.sort(itms,
      function(a,b)
        if (a[TFuBag.I_COUNT] == b[TFuBag.I_COUNT]) then
          -- We only ever stack when on the current player so this is ok.
          return (TFuBag:GetBagType(TFuBag.PLAYERID,a[TFuBag.I_BAG]) or 0) >
                 (TFuBag:GetBagType(TFuBag.PLAYERID,b[TFuBag.I_BAG]) or 0)
        else
          return a[TFuBag.I_COUNT] > b[TFuBag.I_COUNT];
        end
      end);

    -- We start filling the largest stacks and pulling
    -- from the smallest stacks
    local dest = 1;
    local src = #itms;

    -- Unless there's more than one entry there's nothing to do.
    if (src > 1) then
      -- If the src and the dest are equal or have crossed each
      -- other we're done.
      while (src > dest) do
        local srcitm = itms[src];
        local destitm = itms[dest];

        if (destitm[self.I_NEED] >= srcitm[self.I_COUNT]) then
          -- Source will be used up filling dest.
          self:ItemMover(srcitm[self.I_BAG], srcitm[self.I_SLOT],
          destitm[self.I_BAG], destitm[self.I_SLOT]);

          -- Update counts
          destitm[self.I_NEED] = destitm[self.I_NEED] - srcitm[self.I_COUNT];
          destitm[self.I_COUNT] = destitm[self.I_COUNT] + srcitm[self.I_COUNT];

          -- source is now empty
          self:MakeEmptySlot(srcitm);
          -- Push empty slots onto the empty list for possible compression
          self:InsertEmptyInCompArr(ca,srcitm);
          -- Move on to the next source stack
          src = src - 1;
        else
          -- Source is larger than the destination need
          self:ItemMover(srcitm[self.I_BAG], srcitm[self.I_SLOT],
          destitm[self.I_BAG], destitm[self.I_SLOT],
          destitm[self.I_NEED]);

          -- Update counts
          destitm[self.I_NEED] = 0;
          destitm[self.I_COUNT] = destitm[self.I_COUNT] + destitm[self.I_NEED];
          srcitm[self.I_NEED] = srcitm[self.I_NEED] + destitm[self.I_NEED];
          srcitm[self.I_NEED] = srcitm[self.I_COUNT] - destitm[self.I_NEED];
        end
        -- Destination full move to the next one.
        if (destitm[self.I_NEED] == 0) then
          dest = dest + 1;
        end
      end
    end
  end
  if (ca and type(ca) == "table") then
    local epts = ca[self.COMP_EMPTY];
    local itms = ca[self.COMP_ITEM];
    local empty_size = table.getn(epts);
    local items_size = table.getn(itms);

    for empty = 1, empty_size do
      if (epts[empty]) then
        local emptyitm = epts[empty]
        local emptybag = emptyitm[self.I_BAG];
        local emptyslot = emptyitm[self.I_SLOT]
        -- Is it really empty.
        if (emptyitm[self.I_ITEMLINK] == nil) then
          for item = 1, items_size do
            if (itms[item]) then
              local itemitm = itms[item];
              local itembag = itemitm[self.I_BAG];
              local itemslot = itemitm[self.I_SLOT];
              if (itemitm[self.I_ITEMLINK] and
                not self:GetCompSkip(emptybag,emptyslot) and
                not self:GetCompSkip(itembag,itemslot)) then
                local bagtype = self:GetBagType(self.PLAYERID, emptyitm[self.I_BAG]);
                local itmfam = 0;
                if (itemitm[self.I_TYPE] ~= L["Container"]) then
                  itmfam = GetItemFamily(itemitm[self.I_ITEMLINK]);
                end

                -- Does the item go into this bag type?
                if (bagtype and itmfam) and
                    ((bagtype == 2048 and itemitm[self.I_CRAFTINGREAGENT]) or
                     (bit.band(bagtype,itmfam) ~= 0)) then
                  -- Drop one onto the other
                  self:ItemMover(itembag,itemslot,emptybag,emptyslot);

                  -- Empty out the dropped slot in the itmcache
                  self:MakeEmptySlot(itmcache[itemitm[self.I_BAG]][itemitm[self.I_SLOT]]);

                  -- Remove the item from consideration
                  itms[item] = nil;
                  break;
                end
              end
            end
          end
        end
      end
    end

    -- TFuBag.ISSTACKING gets cleared by the item mover coroutine for us.
    -- Has to stay on until coroutine finishes otherwise we end up with
    -- the stack and compress fighting each other.
  end

--  UpdateAddOnMemoryUsage();
--  TFuBag:PrintDEBUG('Stack End Memory = '..tostring(GetAddOnMemoryUsage("TFuBag")));
  return true
end

TFuBag.STACKSKIP = {};
TFuBag.STACKSPLIT = nil;

function TFuBag:ClearStackSkip(bagarr)
  self:ClearItmCache(self.STACKSKIP, bagarr);
end

function TFuBag:GetStackSkip(bag, slot)
  if (self.STACKSKIP[bag] == nil) then
    self.STACKSKIP[bag] = {};
  end
  return self.STACKSKIP[bag][slot];
end

function TFuBag:SetStackSkip(bag, slot, val)
  if (self.STACKSKIP[bag] == nil) then
    self.STACKSKIP[bag] = {};
  end
  self.STACKSKIP[bag][slot] = val;

--  if (val) then
--    self:Print("Skip ("..bag..", "..slot..") val="..val);
--  end
end

TFuBag.COMPSKIP = {};

function TFuBag:ClearCompSkip(bagarr)
  self:ClearItmCache(self.COMPSKIP, bagarr);
end

function TFuBag:GetCompSkip(bag, slot)
  if (self.COMPSKIP[bag] == nil) then
    self.COMPSKIP[bag] = {};
  end
  return self.COMPSKIP[bag][slot];
end

function self:SetCompSkip(bag, slot, val)
  if (self.COMPSKIP[bag] == nil) then
    self.COMPSKIP[bag] = {};
  end
  self.COMPSKIP[bag][slot] = val;
end

function TFuBag.SplitContainerItem(bag, slot, split)
  -- Put this slot on the black list
  TFuBag:SetStackSkip(bag, slot, 1);

  TFuBag.STACKSPLIT = 1;
end

hooksecurefunc(C_Container, "SplitContainerItem", TFuBag.SplitContainerItem);

function TFuBag.PickupContainerItem(bag, slot)
  -- Only skip a slot if we have just manually split
  if (TFuBag.STACKSPLIT) then
    TFuBag:SetStackSkip(bag, slot, 1);
  end
  TFuBag:SetCompSkip(bag, slot, 1);
  TFuBag.STACKSPLIT = nil;
end

hooksecurefunc(C_Container, "PickupContainerItem", TFuBag.PickupContainerItem);

-- array to hold the instructions
-- don't edit this directly use TFuBag:ItemMover.
local ItemMover__instructions = {};

-- Insert a move instruction into the list to do.
-- If count is not > 0 then it will just pickup everything
-- in bag1, slot1 otherwise it will split count off.
function TFuBag:ItemMover(bag1, slot1, bag2, slot2, count)
  local inst = {
    ["from_bag"]  = bag1,
    ["from_slot"] = slot1,
    ["to_bag"]    = bag2,
    ["to_slot"]   = slot2,
    ["count"] = count
  };
  table.insert(ItemMover__instructions,1,inst);
end

-- Main function for the mover coroutine.  This is an infinite loop
-- that runs the whole time the addon is up.  If there is nothing to
-- do it yields back.
local function ItemMover__main(instructions)
  local instructions = instructions;
  while true do
    instruction_count = table.getn(instructions);
    if (instruction_count > 0) then
      for index = instruction_count, 1, -1 do
        local inst = instructions[index];
        local _,_,locked1 = GetContainerItemInfo(inst.from_bag,inst.from_slot);
        local _,_,locked2 = GetContainerItemInfo(inst.to_bag,inst.to_slot);

        if ((not locked1) and (not locked2)) then
          ClearCursor();
          if (inst.count and inst.count > 0) then
            SplitContainerItem(inst.from_bag,inst.from_slot,inst.count);
          else
            PickupContainerItem(inst.from_bag,inst.from_slot);
            TFuBag:SetStackSkip(inst.from_bag,inst.from_slot,nil);
            TFuBag:SetCompSkip(inst.from_bag,inst.from_slot,nil);
          end
          PickupContainerItem(inst.to_bag,inst.to_slot);
          TFuBag:SetStackSkip(inst.to_bag,inst.to_slot,nil);
          TFuBag:SetCompSkip(inst.to_bag,inst.to_slot,nil);
          ClearCursor();
          table.remove(instructions,index);
        end
      end
    else
      -- Done stacking
      TFuBag.ISSTACKING[TFuBag.STACK_BNK] = nil;
      TFuBag.ISSTACKING[TFuBag.STACK_INV] = nil;
    end
    instructions = coroutine.yield(instructions);
  end
end

-- Create the coroutine for handling moves.
local ItemMover__co = coroutine.create(ItemMover__main);

-- resume the coroutine
local function ItemMover_Resume()
  if (coroutine.status(ItemMover__co) == "suspended") then
    local _
    _,instructions = coroutine.resume(ItemMover__co,ItemMover__instructions);
  end
end

function TFuBag:OnUpdate()
  ItemMover_Resume();
end


-----------------------------------------------------------------------
-- Inits and Events
-----------------------------------------------------------------------

function TFuBag:UserDropdown_Init(onclickfunc, TItm, curplayer, selRealm,level)
  local info;
  local users = {};

  -- List EVERY cached character. The old code filtered to realm == selRealm, which
  -- hid all alts whose stored realm string differed from the current realm -- i.e.
  -- everyone on a connected/sister realm, or anyone cached under a differently
  -- formatted realm name -- leaving only the current character in the dropdown.
  for key, value in pairs(TItm) do
    table.insert(users, key);
  end

  -- Sort and add them
  table.sort(users);
  for _, key in ipairs(users) do
    local name, realm = strsplit("|", key);
    info = {};
    -- Disambiguate same-named alts: show the realm when it isn't the current one.
    if (realm and realm ~= "" and realm ~= selRealm) then
      info.text = name.." - "..realm;
    else
      info.text = name;
    end
    info.value = key;
    info.func = onclickfunc;
    if (key == curplayer) then
      info.checked = 1;
    end
    UIDropDownMenu_AddButton(info,level);
  end
end

-- For some resaon CreateFrame doesn't always properly set frame levels right
-- The UIDropDownMenu code depends on it working properly.  When it doesn't work
-- properly the buttons end up with a frame level of 2 and ends up behind the
-- parent window which is the background.  As a result they appear grayed out
-- and unclickable.  This iterates the frames and sets them to their proper frame
-- level.
function TFuBag:FixMenuFrameLevels()
  for l=1,UIDROPDOWNMENU_MAXLEVELS do
    for b=1,UIDROPDOWNMENU_MAXBUTTONS do
      local button = _G["DropDownList"..l.."Button"..b]
      if button then
        local button_parent = button:GetParent()
        if button_parent then
          local button_level = button:GetFrameLevel()
          local parent_level = button_parent:GetFrameLevel()
          if button_level <= parent_level then
            button:SetFrameLevel(parent_level + 2)
          end
        end
      end
    end
  end
end
