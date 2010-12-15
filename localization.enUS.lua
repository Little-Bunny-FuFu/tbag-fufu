-- $Id$

-- localization files should be edited with a utf-8
-- compatable editor and done so with utf-8 encoding.

-- See localization.template.lua to start a new translation.

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

TBag.LOCALES = {}
TBag.LOCALES.enUS = {}
TBag.LOCALES.current = TBag.LOCALES.enUS

TBag.LOCALE = setmetatable({},
  {__index = function(self,key)
    local value = rawget(TBag.LOCALES.current,key)
    if value then
      return value
    end
    rawset(TBag.LOCALES.current, key, key)
    -- Only output the warning on unpackaged versions.
    --@alpha@
    DEFAULT_CHAT_FRAME:AddMessage(string.format("TBag: Please localize: %q", tostring(key)))
    --@end-alpha@
    return key
   end,
   __newindex = function(self, key, value)
     if not rawget(TBag.LOCALES.current, key) then
       -- Replace true with the key as the value
       rawset(TBag.LOCALES.current, key, value == true and key or value)
     else
      DEFAULT_CHAT_FRAME:AddMessage(string.format("TBag: Duplicate translation for: %q",tostring(key)))
     end
   end })

local L = TBag.LOCALE

L[""] = true -- Needed to preserve nil returns

-----------------------------------------------------------------------
-- SKILLS
-----------------------------------------------------------------------

-- Secondary skills
L["Cooking"] = true
L["Fishing"] = true
L["First Aid"] = true
L["Archaeology"] = true

-- Primary professions
L["Alchemy"] = true
L["Blacksmithing"] = true
L["Enchanting"] = true
L["Engineering"] = true
L["Jewelcrafting"] = true
L["Leatherworking"] = true
L["Tailoring"] = true
L["Inscription"] = true

-- Gathering
L["Skinning"] = true
L["Mining"] = true
L["Herbalism"] = true

-- Other skills
L["Lockpicking"] = true
L["Runeforging"] = true

-----------------------------------------------------------------------
-- ITEM TYPES
-----------------------------------------------------------------------

L["Armor"] = true
L["Consumable"] = true
L["Container"] = true
L["Miscellaneous"] = true
L["Projectile"] = true
L["Quest"] = true
L["Quiver"] = true
L["Reagent"] = true
L["Recipe"] = true
L["Trade Goods"] = true
L["Weapon"] = true
L["Key"] = true
L["Elemental"] = true
L["Glyph"] = true

-- Sub types
L["Junk"] = true
L["Explosives"] = true
L["Devices"] = true
L["Parts"] = true
L["Ammo Pouch"] = true
L["Soul Bag"] = true
L["Engineering Bag"] = true
L["Gem Bag"] = true
L["Herb Bag"] = true
L["Mining Bag"] = true
L["Enchanting Bag"] = true
L["Leatherworking Bag"] = true

-- Slots
L["Finger"] = true
L["Trinket"] = true
L["Relic"] = true

L["Soulbound"] = true
L["Account Bound"] = true

-----------------------------------------------------------------------
-- BAG DISPLAY NAMES
-----------------------------------------------------------------------

L["Keyring"] = true
L["Bank"] = true
L["Backpack"] = true
L["First Bag"] = true
L["Second Bag"] = true
L["Third Bag"] = true
L["Fourth Bag"] = true
L["First Bank Bag"] = true
L["Second Bank Bag"] = true
L["Third Bank Bag"] = true
L["Fourth Bank Bag"] = true
L["Fifth Bank Bag"] = true
L["Sixth Bank Bag"] = true
L["Seventh Bank Bag"] = true
L["Empty Slot"] = true

-----------------------------------------------------------------------
-- CATEGORIES
-----------------------------------------------------------------------

-- Templates that are used to create a number of categories.
L["EMPTY_%s_SLOTS"] = true
L["IN_%s_BAG"] = true
L["%s_CREATED"] = true
L["SOULBOUND_%s"] = true
L["ACCOUNTBOUND_%s"] = true
L["EQUIPPED_%s"] = true
L["%s_TOOL"] = true
L["%s_REAGENT"] = true

-- Broad categories for item types
L["PROJECTILE"] = true
L["SOULSHARD"] = true
L["CONSUMABLE"] = true
L["ACT_ON"] = true
L["ACT_OPEN"] = true
L["ACT_SELL"] = true
L["BAG"] = true
L["GRAY_ITEMS"] = true
L["QUEST"] = true
L["KEY_QUEST"] = true
L["KEY_OPEN"] = true
L["ENCHANTS"] = true
L["GLYPHS"] = true
L["BOOK"] = true
L["DESIGN"] = true
L["FORMULA"] = true
L["RECIPE"] = true
L["PATTERN"] = true
L["PLANS"] = true
L["SCHEMATIC"] = true
L["RECIPE_OTHER"] = true
L["PVP"] = true
L["REAGENT"] = true
L["TRADE_GOODS"] = true
L["CLOTH"] = true
L["MINIPET"] = true
L["COMBATPETS"] = true
L["COSTUMES"] = true
L["FIREWORKS"] = true
L["TOYS"] = true
L["MOUNT"] = true
L["FOOD"] = true
L["FOOD_BUFF"] = true
L["DRINK"] = true
L["COMBO"] = true
L["BUFF"] = true
L["DUMMY"] = true
L["BANDAGE"] = true
L["HEALTH_RESTORE"] = true
L["HEALTHSTONE"] = true
L["MANA_RESTORE"] = true
L["COMBO_RESTORE"] = true
L["RAGE_RESTORE"] = true
L["ENERGY_RESTORE"] = true
L["CURE"] = true
L["EXPLOSIVES"] = true
L["HEARTH"] = true
L["MISC"] = true
L["UNKNOWN"] = true

-- Faction and Collectable Categories.
L["THORIUM_BROTHER"] = true
L["TIMBERMAW"] = true
L["CENARION_EXPEDITION"] = true
L["SPOREGGAR"] = true
L["ARGENT_DAWN"] = true
L["ALDOR"] = true
L["SCRYER"] = true
L["SHA'TAR"] = true
L["LOWER_CITY"] = true
L["AHN_QIRAJ"] = true
L["CENARION_CIRCLE"] = true
L["NETHERWING"] = true
L["BLACKWING_LAIR"] = true
L["DARKMOON_FAIRE"] = true
L["OGRI'LA"] = true
L["MOLTEN_CORE"] = true
L["ZUL_GURUB"] = true
L["CONSORTIUM"] = true
L["HALAA"] = true

-- Tradeskill categories
L["TRADE1"] = true
L["TRADE2"] = true
L["ALCHEMY"] = true
L["BLACKSMITHING"] = true
L["ENCHANTING"] = true
L["ENGINEERING"] = true
L["JEWELCRAFTING"] = true
L["LEATHERWORKING"] = true
L["MINING"] = true
L["POISONS"] = true
L["TAILORING"] = true
L["INSCRIPTION"] = true
L["FIRST_AID"] = true
L["COOKING"] = true
L["FISHING"] = true
L["RUNEFORGING"] = true
L["TRADE_TOOL"] = true

-- Item slot categories
-- Note the categories with numbers in them must sort in the same order
-- per the standard lua sort.  Numbering like this is probably needed
-- for all languages to preserve the sort order.
L["01_HEAD"] = true
L["02_NECK"] = true
L["03_SHOULDER"] = true
L["04_BACK"] = true
L["05_CHEST"] = true
L["06_SHIRT"] = true
L["07_TABARD"] = true
L["08_WRIST"] = true
L["09_HANDS"] = true
L["10_WAIST"] = true
L["11_LEGS"] = true
L["12_FEET"] = true
L["13_OFFHAND"] = true
L["RELIC"] = true
L["RING"] = true
L["TRINKET"] = true
L["ARMOR"] = true
L["WEAPON"] = true
L["OTHER"] = true

-- Class Categories
L["DRUID"] = true
L["WARLOCK"] = true
L["ROGUE"] = true
L["MAGE"] = true
L["PALADIN"] = true
L["PRIEST"] = true
L["SHAMAN"] = true
L["WARRIOR"] = true
L["HUNTER"] = true
L["DEATHKNIGHT"] = true
L["CLASS_TOOL"] = true
L["CLASS_REAGENT"] = true

-- Short bag type names used for EMPTY_%s_SLOTS and IN_%s_BAG categories
-- 3-4 characters is about right for these.
L["QUIV"] = true
L["AMMO"] = true
L["SOUL"] = true
L["ENG"] = true
L["GEM"] = true
L["HERB"] = true
L["MINE"] = true
L["ENCH"] = true
L["LTHR"] = true
L["PET"] = true
L["INSC"] = true
L["TACKLE"] = true

-- Bag Position Names, also used for EMPTY_%s_SLOTS and IN_%s_BAG categories
L["KEYRING"] = true
L["BANK"] = true
L["BACKPACK"] = true
L["BAG1"] = true
L["BAG2"] = true
L["BAG3"] = true
L["BAG4"] = true
L["BBAG1"] = true
L["BBAG2"] = true
L["BBAG3"] = true
L["BBAG4"] = true
L["BBAG5"] = true
L["BBAG6"] = true
L["BBAG7"] = true

-- Keywords
L["SOULBOUND"] = true
L["ACCOUNTBOUND"] = true
L["EQUIPPED"] = true

-----------------------------------------------------------------------
-- CHAT STRINGS
-----------------------------------------------------------------------

L["%sSetting keybind to %q"] = true
L["Unassigned category %s has been assigned to slot 1"] = true
L["Character data cached for:"] = true
L["Removed cache for %q"] = true
L["Couldn't find and remove cache for %q"] = true
-----------------------------------------------------------------------
-- SEARCH OUTPUT STRINGS
-----------------------------------------------------------------------
L["Search results for %q:"] = true
L["No results|r for %q"] = true
L[" found:"] = true
L["bags"] = true
L["bank"] = true
L["container"] = true
L["body"] = true
L["mail"] = true
L["tokens"] = true
L[" in %s's %s"] = true -- Used when an item is found in a characters bag or bank
L[" on %s's %s"] = true -- Used when an item is found on a characters body
L[" as %s's %s"] = true -- Used when an item is used as a container for a character

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
L["(Use: Returns you to )([^%.]*)(%.)"] = true
L["%%1%s%%3"] = true

-- Generic name for the home location if we don't have it cached.
-- The tooltip should have something like this where in the text
-- where it describes how to change your bind point.  Brackets are
-- there to imply it's a placeholder.
L["<home location>"] = true

-----------------------------------------------------------------------
-- CHARGES
-----------------------------------------------------------------------
-- Pattern to get the charges from a tooltip
-- Probably only need to chage the Charges.
-- The ? after the s implies that the s may not be there
-- as would be the case in a single Charge.
L["(%d+) Charges?"] = true
-- Format string for adding the charges tooltip.
-- %d is the number of charges.  |4 specifies this
-- is a plural/singular pair.  Up until the : is the
-- singular form after is the plural until the ;.
L["%d |4Charge:Charges;"] = true

-----------------------------------------------------------------------
-- BINDING STRINGS
-----------------------------------------------------------------------
L["Toggle Bank Window"] = true
L["Toggle Inventory Window"] = true

-----------------------------------------------------------------------
-- COMMAND LINE STRINGS
-----------------------------------------------------------------------
-- commands
L["hide"] = true
L["show"] = true
L["update"] = true
L["debug"] = true
L["reset"] = true
L["resetpos"] = true
L["resetsorts"] = true
L["printchars"] = true
L["deletechar"] = true
L["config"] = true
L["tests"] = true
L["getcat"] = true

-- /tbnk help text
L["TBnk Commands:"] = true
L[" /tbnk show  -- open window"] = true
L[" /tbnk hide  -- hide window"] = true
L[" /tbnk update  -- refresh the window"] = true
L[" /tbnk config  -- configuration options"] = true
L[" /tbnk debug  -- turn debug info on/off"] = true
L[" /tbnk reset  -- sets everything back to default values"] = true
L[" /tbnk resetpos -- put the bank back to its default position"] = true
L[" /tbnk resetsorts -- clears the item search list"] = true
L[" /tbnk printchars -- prints a list of all the chars with cached info"] = true
L[" /tbnk deletechar CHAR SERVER -- clears all cached info for character "] = true

-- /tinv help text
L["TInv Commands:"] = true
L[" /tinv show  -- open window"] = true
L[" /tinv hide  -- hide window"] = true
L[" /tinv update  -- refresh the window"] = true
L[" /tinv config  -- configuration options"] = true
L[" /tinv debug  -- turn debug info on/off"] = true
L[" /tinv reset  -- sets everything back to default values"] = true
L[" /tinv resetpos -- put the inventory window back to its default position"] = true
L[" /tinv resetsorts -- clears the item search list"] = true
L[" /tinv printchars -- prints a list of all the chars with cached info"] = true
L[" /tinv deletechar CHAR SERVER -- clears all cached info for character "] = true

-----------------------------------------------------------------------
-- WINDOW STRINGS
-----------------------------------------------------------------------
L["TBag v%s"] = true

L["Normal"] = true
L["Stop highlighting new items."] = true
L["Highlight New"] = true
L["Highlight items marked as new."] = true
L["Clear Search"] = true
L["Stop highlighting search results."] = true

L["Toggle Edit Mode"] = true
L["Select this option to move classes of items into different 'bars' (the red numbers)."] = true

L["Reload and Sort"] = true
L["Reloads your items and sorts them."] = true

L["Toggle Bank"] = true
L["Displays bank contents in a view-only mode.  You may select another player's bank to view from the dropdown."] = true

L["Toggle Purchase Info"] = true
L["Displays the purchase button and cost to buy a new bank slot.  This is disabled in read-only views and edit mode."] = true

L["Unlock Window"] = true
L["Allow window to be moved by dragging it."] = true
L["Lock Window"] = true
L["Prevent window from being moved by dragging it."] = true

L["<++>"] = true
L["Increase Window Size"] = true
L["Increase the number of columns displayed"] = true

L[">--<"] = true
L["Decrease Window Size"] = true
L["Decrease the number of columns displayed"] = true

L["Reset"] = true
L["Close"] = true
L["Add New Cat"] = true
L["Assign Cats"] = true
L["No"] = true
L["Yes"] = true
L["Category"] = true
L["Keywords"] = true
L["Tooltip Search"] = true
L["Type"] = true
L["SubType"] = true

-- Menus and Tooltips
L["Main Background Color"] = true
L["Main Border Color"] = true
L["Set Bar Colors to Main Colors"] = true
L["Spotlight for %s"] = true
L["Current Category: %s"] = true
L["Assign item to category:"] = true
L["Use default category assignment"] = true
L["Debug Info: "] = true
L["Categories within bar %d"] = true
L["Move: |c%s%s|r"] = true
L["Sort Mode:"] = true
L["No sort"] = true
L["Sort by name"] = true
L["Sort last words first"] = true
L["Highlight new items:"] = true
L["Don't tag new items"] = true
L["Tag new items"] = true
L["Hide Bar:"] = true
L["Show items assigned to this bar"] = true
L["Hide items assigned to this bar"] = true
L["Color:"] = true
L["Background Color for Bar %d"] = true
L["Border Color for Bar %d"] = true
L["Select Character"] = true
L["Edit Mode"] = true
L["Lock window"] = true
L["Show Purchase Info"] = true
L["Close Inventory"] = true
L["Highlight New Items"] = true
L["Reset NEW tag"] = true
L["Advanced Configuration"] = true
L["Set Size"] = true
L["Set Colors"] = true
L["Hide"] = true
L["Hide Player Dropdown"] = true
L["Hide Search Box"] = true
L["Hide Re-sort Button"] = true
L["Hide Bank Button"] = true
L["Hide Show Purchase Button"] = true
L["Hide Edit Button"] = true
L["Hide Highlight Button"] = true
L["Hide Lock Button"] = true
L["Hide Close Button"] = true
L["Hide Total"] = true
L["Hide Bag Buttons"] = true
L["Hide Money"] = true
L["Hide Tokens"] = true
L["The Bank"] = true
L["|c%sLeft click to move category |r|c%s%s|r|c%s to bar |r|c%s%s|r"] = true
L["|c%sBar |r|c%s%s|r"] = true
L["|c%s%s|r"] = true
L["Right click for options"] = true
L["|c%sLeft click to select category to move:|r |c%s%s|r"] = true
L["Right click to assign this item to a different category"] = true
L["You are viewing the selected player's bank."] = true
L["You are viewing the selected player's inventory."] = true
L["Equip Container"] = true
L["Anchor"] = true
L["TOPLEFT"] = true
L["TOPRIGHT"] = true
L["BOTTOMLEFT"] = true
L["BOTTOMRIGHT"] = true
L["Show on TBag"] = true
L["Checking this option will allow you to track this currency type in TBag for this character.\n\nYou can also Shift-click a currency to add or remove it from being tracked in TBag."] = true

-- Option Window Strings
L["Main Sizing Preferences"] = true
L["Number of Item Columns:"] = true
L["Number of Horizontal Bars:"] = true
L["Window Scale:"] = true
L["Item Button Size:"] = true
L["Item Button Padding:"] = true
L["Spacing - X Button:"] = true
L["Spacing - Y Button:"] = true
L["Spacing - X Pool:"] = true
L["Spacing - Y Pool:"] = true
L["Count Font Size:"] = true
L["Count Placement - X:"] = true
L["Count Placement - Y:"] = true
L["New Tag Font Size:"] = true
L["Bag Contents Show"] = true
L["Show %s:"] = true
L["General Display Preferences"] = true
L["Show Size on Bag Count:"] = true
L["Show Bag Icons on Empty Slots:"] = true
L["Spotlight Open or Selected Bags:"] = true
L["Spotlight Mouseover:"] = true
L["Show Item Rarity Color:"] = true
L["Auto Stack:"] = true
L["Stack on Re-sort:"] = true
L["Profession Bags precede Sorting:"] = true
L["Trade Creation precedes Sorting (Reopen Window):"] = true
L["New Tag Options"] = true
L["New Tag Text:"] = true
L["Increased Tag Text:"] = true
L["Decreased Tag Text:"] = true
L["New Tag Timeout (minutes):"] = true
L["Recent Tag Timeout (minutes):"] = true
L["Alt Key Auto-Pickup:"] = true
L["Alt Key Auto-Panel:"] = true
L["Show Keyring Empty Slots (Enable Show above):"] = true
L["Show Soul Shard Count On Soul Bags:"] = true

-----------------------------------------------------------------------
-- Unit Tests
-----------------------------------------------------------------------
L["TEST RUN STARTING"] = true
L[" Retrieving item information"] = true
L["SUCCESS: %s"] = true
L["FAIL: %s (%s) expected %q but got %q"] = true
L["ALL TESTS SUCCESSFUL"] = true

-----------------------------------------------------------------------
-- Default Search List Strings
-----------------------------------------------------------------------
L["This Item Begins a Quest"] = true
L["<Right Click to Open>"] = true
L[" Lockbox"] = true
L["Mark of Honor Hold"] = true
L["Mark of Thrallmar"] = true
L["Halaa Battle Token"] = true
L["Spirit Shard"] = true
L["Use: Permanently"] = true
L["Hearthstone%s"] = true
L["Right Click to summon and dismiss"] = true
L["Summons or dismisses a Spirit of"] = true
L["Use: Teaches you how to summon a?n?d? ?d?i?s?m?i?s?s? ?this companion."] = true
L["Requires Riding %("] = true
L["%a+ Scarab"] = true
L["%a+ Idol"] = true
L["Qiraji %a+ %a+"] = true
L["Bone Fragments"] = true
L["Core of Elements"] = true
L["Crypt Fiend Parts"] = true
L["Dark Iron Scraps"] = true
L["Savage Frond"] = true
L["Insignia of the Crusade"] = true
L["Insignia of the Dawn"] = true
L["Argent Dawn Valor Token"] = true
L["Mantle of the Dawn"] = true
L["Vitreous Focuser"] = true
L["Osseous Agitator"] = true
L["Somatic Intensifier"] = true
L["Ectoplasmic Resonator"] = true
L["Arcane Quickener"] = true
L[" Scourgestone"] = true
L["Cenarion %a+ Badge"] = true
L["Twilight Text"] = true
L["Twilight Cultist"] = true
L["Abyssal Crest"] = true
L["Abyssal Signet"] = true
L["Abyssal Scepter"] = true
L["Darkmoon Faire Prize Ticket"] = true
L["Soft Bushy Tail"] = true
L["Vibrant Plume"] = true
L["Small Furry Paw"] = true
L["Evil Bat Eye"] = true
L["Torn Bear Pelt"] = true
L["Glowing Scorpid Blood"] = true
L["Property of the Darkmoon Faire."] = true
L["Combine the %a+ through %a+ of %a+ to complete the set."] = true
L["Incendosaur Scale"] = true
L["Dark Iron Residue"] = true
L["Deadwood Headdress Feather"] = true
L["Winterfall Spirit Beads"] = true
L["Zandalar Honor Token"] = true
L["%a+ Coin"] = true
L["%a+ Bijou"] = true
L["Primal Hakkari"] = true
L["Apexis Crystal"] = true
L["to create a dragonscale cloak"] = true
L["Darkrune"] = true
L["Netherwing Egg"] = true
L["Nethercite Ore"] = true
L["Netherdust Pollen"] = true
L["Netherwing Crystal"] = true
L["Nethermine Cargo"] = true
L["Unidentified Plant Parts"] = true
L["Coilfang Armaments"] = true
L["Mature Spore Sac"] = true
L["Bog Lord Tendril"] = true
L["Glowcap"] = true
L["Fertile Spores"] = true
L["Sanguine Hibiscus"] = true
L["Obsidian Warbeads"] = true
L["Oshu'gun Crystal Fragment"] = true
L["Pair of Ivory Tusks"] = true
L["Zaxxis Insignia"] = true
L["Ethereum Prisoner I%.D%. Tag"] = true
L["Ethereum Prison Key"] = true
L["Halaa Research Token"] = true
L["Oshu'gun Crystal Powder Sample"] = true
L["Dampscale Basilisk Eye"] = true
L["Firewing Signet"] = true
L["Sunfury Signet"] = true
L["Arcane Tome"] = true
L["Arcane Rune"] = true
L["Dreadfang Venom Sac"] = true
L["Mark of Kil'jaeden"] = true
L["Mark of Sargeras"] = true
L["Fel Armament"] = true
L["Holy Dust"] = true
L["Mark of the Illidari"] = true
L["Badge of Justice"] = true
L["Arakkoa Feather"] = true
L["Quest Item"] = true
L["Morbent"] = true
L["Codex: "] = true
L["Manual: "] = true
L["Expert "] = true
L["Tome of "] = true
L["Design: "] = true
L["Formula: "] = true
L["Recipe: "] = true
L["Pattern: "] = true
L["Plans: "] = true
L["Schematic: "] = true
L["[Ss]kinning [Kk]nife"] = true
L["[Mm]ining [Pp]ick"] = true
L["[Bb]lacksmith [Hh]ammer"] = true
L["Runed %a+ Rod"] = true
L["Philosopher's Stone"] = true
L["Salt Shaker"] = true
L["Arclight Spanner"] = true
L["Gyromatic Micro%-Adjust[oe]r"] = true
L["Zulian Slicer"] = true
L["Finkle's Skinner"] = true
L["Blood Scythe"] = true
L["Herbalist's Gloves"] = true
L["Dwarven Fishing Pole"] = true
L["Goblin Fishing Pole"] = true
L["Everlasting Underspore Frond"] = true
L["\nHead"] = true
L["\nNeck"] = true
L["\nShoulder"] = true
L["\nBack"] = true
L["\nChest"] = true
L["\nShirt"] = true
L["\nTabard"] = true
L["\nWrist"] = true
L["\nHands"] = true
L["\nWaist"] = true
L["\nLegs"] = true
L["\nFeet"] = true
L["\nHeld In Off%-hand"] = true
L[" Bandage"] = true
L["Instantly restores %d+ life"] = true
L[" well fed "] = true
L["Restores %d+ health.* increases your "] = true
L["If you spend at least %d+ seconds eating you will"] = true
L["Must remain seated while drinking%."] = true
L["Restores %d+ mana over %d+ sec"] = true
L["Restores %d+ health and %d+ mana over %d+ sec"] = true
L["Restores .* health and .*mana .* %d+ sec"] = true
L["Must remain seated while eating%."] = true
L["Restores %d+ health over %d+ sec"] = true
L["Thistle Tea"] = true
L["[Rr]estores %d+ energy"] = true
L["Rage Potion"] = true
L["[Rr]estores %d+ rage"] = true
L["Rejuvenation Potion"] = true
L["Dreamless Sleep"] = true
L["[Rr]estores %d+ to %d+ mana and health"] = true
L["Mana Potion"] = true
L["[Rr]estores %d+ to %d+ mana"] = true
L["Healing Potion"] = true
L["[Rr]estores %d+ to %d+ health"] = true
L["Place a %a+ stone statue"] = true
L[" [Cc]ure.* poison"] = true
L[" [Cc]ure.* disease"] = true
L[" [Cc]ure.* curse"] = true
L[" [Cc]ure.* magic"] = true
L[" [Rr]emoves %d+ .*effect"] = true
L[" Dynamite"] = true
L[" Bomb"] = true
L[" Mortar"] = true
L["Scroll"] = true
L["Use: Increases "] = true
L["Use: Absorbs "] = true
L["Use: Regenerate "] = true
L["Use: While applied to target weapon"] = true
L[" Sharpening Stone"] = true
L[" Weightstone"] = true
L["Mistletoe"] = true
L["Flame Cap"] = true
L["[AG][li][lv][oe]w?s the [Ii]mbiber "] = true
L[" Key"] = true
L["Light Feather"] = true
L["Infernal Stone"] = true
L["Demonic Figurine"] = true
L[" Seed"] = true
L["Wild "] = true
L["Arcane Powder"] = true
L["Rune of "] = true
L["Symbol of"] = true
L[" Candle"] = true
L["Ankh"] = true
L["Fish Oil"] = true
L["Shiny Fish Scales"] = true
L["Thieves' Tools"] = true
L[" Totem"] = true
L["Soul Shard"] = true
L["Corpse Dust"] = true
L["Target Dummy"] = true
L["Elemental %a+"] = true
L["Essence of %a+"] = true
L["Globe of Water"] = true
L["Breath of Wind"] = true
L["Heart of Fire"] = true
L["Core of Earth"] = true
L["Mote of %a+"] = true
L["Primal Nether"] = true
L["Primal %a+"] = true
L["Void Crystal"] = true
L["Nether Vortex"] = true
L["Sunmote"] = true
L["Heart of Darkness"] = true
L[" Vial"] = true
L["[cC]loth"] = true
L["Coats a weapon with poison that lasts for"] = true
L["Raw "] = true
L["[Ff]ish"] = true
L[" Meat"] = true
L["%a+ Dust"] = true
L["Lesser %a+ Essence"] = true
L["Greater %a+ Essence"] = true
L["Small %a+ Shard"] = true
L["Large %a+ Shard"] = true
L["Papa Hummel's Old%-Fashioned Pet Biscuit"] = true
L["Silver Shafted Arrow"] = true
L["Crashin' Thrashin'"] = true
L["Tonk Controller"] = true
L["Mechanical Yeti"] = true
L["Orb of the Sin'dorei"] = true
L["Orb of the Blackwhelp"] = true
L["Winter Veil Disguise Kit"] = true
L["Hallowed Wand %- "] = true
L["Murloc Costume"] = true
L["Weighted Jack%-o'%-Lantern"] = true
L["Gordok Ogre Suit"] = true
L["Transforms your mount into something more festive"] = true
L["Your mount will be more festive"] = true
L["Shoots a.*firework"] = true
L["Place on the ground to launch .* rockets"] = true
L["Throw into a .* launcher"] = true
L["Brazier of Dancing Flames"] = true
L["Direbrew's Remote"] = true
L["Goblin Weather Machine %- Prototype 01%-B"] = true
L["Use: Right Click to set up a .* picnic."] = true
L["D\.I\.S\.C\.O\."] = true
L["Imp in a Ball"] = true
L["Snowball"] = true
L["Paper Flying Machine Kit"] = true
L["If they have free room in their pack they will catch it"] = true
L["Fishing Chair"] = true
L["Elune Stone"] = true
L["Shower a nearby target with a cascade of"] = true
L["Path of Illidan"] = true
L["Goblin Gumbo"] = true
L["Toasting Goblet"] = true
L["Summons a .* that will protect you for"] = true
L["Creates a .* that will fight for you"] = true
L["Explosive Sheep"] = true
L["Goblin Land Mine"] = true
L["Eye of Arachnida"] = true
L["Pet Leash"] = true
L["Fetch Ball"] = true
L["Happy Pet Snack"] = true
L["Paper Zeppelin Kit"] = true
L["Titanium Seal of Dalaran"] = true
L["Frozen Orb"] = true
L["Crystallized %a+"] = true
L["Eternal %a+"] = true
L["Virtuoso Inking Set"] = true
L["Ink"] = true
L[" Parchment"] = true
L[" Pigment"] = true
L["Grindgear Toy Gorilla"] = true
L["Copper Racer"] = true
L["Toy Train Set"] = true
L["Engineer's Ink"] = true
L["Rickety Magic Broom"] = true
L["Iron Boot Flask"] = true
L["Zapthrottle Mote Extractor"] = true
L["Wand of Holiday Cheer"] = true
L["Rolls a pair of dice"] = true
L["Blessed Medallion of Karabor"] = true
L["Frenzyheart Brew"] = true
L["Tiny %a+ Ragdoll"] = true
L["Festival Firecracker"] = true
L["Elder's Moonstone"] = true
L["Wind%-Up Train Wrecker"] = true
L["Sandbox Tiger"] = true
L["Foam Sword Rack"] = true
L["Unusual Compass"] = true
L["Blossoming Branch"] = true
L["Path of Cenarius"] = true
L["Ogre Pinata"] = true
L["Ultrasafe Transporter:"] = true
L["Dimensional Ripper - "] = true
L["Wormhole Generator:"] = true
L["Goblin Beam Welder"] = true
L["Runed Orb"] = true
L["Crusader Orb"] = true
L["Gnomish Army Knife"] = true
L["Primordial Saronite"] = true
L["Brazie's Gnomish Pleasure Device"] = true
L["Summons and dismisses a rideable"] = true
L["Nurtured Penguin Egg"] = true
L["Truesilver Shafted Arrow"] = true
L["Kirin Tor Familiar"] = true
L["Unhatched Mr. Chilly"] = true
L["Frosty's Collar"] = true
L["Perpetual Purple Firework"] = true
L["Carved Ogre Idol"] = true
L["The Flag of Ownership"] = true
L["Gnomeregan Pride"] = true
