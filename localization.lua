TBAG_VERSION = "2007-06-26-Shefki";
TBAG_S_RARITY  = "R_";  -- Do not touch this  ;-)

TBag_DefaultItemOverrides = {
};

-- Category, Keywords, Tooltip Search, ItemType, ItemSubType
TBag_DefaultSearchList = {
-- Quest items and Collectibles
  { "ACT_ON", "", "This Item Begins a Quest", "", "" },
  { "ACT_OPEN", "", "Right Click to Open", "", "" },
  { "ACT_OPEN", "", " Lockbox", "Miscellaneous", "" },
  { "PVP", "", "Mark of Honor", "Quest", "" },
  { "ENCHANTS", "", "Use: Permanently", "Miscellaneous", "" },
  { "HEARTH", "", "Hearthstone", "Miscellaneous", "" },

  { "AHN_QIRAJ", "", "%a+ Scarab", "Quest", "" },
  { "AHN_QIRAJ", "", "%a+ Idol", "Quest", "" },
  { "AHN_QIRAJ", "", "Qiraji %a+ %a+", "Quest", "" },
  { "ARGENT_DAWN", "", "Bone Fragments", "Miscellaneous", "" },
  { "ARGENT_DAWN", "", "Core of Elements", "Miscellaneous", "" },
  { "ARGENT_DAWN", "", "Crypt Fiend Parts", "Miscellaneous", "" },
  { "ARGENT_DAWN", "", "Dark Iron Scraps", "Miscellaneous", "" },
  { "ARGENT_DAWN", "", "Savage Frond", "Miscellaneous", "" },
  { "ARGENT_DAWN", "", "Insignia of the Crusade", "Miscellaneous", "" },
  { "ARGENT_DAWN", "", "Insignia of the Dawn", "Miscellaneous", "" },
  { "ARGENT_DAWN", "", "Argent Dawn Valor Token", "Quest", "" },
  { "ARGENT_DAWN", "", "Mantle of the Dawn", "Quest", "" },
  { "ARGENT_DAWN", "", "Vitreous Focuser", "Quest", "" },
  { "ARGENT_DAWN", "", "Osseous Agitator", "Quest", "" },
  { "ARGENT_DAWN", "", "Somatic Intensifier", "Quest", "" },
  { "ARGENT_DAWN", "", "Ectoplasmic Resonator", "Quest", "" },
  { "ARGENT_DAWN", "", "Arcane Quickener", "Quest", "" },
  { "ARGENT_DAWN", "", " Scourgestone", "Quest", "" },
  { "CENARION_CIRCLE", "", "Cenarion %a+ Badge", "Quest", "" },
  { "CENARION_CIRCLE", "", "Twilight Text", "Quest", "" },
  { "CENARION_CIRCLE", "", "Twilight Cultist", "Armor", "" },
  { "CENARION_CIRCLE", "", "Twilight Cultist", "Miscellaneous", "" },
  { "CENARION_CIRCLE", "", "Abyssal Crest", "Miscellaneous", "" },
  { "CENARION_CIRCLE", "", "Abyssal Signet", "Miscellaneous", "" },
  { "CENARION_CIRCLE", "", "Abyssal Scepter", "Miscellaneous", "" },
  { "DARKMOON_FAIRE", "",  "Darkmoon Faire Prize Ticket", "", "" },
  { "DARKMOON_FAIRE", "",  "Rabbit's Foot", "Miscellaneous", "" },
  { "DARKMOON_FAIRE", "",  "Soft Bushy Tail", "Miscellaneous", "" },
  { "DARKMOON_FAIRE", "",  "Vibrant Plume", "Miscellaneous", "" },
  { "DARKMOON_FAIRE", "",  "Small Furry Paw", "Miscellaneous", "" },
  { "DARKMOON_FAIRE", "",  "Evil Bat Eye", "Miscellaneous", "" },
  { "DARKMOON_FAIRE", "",  "Torn Bear Pelt", "Miscellaneous", "" },
  { "DARKMOON_FAIRE", "",  "Glowing Scorpid Blood", "Miscellaneous", "" },
  { "DARKMOON_FAIRE", "",  "Warlords", "Miscellaneous", "" },
  { "DARKMOON_FAIRE", "",  "Elementals", "Miscellaneous", "" },
  { "DARKMOON_FAIRE", "",  "Portals", "Miscellaneous", "" },
  { "DARKMOON_FAIRE", "",  "Beasts", "Miscellaneous", "" },
  { "THORIUM_BROTHER", "", "Incendosaur Scale", "Quest", "" },
  { "THORIUM_BROTHER", "", "Dark Iron Residue", "Miscellaneous", "" },
  { "TIMBERMAW", "", "Deadwood Headdress Feather", "Quest", "" },
  { "TIMBERMAW", "", "Winterfall Spirit Beads", "Quest", "" },
  { "ZUL_GURUB", "", "Zandalar Honor Token", "Quest", "" },
  { "ZUL_GURUB", "", "%a+ Coin", "Quest", "" },
  { "ZUL_GURUB", "", "%a+ Bijou", "Quest", "" },
  { "ZUL_GURUB", "", "Primal Hakkari", "", "" },

  { "EQUIPPED_TRINKET", "EQUIPPED", "Trinket", "Quest", "" },
  { "SOULBOUND_TRINKET", "SOULBOUND", "Trinket", "Quest", "" },
  { "TRINKET", "", "Trinket", "Quest", "" },

  { "QUEST", "", "", "Quest", "" },
  { "QUEST", "", "Quest Item", "", "" },
  { "QUEST", "", "Use: Bind pages %d+", "Miscellaneous", "" },
  { "QUEST", "", "Green Hills", "Miscellaneous", "" },
  { "QUEST", "", "Un'Goro Soil", "Miscellaneous", "" },
  { "QUEST", "", "Morbent", "Armor", "" },
  { "GRAY_ITEMS", TBAG_S_RARITY.."0",  "", "", "" },

-- Containers
  { "BAG", "", "", "Container", "" },
  { "BAG", "", "", "Quiver", "" },
  { "PROJECTILE", "", "", "Projectile", "" },

  { "MINIPET", "", "Right Click to summon and dismiss", "", "" },
  { "MOUNT", "", "Summons and dismisses a rideable", "", "" },

  { "BOOK", "", "Codex: ", "Recipe", "" },
  { "BOOK", "", "Manual: ", "Recipe", "" },
  { "BOOK", "", "Expert ", "Recipe", "" },
  { "BOOK", "", "Tome of ", "Recipe", "" },
  { "DESIGN", "", "Design: ", "Recipe", "" },
  { "FORMULA", "", "Formula: ", "Recipe", "" },
  { "RECIPE", "", "Recipe: ", "Recipe", "" },
  { "PATTERN", "", "Pattern: ", "Recipe", "" },
  { "PLANS", "", "Plans: ", "Recipe", "" },
  { "SCHEMATIC", "", "Schematic: ", "Recipe", "" },
  { "RECIPE_OTHER", "", "", "Recipe", "" },

-- Equipment
  { "TRADE_TOOL", "", "[Ss]kinning [Kk]nife", "Weapon", "" },
  { "TRADE_TOOL", "", "[Mm]ining [Pp]ick", "Weapon", "" },
  { "TRADE_TOOL", "", "[Bb]lacksmith [Hh]ammer", "Weapon", "" },
  { "TRADE_TOOL", "", "Runed %a+ Rod", "", "" },
  { "TRADE_TOOL", "", "Philosopher's Stone", "", "" },
  { "TRADE_TOOL", "", "Salt Shaker", "", "" },
  { "TRADE_TOOL", "", "Arclight Spanner", "Weapon", "" },
  { "TRADE_TOOL", "", "Gyromatic Micro.Adjustor", "Trade Goods", "" },
  { "TRADE_TOOL", "", "Zulian Slicer", "", "" },
  { "TRADE_TOOL", "", "Finkle's Skinner", "", "" },
  { "TRADE_TOOL", "", "Blood Scythe", "", "" },
  { "TRADE_TOOL", "", "Herbalist's Gloves", "", "" },
  { "EQUIPPED_WEAPON", "EQUIPPED", "", "Dwarven Fishing Pole", "" },
  { "SOULBOUND_WEAPON", "SOULBOUND", "", "Dwarven Fishing Pole", "" },
  { "WEAPON", "", "Dwarven Fishing Pole", "", "" },
  { "EXPLOSIVES", "", "Goblin Fishing Pole", "", "" },
  { "FISHING", "", "Fishing", "", "" },

  { "EQUIPPED_TRINKET", "EQUIPPED", "Trinket", "Trade Goods", "" },
  { "EQUIPPED_TRINKET", "EQUIPPED", "Trinket", "Armor", "" },
  { "EQUIPPED_RELIC", "EQUIPPED", "Relic", "Armor", "" },
  { "EQUIPPED_RING", "EQUIPPED", "Finger", "Armor", "" },
  { "EQUIPPED_ARMOR", "EQUIPPED", "", "Armor", "" },
  { "EQUIPPED_WEAPON", "EQUIPPED", "", "Weapon", "" },
  { "EQUIPPED_OTHER", "EQUIPPED", "", "", "" },

  { "SOULBOUND_TRINKET", "SOULBOUND", "Trinket", "Trade Goods", "" },
  { "SOULBOUND_TRINKET", "SOULBOUND", "Trinket", "Armor", "" },
  { "SOULBOUND_RELIC", "SOULBOUND", "Relic", "Armor", "" },
  { "SOULBOUND_RING", "SOULBOUND", "Finger", "Armor", "" },
  { "SOULBOUND_ARMOR", "SOULBOUND", "", "Armor", "" },
  { "SOULBOUND_WEAPON", "SOULBOUND", "", "Weapon", "" },

  { "TRINKET", "", "Trinket", "Trade Goods", "" },
  { "TRINKET", "", "Trinket", "Armor", "" },
  { "RELIC", "", "Relic", "Armor", "" },
  { "RING", "", "Finger", "Armor", "" },
  { "ARMOR", "", "", "Armor", "" },
  { "WEAPON", "", "", "Weapon", "" },

-- Restores
  { "BANDAGE", "", " Bandage", "Consumable", "" },
  { "HEALTHSTONE", "", " Healthstone", "", "" },
  { "FOOD_BUFF", "", " well fed ", "Consumable", "" },
  { "FOOD_BUFF", "", "Restores %d+ health.* increases your ", "Consumable", "" },
  { "DRINK", "", "Must remain seated while drinking.", "Consumable", "" },
  { "DRINK", "", "Restores %d+ mana over %d+ sec", "Consumable", "" },
  { "COMBO", "", "Restores %d+ health and %d+ mana over %d+ sec", "Consumable", "" },
  { "COMBO", "", "Restores .* health and mana .* %d+ sec", "Consumable", "" },
  { "FOOD", "", "Must remain seated while eating.", "Consumable", "" },
  { "FOOD", "", "Restores %d+ health over %d+ sec", "Consumable", "" },
  { "ENERGY_RESTORE", "", "Thistle Tea", "Consumable", "" },
  { "ENERGY_RESTORE", "", "[Rr]estores %d+ energy", "", "" },
  { "RAGE_RESTORE", "", "Rage Potion", "Consumable", "" },
  { "RAGE_RESTORE", "", "[Rr]estores %d+ rage", "", "" },
  { "COMBO_RESTORE", "", "Rejuvenation Potion", "Consumable", "" },
  { "COMBO_RESTORE", "", "Dreamless Sleep", "Consumable", "" },
  { "COMBO_RESTORE", "", "[Rr]estores %d+ to %d+ mana and health", "", "" },
  { "MANA_RESTORE", "", "Mana Potion", "Consumable", "" },
  { "MANA_RESTORE", "", "[Rr]estores %d+ to %d+ mana", "", "" },
  { "HEALTH_RESTORE", "", "Healing Potion", "Consumable", "" },
  { "HEALTH_RESTORE", "", "[Rr]estores %d+ to %d+ health", "", "" },

-- Combat buffs
  { "CURE", "", " [Cc]ure.* poison", "", "" },
  { "CURE", "", " [Cc]ure.* disease", "", "" },
  { "CURE", "", " [Cc]ure.* curse", "", "" },
  { "CURE", "", " [Cc]ure.* magic", "", "" },
  { "CURE", "", " [Rr]emoves %d+ .*effect", "", "" },
  { "EXPLOSIVES", "", "", "Trade Goods", "Explosives" },
  { "EXPLOSIVES", "", " Dynamite", "", "" },
  { "EXPLOSIVES", "", " Bomb", "", "" },
  { "EXPLOSIVES", "", " Mortar", "", "" },
  { "BUFF", "", "Scroll", "Consumable", "" },
  { "BUFF", "", "Use: Increases ", "Consumable", "" },
  { "BUFF", "", "Use: Absorbs ", "Consumable", "" },
  { "BUFF", "", "Use: Regenerate ", "Consumable", "" },
  { "BUFF", "", "Use: While applied to target weapon", "", "" },
  { "BUFF", "", " Sharpening Stone", "", "" },
  { "BUFF", "", " Weightstone", "", "" },
  { "KEY_OPEN", "", " Key", "Trade Goods", "" },
  { "KEY_QUEST", "", " Key", "Key", "" },

-- Reagents
  { "CLASS_REAGENT", "", "Light Feather", "Miscellaneous", "" },

  { "WARLOCK_REAGENT", "", "Infernal Stone", "Reagent", "" },
  { "WARLOCK_REAGENT", "", "Demonic Figurine", "Reagent", "" },

  { "ROGUE_REAGENT", "", "Blinding Powder", "", "" },
  { "ROGUE_REAGENT", "", "Flash Powder", "", "" },

  { "DRUID_REAGENT", "", " Seed", "Reagent", "" },
  { "DRUID_REAGENT", "", "Wild ", "Reagent", "" },
  { "MAGE_REAGENT", "", "Arcane Powder", "Reagent", "" },
  { "MAGE_REAGENT", "", "Rune of ", "Reagent", "" },
  { "PALADIN_REAGENT", "", "Symbol of", "Reagent", "" },
  { "PRIEST_REAGENT", "", " Candle", "Reagent", "" },
  { "SHAMAN_REAGENT", "", "Ankh", "Reagent", "" },
  { "SHAMAN_REAGENT", "", "Fish Oil", "", "" },
  { "SHAMAN_REAGENT", "", "Shiny Fish Scales", "", "" },

  { "ROGUE_TOOL", "", "Thieves' Tools", "", "" },
  { "SHAMAN_TOOL", "", " Totem", "Reagent", "" },
  { "SOULSHARD", "", "Soul Shard", "Reagent", "" },

  { "DUMMY", "", "Target Dummy", "Trade Goods", "" },

-- Trades (fishing done above before equipment)
  { "ALCHEMY", "", " Vial", "Trade Goods", "" },
  { "CLOTH", "",   "[cC]loth", "Trade Goods", "" },
  { "TRADE1", "TRADE1", "", "", "" },
  { "TRADE2", "TRADE2", "", "", "" },
  { "TRADE1_CREATED", "TRADE1_CREATED", "", "", "" },
  { "TRADE2_CREATED", "TRADE2_CREATED", "", "", "" },
  { "POISONS_CREATED", "POISONS_CREATED", "", "", "" },
  { "POISONS_CREATED", "", "%a+ Poison [IV]*", "", "" },
  { "POISONS", "POISONS", "", "", "" },
  { "ENCHANTING", "", "%a+ Dust", "", "" },
  { "ENCHANTING", "", "Lesser %a+ Essence", "", "" },
  { "ENCHANTING", "", "Greater %a+ Essence", "", "" },
  { "ENCHANTING", "", "Small %a+ Shard", "", "" },
  { "ENCHANTING", "", "Large %a+ Shard", "", "" },
  { "FISHING", "FISHING", "", "", "" },
  { "COOKING", "COOKING", "", "", "" },
  { "COOKING", "", "Raw ", "Consumable", "" },
  { "COOKING", "", "[Ff]ish", "Consumable", "" },
  { "COOKING", "", " Meat", "Trade Goods", "" },
  { "FIRST_AID", "FIRST_AID", "", "", "" },

  { "REAGENT", "", "", "Reagent", "" },
  { "TRADE_GOODS", "", "", "Trade Goods", "" },

-- Random catchalls
  { "CONSUMABLE", "", "", "Consumable", "" },
  { "MISC", "", "", "Miscellaneous", "" },

-- Who knows?
  { "SOULBOUND_OTHER", "SOULBOUND", "", "", "" },
  { "UNKNOWN", "", "", "", "" }
};

-- Main localization array.  The above search list gets localized with this

TBAG_LOC = {
  [""] = "",  -- Needed to preserve nil returns

-----------------------------------------------------------------------
-- SKILLS
-----------------------------------------------------------------------

-- Secondary skills
  ["Cooking"] = "Cooking",
  ["Fishing"] = "Fishing",
  ["First Aid"] = "First Aid",

-- Primary professions
  ["TRADE1"] = "TRADE1",
  ["TRADE2"] = "TRADE2",
  ["Alchemy"] = "Alchemy",
  ["Blacksmithing"] = "Blacksmithing",
  ["Enchanting"] = "Enchanting",
  ["Engineering"] = "Engineering",
  ["Jewelcrafting"] = "Jewelcrafting",
  ["Leatherworking"] = "Leatherworking",
  ["Tailoring"] = "Tailoring",

-- Gathering
  ["Skinning"] = "Skinning",
  ["Mining"] = "Mining",
  ["Herbalism"] = "Herbalism",

-- Other skills
  ["Lockpicking"] = "Lockpicking",
  ["Poisons"] = "Poisons",

-----------------------------------------------------------------------
-- TYPES
-----------------------------------------------------------------------

  ["Armor"] = "Armor",
  ["Consumable"] = "Consumable",
  ["Container"] = "Container",
  ["Miscellaneous"] = "Miscellaneous",
  ["Projectile"] = "Projectile",
  ["Quest"] = "Quest",
  ["Quiver"] = "Quiver",
  ["Reagent"] = "Reagent",
  ["Recipe"] = "Recipe",
  ["Trade Goods"] = "Trade Goods",
  ["Weapon"] = "Weapon",

  ["Explosives"] = "Explosives",

  ["Finger"] = "Finger",
  ["Trinket"] = "Trinket",
  ["Relic"] = "Relic",

  ["Soulbound"] = "Soulbound",

-----------------------------------------------------------------------
-- CLASSES
-----------------------------------------------------------------------

  ["Druid"] = "Druid",
  ["Hunter"] = "Hunter",
  ["Mage"] = "Mage",
  ["Paladin"] = "Paladin",
  ["Priest"] = "Priest",
  ["Rogue"] = "Rogue",
  ["Shaman"] = "Shaman",
  ["Warlock"] = "Warlock",
  ["Warrior"] = "Warrior",

-----------------------------------------------------------------------
-- WINDOW STRINGS
-----------------------------------------------------------------------

  ["TBag_MenuTitle"] = "TBag v"..TBAG_VERSION,

  ["TBag_MoveLock_locked"] = "L",
  ["TBag_MoveLock_unlocked"] = "U",

  ["TBag_HighlightToggle_on"] = "Normal",
  ["TBag_HighlightToggle_on_tooltip"] = "Highlight of new items is ON.",
  ["TBag_HighlightToggle_off"] = "Hilight",
  ["TBag_HighlightToggle_off_tooltip"] = "Highlight of new items is OFF.",

  ["TBag_ChangeEditMode_on"] = "View",
  ["TBag_ChangeEditMode_off"] = "Edit",
  ["TBag_ChangeEditMode_tooltip_title"] = "Edit Mode",
  ["TBag_ChangeEditMode_tooltip"] = "Select this option to move classes of items into different 'bars' (the red numbers).",

  ["TBag_Reload_tooltip_title"] = "Re-sort View",
  ["TBag_Reload_tooltip"] = "Reloads your items and re-sorts their view.",

  ["TBag_ShowBank_on"] = "Show Bank",
  ["TBag_ShowBank_off"] = "Hide Bank",
  ["TBag_ShowBank_tooltip_title"] = "View Bank",
  ["TBag_ShowBank_tooltip"] = "Displays bank contents in a view-only mode.  You may select another player's bank to view from the dropdown.",

  ["TBag_ShowPurchase_on"] = "Show Purchase",
  ["TBag_ShowPurchase_off"] = "Hide Purchase",
  ["TBag_ShowPurchase_tooltip_title"] = "View Purchase Info",
  ["TBag_ShowPurchase_tooltip"] = "Displays the purchase button and cost to buy a new bank slot.  This is disabled in read-only views and edit mode.",

  ["TBag_ColumnsAdd_buttontitle"] = "<++>",
  ["TBag_ColumnsAdd_tooltip_title"] = "Window Size",
  ["TBag_ColumnsAdd_tooltip"] = "Increase the number of columns displayed",

  ["TBag_ColumnsDel_buttontitle"] = ">--<",
  ["TBag_ColumnsDel_tooltip_title"] = "Window Size",
  ["TBag_ColumnsDel_tooltip"] = "Decrease the number of columns displayed",
};

TBNK_HELP = {
    "TBnk Commands:",
    " /tbnk show  -- open window",
    " /tbnk hide  -- hide window",
    " /tbnk update  -- refresh the window",
    " /tbnk config  -- configuration options",
    " /tbnk debug  -- turn debug info on/off",
    " /tbnk reset  -- sets everything back to default values"
};

TINV_HELP = {
    "TInv Commands:",
    " /tinv show  -- open window",
    " /tinv hide  -- hide window",
    " /tinv update  -- refresh the window",
    " /tinv config  -- configuration options",
    " /tinv debug  -- turn debug info on/off",
    " /tinv reset  -- sets everything back to default values"
};


    SLASH_TBODY1                             = "/tbody";
    TBODY_SUBCMD_SHOW                        = "show";
    TBODY_SUBCMD_CLEAR                       = "clear";
    TBODY_SUBCMD_CLEARALL                    = "clearall";
    TBODY_SUBCMD_PREVIOUS                    = "previous";
    TBODY_SUBCMD_NEXT                        = "next";
    TBODY_SUBCMD_SWITCH                      = "switch";
    TBODY_SUBCMD_LIST                        = "list";
    TBODY_SUBCMD_BANK                        = "bank";
    TBODY_SUBCMD_RESETLOC                    = "resetloc";
    TBODY_SUBCMD_BAGS                        = "bags";
    TBODY_SUBCMD_BAGUSE                      = "baguse";

    -- Localization text
    BINDING_HEADER_TBODY                     = "Characters Viewer";
    BINDING_NAME_TBODY_TOGGLE                = "Open / Close CharactersViewer";
    BINDING_NAME_TBODY_BANKTOGGLE            = "Open / Close CharactersViewer Bank";
    BINDING_NAME_TBODY_SWITCH_PREVIOUS       = "Switch to the previous character";
    BINDING_NAME_TBODY_SWITCH_NEXT           = "Switch to the next character";

    TBODY_CRIT                               = "Critical";

    TBODY_SELPLAYER                          = "Switch";
    TBODY_DROPDOWN2                          = "Compare";
    TBODY_TOOLTIP_BAGRESET                   = "Left-Click: Toggle bags display on/off.\nRight-Click: Reset layout position.";
    TBODY_TOOLTIP_MAIL                       = "Left-Click: Toggle the Inbox(MailTo) display on/off.\nRight-Click: Reset layout position.";
    TBODY_TOOLTIP_BANK                       = "Left-Click: Toggle the Bank display on/off.\nRight-Click: Reset layout position.";
    TBODY_TOOLTIP_DROPDOWN2                  = "Click to select one of your other characters from the same server,\nit'll be displayed with CharactersViewer Frame";
    TBODY_TOOLTIP_BANKBAG                    = "Left-Click: Toggle bank bags display on/off.\nRight-Click: Reset layout position.";
    TBODY_SAVEDON                            = "Saved on: ";

    TBODY_PROFILECLEARED                     = "This profile has been deleted: ";
    TBODY_ALLPROFILECLEARED                  = "Profiles for all server have been cleared. Current character profile added";
    TBODY_NOT_FOUND                          = "Character not found: ";

    TBODY_USAGE                              = "Usage: '/cv <command>' where <command> is";
    TBODY_USAGE_SUBCMD                       = {};
    TBODY_USAGE_SUBCMD[1]                    = " show : displays equipment/stats in a PaperDoll window";
    TBODY_USAGE_SUBCMD[2]                    = " clear <arg1>: clear the profile of character <arg1>";
    TBODY_USAGE_SUBCMD[3]                    = " clearall : clear all stored equipement/stats for all chars in all servers";
    TBODY_USAGE_SUBCMD[4]                    = " previous : " .. BINDING_NAME_TBODY_SWITCH_PREVIOUS;
    TBODY_USAGE_SUBCMD[5]                    = " next : " .. BINDING_NAME_TBODY_SWITCH_NEXT;
    TBODY_USAGE_SUBCMD[6]                    = " switch <arg1>: Switch to character <arg1>";
    TBODY_USAGE_SUBCMD[7]                    = " list : Display various information about player on the current server";
    TBODY_USAGE_SUBCMD[8]                    = " bank : Toggle the Bank display on/off";
    TBODY_USAGE_SUBCMD[9]                    = " resetloc : Reset the position of the main frame of " .. BINDING_HEADER_TBODY;
    TBODY_USAGE_SUBCMD[10]                   = " bags : List the bag sizes owned by each character";
    TBODY_USAGE_SUBCMD[11]                   = " baguse : List the bag usage of each character";

    TBODY_DESCRIPTION                        = "View your other characters equipment, inventory and stats";
    TBODY_SHORT_DESC                         = "Toggle CV on/off";
    TBODY_ICON                               = "Interface\\Buttons\\Button-Backpack-Up";

    TBODY_NOT_CACHED                         = "Item not in local cache";
    TBODY_RESTED                             = "rested";
    TBODY_RESTING                            = "resting";
    TBODY_NOT_RESTING                        = "not resting";
    TBODY_BAG_USE                            = "Bags in use on ";

    TBODY_BANK_TITLE                         = "CharactersViewer (Bank)";
	TBODY_ALLIANCE_HORDE					= "Horde";
   TBODY_ALLIANCE_ALLIANCE				= "Alliance";
	TBODY_ALLIANCE_TOTAL					= "Total";



function TBag_Loc(str)
  -- Use the value if we can't find a localization
  if (TBAG_LOC[str]) then
    return TBAG_LOC[str];
  else
    return str;
  end
end

function TBag_Cat(str)
  -- Uppercase, and replace spaces
  local cat = string.upper(TBag_Loc(str));
  return string.gsub(cat, " ", "_");
end

function TBag_Localize()
  local locale = GetLocale();
--  if ( locale == "deDE" ) then
--    TBag_LocalizeDE();
--  elseif ( locale == "frFR" ) then
--    TBag_LocalizeFR();
--  elseif ( locale == "spSP" ) then
--    TBag_LocalizeSP();
--  end
end


