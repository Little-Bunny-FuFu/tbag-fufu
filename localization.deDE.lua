-- $Id$

-- German translation maintained by Dessa <dessa@gmake.de>.

-- localization files should be edited with a utf-8
-- compatable editor and done so with utf-8 encoding.

-- See localization.template.lua to start a new translation.

if GetLocale() ~= "deDE" then return end

TBag.LOCALES.deDE = {}
TBag.LOCALES.current = TBag.LOCALES.deDE
local L = TBag.LOCALE

L[""] = ""  -- Needed to preserve nil returns

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
L["Consumable"] = "Verbrauchbar"
L["Container"] = "Beh\195\164lter"
L["Miscellaneous"] = MISCELLANEOUS
L["Projectile"] = "Projektil"
L["Quest"] = "Quest"
L["Quiver"] = INVTYPE_QUIVER
L["Reagent"] = "Reagenz"
L["Recipe"] = "Rezept"
L["Trade Goods"] = "Handwerkswaren"
L["Weapon"] = "Waffe"
L["Key"] = "Schl\195\188ssel"
L["Elemental"] = "Elementar"
L["Glyph"] = "Glyphe"

-- Sub types
L["Junk"] = "Plunder"
L["Explosives"] = "Sprengstoff"
L["Devices"] = "Ger\195\164te"
L["Parts"] = "Teile"
L["Ammo Pouch"] = "K\195\182cher"
L["Soul Bag"] = "Seelentasche"
L["Engineering Bag"] = "Ingenieurstasche"
L["Gem Bag"] = "Edelsteintasche"
L["Herb Bag"] = "Kr\195\164utertasche"
L["Mining Bag"] = "Bergbautasche"
L["Enchanting Bag"] = "Verzauberertasche"
L["Leatherworking Bag"] = "Lederertasche"

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
L["Bank"] = "Bank"
L["Backpack"] = "Rucksack"
L["First Bag"] = "Erste Tasche"
L["Second Bag"] = "Zweite Tasche"
L["Third Bag"] = "Dritte Tasche"
L["Fourth Bag"] = "Vierte Tasche"
L["First Bank Bag"] = "Erste Banktasche"
L["Second Bank Bag"] = "Zweite Banktasche"
L["Third Bank Bag"] = "Dritte Banktasche"
L["Fourth Bank Bag"] = "Vierte Banktasche"
L["Fifth Bank Bag"] = "F\195\188nfte Banktasche"
L["Sixth Bank Bag"] = "Sechste Banktasche"
L["Seventh Bank Bag"] = "Siebte Banktasche"
L["Empty Slot"] = "Leerer Platz"

-----------------------------------------------------------------------
-- CATEGORIES
-----------------------------------------------------------------------

-- Templates that are used to create a number of categories.
L["EMPTY_%s_SLOTS"] = "LEERE_%s_PL\195\132TZE"
L["IN_%s_BAG"] = "IN_%s_TASCHE"
L["%s_CREATED"] = "%s_ERSTELLT"
L["SOULBOUND_%s"] = "SEELENGEBUNDEN_%s"
L["ACCOUNTBOUND_%s"] = "ACCOUNTGEBUNDEN_%s"
L["EQUIPPED_%s"] = "ANGELEGT_%s"
L["%s_TOOL"] = "%s_WERKZEUG"
L["%s_REAGENT"] = "%s_REAGENZ"

-- Broad categories for item types
L["PROJECTILE"] = "PROJEKTIL"
L["SOULSHARD"] = "SEELENSPLITTER"
L["CONSUMABLE"] = "VERBRAUCHBAR"
L["ACT_ON"] = "ACT_ON"
L["ACT_OPEN"] = "ACT_OPEN"
L["ACT_SELL"] = "ACT_SELL"
L["BAG"] = "TASCHE"
L["GRAY_ITEMS"] = "GRAUE_ITEMS"
L["QUEST"] = "QUEST"
L["KEY_QUEST"] = "SCHL\195\156SSEL_QUEST"
L["KEY_OPEN"] = "SCHL\195\156SSEL_\195\150FFNEN"
L["ENCHANTS"] = "VERZAUBERUNG"
L["GLYPHS"] = "GLYPHEN"
L["BOOK"] = "BUCH"
L["DESIGN"] = "VORLAGE"
L["FORMULA"] = "FORMEL"
L["RECIPE"] = "REZEPT"
L["PATTERN"] = "MUSTER"
L["PLANS"] = "PL\195\132NE"
L["SCHEMATIC"] = "BAUPLAN"
L["RECIPE_OTHER"] = "ANDERE_REZEPTE"
L["PVP"] = "PVP"
L["REAGENT"] = "REAGENZ"
L["TRADE_GOODS"] = "HANDWERKSWAREN"
L["CLOTH"] = "STOFF"
L["MINIPET"] = "MINIPET"
L["COMBATPETS"] = "KAMPFPETS"
L["COSTUMES"] = "KOST\195\156ME"
L["FIREWORKS"] = "FEUERWERK"
L["TOYS"] = "SPIELZEUG"
L["MOUNT"] = "REITTIER"
L["FOOD"] = "ESSEN"
L["FOOD_BUFF"] = "ESSEN_BUFF"
L["DRINK"] = "TRINKEN"
L["COMBO"] = "COMBO"
L["BUFF"] = "BUFF"
L["DUMMY"] = "DUMMY"
L["BANDAGE"] = "VERB\195\132NDE"
L["HEALTH_RESTORE"] = "LEBEN_WIEDERHERSTELLEN"
L["HEALTHSTONE"] = "GESUNDHEITSSTEIN"
L["MANA_RESTORE"] = "MANA_WIEDERHERSTELLEN"
L["COMBO_RESTORE"] = "COMBO_WIEDERHERSTELLEN"
L["RAGE_RESTORE"] = "WUT_WIEDERHERSTELLEN"
L["ENERGY_RESTORE"] = "ENERGIE_WIEDERHERSTELLEN"
L["CURE"] = "HEILUNG"
L["EXPLOSIVES"] = "EXPLOSIV"
L["HEARTH"] = "RUHE"
L["MISC"] = "VERSCHIEDENES"
L["UNKNOWN"] = "UNBEKANNT"

-- Faction and Collectable Categories.
L["THORIUM_BROTHER"] = "THORIUM_BRUDERSCHAFT"
L["TIMBERMAW"] = "HOLZSCHLUNDFESTE"
L["CENARION_EXPEDITION"] = "EXPEDITION_DES_CENARIUS"
L["SPOREGGAR"] = "SPOREGGAR"
L["ARGENT_DAWN"] = "ARGENTUMD\195\132MMERUNG"
L["ALDOR"] = "ALDOR"
L["SCRYER"] = "SEHER"
L["SHA'TAR"] = "SHA'TAR"
L["LOWER_CITY"] = "UNTERES_VIRTEL"
L["AHN_QIRAJ"] = "AHN_QIRAJ"
L["CENARION_CIRCLE"] = "ZIRKEL_DES_CENARIUS"
L["NETHERWING"] = "NETHERSCHWINGEN"
L["BLACKWING_LAIR"] = "PECHSCHWINGENHORT"
L["DARKMOON_FAIRE"] = "DUNKELMONDJAHRMARKT"
L["OGRI'LA"] = "OGRI'LA"
L["MOLTEN_CORE"] = "GESCHMOLZENER_KERN"
L["ZUL_GURUB"] = "ZUL_GURUB"
L["CONSORTIUM"] = "KONSORTIUM"
L["HALAA"] = "HALAA"

-- Tradeskill categories
L["TRADE1"] = "TRADE1"
L["TRADE2"] = "TRADE2"
L["ALCHEMY"] = "ALCHIMIE"
L["BLACKSMITHING"] = "SCHMIEDEKUNST"
L["ENCHANTING"] = "VERZAUBERKUNST"
L["ENGINEERING"] = "INGENIEURSKUNST"
L["JEWELCRAFTING"] = "JUWELENSCHLEIFEN"
L["LEATHERWORKING"] = "LEDERVERARBEITUNG"
L["MINING"] = "BERGBAU"
L["POISONS"] = "GIFTE"
L["TAILORING"] = "SCHNEIDEREI"
L["INSCRIPTION"] = "INSCHRIFTENKUNDE"
L["FIRST_AID"] = "ERSTE_HILFE"
L["COOKING"] = "KOCHKUNST"
L["FISHING"] = "ANGELN"
L["RUNEFORGING"] = "RUNEN_SCHMIEDEN"
L["TRADE_TOOL"] = "HANDELSWERKZEUG"

-- Item slot categories
-- Note the categories with numbers in them must sort in the same order
-- per the standard lua sort.  Numbering like this is probably needed
-- for all languages to preserve the sort order.
L["01_HEAD"] = "01_KOPF"
L["02_NECK"] = "02_HALS"
L["03_SHOULDER"] = "03_SCHULTER"
L["04_BACK"] = "04_R\195\156CKEN"
L["05_CHEST"] = "05_BRUST"
L["06_SHIRT"] = "06_HEMD"
L["07_TABARD"] = "07_WAPPENROCK"
L["08_WRIST"] = "08_HANDGELENKE"
L["09_HANDS"] = "09_H\195\132NDE"
L["10_WAIST"] = "10_TAILLE"
L["11_LEGS"] = "11_BEINE"
L["12_FEET"] = "12_F\195\156\195\159E"
L["13_OFFHAND"] = "13_SCHILDHAND"
L["RELIC"] = "RELIKT"
L["RING"] = "RING"
L["TRINKET"] = "SCHMUCK"
L["ARMOR"] = "R\195\156STUNG"
L["WEAPON"] = "WAFFE"
L["OTHER"] = "ANDERE"

-- Class Categories
L["DRUID"] = "DRUIDE"
L["WARLOCK"] = "HEXENMEISTER"
L["ROGUE"] = "SCHURKE"
L["MAGE"] = "MAGIER"
L["PALADIN"] = "PALADIN"
L["PRIEST"] = "PRIESTER"
L["SHAMAN"] = "SCHAMANE"
L["WARRIOR"] = "KRIEGER"
L["HUNTER"] = "J\195\132GER"
L["DEATHKNIGHT"] = "TODESRITTER"
L["CLASS_TOOL"] = "KLASSENWERKZEUG"
L["CLASS_REAGENT"] = "KLASSENREAGENZ"

-- Short bag type names used for EMPTY_%s_SLOTS and IN_%s_BAG categories
-- 3-4 characters is about right for these.
L["QUIV"] = "K\195\150CH"
L["AMMO"] = "MUN"
L["SOUL"] = "SEEL"
L["ENG"] = "ING"
L["GEM"] = "JUW"
L["HERB"] = "KR\195\132U"
L["MINE"] = "BERG"
L["ENCH"] = "VERZ"
L["LTHR"] = "LED"
L["PET"] = "PET"
L["INSC"] = "INSCH"

-- Bag Position Names, also used for EMPTY_%s_SLOTS and IN_%s_BAG categories
L["KEYRING"] = "SCHL\195\156SSELBUND"
L["BANK"] = "BANK"
L["BACKPACK"] = "RUCKSACK"
L["BAG1"] = "TASCHE1"
L["BAG2"] = "TASCHE2"
L["BAG3"] = "TASCHE3"
L["BAG4"] = "TASCHE4"
L["BBAG1"] = "BANKTASCHE1"
L["BBAG2"] = "BANKTASCHE2"
L["BBAG3"] = "BANKTASCHE3"
L["BBAG4"] = "BANKTASCHE4"
L["BBAG5"] = "BANKTASCHE5"
L["BBAG6"] = "BANKTASCHE6"
L["BBAG7"] = "BANKTASCHE7"

-- Keywords
L["SOULBOUND"] = "SEELENGEBUNDEN"
L["ACCOUNTBOUND"] = "ACCOUNTGEBUNDEN"
L["EQUIPPED"] = "ANGELEGT"

-----------------------------------------------------------------------
-- CHAT STRINGS
-----------------------------------------------------------------------

L["%sSetting keybind to %q"] = "%sSetze Tastenk\195\188rzel auf %q"
L["Unassigned category %s has been assigned to slot 1"] =
      "Unzugeordnete Kategorie %s wurde dem Slot 1 zugewiesen"
L["Character data cached for:"] = "Charakterdaten gespeichert f\195\188r:"
L["Removed cache for %q"] = "Cache gel\195\182scht f\195\188r %q"
L["Couldn't find and remove cache for %q"] =
      "Kann den Cache nicht finden f\195\188r %q"
-----------------------------------------------------------------------
-- SEARCH OUTPUT STRINGS
-----------------------------------------------------------------------
L["Search results for %q:"] = "Suchergebnis f\195\188r %q:"
L["No results|r for %q"] = "Keine Ergebnisse|r f\195\188r %q"
L[" found:"] = " gefunden:"
L["bags"] = "Taschen"
L["bank"] = "Bank"
L["container"] = "Tasche"
L["body"] = "K\195\182rper"
L["mail"] = "Post"
L["tokens"] = "Abzeichen"
L[" in %s's %s"] = " in %s's %s" -- Used when an item is found in a characters bag or bank
L[" on %s's %s"] = " an %s's %s" -- Used when an item is found on a characters body
L[" as %s's %s"] = " als %s's %s" -- Used when an item is used as a container for a character

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
L["(Use: Returns you to )([^%.]*)(%.)"] = "(Benutzen: Bringt euch zur\195\188ck nach )([^%.]*)(%.)"
L["%%1%s%%3"] = "%%1%s%%3"

-- Generic name for the home location if we don't have it cached.
-- The tooltip should have something like this where in the text
-- where it describes how to change your bind point.  Brackets are
-- there to imply it's a placeholder.
L["<home location>"] = "<Heimatort>"

-----------------------------------------------------------------------
-- CHARGES
-----------------------------------------------------------------------
-- Pattern to get the charges from a tooltip
-- Probably only need to chage the Charges.
-- The ? after the s implies that the s may not be there
-- as would be the case in a single Charge.
L["(%d+) Charges?"] = "(%d+) Aufladung?n?"
-- Format string for adding the charges tooltip.
-- %d is the number of charges.  |4 specifies this
-- is a plural/singular pair.  Up until the : is the
-- singular form after is the plural until the ;.
L["%d |4Charge:Charges;"] = "%d |4Aufladung:Aufladungen;"

-----------------------------------------------------------------------
-- BINDING STRINGS
-----------------------------------------------------------------------
L["Toggle Bank Window"] = "Zeige Bankfester"
L["Toggle Inventory Window"] = "Zeige Inventarfester"

-----------------------------------------------------------------------
-- COMMAND LINE STRINGS
-----------------------------------------------------------------------
-- commands
L["hide"] = "hide"
L["show"] = "show"
L["update"] = "update"
L["debug"] = "debug"
L["reset"] = "reset"
L["resetpos"] = "resetpos"
L["resetsorts"] = "resetsorts"
L["printchars"] = "printchars"
L["deletechar"] = "deletechar"
L["config"] = "config"
L["tests"] = "tests"
L["getcat"] = "getcat"

-- /tbnk help text
L["TBnk Commands:"] = "TBnk Kommandos"
L[" /tbnk show  -- open window"] = " /tbnk show  -- \195\150ffne Fenster"
L[" /tbnk hide  -- hide window"] = " /tbnk hide  -- Verstecke Fenster"
L[" /tbnk update  -- refresh the window"] = " /tbnk update  -- Fenster neu laden"
L[" /tbnk config  -- configuration options"] = " /tbnk config  -- Konfiguration"
L[" /tbnk debug  -- turn debug info on/off"] = " /tbnk debug  -- Debugmodus an- und ausschalten"
L[" /tbnk reset  -- sets everything back to default values"] = " /tbnk reset  -- alles auf Standardwerte zur\195\188cksetzen"
L[" /tbnk resetpos -- put the bank back to its default position"] = " /tbnk resetpos -- Das Bankfenster auf die Standardposition zur\195\188cksetzen"
L[" /tbnk resetsorts -- clears the item search list"] = " /tbnk resetsorts -- l\195\182scht die Item Suchliste"
L[" /tbnk printchars -- prints a list of all the chars with cached info"] = " /tbnk printchars -- Gibt eine Liste aller Charaktere mit gespeicherten Infos aus"
L[" /tbnk deletechar CHAR SERVER -- clears all cached info for character "] = " /tbnk deletechar CHAR SERVER -- L\195\182scht die gespeicherten Daten f\195\188r den gew\195\164hlten Charakter "

-- /tinv help text
L["TInv Commands:"] = "TInv Kommandos:"
L[" /tinv show  -- open window"] = " /tinv show  -- \195\150ffne Fenster"
L[" /tinv hide  -- hide window"] = " /tinv hide  -- Verstecke Fenster"
L[" /tinv update  -- refresh the window"] = " /tinv update  -- Fenster neu laden"
L[" /tinv config  -- configuration options"] = " /tinv config  -- Konfiguration"
L[" /tinv debug  -- turn debug info on/off"] = " /tinv debug  -- Debugmodus an- und ausschalten"
L[" /tinv reset  -- sets everything back to default values"] = " /tinv reset  -- alles auf Standardwerte zur\195\188cksetzen"
L[" /tinv resetpos -- put the inventory window back to its default position"] = " /tinv resetpos -- Das Inventarfenster auf die Standardposition zur\195\188cksetzen"
L[" /tinv resetsorts -- clears the item search list"] = " /tinv resetsorts -- l\195\182scht die Item Suchliste"
L[" /tinv printchars -- prints a list of all the chars with cached info"] = " /tinv printchars -- Gibt eine Liste aller Charaktere mit gespeicherten Infos aus"
L[" /tinv deletechar CHAR SERVER -- clears all cached info for character "] = " /tinv deletechar CHAR SERVER -- L\195\182scht die gespeicherten Daten f\195\188r den gew\195\164hlten Charakter"

-----------------------------------------------------------------------
-- WINDOW STRINGS
-----------------------------------------------------------------------
L["TBag v%s"] = "TBag v%s"

L["Normal"] = "Normal"
L["Stop highlighting new items."] = "Neue Items nicht mehr hervorheben."
L["Highlight New"] = "Neue Hervorheben"
L["Highlight items marked as new."] = "Items die als neu Markiert sind hervorheben."
L["Clear Search"] = "Suche l\195\182schen"
L["Stop highlighting search results."] = "Suchergebnisse nicht mehr hervorheben."

L["Toggle Edit Mode"] = "Bearbeitungsmodus Ein- und Ausschalten"
L["Select this option to move classes of items into different 'bars' (the red numbers)."] = "W\195\164hle diese Option um Itemklassen in andere \"Felder\" zu verschieben (die roten Zahlen)."

L["Reload and Sort"] = "Neuladen und Sortieren"
L["Reloads your items and sorts them."] = "L\195\164d die Items neu und sortiert sie."

L["Toggle Bank"] = "Zeige Bank"
L["Displays bank contents in a view-only mode.  You may select another player's bank to view from the dropdown."] = "Zeigt den Bankinhalt im Nur-Lesen Modus. Du kannst aus dem Men\195\188 die Bank eines anderen Spielers w\195\164hlen."

L["Toggle Purchase Info"] = "Zeige Kauf Info"
L["Displays the purchase button and cost to buy a new bank slot.  This is disabled in read-only views and edit mode."] = "Zeigt den Kauf Button and die Kosten um einen neuen Bankplatz zu kaufen. Deaktiviert im Nur-Lesen- und Bearbeitungsmodus."

L["Unlock Window"] = "Entsperre Fenster"
L["Allow window to be moved by dragging it."] = "Erlaubt das Fenster durch Ziehen zu verschieben."
L["Lock Window"] = "Sperre Fenster"
L["Prevent window from being moved by dragging it."] = "Verbietet das Fenster durch Ziehen zu verschieben."

L["<++>"] = "<++>"
L["Increase Window Size"] = "Erh\195\182he Fenstergr\195\182\195\159e"
L["Increase the number of columns displayed"] = "Erh\195\182he die Anzahl der Reihen"

L[">--<"] = ">--<"
L["Decrease Window Size"] = "Verringere Fenstergr\195\182\195\159e"
L["Decrease the number of columns displayed"] = "Verringere die Anzahl der Reihen"

L["Reset"] = "Reset"
L["Close"] = "Schlie\195\159en"
L["Add New Cat"] = "neue Kat. hinzuf\195\188gen"
L["Assign Cats"] = "Kat. zuweisen"
L["No"] = "Nein"
L["Yes"] = "Ja"
L["Category"] = "Kategorie"
L["Keywords"] = "Schl\195\188sselw\195\182rter"
L["Tooltip Search"] = "Tooltip Suche"
L["Type"] = "Typ"
L["SubType"] = "SubTyp"

-- Menus and Tooltips
L["Main Background Color"] = "Allgemeine Hintergrundfarbe"
L["Main Border Color"] = "Allgemeine Randfarbe"
L["Set Bar Colors to Main Colors"] = "Verwende Feldfarben als allgemeine Farben"
L["Spotlight for %s"] = "Hervorhebung f\195\188r %s"
L["Current Category: %s"] = "Aktuelle Kategorie: %s"
L["Assign item to category:"] = "Item der Kategorie zuordnen:"
L["Use default category assignment"] = "Verwende Standard Kategorie Zuordnung"
L["Debug Info: "] = "Debug Info: "
L["Categories within bar %d"] = "Kategorien in Feld %d"
L["Move: |c%s%s|r"] = "Bewegen: |c%s%s|r"
L["Sort Mode:"] = "Sortiermodus:"
L["No sort"] = "Keine Sortierung"
L["Sort by name"] = "nach Name Sortieren"
L["Sort last words first"] = "nach letzter Verwendung Sotieren"
L["Highlight new items:"] = "Neue Items hervorheben:"
L["Don't tag new items"] = "Neue Items nicht Markieren"
L["Tag new items"] = "neue Items Markieren"
L["Hide Bar:"] = "Verstecke Feld:"
L["Show items assigned to this bar"] = "Zeige Items die dem Feld zugewiesen sind"
L["Hide items assigned to this bar"] = "Verstecke Items die dem Feld zugewiesen sind"
L["Color:"] = "Farbe:"
L["Background Color for Bar %d"] = "Hintergrundfarbe f\195\188r Felder %d"
L["Border Color for Bar %d"] = "Randfarbe f\195\188r Felder %d"
L["Select Character"] = "Zeige Charakter"
L["Edit Mode"] = "Bearbeitungsmodus"
L["Lock window"] = "Fenster sperren"
L["Show Purchase Info"] = "Zeige Kauf Info"
L["Close Inventory"] = "Inventar Schlie\195\159en"
L["Highlight New Items"] = "Neue Items Hervorheben"
L["Reset NEW tag"] = "Setze NEU Markierung zur\195\188ck"
L["Advanced Configuration"] = "Erweiterte Konfiguration"
L["Set Size"] = "Gr\195\182\195\159e setzen"
L["Set Colors"] = "Farben Setzen"
L["Hide"] = "Verstecken"
L["Hide Player Dropdown"] = "Verstecke Spieler"
L["Hide Search Box"] = "Verstecke Suchfeld"
L["Hide Re-sort Button"] = "Verstecke neu Sortieren"
L["Hide Bank Button"] = "Verstecke Bank Knopf"
L["Hide Show Purchase Button"] = "Verstecke Zeige Kaufen Knopf"
L["Hide Edit Button"] = "Verstecke bearbeiten Knopf"
L["Hide Highlight Button"] = "Verstecke Hervorheben Knopf"
L["Hide Lock Button"] = "Verstecke Sperren Knopf"
L["Hide Close Button"] = "Verstecke Schlie\195\159en Knopf"
L["Hide Total"] = "Verstecke Gesamt"
L["Hide Bag Buttons"] = "Verstecke Taschenkn\195\182pfe"
L["Hide Money"] = "Verstecke Geld"
L["Hide Tokens"] = "Verstecke Abzeichen"
L["The Bank"] = "Die Bank"
L["|c%sLeft click to move category |r|c%s%s|r|c%s to bar |r|c%s%s|r"] = "|c%sLinksklick um Kategorie |r|c%s%s|r|c%s zu Felder zu verschieben |r|c%s%s|r"
L["|c%sBar |r|c%s%s|r"] = "|c%sFeld |r|c%s%s|r"
L["|c%s%s|r"] = "|c%s%s|r"
L["Right click for options"] = "Rechtsklick f\195\188r Optionen"
L["|c%sLeft click to select category to move:|r |c%s%s|r"] = "|c%sLinksklick um die Kategorie zum Verschieben zu w\195\164hlen:|r |c%s%s|r"
L["Right click to assign this item to a different category"] = "Rechtsklick um dieses Item einer anderen Kategorie zuzuweisen"
L["You are viewing the selected player's bank."] = "Du siehst die Bank des ausgew\195\164hlten Spielers an"
L["You are viewing the selected player's inventory."] = "Du siehst das Inventar des ausgew\195\164hlten Spielers an."
L["Equip Container"] = "Tasche anlegen"
L["Anchor"] = "Anker"
L["TOPLEFT"] = "OBENLINKS"
L["TOPRIGHT"] = "OBENRECHTS"
L["BOTTOMLEFT"] = "UNTENLINKS"
L["BOTTOMRIGHT"] = "UNTENRECHTS"
L["Show on TBag"] = "Zeige in TBag"
L["Checking this option will allow you to track this currency type in TBag for this character.\n\nYou can also Shift-click a currency to add or remove it from being tracked in TBag."] = "Ist diese Option aktiviert wird diese W\195\164hrung in TBag f\195\188r diesen Charakter angezeigt.\n\nDu kannst auch auf eine W\195\164hrung Shift-Rechtsklicken um sie in TBag anzuzeigen oder zu entfernen."

-- Option Window Strings
L["Main Sizing Preferences"] = "Allgemeine Gr\195\182\195\159eneinstellungen"
L["Number of Item Columns:"] = "Anzahl der Itemspalten:"
L["Number of Horizontal Bars:"] = "Anzahl der Horizontalen Felder:"
L["Window Scale:"] = "Fensterskalierung:"
L["Item Button Size:"] = "Itemknopf Gr\195\182\195\159e:"
L["Item Button Padding:"] = "Itemknopf Abstand:"
L["Spacing - X Button:"] = "Leerraum - X Knopf:"
L["Spacing - Y Button:"] = "Leerraum - Y Knopf:"
L["Spacing - X Pool:"] = "Leerraum - X Pool:"
L["Spacing - Y Pool:"] = "Leerraum - Y Pool:"
L["Count Font Size:"] = "Zahlen Schriftgr\195\182\195\159e:"
L["Count Placement - X:"] = "Zahlenplatzierung - X:"
L["Count Placement - Y:"] = "Zahlenplatzierung - Y:"
L["New Tag Font Size:"] = "Neue Markierungs Schriftgr\195\182\195\159e:"
L["Bag Contents Show"] = "Tascheninhalt anzeigen"
L["Show %s:"] = "Zeige %s:"
L["General Display Preferences"] = "Allgemeine Anzeigeeigenschaften"
L["Show Size on Bag Count:"] = "Zeige Gr\195\182\195\159e auf Taschenzahl:"
L["Show Bag Icons on Empty Slots:"] = "Zeige Taschensymbol auf leeren Pl\195\164tzen:"
L["Spotlight Open or Selected Bags:"] = "Hebe Offene oder Ausgew\195\164hlte Taschen hervor:"
L["Spotlight Mouseover:"] = "Mouseover Hervorhebung:"
L["Show Item Rarity Color:"] = "Zeige Item Seltenheitsfarbe:"
L["Auto Stack:"] = "Automatisches Stapeln:"
L["Stack on Re-sort:"] = "Stapeln beim neu Sortieren:"
L["Profession Bags precede Sorting:"] = "Berufstaschen beim Sortieren Bevorzugen:"
L["Trade Creation precedes Sorting (Reopen Window):"] = "Handel beim Sortieren Bevorzugen (Fenster neu \195\150ffnen):"
L["New Tag Options"] = "Neu Markierungs Optionen"
L["New Tag Text:"] = "Neu Markierungs Text:"
L["Increased Tag Text:"] = "Ver\195\182\195\159erter Markierungstext:"
L["Decreased Tag Text:"] = "Verkleinerter Markierungstext:"
L["New Tag Timeout (minutes):"] = "Neu Markierungs Timeout (Minuten):"
L["Recent Tag Timeout (minutes):"] = "K\195\188rzlich Markierungs Timeout (Minuten):"
L["Alt Key Auto-Pickup:"] = "Alternative Auto-Pickup Taste:"
L["Alt Key Auto-Panel:"] = "Alternative Auto-Panel Taste:"
L["Show Keyring Empty Slots (Enable Show above):"] = "Zeige leere Pl\195\164tze im Schl\195\188sselbund (Anzeige oben Aktivieren):"
L["Show Soul Shard Count On Soul Bags:"] = "Zeige Seelensplitter Anzahl auf Seelentaschen:"

-----------------------------------------------------------------------
-- Unit Tests
-----------------------------------------------------------------------
L["TEST RUN STARTING"] = "TESTLAUF STARTET"
L[" Retrieving item information"] = " Frage Gegenstandsinformationen ab"
L["SUCCESS: %s"] = "ERFOLGREICH: %s"
L["FAIL: %s (%s) expected %q but got %q"] = "FEHLGESCHLAGEN: %s (%s) erwartet %q aber %q erhalten"
L["ALL TESTS SUCCESSFUL"] = "ALLE TESTS ERFOLGREICH"

-----------------------------------------------------------------------
-- Default Search List Strings
-----------------------------------------------------------------------
L["This Item Begins a Quest"] = ITEM_STARTS_QUEST
L["<Right Click to Open>"] = ITEM_OPENABLE
L[" Lockbox"] = "schlie\195\159kassette"
L["Mark of Honor Hold"] = "Abzeichen der Ehrenfeste"
L["Mark of Thrallmar"] = "Abzeichen von Thrallmar"
L["Halaa Battle Token"] = "Kampfmarke von Halaa"
L["Spirit Shard"] = "Geistsplitter"
L["Use: Permanently"] = "Benutzen: .*dauerhaft"
L["Hearthstone%s"] = "Ruhestein%s"
L["Right Click to summon and dismiss"] = "Mit Rechtsklick .* beschw\195\182ren und freigeben%."
L["Summons or dismisses a Spirit of"] = "Beschw\195\182rt einen .*[gG]eist"
L["Use: Teaches you how to summon a?n?d? ?d?i?s?m?i?s?s? ?this companion."] = "Benutzen: Lehrt Euch, wie man diese[ns] [GH][ea][fu].+[ht][ri][te][er]n? beschw\195\182rt.*"
L["Requires Riding %("] = "Ben\195\182tigt Reiten %("
L["%a+ Scarab"] = "%a+skarab\195\164us"
L["%a+ Idol"] = "%a+g\195\182tze"
L["Qiraji %a+ %a+"] = "[%a+]*Qiraji"
L["Bone Fragments"] = "Knochenfragmente"
L["Core of Elements"] = "Kern der Elemente"
L["Crypt Fiend Parts"] = "Teile einer Gruftbestie"
L["Dark Iron Scraps"] = "Dunkeleisenfragmente"
L["Savage Frond"] = "Wildwedel"
L["Insignia of the Crusade"] = "Insigne des Kreuzzugs"
L["Insignia of the Dawn"] = "Insigne der D\195\164mmerung"
L["Argent Dawn Valor Token"] = "Ehrenmarke der Argentumd\195\164mmerung"
L["Mantle of the Dawn"] = "Mantel der D\195\164mmerung"
L["Vitreous Focuser"] = "Glasartiger Fokussierer"
L["Osseous Agitator"] = "Kn\195\182cherner Aufstachler"
L["Somatic Intensifier"] = "Somatischer Verst\195\164rker"
L["Ectoplasmic Resonator"] = "Ektoplasmaresonator"
L["Arcane Quickener"] = "Arkanbeschleuniger"
L[" Scourgestone"] = "Gei\195\159elstein "
L["Cenarion %a+ Badge"] = "Cenarisches %a+abzeichen"
L["Twilight Text"] = "Schattenhammertext"
L["Twilight Cultist"] = "Schattenhammerkultist"
L["Abyssal Crest"] = "Abyssisches Wappen"
L["Abyssal Signet"] = "Abyssisches Siegel"
L["Abyssal Scepter"] = "Abyssisches Szepter"
L["Darkmoon Faire Prize Ticket"] = "Gewinnlos des Dunkelmond%-Jahrmarkts"
L["Soft Bushy Tail"] = "Weicher buschiger Schwanz"
L["Vibrant Plume"] = "Farbenpr\195\164chtiger Federbusch"
L["Small Furry Paw"] = "Kleine pelzige Tatze"
L["Evil Bat Eye"] = "B\195\182ses Fledermausauge"
L["Torn Bear Pelt"] = "Zerrissener B\195\164renpelz"
L["Glowing Scorpid Blood"] = "Leuchtendes Skorpidblut"
L["Property of the Darkmoon Faire."] = "Eigentum des Dunkelmond%-Jahrmarkts"
L["Combine the %a+ through %a+ of %a+ to complete the set."] = "Vereint alle Karten vom %a+ bis zur %a+ de[sr] %a+"
L["Incendosaur Scale"] = "Incendosaurierschuppe"
L["Dark Iron Residue"] = "Dunkeleisenr\195\188ckst\195\164nde"
L["Deadwood Headdress Feather"] = "Kopfputzfeder der Totenwaldfelle"
L["Winterfall Spirit Beads"] = "Geisterperlen der Winterfelle"
L["Zandalar Honor Token"] = "Ehrenm\195\188nze der Zandalari"
L["%a+ Coin"] = "M\195\188nze der %a+"
L["%a+ Bijou"] = "%a+ Schmuckst\195\188ck"
L["Primal Hakkari"] = "Urzeitlicher?%s"
L["Apexis Crystal"] = "Apexiskristall"
L["to create a dragonscale cloak"] = "um einen Drachenschuppenumhang herzustellen"
L["Darkrune"] = "Rune der Dunkelheit"
L["Netherwing Egg"] = "Ei der Netherschwingen"
L["Nethercite Ore"] = "Netheriterz"
L["Netherdust Pollen"] = "Netherstaubpollen"
L["Netherwing Crystal"] = "Kristall der Netherschwingen"
L["Nethermine Cargo"] = "Fracht der Netherminen"
L["Unidentified Plant Parts"] = "Unbekannte Pflanzenteile"
L["Coilfang Armaments"] = "Waffen des Echsenkessels"
L["Mature Spore Sac"] = "Reifer Sporenbeutel"
L["Bog Lord Tendril"] = "Sumpflordranke"
L["Glowcap"] = "Gl\195\188hkappe"
L["Fertile Spores"] = "Fruchtbare Sporen"
L["Sanguine Hibiscus"] = "Bluthibiskus"
L["Obsidian Warbeads"] = "Obsidiankriegsperlen"
L["Oshu'gun Crystal Fragment"] = "Kristallfragment von Oshu'gun"
L["Pair of Ivory Tusks"] = "Paar Elfenbeinsto\195\159z\195\164hne"
L["Zaxxis Insignia"] = "Insigne der Zaxxis"
L["Ethereum Prisoner I%.D%. Tag"] = "Identifikationsmarke eines Gefangenen des Astraleums"
L["Ethereum Prison Key"] = "Gef\195\164ngnisschl\195\188ssel des Astraleums"
L["Halaa Research Token"] = "Forschermarke von Halaa"
L["Oshu'gun Crystal Powder Sample"] = "Kristallpulverprobe von Oshu'gun"
L["Dampscale Basilisk Eye"] = "Auge eines Dunstschuppenbasilisken"
L["Firewing Signet"] = "Siegel der Feuerschwingen"
L["Sunfury Signet"] = "Siegel des Sonnenzorns"
L["Arcane Tome"] = "Arkaner Foliant"
L["Arcane Rune"] = "Arkane Rune"
L["Dreadfang Venom Sac"] = "Schreckensgiftbeutel"
L["Mark of Kil'jaeden"] = "Mal von Kil'jaeden"
L["Mark of Sargeras"] = "Mal des Sargeras"
L["Fel Armament"] = "Teuflische Waffen"
L["Holy Dust"] = "Heiliger Staub"
L["Mark of the Illidari"] = "Mal der Illidari"
L["Badge of Justice"] = "Abzeichen der Gerechtigkeit"
L["Arakkoa Feather"] = "Arakkoafeder"
L["Quest Item"] = ITEM_BIND_QUEST
L["Morbent"] = "Morbent"
L["Codex: "] = "Kodex: "
L["Manual: "] = "Handbuch: "
L["Expert "] = "Experten"
L["Tome of "] = "Foliant de[sr] "
L["Design: "] = "Vorlage: "
L["Formula: "] = "Formel: "
L["Recipe: "] = "Rezept: "
L["Pattern: "] = "Muster: "
L["Plans: "] = "Pl\195\164ne: "
L["Schematic: "] = "Bauplan: "
L["[Ss]kinning [Kk]nife"] = "[Kk]\195\188rschnermesser"
L["[Mm]ining [Pp]ick"] = "[Ss]pitzhacke"
L["[Bb]lacksmith [Hh]ammer"] = "[Ss]chmiedehammer"
L["Runed %a+ Rod"] = "Runenverzierte .*[Rr]ute"
L["Philosopher's Stone"] = "Stein der Weisen"
L["Salt Shaker"] = "Salzstreuer"
L["Arclight Spanner"] = "Bogenlichtschraubenschl\195\188ssel"
L["Gyromatic Micro%-Adjust[oe]r"] = "Gyromatischer Mikroregler"
L["Zulian Slicer"] = "Zulianischer Schnitzler"
L["Finkle's Skinner"] = "Finkles K\195\188rschner"
L["Blood Scythe"] = "Blutsense"
L["Herbalist's Gloves"] = "Kr\195\164uterkundigenhandschuhe"
L["Dwarven Fishing Pole"] = "Zwergenangelrute"
L["Goblin Fishing Pole"] = "Goblinangelrute"
L["Everlasting Underspore Frond"] = "Unverg\195\164nglicher Tiefensporenfarn"
L["\nHead"] = "\nKopf"
L["\nNeck"] = "\nHals"
L["\nShoulder"] = "\nSchulter"
L["\nBack"] = "\nR\195\188cken"
L["\nChest"] = "\nBrust"
L["\nShirt"] = "\nHemd"
L["\nTabard"] = "\nWappenrock"
L["\nWrist"] = "\nHandgelenke"
L["\nHands"] = "\nH\195\164nde"
L["\nWaist"] = "\nTaille"
L["\nLegs"] = "\nBeine"
L["\nFeet"] = "\nF\195\188\195\159e"
L["\nHeld In Off%-hand"] = "\nIn Schildhand gef\195\188hrt"
L[" Bandage"] = "verband"
L["Instantly restores %d+ life"] = "Stellt sofort %d+ Gesundheit"
L[" well fed "] = " satt "
L["Restores %d+ health.* increases your "] = "Stellt im Verlauf von %d+ Sek. insgesamt %d+ Gesundheit wieder her. .* Erh\195\182ht "
L["If you spend at least %d+ seconds eating you will"] = "Wenn Ihr mindestens 10 Sekunden lang mit Essen verbringt, werdet Ihr"
L["Must remain seated while drinking%."] = "Ihr m\195\188sst beim Trinken sitzen bleiben%."
L["Restores %d+ mana over %d+ sec"] = "Stellt im Verlauf von %d+ Sek. insgesamt %d+ Mana wieder her"
L["Restores %d+ health and %d+ mana over %d+ sec"] = "Stellt .*%d+ Sek%. .*%d+ Gesundheit und %d+ Mana wieder her%."
L["Restores .* health and .*mana .* %d+ sec"] = "Stellt .*%d+ Sek%. .* Gesundheit und .* Mana[s] wieder her"
L["Must remain seated while eating%."] = "Ihr m\195\188sst beim Essen sitzen bleiben%."
L["Restores %d+ health over %d+ sec"] = "Stellt im Verlauf von %d+ Sek. insgesamt %d+ Gesundheit wieder her%."
L["Thistle Tea"] = "Disteltee"
L["[Rr]estores %d+ energy"] = "[Ss]tellt %a+ %d+ Energie"
L["Rage Potion"] = "Wuttrank"
L["[Rr]estores %d+ rage"] = "[Ee]rh\195\182ht Wut um %d+ bis %d+"
L["Rejuvenation Potion"] = "Verj\195\188ngungstrank"
L["Dreamless Sleep"] = "traumlosen Schlafs"
L["[Rr]estores %d+ to %d+ mana and health"] = "[Ss]tellt %d+ bis %d+ Mana und Gesundheit"
L["Mana Potion"] = "Manatrank"
L["[Rr]estores %d+ to %d+ mana"] = "[Ss]tellt %d+ bis %d+ Mana wieder her%."
L["Healing Potion"] = "Heiltrank"
L["[Rr]estores %d+ to %d+ health"] = "[Ss]tellt %d+ bis %d+ Gesundheit wieder her%."
L["Place a %a+ stone statue"] = "Stellt eine %a+ Steinstatue"
L[" [Cc]ure.* poison"] = " Gifte"
L[" [Cc]ure.* disease"] = " [Hh]eil.* Krankheit"
L[" [Cc]ure.* curse"] = " [Hh]eil.* Fluch"
L[" [Cc]ure.* magic"] = " [Hh]eil.* Magie"
L[" [Rr]emoves %d+ .*effect"] = " [HB][ea][bn]n?t .*effekt"
L[" Dynamite"] = "[%a+]*Dynamit"
L[" Bomb"] = "[%a+]*[Bb]ombe"
L[" Mortar"] = "[%a+]*[Mm]\195\182rser"
L["Scroll"] = "Rolle"
L["Use: Increases "] = "Benutzen: Erh\195\182ht "
L["Use: Absorbs "] = "Benutzen: Absorbiert "
L["Use: Regenerate "] = "Benutzen: .* regenerieren"
L["Use: While applied to target weapon"] = "bei Anwendung auf eine Waffe"
L[" Sharpening Stone"] = "[%a+]*[Ww]etzstein"
L[" Weightstone"] = "[%a+]*[Gg]ewichtsstein"
L["Mistletoe"] = "Mistelzweig"
L["Flame Cap"] = "Flammenkappe"
L["[AG][li][lv][oe]w?s the [Ii]mbiber "] = "[Dd]e[rm] Anwender"
L[" Key"] = ".*[Ss]chl\195\188ssel"
L["Light Feather"] = "Leichte Feder"
L["Infernal Stone"] = "H\195\182llenstein"
L["Demonic Figurine"] = "D\195\164monenstatuette"
L[" Seed"] = "sa[ma][et]n?k?o?r?n?"
L["Wild "] = "Wildes? "
L["Arcane Powder"] = "Arkanes Pulver"
L["Rune of "] = "Rune der "
L["Symbol of"] = "Symbol der"
L[" Candle"] = "%a+%s?[Kk]erze"
L["Ankh"] = "Ankh"
L["Fish Oil"] = "Fisch\195\182l"
L["Shiny Fish Scales"] = "Gl\195\164nzende Fischschuppen"
L["Thieves' Tools"] = "Diebeswerkzeug"
L[" Totem"] = "totem"
L["Soul Shard"] = "Seelensplitter"
L["Corpse Dust"] = "Leichenstaub"
L["Target Dummy"] = "Zielattrappe"
L["Elemental %a+"] = "Elementar%s?%a+"
L["Essence of %a+"] = "Essenz de[sr] %a+"
L["Globe of Water"] = "Kugel des Wassers"
L["Breath of Wind"] = "Odem des Windes"
L["Heart of Fire"] = "Herz des Feuers"
L["Core of Earth"] = "Erdenkern"
L["Mote of %a+"] = "%a+partikel"
L["Primal Nether"] = "Urnether"
L["Primal %a+"] = "Ur%a+"
L["Void Crystal"] = "Kristall der Leere"
L["Nether Vortex"] = "Nethervortex"
L["Sunmote"] = "Sonnenpartikel"
L["Heart of Darkness"] = "Herz der Dunkelheit"
L[" Vial"] = "[Pp]hiole"
L["[cC]loth"] = "[sS]toff"
L["Coats a weapon with poison that lasts for"] = "\195\156berzieht eine Waffe mit Gift"
L["Raw "] = "%s?[Rr]oher "
L["[Ff]ish"] = "[Ff]isch"
L[" Meat"] = "%a+%s?[Ff]leisch"
L["%a+ Dust"] = "%a+%s?[Ss]taub"
L["Lesser %a+ Essence"] = "Geringe .*[Ee]ssenz"
L["Greater %a+ Essence"] = "Gro\195\159e .*[Ee]ssenz"
L["Small %a+ Shard"] = "Kleiner .*[Ss]plitter"
L["Large %a+ Shard"] = "Gro\195\159er .*[Ss]plitter"
L["Papa Hummel's Old%-Fashioned Pet Biscuit"] = "Papa Hummels traditionelles Leckerli"
L["Silver Shafted Arrow"] = "Silberschaftpfeil"
L["Crashin' Thrashin'"] = "Steuerung f\195\188r Krachbummflitzer"
L["Tonk Controller"] = "Dampfpanzersteuerung"
L["Mechanical Yeti"] = "Mechanischer Yeti"
L["Orb of the Sin'dorei"] = "Kugel der Sin'dorei"
L["Orb of the Blackwhelp"] = "Kugel des Schwarzwelpen"
L["Winter Veil Disguise Kit"] = "Winterhauchverkleidungsset"
L["Hallowed Wand %- "] = "Stab der Verwandlung %- "
L["Murloc Costume"] = "Murlockost\195\188m"
L["Weighted Jack%-o'%-Lantern"] = "Gewichtige K\195\188rbislaterne"
L["Gordok Ogre Suit"] = "Ogeranzug der Gordok"
L["Transforms your mount into something more festive"] = "Verwandelt Euer Reittier in eine etwas festlichere Gestalt"
L["Your mount will be more festive"] = "Euer Reittier legt die Festtagstracht an."
L["Shoots a.*firework"] = "Schie\195\159t .*ein ?h?e?r?r?l?i?c?h?e?s? ?Feuerwerk"
L["Place on the ground to launch .* rockets"] = "Auf dem Boden aufstellen, um .* zu verschie\195\159en"
L["Throw into a .* launcher"] = "Mit einem Z\195\188nder"
L["Brazier of Dancing Flames"] = "Kohlenpfanne der tanzenden Flammen"
L["Direbrew's Remote"] = "D\195\188sterbr\195\164us Fernbedienung"
L["Goblin Weather Machine %- Prototype 01%-B"] = "Wunschwettermaschine %- Prototyp 01%-B"
L["Use: Right Click to set up a .* picnic."] = "Benutzen: Mit Rechts?klick ein .* Picknick" -- TODO: typo on live, hopefully fixed later
L["D\.I\.S\.C\.O\."] = "D\.I\.S\.C\.O\."
L["Imp in a Ball"] = "Wichtel in der Kugel"
L["Snowball"] = "Schneeball"
L["Paper Flying Machine Kit"] = "Papierflugmaschinenset"
L["If they have free room in their pack they will catch it"] = "wird e[rs] [isd][ihe][en] ?S?t?e?i?n? ?a?u?f?fangen"
L["Fishing Chair"] = "Angelstuhl"
L["Elune Stone"] = "Elunes [LS][at][et]e?[ri]ne?"
L["Shower a nearby target with a cascade of"] = "\195\156bersch\195\188ttet ein in der N\195\164he befindliches Ziel mit"
L["Path of Illidan"] = "Illidans Pfad"
L["Goblin Gumbo"] = "Goblingumbo"
L["Toasting Goblet"] = "Trinkbecher"
L["Summons a .* that will protect you for"] = "Beschw\195\182rt einen .* d[ea][rs] Euch %d+ [SM][ti][un]n?d?e?. lang besch\195\188tz[te]n?."
L["Creates a .* that will fight for you"] = "k\195\164mpf[et]n? ?w?i?r?d?." -- TODO: i don't like the idea of keeping the String *that* short, but it works for now, keeping the TODO here in case i can find anything better sometime
L["Explosive Sheep"] = "Explodierendes Schaf"
L["Goblin Land Mine"] = "Goblinlandmine"
L["Eye of Arachnida"] = "Auge von Arachnida"
L["Pet Leash"] = "Haustierleine"
L["Fetch Ball"] = "Apportierball"
L["Happy Pet Snack"] = "Leckerli f\195\188r gl\195\188ckliche Haustiere"
L["Paper Zeppelin Kit"] = "Papierzeppelinset"
L["Titanium Seal of Dalaran"] = "Titansiegel von Dalaran"
L["Frozen Orb"] = "Gefrorene Kugel"
L["Crystallized %a+"] = "Kristallisierte?[rs] %a+"
L["Eternal %a+"] = "\195\132onen%a+"
L["Virtuoso Inking Set"] = "Schreibzeug des Virtuosen"
L["Ink"] = "%a+tinte"
L[" Parchment"] = "Pergament"
L[" Pigment"] = "[Pp]igmente"
L["Grindgear Toy Gorilla"] = "Schleifritzelspielzeuggorilla"
L["Copper Racer"] = "Kupferflitzer"
L["Toy Train Set"] = "Spielzeugzug"
L["Engineer's Ink"] = "Ingenieurstinte"
L["Rickety Magic Broom"] = "Maroder Zauberbesen"
L["Iron Boot Flask"] = "Eiserner Flachmann"
L["Zapthrottle Mote Extractor"] = "Schockdrosselnder Partikelextraktor"
L["Wand of Holiday Cheer"] = "Zauberstab der Festtagsfreude"
L["Rolls a pair of dice"] = "W\195\188rfelt"
L["Blessed Medallion of Karabor"] = "Gesegnetes Medaillon von Karabor"
L["Frenzyheart Brew"] = "Wildherzenbier"
L["Tiny %a+ Ragdoll"] = "Winzige %a+ Stoffpuppe"
L["Festival Firecracker"] = "Festtagsknallfrosch"
L["Elder's Moonstone"] = "Mondstein der Urahnen"
L["Wind%-Up Train Wrecker"] = "Aufziehbarer Zugzerst\195\182rer"
L["Sandbox Tiger"] = "Sandkastentiger"
L["Foam Sword Rack"] = "Schaumstoffschwertst\195\164nder"
L["Unusual Compass"] = "Ungew\195\182hnlicher Kompass"
L["Blossoming Branch"] = "Bl\195\188hender Zweig"
L["Path of Cenarius"] = "Pfad des Cenarius"
L["Ogre Pinata"] = "Ogerpinata"
L["Ultrasafe Transporter:"] = "Extrem sicherer Transporter:"
L["Dimensional Ripper - "] = "Dimensionszerfetzer:"
L["Wormhole Generator:"] = "Wurmlochgenerator"
L["Goblin Beam Welder"] = "Goblinisches Lichtbogenschwei\195\159ger\195\164t"
L["Runed Orb"] = "Runenbeschriebene Kugel"
L["Crusader Orb"] = "Kugel des Kreuzfahrers"
L["Gnomish Army Knife"] = "Gnomisches Armeemesser"
L["Primordial Saronite"] = "Urt\195\188mliches Saronit"
--L["Brazie's Gnomish Pleasure Device"] = false -- never seen on deDE Servers yet, wonder if it ever gets there..
L["Summons and dismisses a rideable"] = "Beschw\195\182rt einen reitbaren"
L["Nurtured Penguin Egg"] = "Bebr\195\188tetes Pinguinei" 
L["Truesilver Shafted Arrow"] = "Echtsilberschaftpfeil" 
L["Kirin Tor Familiar"] = "Familiar der Kirin Tor"
L["Unhatched Mr. Chilly"] = "Ungeschl\195\188pfter Herr Fr\195\182stelich"
L["Frosty's Collar"] = "Frostis Halsband"
L["Perpetual Purple Firework"] = "Unersch\195\182pfliches lila Feuerwerk"
L["Carved Ogre Idol"] = "Geschnitzter Ogerg\195\182tze"
L["The Flag of Ownership"] = "Die Siegesflagge" 
