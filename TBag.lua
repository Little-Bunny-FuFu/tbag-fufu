BINDING_HEADER_TBag = "TBag";

-----------------------------------------------------------------------
-- General Constants
-----------------------------------------------------------------------

-- View switching
TBAG_PLAYERID = "";
TBAG_REALM = GetRealmName();

-- Main mapping array
TBAG_BUTTONS = {};
TBAG_BAGSIZE_MAX = 40;

-- GFX settings
TBAG_BAR_MAX = 32;
TBAG_MAIN_BAR = 0;

TBAG_USERDD_WIDTH = 90;

TBAG_SORTBY_MIN = 0;
TBAG_SORTBY_NONE = 0;
TBAG_SORTBY_NORM = 1;
TBAG_SORTBY_REV = 2; -- reverses the name then sorts it:  ie:   "Potion Mana Major" vs "Major Mana Potion"
TBAG_SORTBY_MAX = 2;

TBAG_REQ_NONE = 0;	-- when items haven't changed, or only item counts
TBAG_REQ_PART = 1;	-- when items have changed location, but it's been sorted once and won't break if we don't sort again
TBAG_REQ_MUST = 2;	-- it's never been sorted, the window is in an unstable state, you MUST sort.

-- String constants
TBAG_CAT_BAR = "catbar";
TBAG_COLORS = "colors";

-- Groups
TBAG_G_BAR_SORT = "bar_sort";
TBAG_G_USE_NEW  = "use_new";

-- Used for indexing - MUST BE DISTINCT
TBAG_I_BAG       = "b";
TBAG_I_SLOT      = "s";
TBAG_I_BAGTYPE   = "bt";
TBAG_I_BAGFREE   = "bf";
TBAG_I_BAGSIZE   = "bz";

TBAG_I_CAT       = "c";
TBAG_I_KEYWORD   = "k";
TBAG_I_BAR       = "r";

TBAG_I_ITEMLINK  = "il";
TBAG_I_ITEMID    = "id";
TBAG_I_NAME      = "in";
TBAG_I_TYPE      = "it";
TBAG_I_SUBTYPE   = "is";

local TBAG_I_RARITY    = "ir";
local TBAG_I_COUNT     = "ic";
local TBAG_I_NEED      = "sn";
local TBAG_I_SOULBOUND = "sb";

-- Used in the New mechanism
local TBAG_I_TIMESTAMP = "ts";
local TBAG_I_NEWSTR    = "nw";
TBAG_V_NEWON     = "newY";
TBAG_V_NEWOFF    = "newN";
TBAG_V_NEWPLUS   = "newP";
TBAG_V_NEWMINUS  = "newM";

-- Local graphics settings
local TBAG_PAD_BOTTOM_EDIT = 30;
local TBAG_PAD_BOTTOM_NORM = 30;
local TBAG_PAD_TOP_GFX = 63;
local TBAG_PAD_TOP_NORM = 25;
local TBAG_BORDER = 2;

local TBAG_COOLDOWN_SCALE = 0.8;

local TBAG_DBC = {  -- Default Bag Colors
  { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 },
  { ["r"] = 1, ["g"] = 0, ["b"] = 0, ["a"] = 1 },
  { ["r"] = 0, ["g"] = 1, ["b"] = 0, ["a"] = 1 },
  { ["r"] = 1, ["g"] = 0.65, ["b"] = 0.05, ["a"] = 1 },
  { ["r"] = 0.8, ["g"] = 0.15, ["b"] = 1, ["a"] = 1 },
  { ["r"] = 0.2, ["g"] = 1, ["b"] = 1, ["a"] = 1 },
  { ["r"] = 0, ["g"] = 0, ["b"] = 1, ["a"] = 1 }, 
  { ["r"] = 1, ["g"] = 0.2, ["b"] = 0.8, ["a"] = 1 }
};

TBAG_C_CAT  = "ffcc55ee";
TBAG_C_BAR  = "ffff3366";
TBAG_C_INST = "ff00ff7f";

TBAG_SCP  = "|cffcc33ccTBag: |r";

-- Assorted player info constants
TBAG_S_MONEY     = "money";
TBAG_S_BANKSLOTS = "bankS";
TBAG_S_BANKFULL  = "bankF";
TBAG_S_EQUIPPED  = "equip";

TBAG_G_BASIC     = "basic";
TBAG_S_LEVEL     = "lvl";
TBAG_S_CLASS     = "class";
TBAG_S_RACE      = "race";
TBAG_S_GENDER    = "gnd";
TBAG_S_ZONE      = "zone";
TBAG_S_SUBZONE   = "subz";
TBAG_S_GUILD     = "guild";
TBAG_S_RANK      = "rank";

TBAG_G_XP        = "xp";
TBAG_S_REST      = "rest";
TBAG_S_XPCURR    = "xp";
TBAG_S_XPMAX     = "max";
TBAG_S_BONUS     = "bonus";

TBAG_G_PVP       = "pvp";
TBAG_S_HK        = "HK";
TBAG_S_HP        = "HP";
TBAG_S_DK        = "DK";

TBAG_S_NAME      = "name";

TBAG_G_STATS     = "stat";
TBAG_G_RESISTS   = "resist";

TBAG_G_COMBAT    = "combat";
TBAG_S_HEALTH    = "hp";
TBAG_S_MANA      = "mana";
TBAG_S_ARMOR     = "armor";
TBAG_S_DEFENSE   = "def";
TBAG_S_PARRY     = "parry";
TBAG_S_DODGE     = "dodge";
TBAG_S_BLOCK     = "block";

TBAG_G_MELEE     = "melee";
TBAG_S_CRIT      = "crit";
TBAG_S_DPS       = "dps";

TBAG_G_RANGE     = "range";

TBAG_G_SPELL     = "spell";

-----------------------------------------------------------------------
-- Large Default Initialization Arrays
-----------------------------------------------------------------------

local TBag_DefaultTrades = {
		["Alchemy"] = {
			["created"] = {
				["3825"] = 1,
				["6050"] = 1,
				["3386"] = 1,
				["13444"] = 1,
				["13455"] = 1,
				["4596"] = 1,
				["5996"] = 1,
				["7080"] = 1,
				["13456"] = 1,
				["7068"] = 1,
				["6051"] = 1,
				["13459"] = 1,
				["7076"] = 1,
				["9210"] = 1,
				["7078"] = 1,
				["3826"] = 1,
				["2455"] = 1,
				["6662"] = 1,
				["9061"] = 1,
				["13462"] = 1,
				["9172"] = 1,
				["3382"] = 1,
				["13443"] = 1,
				["1710"] = 1,
				["12360"] = 1,
				["8951"] = 1,
				["9154"] = 1,
				["18294"] = 1,
				["6049"] = 1,
				["929"] = 1,
				["6052"] = 1,
				["3384"] = 1,
				["7082"] = 1,
				["3388"] = 1,
				["9179"] = 1,
				["9206"] = 1,
				["3577"] = 1,
				["9264"] = 1,
				["10592"] = 1,
				["3389"] = 1,
				["12808"] = 1,
				["3387"] = 1,
				["4623"] = 1,
				["6373"] = 1,
				["118"] = 1,
				["5997"] = 1,
				["9149"] = 1,
				["9088"] = 1,
				["2457"] = 1,
				["2454"] = 1,
				["8956"] = 1,
				["6370"] = 1,
				["9144"] = 1,
				["858"] = 1,
				["13457"] = 1,
				["2458"] = 1,
				["3928"] = 1,
				["3827"] = 1,
				["3383"] = 1,
				["6048"] = 1,
				["3385"] = 1,
				["6037"] = 1,
				["8949"] = 1,
				["9233"] = 1,
				["20002"] = 1,
				["5631"] = 1,
				["6371"] = 1,
				["13445"] = 1,
				["2456"] = 1,
				["6372"] = 1,
				["3390"] = 1,
				["9030"] = 1,
				["2459"] = 1,
				["9224"] = 1,
				["21546"] = 1,
				["13442"] = 1,
				["3824"] = 1,
				["6149"] = 1,
				["13452"] = 1,
				["3391"] = 1,
				["9187"] = 1,
				["13447"] = 1,
				["13461"] = 1,
				["3823"] = 1,
				["13423"] = 1,
				["5634"] = 1,
				["5633"] = 1,
				["3829"] = 1,
				["9155"] = 1,
				["9036"] = 1,
				["12190"] = 1,
				["13446"] = 1,
			},
			["reagent"] = {
				["13465"] = 1,
				["6371"] = 1,
				["12363"] = 1,
				["13467"] = 1,
				["3356"] = 1,
				["7068"] = 1,
				["10620"] = 1,
				["3369"] = 1,
				["7076"] = 1,
				["3818"] = 1,
				["7078"] = 1,
				["8831"] = 1,
				["6522"] = 1,
				["3821"] = 1,
				["2450"] = 1,
				["5637"] = 1,
				["8839"] = 1,
				["2449"] = 1,
				["3355"] = 1,
				["4342"] = 1,
				["9262"] = 1,
				["7972"] = 1,
				["765"] = 1,
				["3358"] = 1,
				["6358"] = 1,
				["7082"] = 1,
				["11176"] = 1,
				["4625"] = 1,
				["3820"] = 1,
				["5635"] = 1,
				["7067"] = 1,
				["3164"] = 1,
				["2453"] = 1,
				["8836"] = 1,
				["6359"] = 1,
				["6370"] = 1,
				["9260"] = 1,
				["3858"] = 1,
				["2452"] = 1,
				["13463"] = 1,
				["7070"] = 1,
				["13464"] = 1,
				["3371"] = 1,
				["4402"] = 1,
				["2447"] = 1,
				["13422"] = 1,
				["3575"] = 1,
				["3372"] = 1,
				["7077"] = 1,
				["3824"] = 1,
				["8845"] = 1,
				["785"] = 1,
				["8838"] = 1,
				["7080"] = 1,
				["118"] = 1,
				["12359"] = 1,
				["1288"] = 1,
				["13423"] = 1,
				["13466"] = 1,
				["8925"] = 1,
				["3819"] = 1,
				["3860"] = 1,
				["8846"] = 1,
				["3357"] = 1,
				["8153"] = 1,
			},
		},
		["Blacksmithing"] = {
			["created"] = {
				["12406"] = 1,
				["6731"] = 1,
				["11128"] = 1,
				["3840"] = 1,
				["3835"] = 1,
				["6040"] = 1,
				["15871"] = 1,
				["9060"] = 1,
				["3855"] = 1,
				["3492"] = 1,
				["3484"] = 1,
				["2851"] = 1,
				["7916"] = 1,
				["3473"] = 1,
				["7969"] = 1,
				["7917"] = 1,
				["12404"] = 1,
				["7922"] = 1,
				["7963"] = 1,
				["7958"] = 1,
				["2871"] = 1,
				["5540"] = 1,
				["7934"] = 1,
				["7071"] = 1,
				["3471"] = 1,
				["2868"] = 1,
				["7918"] = 1,
				["3469"] = 1,
				["2865"] = 1,
				["7966"] = 1,
				["3845"] = 1,
				["12643"] = 1,
				["6043"] = 1,
				["12410"] = 1,
				["11144"] = 1,
				["2870"] = 1,
				["10421"] = 1,
				["15869"] = 1,
				["7919"] = 1,
				["3470"] = 1,
				["3483"] = 1,
				["3851"] = 1,
				["3485"] = 1,
				["2853"] = 1,
				["2857"] = 1,
				["3854"] = 1,
				["12409"] = 1,
				["3472"] = 1,
				["6042"] = 1,
				["3478"] = 1,
				["2864"] = 1,
				["3487"] = 1,
				["7956"] = 1,
				["7913"] = 1,
				["3474"] = 1,
				["3852"] = 1,
				["2863"] = 1,
				["3842"] = 1,
				["3482"] = 1,
				["7967"] = 1,
				["12644"] = 1,
				["7924"] = 1,
				["7964"] = 1,
				["2848"] = 1,
				["3836"] = 1,
				["7941"] = 1,
				["3489"] = 1,
				["2852"] = 1,
				["2854"] = 1,
				["12645"] = 1,
				["5541"] = 1,
				["7933"] = 1,
				["3481"] = 1,
				["3848"] = 1,
				["3239"] = 1,
				["3486"] = 1,
				["3846"] = 1,
				["3488"] = 1,
				["2862"] = 1,
				["7920"] = 1,
				["12420"] = 1,
				["6338"] = 1,
				["6214"] = 1,
				["3856"] = 1,
				["3241"] = 1,
				["3490"] = 1,
				["3853"] = 1,
				["2847"] = 1,
				["7965"] = 1,
				["7931"] = 1,
				["7914"] = 1,
				["7915"] = 1,
				["7930"] = 1,
				["6350"] = 1,
				["3844"] = 1,
				["3240"] = 1,
				["3849"] = 1,
				["7944"] = 1,
				["15870"] = 1,
				["2869"] = 1,
				["7957"] = 1,
				["3491"] = 1,
				["7945"] = 1,
				["12259"] = 1,
				["3843"] = 1,
			},
			["reagent"] = {
				["2321"] = 1,
				["5635"] = 1,
				["7971"] = 1,
				["3577"] = 1,
				["2840"] = 1,
				["2838"] = 1,
				["7067"] = 1,
				["12365"] = 1,
				["1206"] = 1,
				["3864"] = 1,
				["4255"] = 1,
				["7912"] = 1,
				["2605"] = 1,
				["12644"] = 1,
				["7076"] = 1,
				["2318"] = 1,
				["5498"] = 1,
				["2319"] = 1,
				["8170"] = 1,
				["2835"] = 1,
				["1529"] = 1,
				["2842"] = 1,
				["7966"] = 1,
				["11188"] = 1,
				["2589"] = 1,
				["7909"] = 1,
				["4234"] = 1,
				["7077"] = 1,
				["3486"] = 1,
				["4306"] = 1,
				["2880"] = 1,
				["6037"] = 1,
				["2841"] = 1,
				["4304"] = 1,
				["2836"] = 1,
				["7910"] = 1,
				["5637"] = 1,
				["3824"] = 1,
				["2459"] = 1,
				["3575"] = 1,
				["4338"] = 1,
				["818"] = 1,
				["1705"] = 1,
				["3859"] = 1,
				["3466"] = 1,
				["3391"] = 1,
				["3860"] = 1,
				["774"] = 1,
				["1210"] = 1,
				["5500"] = 1,
				["3478"] = 1,
				["11186"] = 1,
				["2592"] = 1,
				["3829"] = 1,
				["12359"] = 1,
				["11185"] = 1,
				["3470"] = 1,
				["14047"] = 1,
			},
		},
		["Enchanting"] = {
			["created"] = {
			},
			["reagent"] = {
				["7082"] = 1,
				["11176"] = 1,
				["4625"] = 1,
				["1210"] = 1,
				["11128"] = 1,
				["12803"] = 1,
				["6370"] = 1,
				["7067"] = 1,
				["11139"] = 1,
				["16203"] = 1,
				["11135"] = 1,
				["11082"] = 1,
				["13467"] = 1,
				["7080"] = 1,
				["11174"] = 1,
				["11084"] = 1,
				["8925"] = 1,
				["8153"] = 1,
				["16204"] = 1,
				["13926"] = 1,
				["7068"] = 1,
				["12359"] = 1,
				["7392"] = 1,
				["11177"] = 1,
				["6217"] = 1,
				["16206"] = 1,
				["7971"] = 1,
				["7078"] = 1,
				["14344"] = 1,
				["7909"] = 1,
				["3371"] = 1,
				["4470"] = 1,
				["6371"] = 1,
				["11137"] = 1,
				["10938"] = 1,
				["6037"] = 1,
				["10940"] = 1,
				["11083"] = 1,
				["6338"] = 1,
				["17034"] = 1,
				["5637"] = 1,
				["11291"] = 1,
				["11178"] = 1,
				["11134"] = 1,
				["3372"] = 1,
				["10998"] = 1,
				["10939"] = 1,
				["9224"] = 1,
				["14343"] = 1,
				["8170"] = 1,
				["8831"] = 1,
				["12811"] = 1,
				["11175"] = 1,
				["5500"] = 1,
				["8838"] = 1,
				["11144"] = 1,
				["12808"] = 1,
				["16202"] = 1,
				["11138"] = 1,
				["10978"] = 1,
				["17035"] = 1,
				["11382"] = 1,
			},
		},
		["Engineering"] = {
			["created"] = {
				["7148"] = 1,
				["10514"] = 1,
				["4406"] = 1,
				["10510"] = 1,
				["10559"] = 1,
				["4374"] = 1,
				["4377"] = 1,
				["4404"] = 1,
				["8069"] = 1,
				["10546"] = 1,
				["4364"] = 1,
				["8068"] = 1,
				["10499"] = 1,
				["4369"] = 1,
				["4360"] = 1,
				["4367"] = 1,
				["10558"] = 1,
				["4375"] = 1,
				["4394"] = 1,
				["4382"] = 1,
				["4378"] = 1,
				["6219"] = 1,
				["4387"] = 1,
				["5507"] = 1,
				["4395"] = 1,
				["4357"] = 1,
				["4358"] = 1,
				["4384"] = 1,
				["10512"] = 1,
				["4366"] = 1,
				["8067"] = 1,
				["4396"] = 1,
				["4389"] = 1,
				["4380"] = 1,
				["6712"] = 1,
				["18588"] = 1,
				["4359"] = 1,
				["4407"] = 1,
				["4370"] = 1,
				["4365"] = 1,
				["4401"] = 1,
				["4392"] = 1,
				["4385"] = 1,
				["4363"] = 1,
				["4361"] = 1,
				["10507"] = 1,
				["10498"] = 1,
				["10518"] = 1,
				["7506"] = 1,
				["11590"] = 1,
				["10508"] = 1,
				["9313"] = 1,
				["4372"] = 1,
				["4371"] = 1,
				["10560"] = 1,
				["4391"] = 1,
				["4386"] = 1,
				["4398"] = 1,
				["4403"] = 1,
				["4405"] = 1,
				["9318"] = 1,
				["4397"] = 1,
				["6714"] = 1,
				["10501"] = 1,
				["4368"] = 1,
				["6533"] = 1,
				["10561"] = 1,
				["10505"] = 1,
				["4390"] = 1,
			},
			["reagent"] = {
				["4371"] = 1,
				["2880"] = 1,
				["6530"] = 1,
				["10559"] = 1,
				["3577"] = 1,
				["2840"] = 1,
				["2589"] = 1,
				["10592"] = 1,
				["4377"] = 1,
				["4404"] = 1,
				["1206"] = 1,
				["3864"] = 1,
				["159"] = 1,
				["7912"] = 1,
				["4368"] = 1,
				["7068"] = 1,
				["4359"] = 1,
				["4375"] = 1,
				["4399"] = 1,
				["1529"] = 1,
				["2318"] = 1,
				["7191"] = 1,
				["2842"] = 1,
				["4389"] = 1,
				["7909"] = 1,
				["2838"] = 1,
				["10285"] = 1,
				["1210"] = 1,
				["4306"] = 1,
				["4363"] = 1,
				["4382"] = 1,
				["2841"] = 1,
				["4339"] = 1,
				["2836"] = 1,
				["10558"] = 1,
				["774"] = 1,
				["4364"] = 1,
				["4361"] = 1,
				["4304"] = 1,
				["4338"] = 1,
				["818"] = 1,
				["3859"] = 1,
				["10560"] = 1,
				["4387"] = 1,
				["2835"] = 1,
				["3860"] = 1,
				["1705"] = 1,
				["3575"] = 1,
				["4234"] = 1,
				["814"] = 1,
				["4357"] = 1,
				["2592"] = 1,
				["3829"] = 1,
				["2319"] = 1,
				["10561"] = 1,
				["10505"] = 1,
				["4400"] = 1,
			},
		},
		["Leatherworking"] = {
			["created"] = {
				["7282"] = 1,
				["4242"] = 1,
				["7352"] = 1,
				["15083"] = 1,
				["7374"] = 1,
				["7377"] = 1,
				["2313"] = 1,
				["8173"] = 1,
				["8216"] = 1,
				["7285"] = 1,
				["7386"] = 1,
				["5966"] = 1,
				["20575"] = 1,
				["2302"] = 1,
				["8170"] = 1,
				["4257"] = 1,
				["8201"] = 1,
				["4236"] = 1,
				["8210"] = 1,
				["4455"] = 1,
				["4253"] = 1,
				["2310"] = 1,
				["4248"] = 1,
				["8193"] = 1,
				["8172"] = 1,
				["6468"] = 1,
				["5963"] = 1,
				["7387"] = 1,
				["4304"] = 1,
				["7375"] = 1,
				["7378"] = 1,
				["8185"] = 1,
				["4262"] = 1,
				["4259"] = 1,
				["4265"] = 1,
				["5782"] = 1,
				["7281"] = 1,
				["4246"] = 1,
				["6466"] = 1,
				["8176"] = 1,
				["8203"] = 1,
				["8212"] = 1,
				["2304"] = 1,
				["8191"] = 1,
				["7358"] = 1,
				["8197"] = 1,
				["8205"] = 1,
				["4237"] = 1,
				["6467"] = 1,
				["7348"] = 1,
				["5781"] = 1,
				["4233"] = 1,
				["15407"] = 1,
				["4247"] = 1,
				["4260"] = 1,
				["7373"] = 1,
				["2315"] = 1,
				["7371"] = 1,
				["15564"] = 1,
				["7280"] = 1,
				["18662"] = 1,
				["5962"] = 1,
				["5739"] = 1,
				["2303"] = 1,
				["8211"] = 1,
				["4251"] = 1,
				["3719"] = 1,
				["8217"] = 1,
				["18948"] = 1,
				["8215"] = 1,
				["8200"] = 1,
				["7276"] = 1,
				["2308"] = 1,
				["8204"] = 1,
				["8218"] = 1,
				["7372"] = 1,
				["15086"] = 1,
				["18238"] = 1,
				["5783"] = 1,
				["4239"] = 1,
				["8198"] = 1,
				["4249"] = 1,
				["4234"] = 1,
				["2319"] = 1,
				["4231"] = 1,
				["4244"] = 1,
				["7279"] = 1,
				["2316"] = 1,
				["7277"] = 1,
				["5780"] = 1,
				["8214"] = 1,
				["5964"] = 1,
				["8175"] = 1,
				["4456"] = 1,
				["7278"] = 1,
				["8213"] = 1,
				["2317"] = 1,
				["2309"] = 1,
				["15084"] = 1,
				["5961"] = 1,
				["8189"] = 1,
				["2314"] = 1,
				["4243"] = 1,
				["2300"] = 1,
				["4256"] = 1,
				["5958"] = 1,
				["8187"] = 1,
				["2307"] = 1,
				["5957"] = 1,
				["2318"] = 1,
				["7391"] = 1,
			},
			["reagent"] = {
				["1210"] = 1,
				["4234"] = 1,
				["4232"] = 1,
				["3864"] = 1,
				["5498"] = 1,
				["8170"] = 1,
				["1529"] = 1,
				["4236"] = 1,
				["4233"] = 1,
				["14341"] = 1,
				["6471"] = 1,
				["6470"] = 1,
				["2325"] = 1,
				["783"] = 1,
				["2934"] = 1,
				["5116"] = 1,
				["2320"] = 1,
				["4289"] = 1,
				["7071"] = 1,
				["8169"] = 1,
				["8951"] = 1,
				["7428"] = 1,
				["2997"] = 1,
				["7286"] = 1,
				["4246"] = 1,
				["5500"] = 1,
				["5784"] = 1,
				["8153"] = 1,
				["8151"] = 1,
				["2321"] = 1,
				["7971"] = 1,
				["7067"] = 1,
				["3389"] = 1,
				["1206"] = 1,
				["8171"] = 1,
				["8343"] = 1,
				["4291"] = 1,
				["2457"] = 1,
				["2319"] = 1,
				["4305"] = 1,
				["8152"] = 1,
				["4235"] = 1,
				["8949"] = 1,
				["8150"] = 1,
				["4231"] = 1,
				["8167"] = 1,
				["4340"] = 1,
				["4304"] = 1,
				["5637"] = 1,
				["3824"] = 1,
				["3182"] = 1,
				["2459"] = 1,
				["5785"] = 1,
				["8154"] = 1,
				["7070"] = 1,
				["4337"] = 1,
				["4243"] = 1,
				["5373"] = 1,
				["2605"] = 1,
				["4461"] = 1,
				["7392"] = 1,
				["2312"] = 1,
				["8172"] = 1,
				["2318"] = 1,
				["15409"] = 1,
			},
		},
		["Tailoring"] = {
			["created"] = {
				["10040"] = 1,
				["7050"] = 1,
				["6242"] = 1,
				["10023"] = 1,
				["10034"] = 1,
				["2996"] = 1,
				["14342"] = 1,
				["10029"] = 1,
				["7026"] = 1,
				["14042"] = 1,
				["9999"] = 1,
				["4328"] = 1,
				["7051"] = 1,
				["21340"] = 1,
				["10004"] = 1,
				["2576"] = 1,
				["10024"] = 1,
				["2583"] = 1,
				["10041"] = 1,
				["2585"] = 1,
				["10055"] = 1,
				["4327"] = 1,
				["4320"] = 1,
				["13868"] = 1,
				["13870"] = 1,
				["10026"] = 1,
				["6384"] = 1,
				["14108"] = 1,
				["19056"] = 1,
				["5762"] = 1,
				["6238"] = 1,
				["6264"] = 1,
				["4321"] = 1,
				["7058"] = 1,
				["10027"] = 1,
				["5765"] = 1,
				["4343"] = 1,
				["5766"] = 1,
				["7053"] = 1,
				["2569"] = 1,
				["7048"] = 1,
				["4312"] = 1,
				["10048"] = 1,
				["6239"] = 1,
				["4322"] = 1,
				["10003"] = 1,
				["4241"] = 1,
				["14153"] = 1,
				["4315"] = 1,
				["14100"] = 1,
				["7062"] = 1,
				["10002"] = 1,
				["14103"] = 1,
				["13863"] = 1,
				["18408"] = 1,
				["4318"] = 1,
				["4307"] = 1,
				["4344"] = 1,
				["10036"] = 1,
				["10042"] = 1,
				["6786"] = 1,
				["13869"] = 1,
				["4331"] = 1,
				["10001"] = 1,
				["2587"] = 1,
				["4308"] = 1,
				["7054"] = 1,
				["14155"] = 1,
				["4324"] = 1,
				["2580"] = 1,
				["5764"] = 1,
				["4325"] = 1,
				["4326"] = 1,
				["2997"] = 1,
				["6795"] = 1,
				["4311"] = 1,
				["6787"] = 1,
				["10045"] = 1,
				["22248"] = 1,
				["10050"] = 1,
				["7049"] = 1,
				["4333"] = 1,
				["10028"] = 1,
				["4240"] = 1,
				["6385"] = 1,
				["2579"] = 1,
				["13865"] = 1,
				["18486"] = 1,
				["4330"] = 1,
				["10051"] = 1,
				["4314"] = 1,
				["2577"] = 1,
				["10008"] = 1,
				["4245"] = 1,
				["10031"] = 1,
				["21341"] = 1,
				["6796"] = 1,
				["22246"] = 1,
				["7052"] = 1,
				["7055"] = 1,
				["7057"] = 1,
				["14046"] = 1,
				["13871"] = 1,
				["10044"] = 1,
				["14111"] = 1,
				["2582"] = 1,
				["4238"] = 1,
				["14112"] = 1,
				["4305"] = 1,
				["10033"] = 1,
				["2584"] = 1,
				["22249"] = 1,
				["10035"] = 1,
				["10021"] = 1,
				["2570"] = 1,
				["7061"] = 1,
				["13867"] = 1,
				["13856"] = 1,
				["10052"] = 1,
				["10025"] = 1,
				["4339"] = 1,
				["7065"] = 1,
				["14048"] = 1,
				["10046"] = 1,
				["2578"] = 1,
				["6263"] = 1,
				["10053"] = 1,
				["4316"] = 1,
				["7064"] = 1,
				["7056"] = 1,
				["10018"] = 1,
				["4334"] = 1,
				["4309"] = 1,
				["7046"] = 1,
				["5763"] = 1,
				["4310"] = 1,
				["10019"] = 1,
				["2572"] = 1,
				["5542"] = 1,
				["9998"] = 1,
				["4336"] = 1,
				["7063"] = 1,
				["2568"] = 1,
				["6240"] = 1,
				["10054"] = 1,
				["2575"] = 1,
				["6241"] = 1,
				["10047"] = 1,
			},
			["reagent"] = {
				["6371"] = 1,
				["4339"] = 1,
				["4234"] = 1,
				["10290"] = 1,
				["2589"] = 1,
				["2996"] = 1,
				["14342"] = 1,
				["13926"] = 1,
				["7069"] = 1,
				["7068"] = 1,
				["8170"] = 1,
				["14047"] = 1,
				["6261"] = 1,
				["20520"] = 1,
				["14341"] = 1,
				["7077"] = 1,
				["4306"] = 1,
				["2325"] = 1,
				["2320"] = 1,
				["4304"] = 1,
				["7071"] = 1,
				["2997"] = 1,
				["4342"] = 1,
				["7972"] = 1,
				["7070"] = 1,
				["8153"] = 1,
				["12808"] = 1,
				["929"] = 1,
				["16203"] = 1,
				["10286"] = 1,
				["2321"] = 1,
				["3577"] = 1,
				["2604"] = 1,
				["7067"] = 1,
				["4337"] = 1,
				["12662"] = 1,
				["4291"] = 1,
				["2319"] = 1,
				["4305"] = 1,
				["6260"] = 1,
				["3827"] = 1,
				["3383"] = 1,
				["14256"] = 1,
				["6037"] = 1,
				["14048"] = 1,
				["12810"] = 1,
				["5500"] = 1,
				["4338"] = 1,
				["4340"] = 1,
				["11137"] = 1,
				["7910"] = 1,
				["10285"] = 1,
				["7078"] = 1,
				["14344"] = 1,
				["2324"] = 1,
				["7080"] = 1,
				["12809"] = 1,
				["8343"] = 1,
				["2605"] = 1,
				["5498"] = 1,
				["14227"] = 1,
				["1529"] = 1,
				["3829"] = 1,
				["7079"] = 1,
				["3182"] = 1,
				["2318"] = 1,
				["2592"] = 1,
			},
		},
	};

local TBag_DefaultSecond = {
		["Cooking"] = {
			["created"] = {
				["2685"] = 1,
				["12218"] = 1,
				["6290"] = 1,
				["3220"] = 1,
				["3663"] = 1,
				["5472"] = 1,
				["13932"] = 1,
				["20452"] = 1,
				["2682"] = 1,
				["13934"] = 1,
				["5095"] = 1,
				["12212"] = 1,
				["12217"] = 1,
				["12209"] = 1,
				["1017"] = 1,
				["12216"] = 1,
				["6657"] = 1,
				["16766"] = 1,
				["3662"] = 1,
				["2681"] = 1,
				["12213"] = 1,
				["2687"] = 1,
				["5477"] = 1,
				["13851"] = 1,
				["18045"] = 1,
				["12214"] = 1,
				["13929"] = 1,
				["21217"] = 1,
				["3727"] = 1,
				["5476"] = 1,
				["13930"] = 1,
				["3726"] = 1,
				["13935"] = 1,
				["2680"] = 1,
				["3664"] = 1,
				["21072"] = 1,
				["2684"] = 1,
				["6890"] = 1,
				["6887"] = 1,
				["4457"] = 1,
				["13931"] = 1,
				["5527"] = 1,
				["6888"] = 1,
				["724"] = 1,
				["2683"] = 1,
				["2888"] = 1,
				["6038"] = 1,
				["4594"] = 1,
				["12215"] = 1,
				["13933"] = 1,
				["787"] = 1,
				["12224"] = 1,
				["12210"] = 1,
				["733"] = 1,
				["17222"] = 1,
				["8364"] = 1,
				["3666"] = 1,
				["17197"] = 1,
				["3729"] = 1,
				["18254"] = 1,
				["4593"] = 1,
				["1082"] = 1,
				["13927"] = 1,
				["3665"] = 1,
				["2679"] = 1,
				["10841"] = 1,
				["5479"] = 1,
				["20074"] = 1,
				["5525"] = 1,
				["7676"] = 1,
				["13928"] = 1,
				["4592"] = 1,
			},
			["reagent"] = {
				["5503"] = 1,
				["3685"] = 1,
				["3667"] = 1,
				["12205"] = 1,
				["13760"] = 1,
				["21153"] = 1,
				["3713"] = 1,
				["2674"] = 1,
				["3404"] = 1,
				["159"] = 1,
				["7974"] = 1,
				["6308"] = 1,
				["21071"] = 1,
				["17194"] = 1,
				["2894"] = 1,
				["20424"] = 1,
				["6522"] = 1,
				["4603"] = 1,
				["1015"] = 1,
				["12207"] = 1,
				["6289"] = 1,
				["1080"] = 1,
				["5468"] = 1,
				["729"] = 1,
				["4402"] = 1,
				["12203"] = 1,
				["5469"] = 1,
				["1468"] = 1,
				["769"] = 1,
				["13889"] = 1,
				["6362"] = 1,
				["3174"] = 1,
				["1179"] = 1,
				["12204"] = 1,
				["12208"] = 1,
				["2675"] = 1,
				["6291"] = 1,
				["12206"] = 1,
				["6303"] = 1,
				["12037"] = 1,
				["4536"] = 1,
				["2692"] = 1,
				["3172"] = 1,
				["3173"] = 1,
				["13758"] = 1,
				["731"] = 1,
				["3730"] = 1,
				["2452"] = 1,
				["13755"] = 1,
				["2673"] = 1,
				["3731"] = 1,
				["5504"] = 1,
				["730"] = 1,
				["2678"] = 1,
				["13756"] = 1,
				["2886"] = 1,
				["6889"] = 1,
				["5470"] = 1,
				["2665"] = 1,
				["12184"] = 1,
				["2596"] = 1,
				["1081"] = 1,
				["723"] = 1,
				["3712"] = 1,
				["13888"] = 1,
				["8365"] = 1,
				["18255"] = 1,
				["13759"] = 1,
				["4655"] = 1,
				["2251"] = 1,
				["12223"] = 1,
				["13754"] = 1,
				["12202"] = 1,
				["2672"] = 1,
				["6361"] = 1,
				["2924"] = 1,
				["13893"] = 1,
				["2677"] = 1,
				["3821"] = 1,
				["5465"] = 1,
			},
		},
		["First Aid"] = {
			["created"] = {
				["14530"] = 1,
				["1251"] = 1,
				["6451"] = 1,
				["6450"] = 1,
				["2581"] = 1,
				["3530"] = 1,
				["8545"] = 1,
				["3531"] = 1,
				["6452"] = 1,
				["14529"] = 1,
				["19440"] = 1,
				["8544"] = 1,
			},
			["reagent"] = {
				["19441"] = 1,
				["2589"] = 1,
				["2592"] = 1,
				["14047"] = 1,
				["4306"] = 1,
				["4338"] = 1,
				["1475"] = 1,
			},
		},
	};

local TBag_DefaultSkills = {
		["Mining"] = {
			["created"] = {
				["3859"] = 1,
				["2842"] = 1,
				["3860"] = 1,
				["2841"] = 1,
				["2840"] = 1,
				["3576"] = 1,
				["3575"] = 1,
				["3577"] = 1,
			},
			["reagent"] = {
				["2772"] = 1,
				["2840"] = 1,
				["2775"] = 1,
				["2776"] = 1,
				["3576"] = 1,
				["3858"] = 1,
				["2770"] = 1,
				["2771"] = 1,
				["3857"] = 1,
				["3575"] = 1,
			},
		},
		["Poisons"] = {
			["created"] = {
				["6949"] = 1,
				["10918"] = 1,
				["5237"] = 1,
				["6947"] = 1,
				["3775"] = 1,
			},
			["reagent"] = {
				["3371"] = 1,
				["2928"] = 1,
				["5173"] = 1,
				["2930"] = 1,
				["3372"] = 1,
			},
		},
	};


-----------------------------------------------------------------------
-- Main Bag and Item arrays
-----------------------------------------------------------------------

local TBAG_BAGMIN = -2;
local TBAG_BAGMAX = 11;
TInv_Bags = { 0, 4, 3, 2, 1, KEYRING_CONTAINER };
TBnk_Bags = { -1, 5, 6, 7, 8, 9, 10, 11 };
TBody_Slots = {
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
  ["RangedSlot"] = 18, 
  ["TabardSlot"] = 19
};

local TBAG_D_BAG = 69;    -- A dummy bag number for search format
local TBAG_D_ITEMID = "6948";  -- A dummy itemlink for searching mail

--[[ New data layout:

  bar, position = refers to the virtual locations
  bag, slot = refers to physical bag/slot

  itmcache[ bag ][ slot ]
    - Contains all the data we collect from the items in the bags.
    - We collect this data before sorting!
  bar_positions[ bar_number ][ position ] = { [TBAG_I_BAG]=bag, [TBAG_I_SLOT]=slot }
    - Contains the final locations in my window after sorting
  TBAG_BUTTONS[ frame_name ] = itmcache[bag][slot]
--]]

function TBag_Init()
  local bag;

  -- Set up the main arrays
  if (TBagCfg == nil) then
    TBagCfg = {};
    TBagCfg["Bnk"] = {};
    TBagCfg["Inv"] = {};
    TBagCfg["Body"] = {};
    TBagCfg[TBAG_S_TRADES] = TBag_DefaultTrades;
    TBagCfg[TBAG_S_SECOND] = TBag_DefaultSecond;
    TBagCfg[TBAG_S_SKILLS] = TBag_DefaultSkills;
  end

  if (TBagInfo == nil) then
    TBagInfo = {};
  end
  if (TInvItm == nil) then
    TInvItm = {};
  end
  if (TBnkItm == nil) then
    TBnkItm = {};
  end
  if (TContItm == nil) then
    TContItm = {};
  end
  if (TBodyItm == nil) then
    TBodyItm = {};
  end
  if (TMailItm == nil) then
    TMailItm = {};
  end
  if (TItmNameIDMap == nil) then
    TItmNameIDMap = {};
  end

  -- Set up the main player arrays
  TBAG_PLAYERID = UnitName("player").."|"..TBAG_REALM;

  if (TBagInfo[TBAG_PLAYERID] == nil) then
    TBag_InitPlayerInfo(TBAG_PLAYERID);
  end
  if (TInvItm[TBAG_PLAYERID] == nil) then
    TInvItm[TBAG_PLAYERID] = {};
    TBag_ClearItmCache(TInvItm[TBAG_PLAYERID], TInv_Bags);
  end
  if (TBnkItm[TBAG_PLAYERID] == nil) then
    TBnkItm[TBAG_PLAYERID] = {};
    TBag_ClearItmCache(TBnkItm[TBAG_PLAYERID], TBnk_Bags);
  end
  if (TContItm[TBAG_PLAYERID] == nil) then
    TContItm[TBAG_PLAYERID] = {};
    TContItm[TBAG_PLAYERID][TBAG_D_BAG] = {};
    TBag_ClearItmCache(TContItm[TBAG_PLAYERID][TBAG_D_BAG], TInv_Bags);
    TBag_ClearItmCache(TContItm[TBAG_PLAYERID][TBAG_D_BAG], TBnk_Bags);
  end
  if (TBodyItm[TBAG_PLAYERID] == nil) then
    TBodyItm[TBAG_PLAYERID] = {};
    TBodyItm[TBAG_PLAYERID][TBAG_D_BAG] = {};
    TBag_ClearItmCache(TBodyItm[TBAG_PLAYERID][TBAG_D_BAG], TBody_Slots);
  end
  if (TMailItm[TBAG_PLAYERID] == nil) then
    TMailItm[TBAG_PLAYERID] = {};
    TMailItm[TBAG_PLAYERID][TBAG_D_BAG] = {};
  end

  -- Force the KEYRING_CONTAINER frame's id to -2.  Can't set frames to
  -- negative values from XML. :(
  getglobal(TBag_GetDummyBagFrameName(KEYRING_CONTAINER)):SetID(-2);
  
  -- Initialize any player related info
  local group;
  group = TBagInfo[TBAG_PLAYERID][TBAG_G_BASIC];
  _, group[TBAG_S_CLASS] = UnitClass("player");

  -- And reset the keybinding, if need be
  LoadAddOn("Blizzard_BindingUI");
end

function TBag_ChangeKeybind()
  if (GetBindingKey("TINV_TOGGLE") == nil) then
    -- Swipe the key from the backpack
    local key1, key2 = GetBindingKey("TOGGLEBACKPACK");
    if (key1) then
      SetBinding(key1, "TINV_TOGGLE");
      TBag_Print(TBAG_SCP.."Setting keybind to '"..key1.."'", 1, 1, 1);
      SaveBindings(GetCurrentBindingSet());
    elseif (key2) then
      SetBinding(key2, "TINV_TOGGLE");
      TBag_Print(TBAG_SCP.."Setting keybind to '"..key2.."'", 1, 1, 1);
      SaveBindings(GetCurrentBindingSet());
    end
  end
end

-----------------------------------------------------------------------
-- UTILITY Funcs
-----------------------------------------------------------------------

function TBag_PrintDEBUG(msg,r,g,b,frame,id,unknown4th)
  if ((TBag_DEBUGMESSAGES) == 1 or (TINV_DEBUGMESSAGES == 1)) then
    TBag_Print(msg,r,g,b,frame,id,unknown4th)
  end
end

function TBag_Print(msg,r,g,b,frame,id,unknown4th)
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

function TBag_Trim(s)
  return string.trim(s);
end

function TBag_ReverseString(strtorev,toggle)
  local out = "", s1, s2;

  s2 = strtorev;

  if toggle==2 then
  repeat
    s1, s2 = TBag_SplitSpace(s2);
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

function TBag_GetSafeVal(arr, idx, val)
  if (arr == nil) then
    return val;
  elseif (arr[idx] == nil) then
    return val;
  else
    return arr[idx];
  end
end

function TBag_InitPlayerInfo(playerid)
  TBagInfo[playerid] = {};
  TBagInfo[playerid][TBAG_S_TRADES] = {};
  TBagInfo[playerid][TBAG_S_SECOND] = {};
  TBagInfo[playerid][TBAG_S_SKILLS] = {};

  TBagInfo[playerid][TBAG_G_BASIC] = {};
  TBagInfo[playerid][TBAG_G_XP] = {};
  TBagInfo[playerid][TBAG_G_PVP] = {};
  TBagInfo[playerid][TBAG_G_STATS] = {};
  TBagInfo[playerid][TBAG_G_RESISTS] = {};
  TBagInfo[playerid][TBAG_G_COMBAT] = {};
  TBagInfo[playerid][TBAG_G_MELEE] = {};
  TBagInfo[playerid][TBAG_G_RANGE] = {};
  TBagInfo[playerid][TBAG_G_SPELL] = {};
end

function TBag_GetPlayer(playerid)
  if (TBagInfo[playerid] == nil) then
    TBag_InitPlayerInfo(playerid);
  end
  return TBagInfo[playerid];
end

function TBag_GetPlayerInfo(playerid, name)
  return TBag_GetPlayer(playerid)[name];
end

function TBag_SetPlayerInfo(playerid, name, val)
  TBag_GetPlayer(playerid)[name] = val;
end

function TBag_GetPlayerBag(playerid, bag)
  if (TContItm[playerid] == nil) then
    TContItm[playerid] = {};
  end
  if (TContItm[playerid][TBAG_D_BAG] == nil) then
    TContItm[playerid][TBAG_D_BAG] = {};
  end

  local bags = TContItm[playerid][TBAG_D_BAG];
  if (bags[bag] == nil) then
    bags[bag] = { 
      [TBAG_I_BAGFREE] = 0, 
      [TBAG_I_BAGSIZE] = 0, 
      [TBAG_I_BAGTYPE] = "", 
      [TBAG_I_ITEMLINK] = nil,
      [TBAG_I_ITEMID] = nil,
      [TBAG_I_NAME] = nil,
      [TBAG_I_COUNT] = nil,
      [TBAG_I_NEED] = nil
    };
  end
  return bags[bag];
end

function TBag_GetPlayerBagCfg(playerid, bag, name)
  return TBag_GetPlayerBag(playerid, bag)[name];
end

function TBag_SetPlayerBagCfg(playerid, bag, name, val)
--  TBag_Print(playerid..", bag ="..bag..", name ="..name);
  TBag_GetPlayerBag(playerid, bag)[name] = val;
end

function TBag_SplitSpace(strtosplit)
  if (strtosplit) then
    local str1 = strtosplit;
    local str2 = "";
    local idx = strfind(strtosplit, " ");

    if ( idx ) then
      str1 = strsub(strtosplit, 1, idx-1);
      str2 = strsub(strtosplit, idx+1);
    end

    return str1, str2;
  else
    return "", "";
  end
end

function TBag_Table_RemoveKey(tab, key)
  local temptab = {};

  for k,v in pairs(tab) do
    if (k ~= key) then
      temptab[k] = v;
    end
  end

  return temptab;
end

function TBag_Split(toCut, separator)
  local splitted = {};
  local i = 0;
  local regEx = "([^" .. separator .. "]*)" .. separator .. "?";

  for item in string.gmatch(toCut .. separator, regEx) do
    i = i + 1;
    splitted[i] = TBag_Trim(item) or '';
  end
  splitted[i] = nil;
  return splitted;
end

function TBag_ClearItmCache(itmcache, bagarr)
  local bag;

  for _, bag in pairs(bagarr) do
    itmcache[bag] = {};
  end

  return itmcache;
end

function TBag_CreateDummyBag(bag, template)
  local dbag = getglobal(TBag_GetDummyBagFrameName(bag));

  if (dbag) then
    local buttonname;

    for slot = 1, TBAG_BAGSIZE_MAX do
      buttonname = TBag_GetBagItemButtonName(bag, slot);
      if not (getglobal(buttonname)) then
        CreateFrame("Button", buttonname, dbag, template);
        getglobal(buttonname):SetID(slot);
        getglobal(buttonname):Hide();
      end
    end
  end
end

function TBag_CreateFrame(type, name, parent, template, num, append)
  local idx;
  if (num) then
    for idx = 1, num do
      if not (getglobal(name..idx..append)) then
        CreateFrame(type, name..idx..append, parent, template);
      end
    end
  else
    if not (getglobal(name)) then
      CreateFrame(type, name, parent, template);
    end
  end
end

function TBag_CreateLayer(type, name, parent, template, num, append)
  local idx;
  if (num) then
    for idx = 1, num do
      if not (getglobal(name..idx..append)) then
--        CreateLayer(type, name..idx..append, parent, template);
      end
    end
  else
    if not (getglobal(name)) then
--      CreateLayer(type, name, parent, template);
    end
  end
end

function TBag_ResetNew(itm)
  if (itm) then
    itm[TBAG_I_TIMESTAMP] = 1;
    itm[TBAG_I_NEWSTR] = TBAG_V_NEWOFF;
  end
end

function TBag_GetItemInfo(itemid)
  if (itemid) then
    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, invTexture = GetItemInfo(itemid);
    return itemName, itemType, itemSubType, itemRarity, itemLink, itemStackCount;
  else
    return;
  end
end

function TBag_GetItemTexture(itemid)
  local _, _, _, _, _, _, _, _, _, invTexture = GetItemInfo(itemid);
  return invTexture;
end

function TBag_GetItemID(link)
  local itemid, itemlink;
  local a,b,c,d;

  if ( (link ~= nil) and (type(link) == "string") ) then
    _, _, a,b,c,d,e,f,g,h = string.find(link, "item:(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%-?%d+):(%-?%d+)");
    if (a) then
      itemid = a;
      itemlink = "item:"..a..":"..b..":"..c..":"..d..":"..e..":"..f..":"..g..":"..h
    end
  end

  if (itemid) then
    return itemid, itemlink;
  else
    return "", "";
  end
end

function TBag_GetItemIDFromName(name)
  -- First raid ItemSync if we can
  if (ISyncDB_Names) then
    for itemid, itemname in pairs(ISyncDB_Names) do
      if (itemname and name == itemname) then
        return tostring(itemid);
      end
    end
  end

  -- Then check our homebrewed cache if need be
  if (TItmNameIDMap[name]) then
    return TItmNameIDMap[name];
  end

  -- Do a brute force search over all items, and cache the result
  for itemid = 1, 30000 do
    itemname = GetItemInfo(itemid)
      if (itemname and name == itemname) then
        TItmNameIDMap[name] = tostring(itemid);
        return tostring(itemid);
	  end
  end

  -- Well, return something
  return TBAG_D_ITEMID;
end


-----------------------------------------------------------------------
-- Searching
-----------------------------------------------------------------------

local TBag_SrchResults = {};
local SC_NONE   = "|cffff1111";
local SC_PLAYER = "|cff11ccee";
local SC_TOTAL  = "|cffeeff11";
local SC_WHITE  = "|cffffffff";

function TBag_PlacePrep(place)
  if (place == "body") then
    return " on ";
  elseif (place == "container") then
    return " as ";
  else
    return " in ";
  end
end

function TBag_AddSearchResult(itemid, playername, place, count)
  TBag_PrintDEBUG("TBag_AddSearchResult "..count.." "..itemid
    ..TBag_PlacePrep(place)..playername.."'s "..place);

  -- First see if this result has been added before
  if (TBag_SrchResults[itemid] == nil) then
    TBag_SrchResults[itemid] = {};
  end
  if (TBag_SrchResults[itemid][playername] == nil) then
    TBag_SrchResults[itemid][playername] = {};
  end
  if (TBag_SrchResults[itemid][playername][place] == nil) then
    TBag_SrchResults[itemid][playername][place] = count;
  else
    TBag_SrchResults[itemid][playername][place] = TBag_SrchResults[itemid][playername][place] + count;
  end
end

function TBag_GatherSearchResults(srch, itmcache, place)
  local playername;

  for playerid, bagarr in pairs(itmcache) do
    playername = TBag_Split(playerid, "|")[1];

    -- Only include results from this realm
    if (TBag_Split(playerid, "|")[2] == TBAG_REALM) then
      TBag_PrintDEBUG("TBag_GatherSearchResults for "..playername.."'s "..place);
      for _, slotarr in pairs(bagarr) do
        for _, itm in pairs(slotarr) do
          -- Exclude empty slots
          if (itm[TBAG_I_ITEMID]) and (itm[TBAG_I_NAME]) then
            -- Do case insensitive searches
            if (string.find(string.lower(itm[TBAG_I_NAME]), srch)) then
              TBag_AddSearchResult(itm[TBAG_I_ITEMLINK], playername, place, itm[TBAG_I_COUNT]);
            end
          end
        end
      end
    end
  end
end

function TBag_JustifyStr(str, width, color)
  local length = strlen(tostring(str));
  local result = "";
  while (length < width) do
    result = result.."  ";
    length = length + 1;
  end
  return result..color..str.."|r";
end

function TBag_DisplaySearchResult(aResult, itemlink)
  local chatframe = DEFAULT_CHAT_FRAME;
  local hyperlink = TBag_MakeHyperlink(itemlink);
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
    chatframe:AddMessage(TBag_JustifyStr(total, 3, SC_TOTAL).." "..hyperlink.." found:", .7, .7, .7);
  end

  -- Then write out a line for each of the place results
  for playername, places in pairs(aResult) do
    for place, count in pairs(places) do
      if (lines == 1) then
        chatframe:AddMessage(TBag_JustifyStr(count, 3, SC_TOTAL).." "..hyperlink..TBag_PlacePrep(place)..SC_PLAYER..playername.."|r's "..place, .7, .7, .7);
      elseif (lines > 1) then
        chatframe:AddMessage(TBag_JustifyStr(count, 6, SC_WHITE)..TBag_PlacePrep(place)..SC_PLAYER..playername.."|r's "..place, .7, .7, .7);
      end
    end
  end
end

function TBag_DoSearch(srch)
  TBag_SrchResults = {};
  
  if (srch) then
    local found;
    
    -- Gather all the search info
    TBag_GatherSearchResults(string.lower(srch), TInvItm, "bags");
    TBag_GatherSearchResults(string.lower(srch), TBnkItm, "bank");
    TBag_GatherSearchResults(string.lower(srch), TContItm, "container");
    TBag_GatherSearchResults(string.lower(srch), TBodyItm, "body");
    TBag_GatherSearchResults(string.lower(srch), TMailItm, "mail");

    -- Sort it alphabetically
    table.sort(TBag_SrchResults);
    for _, playerarr in pairs(TBag_SrchResults) do
      table.sort(playerarr);
    end

    -- Display all the search results
    for itemlink, aResult in pairs(TBag_SrchResults) do
      if (not found) then
        DEFAULT_CHAT_FRAME:AddMessage(TBAG_SCP.."Search results for '"..srch.."':", 1, 1, 1);
      end
      TBag_DisplaySearchResult(aResult, itemlink);
      found = 1;
    end

    -- If there's no results, say so
    if (not found) then
      DEFAULT_CHAT_FRAME:AddMessage(TBAG_SCP..SC_NONE.."No results|r for '"..srch.."'");
    end
  end
end


-----------------------------------------------------------------------
-- Configuration
-----------------------------------------------------------------------

function TBag_SetDef(cfg, var, defval, reset, cleanfunc, param1, param2)
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

function TBag_SetGrpDef(cfg, grp, var, defval, reset, cleanfunc, param1, param2)
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

function TBag_GetGrp(cfg, grp, var)
  if (cfg) and (grp) then
    if (cfg[grp] == nil) then
      cfg[grp] = {};
      return nil;
    end
    return cfg[grp][var];
  end
end

function TBag_NumFunc(value, lowest, highest)
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

function TBag_StrFunc(value, choices_array)
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

function TBag_NicePlacement(buttonsize)
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
function TBag_SetDefLayout(cfg, bagarr, row1offset, reset)
  -- wipe the array if we are resetting
  if (reset == 1) and (cfg) then cfg[TBAG_CAT_BAR] = {}; end

-- Eighth default line (top) - Empty and Act Ons
  TBag_SetCatBar(cfg, "EMPTY_AMMO_SLOTS", 32, reset);
  TBag_SetCatBar(cfg, "IN_AMMO_BAG", 32, reset);
  TBag_SetCatBar(cfg, "EMPTY_SOUL_SLOTS", 32, reset);
  TBag_SetCatBar(cfg, "IN_SOUL_BAG", 32, reset);
  -- arrows and bullets that AREN'T in your shot bags
  TBag_SetCatBar(cfg, "PROJECTILE", 32, reset);
  -- soulshards that AREN'T in your soul bags
  TBag_SetCatBar(cfg, "SOULSHARD", 32, reset);

  TBag_SetCatBar(cfg, "MISC", 31, reset);
  TBag_SetCatBar(cfg, "UNKNOWN", 31, reset);

  TBag_SetCatBar(cfg, "CONSUMABLE", 30, reset);

  TBag_SetCatBar(cfg, "ACT_ON", 29, reset);
  TBag_SetCatBar(cfg, "ACT_OPEN", 29, reset);
  TBag_SetCatBar(cfg, "ACT_SELL", 29, reset);
  TBag_SetCatBar(cfg, "BAG", 29, reset);
  TBag_SetCatBar(cfg, "GRAY_ITEMS", 29, reset); 

  local bag;
  for _, bag in ipairs(bagarr) do
    TBag_SetCatBar(cfg, "EMPTY_"..TBag_GetBagPosName(bag).."_SLOTS", 29, reset); 
  end

-- Seventh default line - Quests and Factions
  TBag_SetCatBar(cfg, "QUEST", 28, reset);
  TBag_SetCatBar(cfg, "SOULBOUND_OTHER", 28, reset); 

  TBag_SetCatBar(cfg, "THORIUM_BROTHER", 27, reset);
  TBag_SetCatBar(cfg, "TIMBERMAW", 27, reset);
  TBag_SetCatBar(cfg, "KEY_QUEST", 27, reset);

  TBag_SetCatBar(cfg, "IN_KEYRING_BAG", 26, reset);
  TBag_SetCatBar(cfg, "EMPTY_KEYRING_SLOTS", 26, reset);
  TBag_SetCatBar(cfg, "PVP", 26, reset);

  TBag_SetCatBar(cfg, "ENCHANTS", 25, reset);
  TBag_SetCatBar(cfg, "BOOK", 25, reset);
  TBag_SetCatBar(cfg, "DESIGN", 25, reset);
  TBag_SetCatBar(cfg, "FORMULA", 25, reset);
  TBag_SetCatBar(cfg, "RECIPE", 25, reset);
  TBag_SetCatBar(cfg, "PATTERN", 25, reset);
  TBag_SetCatBar(cfg, "PLANS", 25, reset);
  TBag_SetCatBar(cfg, "SCHEMATIC", 25, reset);
  TBag_SetCatBar(cfg, "RECIPE_OTHER", 25, reset);

-- Sixth default line - Collectibles 
  TBag_SetCatBar(cfg, "ARGENT_DAWN", 24, reset);

  TBag_SetCatBar(cfg, "AHN_QIRAJ", 23, reset);
  TBag_SetCatBar(cfg, "CENARION_CIRCLE", 23, reset);

  TBag_SetCatBar(cfg, "BLACKWING_LAIR", 22, reset);
  TBag_SetCatBar(cfg, "DARKMOON_FAIRE", 22, reset);

  TBag_SetCatBar(cfg, "MOLTEN_CORE", 21, reset);
  TBag_SetCatBar(cfg, "ZUL_GURUB", 21, reset);

-- Fifth default line - To Sell
  TBag_SetCatBar(cfg, "REAGENT", 20, reset);

  TBag_SetCatBar(cfg, "TRADE_GOODS", 19, reset);
  TBag_SetCatBar(cfg, "ALCHEMY", 19, reset);
  TBag_SetCatBar(cfg, "BLACKSMITHING", 19, reset);
  TBag_SetCatBar(cfg, "ENCHANTING", 19, reset);
  TBag_SetCatBar(cfg, "ENGINEERING", 19, reset);
  TBag_SetCatBar(cfg, "JEWELCRAFTING", 19, reset);
  TBag_SetCatBar(cfg, "LEATHERWORKING", 19, reset);
  TBag_SetCatBar(cfg, "POISONS", 19, reset);
  TBag_SetCatBar(cfg, "TAILORING", 19, reset);

  TBag_SetCatBar(cfg, "RELIC", 18, reset);
  TBag_SetCatBar(cfg, "RING", 18, reset);
  TBag_SetCatBar(cfg, "TRINKET", 18, reset);

  TBag_SetCatBar(cfg, "ARMOR", 17, reset);
  TBag_SetCatBar(cfg, "WEAPON", 17, reset);

-- Fourth default line - To Use or Sell
  TBag_SetCatBar(cfg, "TRADE1", 16, reset);
  TBag_SetCatBar(cfg, "TRADE2", 16, reset);
  TBag_SetCatBar(cfg, "EMPTY_PROF_SLOTS", 16, reset);
  TBag_SetCatBar(cfg, "IN_PROF_BAG", 16, reset);

  TBag_SetCatBar(cfg, "CLOTH", 15, reset);
  TBag_SetCatBar(cfg, "FIRST_AID", 15, reset);

  TBag_SetCatBar(cfg, "COOKING", 14, reset);
  TBag_SetCatBar(cfg, "SOULBOUND_RELIC", 14, reset);
  TBag_SetCatBar(cfg, "SOULBOUND_RING", 14, reset);
  TBag_SetCatBar(cfg, "SOULBOUND_TRINKET", 14, reset);

  TBag_SetCatBar(cfg, "SOULBOUND_ARMOR", 13, reset);
  TBag_SetCatBar(cfg, "SOULBOUND_WEAPON", 13, reset);
  TBag_SetCatBar(cfg, "TRADE1_CREATED", 13, reset);
  TBag_SetCatBar(cfg, "TRADE2_CREATED", 13, reset);

-- Third default line - Swappables
  TBag_SetCatBar(cfg, "MINIPET", 12, reset);
  TBag_SetCatBar(cfg, "MOUNT", 12, reset);

  TBag_SetCatBar(cfg, "FISHING", 11, reset);
  TBag_SetCatBar(cfg, "TRADE_TOOL", 11, reset);
  TBag_SetCatBar(cfg, "CLASS_TOOL", 11, reset);

  TBag_SetCatBar(cfg, "EQUIPPED_RELIC", 10, reset);
  TBag_SetCatBar(cfg, "EQUIPPED_RING", 10, reset);
  TBag_SetCatBar(cfg, "EQUIPPED_TRINKET", 10, reset);
  TBag_SetCatBar(cfg, "EQUIPPED_OTHER", 10, reset);

  TBag_SetCatBar(cfg, "EQUIPPED_ARMOR", 9, reset);
  TBag_SetCatBar(cfg, "EQUIPPED_WEAPON", 9, reset);

-- Second default line - Out of Combat Stocks
  TBag_SetCatBar(cfg, "FOOD", 8, reset);
  TBag_SetCatBar(cfg, "FOOD_BUFF", 8, reset);

  TBag_SetCatBar(cfg, "DRINK", 7, reset);
  TBag_SetCatBar(cfg, "COMBO", 7, reset);

  TBag_SetCatBar(cfg, "BUFF", 6, reset);
  TBag_SetCatBar(cfg, "POISONS_CREATED", 6, reset);

  TBag_SetCatBar(cfg, "CLASS_REAGENT", 5, reset);
  TBag_SetCatBar(cfg, "DUMMY", 5, reset);
  TBag_SetCatBar(cfg, "KEY_OPEN", 5, reset);

-- First default line - In Combat Stocks
  TBag_SetCatBar(cfg, "BANDAGE", 4+row1offset, reset);
  TBag_SetCatBar(cfg, "HEALTH_RESTORE", 4+row1offset, reset);
  TBag_SetCatBar(cfg, "HEALTHSTONE", 4+row1offset, reset);

  TBag_SetCatBar(cfg, "MANA_RESTORE", 3+row1offset, reset);
  TBag_SetCatBar(cfg, "COMBO_RESTORE", 3+row1offset, reset);
  TBag_SetCatBar(cfg, "RAGE_RESTORE", 3+row1offset, reset);
  TBag_SetCatBar(cfg, "ENERGY_RESTORE", 3+row1offset, reset);

  TBag_SetCatBar(cfg, "CURE", 2+row1offset, reset);
  TBag_SetCatBar(cfg, "EXPLOSIVES", 2+row1offset, reset);

  TBag_SetCatBar(cfg, "HEARTH", 1+row1offset, reset);

  table.sort(TBag_GetCatBar(cfg));
end


local TBAG_BKGR_A = 0.4;
local TBAG_BRDR_A = 0.5;

function TBag_SetDefColors(cfg, reset)
  TBag_SetColor(cfg, "newitem", 0.9, 0.9, 0.25, 1.0, reset);
  TBag_SetColor(cfg, "recentitem", 0.0, 1.0, 0.4, 1.0, reset);

  -- Red healing
  TBag_SetColor(cfg, "bkgr_4", 0.8, 0.1, 0.1, TBAG_BKGR_A, reset);
  TBag_SetColor(cfg, "brdr_4", 0.8, 0.1, 0.1, TBAG_BRDR_A, reset);

  TBag_SetColor(cfg, "bkgr_8", 0.8, 0.1, 0.1, TBAG_BKGR_A, reset);
  TBag_SetColor(cfg, "brdr_8", 0.8, 0.1, 0.1, TBAG_BRDR_A, reset);

  -- Blue mana
  TBag_SetColor(cfg, "bkgr_3", 0.1, 0.1, 1.0, TBAG_BKGR_A, reset);
  TBag_SetColor(cfg, "brdr_3", 0.1, 0.1, 1.0, TBAG_BRDR_A, reset);

  TBag_SetColor(cfg, "bkgr_7", 0.1, 0.1, 1.0, TBAG_BKGR_A, reset);
  TBag_SetColor(cfg, "brdr_7", 0.1, 0.1, 1.0, TBAG_BRDR_A, reset);

  -- Green Buffs
  TBag_SetColor(cfg, "bkgr_2", 0.1, 0.8, 0.1, TBAG_BKGR_A, reset);
  TBag_SetColor(cfg, "brdr_2", 0.1, 0.8, 0.1, TBAG_BRDR_A, reset);

  TBag_SetColor(cfg, "bkgr_6", 0.1, 0.8, 0.1, TBAG_BKGR_A, reset);
  TBag_SetColor(cfg, "brdr_6", 0.1, 0.8, 0.1, TBAG_BRDR_A, reset);

  -- Yellow trade
  TBag_SetColor(cfg, "bkgr_15", 0.9, 0.9, 0.1, TBAG_BKGR_A, reset);
  TBag_SetColor(cfg, "brdr_15", 0.9, 0.9, 0.1, TBAG_BRDR_A, reset);

  TBag_SetColor(cfg, "bkgr_16", 0.9, 0.9, 0.1, TBAG_BKGR_A, reset);
  TBag_SetColor(cfg, "brdr_16", 0.9, 0.9, 0.1, TBAG_BRDR_A, reset);

  TBag_SetColor(cfg, "bkgr_19", 0.9, 0.9, 0.1, TBAG_BKGR_A, reset);
  TBag_SetColor(cfg, "brdr_19", 0.9, 0.9, 0.1, TBAG_BRDR_A, reset);

  TBag_SetColor(cfg, "bkgr_20", 0.9, 0.9, 0.1, TBAG_BKGR_A, reset);
  TBag_SetColor(cfg, "brdr_20", 0.9, 0.9, 0.1, TBAG_BRDR_A, reset);

  -- White equipment
  TBag_SetColor(cfg, "bkgr_9", 0.65, 0.7, 0.75, TBAG_BKGR_A, reset);
  TBag_SetColor(cfg, "brdr_9", 0.65, 0.7, 0.75, TBAG_BRDR_A, reset);

  TBag_SetColor(cfg, "bkgr_10", 0.65, 0.7, 0.75, TBAG_BKGR_A, reset);
  TBag_SetColor(cfg, "brdr_10", 0.65, 0.7, 0.75, TBAG_BRDR_A, reset);

  TBag_SetColor(cfg, "bkgr_13", 0.65, 0.7, 0.75, TBAG_BKGR_A, reset);
  TBag_SetColor(cfg, "brdr_13", 0.65, 0.7, 0.75, TBAG_BRDR_A, reset);

  TBag_SetColor(cfg, "bkgr_17", 0.65, 0.7, 0.75, TBAG_BKGR_A, reset);
  TBag_SetColor(cfg, "brdr_17", 0.65, 0.7, 0.75, TBAG_BRDR_A, reset);

  TBag_SetColor(cfg, "bkgr_18", 0.65, 0.7, 0.75, TBAG_BKGR_A, reset);
  TBag_SetColor(cfg, "brdr_18", 0.65, 0.7, 0.75, TBAG_BRDR_A, reset);

  -- purple ammo / shards
  TBag_SetColor(cfg, "bkgr_28", 0.8, 0.3, 0.9, TBAG_BKGR_A, reset);
  TBag_SetColor(cfg, "brdr_28", 0.8, 0.3, 0.9, TBAG_BRDR_A, reset);
end

-- set reset to 1 to restore all default values
function TBag_InitDefVals(cfg, bagarr, row1offset, reset)
  local i, key, value;

  TBag_SetDef(cfg, "moveLock", 1, reset, TBag_NumFunc, 0,1);
  TBag_SetDef(cfg, "show_bag_icons", 0, reset, TBag_NumFunc, 0, 1);
  TBag_SetDef(cfg, "spotlight_open", 1, reset, TBag_NumFunc, 0, 1);
  TBag_SetDef(cfg, "spotlight_hover", 1, reset, TBag_NumFunc, 0, 1);
  TBag_SetDef(cfg, "show_blizzard_frames", 0, reset, TBag_NumFunc, 0, 1);

  TBag_SetDef(cfg, "stack_auto", 1, reset, TBag_NumFunc, 0, 1);
  TBag_SetDef(cfg, "stack_resort", 1, reset, TBag_NumFunc, 0, 1);

  TBag_SetDef(cfg, "bar_x", 4, reset, TBag_NumFunc, 1, TBAG_NUMCOL_MAX);
  TBag_SetDef(cfg, "scale", 1, reset, TBag_NumFunc, 0.1, 1.0);
  TBag_SetDef(cfg, "frameButtonSize", 34, reset, TBag_NumFunc, TBAG_N_BUTTON_MIN, TBAG_N_BUTTON_MAX);

  TBag_SetDef(cfg, "framePad", 1, reset, TBag_NumFunc, 0, TBAG_N_SPACE_MAX);
  TBag_SetDef(cfg, "frameXSpace", 1, reset, TBag_NumFunc, 0, TBAG_N_SPACE_MAX);
  TBag_SetDef(cfg, "frameYSpace", 1, reset, TBag_NumFunc, 0, TBAG_N_SPACE_MAX);
  TBag_SetDef(cfg, "frameXPool", 1, reset, TBag_NumFunc, 0, TBAG_N_SPACE_MAX);
  TBag_SetDef(cfg, "frameYPool", 2, reset, TBag_NumFunc, 0, TBAG_N_SPACE_MAX);
  TBag_SetDef(cfg, "count_font", 14, reset, TBag_NumFunc, TBAG_N_FONT_MIN, TBAG_N_FONT_MAX);
  TBag_SetDef(cfg, "count_font_x", 2, reset, TBag_NumFunc, 0, TBAG_N_BUTTON_MAX);
  TBag_SetDef(cfg, "count_font_y", 2, reset, TBag_NumFunc, 0, TBAG_N_BUTTON_MAX);
  TBag_SetDef(cfg, "new_font", 12, reset, TBag_NumFunc, TBAG_N_FONT_MIN, TBAG_N_FONT_MAX);

  TBag_SetDef(cfg, "show_top_gfx", 0, reset, TBag_NumFunc, 0, 1);
  TBag_SetDef(cfg, "show_bag_sizes", 0, reset, TBag_NumFunc, 0, 1);
  TBag_SetDef(cfg, "special_bag_sort", 1, reset, TBag_NumFunc, 0, 1);
  TBag_SetDef(cfg, "trade_created_sort", 0, reset, TBag_NumFunc, 0, 1);

  TBag_SetDef(cfg, TBAG_V_NEWON, "**", reset);
  TBag_SetDef(cfg, TBAG_V_NEWPLUS, "++", reset);
  TBag_SetDef(cfg, TBAG_V_NEWMINUS, "--", reset);
  TBag_SetDef(cfg, TBAG_V_NEWOFF, "", reset);
  TBag_SetDef(cfg, "newItemTimeout", 60*3 , reset, TBag_NumFunc);   -- 3 hours for an item to lose "new" status
  TBag_SetDef(cfg, "recentTimeout", 10 , reset, TBag_NumFunc);  -- 10 minutes

  -- Do the layout
  TBag_SetDefLayout(cfg, bagarr, row1offset, reset);

  local bag, idx;
  for idx, bag in ipairs(bagarr) do
    if (bag == KEYRING_CONTAINER) then
      TBag_SetDef(cfg, "show_Bag"..bag, 0, reset, TBag_NumFunc, 0, 1);
    else
      TBag_SetDef(cfg, "show_Bag"..bag, 1, reset, TBag_NumFunc, 0, 1);
    end
    TBag_SetColor(cfg, "bag_"..bag, 
      TBAG_DBC[idx]["r"], TBAG_DBC[idx]["g"], TBAG_DBC[idx]["b"], TBAG_DBC[idx]["a"], reset);
  end

  -- default item overrides
  TBag_SetDef(cfg, "itemoverride_loaddefaults", 1, reset, TBag_NumFunc, 0, 1);
  if (cfg["itemoverride_loaddefaults"] == 1) then
    cfg["item_overrides"] = {};
    cfg["item_search_list"] = TBag_DefaultSearchList;

    for key, value in ipairs(cfg["item_search_list"]) do
      -- Localize all the string
      cfg["item_search_list"][key][1] = TBag_Cat(value[1]);
      cfg["item_search_list"][key][2] = TBag_Cat(value[2]);
      cfg["item_search_list"][key][3] = TBag_Loc(value[3]);
      cfg["item_search_list"][key][4] = TBag_Loc(value[4]);
      cfg["item_search_list"][key][5] = TBag_Loc(value[5]);
    end

    cfg["itemoverride_loaddefaults"] = 0;
  end

  -- Put in a default class cat, in case we reset
  TBag_SetClassCats(cfg, TBAG_PLAYERID, reset);

  -- default sort views / default "allow new items in bar" settings
  if (reset ~= 1) then
    TBag_SetGrpDef(cfg, TBAG_G_BAR_SORT, 16, TBAG_SORTBY_REV, reset, TBag_NumFunc, TBAG_SORTBY_MIN, TBAG_SORTBY_MAX);
    for i = 19, 24 do
      TBag_SetGrpDef(cfg, TBAG_G_BAR_SORT, i, TBAG_SORTBY_REV, reset, TBag_NumFunc, TBAG_SORTBY_MIN, TBAG_SORTBY_MAX);
    end
  end

  for i = 1, TBAG_BAR_MAX do
    TBag_SetGrpDef(cfg, TBAG_G_BAR_SORT, i, TBAG_SORTBY_NORM, reset, TBag_NumFunc, TBAG_SORTBY_MIN, TBAG_SORTBY_MAX);
    TBag_SetGrpDef(cfg, TBAG_G_USE_NEW, i, 1, reset, TBag_NumFunc, 0, 1);  
  end

  if (reset == 1) then
    TBag_SetGrpDef(cfg, TBAG_G_BAR_SORT, 16, TBAG_SORTBY_REV, reset, TBag_NumFunc, TBAG_SORTBY_MIN, TBAG_SORTBY_MAX);
    for i = 19, 24 do
      TBag_SetGrpDef(cfg, TBAG_G_BAR_SORT, i, TBAG_SORTBY_REV, reset, TBag_NumFunc, TBAG_SORTBY_MIN, TBAG_SORTBY_MAX);
    end
  end

  TBag_AssignCats(cfg, reset);
end

function TBag_AssignCats(cfg, reset)
  -- find matching categories that are not assigned
  for _ ,value in ipairs(cfg["item_search_list"]) do
    if (TBag_GetCat(cfg, value[1]) == nil) then
      message("TBag: Unassigned category "..value[1].." has been assigned to slot 1");
      TBag_SetCatBar(cfg, value[1], 1, reset);
    end
  end
end

function TBag_SetCatForClass(c, cat)
  c["WARLOCK"] = cat;
  c["ROGUE"] = cat;

  c["DRUID"] = cat;
  c["MAGE"] = cat;
  c["PALADIN"] = cat;
  c["PRIEST"] = cat;
  c["SHAMAN"] = cat;

  c["WARRIOR"] = cat;
  c["HUNTER"] = cat;
end

function TBag_SetClassCats(cfg, playerid, reset)
  local c = {};
  local group = TBagInfo[playerid][TBAG_G_BASIC];
  local class;

  if (group) and (group[TBAG_S_CLASS]) then
    class = string.upper(group[TBAG_S_CLASS]);
  else
    class = "";
  end

  TBag_SetCatForClass(c, "REAGENT")
  c[class] = "CLASS_REAGENT";

  TBag_SetCatBar(cfg, "WARLOCK_REAGENT", c["WARLOCK"], reset);
  TBag_SetCatBar(cfg, "ROGUE_REAGENT", c["ROGUE"], reset);

  TBag_SetCatBar(cfg, "DRUID_REAGENT", c["DRUID"], reset);
  TBag_SetCatBar(cfg, "MAGE_REAGENT", c["MAGE"], reset);
  TBag_SetCatBar(cfg, "PALADIN_REAGENT", c["PALADIN"], reset);
  TBag_SetCatBar(cfg, "PRIEST_REAGENT", c["PRIEST"], reset);
  TBag_SetCatBar(cfg, "SHAMAN_REAGENT", c["SHAMAN"], reset);

  c[class] = "CLASS_TOOL";

  TBag_SetCatBar(cfg, "ROGUE_TOOL", c["ROGUE"], reset);
  TBag_SetCatBar(cfg, "SHAMAN_TOOL", c["SHAMAN"], reset);
end


-----------------------------------------------------------------------
-- Categories and Bars
-----------------------------------------------------------------------

function TBag_SetCatBar(cfg, cat, bar, reset)
  if ((cfg ~= nil) and (cat ~= nil)) then
    if (cfg[TBAG_CAT_BAR] == nil) then
      cfg[TBAG_CAT_BAR] = {};
      cfg[TBAG_CAT_BAR][cat] = bar;
    elseif (cfg[TBAG_CAT_BAR][cat] == nil) then
      cfg[TBAG_CAT_BAR][cat] = bar;
    else
      if (reset == 1) then cfg[TBAG_CAT_BAR][cat] = bar; end
    end
  end
end

function TBag_GetCatBar(cfg)
  if (cfg ~= nil) then
    if (cfg[TBAG_CAT_BAR] == nil) then
      cfg[TBAG_CAT_BAR] = {};
    end
    return cfg[TBAG_CAT_BAR];
  end
end

function TBag_GetCat(cfg, bar)
  if (cfg ~= nil) then
    if (cfg[TBAG_CAT_BAR] == nil) then
      cfg[TBAG_CAT_BAR] = {};
      return nil;
    end
    return cfg[TBAG_CAT_BAR][bar];
  end
end

function TBag_PositionFrame(frameName, childAttachPoint, parentFrameName, parentAttachPoint, xoffset, yoffset, width, height)
  local frame = getglobal(frameName);

  if (frame) then
    frame:ClearAllPoints();
    frame:SetPoint(childAttachPoint, parentFrameName, parentAttachPoint, xoffset, yoffset);
    frame:SetWidth(width);
    frame:SetHeight(height);
    frame:Show();
  else
    message("Attempt to find frame '"..frameName.."' failed.");
  end
end


function TBag_BuildBarClassList(bclist, cfg)
  local bar, barclass;
  local key, val;

  -- First wipe the old bar class lists
  for bar = 1, TBAG_BAR_MAX do
    bclist[bar] = {};
  end

  -- Build up the list
  for barclass, value in pairs(TBag_GetCatBar(cfg)) do
    if ( (type(value) == "number") ) then
      table.insert(bclist[value], barclass);
    end
  end

  -- Then sort the new bar class lists
  for bar = 1, TBAG_BAR_MAX do
    table.sort(bclist[bar]);
  end
end

-- Used for options strings
function TBag_GetBagDispName(bag)
  if ( bag < TBAG_BAGMIN ) or ( bag > TBAG_BAGMAX ) then return ""; end
  if (bag == -2) then return "Keyring"; end
  if (bag == -1) then return "Bank"; end
  if (bag == 0) then return "Backpack"; end
  if (bag == 1) then return "Fourth Bag"; end
  if (bag == 2) then return "Third Bag"; end
  if (bag == 3) then return "Second Bag"; end
  if (bag == 4) then return "First Bag"; end
  if (bag == 5) then return "First Bank Bag"; end
  if (bag == 6) then return "Second Bank Bag"; end
  if (bag == 7) then return "Third Bank Bag"; end
  if (bag == 8) then return "Fourth Bank Bag"; end
  if (bag == 9) then return "Fifth Bank Bag"; end
  if (bag == 10) then return "Sixth Bank Bag"; end
  if (bag == 11) then return "Seventh Bank Bag"; end
end

-- Used for EMPTY_X_SLOTS
function TBag_GetBagPosName(bag)
  if ( bag < TBAG_BAGMIN ) or ( bag > TBAG_BAGMAX ) then return ""; end
  if (bag == -2) then return "KEYRING"; end
  if (bag == -1) then return "BANK"; end
  if (bag == 0) then return "BACKPACK"; end
  if (bag == 1) then return "BAG1"; end
  if (bag == 2) then return "BAG2"; end
  if (bag == 3) then return "BAG3"; end
  if (bag == 4) then return "BAG4"; end
  if (bag == 5) then return "BBAG1"; end
  if (bag == 6) then return "BBAG2"; end
  if (bag == 7) then return "BBAG3"; end
  if (bag == 8) then return "BBAG4"; end
  if (bag == 9) then return "BBAG5"; end
  if (bag == 10) then return "BBAG6"; end
  if (bag == 11) then return "BBAG7"; end
end

-- Used for EMPTY_X_SLOTS and IN_X_BAG
-- Redo this using system calls to the actual frame
function TBag_GetBagType(playerid, bag)
  local type = "";

  if ( bag < TBAG_BAGMIN ) or ( bag > TBAG_BAGMAX ) then return ""; end

  -- get the live info if we are the current player, and at the bank
  if (playerid == TBAG_PLAYERID) then
    if (((TBNK_ATBANK == 1) or TBag_Member(TInv_Bags, bag)) and bag > 0) then
      local _, _, itemlink = strfind(GetInventoryItemLink("player", ContainerIDToInventoryID(bag)) or "", "^|%x+|H(.+)|h%[.+%]");
      local id, itemlink = TBag_GetItemID(itemlink);
      if (id) then 
	    local name, itemType, subType = TBag_GetItemInfo(id);
        if (itemType == "Quiver") then 
          type = "AMMO";
        elseif (itemType == "Container") then
          if (subType == "Soul Bag") then 
            type = "SOUL";
          elseif (subType ~= "Bag") then
            type = "PROF";
          end
        end
        TBag_SetPlayerBagCfg(playerid, bag, TBAG_I_ITEMLINK, itemlink);
        TBag_SetPlayerBagCfg(playerid, bag, TBAG_I_ITEMID, id);
        TBag_SetPlayerBagCfg(playerid, bag, TBAG_I_NAME, name);
        TBag_SetPlayerBagCfg(playerid, bag, TBAG_I_COUNT, 1);
      else
        TBag_SetPlayerBagCfg(playerid, bag, TBAG_I_ITEMLINK, nil);
        TBag_SetPlayerBagCfg(playerid, bag, TBAG_I_ITEMID, nil);
        TBag_SetPlayerBagCfg(playerid, bag, TBAG_I_NAME, nil);
        TBag_SetPlayerBagCfg(playerid, bag, TBAG_I_COUNT, nil);
      end

      -- Save the type to cache
      TBag_SetPlayerBagCfg(playerid, bag, TBAG_I_BAGTYPE, type);
    end
  end

  -- Special keyring setting
  if (bag == KEYRING_CONTAINER) then
    TBag_SetPlayerBagCfg(playerid, bag, TBAG_I_BAGTYPE, "KEYRING");
  end

  -- Get the type from the cache always
  type = TBag_GetPlayerBagCfg(playerid, bag, TBAG_I_BAGTYPE);
  return type;
end


function TBag_GetBagTexture(playerid, bag)
  local itemlink = TBag_GetPlayerBagCfg(playerid, bag, TBAG_I_ITEMLINK);
  local texture;


  -- Special bag textures are always fixed
  if (bag == 0) then
    texture = "Interface\\Buttons\\Button-Backpack-Up";
  elseif (bag == -1) then
    texture = "Interface\\Icons\\INV_Box_03";
  elseif (bag == KEYRING_CONTAINER) then
    texture = "Interface\\ContainerFrame\\KeyRing-Bag-Icon";
  else
    if (itemlink) then
	  texture = TBag_GetItemTexture(itemlink);
    else
      texture = "interface\\paperdoll\\UI-PaperDoll-Slot-Bag";
    end
  end

  return texture;  
end


function TBag_GetBagFrameName(bag)
  if (bag == KEYRING_CONTAINER) then
    return "TInvingButton";
  elseif (bag == -1) then
    return "TBnkFrameBagBank";
  elseif (bag == 0) then
    return "TInvMenuBarBackpackButton";
  elseif TBag_Member(TInv_Bags, bag) then
    return "TInvacterBag"..(bag-1).."Slot";
  elseif TBag_Member(TBnk_Bags, bag) then
    return "TBnkFrameBag"..(bag-4);
  else
    return "INVALID";
  end
end

function TBag_GetDummyBagFrameName(bag)
  if (bag == KEYRING_CONTAINER) then
    return "TInvainerFrame13";
  elseif (bag == 0) then
    return "TInvainerFrame12";
  elseif (bag == -1) then
    return "TBnkFrame";
  elseif TBag_Member(TInv_Bags, bag) then
    return "TInvainerFrame"..(bag);
  elseif TBag_Member(TBnk_Bags, bag) then
    return "TBnkainerFrame"..(bag);
  else
    return "INVALID";
  end
end

function TBag_GetBagItemButtonName(bag, slot)
  return TBag_GetDummyBagFrameName(bag).."Item"..slot;
end

function TBag_GetBagIdxName(bag)
  if (bag == KEYRING_CONTAINER) then
    return "KeyRing";
  elseif (bag == -1) then
    return "Bank";
  elseif (bag == 0) then
    return tostring(bag);
  elseif TBag_Member(TInv_Bags, bag) then
    return tostring(bag);
  else
    return tostring(bag);
  end
end

function TBag_GetBagNumName(bag)
  if TBag_Member(TBnk_Bags, bag) then
    return "TBnkNum"..TBag_GetBagIdxName(bag);
  elseif (bag == 0) then
    return "TInvNum"..TBag_GetBagIdxName(bag);
  elseif TBag_Member(TInv_Bags, bag) then
    return "TInvNum"..TBag_GetBagIdxName(bag);
  else
    return "INVALID";
  end
end

function TBag_GetBagFrameTexture(bag)
  if (bag >= TBAG_BAGMIN) and (bag <= TBAG_BAGMAX) then
    return getglobal(TBag_GetBagFrameName(bag).."IconTexture");
  else
    return nil;
  end
end

function TBag_GetBagFrameSpotlight(bag)
  if (bag >= TBAG_BAGMIN) and (bag <= TBAG_BAGMAX) then
    return getglobal(TBag_GetBagFrameName(bag).."SpotlightTexture");
  else
    return nil;
  end
end

function TBag_GetBagFrameHighlight(bag)
  if (bag >= TBAG_BAGMIN) and (bag <= TBAG_BAGMAX) then
    return getglobal(TBag_GetBagFrameName(bag).."HighlightFrameTexture");
  else
    return nil;
  end
end


function TBag_GetBagFrame(bag)
  if (bag >= TBAG_BAGMIN) and (bag <= TBAG_BAGMAX) then
    return getglobal(TBag_GetBagFrameName(bag));
  else
    return nil;
  end
end

function TBag_GetBagNumFrame(bag)
  return getglobal(TBag_GetBagNumName(bag));
end

function TBag_SetGfx(frame, scale, parentname)
  if (frame) then
    if (parent) then
      frame:SetParent(getglobal(parentname));
    end
    if (scale) then
      frame:SetScale(scale);
    end
  end
end


function TBag_GetCooldownString(cooldownInfo)
  local CoolDownRemaining = cooldownInfo["duration"] - (GetTime() - cooldownInfo["start"]);
  -- 60 secs in a min
  -- 3600 secs in an hour
  -- 86400 secs in a day
  local days, hours, minutes, seconds;
  days = math.floor(CoolDownRemaining / 86400);
  CoolDownRemaining = CoolDownRemaining - 86400 * days;
  hours = math.floor(CoolDownRemaining / 3600);
  CoolDownRemaining = CoolDownRemaining - 3600 * hours;
  minutes = math.floor(CoolDownRemaining / 60);
  seconds = math.floor(CoolDownRemaining - 60 * minutes);
  if days > 0 then
    return format(ITEM_COOLDOWN_TIME_DAYS_P1, days+1);
  elseif hours > 0 then
    return format(ITEM_COOLDOWN_TIME_HOURS_P1, hours+1);
  elseif minutes > 0 then
    return format(ITEM_COOLDOWN_TIME_MIN, minutes+1);
  else
    return format(ITEM_COOLDOWN_TIME_SEC, seconds);
  end
end


function TBag_MakeHyperlink(itemlink)
  local name, _, quality = GetItemInfo(itemlink);
  local QL_Colors = { "ff9d9d9d", "ffffffff", "ff1eff00", "ff0070dd", "ffa335ee", "ffff8000", "ffffcc9d"};

  if (name) and (itemlink) and (quality) then
    quality = tonumber(quality);
    return "|c"..QL_Colors[quality+1].."|H"..itemlink.."|h["..name.."]|h|r";
  end
  return itemlink;
end


function TBag_SetRarityColor(rarity, name)
  local bkgr = getglobal(name.."_bkgr");
  local normal = getglobal(name.."NormalTexture");

  if (rarity == nil) then
    bkgr:SetVertexColor(0.05,0.05,0.05,1);
    normal:SetVertexColor(0.05,0.05,0.05, 0.5);
  elseif (rarity == 0) then     -- gray item
    bkgr:SetVertexColor(0.1,0.1,0.1,1);
    normal:SetVertexColor(0.1,0.1,0.1,0.75);
  elseif (rarity == 1) then     -- white item
    bkgr:SetVertexColor(0.25,0.25,0.25,1);
    normal:SetVertexColor(0.25,0.25,0.25, 0.5);
  elseif (rarity == 2) then     -- green item
    bkgr:SetVertexColor(0,.8,0.2,1);
    normal:SetVertexColor(0,.8,0.2, 0.5);
  elseif (rarity == 3) then     -- blue item
    bkgr:SetVertexColor(0.25,0.15,1,1);
    normal:SetVertexColor(0.25,0.15,1, 0.5);
  elseif (rarity == 4) then     -- purple item
    bkgr:SetVertexColor(1,.2,1,1);
    normal:SetVertexColor(1,.2,1, 0.5);
  else    -- ?!
    bkgr:SetVertexColor(0,0,0,1);
    normal:SetVertexColor(0,0,0, 0.5);
  end
end

function TBag_MakeEven(bkgr, bf)
  bkgr = math.floor(bkgr);
  if ((bkgr - bf)/2) ~= ((bkgr - bf)/2) then
    bkgr = bkgr-1;
  end
  return bkgr;
end

function TBag_Member(arr, ele)
  local val;
  if (arr) then
    for _, val in ipairs(arr) do
      if (val == ele) then return 1; end
    end
  else
    TBag_Print("ele = "..ele);
  end
  return nil;
end

-----------------------------------------------------------------------
-- Bag Counts
-----------------------------------------------------------------------

function TBag_GetSlotInfo(playerid, bag)
  local size = 0;
  local free = 0;
  local item;

  -- Refresh the cache if we are the current player, or at a bank
  if (playerid == TBAG_PLAYERID) then
    if (TBNK_ATBANK == 1) or TBag_Member(TInv_Bags, bag) then
      if (bag == KEYRING_CONTAINER) then
        size = GetKeyRingSize(KEYRING_CONTAINER);
      else
        size = GetContainerNumSlots(bag);
--        TBag_Print("b="..bag..", size="..size);
      end
      for i=1, size do
        _, item = GetContainerItemInfo(bag, i);
        if (not item) then
          free = free + 1;
        end
      end
      -- Save the info to the cache
      TBag_SetPlayerBagCfg(playerid, bag, TBAG_I_BAGFREE, free);
      TBag_SetPlayerBagCfg(playerid, bag, TBAG_I_BAGSIZE, size);
    end
  end
  -- Get the info from the cache always
  free = TBag_GetPlayerBagCfg(playerid, bag, TBAG_I_BAGFREE);
  size = TBag_GetPlayerBagCfg(playerid, bag, TBAG_I_BAGSIZE);

  if (free == nil) then free = 0; end
  if (size == nil) then size = 0; end

  return free, size;
end


function TBag_GetNumBankSlots(playerid)
  local numSlots, full = GetNumBankSlots();
  if (playerid == TBAG_PLAYERID) and (TBNK_ATBANK == 1) then
    TBag_SetPlayerInfo(playerid, TBAG_S_BANKSLOTS, numSlots);
    if (full) then
      TBag_SetPlayerInfo(playerid, TBAG_S_BANKFULL, 1);
    else
      TBag_SetPlayerInfo(playerid, TBAG_S_BANKFULL, 0);
    end
  end
  -- Always fetch from the cache
  numSlots = TBag_GetPlayerInfo(playerid, TBAG_S_BANKSLOTS);
  full = TBag_GetPlayerInfo(playerid, TBAG_S_BANKFULL);

  -- Make safe values, just in case
  if (numSlots == nil) then numSlots = 0; end
  if (full ~= nil) and (full == 0) then
    full = nil;
  end

  return numSlots, full;
end

function TBag_GetMoney(playerid)
  local money = GetMoney();
  if (playerid == TBAG_PLAYERID) then
    TBag_SetPlayerInfo(playerid, TBAG_S_MONEY, money);
  end

  -- Always fetch from the cache
  money = TBag_GetPlayerInfo(playerid, TBAG_S_MONEY);
  if (money == nil) then money = 0; end
  return money;
end

function TBag_MakeFreeString(free, size, showsize)
  if (size <= 0) then return ""; end
  if (showsize == 1) then
    return tostring(free).."|n"..tostring(size);
  else
    return tostring(free);
  end
end

function TBag_SetFreeStr(obj, free, size, showsize)
  obj:SetText(TBag_MakeFreeString(free, size, showsize));
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

function TBag_UpdateSlots(playerid, name, bag, showsize)
  local free, size = TBag_GetSlotInfo(playerid, bag);
  -- TBag_Print(playerid..", b="..bag..", "..free.."/"..size..", AT="..TBNK_ATBANK);
  if (bag == -1) then bag = "Bank"; end
  if (bag == KEYRING_CONTAINER) then bag = "KeyRing"; end

  TBag_SetFreeStr(getglobal(name..bag.."Text"), free, size, showsize);

  return free, size;
end


-----------------------------------------------------------------------
-- Colors
-----------------------------------------------------------------------

function TBag_ColorArr(r, g, b, a)
  local c = {};
  c["r"] = r;
  c["g"] = g;
  c["b"] = b;
  c["a"] = a;
  return c;
end

function TBag_SplitColor(c)
  local r, g, b, a;
  r = TBag_GetSafeVal(c, "r", 0);
  g = TBag_GetSafeVal(c, "g", 0);
  b = TBag_GetSafeVal(c, "b", 0);
  a = TBag_GetSafeVal(c, "a", 0);
  return r, g, b, a;
end


function TBag_SetColor(cfg, colorname, r, g, b, a, reset)
  if ((cfg ~= nil) and (colorname ~= nil)) then
    if (cfg[TBAG_COLORS] == nil) then
      cfg[TBAG_COLORS] = {};
      cfg[TBAG_COLORS][colorname] = TBag_ColorArr(r, g, b, a);
    elseif (cfg[TBAG_COLORS][colorname] == nil) then
      cfg[TBAG_COLORS][colorname] = TBag_ColorArr(r, g, b, a);
    else 
      if (reset == 1) then
        cfg[TBAG_COLORS][colorname] = TBag_ColorArr(r, g, b, a);
      end
    end
  end
end

function TBag_GetColor(cfg, colorname)
  if ((cfg ~= nil) and (colorname ~= nil)) then
    if (cfg[TBAG_COLORS] == nil) then
      cfg[TBAG_COLORS] = {};
      return 0, 0, 0, 0;
    end
    return TBag_SplitColor(cfg[TBAG_COLORS][colorname]);
  end
  return 0, 0, 0, 0;
end


function TBag_ColorFrame(cfg, barframe, bar)
  local r, g, b, a = TBag_GetColor(cfg, "bkgr_"..bar)
  barframe:SetBackdropColor(r, g, b, a);
  r, g, b, a = TBag_GetColor(cfg, "brdr_"..bar)
  barframe:SetBackdropBorderColor(r, g, b, a);
end

function TBag_ColorFont(cfg, stock, font, colorname)
  local r, g, b, a = TBag_GetColor(cfg, colorname)

  stock:SetTextColor(r, g, b);
  font:SetVertexColor(r, g, b, a);
end

function TBag_SetColorFunc(prev)
  local r,g,b,opacity;

  r = nil;
  g = nil;
  b = nil;
  opacity = nil;

  if (this:GetName() == "ColorPickerFrame") then
    r,g,b = this:GetColorRGB();
    opacity = OpacitySliderFrame:GetValue();

    if (UIDROPDOWNMENU_MENU_VALUE ~= nil) then
      if ((r ~= nil) and (g ~= nil) and (b ~= nil) and (opacity ~= nil)) then
        TBag_SetColor(UIDROPDOWNMENU_MENU_VALUE["cfg"],
          UIDROPDOWNMENU_MENU_VALUE["colorname"],
          r, g, b, opacity, 1);
      end
      UIDROPDOWNMENU_MENU_VALUE["updatefunc"]();
    end

  elseif (this:GetName() == "OpacitySliderFrame") then
    opacity = OpacitySliderFrame:GetValue();

    if (UIDROPDOWNMENU_MENU_VALUE ~= nil) then
      r, g, b, _ = TBag_GetColor(UIDROPDOWNMENU_MENU_VALUE["cfg"],
          UIDROPDOWNMENU_MENU_VALUE["colorname"]);
      if ((r ~= nil) and (g ~= nil) and (b ~= nil) and (opacity ~= nil)) then
        TBag_SetColor(UIDROPDOWNMENU_MENU_VALUE["cfg"],
          UIDROPDOWNMENU_MENU_VALUE["colorname"],
          r, g, b, opacity, 1);
      end
      UIDROPDOWNMENU_MENU_VALUE["updatefunc"]();
    end
  else
    return;
  end
end

function TBag_MakeColorPickerInfo(cfg, colorkind, bar, titletext, updatefunc)
  local r, g, b, a = TBag_GetColor(cfg, colorkind..bar);
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
        [TBAG_I_BAR] = bar, ["colorname"] = colorkind..bar, ["cfg"] = cfg,
        ["updatefunc"] = updatefunc 
      },
      ["swatchFunc"] = TBag_SetColorFunc,
      ["cancelFunc"] = TBag_SetColorFunc,
      ["opacityFunc"] = TBag_SetColorFunc
  };
end

function TBag_ResetBarColors(cfg)
  local r, g, b, a = TBag_GetColor(cfg, "bkgr_"..TBAG_MAIN_BAR);
  local rr, rg, rb, ra = TBag_GetColor(cfg, "brdr_"..TBAG_MAIN_BAR);

  for i = 1, TBAG_BAR_MAX do
    TBag_SetColor(cfg, "bkgr_"..i, r, g, b, a, 1);
    TBag_SetColor(cfg, "brdr_"..i, rr, rg, rb, ra, 1);
  end
end

function TBag_UpdateBagColors(bag)
  if (bag ~= KEYRING_CONTAINER) then
    local r, g, b, a = TBag_GetColor(TBag_GetCfgFromBag(bag), "bag_"..bag);
    TBag_GetBagFrame(bag):GetCheckedTexture():SetVertexColor(r, g, b, a);
  end
end

function TBag_GetCfgFromBag(bag)
  -- Find the right config
  if (TBag_Member(TInv_Bags, bag)) then
    return TBagCfg["Inv"];
  elseif (TBag_Member(TBnk_Bags, bag)) then
    return TBagCfg["Bnk"];
  else
    return nil;
  end
end

function TBag_UpdateButtonHighlights()
  local isopen = {};
  local r = {};
  local g = {};
  local b = {};
  local a = {};
  local bag, buttonname, itm;
  local texture;
  local cfg;
  
  -- First check all the bag open states, and highlight their colors
  for _, bag in ipairs(TInv_Bags) do
    isopen[bag] = IsBagOpen(bag);
    r[bag], g[bag], b[bag], a[bag] = TBag_GetColor(TInvCfg, "bag_"..bag);

--    texture = TBag_GetBagFrameHighlight(bag);
--    texture:SetVertexColor(r[bag], g[bag], b[bag], a[bag]);
--    if (isopen[bag]) then
--      texture:Show();
--    else
--      texture:Hide();
--    end
  end
  for _, bag in ipairs(TBnk_Bags) do
    isopen[bag] = IsBagOpen(bag);
    r[bag], g[bag], b[bag], a[bag] = TBag_GetColor(TBnkCfg, "bag_"..bag);

--    texture = TBag_GetBagFrameHighlight(bag);
--    texture:SetVertexColor(r[bag], g[bag], b[bag], a[bag]);
--    if (isopen[bag]) then
--      texture:Show();
--    else
--      texture:Hide();
--    end
  end

  -- Then cycle through all the buttons
  for buttonname, itm in pairs(TBAG_BUTTONS) do
    texture = getglobal(buttonname.."HighlightFrameTexture");
    if (texture) and (itm) then
      bag = itm[TBAG_I_BAG];
      texture:SetVertexColor(r[bag], g[bag], b[bag], a[bag]);
      local cfg = TBag_GetCfgFromBag(bag);

      if (TBag_GetBagFrame(bag):GetChecked() == 1 or isopen[bag]) and (cfg) 
        and (cfg["spotlight_open"] == 1) 
        and (cfg["show_Bag"..bag] == 1) then
        texture:Show();
      else
        texture:Hide();
      end
    end
  end
end

function TBag_MakeColorMenu(cfg, updatefunc, level, bagarr)
  local info, bag;

  info = TBag_MakeColorPickerInfo(cfg, "bkgr_", 
    TBAG_MAIN_BAR, "Main Background Color", updatefunc);
  UIDropDownMenu_AddButton(info, level);

  info = TBag_MakeColorPickerInfo(cfg, "brdr_", 
    TBAG_MAIN_BAR, "Main Border Color", updatefunc);
  UIDropDownMenu_AddButton(info, level);

  info = { ["disabled"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  info = {
    ["text"] = "Set Bar Colors to Main Colors",
    ["value"] = {  },
    ["func"] = function()
      TBag_ResetBarColors(cfg);
      updatefunc();
    end
  };
  UIDropDownMenu_AddButton(info, level);

  info = { ["disabled"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  for _, bag in ipairs(bagarr) do
    info = TBag_MakeColorPickerInfo(cfg, "bag_", 
      bag, "Spotlight for "..TBag_GetBagDispName(bag), updatefunc);
    UIDropDownMenu_AddButton(info, level);
  end
end

-----------------------------------------------------------------------
-- Tooltip
-----------------------------------------------------------------------

function TBag_GetItmFromFrame(butitmmap, frm)
  if (butitmmap[frm] == nil) then
    return nil;
  else
    return butitmmap[frm];
  end
end

function TBag_GetInvSlotID(bag, slot)
  local id;
  if (bag == KEYRING_CONTAINER) then
    id = KeyRingButtonIDToInvSlotID(slot);
  elseif (bag == -1) then
    id = BankButtonIDToInvSlotID(slot);
  elseif (bag >= 0) and (bag <= TBAG_BAGMAX) then
    id = 100*bag + slot;  -- ???
  end

--  TBag_Print("TBag_GetInvSlotID = "..id.." for "..bag..", "..slot);
  return id;
end

function TBag_SetInventoryItem(tt, playerid, itemlink, bag, slot)
  local hasCooldown, repairCost;

  -- If we are the current player, it might be safe to set inventory directly
  if (playerid == TBAG_PLAYERID) then
    -- Inventory and being at the bank is always safe
    if (TBag_Member(TInv_Bags, bag) or TBNK_ATBANK == 1) then
      if (bag == KEYRING_CONTAINER) or (bag == -1) then
        hasCooldown, repairCost = tt:SetInventoryItem("player", TBag_GetInvSlotID(bag, slot));
      else
        hasCooldown, repairCost = tt:SetBagItem(bag, slot);
      end
    else
      -- otherwise, just set a link.  Not as good, but safe
      tt:SetHyperlink(itemlink);
    end
  else
    -- Always just set links for other players
    tt:SetHyperlink(itemlink);
  end
  
  return hasCooldown, repairCost;
end

function TBag_MakeToolTipStr(playerid, itemlink, bag, slot)
  local ttname = "TBag_tt";
  local tt = getglobal(ttname);
  local idx = 1;
  local ttleft = getglobal(ttname.."TextLeft"..idx);
  local tooltip = "";
  local tmpval;
  local hasCooldown, repairCost;
  
  tt:SetOwner(UIParent, "ANCHOR_NONE");  -- this makes sure that tooltip.valid = true

  -- Set as much information as we have
  if (itemlink) and (bag) and (slot) then
    hasCooldown, repairCost = TBag_SetInventoryItem(tt, playerid, itemlink, bag, slot);
  elseif (itemlink) then
    tt:SetHyperlink(itemlink);
  end

  repeat
    tmpval = ttleft:GetText();

    if (tmpval ~= nil) then
      tooltip = tooltip.." "..tmpval;
    end

    idx=idx + 1;
    ttleft = getglobal(ttname.."TextLeft"..idx);
  until (tmpval==nil) or (ttleft==nil);

  tt:Hide();

  return tooltip, hasCooldown, repairCost;
end

function TBag_ExtractTooltip(tooltipframe)
  local txt_left, txt_right, frame_left, frame_right, idx, out, tt_hack;

  tt_hack = getglobal(tooltipframe);
  tt_hack:SetOwner(UIParent, "ANCHOR_NONE");  -- this makes sure that tooltip.valid = true

  out = {};

  for idx = 1, getglobal(tooltipframe):NumLines() do
    frame_left = getglobal(tooltipframe.."TextLeft"..idx);
    frame_right = getglobal(tooltipframe.."TextRight"..idx);

    out[idx] = {
      ["l"] = frame_left:GetText(),
      ["r"] = frame_right:GetText()
      };

    if ( not frame_left:IsVisible() ) then
      out[idx]["l"] = "";
    end
    if ( not frame_right:IsVisible() ) then
      out[idx]["r"] = "";
    end

    if (TBag_ENABLE_GETTEXTCOLOR) then
      if (out[idx]["l"] ~= nil) then
        out[idx]["lr"],
        out[idx]["lg"],
        out[idx]["lb"] = frame_left:GetTextColor();
      end
      if (out[idx]["r"] ~= nil) then
        out[idx]["rr"],
        out[idx]["rg"],
        out[idx]["rb"] = frame_right:GetTextColor();
      end
    end
  end

  return out;
end



-----------------------------------------------------------------------
-- Main Sorting
-----------------------------------------------------------------------

function TBag_MakeEmptySlot(itm)
  if (itm) then
    itm[TBAG_I_NAME] = "Empty Slot";
    itm[TBAG_I_ITEMID] = nil;
    itm[TBAG_I_RARITY] = nil;
    itm[TBAG_I_TYPE] = "";
    itm[TBAG_I_SUBTYPE] = "";
    itm[TBAG_I_COUNT] = 0;
    itm[TBAG_I_NEED] = 0;
  end
end

function TBag_UpdateItmCache(cfg, playerid, itmcache, bagarr, atbank)
  local bag, slot;  -- used as "for loop" counters
  local itm;    -- entry that will be written to the cache
  local update_suggested = 0;
  local resort_suggested = 0;
  local resort_mandatory = 0;
  local stackarr = {};

  -- variables used in outer loop, bag:
  local size;
  local bagtype;

  -- variables used in inner loop, slots:
  local a,b,c,d;

  -- Never update if we are viewing another player's contents
  if (playerid ~= TBAG_PLAYERID) then
    return TBAG_REQ_NONE;
  end

  -- Don't update if we aren't at the bank
  if (atbank) and (atbank ~= 1) then
    return TBAG_REQ_MUST;
  end

  for index, bag in ipairs(bagarr) do
    if (cfg["show_Bag"..bag] == 1) then
      if (itmcache[bag] == nil) then
        itmcache[bag] = {};
      end

      _, size = TBag_GetSlotInfo(playerid, bag);
      bagtype = TBag_GetBagType(playerid, bag);

      if (size > 0) then
        -- Counting down makes stacking prefer existing stacks
        for slot = size, 1, -1 do
          if (itmcache[bag][slot] == nil) then
            itmcache[bag][slot] = { [TBAG_I_KEYWORD] = {} };
          end

          itm = {
            [TBAG_I_ITEMLINK] = GetContainerItemLink(bag, slot);
            [TBAG_I_BAG] = bag,
            [TBAG_I_SLOT] = slot,
            [TBAG_I_BAGTYPE] = bagtype,
            -- take items from old position
            [TBAG_I_BAR] = itmcache[bag][slot][TBAG_I_BAR],
            [TBAG_I_TIMESTAMP] = itmcache[bag][slot][TBAG_I_TIMESTAMP],
            [TBAG_I_NEWSTR] = itmcache[bag][slot][TBAG_I_NEWSTR],
            [TBAG_I_CAT] = itmcache[bag][slot][TBAG_I_CAT],
            [TBAG_I_KEYWORD] = itmcache[bag][slot][TBAG_I_KEYWORD],
            };

          if (itm[TBAG_I_ITEMLINK] ~= nil) then
            -- there's an item in the bag, let's find out more about it
            itm[TBAG_I_ITEMID], itm[TBAG_I_ITEMLINK] = 
              TBag_GetItemID(itm[TBAG_I_ITEMLINK]);

            local tooltip = TBag_MakeToolTipStr(playerid, itm[TBAG_I_ITEMLINK], bag, slot);
            if (string.find(tooltip, "Soulbound")) then
              itm[TBAG_I_SOULBOUND] = 1;
            end

            local stacksize;
            itm[TBAG_I_NAME], itm[TBAG_I_TYPE], itm[TBAG_I_SUBTYPE], itm[TBAG_I_RARITY], _, stacksize = TBag_GetItemInfo(itm[TBAG_I_ITEMLINK]);
            _, itm[TBAG_I_COUNT], _, _, _ = GetContainerItemInfo(bag, slot);
            if (stacksize) then
              itm[TBAG_I_NEED] = stacksize - itm[TBAG_I_COUNT];
            else
              itm[TBAG_I_NEED] = 0;
            end
          else
            -- no item in bag, set it as empty
            TBag_MakeEmptySlot(itm);

            -- And always remove it from the stack skip list
            TBag_SetStackSkip(itm[TBAG_I_BAG], itm[TBAG_I_SLOT], nil);
          end

          -- Put on the stack array if we need more to stack
          if (itm[TBAG_I_NEED] > 0) then
            -- Check that we aren't on the skip list
            if (TBag_GetStackSkip(itm[TBAG_I_BAG], itm[TBAG_I_SLOT]) == nil) then
              TBag_PrintDEBUG("Stack inserting ("..itm[TBAG_I_BAG]..", "
                ..itm[TBAG_I_SLOT]..") with need="..itm[TBAG_I_NEED]);
              table.insert(stackarr, itm);
            end
          end

          if (itm[TBAG_I_BAR] == nil) then
            resort_mandatory = 1;
          end

          if (itm[TBAG_I_SUBTYPE] == nil) then itm[TBAG_I_SUBTYPE] = ""; end
          if (itm[TBAG_I_NAME] == nil) then itm[TBAG_I_NAME] = ""; end

          if (
      (itm[TBAG_I_ITEMLINK] ~= itmcache[bag][slot][TBAG_I_ITEMLINK]) or
      (itm[TBAG_I_BAGTYPE] ~= itmcache[bag][slot][TBAG_I_BAGTYPE])
             ) then
            -- the item changed
            if (itm[TBAG_I_TIMESTAMP] ~= nil) then
              resort_suggested = 1;
              itm[TBAG_I_TIMESTAMP] = GetTime();
              itm[TBAG_I_NEWSTR] = TBAG_V_NEWON;
            end
          else
            -- item has not changed, maybe the count did?
            if ( (itm[TBAG_I_COUNT] ~= itmcache[bag][slot][TBAG_I_COUNT]) and (itmcache[bag][slot][TBAG_I_COUNT] ~= nil) ) then
              update_suggested = 1;
              if (itm[TBAG_I_COUNT] < itmcache[bag][slot][TBAG_I_COUNT]) then
                itm[TBAG_I_NEWSTR] = TBAG_V_NEWMINUS;
              else
                itm[TBAG_I_NEWSTR] = TBAG_V_NEWPLUS;
              end
              itm[TBAG_I_TIMESTAMP] = GetTime();
            end
          end

          if (itm[TBAG_I_TIMESTAMP] == nil) then
            TBag_ResetNew(itm);
          end

           itmcache[bag][slot] = itm;  -- save updated information
        end
      else
        -- size = 0, make sure you wipe the cache entry
        if (table.getn(itmcache[bag]) ~= 0) then
          resort_mandatory = 1;
        end
        itmcache[bag] = {};
      end
    end
  end

  if (resort_mandatory == 1) then
    return TBAG_REQ_MUST, stackarr;
  elseif (resort_suggested == 1) then
    return TBAG_REQ_PART, stackarr;
  else
    return TBAG_REQ_NONE, stackarr;
  end
end


function TBag_SortItmCache(cfg, playerid, itmcache, baritm, bagarr)
  local i;
  local bag, slot;  -- variables used in outer loop
  local size;
  -- variables used in inner loop
  ----- 2nd loop
  local barnum;
  local trade1, trade2 = TBag_GetTwoProfessions(playerid);

  -- wipe the current bar positions table
  baritm = {};
  for i = 1, TBAG_BAR_MAX do
    baritm[i] = {};
  end

  for _, bag in ipairs(bagarr) do
--    TBag_PrintDEBUG("TBag_MakeBarItm: bag ="..bag);
    if itmcache[bag] == nil then
      return baritm;
    end

    if (cfg["show_Bag"..bag] == 1) then
      size = table.getn(itmcache[bag]);
      if (size > 0) then
--        TBag_PrintDEBUG("Show bag "..bag);
        for slot = 1, size do
          itmcache[bag][slot] = TBag_PickBar(cfg, playerid,
            itmcache[bag][slot], trade1, trade2);

          -- An ugly special case check for Keyring slots
          if ( (itmcache[bag][slot][TBAG_I_ITEMLINK]) 
            or (cfg["show_keyring_empty_slots"] ~= 0)
            or (bag ~= KEYRING_CONTAINER) ) then
            table.insert( baritm[ itmcache[bag][slot][TBAG_I_BAR] ], itmcache[bag][slot]);
          end
        end
      end
    end
  end

  -- sort the cache now
  for barnum = 1, TBAG_BAR_MAX do
    local toggle;

    if (TBag_GetGrp(cfg, TBAG_G_BAR_SORT, barnum) == TBAG_SORTBY_NORM) then
      toggle=1;
    elseif (TBag_GetGrp(cfg, TBAG_G_BAR_SORT, barnum) == TBAG_SORTBY_REV) then
      toggle=2;
    end
  
    if (toggle==1 or toggle==2) then
      table.sort(baritm[barnum], 
        function(a,b) return  
          a[TBAG_I_CAT]..
          TBag_ReverseString(a[TBAG_I_NAME],toggle)..
          string.format("%04s",a[TBAG_I_COUNT])..string.format("%02s",a[TBAG_I_SLOT])

          >
          b[TBAG_I_CAT]..
          TBag_ReverseString(b[TBAG_I_NAME],toggle)..
          string.format("%04s",b[TBAG_I_COUNT])..string.format("%02s",b[TBAG_I_SLOT])
        end
      );
    end
  end
  return baritm;
end


function TBag_SetBarFromClass(cfg, itm)
  itm[TBAG_I_BAR] = TBag_GetCat(cfg, itm[TBAG_I_CAT]);
  while ((itm[TBAG_I_BAR] ~= nil) and type(itm[TBAG_I_BAR]) ~= "number") do
    itm[TBAG_I_BAR] = TBag_GetCat(cfg, itm[TBAG_I_BAR]);
  end
  return itm[TBAG_I_BAR];
end


function TBag_PickBar(cfg, playerid, itm, trade1, trade2)
  if (itm[TBAG_I_ITEMLINK] == nil) then
    if (itm[TBAG_I_BAGTYPE]) and (itm[TBAG_I_BAGTYPE] ~= "") then
      itm[TBAG_I_CAT] = "EMPTY_"..itm[TBAG_I_BAGTYPE].."_SLOTS";
    else
      itm[TBAG_I_CAT] = "EMPTY_"..TBag_GetBagPosName(itm[TBAG_I_BAG]).."_SLOTS";
    end
    TBag_SetBarFromClass(cfg, itm);
    return itm;
  else
  -- vars used in tooltip creation
  local tooltip;
  -- vars used in array loops
  local key, value;
  local found;

  -- reset item keywords
  if (itm[TBAG_I_BAGTYPE]) and (itm[TBAG_I_BAGTYPE] ~= "") then
    if (cfg["special_bag_sort"] == 1) then
      itm[TBAG_I_CAT] = "IN_"..itm[TBAG_I_BAGTYPE].."_BAG";
      itm[TBAG_I_KEYWORD] = {
        [itm[TBAG_I_CAT]] = 1,  -- this indicates that the special bag isn't empty
      };
      TBag_SetBarFromClass(cfg, itm);
      return itm;
    end
  end

  itm[TBAG_I_KEYWORD] = {};

  if (itm[TBAG_I_RARITY] ~= nil) then
    itm[TBAG_I_KEYWORD][TBAG_S_RARITY..itm[TBAG_I_RARITY]] = 1;
  end

  TBag_MakeAllTradeKeywords(itm, cfg["trade_created_sort"]);

  if (trade1 ~= "") then
    TBag_SetCatBar(cfg, TBag_Cat(trade1), TBag_Cat("TRADE1"), 1);
    if (cfg["trade_created_sort"] == 1) then
      TBag_SetCatBar(cfg, TBag_Cat(trade1).."_CREATED", TBag_Cat("TRADE1").."_CREATED", 1);
    else
      TBag_SetCatBar(cfg, TBag_Cat(trade1).."_CREATED", nil, 1);
    end
    TBag_MakeTradeKeyword(itm, TBag_Loc(trade1), TBag_Cat("TRADE1"), 
      cfg["trade_created_sort"]);
  end
  if (trade2 ~= "") then
    TBag_SetCatBar(cfg, TBag_Cat(trade2), TBag_Cat("TRADE2"), 1);
    if (cfg["trade_created_sort"] == 1) then
      TBag_SetCatBar(cfg, TBag_Cat(trade2).."_CREATED", TBag_Cat("TRADE2").."_CREATED", 1);
    else
      TBag_SetCatBar(cfg, TBag_Cat(trade2).."_CREATED", nil, 1);
    end
    TBag_MakeTradeKeyword(itm, TBag_Loc(trade2), TBag_Cat("TRADE2"), 
      cfg["trade_created_sort"]);
  end

  if (itm[TBAG_I_SOULBOUND] == 1) then
    itm[TBAG_I_KEYWORD]["SOULBOUND"] = 1;

    -- Only treat soulbound equipment as equipped
    if ( TBag_GetPlayerInfo(playerid, TBAG_S_EQUIPPED) ~= nil ) then
      if (TBag_GetPlayerInfo(playerid, TBAG_S_EQUIPPED)[ itm[TBAG_I_ITEMID] ] ~= nil) then
      itm[TBAG_I_KEYWORD]["EQUIPPED"] = 1;
      end
    end
  end

  -- Load tooltip
  tooltip = TBag_MakeToolTipStr(playerid, itm[TBAG_I_ITEMLINK], itm[TBAG_I_BAG], itm[TBAG_I_SLOT]);

  -- TBag_PrintDEBUG("Tooltip Text: "..tooltip);

  itm[TBAG_I_CAT] = nil;

  -- step 1, check item overrides
  itm[TBAG_I_CAT] = cfg["item_overrides"][itm[TBAG_I_ITEMID]];
  if (itm[TBAG_I_CAT] ~= nil) then
    itm[TBAG_I_BAR] = TBag_GetCat(cfg, itm[TBAG_I_CAT]);
    while ( (itm[TBAG_I_BAR] ~= nil) and (type(itm[TBAG_I_BAR]) ~= "number") ) do
    itm[TBAG_I_BAR] = TBag_GetCat(cfg, itm[TBAG_I_BAR]);
    end
    if (type(itm[TBAG_I_BAR]) ~= "number") then
    itm[TBAG_I_CAT] = nil;
    end
  end

  if (itm[TBAG_I_CAT] == nil) then
    for i = 1, table.getn(cfg["item_search_list"]) do
      local value = cfg["item_search_list"][i];
      if (value[1] ~= "") then
        local found = 1;
      
        -- value[1] == category to place it in

        -- check keywords
        if ( (value[2] ~= "") and (itm[TBAG_I_KEYWORD][value[2]] == nil) ) then
          found = nil;
        end
        -- check tooltip
        if ( (value[3] ~= "") and (not (string.find(tooltip, value[3]))) ) then
          found = nil;
        end
        -- check itemType
        if ( (value[4] ~= "") and (itm[TBAG_I_TYPE] ~= value[4]) ) then
          found = nil;
        end
        -- check itemSubType
        if ( (value[5] ~= "") and (itm[TBAG_I_SUBTYPE] ~= value[5]) ) then
          found = nil;
        end

        if (found) then
          itm[TBAG_I_CAT] = value[1];
          itm[TBAG_I_BAR] = TBag_GetCat(cfg, itm[TBAG_I_CAT]);
          while ( (itm[TBAG_I_BAR] ~= nil) and (type(itm[TBAG_I_BAR]) ~= "number") ) do
            itm[TBAG_I_BAR] = TBag_GetCat(cfg, itm[TBAG_I_BAR]);
          end
          if (type(itm[TBAG_I_BAR]) == "number") then
            break;
          else
            itm[TBAG_I_CAT] = nil;
          end
        end
      end
    end
  end

  if (itm[TBAG_I_CAT] == nil) then
    itm[TBAG_I_CAT] = "UNKNOWN";

    itm[TBAG_I_BAR] = TBag_GetCat(cfg, itm[TBAG_I_CAT]);
    while ( (itm[TBAG_I_BAR] ~= nil) and (type(itm[TBAG_I_BAR]) ~= "number") ) do
    itm[TBAG_I_BAR] = TBag_GetCat(cfg, itm[TBAG_I_BAR]);
    end
    if (type(itm[TBAG_I_BAR]) ~= "number") then
    itm[TBAG_I_CAT] = "UNKNOWN";
    itm[TBAG_I_BAR] = 1;
    end
  end

  end
  return itm;
end


function TBag_ScanEquipped()
  local itemLink;

--  TBag_Print( "Scanning Equipment: ");

  if (TBag_GetPlayerInfo(TBAG_PLAYERID, TBAG_S_EQUIPPED) == nil) then
    TBag_SetPlayerInfo(TBAG_PLAYERID, TBAG_S_EQUIPPED, {});
  end

  -- Arrange by itemlink (for equipped) and player (for TBody)
  for key, value in pairs(TBody_Slots) do
--    TBag_Print("Equipped ID="..GetInventorySlotInfo(key).." for "..key);
    itemLink = GetInventoryItemLink("player", GetInventorySlotInfo(key) );

    TBodyItm[TBAG_PLAYERID][TBAG_D_BAG][value] = {};
    local dbag = TBodyItm[TBAG_PLAYERID][TBAG_D_BAG][value];
    if (itemLink) then
      TBag_SetItemLink(TBag_GetPlayerInfo(TBAG_PLAYERID, TBAG_S_EQUIPPED), itemLink);

      dbag[TBAG_I_ITEMID], dbag[TBAG_I_ITEMLINK] = 
        TBag_GetItemID(itemLink);

      dbag[TBAG_I_NAME] = GetItemInfo(dbag[TBAG_I_ITEMLINK]);
      dbag[TBAG_I_COUNT] = 1;
    end
  end
end


function TBag_ScanMail()
  local itemLink, idx;

  -- Only scan if the number cached is different than the in our inbox
  if (GetInboxNumItems() == table.getn(TMailItm[TBAG_PLAYERID][TBAG_D_BAG])) then
--    TBag_PrintDEBUG( "Aborting Mail Scan");
    return;
  end

--  TBag_Print( "Scanning Mail: ");

  -- Arrange by player (for TMail)
--  CheckInbox();
  TMailItm[TBAG_PLAYERID][TBAG_D_BAG] = {};
  for idx = 1, GetInboxNumItems() do
    TMailItm[TBAG_PLAYERID][TBAG_D_BAG][idx] = {};
    local itm = TMailItm[TBAG_PLAYERID][TBAG_D_BAG][idx];

    local name, itemTexture, count, quality, canUse = GetInboxItem(idx);

    -- Only count those mails with attachments
    if ((name) and (count) and (count > 0)) then
      itm[TBAG_I_NAME] = name;
      itm[TBAG_I_COUNT] = count;

      local itemid = TBag_GetItemIDFromName(name);
      itm[TBAG_I_ITEMID] = itemid;
      itm[TBAG_I_ITEMLINK] = "item:"..itemid..":0:0:0";
    end
  end
end


-----------------------------------------------------------------------
-- Main Display
-----------------------------------------------------------------------

-- Make an inventory slot usable with the item specified in itm
-- cache entry is the array that comes directly from the cache
function TBag_UpdateButton(cfg, playerid, framename, edit_mode,
  edit_hilight, hilight_new)
  local ic_start, ic_duration, ic_enable;
  local showSell = nil;
  local frame = getglobal(framename);
  local frame_texture = getglobal(framename.."IconTexture");
  local frame_font = getglobal(framename.."Count");
  local frame_bkgr = getglobal(framename.."_bkgr");
  local frame_stock = getglobal(framename.."Stock");
  local cooldownFrame = getglobal(framename.."_Cooldown");

  -- First, link to the button map
  itm = TBAG_BUTTONS[framename];
  if (itm == nil) then return; end

  local texture;

  if (itm[TBAG_I_ITEMLINK] ~= nil) then
    ic_start, ic_duration, ic_enable = GetContainerItemCooldown(itm[TBAG_I_BAG], itm[TBAG_I_SLOT]);
    texture  = TBag_GetItemTexture(itm[TBAG_I_ITEMLINK]);
  else
    if (cfg["show_bag_icons"] == 1) then
      texture = TBag_GetBagTexture(playerid, itm[TBAG_I_BAG]);
    else
      -- Clean the empty bag texture if setting is on.
      texture = nil;
    end

    ic_start = 0;
    ic_duration = 0;
    ic_enable = nil;
  end

  SetItemButtonTexture(frame, texture);
  SetItemButtonCount(frame, itm[TBAG_I_COUNT]);

  if ( edit_mode == 1 ) then
    -- we should be hilighting an entire class of item
    if ( itm[TBAG_I_CAT] ~= edit_hilight ) then
      -- dim this item
      frame_texture:SetVertexColor(1,1,1,0.15);
      frame_font:SetVertexColor(1,1,1,0.5);
      frame_bkgr:SetVertexColor(0.4,0.4,0.4,1);
    else
      -- hilight this item
      frame_texture:SetVertexColor(1,1,0.8,1);
      frame_font:SetVertexColor(1,1,0.8,1);
      frame_bkgr:SetVertexColor(1,1,1,1);
    end
  else
    -- no hilights, just do your normal work

    if ( TBag_GetGrp(cfg, TBAG_G_USE_NEW, itm[TBAG_I_BAR]) == 1 
    and (itm[TBAG_I_ITEMLINK] ~= nil) 
    and (itm[TBAG_I_TIMESTAMP]>1) 
    and ((GetTime()-itm[TBAG_I_TIMESTAMP]) < 60*cfg["newItemTimeout"]) ) then
      -- item is still new, display the "new" text.
      frame_stock:SetText( cfg[itm[TBAG_I_NEWSTR]] );
      if ( (GetTime()-itm[TBAG_I_TIMESTAMP]) < 60*cfg["recentTimeout"]) then
        TBag_ColorFont(cfg, frame_stock, frame_font, "recentitem");
      else
        TBag_ColorFont(cfg, frame_stock, frame_font, "newitem");
      end
      frame_stock:Show();
      frame_texture:SetVertexColor(1,1,1,1);
    else
      frame_stock:Hide();
      if (hilight_new == 1) then
        frame_texture:SetVertexColor(1,1,1,0.15);
        frame_font:SetVertexColor(1,1,1,0.5);
      else
        if (itm[TBAG_I_ITEMLINK]) then
          frame_texture:SetVertexColor(1,1,1,1);
          frame_font:SetVertexColor(1,1,1,1);
        else
          frame_texture:SetVertexColor(1,1,1,0.35);
          frame_font:SetVertexColor(1,1,1,1);
        end
      end
    end

    TBag_SetRarityColor(itm[TBAG_I_RARITY], framename);
  end

  -- Another player's view never appears locked
  local locked;
  if (playerid == TBAG_PLAYERID) then
    _, _, locked, _, _ = GetContainerItemInfo(itm[TBAG_I_BAG], itm[TBAG_I_SLOT]);
  end
  SetItemButtonDesaturated(frame, locked, 0.5, 0.5, 0.5);

  -- resize and position fonts
  frame_font:SetTextHeight( math.ceil(cfg["count_font"]) );  -- count, bottomright
  frame_font:ClearAllPoints();
  frame_font:SetPoint("BOTTOMRIGHT", framename, "BOTTOMRIGHT", 0-cfg["count_font_x"], cfg["count_font_y"] );
  
  --frame_stock.font = "Interface\Addons\TBag\DAB_CooldownFont.ttf";
  frame_stock:SetTextHeight( math.ceil(cfg["new_font"]) );  -- stock, topleft
  frame_stock:ClearAllPoints();
  frame_stock:SetPoint("TOPLEFT", framename, "TOPLEFT", (cfg["count_font_x"] / 2), 0-cfg["count_font_y"] );
  
  -- Set cooldown, if it exists
  if (cooldownFrame) then
    CooldownFrame_SetTimer(cooldownFrame, ic_start, ic_duration, ic_enable);
    if ( ( ic_duration > 0 ) and ( ic_enable == 0 ) ) then
      SetItemButtonTextureVertexColor(frame, 0.4, 0.4, 0.4);
    end

    cooldownFrame:SetScale(TBAG_COOLDOWN_SCALE);
  end
end

function TBag_CalcBarLayout(calc_dat, baritm, barnum, numbars, colmax, edit_mode)
  local iBar;

  -- First set the total bar sizes
  calc_dat = {};
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

  return calc_dat;
end

function TBag_GetBarY(bar_x)
  return math.floor(TBAG_BAR_MAX / bar_x);
end

-- fx = Tqqq_FrameX
-- sx = Tqqq_SpaceX

function TBag_LayoutWindow(cfg, framename, baritm, bar_x, edit_mode, buttonmax, assignfunc, fx, fy, sx, sy, px, py)
  local frame = getglobal(framename);
  local TBAG_PAD_BOTTOM;
  local calc_dat = {};
  local barnum, slot;
  local barframe = {};
  local tmpframe;
  local iBar;
  local bar_y = TBag_GetBarY(bar_x);
  local available_width = fx(cfg["maxColumns"]) 
      + sx(bar_x-1) + px(bar_x+1) + (2 * TBAG_BORDER);
  local width_in_between;

  if (edit_mode == 1) then
    TBAG_PAD_BOTTOM = TBAG_PAD_BOTTOM_EDIT;
  else
    TBAG_PAD_BOTTOM = TBAG_PAD_BOTTOM_NORM;
  end

  -- ITEM BUTTONS
  local cur_y = py(1) + TBAG_BORDER + TBAG_PAD_BOTTOM;

  for barnum = 1, bar_x * bar_y, bar_x do
    for iBar = 0, bar_x - 1 do
      barframe[iBar] = getglobal(framename.."_bar_"..(barnum+iBar));
      if (edit_mode ~= 1) then
        -- we're not in edit mode, make sure the SlotTarget button and texture is hidden
        tmpframe = getglobal(framename.."_SlotTarget_"..(barnum+iBar));
        tmpframe:Hide();
      end
    end

    calc_dat = TBag_CalcBarLayout(calc_dat, baritm, barnum, bar_x, 
      cfg["maxColumns"], edit_mode);

    --- now we know the size and height of all bars for this line

    if (calc_dat["height"] == 0) then
      for iBar = 0, bar_x - 1 do
        barframe[iBar]:Hide();
      end
    else
      local cur_x = px(1) + (TBAG_BORDER);
      local cur_width = 0;

      -- Find the space left over
      width_in_between = fx(cfg["maxColumns"]) 
        + sx(bar_x-1) + px(bar_x-1);
      for iBar = 0, bar_x - 1 do
        width_in_between = width_in_between - fx(calc_dat[iBar.."_width"]);
      end

      -- Then position the frames appropriately
      for iBar = 0, bar_x - 1 do
        if (calc_dat[iBar.."_width"] >= 0) then
          -- Keep width separate to get roundoff staggering
          if (bar_x == 1) then
            cur_width = 0;
          else
            cur_width = math.floor(iBar * width_in_between / (bar_x - 1));
          end

          TBag_PositionFrame(framename.."_bar_"..(barnum+iBar), 
            "BOTTOMRIGHT", framename, "BOTTOMRIGHT",
            0-cur_x-cur_width,
            cur_y,
            fx(calc_dat[iBar.."_width"]),
            fy(calc_dat["height"]));

          cur_x = cur_x + fx(calc_dat[iBar.."_width"]);

          -- Color the frame and assign buttons
          TBag_ColorFrame(cfg, barframe[iBar], (barnum+iBar));

          assignfunc((barnum+iBar), framename.."_bar_"..(barnum+iBar),
            calc_dat[iBar.."_width"], calc_dat["height"] );
        else
          barframe[iBar]:Hide();
        end
      end

      cur_y = cur_y + fy(calc_dat["height"]) + py(1);
    end
  end

  -- Hide any "leftover" frames
  for barnum = bar_x * bar_y + 1, TBAG_BAR_MAX do
    getglobal(framename.."_bar_"..barnum):Hide();
  end

  local new_height;
  
  if (cfg["show_top_graphics"] == 1) then
    new_height = cur_y + TBAG_PAD_TOP_GFX + sy(1) + py(1) + TBAG_BORDER;
  else
    new_height = cur_y + TBAG_PAD_TOP_NORM + sy(1) + py(1) + TBAG_BORDER;
  end

  frame:SetWidth( available_width );
  frame:SetHeight( new_height );

  return cur_y;
end

-----------------------------------------------------------------------
-- Stacking
-----------------------------------------------------------------------

local TBAG_ISSTACKING = nil;

function TBag_IsStacking()
  return TBAG_ISSTACKING;
end

-- sa = stackarr, shortened to make the code manageable
function TBag_Stack(itmcache, sa)
  local hasstacked;
  if (sa) then
    local sn = table.getn(sa);
    TBag_PrintDEBUG("Stacking!  Array size = "..sn);

    TBAG_ISSTACKING = 1;

    -- For every need, try to find a count that matches it
    for k_c = 1, sn do
      for k_n = 1, sn do
        if (k_n ~= k_c) and (sa[k_c]) and (sa[k_n]) then
          -- Find matching items
          if (sa[k_c][TBAG_I_ITEMID]) and (sa[k_n][TBAG_I_ITEMID]) 
            and (sa[k_n][TBAG_I_ITEMID] == sa[k_c][TBAG_I_ITEMID]) 
            -- That aren't on the skip list
            and (not TBag_GetStackSkip(sa[k_c][TBAG_I_BAG], sa[k_c][TBAG_I_SLOT])) 
            and (not TBag_GetStackSkip(sa[k_n][TBAG_I_BAG], sa[k_n][TBAG_I_SLOT])) then

          if (sa[k_n][TBAG_I_NEED] <= sa[k_c][TBAG_I_NEED]) 
            and (sa[k_n][TBAG_I_NEED] > 0) then

            -- If one stack will fit on the other, drop it onto it
            if (sa[k_n][TBAG_I_COUNT] <= sa[k_c][TBAG_I_NEED]) then
              -- Drop one onto the other
	      ClearCursor();
              PickupContainerItem(sa[k_n][TBAG_I_BAG], sa[k_n][TBAG_I_SLOT]);
              PickupContainerItem(sa[k_c][TBAG_I_BAG], sa[k_c][TBAG_I_SLOT]);
	      ClearCursor();

              -- Update the count totals
              sa[k_c][TBAG_I_COUNT] = sa[k_c][TBAG_I_COUNT] + sa[k_n][TBAG_I_COUNT];
              sa[k_c][TBAG_I_NEED] = sa[k_c][TBAG_I_NEED] - sa[k_n][TBAG_I_COUNT];
              
              -- And empty out the dropped slot
              TBag_MakeEmptySlot(itmcache[sa[k_n][TBAG_I_BAG]][sa[k_n][TBAG_I_SLOT]]);
              TBag_SetStackSkip(sa[k_n][TBAG_I_BAG], sa[k_n][TBAG_I_SLOT], nil);
              sa[k_n] = nil;
              
            -- Otherwise, split the smaller stack to complete the larger
            elseif (sa[k_n][TBAG_I_COUNT] > sa[k_c][TBAG_I_NEED]) then
              -- Split one and drop onto the other
	      ClearCursor();
              SplitContainerItem(sa[k_n][TBAG_I_BAG], sa[k_n][TBAG_I_SLOT], sa[k_c][TBAG_I_NEED]);
              PickupContainerItem(sa[k_c][TBAG_I_BAG], sa[k_c][TBAG_I_SLOT]);
	      ClearCursor();

              -- Update the count totals
              sa[k_n][TBAG_I_COUNT] = sa[k_n][TBAG_I_COUNT] - sa[k_c][TBAG_I_NEED];
              sa[k_n][TBAG_I_NEED] = sa[k_n][TBAG_I_NEED] + sa[k_c][TBAG_I_NEED];
              sa[k_c][TBAG_I_COUNT] = sa[k_c][TBAG_I_COUNT] + sa[k_c][TBAG_I_NEED];
              sa[k_c][TBAG_I_NEED] = sa[k_c][TBAG_I_NEED] - sa[k_c][TBAG_I_NEED];
            end
            
            -- Make sure to clear the skip list
            TBag_SetStackSkip(sa[k_c][TBAG_I_BAG], sa[k_c][TBAG_I_SLOT], nil);

            -- If we've completed this stack, remove it from consideration
            if (sa[k_c][TBAG_I_NEED] == 0) then
              sa[k_c] = nil;
            end

            hasstacked = 1;
          end
        end
      end
    end
  end 
  end

  TBAG_ISSTACKING = nil;

  return hasstacked;
end

local TBAG_STACKSKIP = {};
local TBAG_STACKSPLIT = nil;

function TBag_ClearStackSkip(bagarr)
  TBag_ClearItmCache(TBAG_STACKSKIP, bagarr);
end

function TBag_GetStackSkip(bag, slot)
  if (TBAG_STACKSKIP[bag] == nil) then
    TBAG_STACKSKIP[bag] = {};
  end
  return TBAG_STACKSKIP[bag][slot];
end

function TBag_SetStackSkip(bag, slot, val)
  if (TBAG_STACKSKIP[bag] == nil) then
    TBAG_STACKSKIP[bag] = {};
  end
  TBAG_STACKSKIP[bag][slot] = val;

--  if (val) then
--    TBag_Print("Skip ("..bag..", "..slot..") val="..val);
--  end
end

function TBag_SplitContainerItem(bag, slot, split)
  -- Put this slot on the black list
  TBag_SetStackSkip(bag, slot, 1);
  
  TBAG_STACKSPLIT = 1;
end

hooksecurefunc('SplitContainerItem', TBag_SplitContainerItem);

function TBag_PickupContainerItem(bag, slot)
  -- Only skip a slot if we have just manually split
  if (TBAG_STACKSPLIT) then
    TBag_SetStackSkip(bag, slot, 1);
  end
  TBAG_STACKSPLIT = nil;
end

hooksecurefunc('PickupContainerItem', TBag_PickupContainerItem);

-----------------------------------------------------------------------
-- Inits and Events
-----------------------------------------------------------------------

function TBag_RealmDropdown_Init(onclickfunc, TItm)
  local info;
  local realms = {};
  
  -- Grab all realms
  for key, value in pairs(TItm) do
    local realm = TBag_Split(key, "|")[2];
    realms[realm] = 1;
  end

  -- Add all the realms
  for key, value in pairs(realms) do
    info = {};
    info.text = key;
    info.value = key;
    info.func = onclickfunc;
    UIDropDownMenu_AddButton(info);
  end
end

function TBag_UserDropdown_Init(onclickfunc, TItm, selRealm)
  local info;
  local users = {};

  -- Grab all the users on this realm only
  for key, value in pairs(TItm) do
    local realm = TBag_Split(key, "|")[2];
    if ( realm == selRealm ) then
      table.insert(users, key);
    end
  end

  -- Sort and add them
  table.sort(users);
  for key, value in pairs(users) do
    info = {};
    info.text = TBag_Split(value, "|")[1];
    info.value = value;
    info.func = onclickfunc;
    UIDropDownMenu_AddButton(info);
  end
end

-- Shit to bypass FluidFrames (Hook), very inefficient but FF works in this way.
-- Borrowed from EngBags 1.25
if (FluidFrames ~= nil) then
        TBag_FF_Hook_Old = FluidFrames.InitTempDraggableFrames;
        TBag_FF_Hook = function()
                if (TBag_FF_Hook_Old ~= nil) then
                        TBag_FF_Hook_Old();
                        local titleRegion = TInvFrame:GetTitleRegion();
                        if (titleRegion ~= nil) then
                                titleRegion:SetPoint("BOTTOMLEFT", "TInvFrame", "BOTTOMLEFT", 0, 0);
                                titleRegion:SetPoint("TOPLEFT", "TInvFrame", "BOTTOMLEFT", 0, 0);
                                titleRegion:SetPoint("BOTTOMRIGHT", "TInvFrame", "BOTTOMLEFT", 0, 0);
                                titleRegion:SetPoint("TOPRIGHT", "TInvFrame", "BOTTOMLEFT", 0, 0);
                        end
                        local titleRegion = TBnkFrame:GetTitleRegion();
                        if (titleRegion ~= nil) then
                                titleRegion:SetPoint("BOTTOMLEFT", "TBnkFrame", "BOTTOMLEFT", 0, 0);
                                titleRegion:SetPoint("TOPLEFT", "TBnkFrame", "BOTTOMLEFT", 0, 0);
                                titleRegion:SetPoint("BOTTOMRIGHT", "TBnkFrame", "BOTTOMLEFT", 0, 0);
                                titleRegion:SetPoint("TOPRIGHT", "TBnkFrame", "BOTTOMLEFT", 0, 0);
                        end
                end
        end
        FluidFrames.InitTempDraggableFrames = TBag_FF_Hook;
end

