-- $Id$

-- This file serves as the template for starting a new
-- translation.  Just change the locale value below and
-- then edit the strings on the right hand side of the
-- list.  Rename the file to localization.locale.lua
-- (e.g. localization.deDE.lua).  Then add the file
-- to the TBag.toc below localization.enUS.lua but
-- above defaults.lua.
--
-- localization files should be edited with a utf-8 
-- compatable editor and done so with utf-8 encoding.

if GetLocale() ~= "deDE" then return end

-- A few of these translations are set to constants from 
-- Blizzard's GlobalStrings.lua which should be translated
-- for every locale already.  They should be left to the 
-- constants unless for some reason they are not translated
-- and need to be.

-- Some of these translations are setup to be passed to
-- string.format with %s and %d placeholders for
-- other text or data to be inserted later.  The
-- order of these placeholders must be preserved but
-- their exact position in the text is irrelevent.

-- Some of these translations include color codes
-- used by the game.  Most if not all of them are
-- also setup to be passed through to string.format
-- so the above note applies as well.  While the
-- color codes can be moved around they are necessary.

-- Some of these translations are actually patterns
-- used for the search list for determining what category
-- items are in.  Some of these will include character
-- class markers such as %a+ etc...  It may be difficult
-- to translate these without some understanding of lua
-- patterns.  Documentation can be found at:
-- http://www.wowwiki.com/HOWTO:_Use_Regular_Expressions

TBag.LOCALE = setmetatable({
  [""] = "",  -- Needed to preserve nil returns

-----------------------------------------------------------------------
-- SKILLS
-----------------------------------------------------------------------

-- Secondary skills
  ["Cooking"] = "Cooking",
  ["Fishing"] = "Fishing",
  ["First Aid"] = "First Aid",

-- Primary professions
  ["Alchemy"] = "Alchemy",
  ["Blacksmithing"] = "Blacksmithing",
  ["Enchanting"] = "Enchanting",
  ["Engineering"] = "Engineering",
  ["Jewelcrafting"] = "Jewelcrafting",
  ["Leatherworking"] = "Leatherworking",
  ["Tailoring"] = "Tailoring",
  ["Inscription"] = "Inscription",

-- Gathering
  ["Skinning"] = "Skinning",
  ["Mining"] = "Mining",
  ["Herbalism"] = "Herbalism",

-- Other skills
  ["Lockpicking"] = "Lockpicking",
  ["Poisons"] = "Poisons",
  ["Runeforging"] = "Runeforging",

-----------------------------------------------------------------------
-- SKILLS REVERSE locale -> enUS
-----------------------------------------------------------------------

-- Secondary skills
  ["Kochen"] = "Cooking",
  ["Angeln"] = "Fishing",
  ["Erste Hilfe"] = "First Aid",

-- Primary professions
  ["Alchimie"] = "Alchemy",
  ["Schmiedekunst"] = "Blacksmithing",
  ["Verzauberkunst"] = "Enchanting",
  ["Ingenieurskunst"] = "Engineering",
  ["Juwelenschleifen"] = "Jewelcrafting",
  ["Lederverarbeitung"] = "Leatherworking",
  ["Schneiderei"] = "Tailoring",
  ["Inscription deDE"] = "Inscription",

-- Gathering
  ["K\195\188rschnerei"] = "Skinning",
  ["Bergbau"] = "Mining",
  ["Kr\195\164uterkunde"] = "Herbalism",

-- Other skills
  ["Schlo\195\159knacken"] = "Lockpicking",
  ["Gifte"] = "Poisons",
  ["Runeforging"] = "Runeforging",

-----------------------------------------------------------------------
-- ITEM TYPES
-----------------------------------------------------------------------

  ["Armor"] = ARMOR,
  ["Consumable"] = "Consumable",
  ["Container"] = "Container",
  ["Miscellaneous"] = MISCELLANEOUS,
  ["Projectile"] = "Projectile",
  ["Quest"] = "Quest",
  ["Quiver"] = INVTYPE_QUIVER,
  ["Reagent"] = "Reagent",
  ["Recipe"] = "Recipe",
  ["Trade Goods"] = "Trade Goods",
  ["Weapon"] = "Weapon",
  ["Key"] = "Key",
  ["Elemental"] = "Elemental",
  ["Glyph"] = "Glyph",

  -- Sub types
  ["Junk"] = "Junk",
  ["Explosives"] = "Explosives",
  ["Devices"] = "Devices",
  ["Parts"] = "Parts",
  ["Ammo Pouch"] = "Ammo Pouch",
  ["Soul Bag"] = "Soul Bag",
  ["Engineering Bag"] = "Engineering Bag",
  ["Gem Bag"] = "Gem Bag",
  ["Herb Bag"] = "Herb Bag",
  ["Mining Bag"] = "Mining Bag",
  ["Enchanting Bag"] = "Enchanting Bag",
  ["Leatherworking Bag"] = "Leatherworking Bag",

  -- Slots
  ["Finger"] = INVTYPE_FINGER,
  ["Trinket"] = INVTYPE_TRINKET,
  ["Relic"] = INVTYPE_RELIC,

  ["Soulbound"] = ITEM_SOULBOUND,

-----------------------------------------------------------------------
-- BAG DISPLAY NAMES 
-----------------------------------------------------------------------

  ["Keyring"] = KEYRING,
  ["Bank"] = "Bank",
  ["Backpack"] = "Backpack",
  ["First Bag"] = "First Bag",
  ["Second Bag"] = "Second Bag",
  ["Third Bag"] = "Third Bag",
  ["Fourth Bag"] = "Fourth Bag",
  ["First Bank Bag"] = "First Bank Bag",
  ["Second Bank Bag"] = "Second Bank Bag",
  ["Third Bank Bag"] = "Third Bank Bag",
  ["Fourth Bank Bag"] = "Fourth Bank Bag",
  ["Fifth Bank Bag"] = "Fifth Bank Bag",
  ["Sixth Bank Bag"] = "Sixth Bank Bag",
  ["Seventh Bank Bag"] = "Seventh Bank Bag",
  ["Empty Slot"] = "Empty Slot",

-----------------------------------------------------------------------
-- CATEGORIES
-----------------------------------------------------------------------

  -- Templates that are used to create a number of categories.
  ["EMPTY_%s_SLOTS"] = "EMPTY_%s_SLOTS",
  ["IN_%s_BAG"] = "IN_%s_BAG",
  ["%s_CREATED"] = "%s_CREATED",
  ["SOULBOUND_%s"] = "SOULBOUND_%s",
  ["EQUIPPED_%s"] = "EQUIPPED_%s",
  ["%s_TOOL"] = "%s_TOOL",
  ["%s_REAGENT"] = "%s_REAGENT",

  -- Broad categories for item types
  ["PROJECTILE"] = "PROJECTILE",
  ["SOULSHARD"] = "SOULSHARD",
  ["CONSUMABLE"] = "CONSUMABLE",
  ["ACT_ON"] = "ACT_ON",
  ["ACT_OPEN"] = "ACT_OPEN",
  ["ACT_SELL"] = "ACT_SELL",
  ["BAG"] = "BAG",
  ["GRAY_ITEMS"] = "GRAY_ITEMS",
  ["QUEST"] = "QUEST",
  ["KEY_QUEST"] = "KEY_QUEST",
  ["KEY_OPEN"] = "KEY_OPEN",
  ["ENCHANTS"] = "ENCHANTS",
  ["GLYPHS"] = "GLYPHS",
  ["BOOK"] = "BOOK",
  ["DESIGN"] = "DESIGN",
  ["FORMULA"] = "FORMULA",
  ["RECIPE"] = "RECIPE",
  ["PATTERN"] = "PATTERN",
  ["PLANS"] = "PLANS",
  ["SCHEMATIC"] = "SCHEMATIC",
  ["RECIPE_OTHER"] = "RECIPE_OTHER",
  ["PVP"] = "PVP",
  ["REAGENT"] = "REAGENT",
  ["TRADE_GOODS"] = "TRADE_GOODS",
  ["CLOTH"] = "CLOTH",
  ["MINIPET"] = "MINIPET",
  ["COMBATPETS"] = "COMBATPETS",
  ["COSTUMES"] = "COSTUMES",
  ["FIREWORKS"] = "FIREWORKS",
  ["TOYS"] = "TOYS",
  ["MOUNT"] = "MOUNT",
  ["FOOD"] = "FOOD",
  ["FOOD_BUFF"] = "FOOD_BUFF",
  ["DRINK"] = "DRINK",
  ["COMBO"] = "COMBO",
  ["BUFF"] = "BUFF",
  ["DUMMY"] = "DUMMY",
  ["BANDAGE"] = "BANDAGE",
  ["HEALTH_RESTORE"] = "HEALTH_RESTORE",
  ["HEALTHSTONE"] = "HEALTHSTONE",
  ["MANA_RESTORE"] = "MANA_RESTORE",
  ["COMBO_RESTORE"] = "COMBO_RESTORE",
  ["RAGE_RESTORE"] = "RAGE_RESTORE",
  ["ENERGY_RESTORE"] = "ENERGY_RESTORE",
  ["CURE"] = "CURE",
  ["EXPLOSIVES"] = "EXPLOSIVES",
  ["HEARTH"] = "HEARTH",
  ["MISC"] = "MISC",
  ["UNKNOWN"] = "UNKNOWN",

  -- Faction and Collectable Categories.
  ["THORIUM_BROTHER"] = "THORIUM_BROTHER",
  ["TIMBERMAW"] = "TIMBERMAW",
  ["CENARION_EXPEDITION"] = "CENARION_EXPEDITION",
  ["SPOREGGAR"] = "SPOREGGAR",
  ["ARGENT_DAWN"] = "ARGENT_DAWN",
  ["ALDOR"] = "ALDOR",
  ["SCRYER"] = "SCRYER",
  ["SHA'TAR"] = "SHA'TAR",
  ["LOWER_CITY"] = "LOWER_CITY",
  ["AHN_QIRAJ"] = "AHN_QIRAJ",
  ["CENARION_CIRCLE"] = "CENARION_CIRCLE",
  ["NETHERWING"] = "NETHERWING",
  ["BLACKWING_LAIR"] = "BLACKWING_LAIR",
  ["DARKMOON_FAIRE"] = "DARKMOON_FAIRE",
  ["OGRI'LA"] = "OGRI'LA",
  ["MOLTEN_CORE"] = "MOLTEN_CORE",
  ["ZUL_GURUB"] = "ZUL_GURUB",
  ["CONSORTIUM"] = "CONSORTIUM",
  ["HALAA"] = "HALAA",

  -- Tradeskill categories
  ["TRADE1"] = "TRADE1",
  ["TRADE2"] = "TRADE2",
  ["ALCHEMY"] = "ALCHEMY",
  ["BLACKSMITHING"] = "BLACKSMITHING",
  ["ENCHANTING"] = "ENCHANTING",
  ["ENGINEERING"] = "ENGINEERING",
  ["JEWELCRAFTING"] = "JEWELCRAFTING",
  ["LEATHERWORKING"] = "LEATHERWORKING",
  ["MINING"] = "MINING",
  ["POISONS"] = "POISONS",
  ["TAILORING"] = "TAILORING",
  ["INSCRIPTION"] = "INSCRIPTION",
  ["FIRST_AID"] = "FIRST_AID",
  ["COOKING"] = "COOKING",
  ["FISHING"] = "FISHING",
  ["RUNEFORGING"] = "RUNEFORGING",
  ["TRADE_TOOL"] = "TRADE_TOOL",

  -- Item slot categories
  -- Note the categories with numbers in them must sort in the same order
  -- per the standard lua sort.  Numbering like this is probably needed
  -- for all languages to preserve the sort order.
  ["01_HEAD"] = "01_HEAD",
  ["02_NECK"] = "02_NECK",
  ["03_SHOULDER"] = "03_SHOULDER",
  ["04_BACK"] = "04_BACK",
  ["05_CHEST"] = "05_CHEST",
  ["06_SHIRT"] = "06_SHIRT",
  ["07_TABARD"] = "07_TABARD",
  ["08_WRIST"] = "08_WRIST",
  ["09_HANDS"] = "09_HANDS",
  ["10_WAIST"] = "10_WAIST",
  ["11_LEGS"] = "11_LEGS",
  ["12_FEET"] = "12_FEET",
  ["13_OFFHAND"] = "13_OFFHAND",
  ["RELIC"] = "RELIC",
  ["RING"] = "RING",
  ["TRINKET"] = "TRINKET",
  ["ARMOR"] = "ARMOR",
  ["WEAPON"] = "WEAPON",
  ["OTHER"] = "OTHER",
 
  -- Class Categories
  ["DRUID"] = "DRUID",
  ["WARLOCK"] = "WARLOCK",
  ["ROGUE"] = "ROGUE",
  ["MAGE"] = "MAGE",
  ["PALADIN"] = "PALADIN",
  ["PRIEST"] = "PRIEST",
  ["SHAMAN"] = "SHAMAN",
  ["WARRIOR"] = "WARRIOR",
  ["HUNTER"] = "HUNTER",
  ["DEATHKNIGHT"] = "DEATHKNIGHT",
  ["CLASS_TOOL"] = "CLASS_TOOL",
  ["CLASS_REAGENT"] = "CLASS_REAGENT",
  
  -- Short bag type names used for EMPTY_%s_SLOTS and IN_%s_BAG categories
  -- 3-4 characters is about right for these.
  ["BAG"] = "BAG",
  ["QUIV"] = "QUIV",
  ["AMMO"] = "AMMO",
  ["SOUL"] = "SOUL",
  ["ENG"] = "ENG",
  ["GEM"] = "GEM",
  ["HERB"] = "HERB",
  ["MINE"] = "MINE",
  ["ENCH"] = "ENCH",
  ["LTHR"] = "LTHR",
  ["PET"] = "PET",
  ["UNKNOWN"] = "UNKNOWN",

  -- Bag Position Names, also used for EMPTY_%s_SLOTS and IN_%s_BAG categories
  ["KEYRING"] = "KEYRING",
  ["BANK"] = "BANK",
  ["BACKPACK"] = "BACKPACK",
  ["BAG1"] = "BAG1",
  ["BAG2"] = "BAG2",
  ["BAG3"] = "BAG3",
  ["BAG4"] = "BAG4",
  ["BBAG1"] = "BBAG1",
  ["BBAG2"] = "BBAG2",
  ["BBAG3"] = "BBAG3",
  ["BBAG4"] = "BBAG4",
  ["BBAG5"] = "BBAG5",
  ["BBAG6"] = "BBAG6",
  ["BBAG7"] = "BBAG7",
  
  -- Keywords
  ["SOULBOUND"] = "SOULBOUND",
  ["EQUIPPED"] = "EQUIPPED",

-----------------------------------------------------------------------
-- CHAT STRINGS
-----------------------------------------------------------------------

  ["%sSetting keybind to %q"] = "%sSetting keybind to %q",
  ["Unassigned category %s has been assigned to slot 1"] = 
      "Unassigned category %s has been assigned to slot 1", 
  ["Character data cached for:"] = "Character data cached for:",
  ["Removed cache for %q"] = "Removed cache for %q",
  ["Couldn't find and remove cache for %q"] = 
      "Couldn't find and remove cache for %q",       
-----------------------------------------------------------------------
-- SEARCH OUTPUT STRINGS 
-----------------------------------------------------------------------
  ["Search results for %q:"] = "Search results for %q:",
  ["No results|r for %q"] = "No results|r for %q",
  [" found:"] = " found:",
  ["bags"] = "bags",
  ["bank"] = "bank",
  ["container"] = "container",
  ["body"] = "body",
  ["mail"] = "mail",
  ["tokens"] = "tokens",
  [" in %s's %s"] = " in %s's %s", -- Used when an item is found in a characters bag or bank
  [" on %s's %s"] = " on %s's %s", -- Used when an item is found on a characters body
  [" as %s's %s"] = " as %s's %s", -- Used when an item is used as a container for a character

-----------------------------------------------------------------------
-- HEARTHSTONE 
-----------------------------------------------------------------------
  -- These two strings are used to replace the home location on the tooltip
  -- for Hearthstones.  The first string should be translated to match the
  -- text from the Use: up to the actual location and end on the period.
  -- If you keep it to just 3 captures with the 2nd capture from the
  -- expression being the location then you probably don't need to change
  -- the 2nd line.  The 2nd line controls putting the string back together.
  -- %%1 and %%3 represent the first and third captures from the previous
  -- expresion.  %s is the location that will be replaced.
  ["(Use: Returns you to )([^%.]*)(%.)"] = "(Use: Returns you to )([^%.]*)(%.)",
  ["%%1%s%%3"] = "%%1%s%%3",

  -- Generic name for the home location if we don't have it cached.
  -- The tooltip should have something like this where in the text
  -- where it describes how to change your bind point.  Brackets are
  -- there to imply it's a placeholder.
  ["<home location>"] = "<home location>",

-----------------------------------------------------------------------
-- CHARGES 
-----------------------------------------------------------------------
  -- Pattern to get the charges from a tooltip
  -- Probably only need to chage the Charges.
  -- The ? after the s implies that the s may not be there
  -- as would be the case in a single Charge.
  ["(%d+) Charges?"] = "(%d+) Charges?",
  -- Format string for adding the charges tooltip.
  -- %d is the number of charges.  |4 specifies this
  -- is a plural/singular pair.  Up until the : is the
  -- singular form after is the plural until the ;.
  ["%d |4Charge:Charges;"] = "%d |4Charge:Charges;",

-----------------------------------------------------------------------
-- BINDING STRINGS 
-----------------------------------------------------------------------
  ["Toggle Bank Window"] = "Toggle Bank Window",
  ["Toggle Inventory Window"] = "Toggle Inventory Window",
  
-----------------------------------------------------------------------
-- COMMAND LINE STRINGS 
-----------------------------------------------------------------------
  -- commands
  ["hide"] = "hide",
  ["show"] = "show",
  ["update"] = "update",
  ["debug"] = "debug",
  ["reset"] = "reset",
  ["resetpos"] = "resetpos",
  ["resetsorts"] = "resetsorts",
  ["printchars"] = "printchars",
  ["deletechar"] = "deletechar",
  ["config"] = "config",
  ["tests"] = "tests",
  ["getcat"] = "getcat",

  -- /tbnk help text
  ["TBnk Commands:"] = "TBnk Commands",
  [" /tbnk show  -- open window"] = " /tbnk show  -- open window",
  [" /tbnk hide  -- hide window"] = " /tbnk hide  -- hide window",
  [" /tbnk update  -- refresh the window"] = " /tbnk update  -- refresh the window",
  [" /tbnk config  -- configuration options"] = " /tbnk config  -- configuration options",
  [" /tbnk debug  -- turn debug info on/off"] = " /tbnk debug  -- turn debug info on/off",
  [" /tbnk reset  -- sets everything back to default values"] = " /tbnk reset  -- sets everything back to default values",
  [" /tbnk resetpos -- put the bank back to its default position"] = " /tbnk resetpos -- put the bank back to its default position",
  [" /tbnk resetsorts -- clears the item search list"] = " /tbnk resetsorts -- clears the item search list",
  [" /tbnk printchars -- prints a list of all the chars with cached info"] = " /tbnk printchars -- prints a list of all the chars with cached info",
  [" /tbnk deletechar CHAR SERVER -- clears all cached info for character "] = " /tbnk deletechar CHAR SERVER -- clears all cached info for character ",

  -- /tinv help text
  ["TInv Commands:"] = "TInv Commands:",
  [" /tinv show  -- open window"] = " /tinv show  -- open window",
  [" /tinv hide  -- hide window"] = " /tinv hide  -- hide window",
  [" /tinv update  -- refresh the window"] = " /tinv update  -- refresh the window",
  [" /tinv config  -- configuration options"] = " /tinv config  -- configuration options",
  [" /tinv debug  -- turn debug info on/off"] = " /tinv debug  -- turn debug info on/off",
  [" /tinv reset  -- sets everything back to default values"] = " /tinv reset  -- sets everything back to default values",
  [" /tinv resetpos -- put the inventory window back to its default position"] = " /tinv resetpos -- put the inventory window back to its default position",
  [" /tinv resetsorts -- clears the item search list"] = " /tinv resetsorts -- clears the item search list",
  [" /tinv printchars -- prints a list of all the chars with cached info"] = " /tinv printchars -- prints a list of all the chars with cached info",
  [" /tinv deletechar CHAR SERVER -- clears all cached info for character "] = " /tinv deletechar CHAR SERVER -- clears all cached info for character ",

-----------------------------------------------------------------------
-- WINDOW STRINGS
-----------------------------------------------------------------------
  ["TBag v%s"] = "TBag v%s",

  ["Normal"] = "Normal",
  ["Stop highlighting new items."] = "Stop highlighting new items.",
  ["Highlight New"] = "Highlight New",
  ["Highlight items marked as new."] = "Highlight items marked as new.",
  ["Clear Search"] = "Clear Search",
  ["Stop highlighting search results."] = "Stop highlighting search results.",

  ["Toggle Edit Mode"] = "Toggle Edit Mode",
  ["Select this option to move classes of items into different 'bars' (the red numbers)."] = "Select this option to move classes of items into different 'bars' (the red numbers).",

  ["Reload and Sort"] = "Reload and Sort",
  ["Reloads your items and sorts them."] = "Reloads your items and sorts them.",

  ["Toggle Bank"] = "Toggle Bank",
  ["Displays bank contents in a view-only mode.  You may select another player's bank to view from the dropdown."] = "Displays bank contents in a view-only mode.  You may select another player's bank to view from the dropdown.",

  ["Toggle Purchase Info"] = "Toggle Purchase Info",
  ["Displays the purchase button and cost to buy a new bank slot.  This is disabled in read-only views and edit mode."] = "Displays the purchase button and cost to buy a new bank slot.  This is disabled in read-only views and edit mode.",

  ["Unlock Window"] = "Unlock Window",
  ["Allow window to be moved by dragging it."] = "Allow window to be moved by dragging it.",
  ["Lock Window"] = "Lock Window",
  ["Prevent window from being moved by dragging it."] = "Prevent window from being moved by dragging it.",
  
  ["<++>"] = "<++>",
  ["Increase Window Size"] = "Increase Window Size",
  ["Increase the number of columns displayed"] = "Increase the number of columns displayed",

  [">--<"] = ">--<",
  ["Decrease Window Size"] = "Decrease Window Size",
  ["Decrease the number of columns displayed"] = "Decrease the number of columns displayed",

  ["Reset"] = "Reset",
  ["Close"] = "Close",
  ["Add New Cat"] = "Add New Cat",
  ["Assign Cats"] = "Assign Cats",
  ["No"] = "No",
  ["Yes"] = "Yes",
  ["Category"] = "Category",
  ["Keywords"] = "Keywords",
  ["Tooltip Search"] = "Tooltip Search",
  ["Type"] = "Type",
  ["SubType"] = "SubType",
  
  -- Menus and Tooltips
  ["Main Background Color"] = "Main Background Color",
  ["Main Border Color"] = "Main Border Color",
  ["Set Bar Colors to Main Colors"] = "Set Bar Colors to Main Colors",
  ["Spotlight for %s"] = "Spotlight for %s",
  ["Current Category: %s"] = "Current Category: %s",
  ["Assign item to category:"] = "Assign item to category:",
  ["Use default category assignment"] = "Use default category assignment",
  ["Debug Info: "] = "Debug Info: ",
  ["Categories within bar %d"] = "Categories within bar %d",
  ["Move: |c%s%s|r"] = "Move: |c%s%s|r",
  ["Sort Mode:"] = "Sort Mode:",
  ["No sort"] = "No sort",
  ["Sort by name"] = "Sort by name",
  ["Sort last words first"] = "Sort last words first",
  ["Highlight new items:"] = "Highlight new items:",
  ["Don't tag new items"] = "Don't tag new items",
  ["Tag new items"] = "Tag new items",
  ["Hide Bar:"] = "Hide Bar:",
  ["Show items assigned to this bar"] = "Show items assigned to this bar",
  ["Hide items assigned to this bar"] = "Hide items assigned to this bar",
  ["Color:"] = "Color:",
  ["Background Color for Bar %d"] = "Background Color for Bar %d",
  ["Border Color for Bar %d"] = "Border Color for Bar %d",
  ["Select Character"] = "Select Character",
  ["Edit Mode"] = "Edit Mode",
  ["Lock window"] = "Lock window",
  ["Show Purchase Info"] = "Show Purchase Info",
  ["Close Inventory"] = "Close Inventory",
  ["Highlight New Items"] = "Highlight New Items",
  ["Reset NEW tag"] = "Reset NEW tag",
  ["Advanced Configuration"] = "Advanced Configuration",
  ["Set Size"] = "Set Size",
  ["Set Colors"] = "Set Colors",
  ["Hide"] = "Hide",
  ["Hide Player Dropdown"] = "Hide Player Dropdown",
  ["Hide Search Box"] = "Hide Search Box",
  ["Hide Re-sort Button"] = "Hide Re-sort Button",
  ["Hide Bank Button"] = "Hide Bank Button",
  ["Hide Show Purchase Button"] = "Hide Show Purchase Button",
  ["Hide Edit Button"] = "Hide Edit Button",
  ["Hide Highlight Button"] = "Hide Highlight Button",
  ["Hide Lock Button"] = "Hide Lock Button",
  ["Hide Close Button"] = "Hide Close Button",
  ["Hide Total"] = "Hide Total",
  ["Hide Bag Buttons"] = "Hide Bag Buttons",
  ["Hide Money"] = "Hide Money",
  ["Hide Tokens"] = "Hide Tokens",
  ["The Bank"] = "The Bank",
  ["|c%sLeft click to move category |r|c%s%s|r|c%s to bar |r|c%s%s|r"] = "|c%sLeft click to move category |r|c%s%s|r|c%s to bar |r|c%s%s|r",
  ["|c%sBar |r|c%s%s|r"] = "|c%sBar |r|c%s%s|r",
  ["|c%s%s|r"] = "|c%s%s|r",
  ["Right click for options"] = "Right click for options",
  ["|c%sLeft click to select category to move:|r |c%s%s|r"] = "|c%sLeft click to select category to move:|r |c%s%s|r",
  ["Right click to assign this item to a different category"] = "Right click to assign this item to a different category",
  ["You are viewing the selected player's bank."] = "You are viewing the selected player's bank.",
  ["You are viewing the selected player's inventory."] = "You are viewing the selected player's inventory.",
  ["Equip Container"] = "Equip Container",
  ["Anchor"] = "Anchor",
  ["TOPLEFT"] = "TOPLEFT",
  ["TOPRIGHT"] = "TOPRIGHT",
  ["BOTTOMLEFT"] = "BOTTOMLEFT",
  ["BOTTOMRIGHT"] = "BOTTOMRIGHT",
  ["Show on TBag"] = "Show on TBag",
  ["Checking this option will allow you to track this currency type in TBag for this character.\n\nYou can also Shift-click a currency to add or remove it from being tracked in TBag."] = "Checking this option will allow you to track this currency type in TBag for this character.\n\nYou can also Shift-click a currency to add or remove it from being tracked in TBag.",

  -- Option Window Strings
  ["Main Sizing Preferences"] = "Main Sizing Preferences",
  ["Number of Item Columns:"] = "Number of Item Columns:",
  ["Number of Horizontal Bars:"] = "Number of Horizontal Bars:",
  ["Window Scale:"] = "Window Scale:",
  ["Item Button Size:"] = "Item Button Size:",
  ["Item Button Padding:"] = "Item Button Padding:",
  ["Spacing - X Button:"] = "Spacing - X Button:",
  ["Spacing - Y Button:"] = "Spacing - Y Button:",
  ["Spacing - X Pool:"] = "Spacing - X Pool:",
  ["Spacing - Y Pool:"] = "Spacing - Y Pool:",
  ["Count Font Size:"] = "Count Font Size:",
  ["Count Placement - X:"] = "Count Placement - X:",
  ["Count Placement - Y:"] = "Count Placement - Y:",
  ["New Tag Font Size:"] = "New Tag Font Size:",
  ["Bag Contents Show"] = "Bag Contents Show",
  ["Show %s:"] = "Show %s:",
  ["General Display Preferences"] = "General Display Preferences",
  ["Show Size on Bag Count:"] = "Show Size on Bag Count:",
  ["Show Bag Icons on Empty Slots:"] = "Show Bag Icons on Empty Slots:",
  ["Spotlight Open or Selected Bags:"] = "Spotlight Open or Selected Bags:",
  ["Spotlight Mouseover:"] = "Spotlight Mouseover:",
  ["Show Item Rarity Color:"] = "Show Item Rarity Color:",
  ["Auto Stack:"] = "Auto Stack:",
  ["Stack on Re-sort:"] = "Stack on Re-sort:",
  ["Profession Bags precede Sorting:"] = "Profession Bags precede Sorting:",
  ["Trade Creation precedes Sorting (Reopen Window):"] = "Trade Creation precedes Sorting (Reopen Window):",
  ["New Tag Options"] = "New Tag Options",
  ["New Tag Text:"] = "New Tag Text:",
  ["Increased Tag Text:"] = "Increased Tag Text:",
  ["Decreased Tag Text:"] = "Decreased Tag Text:",
  ["New Tag Timeout (minutes):"] = "New Tag Timeout (minutes):",
  ["Recent Tag Timeout (minutes):"] = "Recent Tag Timeout (minutes):",
  ["Alt Key Auto-Pickup:"] = "Alt Key Auto-Pickup:",
  ["Alt Key Auto-Panel:"] = "Alt Key Auto-Panel:",
  ["Show Keyring Empty Slots (Enable Show above):"] = "Show Keyring Empty Slots (Enable Show above):",
  ["Show Soul Shard Count On Soul Bags:"] = "Show Soul Shard Count On Soul Bags:",

-----------------------------------------------------------------------
-- Unit Tests 
-----------------------------------------------------------------------
  ["TEST RUN STARTING"] = "TEST RUN STARTING",
  [" Retrieving item information"] = " Retrieving item information",
  ["SUCCESS: %s"] = "SUCCESS: %s",
  ["FAIL: %s (%s) expected %q but got %q"] = "FAIL: %s (%s) expected %q but got %q",
  ["ALL TESTS SUCCESSFUL"] = "ALL TESTS SUCCESSFUL",

-----------------------------------------------------------------------
-- Default Search List Strings 
-----------------------------------------------------------------------
  ["This Item Begins a Quest"] = ITEM_STARTS_QUEST,
  ["<Right Click to Open>"] = ITEM_OPENABLE,
  [" Lockbox"] = " Lockbox",
  ["Mark of Honor"] = "Mark of Honor",
  ["Mark of Honor Hold"] = "Mark of Honor Hold",
  ["Mark of Thrallmar"] = "Mark of Thrallmar",
  ["Halaa Battle Token"] = "Halaa Battle Token",
  ["Spirit Shard"] = "Spirit Shard",
  ["Use: Permanently"] = "Use: Permanently",
  ["Hearthstone"] = "Hearthstone",
  ["Right Click to summon and dismiss"] = "Right Click to summon and dismiss",
  ["Summons or dismisses a Spirit of"] = "Summons or dismisses a Spirit of",
  ["Use: Teaches you how to summon this companion."] = "Use: Teaches you how to summon this companion.",
  ["Requires Riding %("] = "Requires Riding %(",
  ["%a+ Scarab"] = "%a+ Scarab",
  ["%a+ Idol"] = "%a+ Idol",
  ["Qiraji %a+ %a+"] = "Qiraji %a+ %a+",
  ["Bone Fragments"] = "Bone Fragments",
  ["Core of Elements"] = "Core of Elements",
  ["Crypt Fiend Parts"] = "Crypt Fiend Parts",
  ["Dark Iron Scraps"] = "Dark Iron Scraps",
  ["Savage Frond"] = "Savage Frond",
  ["Insignia of the Crusade"] = "Insignia of the Crusade",
  ["Insignia of the Dawn"] = "Insignia of the Dawn",
  ["Argent Dawn Valor Token"] = "Argent Dawn Valor Token",
  ["Mantle of the Dawn"] = "Mantle of the Dawn",
  ["Vitreous Focuser"] = "Vitreous Focuser",
  ["Osseous Agitator"] = "Osseous Agitator",
  ["Somatic Intensifier"] = "Somatic Intensifier",
  ["Ectoplasmic Resonator"] = "Ectoplasmic Resonator",
  ["Arcane Quickener"] = "Arcane Quickener",
  [" Scourgestone"] = " Scourgestone",
  ["Cenarion %a+ Badge"] = "Cenarion %a+ Badge",
  ["Twilight Text"] = "Twilight Text",
  ["Twilight Cultist"] = "Twilight Cultist",
  ["Abyssal Crest"] = "Abyssal Crest",
  ["Abyssal Signet"] = "Abyssal Signet",
  ["Abyssal Scepter"] = "Abyssal Scepter",
  ["Darkmoon Faire Prize Ticket"] = "Darkmoon Faire Prize Ticket",
  ["Soft Bushy Tail"] = "Soft Bushy Tail",
  ["Vibrant Plume"] = "Vibrant Plume",
  ["Small Furry Paw"] = "Small Furry Paw",
  ["Evil Bat Eye"] = "Evil Bat Eye",
  ["Torn Bear Pelt"] = "Torn Bear Pelt",
  ["Glowing Scorpid Blood"] = "Glowing Scorpid Blood",
  ["Warlords"] = "Warlords",
  ["Elementals"] = "Elementals",
  ["Portals"] = "Portals",
  ["Beasts"] = "Beasts",
  ["Blessings"] = "Blessings",
  ["Furies"] = "Furies",
  ["Lunacy"] = "Lunacy",
  ["Storms"] = "Storms",
  ["Incendosaur Scale"] = "Incendosaur Scale",
  ["Dark Iron Residue"] = "Dark Iron Residue",
  ["Deadwood Headdress Feather"] = "Deadwood Headdress Feather",
  ["Winterfall Spirit Beads"] = "Winterfall Spirit Beads",
  ["Zandalar Honor Token"] = "Zandalar Honor Token",
  ["%a+ Coin"] = "%a+ Coin",
  ["%a+ Bijou"] = "%a+ Bijou",
  ["Primal Hakkari"] = "Primal Hakkari",
  ["Apexis Crystal"] = "Apexis Crystal",
  ["to create a dragonscale cloak"] = "to create a dragonscale cloak",
  ["Darkrune"] = "Darkrune",
  ["Netherwing Egg"] = "Netherwing Egg",
  ["Nethercite Ore"] = "Nethercite Ore",
  ["Netherdust Pollen"] = "Netherdust Pollen",
  ["Netherwing Crystal"] = "Netherwing Crystal",
  ["Nethermine Cargo"] = "Nethermine Cargo",
  ["Unidentified Plant Parts"] = "Unidentified Plant Parts",
  ["Coilfang Armaments"] = "Coilfang Armaments",
  ["Mature Spore Sac"] = "Mature Spore Sac",
  ["Bog Lord Tendril"] = "Bog Lord Tendril",
  ["Glowcap"] = "Glowcap",
  ["Fertile Spores"] = "Fertile Spores",
  ["Sanguine Hibiscus"] = "Sanguine Hibiscus",
  ["Obsidian Warbeads"] = "Obsidian Warbeads",
  ["Oshu'gun Crystal Fragment"] = "Oshu'gun Crystal Fragment",
  ["Pair of Ivory Tusks"] = "Pair of Ivory Tusks",
  ["Zaxxis Insignia"] = "Zaxxis Insignia",
  ["Ethereum Prisoner I%.D%. Tag"] = "Ethereum Prisoner I%.D%. Tag",
  ["Ethereum Prison Key"] = "Ethereum Prison Key",
  ["Halaa Research Token"] = "Halaa Research Token",
  ["Oshu'gun Crystal Powder Sample"] = "Oshu'gun Crystal Powder Sample",
  ["Dampscale Basilisk Eye"] = "Dampscale Basilisk Eye",
  ["Firewing Signet"] = "Firewing Signet",
  ["Sunfury Signet"] = "Sunfury Signet",
  ["Arcane Tome"] = "Arcane Tome",
  ["Arcane Rune"] = "Arcane Rune",
  ["Dreadfang Venom Sac"] = "Dreadfang Venom Sac",
  ["Mark of Kil'jaeden"] = "Mark of Kil'jaeden",
  ["Mark of Sargeras"] = "Mark of Sargeras",
  ["Fel Armament"] = "Fel Armament",
  ["Holy Dust"] = "Holy Dust",
  ["Mark of the Illidari"] = "Mark of the Illidari",
  ["Badge of Justice"] = "Badge of Justice",
  ["Arakkoa Feather"] = "Arakkoa Feather",
  ["Quest Item"] = ITEM_BIND_QUEST,
  ["Morbent"] = "Morbent",
  ["Codex: "] = "Codex: ",
  ["Manual: "] = "Manual: ",
  ["Expert "] = "Expert ",
  ["Tome of "] = "Tome of ",
  ["Design: "] = "Design: ",
  ["Formula: "] = "Formula: ",
  ["Recipe: "] = "Recipe: ",
  ["Pattern: "] = "Pattern: ",
  ["Plans: "] = "Plans: ",
  ["Schematic: "] = "Schematic: ",
  ["[Ss]kinning [Kk]nife"] = "[Ss]kinning [Kk]nife",
  ["[Mm]ining [Pp]ick"] = "[Mm]ining [Pp]ick",
  ["[Bb]lacksmith [Hh]ammer"] = "[Bb]lacksmith [Hh]ammer",
  ["Runed %a+ Rod"] = "Runed %a+ Rod",
  ["Philosopher's Stone"] = "Philosopher's Stone",
  ["Salt Shaker"] = "Salt Shaker",
  ["Arclight Spanner"] = "Arclight Spanner",
  ["Gyromatic Micro%-Adjustor"] = "Gyromatic Micro%-Adjustor",
  ["Zulian Slicer"] = "Zulian Slicer",
  ["Finkle's Skinner"] = "Finkle's Skinner",
  ["Blood Scythe"] = "Blood Scythe",
  ["Herbalist's Gloves"] = "Herbalist's Gloves",
  ["Dwarven Fishing Pole"] = "Dwarven Fishing Pole",
  ["Goblin Fishing Pole"] = "Goblin Fishing Pole",
  ["Everlasting Underspore Frond"] = "Everlasting Underspore Frond",
  ["\nHead"] = "\nHead",
  ["\nNeck"] = "\nNeck",
  ["\nShoulder"] = "\nShoulder",
  ["\nBack"] = "\nBack",
  ["\nChest"] = "\nChest",
  ["\nShirt"] = "\nShirt",
  ["\nTabard"] = "\nTabard",
  ["\nWrist"] = "\nWrist",
  ["\nHands"] = "\nHands",
  ["\nWaist"] = "\nWaist",
  ["\nLegs"] = "\nLegs",
  ["\nFeet"] = "\nFeet",
  ["\nHeld In Off%-hand"] = "\nHeld In Off%-hand",
  [" Bandage"] = " Bandage",
  ["Instantly restores %d+ life"] = "Instantly restores %d+ life",
  [" well fed "] = " well fed ",
  ["Restores %d+ health.* increases your "] = "Restores %d+ health.* increases your ",
  ["Must remain seated while drinking%."] = "Must remain seated while drinking%.",
  ["Restores %d+ mana over %d+ sec"] = "Restores %d+ mana over %d+ sec",
  ["Restores %d+ health and %d+ mana over %d+ sec"] = "Restores %d+ health and %d+ mana over %d+ sec",
  ["Restores .* health and mana .* %d+ sec"] = "Restores .* health and mana .* %d+ sec",
  ["Must remain seated while eating%."] = "Must remain seated while eating%.",
  ["Restores %d+ health over %d+ sec"] = "Restores %d+ health over %d+ sec",
  ["Thistle Tea"] = "Thistle Tea",
  ["[Rr]estores %d+ energy"] = "[Rr]estores %d+ energy",
  ["Rage Potion"] = "Rage Potion",
  ["[Rr]estores %d+ rage"] = "[Rr]estores %d+ rage",
  ["Rejuvenation Potion"] = "Rejuvenation Potion",
  ["Dreamless Sleep"] = "Dreamless Sleep",
  ["[Rr]estores %d+ to %d+ mana and health"] = "[Rr]estores %d+ to %d+ mana and health",
  ["Mana Potion"] = "Mana Potion",
  ["[Rr]estores %d+ to %d+ mana"] = "[Rr]estores %d+ to %d+ mana",
  ["Healing Potion"] = "Healing Potion",
  ["[Rr]estores %d+ to %d+ health"] = "[Rr]estores %d+ to %d+ health",
  ["Place a %a+ stone statue"] = "Place a %a+ stone statue",
  [" [Cc]ure.* poison"] = " [Cc]ure.* poison",
  [" [Cc]ure.* disease"] = " [Cc]ure.* disease",
  [" [Cc]ure.* curse"] = " [Cc]ure.* curse",
  [" [Cc]ure.* magic"] = " [Cc]ure.* magic",
  [" [Rr]emoves %d+ .*effect"] = " [Rr]emoves %d+ .*effect",
  [" Dynamite"] = " Dynamite",
  [" Bomb"] = " Bomb",
  [" Mortar"] = " Mortar",
  ["Scroll"] = "Scroll",
  ["Use: Increases "] = "Use: Increases ",
  ["Use: Absorbs "] = "Use: Absorbs ",
  ["Use: Regenerate "] = "Use: Regenerate ",
  ["Use: While applied to target weapon"] = "Use: While applied to target weapon",
  [" Sharpening Stone"] = " Sharpening Stone",
  [" Weightstone"] = " Weightstone",
  ["Mistletoe"] = "Mistletoe",
  ["Flame Cap"] = "Flame Cap",
  ["[AG][li][lv][oe]w?s the [Ii]mbiber "] = "[AG][li][lv][oe]w?s the [Ii]mbiber ",
  [" Key"] = " Key",
  ["Light Feather"] = "Light Feather",
  ["Infernal Stone"] = "Infernal Stone",
  ["Demonic Figurine"] = "Demonic Figurine",
  ["Flash Powder"] = "Flash Powder",
  [" Seed"] = " Seed",
  ["Wild "] = "Wild ",
  ["Arcane Powder"] = "Arcane Powder",
  ["Rune of "] = "Rune of ",
  ["Symbol of"] = "Symbol of",
  [" Candle"] = " Candle",
  ["Ankh"] = "Ankh",
  ["Fish Oil"] = "Fish Oil",
  ["Shiny Fish Scales"] = "Shiny Fish Scales",
  ["Thieves' Tools"] = "Thieves' Tools",
  [" Totem"] = " Totem",
  ["Soul Shard"] = "Soul Shard",
  ["Corpse Dust"] = "Corpse Dust",
  ["Target Dummy"] = "Target Dummy",
  ["Elemental %a+"] = "Elemental %a+",
  ["Essence of %a+"] = "Essence of %a+",
  ["Globe of Water"] = "Globe of Water",
  ["Breath of Wind"] = "Breath of Wind",
  ["Heart of Fire"] = "Heart of Fire",
  ["Core of Earth"] = "Core of Earth",
  ["Mote of %a+"] = "Mote of %a+",
  ["Primal Nether"] = "Primal Nether",
  ["Primal %a+"] = "Primal %a+",
  ["Void Crystal"] = "Void Crystal",
  ["Nether Vortex"] = "Nether Vortex",
  ["Sunmote"] = "Sunmote",
  ["Heart of Darkness"] = "Heart of Darkness",
  [" Vial"] = " Vial",
  ["[cC]loth"] = "[cC]loth",
  ["%a+ Poison [IV]*"] = "%a+ Poison [IV]*",
  ["Raw "] = "Raw ",
  ["[Ff]ish"] = "[Ff]ish",
  [" Meat"] = " Meat",
  ["%a+ Dust"] = "%a+ Dust",
  ["Lesser %a+ Essence"] = "Lesser %a+ Essence",
  ["Greater %a+ Essence"] = "Greater %a+ Essence",
  ["Small %a+ Shard"] = "Small %a+ Shard",
  ["Large %a+ Shard"] = "Large %a+ Shard",
  ["Papa Hummel's Old%-Fashioned Pet Biscuit"] = "Papa Hummel's Old%-Fashioned Pet Biscuit",
  ["Silver Shafted Arrow"] = "Silver Shafted Arrow",
  ["Crashin' Thrashin'"] = "Crashin' Thrashin'",
  ["Tonk Controller"] = "Tonk Controller",
  ["Mechanical Yeti"] = "Mechanical Yeti",
  ["Orb of the Sin'dorei"] = "Orb of the Sin'dorei",
  ["Orb of the Blackwhelp"] = "Orb of the Blackwhelp",
  ["Winter Veil Disguise Kit"] = "Winter Veil Disguise Kit",
  ["Hallowed Wand %- "] = "Hallowed Wand %- ",
  ["Murloc Costume"] = "Murloc Costume",
  ["Weighted Jack%-o'%-Lantern"] = "Weighted Jack%-o'%-Lantern",
  ["Gordok Ogre Suit"] = "Gordok Ogre Suit",
  ["Transforms your mount into something more festive"] = "Transforms your mount into something more festive",
  ["Shoots a.*firework"] = "Shoots a.*firework",
  ["Place on the ground to launch .* rockets"] = "Place on the ground to launch .* rockets",
  ["Throw into a .* launcher"] = "Throw into a .* launcher",
  ["Brazier of Dancing Flames"] = "Brazier of Dancing Flames",
  ["Direbrew's Remote"] = "Direbrew's Remote",
  ["Goblin Weather Machine %- Prototype 01%-B"] = "Goblin Weather Machine %- Prototype 01%-B",
  ["Use: Right Click to set up a .* picnic."] = "Use: Right Click to set up a .* picnic.",
  ["D\.I\.S\.C\.O\."] = "D\.I\.S\.C\.O\.",
  ["Imp in a Ball"] = "Imp in a Ball",
  ["Snowball"] = "Snowball",
  ["Paper Flying Machine Kit"] = "Paper Flying Machine Kit",
  ["If they have free room in their pack they will catch it"] = "If they have free room in their pack they will catch it",
  ["Fishing Chair"] = "Fishing Chair",
  ["Elune Stone"] = "Elune Stone",
  ["Shower a nearby target with a cascade of"] = "Shower a nearby target with a cascade of",
  ["Path of Illidan"] = "Path of Illidan",
  ["Goblin Gumbo"] = "Goblin Gumbo",
  ["Toasting Goblet"] = "Toasting Goblet",
  ["Summons a .* that will protect you for"] = "Summons a .* that will protect you for",
  ["Creates a .* that will fight for you"] = "Creates a .* that will fight for you",
  ["Explosive Sheep"] = "Explosive Sheep",
  ["Goblin Land Mine"] = "Goblin Land Mine",
  ["Eye of Arachnida"] = "Eye of Arachnida",
  ["Rope Pet Leash"] = "Rope Pet Leash",
  ["Fetch Ball"] = "Fetch Ball",
  ["Happy Pet Snack"] = "Happy Pet Snack",
  ["Paper Zeppelin Kit"] = "Paper Zeppelin Kit",
  ["Titanium Seal of Dalaran"] = "Titanium Seal of Dalaran",
  ["Frozen Orb"] = "Frozen Orb",
  ["Crystallized %a+"] = "Crystallized %a+",
  ["Eternal %a+"] = "Eternal %a+",
  ["Virtuoso Inking Set"] = "Virtuoso Inking Set",
  ["Ink"] = "Ink",
  [" Parchment"] = "Parchment",
  [" Pigment"] = "Pigment",
  ["Grindgear Toy Gorilla"] = "Grindgear Toy Gorilla",
  ["Trusty Copper Racer"] = "Trusty Copper Racer",
  ["Toy Train Set"] = "Toy Train Set",
  ["Engineer's Ink"] = "Engineer's Ink",
}, { __index = TBag.LOCALE }); 
