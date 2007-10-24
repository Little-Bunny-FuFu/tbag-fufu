
TBodyProfile = {};
TBodyProfile[TBAG_REALM] = {};

-- View switching
TBODY_PLAYERID = "";

function TBody_SetPlayer(playerid)
  TBODY_PLAYERID = playerid;
end

local function print(msg) SELECTED_CHAT_FRAME:AddMessage("TBody: "..msg); end

TBody = {
  -- Functions

  unregister =
    {
      Event = function ()
        for index, event in TBody.constant.event do
          this:UnregisterEvent(event);  -- Event that will be called for initialisation of the addon
        end
        for index, event in TBody.constant.toggleEvents do
          this:UnregisterEvent(event);
        end
      end;
    };

  register =
    {  
      Event = function ()
        for index, event in TBody.constant.event do
          this:RegisterEvent(event);    -- Event that will be called for initialisation of the addon
        end
        TBody.status.register.event = true;
      end;

      hook = function ()
        TBody.status.register.hook = true;
      end;

      titanmodmenu = function ()
        if(TitanModMenu_MenuItems) then
          TitanModMenu_MenuItems["TBody"] = {
            frame = "TBody_Frame",
            cat = TITAN_MODMENU_CAT_INVENTORY,
            text = BINDING_HEADER_TBODY,
            func = "TBody_Toggle"
            };
          TBody.status.register.titanmodmenu = true;
        end
      end;
    };

  onLoad = function ()
    -- Registering Event
    TBody.register.Event();

    TBody.register.titanmodmenu();
  end;

  Toggle = function ()
    if(TBody_Frame:IsVisible()) then
      TBody.Hide();
    else
      TBody_Show();
    end
  end;

  Hide = function()
    HideUIPanel(TBody_Frame);
    PlaySound("igMainMenuClose");
  end;

  ResetLoc = function()
    UIPanelWindows["TBody_Frame"] = { area = "up", pushable = 6 };
    HideUIPanel(TBody_Frame);
    ShowUIPanel(TBody_Frame);
    UIPanelWindows["TBody_Frame"] = nil;
    HideUIPanel(TBody_Frame);
    ShowUIPanel(TBody_Frame);
    TBody_Frame:SetUserPlaced();
  end;

  List = function ()
    if(TBodyProfile and TBodyProfile[TBAG_REALM]) then
      for index, item in TBodyProfile[TBAG_REALM] do
        if(  TBodyProfile[TBAG_REALM][index]["Type"] and TBodyProfile[TBAG_REALM][index]["Type"] == "Self") then
          if( TBodyProfile[TBAG_REALM][index] and TBodyProfile[TBAG_REALM][index]["Data"]) then
            local output = index;
            if(TBodyProfile[TBAG_REALM][index]["Data"]["Id"] and TBodyProfile[TBAG_REALM][index]["Data"]["Id"]["Class"]) then
              output = output .. ", " .. TBodyProfile[TBAG_REALM][index]["Data"]["Id"]["Class"];
            end
            if(TBodyProfile[TBAG_REALM][index]["Data"]["Id"] and TBodyProfile[TBAG_REALM][index]["Data"]["Id"]["Level"]) then
              output = output .. ", " .. TBodyProfile[TBAG_REALM][index]["Data"]["Id"]["Level"];
            end
            if(TBodyProfile[TBAG_REALM][index]["Data"]["Location"] and TBodyProfile[TBAG_REALM][index]["Data"]["Location"]["Zone"]) then
              output = output .. ", " .. TBodyProfile[TBAG_REALM][index]["Data"]["Location"]["Zone"];
            end
            if( TBodyProfile[TBAG_REALM][index]["Data"]["Mail"] and TBodyProfile[TBAG_REALM][index]["Data"]["Mail"]["HasNewMail"]) then
              output = output .. ", " .. HAVE_MAIL;
            end
            if( TBodyProfile[TBAG_REALM][index]["Data"]["xp"] ) then
              local temp = TBody.library.CalcRestedXP( TBodyProfile[TBAG_REALM][index]["Data"]["xp"] );
              if( temp and temp.estimated > 0 ) then
                output = output .. ", " .. temp.levelratio .. " " .. LEVEL .. " " .. TBODY_RESTED;
              end
              if( TBodyProfile[TBAG_REALM][index]["Data"]["xp"]["resting"] and temp.levelratio < 1.5 ) then
                output = output .. ", " .. TBODY_RESTING;
              end
            end
            print(output);
          end
        end
      end
    end
  end;

  Switch = function (choice)
    if(choice == nil) then
      choice = UnitName("player"); --! todo: improve
    end

    if(choice == -1 or choice == 1) then
      local current = 0;
      local i = 0;
      local temp = {};
      for j, name in TBodyProfile[TBAG_REALM] do
        if(name["Type"] == "Self") then
          i = i + 1;
          temp[i] = j;
          if(j == TBody.index ) then
            current = i;
          end
        end
      end
      current = current + choice;
      if(current <= 0) then
        choice = temp[i];
      elseif(current > i) then
        choice = temp[1];
      else
        choice = temp[current];
      end
    end

    -- Switch the current characterviwer character
    choice2 = string.upper(string.sub(choice, 1,1)) .. string.lower(string.sub(choice , 2));  -- Make the first character upper, all the other lowercase.
    if(TBodyProfile[TBAG_REALM][choice] ~= nil) then
      TBody.index = choice;
      TBodyCurrentIndex = TBody.index;    -- Backward compatibility
    elseif(TBodyProfile[TBAG_REALM][choice2] ~= nil) then
      TBody.index = choice2;
      TBodyCurrentIndex = TBody.index;    -- Backward compatibility
    else
      print(TBODY_NOT_FOUND .. choice);
      TBody.Hide();
    end

    if(TBody_Frame:IsVisible()) then
      TBody_Show();
    end

    if( AC_Target and AC_Target:IsVisible()) then
      AC_CV_DropDown_OnClick(name);
    end
  end;

  collect =
    {
      basic = function (target)
        local temp = {};

        -- Set the mana pool if it's a mana user
        if( UnitPowerType(target) and UnitPowerType(target) == 0 ) then
          if( UnitManaMax(target) and UnitManaMax(target) > 0) then
            temp["Mana"] = UnitManaMax(target);
          else
            temp["Mana"] = "??";
          end
        end

        if(UnitHealthMax(target) and (UnitHealthMax(target) > 100 or target == "player") ) then
          temp["Health"] = UnitHealthMax(target);
        else
          temp["Health"] = "??";
        end

        if(target == "player") then
          temp["Defense"] = UnitDefense(target);
          -- Set the armor value
          local baseArm, effectiveArmor, armor, positiveArm, negativeArm = UnitArmor(target);
          temp["Armor"] = baseArm .. ":" .. (baseArm + positiveArm) .. ":" .. positiveArm; -- if they have a debuf on, don't save it
        end
        return temp;
      end;

      id = function (target)            -- Flisher 2005-07-29
        local Race, RaceEn = UnitRace(target);
        local Class, ClassEn = UnitClass(target);
        local temp = {
          Sex = TBody.collect.sex(target, 0),
          SexId = TBody.collect.sex(target, 1),
          Race = Race,
          RaceEn = RaceEn,
          Class = Class,
          ClassEn = ClassEn,
          Level = UnitLevel(target),
          Server = TBAG_REALM,
          Name = UnitName(target),        -- Added 2005-07-28 for easyness of access, by Flisher
        };
        return temp;
      end;

      location = function ()            -- Flisher 2005-07-29
        return {
          Zone = GetZoneText(),
          SubZone = GetSubZoneText(),
        }

      end;

      xp = function()                 -- Flisher 2005-07-29
        return {
          max = UnitXPMax("player");
          current = UnitXP("player");
          resting = IsResting() == 1 or false;
          bonus = GetXPExhaustion();
          timestamp = time();
        }
      end;

      mail = function ()                -- Flisher 2005-07-28
        local temp = {};
        temp["HasNewMail"] = HasNewMail() == 1 or false;
        --temp["nb"] = GetInboxNumItems();
        return temp;
      end;

      sex = function (target, num)                 -- Flisher 2006-07-01, TBody.collect.sex
        local temp = "";
        temp = mod(UnitSex(target),2);
        if( (not num) or num == 0) then
          if(temp and temp == 0) then
            temp = MALE;
          else
            temp = FEMALE;
          end
        end
        return temp;
      end;

      guild = function (target)               -- Flisher 2005-07-28
        local temp = {};
        temp["GuildName"], temp["Title"], temp["Rank"] = GetGuildInfo(target);
        return temp;
      end;

      stats = function ()               -- Flisher 2005-07-28
        -- "stat" is the same as effectiveStat...
        -- problem here is if they have a debuff spell on, the values saved will be wrong
        local temp = {};
        for index = 1, 5 do
          local stat, effectiveStat, posBuff, negBuff = UnitStat("player", index);
          temp[index] = (stat - posBuff - negBuff) .. ":" .. effectiveStat .. ":" .. posBuff .. ":" .. negBuff;
        end
        return temp;
      end;

      resistance = function ()
        local temp = {};
        for index = 2, 6 do
          local base, resistance, positive, negative = UnitResistance("player", index);
          temp[index] = resistance;
        end
        return temp;
      end;

      combatstats = function ()           -- Flisher 2005-06-12
        local temp = {};
        temp["D"] = GetDodgeChance();
        if( GetBlockChance() > 0) then
          temp["B"] = GetBlockChance();
        end

        -- Get Parry Chance
        local _, class = UnitClass('player');
        if( class=="MAGE" or class=="WARLOCK" or class=="DRUID" or class=="PRIEST" ) then
          temp["P"] = 0;
        else
          temp["P"] = GetParryChance();
        end

        -- Get Crit Chance
        local i=0;
        repeat
          i=i+1;
          spellName, subSpellName = GetSpellName(i,BOOKTYPE_SPELL);
        until (spellName == ATTACK) or (not spellName)
        if(not spellName) then
          return temp;
        end
        CharactersVTooltip:SetOwner(UIParent, "ANCHOR_NONE");
        CharactersVTooltip:SetSpell(i, BOOKTYPE_SPELL);
        local _, _, tmpStr = string.find(CharactersVTooltipTextLeft2:GetText(), '(%d+\.%d+)');
        CharactersVTooltip:Hide();
        tmpStr = string.gsub(tmpStr, ",", ".");
        temp["C"] = tmpStr;

        return temp;
      end;

      honor = function (target)             -- Flisher 2005-06-12
        local temp = {};
        if(UnitPVPRank(target) and GetPVPRankInfo(UnitPVPRank(target)) and UnitPVPRank(target) >= 1) then
          temp["rankName"], temp["rankNumber"] = GetPVPRankInfo(UnitPVPRank(target));
        end
              temp["HK"],temp["DK"] = GetPVPLifetimeStats(); -- Wakyhorse HK's       
        return temp;
      end;

      all = function ()              -- Changed Flisher 2005-06-12
        -- Properly initialize the SavedVariable if it do not exist
        if( not TBodyProfile ) then
          TBodyProfile = {};
        end
        -- Properly initialize the current realm if it do not exist
        if( not TBodyProfile[TBAG_REALM] ) then
          TBodyProfile[TBAG_REALM] = {};
        end

        -- Bank restore
        TBodyProfile[TBAG_REALM][UnitName("player")] = {};

        -- Initialise the type
        TBodyProfile[TBAG_REALM][UnitName("player")]["Type"] = "Self";
        TBodyProfile[TBAG_REALM][UnitName("player")]["Timestamp"] = time();

        TBodyProfile[TBAG_REALM][UnitName("player")]["Data"] = {
            Type = TBodyProfile[TBAG_REALM][UnitName("player")]["Type"];
            Timestamp = TBodyProfile[TBAG_REALM][UnitName("player")]["Timestamp"];
            Money = GetMoney(),
            Guild = TBody.collect.guild("player");
            Resists = TBody.collect.resistance();
            Stats = TBody.collect.stats();
            CombatStats = TBody.collect.combatstats();
            Mail = TBody.collect.mail(false);
            Id = TBody.collect.id("player");
            Location = TBody.collect.location();
            xp = TBody.collect.xp();
            Honor = TBody.collect.honor("player");
            Basic = TBody.collect.basic("player");
          }

        -- Set the status flag if data was collected at least once sicne the addon loaded
        if(not TBody.status.collected) then
          TBody.status.collected = true;
          TBody.Switch();
          TBody_PaperDoll_Dropdown2_Toggle();
        end
      end;

  db = {
      init = function ()          --TBody.db.init()
        if (TBodyProfile == nil) then
          TBodyProfile = {};
        end
      end;

    };

  library =                               -- TBody.library
    {   GetRaceFaction = function( raceEn) -- Wakyhorse Added GetRaceFaction Function Starts here
        if (raceEn == "Human" or raceEn == "Dwarf" or raceEn == "Gnome" or raceEn == "NightElf") 
          then return 1;
        end

        if (raceEn == "Orc" or raceEn == "Troll" or raceEn == "Scourge" or raceEn == "Tauren") then 
          return 2;
        end
        --print("Unknown Race "..race);
        return 3;
      end;                 -- Wakyhorse Added GetRaceFaction Function Ends here


      splitstring = function (input)            -- TBody.library.splitstring
        local list = {};
        local i = 0;
        for w in string.gfind(input, "([^ ]+)") do
          list[i] = w;
          i = i + 1;
        end
        return list;
      end;

      CalcRestedXP = function (data)            -- TBody.library.CalcRestedXP
        local temp = {
          estimated = 0;
          levelratio = 0;
          percentrested = 0;
        }
        if(data and data["bonus"] and data["resting"] ~= nil and data["max"] and data["timestamp"]) then
          local speed = data.resting and 4 or 1;
          local estimated = data.bonus;
          if(data.timestamp < time()) then
            estimated = data.bonus + floor((time()-data.timestamp) * data.max * 1.5 / 864000 / 4 * speed);
            if(estimated  > (data.max * 1.5) ) then
              estimated = (data.max * 1.5);
            end
          end
          temp = {
            estimated = estimated;
            levelratio = floor(estimated/data.max *10)/10;
            percentrested = floor(estimated / (data.max  *1.5) *100)/100;
          }
        end
        return temp;
      end;

      MoneyTotal = function(faction)               -- TBody.library.MoneyTotal
        local total = 0;
        if( TBodyProfile and TBodyProfile[TBAG_REALM] ) then
          for index in TBodyProfile[TBAG_REALM] do
            if( TBodyProfile[TBAG_REALM][index]["Data"] and TBodyProfile[TBAG_REALM][index]["Data"]["Money"] ) then
                  if (TBodyProfile[TBAG_REALM][index]["Data"]["Id"]["RaceEn"]) then
                    if ( TBody.library.GetRaceFaction(TBodyProfile[TBAG_REALM][index]["Data"]["Id"]["RaceEn"]) == faction) then
                      total = total + TBodyProfile[TBAG_REALM][index]["Data"]["Money"];
                    end
                  end
            end
          end
        end
        return total;
      end;
    };

  -- Variables
  index = nil;        -- is now initialised via the first data collect, which should happen before any possible call
  loaded = nil;         -- Successful load of the script
  version =
    {  db = 62;
      text = "1.03";
      number = 103;
      date = "July 6th, 2006";
    };

  constant =
    {   event = -- TBody.constant.event
        {
          "VARIABLES_LOADED";
          "UNIT_NAME_UPDATE";
          "PLAYER_GUILD_UPDATE";
          "UNIT_INVENTORY_CHANGED";
          "PLAYER_LEVEL_UP";
          "PLAYER_PVP_RANK_CHANGED";
          "CHARACTER_POINTS_CHANGED";

          "MAIL_SHOW";          -- Mail
          "MAIL_CLOSED";          -- Mail
        };

      inventorySlot =
        {
          Name =
            {    
              [0] = AMMOSLOT,            -- 0
              [1] = HEADSLOT,             -- 1
              [2] = NECKSLOT,             -- 2
              [3] = SHOULDERSLOT,          -- 3
              [4] = SHIRTSLOT,             -- 4
              [5] = CHESTSLOT,             -- 5
              [6] = WAISTSLOT,             -- 6
              [7] = LEGSSLOT,             -- 7
              [8] = FEETSLOT,             -- 8
              [9] = WRISTSLOT,             -- 9
              [10] = HANDSSLOT,             -- 10
              [11] = FINGER0SLOT,          -- 11
              [12] = FINGER1SLOT,          -- 12
              [13] = TRINKET0SLOT,          -- 13
              [14] = TRINKET1SLOT,          -- 14
              [15] = BACKSLOT,             -- 15
              [16] = MAINHANDSLOT,          -- 16
              [17] = SECONDARYHANDSLOT,      -- 17
              [18] = RANGEDSLOT,          -- 18
              [19] = TABARDSLOT,          -- 19
            };

          Texture =
            {  
              [0] = ({GetInventorySlotInfo("AMMOSLOT")})[2],       -- 0
              [1] = ({GetInventorySlotInfo("HEADSLOT")})[2],      -- 1
              [2] = ({GetInventorySlotInfo("NECKSLOT")})[2],      -- 2
              [3] = ({GetInventorySlotInfo("SHOULDERSLOT")})[2],     -- 3
              [4] = ({GetInventorySlotInfo("SHIRTSLOT")})[2],      -- 4
              [5] = ({GetInventorySlotInfo("CHESTSLOT")})[2],      -- 5
              [6] = ({GetInventorySlotInfo("WAISTSLOT")})[2],      -- 6
              [7] = ({GetInventorySlotInfo("LEGSSLOT")})[2],      -- 7
              [8] = ({GetInventorySlotInfo("FEETSLOT")})[2],      -- 8
              [9] = ({GetInventorySlotInfo("WRISTSLOT")})[2],      -- 9
              [10] = ({GetInventorySlotInfo("HANDSSLOT")})[2],       -- 10
              [11] = ({GetInventorySlotInfo("FINGER0SLOT")})[2],    -- 11
              [12] = ({GetInventorySlotInfo("FINGER1SLOT")})[2],    -- 12
              [13] = ({GetInventorySlotInfo("TRINKET0SLOT")})[2],    -- 13
              [14] = ({GetInventorySlotInfo("TRINKET1SLOT")})[2],    -- 14
              [15] = ({GetInventorySlotInfo("BACKSLOT")})[2],       -- 15
              [16] = ({GetInventorySlotInfo("MAINHANDSLOT")})[2],    -- 16
              [17] = ({GetInventorySlotInfo("SECONDARYHANDSLOT")})[2],  -- 17
              [18] = ({GetInventorySlotInfo("RANGEDSLOT")})[2],       -- 18
              [19] = ({GetInventorySlotInfo("TABARDSLOT")})[2],       -- 19
            }
          };
    };

    config = { };

    status = {
      register = {};
      -- Known status to be inserted by the code lather
      -- loaded (meaning the initial load/initialisation is done)
      -- collected (true = that the system collected data at least once
    };

    debug = {
    };

};   -- End of TBody Object

-- OnFoo functions

function TBody_OnEvent(event, arg1)
  if(event == "VARIABLES_LOADED" and not TBody.status.loaded) then
    -- Set the Loaded Status to true, to ensure it's not runned twice, we never know with blizzard...
    TBody.status.loaded = true;

    -- Configure the panel display and title
    tinsert(UISpecialFrames, "TBody_Frame");
    UIPanelWindows["TBody_Frame"] = nil;
    TBody_Frame:RegisterForDrag("LeftButton");

    TBody_FrameTitleText:SetText("TBody Viewer");

    -- Hooked function
    TBody.register.hook();

    TBody.db.init();
  end

  return;
end

function TBodyItemButton_OnEnter()            -- Cleaned by Flisher 2005-05-31
  local link, text, itemCount;
  -- Detecting if it's from the inventory or equipment
  if(this:GetID() < 100 and this:GetID() > 0) then
    -- Equiped item link
    if(TBodyProfile[TBAG_REALM][TBody.index]["Equipment"][this:GetID()]) then
      link = TBodyProfile[TBAG_REALM][TBody.index]["Equipment"][this:GetID()].L ;
      if(TBodyProfile[TBAG_REALM][TBody.index]["Equipment"][this:GetID()].C) then
        itemCount = TBodyProfile[TBAG_REALM][TBody.index]["Equipment"][this:GetID()].C;
      end
    else
      text = TBody.constant.inventorySlot.Name[this:GetID()];
    end
  elseif(this:GetID() > 2000 and this:GetID() < 2100) then
    local slot = this:GetID() - 2000;
    if( TBodyProfile and TBodyProfile[TBAG_REALM] and TBodyProfile[TBAG_REALM][TBody.index] and TBodyProfile[TBAG_REALM][TBody.index]["Bank"] and TBodyProfile[TBAG_REALM][TBody.index]["Bank"]["Main"] and TBodyProfile[TBAG_REALM][TBody.index]["Bank"]["Main"][slot] ) then
      if( TBodyProfile[TBAG_REALM][TBody.index]["Bank"]["Main"][slot].L ) then
        link = TBodyProfile[TBAG_REALM][TBody.index]["Bank"]["Main"][slot].L;
        if( TBodyProfile[TBAG_REALM][TBody.index]["Bank"]["Main"][slot].C ) then
          itemCount =  TBodyProfile[TBAG_REALM][TBody.index]["Bank"]["Main"][slot].C;
        end
      end
    else
      text = EMPTY;
    end
  elseif ( (this:GetID() >= 100 and this:GetID() < 600) or (this:GetID() >= -100 and this:GetID() < -80 ) ) then
    -- Inventory item link
    local slot = math.mod( abs(this:GetID() +100), 100); 
    local bag  = (this:GetID() - slot - 100) / 100;
    if(TBodyProfile[TBAG_REALM][TBody.index]["Bag"] and TBodyProfile[TBAG_REALM][TBody.index]["Bag"][bag] and TBodyProfile[TBAG_REALM][TBody.index]["Bag"][bag][slot] and TBodyProfile[TBAG_REALM][TBody.index]["Bag"][bag][slot].L) then
      link = TBodyProfile[TBAG_REALM][TBody.index]["Bag"][bag][slot].L;
      if(TBodyProfile[TBAG_REALM][TBody.index]["Bag"][bag][slot].C) then
         itemCount = TBodyProfile[TBAG_REALM][TBody.index]["Bag"][bag][slot].C;
      end
    else
      text = EMPTY;
    end
  elseif(this:GetID() >= 600 and this:GetID() < 1200) then
    -- Inventory item link
    local slot = math.mod(this:GetID(), 100);
    local bag  = (this:GetID() - slot - 100) / 100;
    if(TBodyProfile[TBAG_REALM][TBody.index]["Bank"] and TBodyProfile[TBAG_REALM][TBody.index]["Bank"][bag] and TBodyProfile[TBAG_REALM][TBody.index]["Bank"][bag][slot] and TBodyProfile[TBAG_REALM][TBody.index]["Bank"][bag][slot].L) then
      link = TBodyProfile[TBAG_REALM][TBody.index]["Bank"][bag][slot].L;
      if(TBodyProfile[TBAG_REALM][TBody.index]["Bank"][bag][slot].C) then
        itemCount = TBodyProfile[TBAG_REALM][TBody.index]["Bank"][bag][slot].C;
      end
    else
      text = EMPTY;
    end
  end
  ShowUIPanel(GameTooltip);
  GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
  if(link) then
    if( GetItemInfo(link) ) then
      GameTooltip:SetHyperlink(link);
    else
      GameTooltip:SetText(TBODY_NOT_CACHED);
    end
  else
    GameTooltip:SetText(text);
  end

  -- Book of Crafts inter-operability (http://www.curse-gaming.com/mod.php?addid=1397)
  if(BookOfCrafts_UpdateGameToolTips and link) then
    BookOfCrafts_UpdateGameToolTips();
  end

  -- Receipe Book inter-operability (http://www.curse-gaming.com/mod.php?addid=914)
  if( RecipeBook_DoHookedFunction and link) then
    RecipeBook_DoHookedFunction();
  end



  --Auctioneer inter-operability (http://www.curse-gaming.com/mod.php?addid=146)
  if(TT_TooltipCall and link) then
    local name,_,quality = GetItemInfo(link);
    if(name) then
      if(not itemCount) then
        itemCount = 1;
      end
      TT_Clear();
      TT_TooltipCall(GameTooltip, name, TBody.library.MakeLink(link), quality, itemCount);
      TT_Show(GameTooltip);
    end
  end

end

function TBody_Tooltip_SetInventoryItem(tooltip, slotid)   -- Cleaned by Flisher 2005-05-31
  local link, text;
--! if(not TBody.index) then
--!   TBody.Switch();
--! end

  if( TBody.index ~= UnitName("player") ) then
    -- Detecting if it's from the inventory or equipment
    if( slotid < 100 and slotid > 0) then
      -- Equiped item link
      if( TBodyProfile[TBAG_REALM][TBody.index]["Equipment"][slotid] ) then
        link = TBodyProfile[TBAG_REALM][TBody.index]["Equipment"][slotid].L ;
      else
        text = TBody.constant.inventorySlot.Name[slotid];
      end
    elseif(slotid > 2000 and slotid < 2100) then
      local slot = slotid - 2000;
      if( TBodyProfile and TBodyProfile[TBAG_REALM] and TBodyProfile[TBAG_REALM][TBody.index] and TBodyProfile[TBAG_REALM][TBody.index]["Bank"] and TBodyProfile[TBAG_REALM][TBody.index]["Bank"]["Main"] and TBodyProfile[TBAG_REALM][TBody.index]["Bank"]["Main"][slot] ) then
        if( TBodyProfile[TBAG_REALM][TBody.index]["Bank"]["Main"][slot].L ) then
          link = TBodyProfile[TBAG_REALM][TBody.index]["Bank"]["Main"][slot].L;
        end
      else
        text = EMPTY;
      end
    elseif ( ( slotid >= 100 and slotid < 600) or (slotid >= -100 and slotid < -80 ) ) then
      -- Inventory item link
      local slot = math.mod( abs(slotid+100), 100); 
      local bag  = (slotid - slot - 100) / 100;
      if(TBodyProfile[TBAG_REALM][TBody.index]["Bag"] and TBodyProfile[TBAG_REALM][TBody.index]["Bag"][bag] and TBodyProfile[TBAG_REALM][TBody.index]["Bag"][bag][slot] and TBodyProfile[TBAG_REALM][TBody.index]["Bag"][bag][slot].L) then
        link = TBodyProfile[TBAG_REALM][TBody.index]["Bag"][bag][slot].L;
      else
        text = EMPTY;
      end
    elseif( slotid >= 600 and slotid < 1200) then
      -- Inventory item link
      local slot = math.mod(slotid, 100);
      local bag  = (slotid - slot - 100) / 100;
      if(TBodyProfile[TBAG_REALM][TBody.index]["Bank"] and TBodyProfile[TBAG_REALM][TBody.index]["Bank"][bag] and TBodyProfile[TBAG_REALM][TBody.index]["Bank"][bag][slot]and TBodyProfile[TBAG_REALM][TBody.index]["Bank"][bag][slot].L) then
        link = TBodyProfile[TBAG_REALM][TBody.index]["Bank"][bag][slot].L;
      else
        text = EMPTY;
      end
    end

    if(link) then
      if( GetItemInfo(link) ) then
        tooltip:SetHyperlink(link);
        if(UnitName("player") ~= TBody.index) then
          tooltip:AddLine(TBody.index .. " " .. INVENTORY_TOOLTIP);
          tooltip:Show();
        else
          tooltip:Show();
        end
      else
        tooltip:SetText(TBODY_NOT_CACHED);
      end
    end
  else
    -- if the player requested is the logged one, use the original game tooltip
    tooltip:SetInventoryItem("player", slotid);
    tooltip:Show();
  end

end

function TBodyItemButton_OnClick(arg1)               -- Cleaned by Flisher 2005-05-31
  local link, item;
  -- Detecting if it's from the inventory or equipment
  if(this:GetID() < 100 and this:GetID() > 0 ) then
    -- Equiped item link
    if(TBodyProfile[TBAG_REALM][TBody.index]["Equipment"][this:GetID()]) then
      link = TBodyProfile[TBAG_REALM][TBody.index]["Equipment"][this:GetID()].L;
    end
  elseif(this:GetID() > 2000 and this:GetID() < 2100) then
    local slot = this:GetID() - 2000;
    if( TBodyProfile and TBodyProfile[TBAG_REALM] and TBodyProfile[TBAG_REALM][TBody.index] and TBodyProfile[TBAG_REALM][TBody.index]["Bank"] and TBodyProfile[TBAG_REALM][TBody.index]["Bank"]["Main"] and TBodyProfile[TBAG_REALM][TBody.index]["Bank"]["Main"][slot] ) then
      if( TBodyProfile[TBAG_REALM][TBody.index]["Bank"]["Main"][slot].L ) then
         link = TBodyProfile[TBAG_REALM][TBody.index]["Bank"]["Main"][slot].L;
      end
    end
  elseif ( ( this:GetID() >= 100 and this:GetID() < 600) or (this:GetID() >= -100 and this:GetID() < -80 ) ) then
    -- Inventory item link
    local slot = math.mod( abs(this:GetID()+100), 100); 
    local bag  = (this:GetID() - slot - 100) / 100;
    if(TBodyProfile[TBAG_REALM][TBody.index]["Bag"] and TBodyProfile[TBAG_REALM][TBody.index]["Bag"][bag] and TBodyProfile[TBAG_REALM][TBody.index]["Bag"][bag][slot] and TBodyProfile[TBAG_REALM][TBody.index]["Bag"][bag][slot].L) then
       link = TBodyProfile[TBAG_REALM][TBody.index]["Bag"][bag][slot].L;
    end
  elseif( this:GetID() >= 600 and this:GetID() < 1200) then
    -- Inventory item link
    local slot = math.mod(this:GetID(), 100);
    local bag  = (this:GetID() - slot - 100) / 100;
    if ( TBodyProfile and TBodyProfile[TBAG_REALM] and TBodyProfile[TBAG_REALM][TBody.index] and TBodyProfile[TBAG_REALM][TBody.index]["Bank"] and TBodyProfile[TBAG_REALM][TBody.index]["Bank"][bag] and TBodyProfile[TBAG_REALM][TBody.index]["Bank"][bag][slot] and TBodyProfile[TBAG_REALM][TBody.index]["Bank"][bag][slot].L ) then
      link = TBodyProfile[TBAG_REALM][TBody.index]["Bank"][bag][slot].L;
    end
  end
  link = TBody.library.MakeLink(link);
  if(IsShiftKeyDown() and ChatFrameEditBox:IsVisible() and link and arg1 == "LeftButton") then
    ChatFrameEditBox:Insert(link);
  end
  if( arg1 == "LeftButton" and IsControlKeyDown() ) then
    DressUpItemLink(link);
  end

  -- Component interaction, http://www.curse-gaming.com/mod.php?addid=1256, added by Flisher 2005-06-16
  --! TBodyItemButton_OnClick must be kept in backtracking ability TBody.button.onclick();
  if(Comp_TestOnClick and Comp_TestOnClick() and link) then
    return Comp_OnClick(arg1, link);
  end
end

function TBodyMagicResistanceFrame_OnEnter()           -- Checked by Flisher 2005-05-31
  ShowUIPanel(GameTooltip);
  GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
  GameTooltip:SetText(TEXT(getglobal("RESISTANCE"..this:GetID().."_NAME")));
end

function TBodyDropDown_OnEnter()                  -- Checked by Flisher 2005-05-31
  ShowUIPanel(GameTooltip);
  GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
  GameTooltip:SetText(TBODY_TOOLTIP_DROPDOWN2);
end

function TBody_Show()
  TBody.Hide();
  local temp;
  if(TBody.index == UnitName("player")) then
    TBody.collect.all();
  end

  -- Character Name and location
  if(TBodyProfile[TBAG_REALM][TBody.index]["Data"]) then

    -- "Name (Zone / SubZone)"
    temp = TBody.index;
    if( TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Location"] ~= nil
     and TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Location"]["Zone"] ~= nil
     and TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Location"]["SubZone"] ~= nil ) then
      temp = temp .. " (" .. TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Location"]["Zone"] .. " - " .. TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Location"]["SubZone"] .. ")";
    end
    TBody_FrameTopText1:SetText(temp);

    -- Character Honor Rank, Level, Race and Class
    temp = "";
    if( TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Id"] ~= nil
     and TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Id"]["Level"] ~= nil
     and TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Id"]["Class"] ~= nil ) then
      temp = temp .. "Level " .. TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Id"]["Level"] ..  " " .. TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Id"]["Class"];
    end
    if( TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Honor"] ~= nil
     and TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Honor"]["rankNumber"] ~= nil
     and TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Honor"]["rankName"] ~= nil) then
      temp  = temp .. " (Rank " .. TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Honor"]["rankNumber"] .. ", " .. TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Honor"]["rankName"] .. ")";
    end
    TBody_FrameTopText2:SetText(temp);

    -- Guild Rank and Name display initialisation
    temp = "";
    if( TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Guild"]
     and TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Guild"]["GuildName"]
     and TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Guild"]["Title"] ) then
      temp = TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Guild"]["Title"] .. " of " .. TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Guild"]["GuildName"];
    end
    TBody_FrameTopText3:SetText(temp);

    -- Characters stats (str agi spirit intel stam...)
    temp = { "", "", "", "", ""};
    if(TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Stats"]) then
      for index = 1, 5 do
        if(TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Stats"][index]) then
          local j = 0, stat, effectiveStat, posBuff, negBuff;
          for w in string.gfind(TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Stats"][index], "%d+") do
            j = j + 1;
            if(j == 1) then stat = w;
            elseif(j == 2) then effectiveStat = w;
            elseif(j == 3) then posBuff = w;
            elseif(j == 4) then negBuff = w;

            end
          end
        end
        temp[index] = effectiveStat;
      end
    end
    for index = 1, 5 do
      getglobal("TBody_FrameStatsTitle"..index):SetText(TEXT(getglobal("SPELL_STAT"..(index-1).."_NAME"))..":");
      getglobal("TBody_FrameStatsText"..index):SetText(temp[index]);
    end


    if(TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Basic"]) then
      -- Initialise the armor display
      temp = "";
      if(TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Basic"]["Armor"]) then
        local j =0, stat, effectiveStat, posBuff, negBuff;
        for w in string.gfind(TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Basic"]["Armor"], "%d+") do
          j = j + 1;
          if(j == 1) then stat = w;
          elseif(j == 2) then effectiveStat = w;
          elseif(j == 3) then posBuff = w;
          elseif(j == 4) then negBuff = w;
          end
          temp = effectiveStat;
        end
      end
      TBody_FrameStatsTitle6:SetText(ARMOR_COLON);
      TBody_FrameStatsText6:SetText(temp);

      -- Initialise the Health display
      temp = "";
      if(TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Basic"]["Health"]) then
        temp = TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Basic"]["Health"];
      end
      TBody_FrameDetailTitle1:SetText(HEALTH_COLON);
      TBody_FrameDetailText1:SetText(temp);

      -- Initialise the mana display
      temp = "";
      if(TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Basic"]["Mana"]) then
        temp = TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Basic"]["Mana"];
      end
      TBody_FrameDetailTitle2:SetText(MANA_COLON);
      TBody_FrameDetailText2:SetText(temp);
    end


    -- Initialize the combats stats (crit, parry, dodge, block...)
    if(TBodyProfile[TBAG_REALM][TBody.index]["Data"]["CombatStats"]) then
      temp = "";
      if( TBodyProfile[TBAG_REALM][TBody.index]["Data"]["CombatStats"]["C"] ) then
        temp = string.format("%01.2f%%", TBodyProfile[TBAG_REALM][TBody.index]["Data"]["CombatStats"]["C"] );
      end
      TBody_FrameDetailTitle3:SetText(TBODY_CRIT ..":");
      TBody_FrameDetailText3:SetText(temp);

      temp = "";
      if( TBodyProfile[TBAG_REALM][TBody.index]["Data"]["CombatStats"]["D"] ) then
        temp = string.format("%01.2f%%", TBodyProfile[TBAG_REALM][TBody.index]["Data"]["CombatStats"]["D"] );
      end
      TBody_FrameDetailTitle4:SetText(DODGE ..":");
      TBody_FrameDetailText4:SetText(temp);

      if( TBodyProfile[TBAG_REALM][TBody.index]["Data"]["CombatStats"]["B"] ) then
        TBody_FrameDetailTitle5:SetText(BLOCK ..":");
        TBody_FrameDetailText5:SetText( string.format("%01.2f%%", TBodyProfile[TBAG_REALM][TBody.index]["Data"]["CombatStats"]["B"] ));
      end
      TBody_FrameDetailTitle5:SetText("");
      TBody_FrameDetailText5:SetText("");

      if( TBodyProfile[TBAG_REALM][TBody.index]["Data"]["CombatStats"]["P"] ) then
        TBody_FrameDetailTitle6:SetText(PARRY ..":");
        TBody_FrameDetailText6:SetText( string.format("%01.2f%%", TBodyProfile[TBAG_REALM][TBody.index]["Data"]["CombatStats"]["P"] ));
      else
        TBody_FrameDetailTitle6:SetText("");
        TBody_FrameDetailText6:SetText("");
      end
      if( TBodyProfile[TBAG_REALM][TBody.index]["Data"]["xp"] ) then
        temp = TBody.library.CalcRestedXP( TBodyProfile[TBAG_REALM][TBody.index]["Data"]["xp"] );
        if( temp and temp.levelratio ~= nil) then
          temp = temp.levelratio .. " " .. LEVEL .. " " .. TBODY_RESTED;
        else
          temp = "";
        end
        TBody_FrameDetailTitle7:SetText(XP .. ":");
        TBody_FrameDetailText7:SetText(temp);

        temp = "";
        if( TBodyProfile[TBAG_REALM][TBody.index]["Data"]["xp"]["current"] ) then
          temp = TBodyProfile[TBAG_REALM][TBody.index]["Data"]["xp"]["current"];
        else
          temp = "??";
        end
        if( TBodyProfile[TBAG_REALM][TBody.index]["Data"]["xp"]["max"] ) then
          temp = temp .. "/" .. TBodyProfile[TBAG_REALM][TBody.index]["Data"]["xp"]["max"];
        else
          temp = temp .. "/??";
        end
        TBody_FrameDetailTitle8:SetText("");
        TBody_FrameDetailText8:SetText(temp);

        if( TBodyProfile[TBAG_REALM][TBody.index]["Data"]["xp"]["resting"] ) then
          TBody_RestedFrame:Show();
        else
          TBody_RestedFrame:Hide();
        end
      end
      if( TBodyProfile[TBAG_REALM][TBody.index]["Timestamp"] ~= nil) then
        TBody_FrameDetailTitle0:SetText(TBODY_SAVEDON);
        TBody_FrameDetailText0:SetText( date(nil, TBodyProfile[TBAG_REALM][TBody.index]["Timestamp"]) );
      end
    else
      TBody_FrameDetailTitle3:SetText("");
      TBody_FrameDetailText3:SetText("");
      TBody_FrameDetailTitle4:SetText("");
      TBody_FrameDetailText4:SetText("");
      TBody_FrameDetailTitle5:SetText("");
      TBody_FrameDetailText5:SetText("");
      TBody_FrameDetailTitle6:SetText("");
      TBody_FrameDetailText6:SetText("");
      TBody_FrameDetailTitle7:SetText("");
      TBody_FrameDetailText7:SetText("");
      TBody_FrameDetailTitle8:SetText("");
      TBody_FrameDetailText8:SetText("");
      TBody_FrameDetailTitle0:SetText("");
      TBody_FrameDetailText0:SetText("");
      TBody_RestedFrame:Hide();
      TBody_MoneyFrame:Hide();
    end

    if( TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Resists"]) then
      -- Initialise the various resistance display
      for index = 2, 6 do
        temp = "";
        if( TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Resists"][index] ) then
          temp = TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Resists"][index];
        end
        getglobal("TBodyMagicResText"..index):SetText(temp);
      end
    else
      for index = 2, 6 do
        getglobal("TBodyMagicResText"..index):SetText("x");
      end
    end

    if(TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Money"]) then
      MoneyFrame_Update("TBody_MoneyFrame", TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Money"]);
    else
      MoneyFrame_Update("TBody_MoneyFrame", 0 );
      TBody_MoneyFrame:Hide();
    end
  end

  local index, item, button, texture;
  for index = 1, 19 do
    button = getglobal("TBody_FrameItem"..index);
    texture = getglobal("TBody_FrameItem"..index.."IconTexture");
    texture2 = TBody.constant.inventorySlot.Texture[index];
    texture:SetTexture(texture2);
    SetItemButtonCount(button, 0);
  end
  for index, item in TBodyProfile[TBAG_REALM][TBody.index]["Equipment"] do
     button = getglobal("TBody_FrameItem"..index);
     texture = getglobal("TBody_FrameItem"..index.."IconTexture");
     texture:SetTexture(item.T);
     SetItemButtonCount(button, item.C);
  end

  if( TBodyProfile[TBAG_REALM][TBody.index]["Data"] and TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Id"] and TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Id"]["SexId"] and TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Id"]["RaceEn"]) then
    local temprace, tempsex;
    if(TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Id"]["RaceEn"] == "Night Elf") then
      temprace = "NightElf";
    else
      temprace = TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Id"]["RaceEn"];
    end
    if( TBodyProfile[TBAG_REALM][TBody.index]["Data"]["Id"]["SexId"] == 0) then
      tempsex = "Male";
    else
      tempsex = "Female";
    end
    temp = "Interface\\CharacterFrame\\TemporaryPortrait-" .. tempsex .. "-" .. temprace;
  else
    temp = "Interface\\CharacterFrame\\TempPortrait";
  end
  TBody_PortraitTexure:SetTexture(temp);

  ShowUIPanel(TBody_Frame);
end

function TBodyDropDown_OnLoad()            -- Checked by Flisher 2005-05-31
  --! enable/disable checkup on this
  UIDropDownMenu_Initialize(this, TBodyDropDown_Initialize);
  UIDropDownMenu_SetText(TBODY_SELPLAYER, this);
  UIDropDownMenu_SetWidth(80, this);
end

function TBodyDropDown_OnClick()
  TBody.Switch(this.value);
  TBody_Show();

end

function TBodyDropDown_Initialize()
  local info = {};
  for index, item in TBodyProfile[TBAG_REALM] do
    if(TBodyProfile[TBAG_REALM][index]["Type"] == "Self") then
      local realm, player;
      info.text = index;
      info.value = index;
      info.func = TBodyDropDown_OnClick;
      info.notCheckable = nil;
      info.keepShownOnClick = nil;
      UIDropDownMenu_AddButton(info);
    end
  end;
end

function TBody_PaperDoll_Dropdown2_Toggle()
    --! enable button on/off
    local count = 0;
      for anything in TBodyProfile[TBAG_REALM] do
    count = count + 1;
    end
    if( count > 1 ) then
      getglobal("TBodyDropDown2"):Show();
    else
      getglobal("TBodyDropDown2"):Hide();
    end
end

-- Backward / inter-addons compatibility

-- Called By EquipCompare, soon to be removed, modified to fit with my new code - Flisher 2005-05-16

function TBodyGetBSIIndex(forceRecreate)
  if(forceRecreate or not TBodyCurrentIndex) then
    TBody.Switch();
  end
  return TBody.index ;     -- same as returning TBodyCurrentIndex
end


-- this one is also for Equipcompare interoperability:
TBODY_VERSION = TBody.version.number;
TBodyCurrentIndex = nil -- Not local so someone can hook to it

function TBody_Toggle()          -- Changed by Flisher 2005-06-12
  TBody.Toggle();
end

local function Used(bag,nr)
  used = 0;
  for i = 1,nr do
    if(bag[i] and bag[i].L) then used = used+1; end
  end
  return used
end

function TBody_Bags(arg)
  if(not TBodyProfile) then return; end
  local CV = TBodyProfile[TBAG_REALM]
  if(not CV) then return; end
  local use = arg=='use'
  print(TBODY_BAG_USE..TBAG_REALM)
  local text,list,total,bag,tused,used
  for name,data in CV do
    if(data.Type=='Self') then
    list,total,tused = '',0,0
      for ix,bag in data.Bag do
      if(list~='') then list = list..'+'; end
      if(use) then
      used = Used(bag,bag.size)
      list = list..used..'/'
      tused = tused+used
      end
      list = list..bag.size
      total = total+bag.size
    end
    tused = use and tused..'/' or ''
    text = format("%s: %s=%s%d",name,list,tused,total)
    list,total,tused = '24',24,0;
    if(data.Bank) then
      if(use) then
      used = Used(data.Bank.Main,24)
      list = used..'/24'
      tused = used
      end
      for ix,bag in data.Bank do
        if type(bag)=='table' then
          if(ix~='Main') then
          if(use) then
          used = Used(bag,bag.size)
          list = format("%s+%d/%d",list,used,bag.size)
          tused = tused+used
          else list = list..'+'..bag.size; end
          total = total+bag.size
        end
        end
      end
      tused = use and tused..'/' or ''
      text = format("%s,   Bank: %s=%s%d",text,list,tused,total)
    end
    print(text)
    end
  end
end


function TBody_UserDropdown_OnLoad()
  UIDropDownMenu_Initialize(this, TBody_UserDropdown_Initialize);
  UIDropDownMenu_SetSelectedValue(this, TBAG_PLAYERID);
  TBody_UserDropdown.tooltip = "You are viewing this player's body.";
  UIDropDownMenu_SetWidth(TBAG_USERDD_WIDTH, this);
  OptionsFrame_EnableDropDown(this);
end

function TBody_UserDropdown_Initialize()
  TBag_UserDropdown_Init(TBody_UserDropdown_OnClick,
    TBodyItm, TBAG_REALM);
end

function TBody_UserDropdown_OnClick()
  UIDropDownMenu_SetSelectedValue(TBody_UserDropdown, this.value);
  if ( this.value ) then
    TBody_SetPlayer(this.value);
  end
  if ( not TBODY_PLAYERID ) then
    TBag_PrintDEBUG("TBody_UserDropdown_OnClick Failed");
    return;
  end
  TBag_PrintDEBUG("Selected Player "..TBODY_PLAYERID);

  TBody_UpdateWindow(TBAG_REQ_MUST);
end

