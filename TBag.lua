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
TFuBag.BAR_MAX = 32;
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
TFuBag.BAGMAX = 11;
TFuBag.MAX_REAGENTBANK_ITEMS = 98 -- has to be a constant since game can't tell us in time
-- Reagent bag (Enum.BagIndex.ReagentBag = 5, added 10.0) appended last so the
-- existing bag layout order is unchanged; GetContainerNumSlots(5) is 0 when no
-- reagent bag is equipped, so the section degrades to empty/hidden cleanly.
TFuBag.Inv_Bags = { BACKPACK_CONTAINER, 4, 3, 2, 1, 5 };

TFuBag.Bnk_Bags = { BANK_CONTAINER, REAGENTBANK_CONTAINER, 5, 6, 7, 8, 9, 10, 11 };
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
      local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, iconFileDataID = GetItemInfo(itemid);
      return itemName, itemType, itemSubType, itemRarity, itemLink, itemStackCount;
    else
      local _,species,_,quality = strsplit(":", itemid)
      local itemName = C_PetJournal.GetPetInfoBySpeciesID(species)
      return itemName, "Miscellaneous", "Companion Pets", quality, itemid, 1
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

  self:SetCatBar(cfg, L["TRADE_GOODS"], 19, reset);
  self:SetCatBar(cfg, L["ALCHEMY"], 19, reset);
  self:SetCatBar(cfg, L["BLACKSMITHING"], 19, reset);
  self:SetCatBar(cfg, L["ENCHANTING"], 19, reset);
  self:SetCatBar(cfg, L["ENGINEERING"], 19, reset);
  self:SetCatBar(cfg, L["JEWELCRAFTING"], 19, reset);
  self:SetCatBar(cfg, L["LEATHERWORKING"], 19, reset);
  self:SetCatBar(cfg, L["MINING"], 19, reset);
  self:SetCatBar(cfg, L["TAILORING"], 19, reset);
  self:SetCatBar(cfg, L["INSCRIPTION"], 19, reset);

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

  self:SetCatBar(cfg, string.format(L["EQUIPPED_%s"],L["RING"]), 10, reset);
  self:SetCatBar(cfg, string.format(L["EQUIPPED_%s"],L["TRINKET"]), 10, reset);
  self:SetCatBar(cfg, string.format(L["EQUIPPED_%s"],L["OTHER"]), 10, reset);

  self:SetCatBar(cfg, string.format(L["EQUIPPED_%s"],L["01_HEAD"]), 9, reset);
  self:SetCatBar(cfg, string.format(L["EQUIPPED_%s"],L["02_NECK"]), 9, reset);
  self:SetCatBar(cfg, string.format(L["EQUIPPED_%s"],L["03_SHOULDER"]), 9, reset);
  self:SetCatBar(cfg, string.format(L["EQUIPPED_%s"],L["04_BACK"]), 9, reset);
  self:SetCatBar(cfg, string.format(L["EQUIPPED_%s"],L["05_CHEST"]), 9, reset);
  self:SetCatBar(cfg, string.format(L["EQUIPPED_%s"],L["06_SHIRT"]), 9, reset);
  self:SetCatBar(cfg, string.format(L["EQUIPPED_%s"],L["07_TABARD"]), 9, reset);
  self:SetCatBar(cfg, string.format(L["EQUIPPED_%s"],L["08_WRIST"]), 9, reset);
  self:SetCatBar(cfg, string.format(L["EQUIPPED_%s"],L["09_HANDS"]), 9, reset);
  self:SetCatBar(cfg, string.format(L["EQUIPPED_%s"],L["10_WAIST"]), 9, reset);
  self:SetCatBar(cfg, string.format(L["EQUIPPED_%s"],L["11_LEGS"]), 9, reset);
  self:SetCatBar(cfg, string.format(L["EQUIPPED_%s"],L["12_FEET"]), 9, reset);
  self:SetCatBar(cfg, string.format(L["EQUIPPED_%s"],L["13_OFFHAND"]), 9, reset);
  self:SetCatBar(cfg, string.format(L["EQUIPPED_%s"],L["ARMOR"]), 9, reset);
  self:SetCatBar(cfg, string.format(L["EQUIPPED_%s"],L["WEAPON"]), 9, reset);

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
  cfg["item_search_list"] = self.DefaultSearchList;
end

-- set reset to 1 to restore all default values
function TFuBag:InitDefVals(cfg, bagarr, row1offset, reset)
  local i, key, value;

  self:SetDef(cfg, "moveLock", 1, reset, self.NumFunc, 0,1);
  self:SetDef(cfg, "show_bag_icons", 0, reset, self.NumFunc, 0, 1);
  self:SetDef(cfg, "spotlight_open", 1, reset, self.NumFunc, 0, 1);
  self:SetDef(cfg, "spotlight_hover", 1, reset, self.NumFunc, 0, 1);
  self:SetDef(cfg, "show_rarity_color", 1, reset, self.NumFunc, 0, 1);

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
  -- Bag 5 is the live reagent bag (Enum.BagIndex.ReagentBag). The old bank model
  -- also numbered its first bank bag 5, but the bank module is gated off pending
  -- a C_Bank rewrite (which uses CharacterBankTab_* ids, not 5), so labeling 5 as
  -- the reagent bag is correct for current behavior. Revisit in the bank rewrite.
  if (bag == 5) then return L["Reagent Bag"]; end
  if (bag == 6) then return L["Second Bank Bag"]; end
  if (bag == 7) then return L["Third Bank Bag"]; end
  if (bag == 8) then return L["Fourth Bank Bag"]; end
  if (bag == 9) then return L["Fifth Bank Bag"]; end
  if (bag == 10) then return L["Sixth Bank Bag"]; end
  if (bag == 11) then return L["Seventh Bank Bag"]; end
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
  if (bag == 6) then return L["BBAG2"]; end
  if (bag == 7) then return L["BBAG3"]; end
  if (bag == 8) then return L["BBAG4"]; end
  if (bag == 9) then return L["BBAG5"]; end
  if (bag == 10) then return L["BBAG6"]; end
  if (bag == 11) then return L["BBAG7"]; end
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
    if (bag > BACKPACK_CONTAINER) then
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
    return "TFuBnkFrameBag"..(bag-4);
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

function TFuBag:UpdateBagColors(bag)
  local r, g, b, a = self:GetColor(self:GetCfgFromBag(bag), "bag_"..bag);
  self:GetBagFrame(bag):GetCheckedTexture():SetVertexColor(r, g, b, a);
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
    if (texture) and (itm) and next(itm) then
      bag = itm[self.I_BAG];
      local cfg = self:GetCfgFromBag(bag);
      local cr, cg, cb, ca = self:GetColor(cfg, "bag_"..bag);
      texture:SetVertexColor(cr, cg, cb, ca);

      if (self:GetBagFrame(bag):GetChecked() or isopen[bag]) and (cfg)
        and (cfg["spotlight_open"] == 1) then
        --and (cfg["show_Bag"..bag] == 1) then
        texture:Show();
      else
        texture:Hide();
      end
    end
  end
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
            _, itm[self.I_TYPE], itm[self.I_SUBTYPE], _, _, stacksize = self:GetItemInfo(itm[self.I_ITEMLINK]);
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


          if (itm[self.I_BAR] == nil and
              (cfg["show_Bag"..bag] == 1 or TFuBag:GetBagFrame(bag):GetChecked())) then
            resort_mandatory = 1;
          end

          if (itm[self.I_SUBTYPE] == nil) then itm[self.I_SUBTYPE] = ""; end
          if (itm[self.I_NAME] == nil) then itm[self.I_NAME] = ""; end

          if (itm[self.I_ITEMLINK] ~= itmcache[bag][slot][self.I_ITEMLINK]) then
            -- the item changed
            if (itm[self.I_TIMESTAMP] ~= nil) then
              if (cfg["show_Bag"..bag] == 1 or TFuBag:GetBagFrame(bag):GetChecked()) then
                resort_suggested = 1;
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

  for _, bag in ipairs(bagarr) do
--    self:PrintDEBUG("TFuBag:MakeBarItm: bag ="..bag);
    if itmcache[bag] == nil then
      return baritm;
    end

    if (cfg["show_Bag"..bag] == 1 or TFuBag:GetBagFrame(bag):GetChecked()) then
      size = table.getn(itmcache[bag]);
      if (size > 0) then
--        self:PrintDEBUG("Show bag "..bag);
        for slot = 1, size do
          if next(itmcache[bag][slot]) then
            itmcache[bag][slot] = self:PickBar(cfg, playerid,
              itmcache[bag][slot], trade1, trade2);

            table.insert( baritm[ itmcache[bag][slot][self.I_BAR] ], itmcache[bag][slot]);
          end
        end
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

  if (itm[self.I_SOULBOUND] == 1 or itm[self.I_ACCTBOUND]) then
    -- Only treat soulbound or accountbound equipment as equipped
    if ( self:GetPlayerInfo(playerid, self.S_EQUIPPED) ~= nil ) then
      if (self:GetPlayerInfo(playerid, self.S_EQUIPPED)[ itemid ] ~= nil) then
      itm[self.I_KEYWORD][L["EQUIPPED"]] = 1;
      end
    end
  end

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

  if (itm[self.I_CAT] == nil) then
    for i = 1, table.getn(cfg["item_search_list"]) do
      local value = cfg["item_search_list"][i];
      if (value[1] ~= "") then
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


function TFuBag:ScanEquipped()
  local itemLink;

--  self:Print( "Scanning Equipment: ");

  if (self:GetPlayerInfo(self.PLAYERID, self.S_EQUIPPED) == nil) then
    self:SetPlayerInfo(self.PLAYERID, self.S_EQUIPPED, {});
  end

  -- Arrange by itemlink (for equipped) and player (for TFuBody)
  for key, value in pairs(self.Body_Slots) do
--    self:Print("Equipped ID="..GetInventorySlotInfo(key).." for "..key);
    local slot = GetInventorySlotInfo(key);
    itemLink = GetInventoryItemLink("player", slot);

    TFuBodyItm[self.PLAYERID][self.D_BAG][value] = {};
    local dbag = TFuBodyItm[self.PLAYERID][self.D_BAG][value];
    if (itemLink) then
      self:SetItemLink(self:GetPlayerInfo(self.PLAYERID, self.S_EQUIPPED), itemLink);

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

    self:PositionFrame(buttonname, "BOTTOMRIGHT", frame, "BOTTOMRIGHT",
      0-mainFrame:FrameX(cur_x)+mainFrame.BF_X_PAD,
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
      0-mainFrame:FrameX(width-1)+mainFrame.BF_X_PAD,
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

function TFuBag:LayoutWindow(frame)
  local framename = frame:GetName()
  local cfg = frame.cfg
  local baritm = frame.BARITM
  local bar_x = cfg.bar_x
  local edit_mode = frame.edit_mode
  local assignfunc = frame.AssignButtonsToFrame
  -- Category Spacing: extra hard gap between adjacent category bars (both axes),
  -- on top of the existing Space/Pool budgets. Default 0 leaves layout unchanged.
  local cat_spacing = cfg.cat_spacing or 0
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
    if (TFuBnkFrame_Total:IsVisible() or TFuBnkFrameBagBank:IsVisible() or
        TFuBnkFrame_MoneyFrame:IsVisible() or TFuBnkFrame_TokenFrame:IsVisible()) then
      PAD_BOTTOM = PAD_BOTTOM + self.PAD_BOTTOM_NORM;
    end
    if (edit_mode == 1) then
      PAD_BOTTOM = PAD_BOTTOM + self.PAD_BOTTOM_EDIT;
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

  -- ITEM BUTTONS
  local cur_y = frame:PoolY(1) + self.BORDER + PAD_BOTTOM;

  for barnum = 1, self.BAR_MAX, bar_x do
    -- last row is partial when bar_x does not divide BAR_MAX evenly; only the
    -- bars that actually exist (<= BAR_MAX) are touched.
    local nbars = math.min(bar_x, self.BAR_MAX - barnum + 1)
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
      if (drew_row) then
        cur_y = cur_y + cat_spacing;
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

          self:PositionFrame(framename.."_bar_"..(barnum+iBar),
            "BOTTOMRIGHT", framename, "BOTTOMRIGHT",
            0-cur_x-cur_width,
            cur_y,
            frame:FrameX(calc_dat[iBar.."_width"]),
            frame:FrameY(calc_dat["height"]));

          -- Category Spacing: hard horizontal gap between adjacent category bars.
          cur_x = cur_x + frame:FrameX(calc_dat[iBar.."_width"]) + cat_spacing;

          -- Color the frame and assign buttons
          self:ColorFrame(cfg, barframe[iBar], (barnum+iBar));

          TFuBag:AssignButtonsToFrame(frame,(barnum+iBar), framename.."_bar_"..(barnum+iBar),
            calc_dat[iBar.."_width"], calc_dat["height"] );
            barframe[iBar]:Show();
        else
          barframe[iBar]:Hide();
        end
      end

      cur_y = cur_y + frame:FrameY(calc_dat["height"]) + frame:PoolY(1);
      drew_row = true;
    end
  end

  -- (No leftover frames to hide: the loop above lays out all BAR_MAX bars,
  -- including a partial final row when bar_x does not divide BAR_MAX evenly.)

  local new_height;
  new_height = cur_y + PAD_TOP + frame:SpaceY(1) + frame:PoolY(1) + self.BORDER;

  frame:SetWidth( available_width );
  frame:SetHeight( new_height );

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

  -- Grab all the users on this realm only
  for key, value in pairs(TItm) do
    local name,realm = strsplit("|", key)
    if ( realm == selRealm ) then
      table.insert(users, key);
    end
  end

  -- Sort and add them
  table.sort(users);
  for key, value in pairs(users) do
    info = {};
    info.text = strsplit("|",value)
    info.value = value;
    info.func = onclickfunc;
    if (value == curplayer) then
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
