-- $Id $

-- Test harness don't bother to load if this isn't a dev version.
if (not string.match(TBAG_VERSION,"-Alpha") and
    not string.match(TBAG_VERSION,"-Beta")) then
  return
end

-- Localization Support
local L = TBAG_LOCALE;

-- Config table we'll use.
local cfg = { }

-- Table of tests to execute.
-- Key is an itemid and the value is the expected category.
local tests = {
  [1357] = L["ACT_ON"],
  -- Note we can't test the Right click to open rule because it's
  -- added only for items actually in your inventory.
  [5759] = L["ACT_OPEN"],

  -- PVP Items
  [20560] = L["PVP"],
  [20559] = L["PVP"],
  [29024] = L["PVP"],
  [20558] = L["PVP"],
  [24579] = L["PVP"],
  [26045] = L["PVP"],
  [28558] = L["PVP"],

  -- Enchants
  [11643] = L["ENCHANTS"],
  [24276] = L["ENCHANTS"],

  -- Hearthstones
  [6948] = L["HEARTH"],

  -- Minipets
  [4401] = L["MINIPET"],  
  [8492] = L["MINIPET"],  
  [23083] = L["MINIPET"],  
  
  -- Mounts
  [33977] = L["MOUNT"],
  [32861] = L["MOUNT"],

  -- AQ
  [20864] = L["AHN_QIRAJ"],
  [21685] = L["TRINKET"], -- similar name shouldn't match the rule though
  [19431] = L["TRINKET"], -- similar name shouldn't match the rule though
  [20864] = L["AHN_QIRAJ"],
  [20873] = L["AHN_QIRAJ"],
  [29390] = L["RELIC"], -- Druid idols shouldn't match
  [20888] = L["AHN_QIRAJ"],
  [20884] = L["AHN_QIRAJ"],
  [20885] = L["AHN_QIRAJ"],
  [20889] = L["AHN_QIRAJ"],

  -- Argent Dawn
  [22526] = L["ARGENT_DAWN"],
  [22527] = L["ARGENT_DAWN"],
  [22525] = L["ARGENT_DAWN"],
  [22528] = L["ARGENT_DAWN"],
  [22529] = L["ARGENT_DAWN"],
  [22524] = L["ARGENT_DAWN"],
  [22523] = L["ARGENT_DAWN"],
  [12844] = L["ARGENT_DAWN"],
  -- [18171] = L["ARGENT_DAWN"], -- Not sure what to do on these two
  -- [18170] = L["ARGENT_DAWN"], -- they match enchants too
  [13370] = L["ARGENT_DAWN"],
  [13357] = L["ARGENT_DAWN"],
  [13356] = L["ARGENT_DAWN"],
  [13354] = L["ARGENT_DAWN"],
  [13320] = L["ARGENT_DAWN"],
  [13320] = L["ARGENT_DAWN"],
  [12843] = L["ARGENT_DAWN"],
  [12841] = L["ARGENT_DAWN"],
  [12840] = L["ARGENT_DAWN"],
 
  -- Cenarion Circle
  [20801] = L["CENARION_CIRCLE"],
  [20800] = L["CENARION_CIRCLE"],
  [20802] = L["CENARION_CIRCLE"],
  [20513] = L["CENARION_CIRCLE"],
  [20514] = L["CENARION_CIRCLE"],
  [20515] = L["CENARION_CIRCLE"],

  -- Darkmoon Faire
  [19182] = L["DARKMOON_FAIRE"],
  [4582] = L["DARKMOON_FAIRE"],
  [4582] = L["DARKMOON_FAIRE"],
  [5117] = L["DARKMOON_FAIRE"],
  [5134] = L["DARKMOON_FAIRE"],
  [11404] = L["DARKMOON_FAIRE"],
  [11407] = L["DARKMOON_FAIRE"],
  [19933] = L["DARKMOON_FAIRE"],
  [19933] = L["DARKMOON_FAIRE"],
  -- The decks actually end up in ACT_ON
  [19257] = L["ACT_ON"],
  [19258] = L["DARKMOON_FAIRE"],
  [19267] = L["ACT_ON"],
  [19268] = L["DARKMOON_FAIRE"],
  [19277] = L["ACT_ON"],
  [19276] = L["DARKMOON_FAIRE"],
  [19228] = L["ACT_ON"],
  [19227] = L["DARKMOON_FAIRE"],
  [31890] = L["ACT_ON"],
  [31882] = L["DARKMOON_FAIRE"],
  [31907] = L["ACT_ON"],
  [31901] = L["DARKMOON_FAIRE"],
  [31914] = L["ACT_ON"],
  [31910] = L["DARKMOON_FAIRE"],
  [31891] = L["ACT_ON"],
  [31892] = L["DARKMOON_FAIRE"],

  -- Thorium Brotherhood
  [18944] = L["THORIUM_BROTHER"],
  [18945] = L["THORIUM_BROTHER"],
 
  -- Timbermaw
  [21377] = L["TIMBERMAW"],
  [21383] = L["TIMBERMAW"],
 
  -- Zul'Grub
  [19858] = L["ZUL_GURUB"],
  [19699] = L["ZUL_GURUB"],
  [19708] = L["ZUL_GURUB"],
  [19724] = L["ZUL_GURUB"],
  [19717] = L["ZUL_GURUB"],
  [19716] = L["ZUL_GURUB"],
  [19719] = L["ZUL_GURUB"],
  [19723] = L["ZUL_GURUB"],
  [19720] = L["ZUL_GURUB"],
  [19721] = L["ZUL_GURUB"],
  [19718] = L["ZUL_GURUB"],
  [19722] = L["ZUL_GURUB"],
  [19722] = L["ZUL_GURUB"],
  [22637] = L["ZUL_GURUB"],
  
  -- Ogri'la
  [32572] = L["OGRI'LA"],
  [32684] = L["OGRI'LA"],
  [32683] = L["OGRI'LA"],
  [32682] = L["OGRI'LA"],
  [32681] = L["OGRI'LA"],
  [32643] = L["OGRI'LA"],
  [33784] = L["OGRI'LA"],
  [33784] = L["OGRI'LA"],
  [32602] = L["OGRI'LA"],
  
  -- Netherwing
  [32506] = L["NETHERWING"],
  [32464] = L["NETHERWING"],
  [32468] = L["NETHERWING"],
  [32468] = L["NETHERWING"],
  [32427] = L["NETHERWING"],
  [32723] = L["NETHERWING"],

  -- Cenarion Expedition
  [24401] = L["CENARION_EXPEDITION"],
  [24368] = L["CENARION_EXPEDITION"],

  -- Sporeggar
  [24290] = L["SPOREGGAR"],
  [24291] = L["SPOREGGAR"],
  [24291] = L["SPOREGGAR"],
  [24245] = L["SPOREGGAR"],
  [24449] = L["SPOREGGAR"],
  [24449] = L["SPOREGGAR"],
  [24246] = L["SPOREGGAR"],

  -- Consortium
  [25433] = L["CONSORTIUM"],
  [25416] = L["CONSORTIUM"],
  [25463] = L["CONSORTIUM"],
  [29209] = L["CONSORTIUM"],
  [31957] = L["CONSORTIUM"],
  [29460] = L["CONSORTIUM"],
 
  -- Halaa
  [26044] = L["HALAA"],
  [26042] = L["HALAA"],
  [26043] = L["HALAA"],

  -- Scryer
  [25744] = L["SCRYER"],
  [29426] = L["SCRYER"],
  [30810] = L["SCRYER"],
  [29739] = L["SCRYER"],
  [29736] = L["SCRYER"],
  
  -- Aldor
  [25802] = L["ALDOR"],
  [29425] = L["ALDOR"],
  [30809] = L["ALDOR"],
  [29740] = L["ALDOR"],
  [29735] = L["ALDOR"],
  [32897] = L["ALDOR"],

  -- Sha'tar
  [29434] = L["SHA'TAR"],

  -- Lower City
  [25719] = L["LOWER_CITY"],

  -- Trinket
  [28830] = L["TRINKET"],
  
  -- Quest
  [11018] = L["QUEST"],
  [7297] = L["QUEST"],
  
  -- Gray items
  [3300] = L["GRAY_ITEMS"],

  -- Containers
  [21876] = L["BAG"],
  [29143] = L["BAG"],
  [34106] = L["BAG"],
 
  -- Projectiles
  [31737] = L["PROJECTILE"],
  [31735] = L["PROJECTILE"],

  -- Books
  [29549] = L["BOOK"],
  [21993] = L["BOOK"],
  [16072] = L["BOOK"],
  [22153] = L["BOOK"],
  [21953] = L["DESIGN"],
  [33151] = L["FORMULA"],
  [22919] = L["RECIPE"],
  [25731] = L["PATTERN"],
  [12827] = L["PLANS"],
  [23887] = L["SCHEMATIC"],

  -- Trade Tools
  [7005] = L["TRADE_TOOL"],
  [19901] = L["TRADE_TOOL"],
  [2901] = L["TRADE_TOOL"],
  [778] = L["TRADE_TOOL"],
  [5956] = L["TRADE_TOOL"],
  [22462] = L["TRADE_TOOL"],
  [9149] = L["TRADE_TOOL"],
  [15846] = L["TRADE_TOOL"],
  [6219] = L["TRADE_TOOL"],
  [10498] = L["TRADE_TOOL"],
  [12709] = L["TRADE_TOOL"],
  [19727] = L["TRADE_TOOL"],
  [7349] = L["TRADE_TOOL"],
  [3567] = L["WEAPON"], -- Avoid matching fishing pole
  [4598] = L["EXPLOSIVES"], -- ditto
  [19970] = L["FISHING"],
  
  -- Various equipment items
  [33508] = L["RELIC"],
  [28757] = L["RING"],
  [33972] = L["01_HEAD"],
  [31749] = L["02_NECK"],
  [19689] = L["03_SHOULDER"],
  [29375] = L["04_BACK"],
  [4333] = L["06_SHIRT"],
  [31780] = L["07_TABARD"],
  [33580] = L["08_WRIST"],
  [34904] = L["09_HANDS"],
  [30042] = L["10_WAIST"],
  [28591] = L["11_LEGS"],
  [29265] = L["12_FEET"],
  [28728] = L["13_OFFHAND"],
  [18608] = L["WEAPON"],

  -- Restores
  [21991] = L["BANDAGE"],
  [5509] = L["HEALTHSTONE"],
  [32578] = L["HEALTHSTONE"],
  [27666] = L["FOOD_BUFF"],
  [13810] = L["FOOD_BUFF"],
  [22018] = L["DRINK"],
  [34062] = L["COMBO"],
  [13893] = L["FOOD"],
  [35285] = L["FOOD"],
  [28111] = L["FOOD"],
  [7676] = L["ENERGY_RESTORE"],
  [27553] = L["ENERGY_RESTORE"],
  [5631] = L["RAGE_RESTORE"],
  [22850] = L["COMBO_RESTORE"],
  [22836] = L["COMBO_RESTORE"],
  [34440] = L["COMBO_RESTORE"],
  [22832] = L["MANA_RESTORE"],
  [32902] = L["MANA_RESTORE"],
  [22829] = L["HEALTH_RESTORE"],
  [32905] = L["HEALTH_RESTORE"],
  [25883] = L["HEALTH_RESTORE"],

  -- Combat Buffs
  [6452] = L["CURE"],
  [12586] = L["CURE"],
  [31437] = L["CURE"],
  [5951] = L["CURE"],
  [9030] = L["CURE"],
  [4398] = L["EXPLOSIVES"],
  [4378] = L["EXPLOSIVES"],
  [24538] = L["EXPLOSIVES"],
  [27498] = L["BUFF"],
  [29529] = L["BUFF"],
  [22797] = L["BUFF"],
  [22795] = L["BUFF"],
  [22840] = L["BUFF"],
  [20748] = L["BUFF"],
  [23529] = L["BUFF"],
  [28421] = L["BUFF"],
  [21519] = L["BUFF"],
  [22788] = L["BUFF"],
  [24421] = L["BUFF"],
  [32079] = L["KEY_QUEST"],

  -- Reagents
  [17056] = L["CLASS_REAGENT"],
  [5565] = string.format(L["%s_REAGENT"],L["WARLOCK"]), 
  [16583] = string.format(L["%s_REAGENT"],L["WARLOCK"]),
  [5140] = string.format(L["%s_REAGENT"],L["ROGUE"]),
  [22147] = string.format(L["%s_REAGENT"],L["DRUID"]),
  [17037] = string.format(L["%s_REAGENT"],L["DRUID"]),
  [22148] = string.format(L["%s_REAGENT"],L["DRUID"]),
  [17020] = string.format(L["%s_REAGENT"],L["MAGE"]),
  [17031] = string.format(L["%s_REAGENT"],L["MAGE"]),
  [17032] = string.format(L["%s_REAGENT"],L["MAGE"]),
  [21177] = string.format(L["%s_REAGENT"],L["PALADIN"]),
  [17033] = string.format(L["%s_REAGENT"],L["PALADIN"]),
  [17029] = string.format(L["%s_REAGENT"],L["PRIEST"]),
  [17030] = string.format(L["%s_REAGENT"],L["SHAMAN"]),
  [17058] = string.format(L["%s_REAGENT"],L["SHAMAN"]),
  [17057] = string.format(L["%s_REAGENT"],L["SHAMAN"]),
  [5060] = string.format(L["%s_TOOL"],L["ROGUE"]),
  [5178] = string.format(L["%s_TOOL"],L["SHAMAN"]),
  [5175] = string.format(L["%s_TOOL"],L["SHAMAN"]),
  [5176] = string.format(L["%s_TOOL"],L["SHAMAN"]),
  [5177] = string.format(L["%s_TOOL"],L["SHAMAN"]),
  [6265] = L["SOULSHARD"],
  [4392] = L["DUMMY"],

  [7068] = L["REAGENT"],
  [7082] = L["REAGENT"],
  [7079] = L["REAGENT"],
  [7081] = L["REAGENT"],
  [7077] = L["REAGENT"],
  [7075] = L["REAGENT"],
  [22572] = L["REAGENT"],
  [23572] = L["REAGENT"],
  [21886] = L["REAGENT"],
  [22450] = L["REAGENT"],
  [30183] = L["REAGENT"],
  [32428] = L["REAGENT"],
  [34664] = L["REAGENT"],

  -- Trades
  [8925] = L["ALCHEMY"],
  [4305] = L["CLOTH"],
  [21877] = L["CLOTH"],
  [3173] = L["COOKING"],
  [11083] = L["ENCHANTING"],
  [10998] = L["ENCHANTING"],
  [11082] = L["ENCHANTING"],
  [14343] = L["ENCHANTING"],
  [14343] = L["ENCHANTING"],
  [14344] = L["ENCHANTING"],

}

local function build_itm(id,itm)
  itm[TBAG_I_ITEMLINK] = "item:"..id..":0:0:0:0:0:0:0";
  itm[TBAG_I_BAG] = 1;
  itm[TBAG_I_SLOT] = 1;
  itm[TBAG_I_NAME], itm[TBAG_I_TYPE], itm[TBAG_I_SUBTYPE], itm[TBAG_I_RARITY]
    = TBag_GetItemInfo(itm[TBAG_I_ITEMLINK]);
end

-- Executes a single test 
--   inputs: itemid and the expected category
--   output: result (boolean), itm (table produced) 
local function test(id,cat)
  local itm = { };

  build_itm(id,itm);
  TBag_PickBar(cfg, "TBAGTEST|TBAGTEST", itm, "", "");
  
  return (cat == itm[TBAG_I_CAT]), itm;
end



function TBag_RunTests()
  local fail = false;
  -- Initialize the cfg with default values
  TBag_InitDefVals(cfg, TInv_Bags, 0, 1);  

  TBag_Print(L["TEST RUN STARTING"]);
  
  -- Run through all the test ids to get them cached.
  for id in pairs (tests) do
    local start = time();
    local itemlink = "item:"..id;
    repeat 
      local tooltip = TBag_MakeToolTipStr(nil,itemlink)
    until (tooltip ~= L[" Retrieving item information"] or time() - start >= 2)
  end
  
  for id,cat in pairs(tests) do
    local result, itm = test(id,cat)
    local link = TBag_MakeHyperlink(itm[TBAG_I_ITEMLINK],itm[TBAG_I_NAME],
                                    itm[TBAG_I_RARITY]);
    link = tostring(link); 
    
    if (result == true) then
      local output = string.format(L["SUCCESS: %s"], link);
      TBag_Print(output,0,1,0);
    else
      fail = true;
      local output = string.format(L["FAIL: %s (%s) expected %q but got %q"], link,
                                   tostring(id),tostring(cat),tostring(itm[TBAG_I_CAT]));
      TBag_Print(output,1,0,0);
    end
  end

  if (fail == false) then
    TBag_Print(L["ALL TESTS SUCCESSFUL"]);
  end
end
