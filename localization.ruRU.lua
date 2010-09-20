-- $Id: localization.ruRU.lua 340 2009-11-14 12:33:14Z by Brialius(260) and dRonix(340)$

-- Russian translation for 260 maintained by Brialius <denis.bel@gmail.com>.
-- Russian translation for 340 made by dRonix <dronixster@gmail.com>.
-- Correction of errors and inaccuracies made by dRonix <dronixster@gmail.com> and StingerSoft.

-- localization files should be edited with a utf-8
-- compatable editor and done so with utf-8 encoding.

-- See localization.template.lua to start a new translation.

if GetLocale() ~= "ruRU" then return end

TBag.LOCALES.ruRU = {}
TBag.LOCALES.current = TBag.LOCALES.ruRU
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

L["Armor"] = "Доспехи"
L["Consumable"] = "Расходуемые"
L["Container"] = "Сумки"
L["Miscellaneous"] = MISCELLANEOUS
L["Projectile"] = "Боеприпасы"
L["Quest"] = "Задания"
L["Quiver"] = "Амуниция"
L["Reagent"] = "Реагенты"
L["Recipe"] = "Рецепты"
L["Trade Goods"] = "Хозяйственные товары"
L["Weapon"] = "Оружие"
L["Key"] = "Ключи"
L["Elemental"] = "Стихии"
L["Glyph"] = "Символы"

-- Sub types
L["Junk"] = "Хлам"
L["Explosives"] = "Взрывчатка"
L["Devices"] = "Устройства"
L["Parts"] = "Детали"
L["Ammo Pouch"] = "Подсумок"
L["Soul Bag"] = "Сумка душ"
L["Engineering Bag"] = "Сумка инженера"
L["Gem Bag"] = "Сумка ювелира"
L["Herb Bag"] = "Сумка травника"
L["Mining Bag"] = "Шахтерская сумка"
L["Enchanting Bag"] = "Сумка зачаровывателя"
L["Leatherworking Bag"] = "Сумка кожевника"

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
L["Bank"] = "Банк"
L["Backpack"] = "Рюкзак"
L["First Bag"] = "Первая сумка"
L["Second Bag"] = "Вторая сумка"
L["Third Bag"] = "Третья сумка"
L["Fourth Bag"] = "Четвертая сумка"
L["First Bank Bag"] = "Первая сумка банка"
L["Second Bank Bag"] = "Вторая сумка банка"
L["Third Bank Bag"] = "Третья сумка банка"
L["Fourth Bank Bag"] = "Четвертая сумка банка"
L["Fifth Bank Bag"] = "Пятая сумка банка"
L["Sixth Bank Bag"] = "Первая сумка банка"
L["Seventh Bank Bag"] = "Седьмая сумка банка"
L["Empty Slot"] = "Пустая ячейка"

-----------------------------------------------------------------------
-- CATEGORIES
-----------------------------------------------------------------------

-- Templates that are used to create a number of categories.
L["EMPTY_%s_SLOTS"] = "ПУСТАЯ_%s_ЯЧЕЙКА"
L["IN_%s_BAG"] = "В_%s_СУМКЕ"
L["%s_CREATED"] = "%s_СОЗДАНО"
L["SOULBOUND_%s"] = "ИМЕННОЕ_%s"
L["ACCOUNTBOUND_%s"] = "УЧЁТНАЯЗАПИСЬ_%s"
L["EQUIPPED_%s"] = "НА_ПЕРСОНАЖЕ_%s"
L["%s_TOOL"] = "%s_ИНСТРУМЕНТ"
L["%s_REAGENT"] = "%s_РЕАГЕНТ"

-- Broad categories for item types
L["PROJECTILE"] = "БОЕПРИПАСЫ"
L["SOULSHARD"] = "ОСКОЛОК_ДУШИ"
L["CONSUMABLE"] = "РАСХОДУЕМЫЕ"
L["ACT_ON"] = "ДЕЙСТВИЕ_НА"
L["ACT_OPEN"] = "ДЕЙСТВИЕ_ОКРЫТЬ"
L["ACT_SELL"] = "ДЕЙСТВИЕ_ПРОДАЖА"
L["BAG"] = "СУМКА"
L["GRAY_ITEMS"] = "СЕРЫЕ_ВЕЩИ"
L["QUEST"] = "ЗАДАНИЯ"
L["KEY_QUEST"] = "КЛЮЧИ_ЗАДАНИЙ"
L["KEY_OPEN"] = "КЛЮЧИ_ОКРЫТЬ"
L["ENCHANTS"] = "НАЛОЖЕНИЯ_ЧАР"
L["GLYPHS"] = "СИМВОЛЫ"
L["BOOK"] = "КНИГИ"
L["DESIGN"] = "ПРОЕКТЫ"
L["FORMULA"] = "ФОРМУЛЫ"
L["RECIPE"] = "РЕЦЕПТЫ"
L["PATTERN"] = "ЧАСТИ"
L["PLANS"] = "ЧЕРТЕЖЫ"
L["SCHEMATIC"] = "СХЕМЫ"
L["RECIPE_OTHER"] = "РЕЦЕПТЫ_ДРУГОЕ"
L["PVP"] = "PVP"
L["REAGENT"] = "РЕАГЕНТЫ"
L["TRADE_GOODS"] = "ХОЗЯЙСТВЕННЫЕ_ТОВАРЫ"
L["CLOTH"] = "ТКАНЬ"
L["MINIPET"] = "МИНИСПУТНИКИ"
L["COMBATPETS"] = "ЗАЩИТНИКИ"
L["COSTUMES"] = "КОСТЮМЫ"
L["FIREWORKS"] = "ФЕЕРВЕРКИ"
L["TOYS"] = "ИГРУШКИ"
L["MOUNT"] = "ЕЗДОВЫЕ_ЖИВОТНЫЕ"
L["FOOD"] = "ЕДА"
L["FOOD_BUFF"] = "ЕДА_С_БАФФАМИ"
L["DRINK"] = "ВОДА"
L["COMBO"] = "СМЕШАНО"
L["BUFF"] = "БАФФЫ"
L["DUMMY"] = "КУКЛЫ"
L["BANDAGE"] = "БИНТЫ"
L["HEALTH_RESTORE"] = "ВОССТАНОВЛЕНИЕ_ЗДОРОВЬЯ"
L["HEALTHSTONE"] = "КАМЕНЬ_ЗДРОВЬЯ"
L["MANA_RESTORE"] = "ВОССТАНОВЛЕНИЕ_МАНЫ"
L["COMBO_RESTORE"] = "ВОССТАНОВЛЕНИЕ_ПРИЕМОВ_СЕРИИ"
L["RAGE_RESTORE"] = "ВОССТАНОВЛЕНИЕ_ЯРОСТИ"
L["ENERGY_RESTORE"] = "ВОССТАНОВЛЕНИЕ_ЭНЕРГИИ"
L["CURE"] = "ЛЕЧЕНИЕ"
L["EXPLOSIVES"] = "ВЗРЫВЧАТКА"
L["HEARTH"] = "ЗДОРОВЬЕ"
L["MISC"] = "РАЗНОЕ"
L["UNKNOWN"] = "НЕИЗВЕСТНО"

-- Faction and Collectable Categories.
L["THORIUM_BROTHER"] = "БРАТСТВО_ТОРИЯ"
L["TIMBERMAW"] = "ДРЕВОБРЮХИ"
L["CENARION_EXPEDITION"] = "КЕНЕРАЙСКАЯ_ЭКСПЕДИЦИЯ"
L["SPOREGGAR"] = "СПОРЕГГАР"
L["ARGENT_DAWN"] = "СЕРЕБРЯНЫЙ_РАССВЕТ"
L["ALDOR"] = "АЛДОРЫ"
L["SCRYER"] = "ПРОВИДЦЫ"
L["SHA'TAR"] = "ША'ТАР"
L["LOWER_CITY"] = "НИЖНИЙ_ГОРОД"
L["AHN_QIRAJ"] = "АН'КИРАЖ"
L["CENARION_CIRCLE"] = "КРУГ_КЕНАРИЯ"
L["NETHERWING"] = "КРЫЛЬЯ_ПУСТОТЫ"
L["BLACKWING_LAIR"] = "ЛОГОВО_КРЫЛА_ТЬМЫ"
L["DARKMOON_FAIRE"] = "ЯРМАРКА_НОВОЛУНИЯ"
L["OGRI'LA"] = "ОГРИ'ЛА"
L["MOLTEN_CORE"] = "ОГНЕННЫЕ_НЕДРА"
L["ZUL_GURUB"] = "ЗУЛ'ГУРУБ"
L["CONSORTIUM"] = "КОНСОРЦИУМ"
L["HALAA"] = "ХАЛАА"

-- Tradeskill categories
L["TRADE1"] = "ТОРГОВЛЯ1"
L["TRADE2"] = "ТОРГОВЛЯ2"
L["ALCHEMY"] = "АЛХИМИЯ"
L["BLACKSMITHING"] = "КУЗНЕЧНОЕ_ДЕЛО"
L["ENCHANTING"] = "НАЛОЖЕНИЕ_ЧАР"
L["ENGINEERING"] = "ИНЖЕНЕРНОЕ_ДЕЛО"
L["JEWELCRAFTING"] = "ЮВЕЛИРНОЕ_ДЕЛО"
L["LEATHERWORKING"] = "КОЖНИЧЕСТВО"
L["MINING"] = "ГОРНОЕ_ДЕЛО"
L["POISONS"] = "ЯДЫ"
L["TAILORING"] = "ПОРТЯЖНОЕ_ДЕЛО"
L["INSCRIPTION"] = "НАЧЕРТАНИЕ"
L["FIRST_AID"] = "ПЕРВАЯ_ПОМОЩЬ"
L["COOKING"] = "КУЛИНАРИЯ"
L["FISHING"] = "РЫБНАЯ_ЛОВЛЯ"
L["RUNEFORGING"] = "ГРАВИРОВАНИЕ"
L["TRADE_TOOL"] = "ТОРГ_ИНСТРУМЕНТ"

-- Item slot categories
-- Note the categories with numbers in them must sort in the same order
-- per the standard lua sort.  Numbering like this is probably needed
-- for all languages to preserve the sort order.
L["01_HEAD"] = "01_ГОЛОВА"
L["02_NECK"] = "02_ШЕЯ"
L["03_SHOULDER"] = "03_ПЛЕЧО"
L["04_BACK"] = "04_СПИНА"
L["05_CHEST"] = "05_ГРУДЬ"
L["06_SHIRT"] = "06_РУБАШКА"
L["07_TABARD"] = "07_ГЕРБОВАЯ_НАКИДКА"
L["08_WRIST"] = "08_ЗАПЯСТЬЯ"
L["09_HANDS"] = "09_КИСТИ_РУК"
L["10_WAIST"] = "10_ПОЯС"
L["11_LEGS"] = "11_НОГИ"
L["12_FEET"] = "12_СТУПНИ"
L["13_OFFHAND"] = "13_ЛЕВАЯ_РУКА"
L["RELIC"] = "РЕЛИКВИЯ"
L["RING"] = "ПАЛЕЦ"
L["TRINKET"] = "АКСЕССУАР"
L["ARMOR"] = "ДОСПЕХИ"
L["WEAPON"] = "ОРУЖИЕ"
L["OTHER"] = "ДРУГОЕ"
 
-- Class Categories
L["DRUID"] = "ДРУИД"
L["WARLOCK"] = "ЧЕРНОКНИЖНИК"
L["ROGUE"] = "РАЗБОЙНИК"
L["MAGE"] = "МАГ"
L["PALADIN"] = "ПАЛАДИН"
L["PRIEST"] = "ЖРЕЦ"
L["SHAMAN"] = "ШАМАН"
L["WARRIOR"] = "ВОИН"
L["HUNTER"] = "ОХОТНИК"
L["DEATHKNIGHT"] = "РЫЦАРЬ_СМЕРТИ"
L["CLASS_TOOL"] = "КЛАССОВАЯ_ВЕЩЬ"
L["CLASS_REAGENT"] = "КЛАССОВЫЙ_РЕАГЕНТ"
  
-- Short bag type names used for EMPTY_%s_SLOTS and IN_%s_BAG categories
-- 3-4 characters is about right for these.
L["QUIV"] = "АМУН"
L["AMMO"] = "БОЕП"
L["SOUL"] = "ОСК"
L["ENG"] = "ИНЖ"
L["GEM"] = "ЮВЛ"
L["HERB"] = "ТРАВ"
L["MINE"] = "ГОРН"
L["ENCH"] = "НАЛЖ"
L["LTHR"] = "КОЖВ"
L["PET"] = "ПИТ"
L["INSC"] = "НАЧР"

-- Bag Position Names, also used for EMPTY_%s_SLOTS and IN_%s_BAG categories
L["KEYRING"] = "КЛЮЧИ"
L["BANK"] = "БАНК"
L["BACKPACK"] = "РЮКЗАК"
L["BAG1"] = "СУМКА1"
L["BAG2"] = "СУМКА2"
L["BAG3"] = "СУМКА3"
L["BAG4"] = "СУМКА4"
L["BBAG1"] = "БСУМКА1"
L["BBAG2"] = "БСУМКА2"
L["BBAG3"] = "БСУМКА3"
L["BBAG4"] = "БСУМКА4"
L["BBAG5"] = "БСУМКА5"
L["BBAG6"] = "БСУМКА6"
L["BBAG7"] = "БСУМКА7"
  
-- Keywords
L["SOULBOUND"] = "ПЕРСОНАЛЬНЫЙ ПРЕДМЕТ"
L["ACCOUNTBOUND"] = "СВЯЗАН С УЧЕТНОЙ ЗАПИСЬЮ"
L["EQUIPPED"] = "НА ПЕРСОНАЖЕ"

-----------------------------------------------------------------------
-- CHAT STRINGS
-----------------------------------------------------------------------

L["%sSetting keybind to %q"] = "%sНазначить клавишу для %q"
L["Unassigned category %s has been assigned to slot 1"] = "Нераспределенная категория %s была назначена на 1 слот" 
L["Character data cached for:"] = "Данные персонажа помещены в кэш:"
L["Removed cache for %q"] = "Кеш удалён для %q"
L["Couldn't find and remove cache for %q"] = "Не удалось найти и удалить кэш для %q"       
-----------------------------------------------------------------------
-- SEARCH OUTPUT STRINGS 
-----------------------------------------------------------------------
L["Search results for %q:"] = "Поиск результата для %q:"
L["No results|r for %q"] = "Нет результат для|r %q"
L[" found:"] = " найдено:"
L["bags"] = "сумки"
L["bank"] = "банк"
L["container"] = "контейнер"
L["body"] = "тело"
L["mail"] = "почта"
L["tokens"] = "знаки"
L[" in %s's %s"] = " в %s %s" -- Used when an item is found in a characters bag or bank
L[" on %s's %s"] = " на %s %s" -- Used when an item is found on a characters body
L[" as %s's %s"] = " как %s %s" -- Used when an item is used as a container for a character

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
L["(Use: Returns you to )([^%.]*)(%.)"] = "(Использование: Возвращает вас в зону)([^%.]*)(%.)"
L["%%1%s%%3"] = "%%1%s%%3"

-- Generic name for the home location if we don't have it cached.
-- The tooltip should have something like this where in the text
-- where it describes how to change your bind point.  Brackets are
-- there to imply it's a placeholder.
L["<home location>"] = "<домашняя локация>"

-----------------------------------------------------------------------
-- CHARGES 
-----------------------------------------------------------------------
-- Pattern to get the charges from a tooltip
-- Probably only need to chage the Charges.
-- The ? after the s implies that the s may not be there
-- as would be the case in a single Charge.
L["(%d+) Charges?"] = "(%d+) зарядов?"
-- Format string for adding the charges tooltip.
-- %d is the number of charges.  |4 specifies this
-- is a plural/singular pair.  Up until the : is the
-- singular form after is the plural until the ;.
L["%d |4Charge:Charges;"] = "%d |4заряд:заряда:зарядов;"

-----------------------------------------------------------------------
-- BINDING STRINGS 
-----------------------------------------------------------------------
L["Toggle Bank Window"] = "Показать окно банка"
L["Toggle Inventory Window"] = "Показывает инвентарь в окне"
  
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
L["TBnk Commands:"] = "TBnk команды сумок банка"
L[" /tbnk show  -- open window"] = " /tbnk show -- открыть окно"
L[" /tbnk hide  -- hide window"] = " /tbnk hide -- скрыть окно"
L[" /tbnk update  -- refresh the window"] = " /tbnk update -- обновить окно"
L[" /tbnk config  -- configuration options"] = " /tbnk config -- настройки"
L[" /tbnk debug  -- turn debug info on/off"] = " /tbnk debug -- показывать информацию отладки вкл\выкл"
L[" /tbnk reset  -- sets everything back to default values"] = " /tbnk reset -- сбросить всё настройки(по-умолчанию)"
L[" /tbnk resetpos -- put the bank back to its default position"] = " /tbnk resetpos -- сбросить позицию сумок банка"
L[" /tbnk resetsorts -- clears the item search list"] = " /tbnk resetsorts -- очистить поиск(сбросить сортировку)"
L[" /tbnk printchars -- prints a list of all the chars with cached info"] = " /tbnk printchars -- вывести всю информаццию других персонажей из кеша"
L[" /tbnk deletechar CHAR SERVER -- clears all cached info for character "] = " /tbnk deletechar ПЕРСОНАЖ СЕРВЕР -- удалить данные об персонаже"

-- /tinv help text
L["TInv Commands:"] = "TInv команды сумок(не банка)"
L[" /tinv show  -- open window"] = " /tbnv show -- открыть окно"
L[" /tinv hide  -- hide window"] = " /tinv hide -- скрыть окно"
L[" /tinv update  -- refresh the window"] = " /tinv update -- обновить окно"
L[" /tinv config  -- configuration options"] = " /tinv config -- настройки"
L[" /tinv debug  -- turn debug info on/off"] = " /tinv debug -- показывать информацию отладки вкл\выкл"
L[" /tinv reset  -- sets everything back to default values"] = " /tinv reset -- сбросить всё настройки(по-умолчанию)"
L[" /tinv resetpos -- put the inventory window back to its default position"] = " /tinv resetpos - сбросить позицию окна сумок"
L[" /tinv resetsorts -- clears the item search list"] = " /tinv resetsorts -- очистить поиск(сбросить сортировку)"
L[" /tinv printchars -- prints a list of all the chars with cached info"] = " /tinv printchars -- вывести всю информаццию других персонажей из кеша"
L[" /tinv deletechar CHAR SERVER -- clears all cached info for character "] = " /tinv deletechar ПЕРСОНАЖ СЕРВЕР -- удалить данные об персонаже"

-----------------------------------------------------------------------
-- WINDOW STRINGS
-----------------------------------------------------------------------
L["TBag v%s"] = "TBag v%s"

L["Normal"] = "Нормальный вид"
L["Stop highlighting new items."] = "Остановить перемещение на первый план новых вещей"
L["Highlight New"] = "Выделить новые"
L["Highlight items marked as new."] = "Выделить вещи, помеченные, как новые"
L["Clear Search"] = "Очистить поиск"
L["Stop highlighting search results."] = "Не выделять результаты поиска"

L["Toggle Edit Mode"] = "Переключить режим редактирования"
L["Select this option to move classes of items into different 'bars' (the red numbers)."] = "Выберите эту опцию, чтобы переместить классы предметов в различные бары (красные номера)"

L["Reload and Sort"] = "Перегрузить и отсортировать"
L["Reloads your items and sorts them."] = "Перегрузить ваши вещи и отсортировать их"

L["Toggle Bank"] = "Показать/спрятать банк"
L["Displays bank contents in a view-only mode.  You may select another player's bank to view from the dropdown."] = "Показывает банк игрока в режиме просмотра. Вы также можете выбрать для просмотра банк другого персонажа."

L["Toggle Purchase Info"] = "Показать информацию о покупках"
L["Displays the purchase button and cost to buy a new bank slot.  This is disabled in read-only views and edit mode."] = "Показывает на экране сколько будет стоить новый слот в банке. Это отключено в режиме чтения и при редактировании сумок."

L["Unlock Window"] = "Разблокировать окно"
L["Allow window to be moved by dragging it."] = "Позволяет перемещать окно"
L["Lock Window"] = "Закрепить окно"
L["Prevent window from being moved by dragging it."] = "Запрещает перемещать окно"
  
L["<++>"] = "<++>"
L["Increase Window Size"] = "Увеличение размера окна"
L["Increase the number of columns displayed"] = "Увеличение количества отображаемых столбцов"

L[">--<"] = ">--<"
L["Decrease Window Size"] = "Уменьшение размера окна"
L["Decrease the number of columns displayed"] = "Уменьшение количества отображаемых столбцов"

L["Reset"] = "Сброс"
L["Close"] = "Закрыть"
L["Add New Cat"] = "Новая категория"
L["Assign Cats"] = "Назначить категорию"
L["No"] = "Нет"
L["Yes"] = "Да"
L["Category"] = "Категории"
L["Keywords"] = "Ключевые слова"
L["Tooltip Search"] = "Поиск"
L["Type"] = "Тип"
L["SubType"] = "Подтип"
  
-- Menus and Tooltips
L["Main Background Color"] = "Основной цвет фона"
L["Main Border Color"] = "Основной цвет границы"
L["Set Bar Colors to Main Colors"] = "Выбрать цвет панели к основному цвету"
L["Spotlight for %s"] = "Выделение для %s"
L["Current Category: %s"] = "Текущая категория: %s"
L["Assign item to category:"] = "Назначить предмет для категории:"
L["Use default category assignment"] = "Назначить категории используемые по умолчанию"
L["Debug Info: "] = "Информация отладки: "
L["Categories within bar %d"] = "Категории в пределах панели %d"
L["Move: |c%s%s|r"] = "Двигать: |c%s%s|r"
L["Sort Mode:"] = "Режим сортировки:"
L["No sort"] = "Не сортировать"
L["Sort by name"] = "Сортировать по имени"
L["Sort last words first"] = "Сортировать по последним словам"
L["Highlight new items:"] = "Выделять новые предметы"
L["Don't tag new items"] = "Не помечать новые предметы"
L["Tag new items"] = "Помечать новые предметы"
L["Hide Bar:"] = "Скрыть панель"
L["Show items assigned to this bar"] = "Показать предметы, назначенные в эту панель"
L["Hide items assigned to this bar"] = "Скрыть предметы, назначенные в эту панель"
L["Color:"] = "Цвет:"
L["Background Color for Bar %d"] = "Цвет Фона для панели %d"
L["Border Color for Bar %d"] = "Цвет границы для панелиа %d"
L["Select Character"] = "Выбрать персонажа"
L["Edit Mode"] = "Режим редактирования"
L["Lock window"] = "Закрепить окно"
L["Show Purchase Info"] = "Показать информацию о покупке"
L["Close Inventory"] = "Закрыть Инвертарь"
L["Highlight New Items"] = "Выделить новые предметы"
L["Reset NEW tag"] = "Сбросить пометку НОВЫЕ"
L["Advanced Configuration"] = "Расширенная настройка"
L["Set Size"] = "Указать размер"
L["Set Colors"] = "Указать цвет"
L["Hide"] = "Скрыть"
L["Hide Player Dropdown"] = "Скрыть окно выбора персонажей"
L["Hide Search Box"] = "Скрыть окно поиска"
L["Hide Re-sort Button"] = "Скрыть кнопку пересортировки"
L["Hide Bank Button"] = "Скрыть кнопку банка"
L["Hide Show Purchase Button"] = "Скрыть показа информации о покупке"
L["Hide Edit Button"] = "Скрыть кнопку редактирования"
L["Hide Highlight Button"] = "Скрыть кнопку выделения"
L["Hide Lock Button"] = "Скрыть кнопку закрепления"
L["Hide Close Button"] = "Скрыть кнопку закрытия"
L["Hide Total"] = "Скрыть всё"
L["Hide Bag Buttons"] = "Скрыть кнопки сумок"
L["Hide Money"] = "Скрыть деньги"
L["Hide Tokens"] = "Скрыть символы"
L["The Bank"] = "Банк"
L["|c%sLeft click to move category |r|c%s%s|r|c%s to bar |r|c%s%s|r"] = "|c%sЛевый клик для перемещения категории |r|c%s%s|r|c%s панели |r|c%s%s|r"
L["|c%sBar |r|c%s%s|r"] = "|c%sПанель |r|c%s%s|r"
L["|c%s%s|r"] = "|c%s%s|r"
L["Right click for options"] = "Правый клик для опций"
L["|c%sLeft click to select category to move:|r |c%s%s|r"] = "|c%sЛевый клик для выбора категории, для перемещения:|r |c%s%s|r"
L["Right click to assign this item to a different category"] = "Правый клик для определения данного предмета в другую категорию"
L["You are viewing the selected player's bank."] = "Вы просматриваете банк выделенного персонажа"
L["You are viewing the selected player's inventory."] = "Вы просматриваете инвентарь выделенного персонажа."
L["Equip Container"] = "Одетые сумки"
L["Anchor"] = "Якорь"
L["TOPLEFT"] = "ВЕРХВЛЕВО"
L["TOPRIGHT"] = "ВЕРХВПРАВО"
L["BOTTOMLEFT"] = "НИЗВЛЕВО"
L["BOTTOMRIGHT"] = "НИЗВПРАВО"
L["Show on TBag"] = "Показать в TBag"
L["Checking this option will allow you to track this currency type in TBag for this character.\n\nYou can also Shift-click a currency to add or remove it from being tracked in TBag."] = "Выбрав этот вариант,вы позволите отслеживать этот тип валюты в TBag для этого персонажа.\n\n Также вы можете использовать комбинацию Shift-Click, чтобы добавить или удалить отслеживание валюты в TBag."

-- Option Window Strings
L["Main Sizing Preferences"] = "Настройки размеров:"
L["Number of Item Columns:"] = "Количество колонок:"
L["Number of Horizontal Bars:"] = "Количество горизонтальных баров:"
L["Window Scale:"] = "Масштаб окна:"
L["Item Button Size:"] = "Размер ячеек:"
L["Item Button Padding:"] = "Отступ в ячейке:"
L["Spacing - X Button:"] = "Отступ по X между ячейками:"
L["Spacing - Y Button:"] = "Отступ по Y между ячейками:"
L["Spacing - X Pool:"] = "Отступ по X между областями:"
L["Spacing - Y Pool:"] = "Отступ по Y между областями:"
L["Count Font Size:"] = "Размер шрифта:"
L["Count Placement - X:"] = "Ячеек по Х:"
L["Count Placement - Y:"] = "Ячеек по Y:"
L["New Tag Font Size:"] = "Размер шрифта меток:"
L["Bag Contents Show"] = "Показать содержимое сумки"
L["Show %s:"] = "Показать %s:"
L["General Display Preferences"] = "Главные настройки отображения"
L["Show Size on Bag Count:"] = "Показать размер на сумках"
L["Show Bag Icons on Empty Slots:"] = "Показать иконку сумки в пустых ячейках:"
L["Spotlight Open or Selected Bags:"] = "Подсвечивает открытие или выбор сумок"
L["Spotlight Mouseover:"] = "Подсвечивает Указатель"
L["Show Item Rarity Color:"] = "Окраска редких предметов:"
L["Auto Stack:"] = "Авто пачки"
L["Stack on Re-sort:"] = "Упаковывать в пачки при пересортировке"
L["Profession Bags precede Sorting:"] = "Проффесиональные сумки предшествуют Сортировке:"
L["Trade Creation precedes Sorting (Reopen Window):"] = "Создание торговли предшествует сортировке(Откройте Заново Окно):"
L["New Tag Options"] = "Новые варианты Показа"
L["New Tag Text:"] = "Новые варианты Текста:"
L["Increased Tag Text:"] = "Увеличенный текст:"
L["Decreased Tag Text:"] = "Уменьшенный текст:"
L["New Tag Timeout (minutes):"] = "Время нового варианта (минуты):"
L["Recent Tag Timeout (minutes):"] = "Последнее время вараинта (минуты):"
L["Alt Key Auto-Pickup:"] = "Alt - автопогрузка:"
L["Alt Key Auto-Panel:"] = "Alt - автопанель:"
L["Show Keyring Empty Slots (Enable Show above):"] = "Показать свободные ячейки в повязке ключей (Включить, чтобы показать выше)"
L["Show Soul Shard Count On Soul Bags:"] = "Показать количество осколков душ в сумке душ:"

-----------------------------------------------------------------------
-- Unit Tests 
-----------------------------------------------------------------------
L["TEST RUN STARTING"] = "ТЕСТ НАЧАЛСЯ"
L[" Retrieving item information"] = " Восстановление информации предмета"
L["SUCCESS: %s"] = "УСПЕШНО: %s"
L["FAIL: %s (%s) expected %q but got %q"] = "НЕУДАЧНО: %s (%s) ожидал %q но получил %q"
L["ALL TESTS SUCCESSFUL"] = "ВСЕ ТЕСТЫ ПРОЙДЕНЫ УСПЕШНО"

-----------------------------------------------------------------------
-- Default Search List Strings 
-----------------------------------------------------------------------
L["This Item Begins a Quest"] = ITEM_STARTS_QUEST
L["<Right Click to Open>"] = ITEM_OPENABLE
L[" Lockbox"] = "[Сc]ейф"
L["Mark of Honor Hold"] = "Почетный знак Оплота Чести"
L["Mark of Thrallmar"] = "Печать Траллмара"
L["Halaa Battle Token"] = "Боевой знак Халаа"
L["Spirit Shard"] = "Осколок души"
L["Use: Permanently"] = "Использование: Наложение"
L["Hearthstone%s"] = "Камень возвращения%s"
L["Right Click to summon and dismiss"] = "Использование: Призыв и освобождение"
L["Summons or dismisses a Spirit of"] = "Позволяет призывать и отпускать Дух"
L["Use: Teaches you how to summon this companion."] = "Использование: Учит призывать этого спутника."
L["Requires Riding %("] = "Верховая езда %("
L["%a+ Scarab"] = "%a+ [Сс]карабей"
L["%a+ Idol"] = "%a+ [Ии]дол"
L["Qiraji %a+ %a+"] = "Киражск[ии][ий] %a+ %a+"
L["Bone Fragments"] = "Обломки костей"
L["Core of Elements"] = "Средоточие стихий"
L["Crypt Fiend Parts"] = "Конечности и панцири некрорахнидов"
L["Dark Iron Scraps"] = "Пластины из темного железа"
L["Savage Frond"] = "Дикий росток"
L["Insignia of the Crusade"] = "Значок Алого ордена"
L["Insignia of the Dawn"] = "Значок Серебряного Рассвета"
L["Argent Dawn Valor Token"] = "Знак доблести Серебряного Рассвета"
L["Mantle of the Dawn"] = "мантия Рассвета"
L["Vitreous Focuser"] = "Стеклянный прибор для фокусировки"
L["Osseous Agitator"] = "Костяной катализатор"
L["Somatic Intensifier"] = "Соматический усилитель"
L["Ectoplasmic Resonator"] = "Эктоплазматический резонатор"
L["Arcane Quickener"] = "Чародейский ускоритель"
L[" Scourgestone"] = "Камень Плети "
L["Cenarion %a+ Badge"] = "Кенарийский знак %a+"
L["Twilight Text"] = "Сумеречный текст"
L["Twilight Cultist"] = "%a+ сумеречного заклинателя"
L["Abyssal Crest"] = "Талисманы Бездны"
L["Abyssal Signet"] = "Перстень Бездны"
L["Abyssal Scepter"] = "Скипетр Бездны"
L["Darkmoon Faire Prize Ticket"] = "Подарочный купон ярмарки Новолуния"
L["Soft Bushy Tail"] = "Мягкий пушистый хвост"
L["Vibrant Plume"] = "Радужное перо"
L["Small Furry Paw"] = "Маленькая мохнатая лапка"
L["Evil Bat Eye"] = "Глаз злобной летучей мыши"
L["Torn Bear Pelt"] = "Разорванная шкура медведя"
L["Glowing Scorpid Blood"] = "Светящаяся кровь скорпида"
L["Property of the Darkmoon Faire."] = "Собственность ярмарки Новолуния"
L["Combine the %a+ through %a+ of %a+ to complete the set."] = "Объединить %а+ до %а+ из %а+ до полного набора."
L["Incendosaur Scale"] = "Чешуя пламезавра"
L["Dark Iron Residue"] = "Окалина черного железа"
L["Deadwood Headdress Feather"] = "Перо из головного убора Мертвого Леса"
L["Winterfall Spirit Beads"] = "Бусины духов Зимнего Сна"
L["Zandalar Honor Token"] = "Почетный знак Зандалара"
L["%a+ Coin"] = "Монета %a+"
L["%a+ Bijou"] = "%a+ брелок хаккари"
L["Primal Hakkari"] = "Изначальный %a+ хаккари"
L["Apexis Crystal"] = "Апекситовый осколок"
L["to create a dragonscale cloak"] = "плащ из драконьей чешуи"
L["Darkrune"] = "Темная руна"
L["Netherwing Egg"] = "Яйцо дракона из стаи Крыльев Пустоты"
L["Nethercite Ore"] = "Хаотитовая руда"
L["Netherdust Pollen"] = "Пыльца хаотического пыльника"
L["Netherwing Crystal"] = "Кристалл Крыла Хаоса"
L["Nethermine Cargo"] = "Груз копей Хаоса"
L["Unidentified Plant Parts"] = "Неопознанные части растений"
L["Coilfang Armaments"] = "Оружие Змеиного Зуба"
L["Mature Spore Sac"] = "Мешочек зрелых спор"
L["Bog Lord Tendril"] = "Усик болотника"
L["Glowcap"] = "Огнешляпка"
L["Fertile Spores"] = "Прорастающие споры"
L["Sanguine Hibiscus"] = "Кровавый гибискус"
L["Obsidian Warbeads"] = "Обсидиановое боевое ожерелье"
L["Oshu'gun Crystal Fragment"] = "Осколок кристалла Ошу'гуна"
L["Pair of Ivory Tusks"] = "Пара бивней"
L["Zaxxis Insignia"] = "Знак отличия братства Заксис"
L["Ethereum Prisoner I%.D%. Tag"] = "Идентификационная табличка пленника Эфириума"
L["Ethereum Prison Key"] = "Ключ от тюрьмы братства Астрала"
L["Halaa Research Token"] = "Изыскательский знак Халаа"
L["Oshu'gun Crystal Powder Sample"] = "Образец порошка кристалла Ошу'гуна"
L["Dampscale Basilisk Eye"] = "Глаз гладкоспинного василиска"
L["Firewing Signet"] = "Перстень Огнекрылов"
L["Sunfury Signet"] = "Перстень Ярости Солнца"
L["Arcane Tome"] = "Чародейский фолиант"
L["Arcane Rune"] = "Arcane Rune"
L["Dreadfang Venom Sac"] = "Ядовитая железа Смертеплета"
L["Mark of Kil'jaeden"] = "Знак Кил'джедена"
L["Mark of Sargeras"] = "Знак Саргераса"
L["Fel Armament"] = "Латные перчатки Скверны"
L["Holy Dust"] = "Святая пыль"
L["Mark of the Illidari"] = "Знак Иллидари"
L["Badge of Justice"] = "Знак справедливости"
L["Arakkoa Feather"] = "Перо араккоа"
L["Quest Item"] = ITEM_BIND_QUEST
L["Morbent"] = "Морбента"
L["Codex: "] = "Кодекс: "
L["Manual: "] = "Учебник: "
L["Expert "] = "[Уу]мел[ье]ц.*"
L["Tome of "] = "Фолиант "
L["Design: "] = "Эскиз: "
L["Formula: "] = "Формула: "
L["Recipe: "] = "Рецепт: "
L["Pattern: "] = "Выкройка: "
L["Plans: "] = "Чертеж: "
L["Schematic: "] = "Схема: "
L["[Ss]kinning [Kk]nife"] = "Нож для снятия шкур"
L["[Mm]ining [Pp]ick"] = "Шахтерская кирка"
L["[Bb]lacksmith [Hh]ammer"] = "Кузнечный молот"
L["Runed %a+ Rod"] = "Рунный %a+ жезл"
L["Philosopher's Stone"] = "Философский камень"
L["Salt Shaker"] = "Солонка"
L["Arclight Spanner"] = "Тангенциальный вращатель"
L["Gyromatic Micro%-Adjustor"] = "Шлицевой гироинструмент"
L["Zulian Slicer"] = "Зулианский тесак"
L["Finkle's Skinner"] = "Живодер Финкля"
L["Blood Scythe"] = "Кровокос"
L["Herbalist's Gloves"] = "Перчатки травника"
L["Dwarven Fishing Pole"] = " Дворфийская удочка"
L["Goblin Fishing Pole"] = "Гоблинская удочка"
L["Everlasting Underspore Frond"] = "Вечная Подспорная ветвь"
L["\nHead"] = "\nГолова"
L["\nNeck"] = "\nШея"
L["\nShoulder"] = "\nПлечо"
L["\nBack"] = "\nСпина"
L["\nChest"] = "\nГрудь"
L["\nShirt"] = "\nРубашка"
L["\nTabard"] = "\nГербовая накидка"
L["\nWrist"] = "\nЗапястья"
L["\nHands"] = "\nКисти рук"
L["\nWaist"] = "\nПояс"
L["\nLegs"] = "\nНоги"
L["\nFeet"] = "\nСтупни"
L["\nHeld In Off%-hand"] = "\nЛевая рука"
L[" Bandage"] = "[Бб]инты"
L["Instantly restores %d+ life"] = "Мгновенное восполнение %d+ ед. здоровья"
L[" well fed "] = " действия эффекта"
L["Restores %d+ health.* increases your "] = "Использование: Восполнение %d+ ед. здоровья за.*пов"
L["If you spend at least %d+ seconds eating you will"] = "Если Вы потратите по крайней мере %d + секунд еды, вы будете"
L["Must remain seated while drinking%."] = "Действие эффекта прерывается, если персонаж встает с места%."
L["Restores %d+ mana over %d+ sec"] = "Использование: Восполнение %d+ ед. маны за"
L["Restores %d+ health and %d+ mana over %d+ sec"] = "Восполнение %d+ ед. здоровья и %d+ ед. маны за %d+ сек"
L["Restores .* health and mana .* %d+ sec"] = "Восполнение %d+ ед. здоровья и маны за %d+ сек"
L["Must remain seated while eating%."] = "персонаж встает с места%."
L["Restores %d+ health over %d+ sec"] = "Использование: Восполнение %d+ ед. здоровья за"
L["Thistle Tea"] = "Артишоковый чай"
L["[Rr]estores %d+ energy"] = "[Вв]осполнение %d+ ед. энергии"
L["Rage Potion"] = "[Зз]елье ярости"
L["[Rr]estores %d+ rage"] = "Увеличения ярости на %d+"
L["Rejuvenation Potion"] = "[Зз]елье омоложения"
L["Dreamless Sleep"] = "[Зз]елье спокойного сна"
L["[Rr]estores %d+ to %d+ mana and health"] = "[Вв]осполняет %d+ ед. здоровья и %d+ ед. маны"
L["Mana Potion"] = "[Зз]елье маны"
L["[Rr]estores %d+ to %d+ mana"] = "Восполнение %d+% ?- ?%d+ ед. маны"
L["Healing Potion"] = "[Лл]ечебное зелье"
L["[Rr]estores %d+ to %d+ health"] = "Восполн.* %d+% ?- ?%d+ ед. здоровья"
L["Place a %a+ stone statue"] = "Поставить на %a+ тяжелую каменную статую"
L[" [Cc]ure.* poison"] = " снять.* яд"
L[" [Cc]ure.* disease"] = " снять.* болезнь"
L[" [Cc]ure.* curse"] = " снять.* проклятье"
L[" [Cc]ure.* magic"] = " снять.* заклинание"
L[" [Rr]emoves %d+ .*effect"] = "Предпринимает попытку снять.*"
L[" Dynamite"] = "[Дд]инамит"
L[" Bomb"] = "[Бб]омба"
L[" Mortar"] = "[мМ]иномет"
L["Scroll"] = "[Сс]виток"
L["Use: Increases "] = "Использование: Увелич[ениват]+ "
L["Use: Absorbs "] = "Использование: Поглащ[ениват]+ "
L["Use: Regenerate "] = "Использование: Восполнен[яениват]+ "
L["Use: While applied to target weapon"] = "Использование: При применении к выбранному оружию"
L[" Sharpening Stone"] = " Точило"
L[" Weightstone"] = "[Гг]рузик"
L["Mistletoe"] = "Омела"
L["Flame Cap"] = "Огнеголовик"
L["[AG][li][lv][oe]w?s the [Ii]mbiber "] = false
L[" Key"] = " Ключ"
L["Light Feather"] = "Легкое перышко"
L["Infernal Stone"] = "Камень инфернала"
L["Demonic Figurine"] = "Демоническая статуэтка"
L[" Seed"] = "[Сс]ем[ея].*"
L["Wild "] = "Дикий "
L["Arcane Powder"] = "Порошок чар"
L["Rune of "] = "Руна "
L["Symbol of"] = "Символ"
L[" Candle"] = "[Сс]веча"
L["Ankh"] = "Крест"
L["Fish Oil"] = "Рыбий жир"
L["Shiny Fish Scales"] = "Блестящая рыбья чешуя"
L["Thieves' Tools"] = "Отмычки"
L[" Totem"] = "[Тт]отем"
L["Soul Shard"] = "Осколок души"
L["Corpse Dust"] = "Прах"
L["Target Dummy"] = "[Мм]анекен%-мишень"
L["Elemental %a+"] = "Первородн.* %a+"
L["Essence of %a+"] = "Субстанция %a+"
L["Globe of Water"] = "Магическая сфера воды"
L["Breath of Wind"] = "Дыхание ветра"
L["Heart of Fire"] = "Сердце огня"
L["Core of Earth"] = "Ядро земли"
L["Mote of %a+"] = "Частица %a+"
L["Primal Nether"] = "Изначальная Пустота"
L["Primal %a+"] = "Изначальная %a+"
L["Void Crystal"] = "Кристалл Бездны"
L["Nether Vortex"] = "Воронка Пустоты"
L["Sunmote"] = "Солнечная пылинка"
L["Heart of Darkness"] = "Сердце тьмы"
L[" Vial"] = "[кК]олба"
L["[cC]loth"] = "[тТ]кань"
L["Coats a weapon with poison that lasts for"] = "Покрывает оружие ядом, действующим в течение"
L["Raw "] = "[Сс]ыр[ао][яйе] "
L["[Ff]ish"] = "[Рр]ыба"
L[" Meat"] = "[Мм]яс[ао]"
L["%a+ Dust"] = "%a+ пыль"
L["Lesser %a+ Essence"] = "Простая %a+ субстанция"
L["Greater %a+ Essence"] = "Великая %a+ субстанция"
L["Small %a+ Shard"] = "Малый %a+ осколок"
L["Large %a+ Shard"] = "Большой %a+ осколок"
L["Papa Hummel's Old%-Fashioned Pet Biscuit"] = "Старомодное лакомство для питомцев от Папаши Хюммеля"
L["Silver Shafted Arrow"] = "Стрела с серебряным древком"
L["Crashin' Thrashin'"] = "\"Бей-Молоти\""
L["Tonk Controller"] = "Пульт управления танком"
L["Mechanical Yeti"] = "Механический йети"
L["Orb of the Sin'dorei"] = "Сфера Син'Дорай"
L["Orb of the Blackwhelp"] = "Сфера темного дракончика"
L["Winter Veil Disguise Kit"] = "Набор для переодевания Зимнего Покрова"
L["Hallowed Wand %- "] = "Волшебная палочка %– "
L["Murloc Costume"] = "Костюм мурлока"
L["Weighted Jack%-o'%-Lantern"] = "Утяжеленный фонарь из тыквы"
L["Gordok Ogre Suit"] = "Броня огров Гордока"
L["Transforms your mount into something more festive"] = "Придание вашему ездовому животному более праздничного вида"
L["Your mount will be more festive"] = "Ваше ездовое животное будте более праздничного вида"
L["Shoots a.*firework"] = "Запуск фейерверка"
L["Place on the ground to launch .* rockets"] = "Разместите на земле для запуска .* фейерверков"
L["Throw into a .* launcher"] = "В пусковую установку ее!"
L["Brazier of Dancing Flames"] = "Жаровня танцующего пламени"
L["Direbrew's Remote"] = "Пульт управления Худовара"
L["Goblin Weather Machine %- Prototype 01%-B"] = "Гоблинская метеоустановка %- прототип 01%-B"
L["Use: Right Click to set up a .* picnic."] = "Использование: Щелкните правой кнопкой мыши, чтобы устроить .* пикник."
L["D\.I\.S\.C\.O\."] = "Т.А.Н.Э.Ц."
L["Imp in a Ball"] = "Бес в шаре"
L["Snowball"] = "Снежок"
L["Paper Flying Machine Kit"] = "Складной бумажный ветролет"
L["If they have free room in their pack they will catch it"] = "Если у того найдется свободное место в сумках, он ее поймает!"
L["Fishing Chair"] = "Стул рыболова"
L["Elune Stone"] = "Камень Элуны"
L["Shower a nearby target with a cascade of"] = "Ближайшую цель осыпает куча"
L["Path of Illidan"] = "Путь Иллидана"
L["Goblin Gumbo"] = "Гоблинское хлебово"
L["Toasting Goblet"] = "Кубок для тостов"
L["Summons a .* that will protect you for"] = "Призыв .*, защищающего вас в течение"
L["Creates a .* that will fight for you"] = "Создание .*, который будет сражаться на вашей стороне в течение"
L["Explosive Sheep"] = "Взрывоопасная овца"
L["Goblin Land Mine"] = "Гоблинская наземная мина"
L["Eye of Arachnida"] = "Глаз Арахниды"
L["Pet Leash"] = "поводок"
L["Fetch Ball"] = "Мячик для игры"
L["Happy Pet Snack"] = "Закуска \"Счастливый питомец\""
L["Paper Zeppelin Kit"] = "Набор бумажного дирижабля"
L["Titanium Seal of Dalaran"] = "Титановая печать Даларана"
L["Frozen Orb"] = "Ледяной шар"
L["Crystallized %a+"] = "Кристаллизованн[ыа][йя] %a+"
L["Eternal %a+"] = "Неугасимое %a+"
L["Virtuoso Inking Set"] = "Набор виртуозного начертателя"
L["Ink"] = "[Чч]ернила"
L[" Parchment"] = "[Пп]ергамент"
L[" Pigment"] = "[Кк]раситель"
L["Grindgear Toy Gorilla"] = "Игрушечная заводная горилла"
L["Copper Racer"] = "медный болид"
L["Toy Train Set"] = "Игрушечная железная дорога"
L["Engineer's Ink"] = "Инженерный краситель"
L["Rickety Magic Broom"] = "Хлипкая волшебная метла"
L["Iron Boot Flask"] = "Железная походная фляга"
L["Zapthrottle Mote Extractor"] = "Удаленный конденсатор выхлопов"
L["Wand of Holiday Cheer"] = "Жезл праздничного веселья"
L["Rolls a pair of dice"] = "Бросок пары игральных костей"
L["Blessed Medallion of Karabor"] = "Благословенный медальон Карабора"
L["Frenzyheart Brew"] = "Варево Бешеного Сердца"
L["Tiny %a+ Ragdoll"] = "Маленькая %a+ тряпичная кукла"
L["Festival Firecracker"] = "Праздничная хлопушка"
L["Elder's Moonstone"] = "Лунный камень предков"
L["Wind%-Up Train Wrecker"] = "Зводной крушитель поездов"
L["Sandbox Tiger"] = "Тигр-качалка"
L["Foam Sword Rack"] = "Подставка для меча из пенополимера"
L["Unusual Compass"] = "Необычный компас"
L["Blossoming Branch"] = "Цветущая ветвь"
L["Path of Cenarius"] = "Путь Кенария"
L["Ogre Pinata"] = "Огрская пиньята"
L["Ultrasafe Transporter:"] = "Сверхбезопасный транспортер"
L["Dimensional Ripper - "] = "Пространственный проходчик - "
L["Wormhole Generator:"] = "Генератор червоточины:"
L["Goblin Beam Welder"] = "Гоблинский лучевой трансформатор"
L["Runed Orb"] = "Руническая сфера"
L["Crusader Orb"] = "Сфера рыцаря"
L["Gnomish Army Knife"] = "Гномский армейский нож"
L["Primordial Saronite"] = "Древний саронит"
--L["Brazie's Gnomish Pleasure Device"] = ""
L["Summons and dismisses a rideable"] = "Позволяет призывать и отпускать"
L["Nurtured Penguin Egg"] = "Высиженное яйцо пингвина"
L["Truesilver Shafted Arrow"] = "Стрела с древком из истинного серебра"
L["Kirin Tor Familiar"] = "Фамильяр Кирин-Тора"
L["Unhatched Mr. Chilly"] = "Мистер Холодок"
L["Frosty's Collar"] = "Ошейник Морозца"
L["Perpetual Purple Firework"] = "Нескончаемый лиловый фейерверк"
L["Carved Ogre Idol"] = "Резной огрский идол"
L["The Flag of Ownership"] = "Знамя победителя"
L["Gnomeregan Pride"] = "Гордость Гномрегана" 
