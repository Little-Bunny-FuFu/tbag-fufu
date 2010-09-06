-- $Id$

-- This file serves as the template for starting a new
-- translation.  Just change the locale value below and
-- then edit the strings on the right hand side of the
-- list.  Rename the file to localization.locale.lua
-- (e.g. localization.deDE.lua).  Then add the file
-- to the TBag.toc below localization.enUS.lua but
-- above defaults.lua.
--
-- Unlocalized strings are initially set to false as
-- you translate them change them to the string value
-- in the language you are translating to.
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

TBag.LOCALES.deDE = {}
TBag.LOCALES.current = TBag.LOCALES.deDE
local L = TBag.LOCALE

L[""] = false  -- Needed to preserve nil returns

-----------------------------------------------------------------------
-- SKILLS
-----------------------------------------------------------------------

-- Secondary skills
L["Cooking"] = GetSpellInfo(2550)
L["Fishing"] = GetSpellInfo(7620)
L["First Aid"] = GetSpellInfo(3273)
L["Archaeology"] = GetSpellInfo(78670)

-- Primary professions
L["Alchemy"] = GetSpellInfo(2259)
L["Blacksmithing"] = GetSpellInfo(2018)
L["Enchanting"] = GetSpellInfo(7411)
L["Engineering"] = GetSpellInfo(4036)
L["Jewelcrafting"] = GetSpellInfo(25229)
L["Leatherworking"] = GetSpellInfo(2108)
L["Tailoring"] = GetSpellInfo(3908)
L["Inscription"] = GetSpellInfo(45357)

-- Gathering
L["Skinning"] = GetSpellInfo(8613)
L["Mining"] = GetSpellInfo(2575)
L["Herbalism"] = GetSpellInfo(9134)

-- Other skills
L["Lockpicking"] = GetSpellInfo(1809)
L["Runeforging"] = GetSpellInfo(53428)

-----------------------------------------------------------------------
-- ITEM TYPES
-----------------------------------------------------------------------

L["Armor"] = ARMOR
L["Consumable"] = false
L["Container"] = false
L["Miscellaneous"] = MISCELLANEOUS
L["Projectile"] = false
L["Quest"] = false
L["Quiver"] = INVTYPE_QUIVER
L["Reagent"] = false
L["Recipe"] = false
L["Trade Goods"] = false
L["Weapon"] = false
L["Key"] = false
L["Elemental"] = false
L["Glyph"] = false

-- Sub types
L["Junk"] = false
L["Explosives"] = false
L["Devices"] = false
L["Parts"] = false
L["Ammo Pouch"] = false
L["Soul Bag"] = false
L["Engineering Bag"] = false
L["Gem Bag"] = false
L["Herb Bag"] = false
L["Mining Bag"] = false
L["Enchanting Bag"] = false
L["Leatherworking Bag"] = false

-- Slots
L["Finger"] = INVTYPE_FINGER
L["Trinket"] = INVTYPE_TRINKET
L["Relic"] = INVTYPE_RELIC

L["Soulbound"] = ITEM_SOULBOUND
L["Account Bound"] = ITEM_ACCOUNTBOUND

-----------------------------------------------------------------------
-- BAG DISPLAY NAMES
-----------------------------------------------------------------------

L["Keyring"] = KEYRING
L["Bank"] = false
L["Backpack"] = false
L["First Bag"] = false
L["Second Bag"] = false
L["Third Bag"] = false
L["Fourth Bag"] = false
L["First Bank Bag"] = false
L["Second Bank Bag"] = false
L["Third Bank Bag"] = false
L["Fourth Bank Bag"] = false
L["Fifth Bank Bag"] = false
L["Sixth Bank Bag"] = false
L["Seventh Bank Bag"] = false
L["Empty Slot"] = false

-----------------------------------------------------------------------
-- CATEGORIES
-----------------------------------------------------------------------

-- Templates that are used to create a number of categories.
L["EMPTY_%s_SLOTS"] = false
L["IN_%s_BAG"] = false
L["%s_CREATED"] = false
L["SOULBOUND_%s"] = false
L["ACCOUNTBOUND_%s"] = false
L["EQUIPPED_%s"] = false
L["%s_TOOL"] = false
L["%s_REAGENT"] = false

-- Broad categories for item types
L["PROJECTILE"] = false
L["SOULSHARD"] = false
L["CONSUMABLE"] = false
L["ACT_ON"] = false
L["ACT_OPEN"] = false
L["ACT_SELL"] = false
L["BAG"] = false
L["GRAY_ITEMS"] = false
L["QUEST"] = false
L["KEY_QUEST"] = false
L["KEY_OPEN"] = false
L["ENCHANTS"] = false
L["GLYPHS"] = false
L["BOOK"] = false
L["DESIGN"] = false
L["FORMULA"] = false
L["RECIPE"] = false
L["PATTERN"] = false
L["PLANS"] = false
L["SCHEMATIC"] = false
L["RECIPE_OTHER"] = false
L["PVP"] = false
L["REAGENT"] = false
L["TRADE_GOODS"] = false
L["CLOTH"] = false
L["MINIPET"] = false
L["COMBATPETS"] = false
L["COSTUMES"] = false
L["FIREWORKS"] = false
L["TOYS"] = false
L["MOUNT"] = false
L["FOOD"] = false
L["FOOD_BUFF"] = false
L["DRINK"] = false
L["COMBO"] = false
L["BUFF"] = false
L["DUMMY"] = false
L["BANDAGE"] = false
L["HEALTH_RESTORE"] = false
L["HEALTHSTONE"] = false
L["MANA_RESTORE"] = false
L["COMBO_RESTORE"] = false
L["RAGE_RESTORE"] = false
L["ENERGY_RESTORE"] = false
L["CURE"] = false
L["EXPLOSIVES"] = false
L["HEARTH"] = false
L["MISC"] = false
L["UNKNOWN"] = false

-- Faction and Collectable Categories.
L["THORIUM_BROTHER"] = false
L["TIMBERMAW"] = false
L["CENARION_EXPEDITION"] = false
L["SPOREGGAR"] = false
L["ARGENT_DAWN"] = false
L["ALDOR"] = false
L["SCRYER"] = false
L["SHA'TAR"] = false
L["LOWER_CITY"] = false
L["AHN_QIRAJ"] = false
L["CENARION_CIRCLE"] = false
L["NETHERWING"] = false
L["BLACKWING_LAIR"] = false
L["DARKMOON_FAIRE"] = false
L["OGRI'LA"] = false
L["MOLTEN_CORE"] = false
L["ZUL_GURUB"] = false
L["CONSORTIUM"] = false
L["HALAA"] = false

-- Tradeskill categories
L["TRADE1"] = false
L["TRADE2"] = false
L["ALCHEMY"] = false
L["BLACKSMITHING"] = false
L["ENCHANTING"] = false
L["ENGINEERING"] = false
L["JEWELCRAFTING"] = false
L["LEATHERWORKING"] = false
L["MINING"] = false
L["POISONS"] = false
L["TAILORING"] = false
L["INSCRIPTION"] = false
L["FIRST_AID"] = false
L["COOKING"] = false
L["FISHING"] = false
L["RUNEFORGING"] = false
L["TRADE_TOOL"] = false

-- Item slot categories
-- Note the categories with numbers in them must sort in the same order
-- per the standard lua sort.  Numbering like this is probably needed
-- for all languages to preserve the sort order.
L["01_HEAD"] = false
L["02_NECK"] = false
L["03_SHOULDER"] = false
L["04_BACK"] = false
L["05_CHEST"] = false
L["06_SHIRT"] = false
L["07_TABARD"] = false
L["08_WRIST"] = false
L["09_HANDS"] = false
L["10_WAIST"] = false
L["11_LEGS"] = false
L["12_FEET"] = false
L["13_OFFHAND"] = false
L["RELIC"] = false
L["RING"] = false
L["TRINKET"] = false
L["ARMOR"] = false
L["WEAPON"] = false
L["OTHER"] = false

-- Class Categories
L["DRUID"] = false
L["WARLOCK"] = false
L["ROGUE"] = false
L["MAGE"] = false
L["PALADIN"] = false
L["PRIEST"] = false
L["SHAMAN"] = false
L["WARRIOR"] = false
L["HUNTER"] = false
L["DEATHKNIGHT"] = false
L["CLASS_TOOL"] = false
L["CLASS_REAGENT"] = false

-- Short bag type names used for EMPTY_%s_SLOTS and IN_%s_BAG categories
-- 3-4 characters is about right for these.
L["QUIV"] = false
L["AMMO"] = false
L["SOUL"] = false
L["ENG"] = false
L["GEM"] = false
L["HERB"] = false
L["MINE"] = false
L["ENCH"] = false
L["LTHR"] = false
L["PET"] = false
L["INSC"] = false

-- Bag Position Names, also used for EMPTY_%s_SLOTS and IN_%s_BAG categories
L["KEYRING"] = false
L["BANK"] = false
L["BACKPACK"] = false
L["BAG1"] = false
L["BAG2"] = false
L["BAG3"] = false
L["BAG4"] = false
L["BBAG1"] = false
L["BBAG2"] = false
L["BBAG3"] = false
L["BBAG4"] = false
L["BBAG5"] = false
L["BBAG6"] = false
L["BBAG7"] = false

-- Keywords
L["SOULBOUND"] = false
L["ACCOUNTBOUND"] = false
L["EQUIPPED"] = false

-----------------------------------------------------------------------
-- CHAT STRINGS
-----------------------------------------------------------------------

L["%sSetting keybind to %q"] = false
L["Unassigned category %s has been assigned to slot 1"] =
      "Unassigned category %s has been assigned to slot 1"
L["Character data cached for:"] = false
L["Removed cache for %q"] = false
L["Couldn't find and remove cache for %q"] =
      "Couldn't find and remove cache for %q"
-----------------------------------------------------------------------
-- SEARCH OUTPUT STRINGS
-----------------------------------------------------------------------
L["Search results for %q:"] = false
L["No results|r for %q"] = false
L[" found:"] = false
L["bags"] = false
L["bank"] = false
L["container"] = false
L["body"] = false
L["mail"] = false
L["tokens"] = false
L[" in %s's %s"] = false -- Used when an item is found in a characters bag or bank
L[" on %s's %s"] = false -- Used when an item is found on a characters body
L[" as %s's %s"] = false -- Used when an item is used as a container for a character

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
L["(Use: Returns you to )([^%.]*)(%.)"] = false
L["%%1%s%%3"] = false

-- Generic name for the home location if we don't have it cached.
-- The tooltip should have something like this where in the text
-- where it describes how to change your bind point.  Brackets are
-- there to imply it's a placeholder.
L["<home location>"] = false

-----------------------------------------------------------------------
-- CHARGES
-----------------------------------------------------------------------
-- Pattern to get the charges from a tooltip
-- Probably only need to chage the Charges.
-- The ? after the s implies that the s may not be there
-- as would be the case in a single Charge.
L["(%d+) Charges?"] = false
-- Format string for adding the charges tooltip.
-- %d is the number of charges.  |4 specifies this
-- is a plural/singular pair.  Up until the : is the
-- singular form after is the plural until the ;.
L["%d |4Charge:Charges;"] = false

-----------------------------------------------------------------------
-- BINDING STRINGS
-----------------------------------------------------------------------
L["Toggle Bank Window"] = false
L["Toggle Inventory Window"] = false

-----------------------------------------------------------------------
-- COMMAND LINE STRINGS
-----------------------------------------------------------------------
-- commands
L["hide"] = false
L["show"] = false
L["update"] = false
L["debug"] = false
L["reset"] = false
L["resetpos"] = false
L["resetsorts"] = false
L["printchars"] = false
L["deletechar"] = false
L["config"] = false
L["tests"] = false
L["getcat"] = false

-- /tbnk help text
L["TBnk Commands:"] = false
L[" /tbnk show  -- open window"] = false
L[" /tbnk hide  -- hide window"] = false
L[" /tbnk update  -- refresh the window"] = false
L[" /tbnk config  -- configuration options"] = false
L[" /tbnk debug  -- turn debug info on/off"] = false
L[" /tbnk reset  -- sets everything back to default values"] = false
L[" /tbnk resetpos -- put the bank back to its default position"] = false
L[" /tbnk resetsorts -- clears the item search list"] = false
L[" /tbnk printchars -- prints a list of all the chars with cached info"] = false
L[" /tbnk deletechar CHAR SERVER -- clears all cached info for character "] = false

-- /tinv help text
L["TInv Commands:"] = false
L[" /tinv show  -- open window"] = false
L[" /tinv hide  -- hide window"] = false
L[" /tinv update  -- refresh the window"] = false
L[" /tinv config  -- configuration options"] = false
L[" /tinv debug  -- turn debug info on/off"] = false
L[" /tinv reset  -- sets everything back to default values"] = false
L[" /tinv resetpos -- put the inventory window back to its default position"] = false
L[" /tinv resetsorts -- clears the item search list"] = false
L[" /tinv printchars -- prints a list of all the chars with cached info"] = false
L[" /tinv deletechar CHAR SERVER -- clears all cached info for character "] = false

-----------------------------------------------------------------------
-- WINDOW STRINGS
-----------------------------------------------------------------------
L["TBag v%s"] = false

L["Normal"] = false
L["Stop highlighting new items."] = false
L["Highlight New"] = false
L["Highlight items marked as new."] = false
L["Clear Search"] = false
L["Stop highlighting search results."] = false

L["Toggle Edit Mode"] = false
L["Select this option to move classes of items into different 'bars' (the red numbers)."] = false

L["Reload and Sort"] = false
L["Reloads your items and sorts them."] = false

L["Toggle Bank"] = false
L["Displays bank contents in a view-only mode.  You may select another player's bank to view from the dropdown."] = false

L["Toggle Purchase Info"] = false
L["Displays the purchase button and cost to buy a new bank slot.  This is disabled in read-only views and edit mode."] = false

L["Unlock Window"] = false
L["Allow window to be moved by dragging it."] = false
L["Lock Window"] = false
L["Prevent window from being moved by dragging it."] = false

L["<++>"] = false
L["Increase Window Size"] = false
L["Increase the number of columns displayed"] = false

L[">--<"] = false
L["Decrease Window Size"] = false
L["Decrease the number of columns displayed"] = false

L["Reset"] = false
L["Close"] = false
L["Add New Cat"] = false
L["Assign Cats"] = false
L["No"] = false
L["Yes"] = false
L["Category"] = false
L["Keywords"] = false
L["Tooltip Search"] = false
L["Type"] = false
L["SubType"] = false

-- Menus and Tooltips
L["Main Background Color"] = false
L["Main Border Color"] = false
L["Set Bar Colors to Main Colors"] = false
L["Spotlight for %s"] = false
L["Current Category: %s"] = false
L["Assign item to category:"] = false
L["Use default category assignment"] = false
L["Debug Info: "] = false
L["Categories within bar %d"] = false
L["Move: |c%s%s|r"] = false
L["Sort Mode:"] = false
L["No sort"] = false
L["Sort by name"] = false
L["Sort last words first"] = false
L["Highlight new items:"] = false
L["Don't tag new items"] = false
L["Tag new items"] = false
L["Hide Bar:"] = false
L["Show items assigned to this bar"] = false
L["Hide items assigned to this bar"] = false
L["Color:"] = false
L["Background Color for Bar %d"] = false
L["Border Color for Bar %d"] = false
L["Select Character"] = false
L["Edit Mode"] = false
L["Lock window"] = false
L["Show Purchase Info"] = false
L["Close Inventory"] = false
L["Highlight New Items"] = false
L["Reset NEW tag"] = false
L["Advanced Configuration"] = false
L["Set Size"] = false
L["Set Colors"] = false
L["Hide"] = false
L["Hide Player Dropdown"] = false
L["Hide Search Box"] = false
L["Hide Re-sort Button"] = false
L["Hide Bank Button"] = false
L["Hide Show Purchase Button"] = false
L["Hide Edit Button"] = false
L["Hide Highlight Button"] = false
L["Hide Lock Button"] = false
L["Hide Close Button"] = false
L["Hide Total"] = false
L["Hide Bag Buttons"] = false
L["Hide Money"] = false
L["Hide Tokens"] = false
L["The Bank"] = false
L["|c%sLeft click to move category |r|c%s%s|r|c%s to bar |r|c%s%s|r"] = false
L["|c%sBar |r|c%s%s|r"] = false
L["|c%s%s|r"] = false
L["Right click for options"] = false
L["|c%sLeft click to select category to move:|r |c%s%s|r"] = false
L["Right click to assign this item to a different category"] = false
L["You are viewing the selected player's bank."] = false
L["You are viewing the selected player's inventory."] = false
L["Equip Container"] = false
L["Anchor"] = false
L["TOPLEFT"] = false
L["TOPRIGHT"] = false
L["BOTTOMLEFT"] = false
L["BOTTOMRIGHT"] = false
L["Show on TBag"] = false
L["Checking this option will allow you to track this currency type in TBag for this character.\n\nYou can also Shift-click a currency to add or remove it from being tracked in TBag."] = false

-- Option Window Strings
L["Main Sizing Preferences"] = false
L["Number of Item Columns:"] = false
L["Number of Horizontal Bars:"] = false
L["Window Scale:"] = false
L["Item Button Size:"] = false
L["Item Button Padding:"] = false
L["Spacing - X Button:"] = false
L["Spacing - Y Button:"] = false
L["Spacing - X Pool:"] = false
L["Spacing - Y Pool:"] = false
L["Count Font Size:"] = false
L["Count Placement - X:"] = false
L["Count Placement - Y:"] = false
L["New Tag Font Size:"] = false
L["Bag Contents Show"] = false
L["Show %s:"] = false
L["General Display Preferences"] = false
L["Show Size on Bag Count:"] = false
L["Show Bag Icons on Empty Slots:"] = false
L["Spotlight Open or Selected Bags:"] = false
L["Spotlight Mouseover:"] = false
L["Show Item Rarity Color:"] = false
L["Auto Stack:"] = false
L["Stack on Re-sort:"] = false
L["Profession Bags precede Sorting:"] = false
L["Trade Creation precedes Sorting (Reopen Window):"] = false
L["New Tag Options"] = false
L["New Tag Text:"] = false
L["Increased Tag Text:"] = false
L["Decreased Tag Text:"] = false
L["New Tag Timeout (minutes):"] = false
L["Recent Tag Timeout (minutes):"] = false
L["Alt Key Auto-Pickup:"] = false
L["Alt Key Auto-Panel:"] = false
L["Show Keyring Empty Slots (Enable Show above):"] = false
L["Show Soul Shard Count On Soul Bags:"] = false

-----------------------------------------------------------------------
-- Unit Tests
-----------------------------------------------------------------------
L["TEST RUN STARTING"] = false
L[" Retrieving item information"] = false
L["SUCCESS: %s"] = false
L["FAIL: %s (%s) expected %q but got %q"] = false
L["ALL TESTS SUCCESSFUL"] = false

-----------------------------------------------------------------------
-- Default Search List Strings
-----------------------------------------------------------------------
L["This Item Begins a Quest"] = ITEM_STARTS_QUEST
L["<Right Click to Open>"] = ITEM_OPENABLE
L[" Lockbox"] = false
L["Mark of Honor Hold"] = false
L["Mark of Thrallmar"] = false
L["Halaa Battle Token"] = false
L["Spirit Shard"] = false
L["Use: Permanently"] = false
L["Hearthstone%s"] = false
L["Right Click to summon and dismiss"] = false
L["Summons or dismisses a Spirit of"] = false
L["Use: Teaches you how to summon a?n?d? ?d?i?s?m?i?s?s? ?this companion."] = false
L["Requires Riding %("] = false
L["%a+ Scarab"] = false
L["%a+ Idol"] = false
L["Qiraji %a+ %a+"] = false
L["Bone Fragments"] = false
L["Core of Elements"] = false
L["Crypt Fiend Parts"] = false
L["Dark Iron Scraps"] = false
L["Savage Frond"] = false
L["Insignia of the Crusade"] = false
L["Insignia of the Dawn"] = false
L["Argent Dawn Valor Token"] = false
L["Mantle of the Dawn"] = false
L["Vitreous Focuser"] = false
L["Osseous Agitator"] = false
L["Somatic Intensifier"] = false
L["Ectoplasmic Resonator"] = false
L["Arcane Quickener"] = false
L[" Scourgestone"] = false
L["Cenarion %a+ Badge"] = false
L["Twilight Text"] = false
L["Twilight Cultist"] = false
L["Abyssal Crest"] = false
L["Abyssal Signet"] = false
L["Abyssal Scepter"] = false
L["Darkmoon Faire Prize Ticket"] = false
L["Soft Bushy Tail"] = false
L["Vibrant Plume"] = false
L["Small Furry Paw"] = false
L["Evil Bat Eye"] = false
L["Torn Bear Pelt"] = false
L["Glowing Scorpid Blood"] = false
L["Property of the Darkmoon Faire."] = false
L["Combine the %a+ through %a+ of %a+ to complete the set."] = false
L["Incendosaur Scale"] = false
L["Dark Iron Residue"] = false
L["Deadwood Headdress Feather"] = false
L["Winterfall Spirit Beads"] = false
L["Zandalar Honor Token"] = false
L["%a+ Coin"] = false
L["%a+ Bijou"] = false
L["Primal Hakkari"] = false
L["Apexis Crystal"] = false
L["to create a dragonscale cloak"] = false
L["Darkrune"] = false
L["Netherwing Egg"] = false
L["Nethercite Ore"] = false
L["Netherdust Pollen"] = false
L["Netherwing Crystal"] = false
L["Nethermine Cargo"] = false
L["Unidentified Plant Parts"] = false
L["Coilfang Armaments"] = false
L["Mature Spore Sac"] = false
L["Bog Lord Tendril"] = false
L["Glowcap"] = false
L["Fertile Spores"] = false
L["Sanguine Hibiscus"] = false
L["Obsidian Warbeads"] = false
L["Oshu'gun Crystal Fragment"] = false
L["Pair of Ivory Tusks"] = false
L["Zaxxis Insignia"] = false
L["Ethereum Prisoner I%.D%. Tag"] = false
L["Ethereum Prison Key"] = false
L["Halaa Research Token"] = false
L["Oshu'gun Crystal Powder Sample"] = false
L["Dampscale Basilisk Eye"] = false
L["Firewing Signet"] = false
L["Sunfury Signet"] = false
L["Arcane Tome"] = false
L["Arcane Rune"] = false
L["Dreadfang Venom Sac"] = false
L["Mark of Kil'jaeden"] = false
L["Mark of Sargeras"] = false
L["Fel Armament"] = false
L["Holy Dust"] = false
L["Mark of the Illidari"] = false
L["Badge of Justice"] = false
L["Arakkoa Feather"] = false
L["Quest Item"] = ITEM_BIND_QUEST
L["Morbent"] = false
L["Codex: "] = false
L["Manual: "] = false
L["Expert "] = false
L["Tome of "] = false
L["Design: "] = false
L["Formula: "] = false
L["Recipe: "] = false
L["Pattern: "] = false
L["Plans: "] = false
L["Schematic: "] = false
L["[Ss]kinning [Kk]nife"] = false
L["[Mm]ining [Pp]ick"] = false
L["[Bb]lacksmith [Hh]ammer"] = false
L["Runed %a+ Rod"] = false
L["Philosopher's Stone"] = false
L["Salt Shaker"] = false
L["Arclight Spanner"] = false
L["Gyromatic Micro%-Adjust[oe]r"] = false
L["Zulian Slicer"] = false
L["Finkle's Skinner"] = false
L["Blood Scythe"] = false
L["Herbalist's Gloves"] = false
L["Dwarven Fishing Pole"] = false
L["Goblin Fishing Pole"] = false
L["Everlasting Underspore Frond"] = false
L["\nHead"] = false
L["\nNeck"] = false
L["\nShoulder"] = false
L["\nBack"] = false
L["\nChest"] = false
L["\nShirt"] = false
L["\nTabard"] = false
L["\nWrist"] = false
L["\nHands"] = false
L["\nWaist"] = false
L["\nLegs"] = false
L["\nFeet"] = false
L["\nHeld In Off%-hand"] = false
L[" Bandage"] = false
L["Instantly restores %d+ life"] = false
L[" well fed "] = false
L["Restores %d+ health.* increases your "] = false
L["If you spend at least %d+ seconds eating you will"] = false
L["Must remain seated while drinking%."] = false
L["Restores %d+ mana over %d+ sec"] = false
L["Restores %d+ health and %d+ mana over %d+ sec"] = false
L["Restores .* health and .*mana .* %d+ sec"] = false
L["Must remain seated while eating%."] = false
L["Restores %d+ health over %d+ sec"] = false
L["Thistle Tea"] = false
L["[Rr]estores %d+ energy"] = false
L["Rage Potion"] = false
L["[Rr]estores %d+ rage"] = false
L["Rejuvenation Potion"] = false
L["Dreamless Sleep"] = false
L["[Rr]estores %d+ to %d+ mana and health"] = false
L["Mana Potion"] = false
L["[Rr]estores %d+ to %d+ mana"] = false
L["Healing Potion"] = false
L["[Rr]estores %d+ to %d+ health"] = false
L["Place a %a+ stone statue"] = false
L[" [Cc]ure.* poison"] = false
L[" [Cc]ure.* disease"] = false
L[" [Cc]ure.* curse"] = false
L[" [Cc]ure.* magic"] = false
L[" [Rr]emoves %d+ .*effect"] = false
L[" Dynamite"] = false
L[" Bomb"] = false
L[" Mortar"] = false
L["Scroll"] = false
L["Use: Increases "] = false
L["Use: Absorbs "] = false
L["Use: Regenerate "] = false
L["Use: While applied to target weapon"] = false
L[" Sharpening Stone"] = false
L[" Weightstone"] = false
L["Mistletoe"] = false
L["Flame Cap"] = false
L["[AG][li][lv][oe]w?s the [Ii]mbiber "] = false
L[" Key"] = false
L["Light Feather"] = false
L["Infernal Stone"] = false
L["Demonic Figurine"] = false
L[" Seed"] = false
L["Wild "] = false
L["Arcane Powder"] = false
L["Rune of "] = false
L["Symbol of"] = false
L[" Candle"] = false
L["Ankh"] = false
L["Fish Oil"] = false
L["Shiny Fish Scales"] = false
L["Thieves' Tools"] = false
L[" Totem"] = false
L["Soul Shard"] = false
L["Corpse Dust"] = false
L["Target Dummy"] = false
L["Elemental %a+"] = false
L["Essence of %a+"] = false
L["Globe of Water"] = false
L["Breath of Wind"] = false
L["Heart of Fire"] = false
L["Core of Earth"] = false
L["Mote of %a+"] = false
L["Primal Nether"] = false
L["Primal %a+"] = false
L["Void Crystal"] = false
L["Nether Vortex"] = false
L["Sunmote"] = false
L["Heart of Darkness"] = false
L[" Vial"] = false
L["[cC]loth"] = false
L["Coats a weapon with poison that lasts for"] = false
L["Raw "] = false
L["[Ff]ish"] = false
L[" Meat"] = false
L["%a+ Dust"] = false
L["Lesser %a+ Essence"] = false
L["Greater %a+ Essence"] = false
L["Small %a+ Shard"] = false
L["Large %a+ Shard"] = false
L["Papa Hummel's Old%-Fashioned Pet Biscuit"] = false
L["Silver Shafted Arrow"] = false
L["Crashin' Thrashin'"] = false
L["Tonk Controller"] = false
L["Mechanical Yeti"] = false
L["Orb of the Sin'dorei"] = false
L["Orb of the Blackwhelp"] = false
L["Winter Veil Disguise Kit"] = false
L["Hallowed Wand %- "] = false
L["Murloc Costume"] = false
L["Weighted Jack%-o'%-Lantern"] = false
L["Gordok Ogre Suit"] = false
L["Transforms your mount into something more festive"] = false
L["Your mount will be more festive"] = false
L["Shoots a.*firework"] = false
L["Place on the ground to launch .* rockets"] = false
L["Throw into a .* launcher"] = false
L["Brazier of Dancing Flames"] = false
L["Direbrew's Remote"] = false
L["Goblin Weather Machine %- Prototype 01%-B"] = false
L["Use: Right Click to set up a .* picnic."] = false
L["D\.I\.S\.C\.O\."] = false
L["Imp in a Ball"] = false
L["Snowball"] = false
L["Paper Flying Machine Kit"] = false
L["If they have free room in their pack they will catch it"] = false
L["Fishing Chair"] = false
L["Elune Stone"] = false
L["Shower a nearby target with a cascade of"] = false
L["Path of Illidan"] = false
L["Goblin Gumbo"] = false
L["Toasting Goblet"] = false
L["Summons a .* that will protect you for"] = false
L["Creates a .* that will fight for you"] = false
L["Explosive Sheep"] = false
L["Goblin Land Mine"] = false
L["Eye of Arachnida"] = false
L["Pet Leash"] = false
L["Fetch Ball"] = false
L["Happy Pet Snack"] = false
L["Paper Zeppelin Kit"] = false
L["Titanium Seal of Dalaran"] = false
L["Frozen Orb"] = false
L["Crystallized %a+"] = false
L["Eternal %a+"] = false
L["Virtuoso Inking Set"] = false
L["Ink"] = false
L[" Parchment"] = false
L[" Pigment"] = false
L["Grindgear Toy Gorilla"] = false
L["Copper Racer"] = false
L["Toy Train Set"] = false
L["Engineer's Ink"] = false
L["Rickety Magic Broom"] = false
L["Iron Boot Flask"] = false
L["Zapthrottle Mote Extractor"] = false
L["Wand of Holiday Cheer"] = false
L["Rolls a pair of dice"] = false
L["Blessed Medallion of Karabor"] = false
L["Frenzyheart Brew"] = false
L["Tiny %a+ Ragdoll"] = false
L["Festival Firecracker"] = false
L["Elder's Moonstone"] = false
L["Wind%-Up Train Wrecker"] = false
L["Sandbox Tiger"] = false
L["Foam Sword Rack"] = false
L["Unusual Compass"] = false
L["Blossoming Branch"] = false
L["Path of Cenarius"] = false
L["Ogre Pinata"] = false
L["Ultrasafe Transporter:"] = false
L["Dimensional Ripper - "] = false
L["Wormhole Generator:"] = false
L["Goblin Beam Welder"] = false
L["Runed Orb"] = false
L["Crusader Orb"] = false
L["Gnomish Army Knife"] = false
L["Primordial Saronite"] = false
L["Brazie's Gnomish Pleasure Device"] = false
L["Summons and dismisses a rideable"] = false
L["Nurtured Penguin Egg"] = false
L["Truesilver Shafted Arrow"] = false
L["Kirin Tor Familiar"] = false
L["Unhatched Mr. Chilly"] = false
L["Frosty's Collar"] = false
L["Perpetual Purple Firework"] = false
L["Carved Ogre Idol"] = false
L["The Flag of Ownership"] = false
