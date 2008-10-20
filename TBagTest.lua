-- $Id$

-- Test harness don't bother to load if this isn't a dev version.
if (not string.match(TBag.VERSION,"-Alpha") and
    not string.match(TBag.VERSION,"-Beta")) then
  return
end

local TBag = TBag

-- Localization Support
local L = TBag.LOCALE;

-- Config table we'll use.
local cfg = { }

-- Table of tests to execute.
-- Key is an itemid and the value is the expected category.
-- Multiple possible category matches can be separated with a | (pipe) character.
-- This is needed for some items like items that can be opened, the tooltip
-- string for opening the item only shows if you actually have the item in your
-- inventory.
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
  [24581] = L["PVP"],

  -- Enchants
  [11643] = L["ENCHANTS"],
  [24276] = L["ENCHANTS"],
  [29193] = L["ENCHANTS"],
  [18170] = L["ENCHANTS"],
  [29486] = L["ENCHANTS"],
  [19789] = L["ENCHANTS"],
  [29533] = L["ENCHANTS"],
  [38896] = L["ENCHANTS"],

  -- Glyphs
  [43673] = L["GLYPHS"],
  [40912] = L["GLYPHS"],

  -- Hearthstones
  [6948] = L["HEARTH"],

  -- Minipets
  [4401] = L["MINIPET"],  
  [8492] = L["MINIPET"],  
  [23083] = L["MINIPET"],  
  [35223] = L["MINIPET"],
  [22200] = L["MINIPET"],
  [37431] = L["MINIPET"],
  [37460] = L["MINIPET"],
  [43626] = L["MINIPET"],
 
  -- Combat Pets
  [23767] = L["COMBATPETS"],
  [31666] = L["COMBATPETS"],
  [22728] = L["COMBATPETS"],
  [22729] = L["SCHEMATIC"], -- Patern for the Steam Tonk Controller
  [15778] = L["COMBATPETS"],
  [21277] = L["MINIPET"], -- Similar name but should be a MINIPET.
  [12928] = L["QUEST"], -- Similar name but should be a QUEST item.
  [3456] = L["COMBATPETS"],
  [23379] = L["COMBATPETS"],
  [13508] = L["COMBATPETS"],
  [21325] = L["COMBATPETS"],
  [15778] = L["COMBATPETS"],
  [1187] = L["COMBATPETS"],
  [4391] = L["COMBATPETS"],
  [4395] = L["COMBATPETS"],
  [10725] = L["COMBATPETS"],
  [17067] = L["13_OFFHAND"],
  [13353] = L["13_OFFHAND"],

  -- Costumes
  [35275] = L["COSTUMES"],
  [31337] = L["COSTUMES"],
  [17712] = L["COSTUMES"],
  [20410] = L["COSTUMES"],
  [20409] = L["COSTUMES"],
  [20399] = L["COSTUMES"],
  [20398] = L["COSTUMES"],
  [20397] = L["COSTUMES"],
  [20413] = L["COSTUMES"],
  [20411] = L["COSTUMES"],
  [20414] = L["COSTUMES"],
  [33079] = L["COSTUMES"],
  [34068] = L["COSTUMES"],
  [18258] = L["COSTUMES"],
  [37816] = L["COSTUMES"],
  [21213] = L["COSTUMES"],

  -- Fireworks
  [21570] = L["FIREWORKS"],
  [21569] = L["FIREWORKS"],
  [21571] = L["FIREWORKS"],
  [21574] = L["FIREWORKS"],
  [21716] = L["FIREWORKS"],
  [21718] = L["FIREWORKS"],
  [21744] = L["FIREWORKS"],
  [21576] = L["FIREWORKS"],
  [21562] = L["FIREWORKS"],
  [21561] = L["FIREWORKS"],
  [21557] = L["FIREWORKS"],
  [21559] = L["FIREWORKS"],
  [21558] = L["FIREWORKS"],
  [21558] = L["FIREWORKS"],
  [21589] = L["FIREWORKS"],
  [21590] = L["FIREWORKS"],
  [21592] = L["FIREWORKS"],
  [9312] = L["FIREWORKS"],
  [21713] = L["FIREWORKS"],
  [9313] = L["FIREWORKS"],
  [34258] = L["FIREWORKS"],
  [9318] = L["FIREWORKS"],
  [9314] = L["FIREWORKS"],
  [9317] = L["FIREWORKS"],
  [19026] = L["FIREWORKS"],
  [9315] = L["FIREWORKS"],
  [23714] = L["TRINKET"],

  -- Consumables
  [33927] = L["CONSUMABLE"],
  [33219] = L["CONSUMABLE"],

  -- Toys, various non-equipable items that have no real purpose
  [34686] = L["TOYS"],
  [37863] = L["TOYS"],
  [35227] = L["TOYS"],
  [32566] = L["TOYS"],
  [34480] = L["TOYS"],
  [19035] = L["MISC"].."|"..L["ACT_OPEN"], -- Similar name, ACT_OPEN or MISC 
  [38301] = L["TOYS"],
  [32542] = L["TOYS"],
  [35557] = L["TOYS"],
  [17202] = L["TOYS"],
  [33081] = L["TOYS"],
  [18662] = L["TOYS"],
  [18640] = L["TOYS"],
  [38308] = L["TOYS"],
  [38308] = L["TOYS"],
  [34497] = L["TOYS"],
  [38266] = L["TOYS"],
  [34494] = L["TOYS"],
  [33223] = L["TOYS"],
  [34499] = L["TOYS"],
  [21540] = L["TOYS"],
  [21536] = L["TOYS"],
  [22218] = L["TOYS"],
  [34191] = L["TOYS"],
  [34684] = L["TOYS"],
  [22206] = L["13_OFFHAND"], -- Similar effect but equipable.
  [38233] = L["TOYS"],
  [34498] = L["TOYS"],
  [44430] = L["TOYS"],
  [44606] = L["TOYS"],
  [44482] = L["TOYS"],
  [44481] = L["TOYS"],

  -- Mounts
  [33977] = L["MOUNT"],
  [32861] = L["MOUNT"],
  [33189] = L["MOUNT"],

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
  [39505] = L["TRADE_TOOL"],
  [3567] = L["WEAPON"], -- Avoid matching fishing pole
  [4598] = L["EXPLOSIVES"], -- ditto
  [19970] = L["FISHING"],
 
  -- Inscription
  [43125] = L["INSCRIPTION"],
  [43117] = L["INSCRIPTION"],
  [43121] = L["INSCRIPTION"],
  [43115] = L["INSCRIPTION"],
  [43123] = L["INSCRIPTION"],
  [43123] = L["INSCRIPTION"],
  [31519] = L["11_LEGS"], -- Has ink in the name but not inscription item
  [43119] = L["INSCRIPTION"],
  [43127] = L["INSCRIPTION"],
  [34645] = L["INSCRIPTION"],
  [10647] = L["ENGINEERING"], -- Engineer's Ink
  [43124] = L["INSCRIPTION"],
  [43126] = L["INSCRIPTION"],
  [37101] = L["INSCRIPTION"],
  [43118] = L["INSCRIPTION"],
  [43116] = L["INSCRIPTION"],
  [39774] = L["INSCRIPTION"],
  [39469] = L["INSCRIPTION"],
  [43122] = L["INSCRIPTION"],
  [37100] = L["INSCRIPTION"],
  [37100] = L["INSCRIPTION"],
  [6929] = L["QUEST"], -- Bath'rah's Parchment
  [10648] = L["INSCRIPTION"],
  [11105] = L["QUEST"], -- Curled Map Parchment 
  [3706] = L["ACT_ON"], -- Enscorcelled Parchment
  [9553] = L["QUEST"], -- Etched Parchment 
  [9323] = L["QUEST"], -- Gadrin's Parchment 
  [39501] = L["INSCRIPTION"],
  [39354] = L["INSCRIPTION"],
  [39502] = L["INSCRIPTION"],
  [34647] = L["INSCRIPTION"],
  [12635] = L["QUEST"], -- Simple Parchment 
  [5348] = L["QUEST"], -- Worn Parchment 
  [3767] = L["GRAY_ITEMS"], -- Fine Parchment 
  [40737] = L["08_WRIST"], -- Pigmented Clan Bindings 
  [44061] = L["05_CHEST"], -- Pigmented Clan Bindings 
  [43104] = L["INSCRIPTION"],
  [43108] = L["INSCRIPTION"],
  [43109] = L["INSCRIPTION"],
  [43105] = L["INSCRIPTION"],
  [43106] = L["INSCRIPTION"],
  [43106] = L["INSCRIPTION"],
  [43107] = L["INSCRIPTION"],
  [43103] = L["INSCRIPTION"],
  [39151] = L["INSCRIPTION"],
  [39343] = L["INSCRIPTION"],
  [39334] = L["INSCRIPTION"],
  [39339] = L["INSCRIPTION"],
  [39338] = L["INSCRIPTION"],
  [39342] = L["INSCRIPTION"],
  [39341] = L["INSCRIPTION"],
  [39340] = L["INSCRIPTION"],

  -- Various equipment items
  [33508] = L["RELIC"],
  [28757] = L["RING"],
  [33972] = L["01_HEAD"],
  [31749] = L["02_NECK"],
  [19689] = L["03_SHOULDER"],
  [29375] = L["04_BACK"],
  [4333] = L["06_SHIRT"],
  [6125] = L["06_SHIRT"],
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
  [19301] = L["COMBO"],
  [34062] = L["COMBO"],
  [2682] = L["COMBO"],
  [13724] = L["COMBO"],
  [32722] = L["COMBO"],
  [20031] = L["COMBO"],
  [20031] = L["COMBO"],
  [21215] = L["COMBO"], -- fruitcake 2nd pattern is for this.
  [33053] = L["COMBO"],
  [34780] = L["COMBO"],
  [3448] = L["COMBO"],
  [28112] = L["COMBO"],
  [21153] = L["COMBO"],
  [13893] = L["FOOD"],
  [35285] = L["FOOD"],
  [28111] = L["FOOD"],
  [7676] = L["ENERGY_RESTORE"],
  [27553] = L["ENERGY_RESTORE"],
  [5631] = L["RAGE_RESTORE"],
  [22850] = L["COMBO_RESTORE"],
  [22836] = L["COMBO_RESTORE"],
  [34440] = L["COMBO_RESTORE"],
  [20002] = L["COMBO_RESTORE"],
  [12190] = L["COMBO_RESTORE"],
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
  [9030] = L["CURE"],
  [25550] = L["CURE"],
  [17744] = L["TRINKET"], -- Might match deDE pattern for removing poisons
  [10455] = L["TRINKET"], -- ditto
  [4444] = L["ARMOR"], -- ditto
  [5613] = L["WEAPON"], -- ditto
  [4398] = L["EXPLOSIVES"],
  [4378] = L["EXPLOSIVES"],
  [24538] = L["EXPLOSIVES"],
  [27498] = L["BUFF"],
  [29529] = L["BUFF"],
  [22797] = L["BUFF"],
  [22795] = L["BUFF"],
  [22840] = L["BUFF"],
  [20007] = L["BUFF"],
  [20004] = L["BUFF"],
  [3826] = L["BUFF"],
  [3388] = L["BUFF"],
  [3382] = L["BUFF"],
  [20748] = L["BUFF"],
  [23529] = L["BUFF"],
  [28421] = L["BUFF"],
  [21519] = L["BUFF"],
  [21267] = L["BUFF"],
  [22788] = L["BUFF"],
  [24421] = L["BUFF"],
  [3823] = L["BUFF"],
  [9172] = L["BUFF"],
  [32079] = L["KEY_QUEST"],

  -- Reagents
  [17056] = L["CLASS_REAGENT"],
  [5565] = string.format(L["%s_REAGENT"],L["WARLOCK"]), 
  [16583] = string.format(L["%s_REAGENT"],L["WARLOCK"]),
  [5140] = string.format(L["%s_REAGENT"],L["ROGUE"]),
  [22147] = string.format(L["%s_REAGENT"],L["DRUID"]),
  [17037] = string.format(L["%s_REAGENT"],L["DRUID"]),
  [22148] = string.format(L["%s_REAGENT"],L["DRUID"]),
  [44614] = string.format(L["%s_REAGENT"],L["DRUID"]),
  [44605] = string.format(L["%s_REAGENT"],L["DRUID"]),
  [17020] = string.format(L["%s_REAGENT"],L["MAGE"]),
  [17031] = string.format(L["%s_REAGENT"],L["MAGE"]),
  [17032] = string.format(L["%s_REAGENT"],L["MAGE"]),
  [21177] = string.format(L["%s_REAGENT"],L["PALADIN"]),
  [17033] = string.format(L["%s_REAGENT"],L["PALADIN"]),
  [17029] = string.format(L["%s_REAGENT"],L["PRIEST"]),
  [44615] = string.format(L["%s_REAGENT"],L["PRIEST"]),
  [17030] = string.format(L["%s_REAGENT"],L["SHAMAN"]),
  [17058] = string.format(L["%s_REAGENT"],L["SHAMAN"]),
  [17057] = string.format(L["%s_REAGENT"],L["SHAMAN"]),
  [37201] = string.format(L["%s_REAGENT"],L["DEATHKNIGHT"]),
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
  [43102] = L["REAGENT"],
  [37700] = L["REAGENT"],
  [37701] = L["REAGENT"],
  [37702] = L["REAGENT"],
  [37703] = L["REAGENT"],
  [37704] = L["REAGENT"],
  [37705] = L["REAGENT"],
  [35622] = L["REAGENT"],
  [35623] = L["REAGENT"],
  [35624] = L["REAGENT"],
  [35625] = L["REAGENT"],
  [35627] = L["REAGENT"],
  [36860] = L["REAGENT"],

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
  [22445] = L["ENCHANTING"],
  [22449] = L["ENCHANTING"],
  [22202] = L["BLACKSMITHING"], -- Similar to enchanting but shouldn't match
  [22203] = L["BLACKSMITHING"], -- ditto

}

if not TBag.WoTLK then
  -- Remove the few that are irrelevent for Live clients
  -- XXX: Remove this code once Wrath goes live
  tests[40582] = nil
  tests[34494] = nil
  tests[38266] = nil
  tests[37431] = nil
  tests[37460] = nil
  tests[43626] = nil
  tests[34498] = nil
  tests[44430] = nil
  tests[43102] = nil
  tests[37700] = nil
  tests[37701] = nil
  tests[37702] = nil
  tests[37703] = nil
  tests[37704] = nil
  tests[37705] = nil
  tests[35622] = nil
  tests[35623] = nil
  tests[35624] = nil
  tests[35625] = nil
  tests[35627] = nil
  tests[36860] = nil
  tests[38896] = nil
  tests[43125] = nil
  tests[43117] = nil
  tests[43121] = nil
  tests[43115] = nil
  tests[43123] = nil
  tests[43123] = nil
  tests[31519] = nil
  tests[43119] = nil
  tests[43127] = nil
  tests[34645] = nil
  tests[10647] = nil
  tests[43124] = nil
  tests[43126] = nil
  tests[37101] = nil
  tests[43118] = nil
  tests[43116] = nil
  tests[39774] = nil
  tests[39469] = nil
  tests[43122] = nil
  tests[37100] = nil
  tests[37100] = nil
  tests[6929] = nil
  tests[10648] = nil
  tests[11105] = nil
  tests[3706] = nil
  tests[9553] = nil
  tests[9323] = nil
  tests[39501] = nil
  tests[39354] = nil
  tests[39502] = nil
  tests[34647] = nil
  tests[12635] = nil
  tests[5348] = nil
  tests[3767] = nil
  tests[40737] = nil
  tests[44061] = nil
  tests[43104] = nil
  tests[43108] = nil
  tests[43109] = nil
  tests[43105] = nil
  tests[43106] = nil
  tests[43106] = nil
  tests[43107] = nil
  tests[43103] = nil
  tests[39151] = nil
  tests[39343] = nil
  tests[39334] = nil
  tests[39339] = nil
  tests[39338] = nil
  tests[39342] = nil
  tests[39341] = nil
  tests[39340] = nil
  tests[39505] = nil
  tests[43673] = nil 
  tests[40912] = nil 
  tests[44606] = nil
  tests[44482] = nil
  tests[44481] = nil
  tests[44614] = nil
  tests[44605] = nil
  tests[44615] = nil
  tests[37201] = nil
else
  -- Tests that need to be removed for WoTLK
  -- XXX: Adjust the tests for Wrath when it goes live.
  tests[20558] = nil
  tests[20559] = nil
  tests[20560] = nil
  tests[29024] = nil
  tests[5140] = nil

  -- Known items not working on beta/PTR realms
  -- Found from wowhead but apparently not seen on any of the realms
  tests[38266] = nil  
  tests[34645] = nil
  tests[34647] = nil 

  tests[22218] = nil  -- Apparently the valentine's day stuff isn't seen
  tests[22200] = nil  -- more v'day stuff
end

local function build_itm(id,itm)
  itm[TBag.I_ITEMLINK] = "item:"..id..":0:0:0:0:0:0:0";
  itm[TBag.I_BAG] = 1;
  itm[TBag.I_SLOT] = 1;
  itm[TBag.I_NAME], itm[TBag.I_TYPE], itm[TBag.I_SUBTYPE], itm[TBag.I_RARITY]
    = TBag:GetItemInfo(itm[TBag.I_ITEMLINK]);
end

-- Executes a single test 
--   inputs: itemid and the expected category
--   output: result (boolean), itm (table produced) 
local function test(id,cat)
  local itm = { };
  local result = false

  build_itm(id,itm);
  TBag:PickBar(cfg, "TBAGTEST|TBAGTEST", itm, "", "");
  for c in cat:gmatch("[^|]+") do 
    if c == itm[TBag.I_CAT] then
      result = true
    end
  end
  return result, itm;
end

function TBag:GetCategory(id)
 self:InitDefVals(cfg, self.Inv_Bags, 0, 1)

 local _, itm = test(id,"TEST")
 local link = self:MakeHyperlink(itm[self.I_ITEMLINK],itm[self.I_NAME],
                                 itm[self.I_RARITY],80);
 link = tostring(link); 
 TBag:Print(string.format("%s (%s) = %s",link,tostring(id),tostring(itm[self.I_CAT])))
end

function TBag:RunTests(verbose)
  local fail = false;
  -- Initialize the cfg with default values
  self:InitDefVals(cfg, self.Inv_Bags, 0, 1);  

  self:Print(L["TEST RUN STARTING"]);
  
  for id,cat in pairs(tests) do
    local result, itm = test(id,cat)
    local link = self:MakeHyperlink(itm[self.I_ITEMLINK],itm[self.I_NAME],
                                    itm[self.I_RARITY],80);
    link = tostring(link); 
    
    if (result == true) then
      if (verbose) then
        local output = string.format(L["SUCCESS: %s"], link);
        self:Print(output,0,1,0);
      end
    else
      fail = true;
      local output = string.format(L["FAIL: %s (%s) expected %q but got %q"], link,
                                   tostring(id),tostring(cat),tostring(itm[self.I_CAT]));
      self:Print(output,1,0,0);
    end
  end

  if (fail == false) then
    self:Print(L["ALL TESTS SUCCESSFUL"]);
  end
end
