-- $Id$

local _G = getfenv(0)
local TFuBag = _G.TFuBag
TFuBag.Bank = {}
local Bank = TFuBag.Bank
Bank.PREFIX = "TFuBnk"  -- window short-prefix for _G[...] chrome lookups (Tier 1)

-- Bank module: 12.0 C_Bank rewrite (Stage 1, read layer). The classic fixed-bank
-- API (BANK_CONTAINER, REAGENTBANK_CONTAINER, 7 purchasable bag slots) is gone;
-- 12.0 uses a tab-as-container model (Enum.BagIndex.CharacterBankTab_1..6 = 6-11,
-- AccountBankTab_1..5 = 12-16) read with the same C_Container calls as bags.
-- We do NOT hijack Blizzard's BankFrame (Syndicator/Baganator don't either) -- it
-- opens normally alongside ours; all C_Bank reads are AllowedWhenUntainted.
-- See tbag-fufu-bank-rewrite-design.md.
TFuBag.BANK_ENABLED = true

-- Include warband/account bank tabs (12-16) alongside character tabs (6-11).
-- Reads are taint-safe; deposit/purchase actions are deferred to later stages.
TFuBag.BANK_INCLUDE_WARBAND = true

-- Localization Support
local L = TFuBag.LOCALE;

BINDING_NAME_TFuBNK_TOGGLE = L["Toggle Bank Window"];

-- Constants
TFuBnk_SHOWITEMDEBUGINFO = 0;
local TFuBnk_WIPECONFIGONLOAD = 0; -- for debugging, test it out on a new config every load


------------------------

function Bank:CalcButtonSize(newsize, pad)
  local k = "button_size_opts";
  -- constants
  self.BF_X_PAD = pad;
  self.BF_Y_PAD = pad;
  self.BF_WIDTH = newsize;
  self.BF_HEIGHT = newsize;
  self.BF_PADWIDTH = self.BF_WIDTH + (self.BF_X_PAD*2);
  self.BF_PADHEIGHT = self.BF_HEIGHT + (self.BF_Y_PAD*2);
  self.BGF_WIDTH = self.BF_WIDTH * 1.6 + (self.BF_X_PAD*2);
  self.BGF_HEIGHT = self.BF_HEIGHT * 1.6 + (self.BF_Y_PAD*2);

  -- Always ensure a visually appealing fit
  self.BGF_WIDTH = TFuBag:MakeEven(self.BGF_WIDTH, self.BF_WIDTH);
  self.BGF_HEIGHT = TFuBag:MakeEven(self.BGF_HEIGHT, self.BF_HEIGHT);
end

function Bank:SetDefPos(cfg, reset)
  TFuBag:SetDef(cfg, "frameLEFT", UIParent:GetRight() * UIParent:GetScale() * 0.294, reset, TFuBag.NumFunc);
  TFuBag:SetDef(cfg, "frameRIGHT", UIParent:GetRight() * UIParent:GetScale() * 0.684, reset, TFuBag.NumFunc);
  TFuBag:SetDef(cfg, "frameTOP", UIParent:GetTop() * UIParent:GetScale() * 0.83, reset, TFuBag.NumFunc);
  TFuBag:SetDef(cfg, "frameBOTTOM", UIParent:GetTop() * UIParent:GetScale() * 0.232, reset, TFuBag.NumFunc);
  TFuBag:SetDef(cfg, "frameXRelativeTo", "LEFT", reset, TFuBag.StrFunc, {"RIGHT","LEFT"} );
  TFuBag:SetDef(cfg, "frameYRelativeTo", "BOTTOM", reset, TFuBag.StrFunc, {"TOP","BOTTOM"} );
end

function Bank:InitDefVals(reset)
  local i, key, value;
  local cfg = self.cfg;

  TFuBag:InitDefVals(cfg, self.bags, 4, reset);

  TFuBag:SetDef(cfg, "maxColumns", 14, reset, TFuBag.NumFunc, TFuBag.NUMCOL_MIN,TFuBag.NUMCOL_MAX);

  TFuBag:SetDef(cfg, "show_purchase_button", 0, reset, TFuBag.NumFunc, 0, 1);
  TFuBag:SetDef(cfg, "show_purchasetoggle", 1, reset, TFuBag.NumFunc, 0, 1);
  TFuBag:SetDef(cfg, "show_searchbox", 1, reset, TFuBag.NumFunc, 0, 1);

  -- Colors
  TFuBag:SetColor(cfg, "bkgr_"..TFuBag.MAIN_BAR, 0.3, 0.1, 0.0, 0.4, reset);
  TFuBag:SetColor(cfg, "brdr_"..TFuBag.MAIN_BAR, 0.7, 0.1, 0.1, 0.3, reset);
  for i = 1, TFuBag.BAR_MAX do
    TFuBag:SetColor(cfg, "bkgr_"..i, 0.3, 0.1, 0.0, 0.4, reset);
    TFuBag:SetColor(cfg, "brdr_"..i, 0.7, 0.1, 0.1, 0.3, reset);
  end
  TFuBag:SetDefColors(cfg, reset);

  self:SetDefPos(cfg, reset);

end

function Bank:SetPlayer(playerid)
  if self.playerid ~= playerid then
    self.CACHE_REQ = TFuBag.REQ_MUST
  end
  self.playerid = playerid;
  -- Render the viewed character with THEIR profile (see Inv:SetPlayer).
  self.cfg = TFuBag:CfgForPlayer(playerid, "Bnk");
  if (playerid ~= TFuBag.PLAYERID) then
    self:CompleteAltCfg("Bnk");
  end
  TFuBag.Tokens.Update(TFuBnkFrame_TokenFrame)
end

-- Set reset=1 to restore default values
function Bank:init(reset)
  if not Bank.metatabledone then
    setmetatable(TFuBag.MainFrame, getmetatable(TFuBnkFrame))
    setmetatable(TFuBag.Bank,{__index=TFuBag.MainFrame})
    setmetatable(TFuBnkFrame,{__index=TFuBag.Bank})
    Bank.metatabledone = true
  end
  self = TFuBnkFrame
  self:SetUserPlaced(false) -- remove us from the layout-cache

  -- Bank switching
  self.playerid = "";
  self.atbank = 0;
  self.physAtBank = 0;
  -- 12.0: bag list is built dynamically from purchased tabs on BANKFRAME_OPENED
  -- (Bank:RebuildTabList). Empty until then. tabData caches per-tab name/icon/type;
  -- tabFramesCreated tracks which tab container frames we've already built.
  self.bags = {}
  self.tabData = {}
  self.tabFramesCreated = {}
  -- Active bank view (Character vs Account/Warband). Default Character; switched via
  -- Bank:SetBankType / Bank:ToggleBankType. Only the active type is scanned/rendered.
  self.bankType = Enum.BankType and Enum.BankType.Character

  self.CACHE_REQ = TFuBag.REQ_NONE

  self.cfg = nil;
  self.BARITM = {};
  self.hilight_new = 0;
  self.edit_mode = 0;
  self.ml_edit = 0;               -- Manual Layout edit/unlock: 1 = boxes draggable; manual_layout stays active when this is 0
  self.edit_hilight = "";         -- when editmode is 1, which items do you want to hilight
  self.edit_selected = "";        -- when editmode is 1, this is the class of item you clicked on
  self.RightClickMenu_mode = "";
  self.RightClickMenu_opts = {};
  self.RightClickMenu = TFuBnkFrame_RightClickMenu

  self.BC_LIST = {};  -- Bar to Class list

  self.BF_X_PAD = 1;
  self.BF_Y_PAD = 1;
  self.BF_WIDTH = 34;
  self.BF_HEIGHT = 34;
  self.BF_PADWIDTH = 36;
  self.BF_PADHEIGHT = 36;
  self.BGF_WIDTH = 38;
  self.BGF_HEIGHT = 38;


  TFuBag:Init();

  self.cfg = TFuBag:ActiveCfg("Bnk")
  local cfg = self.cfg
  self.atbank = 0
  self.physAtBank = 0

  if ( TFuBnk_WIPECONFIGONLOAD == 1 ) then
    cfg = {};
  end

  self:SetPlayer(TFuBag.PLAYERID);

  -- Scroll viewport (WowScrollBox single-content-frame pattern; see TInv.lua).
  -- Cached on self so Bank:RebuildTabList can parent newly-created tab container
  -- frames (warband tabs 12-16 have no static XML frame) into the same content frame.
  local bnkContainer = TFuBnkFrame.Scroll
    and TFuBnkFrame.Scroll.ScrollChild
    and TFuBnkFrame.Scroll.ScrollChild.Container;
  self.bnkContainer = bnkContainer or TFuBnkFrame;

  -- Per-tab dummy bag frames + item buttons are created lazily on bank open
  -- (Bank:RebuildTabList), since the tab set isn't known until BANKFRAME_OPENED.

  TFuBag:CreateFrame("Frame", "TFuBnkFrame_bar_", bnkContainer or TFuBnkFrame,
    "TFuBag_BarFrameTemplate", TFuBag.BAR_MAX, "");
  TFuBag:CreateFrame("Button", "TFuBnkFrame_BarButton_", bnkContainer or TFuBnkFrame,
    "TFuBag_BarButtonTemplate", TFuBag.BAR_MAX, "");

  -- register slash command
  SlashCmdList["TFuBnk"] = TFuBnk_cmd;
  SLASH_TFuBnk1 = "/tbnk";

  -- load default values
  self:InitDefVals(reset);

  self:CalcButtonSize(cfg["frameButtonSize"], cfg["framePad"]);

  -- (Static bag-slot button scaling + InitBagGfx removed: the per-tab selector
  -- buttons are built on bank open in a later stage. We do NOT hijack Blizzard's
  -- BankFrame -- it opens normally alongside ours, avoiding the SetReplaceBank taint.)

  if (cfg["moveLock"] == 0) then
    TFuBnkLockNorm:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Locked-Up");
    TFuBnkLockPush:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Locked-Down");
  else
    TFuBnkLockNorm:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Unlocked-Up");
    TFuBnkLockPush:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Unlocked-Down");
  end

  TFuBnk_SearchBox:SetMaxLetters(25);

  -- 12.0 Stage 1: the static classic bag-slot selector buttons (7 bank bags + bank
  -- + reagent) are not wired to the tab-as-container model and reference removed APIs
  -- on hover (e.g. GetReagentBankCost). Per-tab selector buttons replace them in
  -- Stage 2; until then, always hide them so they can't be hovered/clicked into the
  -- removed classic-bank code paths.
  TFuBnkFrameBag1:Hide();
  TFuBnkFrameBag2:Hide();
  TFuBnkFrameBag3:Hide();
  TFuBnkFrameBag4:Hide();
  TFuBnkFrameBag5:Hide();
  TFuBnkFrameBag6:Hide();
  TFuBnkFrameBag7:Hide();
  TFuBnkFrameBagBank:Hide();
  TFuBnkFrameBagReagent:Hide();

  -- Stage 2: build the per-tab selector strip (Character/Warband switch + one button
  -- per purchased tab + buy-tab affordance) in the bottom chrome. Created once; the
  -- active view's tab row is (re)populated on bank open by Bank:RefreshTabStrip.
  self:BuildTabStrip();
  -- Honor a saved "Hide Bag Buttons" choice: in 12.0 that toggles the per-tab strip.
  if (cfg["show_bagbuttons"] == 0 and TFuBnkFrame.TabStrip) then
    TFuBnkFrame.TabStrip:Hide();
  end

  if (cfg["show_searchbox"] == 0) then
    TFuBnk_SearchBox:Hide();
  end
  if (cfg["show_userdropdown"] == 0) then
    TFuBnk_UserDropdown:Hide();
  end
  if (cfg["show_reloadbutton"] == 0) then
    TFuBnk_Button_Reload:Hide();
  end
  if (cfg["show_editbutton"] == 0) then
    TFuBnk_Button_ChangeEditMode:Hide();
  end
  if (cfg["show_hilightbutton"] == 0) then
    TFuBnk_Button_HighlightToggle:Hide();
  end
  if (cfg["show_lockbutton"] == 0) then
    TFuBnk_Button_MoveLockToggle:Hide();
  end
  if (cfg["show_closebutton"] == 0) then
    TFuBnk_Button_Close:Hide();
  end
  if (cfg["show_total"] == 0) then
    TFuBnkFrame_Total:Hide();
  end
  if (cfg["show_money"] == 0) then
    TFuBnkFrame_MoneyFrame:Hide();
  end
  if (cfg["show_tokens"] == 0) then
    TFuBnkFrame_TokenFrame:Hide();
  end
  if (cfg["show_filterbutton"] == 0) then
    TFuBnk_Button_Filter:Hide();
  end

  TFuBag:BuildBarClassList(self.BC_LIST, cfg);

  -- Do one sorting to init the baritm array
  self.BARITM = TFuBag:SortItmCache(cfg,
    self.playerid, TFuBnkItm[self.playerid], self.BARITM, self.bags);
  TFuBag:LayoutWindow(self)
end

-- Probe whether a bank type has any purchased tabs available.
local function FetchTabsFor(bankType)
  if (bankType == nil or not C_Bank or not C_Bank.FetchPurchasedBankTabData) then return nil; end
  local ok, tabs = pcall(C_Bank.FetchPurchasedBankTabData, bankType)
  if (ok and tabs and #tabs > 0) then return tabs; end
  return nil;
end

-- Default per-tab selection-border colors. Deliberately avoids the WoW item-rarity
-- colors -- especially deep blue (0,0,1) = "rare" -- so the crisp tab border isn't
-- mistaken for a rarity border on nearby items. Cycled by tab position; the user can
-- still recolor any tab in the options (these only seed tabs with no saved color).
local TAB_DEFAULT_COLORS = {
  { r = 1.00, g = 0.82, b = 0.00, a = 1 },  -- gold
  { r = 0.20, g = 0.85, b = 0.55, a = 1 },  -- teal
  { r = 1.00, g = 0.35, b = 0.80, a = 1 },  -- pink
  { r = 1.00, g = 0.50, b = 0.15, a = 1 },  -- amber
  { r = 0.55, g = 0.80, b = 1.00, a = 1 },  -- pale sky (clearly lighter than rare blue)
  { r = 0.80, g = 0.95, b = 0.30, a = 1 },  -- lime
}

-- Is this bank type SELECTABLE right now -- i.e. can the player view it (and thus
-- switch to / buy into it), even with ZERO purchased tabs? CanViewBank is the
-- authoritative gate; fall back to "has purchased tabs" on clients lacking it. This
-- is what makes an empty Character bank reachable (to buy a first tab) instead of a
-- greyed-out dead end.
local function IsBankViewable(bankType, tabs)
  if (bankType == nil) then return false; end
  if (C_Bank and C_Bank.CanViewBank) then
    local ok, can = pcall(C_Bank.CanViewBank, bankType)
    if (ok) then return can == true; end
  end
  return tabs ~= nil
end

-- 12.0 read layer: build the dynamic bag list from ONE bank type at a time (the
-- active self.bankType -- Character or Account/Warband), NOT both combined. Each is
-- a separate switchable view (Bank:SetBankType), mirroring Baganator's split bank
-- views. Rendering one type keeps the slot count (and per-open scan/layout cost) and
-- window height roughly halved. Tab ids ARE Enum.BagIndex container ids, read with
-- the same C_Container calls as bags. All C_Bank reads are AllowedWhenUntainted; no
-- Authoritative "a live bank session exists right now" signal for 12.0. Blizzard's
-- BankFrame opens on BANKFRAME_OPENED and its OnHide calls C_Bank.CloseBankFrame(), so
-- the panel being shown == an open server-side bank session. We read it (never write) so
-- there is no taint. This is more reliable than our own physAtBank latch, which OnHide
-- clears even though our no-op CloseBankFrame() stub leaves the session (and Blizzard's
-- bank) alive -- the desync that made the Show Bank toggle reopen the CACHED bank instead
-- of the live one while still standing at the banker.
function Bank:IsBankSessionLive()
  return (BankFrame and BankFrame:IsShown()) and true or false
end

-- Suppress / restore Blizzard's own bank window for the /tbnk blizzbank toggle.
--
-- We MUST NOT simply Hide() BankFrame: BankFrameMixin:OnHide calls C_Bank.CloseBankFrame()
-- (+ CloseAllBags), so hiding it during a live session closes the bank we just opened --
-- the contents go cached/blank and become un-clickable (and BANKFRAME_CLOSED tears down
-- tbag's windows). BankFrameMixin:OnShow likewise calls OpenAllBags.
--
-- Instead, mirror Baganator: NEUTRALIZE BankFrame's OnShow/OnHide/OnEvent and reparent it
-- under a permanently-hidden holder. Then it never renders AND hiding it never ends the
-- session. tbag drives everything itself: it opens its own inv window on BANKFRAME_OPENED
-- and ends the session via C_Bank.CloseBankFrame() from MainFrame:OnHide, so none of
-- Blizzard's BankFrame logic is needed. Fully reversible (restore the saved scripts +
-- reparent to UIParent) so the toggle can switch the default UI back on.
--
-- Order matters: neutralize OnHide BEFORE the reparent/Hide so neither can fire
-- CloseBankFrame. Money transfer (Blizzard BANK_MONEY_* popups) and item ops (untainted
-- C_* APIs) never route through BankFrame, so this touches no protected/secure path.
local blizzBankHolder   -- permanently-hidden reparent target (lazy)
local blizzBankSaved    -- captured Blizzard originals (once, before we neutralize)

function Bank:ApplyBlizzardBankSuppression()
  if (not BankFrame) then return end
  if (InCombatLockdown()) then return end  -- SetParent may be combat-protected; re-applied on next open
  if (not blizzBankSaved) then
    blizzBankSaved = {
      OnShow  = BankFrame:GetScript("OnShow"),
      OnHide  = BankFrame:GetScript("OnHide"),
      OnEvent = BankFrame:GetScript("OnEvent"),
      parent  = BankFrame:GetParent() or UIParent,
    }
  end

  local hide = (TFuBag.BANK_ENABLED and TFuBagCfg and TFuBagCfg["hide_blizzard_bank"] == 1)
  if (hide) then
    if (not blizzBankHolder) then
      blizzBankHolder = CreateFrame("Frame")
      blizzBankHolder:Hide()
    end
    BankFrame:SetScript("OnHide", nil)   -- FIRST: stop hide/reparent from closing the session
    BankFrame:SetScript("OnShow", nil)   -- stop OpenAllBags / tab setup on (re)show
    BankFrame:SetScript("OnEvent", nil)
    if (BankFrame:GetParent() ~= blizzBankHolder) then
      BankFrame:SetParent(blizzBankHolder)
    end
    if (BankFrame:IsShown()) then BankFrame:Hide() end  -- safe now (OnHide neutralized)
  elseif (blizzBankSaved) then
    BankFrame:SetScript("OnShow", blizzBankSaved.OnShow)
    BankFrame:SetScript("OnHide", blizzBankSaved.OnHide)
    BankFrame:SetScript("OnEvent", blizzBankSaved.OnEvent)
    if (BankFrame:GetParent() ~= blizzBankSaved.parent) then
      BankFrame:SetParent(blizzBankSaved.parent)
    end
  end
end

-- BankFrame hijack -> no taint. Run on BANKFRAME_OPENED + BANK_TABS_CHANGED + switch.
-- Live = a bank session is open AND we are viewing our OWN character. Only then do the
-- C_Bank reads return real data and the live controls (deposit / money transfer / buy
-- tab / tab settings) apply. Viewing another character, or our own bank away from a
-- banker, is a cache-only (read-only) view. Recomputed whenever the player selection or
-- physical bank state changes (RebuildTabList, dropdown switch).
--   physAtBank is our BANKFRAME_OPENED/CLOSED latch; BankFrame:IsShown() is the live
-- session itself. We OR them: closing the tbag window clears physAtBank but leaves the
-- session alive, so consulting the panel lets the Show Bank toggle re-open the LIVE bank
-- (as if you had clicked the banker) rather than the stale cached snapshot.
function Bank:RefreshLiveFlag()
  -- Heal the physAtBank latch from the authoritative session signal: if Blizzard's bank
  -- is open we ARE physically at a banker, even if OnHide cleared the latch. This keeps
  -- the physAtBank==1 gates in Events.lua (live tab/slot refreshes) working after the
  -- tbag window is closed and re-opened against a still-live session. BANKFRAME_CLOSED
  -- clears it again when the session actually ends.
  if (self:IsBankSessionLive()) then
    self.physAtBank = 1
  end
  -- ONE-WAY heal only (set, never clear). physAtBank is an event-driven latch:
  -- BANKFRAME_OPENED sets it, BANKFRAME_CLOSED / OnHide clears it. Do NOT also clear it
  -- from BankFrame:IsShown() here -- at BANKFRAME_OPENED time Blizzard has not shown its
  -- BankFrame yet (the open is a handshake; our handler runs first), so a two-way heal
  -- wrongly clears the just-set latch -> atbank = 0 -> RebuildTabList takes the cached
  -- (non-live) branch and the Warband view never appears on first open (it only shows
  -- after a dropdown round-trip re-runs this once the frame is finally shown).
  if (self.physAtBank == 1 and self.playerid == TFuBag.PLAYERID) then
    self.atbank = 1
  else
    self.atbank = 0
  end
end

-- Persist a character's purchased character-bank tab layout (ids + name/icon) so it can
-- be rendered from cache when that character's bank is viewed remotely. Stored per
-- character in TFuBagInfo. viewable mirrors C_Bank.CanViewBank (an empty-but-viewable
-- bank still snapshots, so it stays reachable). tabs == nil means "no purchased tabs".
function Bank:SaveCharTabSnapshot(playerid, tabs, viewable)
  if (not playerid) then return; end
  local info = TFuBagInfo and TFuBagInfo[playerid]
  if (not info) then return; end
  local snap = { viewable = (viewable == true), tabs = {} }
  if (tabs) then
    for _, t in ipairs(tabs) do
      if (t and t.ID) then
        snap.tabs[#snap.tabs + 1] = { ID = t.ID, name = t.name, icon = t.icon }
      end
    end
  end
  info.bankTabs_char = snap
end

-- Returns (tabs, viewable) for a character's persisted character-bank layout, or
-- (nil, false) if never snapshotted. An empty tab list is returned as nil so the
-- "pick a type that actually has tabs" logic in RebuildTabList matches the live path.
function Bank:LoadCharTabSnapshot(playerid)
  local info = playerid and TFuBagInfo and TFuBagInfo[playerid]
  local snap = info and info.bankTabs_char
  if (not snap) then return nil, false; end
  local tabs = snap.tabs
  if (not tabs or #tabs == 0) then tabs = nil; end
  return tabs, (snap.viewable == true)
end

-- Warband bank is account-wide, so its tab layout snapshot is shared across all
-- characters (TFuBagCfg), refreshed whenever any character views the warband bank live.
function Bank:SaveWarbandTabSnapshot(tabs, viewable)
  local snap = { viewable = (viewable == true), tabs = {} }
  if (tabs) then
    for _, t in ipairs(tabs) do
      if (t and t.ID) then
        snap.tabs[#snap.tabs + 1] = { ID = t.ID, name = t.name, icon = t.icon }
      end
    end
  end
  TFuBagCfg["bankTabs_warband"] = snap
end

-- Fallback for a character that has a persisted bank item cache but no saved tab
-- snapshot (cached under an older build, before SaveCharTabSnapshot existed). Build a
-- tab list from whatever tab bags in [lo, hi] actually hold cached slots, so that
-- character's bank still renders remotely instead of silently dropping to the wrong
-- view (e.g. the account-wide warband bank, whose tabs are shared + viewable for every
-- character). Names are placeholders; the real snapshot overwrites this the next time
-- that character visits its bank live. Returns nil when no bag in the range is cached.
function Bank:DeriveTabsFromCache(playerid, lo, hi)
  local itm = playerid and TFuBnkItm and TFuBnkItm[playerid]
  if (not itm) then return nil; end
  local tabs = nil
  for bag = lo, hi do
    local b = itm[bag]
    if (b and #b > 0) then
      tabs = tabs or {}
      tabs[#tabs + 1] = { ID = bag, name = string.format("Tab %d", #tabs + 1) }
    end
  end
  return tabs
end

function Bank:RebuildTabList()
  self:RefreshLiveFlag()
  local live = (self.atbank == 1)
  local prevBags = self.bags or {}
  -- Clear the currently-shown item buttons before rebuilding. Every character reuses the
  -- same character-bank bag ids (6-11), so a dropdown switch to another character keeps
  -- the same self.bags and the previous character's buttons would otherwise linger at
  -- stale positions until a full re-layout. The bank-type switch (SetBankType) already
  -- did this clear, which is why clicking a tab "fixed" the corruption; do it for every
  -- rebuild so the dropdown switch is clean too. UpdateWindow re-shows the active tabs'
  -- buttons immediately after; HideInactiveTabButtons (tail) covers tabs dropped here.
  self:HideAllTabButtons()
  local ids = {}
  local data = {}
  local available = {}

  local CHAR = Enum.BankType and Enum.BankType.Character
  local ACCT = Enum.BankType and Enum.BankType.Account

  -- Tab sources. When physically at our OWN bank (live), read the authoritative C_Bank
  -- tab data AND persist a snapshot so other characters / away-from-bank views can
  -- render the same layout from cache. Otherwise (viewing another character, or our own
  -- bank remotely) rebuild from that snapshot; item contents come from the persisted
  -- TFuBnkItm cache. Warband is account-wide, so its snapshot is shared (TFuBagCfg).
  local charTabs, warTabs = nil, nil
  local charViewable, warViewable = false, false
  if (live) then
    charTabs = FetchTabsFor(CHAR)
    charViewable = IsBankViewable(CHAR, charTabs)
    if (TFuBag.BANK_INCLUDE_WARBAND and ACCT ~= nil) then
      local locked = C_Bank and C_Bank.FetchBankLockedReason
        and C_Bank.FetchBankLockedReason(ACCT)
      if (locked == nil) then
        warTabs = FetchTabsFor(ACCT)
        warViewable = IsBankViewable(ACCT, warTabs)
      end
    end
    self:SaveCharTabSnapshot(self.playerid, charTabs, charViewable)
    if (TFuBag.BANK_INCLUDE_WARBAND and ACCT ~= nil) then
      self:SaveWarbandTabSnapshot(warTabs, warViewable)
    end
  else
    -- Viewing another character (or our own bank away from a banker): CHARACTER bank
    -- ONLY. The warband bank is account-wide and only meaningful live at the banker, so
    -- it is never offered in a cached view -- switching characters always lands on the
    -- character bank (warTabs / warViewable stay nil / false, so the Warband type-switch
    -- button is hidden and a stale Warband selection cannot carry over from the previous
    -- character). The character bank comes from the saved snapshot, or is synthesized
    -- from the persisted item cache when a character was last cached under an older
    -- build (before tab snapshotting existed).
    charTabs, charViewable = self:LoadCharTabSnapshot(self.playerid)
    if (charTabs == nil) then
      charTabs = self:DeriveTabsFromCache(self.playerid, 6, 11)
      if (charTabs ~= nil) then charViewable = true; end
    end
  end
  local tabsByType = {}
  if (CHAR ~= nil) then tabsByType[CHAR] = charTabs; end
  if (ACCT ~= nil) then tabsByType[ACCT] = warTabs; end

  -- A type is SELECTABLE (shown + clickable) if viewable, even with zero tabs -- so an
  -- empty Character bank is reachable to buy a first tab. Order: Character, Warband.
  if (charViewable) then available[#available + 1] = CHAR; end
  if (warViewable) then available[#available + 1] = ACCT; end

  local function selectable(t)
    if (t == nil) then return false; end
    for _, a in ipairs(available) do if (a == t) then return true; end end
    return false
  end

  -- When not live (viewing another character, or our own bank remotely), always default
  -- to the Character bank rather than inheriting the previously-shown character's view
  -- (e.g. a Warband selection that should never appear for an alt), so switching
  -- characters is consistent and lands on the character bank every time.
  if (not live) then self.bankType = CHAR; end

  -- Respect the current view if it is still selectable (even when it has 0 tabs --
  -- e.g. the user switched to an empty Character bank to buy a tab). Only when the
  -- current type is NOT selectable (first open, or a remote warband-only open) do we
  -- auto-pick: prefer a selectable type that actually has tabs, else the first
  -- selectable type (may be nil if no bank is viewable at all).
  if (not selectable(self.bankType)) then
    local pick = nil
    for _, t in ipairs(available) do
      if (tabsByType[t] ~= nil) then pick = t; break; end
    end
    self.bankType = pick or available[1]
  end
  local activeTabs = (self.bankType ~= nil) and tabsByType[self.bankType] or nil

  if (activeTabs) then
    for _, t in ipairs(activeTabs) do
      if (t and t.ID) then
        ids[#ids + 1] = t.ID
        data[t.ID] = { name = t.name, icon = t.icon, bankType = self.bankType }
      end
    end
  end

  self.bags = ids
  self.tabData = data
  self.availableBankTypes = available
  TFuBag.Bnk_Bags = ids   -- keep Member(Bnk_Bags, ...) branches working

  -- If the active tab set changed (first open after a reload: empty -> real tab IDs;
  -- or a Character<->Warband switch), the runtime BARITM is stale for the new set.
  -- A warm persisted TFuBnkItm makes UpdateItmCache report "no change" -> REQ_PART,
  -- which would skip the resort and leave categories unsorted until something else
  -- forced REQ_MUST (the "switch tabs to make it sort" symptom). Flag a one-shot full
  -- sort; CACHE_REQ is consumed + reset by the next UpdateWindow. An unchanged set
  -- (a same-session reopen) does NOT set this, so there is no per-open re-sort lag.
  local changed = (#prevBags ~= #ids)
  if (not changed) then
    for i = 1, #ids do
      if (prevBags[i] ~= ids[i]) then changed = true; break; end
    end
  end
  if (changed) then self.CACHE_REQ = TFuBag.REQ_MUST; end

  -- Per-tab config defaults. InitDefVals seeds show_Bag<id> + bag colors per bag,
  -- but it ran at login with an empty tab list, so tab ids have none -> the options
  -- "Show <tab>" checkbox reads cfg["show_Bag"<id>] == nil and SetValue(nil) errors
  -- (TBagOpt EnableLine). Seed them here (reset=nil preserves any user change).
  local cfg = self.cfg
  if (cfg) then
    local pal = TAB_DEFAULT_COLORS
    for idx, bag in ipairs(ids) do
      TFuBag:SetDef(cfg, "show_Bag"..bag, 1, nil, TFuBag.NumFunc, 0, 1)
      if (pal and #pal > 0) then
        local c = pal[((idx - 1) % #pal) + 1]
        if (c) then TFuBag:SetColor(cfg, "bag_"..bag, c.r, c.g, c.b, c.a, nil) end
      end
      -- Give this tab's empty slots a real category bar (29, same as the inventory's
      -- empty-slot bar) so they DISPLAY as drop targets. Without this the tab's
      -- EMPTY_<name>_SLOTS category had no bar (set up at login when the tab list was
      -- empty), so PickBar produced a nil bar and SortItmCache dropped every empty
      -- slot -- leaving nowhere to drag items INTO, and ghost cells on right-click-out.
      -- PickBar builds the same string from GetBagPosName (tab bagtype is 0 -> the
      -- GetBagPosName branch), so this key matches. reset=nil preserves user changes.
      TFuBag:SetCatBar(cfg, string.format(L["EMPTY_%s_SLOTS"], TFuBag:GetBagPosName(bag)), 29, nil)
    end
    -- Refresh the bar->class list so the newly-mapped empty categories resolve for
    -- edit-mode display (item placement reads cfg directly, but keep this in sync).
    TFuBag:BuildBarClassList(self.BC_LIST, cfg)
  end

  -- Ensure a dummy container frame + item buttons exist for each tab in the active
  -- view. Character tabs 6-11 reuse the static XML frames (TFuBnkainerFrame6..11);
  -- warband tabs 12-16 have none, so create them under the same scroll content frame.
  local parent = self.bnkContainer or TFuBnkFrame
  for _, bag in ipairs(ids) do
    local fname = TFuBag:GetDummyBagFrameName(bag)
    local f = _G[fname]
    if (not f) then
      f = CreateFrame("Frame", fname, parent, "TFuBagainerFrameTemplate")
      f:SetID(bag)
    elseif (f:GetParent() ~= parent) then
      -- Character-tab container frames (6-11) are defined in XML as children of the
      -- MAIN frame, not the scroll content (Container). Reparent them into Container --
      -- the same place the warband tabs (12-16) are created above -- so their item
      -- buttons are descendants of the WowScrollBox and get clipped at the scroll
      -- viewport. Without this an overflowing CHARACTER bank's items aren't clipped at
      -- the viewport bottom and bleed over the bottom chrome (Slots/Bags/Currency);
      -- the warband tabs looked fine only because they were already in Container.
      -- (Item buttons are children of this frame, so they follow the reparent.)
      f:SetParent(parent)
    end
    if (not self.tabFramesCreated[bag]) then
      TFuBag:CreateDummyBag(bag, "TFuBag_ItemButtonTemplate")
      self.tabFramesCreated[bag] = true
    end
  end

  -- Hide item buttons of any previously-created tab that is NOT in the active view.
  -- Without this, switching bank type (or opening warband remotely while character
  -- tabs were rendered earlier) leaves the other type's buttons visible -- they
  -- bleed/overlay on top of the active content (UpdateWindow only manages buttons
  -- for tabs in self.bags).
  self:HideInactiveTabButtons()

  self:RefreshTabStrip()
end

-- Hide every item button of the currently-listed tabs. Used before switching bank
-- types so the previous view's buttons don't linger visible behind the new one.
function Bank:HideAllTabButtons()
  for _, bag in ipairs(self.bags or {}) do
    for slot = 1, TFuBag:GetBagMaxItems(bag) do
      local b = _G[TFuBag:GetBagItemButtonName(bag, slot)]
      if (b) then b:Hide(); end
    end
  end
end

-- Hide item buttons for every tab we've ever created that is NOT in the current
-- active view (self.bags). Prevents the other bank type's content from bleeding
-- through / overlaying the active view.
function Bank:HideInactiveTabButtons()
  local active = {}
  for _, bag in ipairs(self.bags or {}) do active[bag] = true end
  for bag in pairs(self.tabFramesCreated or {}) do
    if (not active[bag]) then
      for slot = 1, TFuBag:GetBagMaxItems(bag) do
        local b = _G[TFuBag:GetBagItemButtonName(bag, slot)]
        if (b) then b:Hide(); end
      end
    end
  end
end

-----------------------------------------------------------------------
-- Stage 2: per-tab selector strip
-----------------------------------------------------------------------
-- A horizontal row in the bank window's bottom chrome (where the classic bag-slot
-- buttons used to live): the Character/Warband view switch, one selector button per
-- purchased tab of the active view, and a buy-tab affordance. Each per-tab button IS
-- the bag-selector frame (named "TFuBnkTabBtn"<id>, see TFuBag:GetBagFrameName), so
-- GetChecked()/GetCheckedTexture() drive the existing spotlight + color machinery.
local TABBTN_SIZE = 26
local TABBTN_GAP = 4
local TYPEBTN_SIZE = 34   -- Character/Warband view-switch icons: larger than the tab icons
-- Tintable selection/hover ring (glowing square border, takes a vertex color).
local TAB_SEL_TEX = "Interface\\Buttons\\UI-ActionButton-Border"
local TAB_FALLBACK_ICON = 134400  -- INV_Misc_QuestionMark

-- Create the strip container + the static (Character/Warband/buy) buttons once.
function Bank:BuildTabStrip()
  if (TFuBnkFrame.TabStrip) then return; end

  -- Parented to the bank window (NOT UIParent like the interim floats): the strip
  -- sits inside the window's reserved bottom chrome, within the frame bounds, so the
  -- clipChildren scroll cascade doesn't clip it. Anchored to the bottom edge so it
  -- stays put as the scroll viewport caps the window height.
  local strip = CreateFrame("Frame", "TFuBnkFrame_TabStrip", TFuBnkFrame)
  strip:SetSize(TABBTN_SIZE, TABBTN_SIZE)
  -- Share the bottom Total row, flowing right from the Total text -- exactly the
  -- freed space the classic bag-slot grid used (anchored to $parent_Total too). The
  -- strip is just a left-anchor for the button row; its own size doesn't bound the
  -- children (no clip on the strip; clipChildren clips at the TFuBnkFrame edge).
  -- Flow the tab row right from the Total with a normal gap. (The old wider gap that
  -- cleared the bottom-left free-slots cell is gone -- that cell moved to the bottom of
  -- the item area as the single empty-slot widget.)
  strip:SetPoint("BOTTOMLEFT", TFuBnkFrame_Total, "BOTTOMRIGHT", 4, 0)
  TFuBnkFrame.TabStrip = strip

  -- Character / Warband view switch -- icon buttons matching the per-tab selector style
  -- (icon + a 2px accent selection border on the ACTIVE view), replacing the old text
  -- buttons so they match the rest of tbag's icon chrome. Field names kept (MainFrame:
  -- OnHide and /tbnk reference them). TYPE_SEL = the active-view border colour (gold).
  local TYPE_SEL = { 1, 0.82, 0, 1 }
  local function mkTypeButton(name, applyIcon, tipTitle, tipBody, onClick)
    local b = CreateFrame("Button", name, strip)
    b:SetSize(TYPEBTN_SIZE, TYPEBTN_SIZE)
    local icon = b:CreateTexture(nil, "BACKGROUND")
    icon:SetPoint("TOPLEFT", 1, -1); icon:SetPoint("BOTTOMRIGHT", -1, 1)
    applyIcon(icon)
    b.tfuIcon = icon
    -- 2px solid selection border (mirror GetTabButton), painted on the active view.
    local function mkEdge() local e = b:CreateTexture(nil, "OVERLAY"); e:SetColorTexture(0, 0, 0, 0); return e end
    local eT, eB, eL, eR = mkEdge(), mkEdge(), mkEdge(), mkEdge()
    eT:SetPoint("TOPLEFT"); eT:SetPoint("TOPRIGHT"); eT:SetHeight(2)
    eB:SetPoint("BOTTOMLEFT"); eB:SetPoint("BOTTOMRIGHT"); eB:SetHeight(2)
    eL:SetPoint("TOPLEFT"); eL:SetPoint("BOTTOMLEFT"); eL:SetWidth(2)
    eR:SetPoint("TOPRIGHT"); eR:SetPoint("BOTTOMRIGHT"); eR:SetWidth(2)
    b.tfuEdges = { eT, eB, eL, eR }
    b.SetSelectedBorder = function(_, on)
      local a = on and 1 or 0
      for _, e in ipairs(b.tfuEdges) do e:SetColorTexture(TYPE_SEL[1], TYPE_SEL[2], TYPE_SEL[3], a) end
    end
    local hl = b:CreateTexture(nil, "HIGHLIGHT"); hl:SetAllPoints(); hl:SetColorTexture(1, 1, 1, 0.15)
    b:SetScript("OnClick", onClick)
    b:SetScript("OnEnter", function(self) TFuBag.NewbieTip(self, tipTitle, 1.0, 1.0, 1.0, tipBody) end)
    b:SetScript("OnLeave", function() GameTooltip:Hide(); ResetCursor() end)
    return b
  end

  local cb = mkTypeButton("TFuBnkFrame_CharTabButton",
    function(icon) icon:SetTexture("Interface\\Icons\\INV_Misc_Bag_08") end,
    L["Character"], "Show your character's personal bank.",
    function() TFuBnkFrame:SetBankType(Enum.BankType.Character); end)
  cb:SetPoint("LEFT", strip, "LEFT", 0, 0)
  TFuBnkFrame.CharTabButton = cb

  local wb = mkTypeButton("TFuBnkFrame_WarbandTabButton",
    function(icon) icon:SetAtlas("warbands-icon") end,
    L["Warband"], "Show the account-wide Warband bank.",
    function() TFuBnkFrame:SetBankType(Enum.BankType.Account); end)
  wb:SetPoint("LEFT", cb, "RIGHT", TABBTN_GAP, 0)
  TFuBnkFrame.WarbandTabButton = wb

  -- Buy-tab affordance: shown only when C_Bank.CanPurchaseBankTab is true.
  -- C_Bank.PurchaseBankTab is a PROTECTED (HasRestrictions) function: an addon-shown
  -- CONFIRM_BUY_BANK_TAB popup runs its OnAccept tainted, so the purchase is silently
  -- blocked (dialog just closes). The taint-safe path (per Baganator) is to inherit
  -- Blizzard's secure BankPanelPurchaseButtonScriptTemplate -- its OnClick (Blizzard
  -- code) shows the popup UNTAINTED -- and tell it which bank type via the
  -- "overrideBankType" attribute (set in RefreshTabStrip). Do NOT SetScript("OnClick")
  -- here: that would replace the secure handler. Hook it only for non-secure extras.
  local buy = CreateFrame("Button", "TFuBnkFrame_BuyTabButton", strip,
    "UIPanelButtonTemplate, BankPanelPurchaseButtonScriptTemplate")
  buy:SetSize(TABBTN_SIZE, TABBTN_SIZE)
  buy:SetText("+")
  buy:SetScript("OnEnter", function(b)
    GameTooltip:SetOwner(b, "ANCHOR_TOP")
    GameTooltip:SetText(L["Buy a Bank Tab"], 1, 1, 1)
    local nt = C_Bank and C_Bank.FetchNextPurchasableBankTabData
      and C_Bank.FetchNextPurchasableBankTabData(TFuBnkFrame.bankType)
    if (nt and nt.tabCost) then SetTooltipMoney(GameTooltip, nt.tabCost) end
    GameTooltip:Show()
  end)
  buy:SetScript("OnLeave", function() GameTooltip:Hide() end)
  buy:Hide()
  TFuBnkFrame.BuyTabButton = buy

  -- Warband-money deposit / withdraw controls. These reuse Blizzard's own
  -- StaticPopupDialogs ("BANK_MONEY_DEPOSIT" / "BANK_MONEY_WITHDRAW", defined in
  -- Blizzard_UIPanels_Game/BankFrame.lua); their OnAccept runs Blizzard code that
  -- calls C_Bank.DepositMoney / C_Bank.WithdrawMoney, so the protected transfer is
  -- never invoked from tainted addon code. We only pass the bankType in the dialog
  -- data table -- no secure frame is touched. Parented to the strip (a plain frame
  -- we own), anchored next to the MoneyFrame in UpdateMoneyControls.
  -- Warband-money deposit / withdraw -- icon action buttons (top-bar style: icon + ADD
  -- highlight + tooltip), to match tbag's other icon buttons. Greyed via desaturation
  -- when the action isn't allowed (UpdateMoneyControls). Click logic unchanged (it
  -- drives Blizzard's BANK_MONEY_* popups, which run the protected transfer untainted).
  -- Both share the gold-coin icon; a colored badge (+ green deposit / - red withdraw)
  -- overlays it so the direction reads at a glance.
  local COIN_ICON = "Interface\\Icons\\INV_Misc_Coin_01"
  local function mkMoneyButton(name, badge, badgeColor, tipTitle, tipBody, onClick)
    local b = CreateFrame("Button", name, strip)
    b:SetSize(TABBTN_SIZE, TABBTN_SIZE)
    b:SetNormalTexture(COIN_ICON)
    b:SetPushedTexture(COIN_ICON)
    b:SetHighlightTexture(COIN_ICON)
    local h = b:GetHighlightTexture(); if (h) then h:SetBlendMode("ADD") end
    -- Direction badge drawn as crossing BARS, each anchored CENTER -- so the cross is
    -- exactly centered on the coin. (The minimap zoom atlas draws its glyph off-center
    -- within the texture, so anchoring it does NOT center the symbol; bars give the same
    -- bold +/- look, centered.) Each axis = a black outline bar + the colored bar. "+"
    -- gets both axes; "-" only the horizontal.
    local isPlus = (badge == "+")
    local inner = TABBTN_SIZE * 0.62
    local thick = math.max(3, math.floor(inner * 0.30))
    local parts = {}
    local function bar(w, hgt, sublevel, r, g, bl, a)
      a = a or 1
      local t = b:CreateTexture(nil, "OVERLAY")
      t:SetColorTexture(r, g, bl, a)
      t:SetDrawLayer("OVERLAY", sublevel)
      t:SetSize(w, hgt)
      t:SetPoint("CENTER", b, "CENTER", 0, 0)
      t.tfuBase = a
      parts[#parts + 1] = t
    end
    bar(inner + 2, thick + 2, 1, 0, 0, 0, 1)                                          -- h outline
    bar(inner,     thick,     2, badgeColor[1], badgeColor[2], badgeColor[3], 1)      -- h colour
    if (isPlus) then
      bar(thick + 2, inner + 2, 1, 0, 0, 0, 1)                                        -- v outline
      bar(thick,     inner,     2, badgeColor[1], badgeColor[2], badgeColor[3], 1)    -- v colour
    end
    b.SetBadgeDim = function(_, dim)
      for _, p in ipairs(parts) do p:SetAlpha(p.tfuBase * (dim and 0.35 or 1)) end
    end
    b:SetScript("OnClick", onClick)
    b:SetScript("OnEnter", function(self) TFuBag.NewbieTip(self, tipTitle, 1.0, 1.0, 1.0, tipBody) end)
    b:SetScript("OnLeave", function() GameTooltip:Hide(); ResetCursor() end)
    b:Hide()
    return b
  end

  local dep = mkMoneyButton("TFuBnkFrame_MoneyDepositButton", "+", { 0.1, 1.0, 0.1 },
    BANK_DEPOSIT_MONEY_BUTTON_LABEL or L["Deposit"], "Deposit money into the Warband bank.",
    function()
      StaticPopup_Hide("BANK_MONEY_WITHDRAW")
      if (StaticPopup_Visible("BANK_MONEY_DEPOSIT")) then
        StaticPopup_Hide("BANK_MONEY_DEPOSIT")
        return
      end
      StaticPopup_Show("BANK_MONEY_DEPOSIT", nil, nil, { bankType = Enum.BankType.Account })
    end)
  TFuBnkFrame.MoneyDepositButton = dep

  local wdr = mkMoneyButton("TFuBnkFrame_MoneyWithdrawButton", "-", { 1.0, 0.2, 0.2 },
    BANK_WITHDRAW_MONEY_BUTTON_LABEL or L["Withdraw"], "Withdraw money from the Warband bank.",
    function()
      StaticPopup_Hide("BANK_MONEY_DEPOSIT")
      if (StaticPopup_Visible("BANK_MONEY_WITHDRAW")) then
        StaticPopup_Hide("BANK_MONEY_WITHDRAW")
        return
      end
      StaticPopup_Show("BANK_MONEY_WITHDRAW", nil, nil, { bankType = Enum.BankType.Account })
    end)
  TFuBnkFrame.MoneyWithdrawButton = wdr

  TFuBnkFrame.tabButtons = TFuBnkFrame.tabButtons or {}
  self.tabSel = self.tabSel or {}
end

-- Show/position the warband deposit + withdraw buttons. They appear only when the
-- Warband (Account) view is active, the window shows the current player, and the
-- bank is open (the C_Bank money-transfer API requires an open bank session).
-- Anchored to the left of the MoneyFrame so they ride the same bottom-right chrome.
function Bank:UpdateMoneyControls()
  local dep = TFuBnkFrame.MoneyDepositButton
  local wdr = TFuBnkFrame.MoneyWithdrawButton
  if (not dep or not wdr) then return; end

  local ACCT = Enum.BankType and Enum.BankType.Account
  local isAcct = (self.bankType == ACCT)
  local isLive = (self.playerid == TFuBag.PLAYERID) and (self.atbank == 1)
  local moneyShown = (self.cfg["show_money"] == 1) and TFuBnkFrame_MoneyFrame:IsShown()

  local supported = false
  if (isAcct and isLive and moneyShown and C_Bank and C_Bank.DoesBankTypeSupportMoneyTransfer) then
    local ok, can = pcall(C_Bank.DoesBankTypeSupportMoneyTransfer, ACCT)
    supported = ok and can
  end

  if (not supported) then
    dep:Hide()
    wdr:Hide()
    return
  end

  local canDep, canWdr = false, false
  if (C_Bank.CanDepositMoney) then
    local ok, v = pcall(C_Bank.CanDepositMoney, ACCT)
    canDep = ok and v
  end
  if (C_Bank.CanWithdrawMoney) then
    local ok, v = pcall(C_Bank.CanWithdrawMoney, ACCT)
    canWdr = ok and v
  end
  dep:SetEnabled(canDep and true or false)
  wdr:SetEnabled(canWdr and true or false)
  -- Icon buttons don't grey on disable, so desaturate the icon + dim the badge bars.
  local dn = dep:GetNormalTexture(); if (dn) then dn:SetDesaturated(not canDep) end
  local wn = wdr:GetNormalTexture(); if (wn) then wn:SetDesaturated(not canWdr) end
  if (dep.SetBadgeDim) then dep:SetBadgeDim(not canDep) end
  if (wdr.SetBadgeDim) then wdr:SetBadgeDim(not canWdr) end

  -- Bottom-align the transfer buttons to the money frame's bottom edge so they share
  -- the gold display's spacing from the window bottom. Center-anchoring to the (shorter)
  -- money text let these taller buttons hang down onto the window's bottom edge.
  wdr:ClearAllPoints()
  wdr:SetPoint("BOTTOMRIGHT", TFuBnkFrame_MoneyFrame, "BOTTOMLEFT", -6, 0)
  dep:ClearAllPoints()
  dep:SetPoint("BOTTOMRIGHT", wdr, "BOTTOMLEFT", -4, 0)
  dep:Show()
  wdr:Show()
end

-- Get (or lazily create) the selector button for a tab id. Pooled by bag id; the
-- name matches GetBagFrameName so GetBagFrame(bag) resolves to it.
function Bank:GetTabButton(bag)
  local name = "TFuBnkTabBtn"..bag
  local btn = (TFuBnkFrame.tabButtons and TFuBnkFrame.tabButtons[bag]) or _G[name]
  if (btn) then return btn; end

  btn = CreateFrame("CheckButton", name, TFuBnkFrame.TabStrip)
  btn:SetSize(TABBTN_SIZE, TABBTN_SIZE)
  btn:SetID(bag)
  btn.tfuTabButton = true

  local icon = btn:CreateTexture(nil, "BACKGROUND")
  icon:SetPoint("TOPLEFT", 1, -1)
  icon:SetPoint("BOTTOMRIGHT", -1, 1)
  btn.tfuIcon = icon

  -- Selection = a crisp 2px SOLID colored frame around the icon (4 edge textures),
  -- NOT a soft ADD-blended fill (which washed the whole button on light colors and
  -- vanished on dark ones). SetColorTexture gives an exact, bright, defined border.
  -- UpdateBagColors paints these from cfg.bag_<id> at full alpha when checked, and
  -- clears them (alpha 0) when not -- see TFuBag:UpdateBagColors. No checked texture
  -- is set, so the engine's default whole-button check glow never shows.
  local function mkEdge()
    local e = btn:CreateTexture(nil, "OVERLAY")
    e:SetColorTexture(0, 0, 0, 0)
    return e
  end
  local eT, eB, eL, eR = mkEdge(), mkEdge(), mkEdge(), mkEdge()
  eT:SetPoint("TOPLEFT");    eT:SetPoint("TOPRIGHT");    eT:SetHeight(2)
  eB:SetPoint("BOTTOMLEFT"); eB:SetPoint("BOTTOMRIGHT"); eB:SetHeight(2)
  eL:SetPoint("TOPLEFT");    eL:SetPoint("BOTTOMLEFT");  eL:SetWidth(2)
  eR:SetPoint("TOPRIGHT");   eR:SetPoint("BOTTOMRIGHT"); eR:SetWidth(2)
  btn.tfuEdges = { eT, eB, eL, eR }

  -- Subtle hover wash so the button reacts to mouseover without competing with the
  -- selection border.
  local hl = btn:CreateTexture(nil, "HIGHLIGHT")
  hl:SetAllPoints()
  hl:SetColorTexture(1, 1, 1, 0.15)

  btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  btn:SetScript("OnClick", function(b, mouseButton) TFuBnkFrame:TabButton_OnClick(b, mouseButton); end)
  btn:SetScript("OnEnter", function(b)
    GameTooltip:SetOwner(b, "ANCHOR_TOP")
    local d = TFuBnkFrame.tabData and TFuBnkFrame.tabData[b:GetID()]
    GameTooltip:SetText((d and d.name) or L["Bank Tab"], 1, 1, 1)
    GameTooltip:AddLine(L["Right-click for tab settings"], 0.7, 0.7, 0.7)
    GameTooltip:Show()
  end)
  btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

  TFuBnkFrame.tabButtons[bag] = btn
  return btn
end

-- Left-click toggles selection (-> spotlight on that tab's slots, mirroring the
-- inventory bag-slot buttons). Right-click opens our tab-settings dialog WITHOUT
-- changing selection. self.tabSel is the authoritative selection state: SetChecked
-- is driven from it so the engine's built-in checkbox toggle can't desync it.
function Bank:TabButton_OnClick(btn, mouseButton)
  local bag = btn:GetID()
  self.tabSel = self.tabSel or {}
  if (mouseButton == "RightButton") then
    btn:SetChecked(self.tabSel[bag] == true)   -- revert any engine auto-toggle
    self:OpenTabSettings(bag)
    return
  end
  self.tabSel[bag] = not (self.tabSel[bag] == true)
  btn:SetChecked(self.tabSel[bag])
  TFuBag:UpdateBagColors(bag)        -- repaint the selection border immediately
  TFuBag:UpdateButtonHighlights()    -- and the item spotlights
end

-----------------------------------------------------------------------
-- Taint-safe tab-settings dialog (rename / icon / deposit flags)
-----------------------------------------------------------------------
-- A self-owned plain Frame (created with CreateFrame under TFuBnkFrame). It NEVER
-- touches Blizzard's secure BankPanel / BankPanelTabSettingsMenu objects. The only
-- write to game state is the public, AllowedWhenUntainted call
-- C_Bank.UpdateBankTabSettings(bankType, tabID, tabName, tabIcon, depositFlags)
-- (verified Blizzard_APIDocumentationGenerated/BankDocumentation.lua:291-303). Reads
-- use C_Bank.FetchPurchasedBankTabData (BankDocumentation.lua:210-223; returns
-- BankTabData with ID/bankType/name/icon/depositFlags, ibid:400-412). Both are
-- AllowedWhenUntainted, so calling them from addon code does not taint Blizzard
-- frames; building our own frame keeps the dialog itself off the secure path.

-- Right-click tab settings: open our own taint-safe dialog pre-filled from the tab's
-- live BankTabData, apply via the public C_Bank.UpdateBankTabSettings on OK.
function Bank:OpenTabSettings(bag)
  -- Tab settings modify the LIVE bank; only valid at our own banker. (No-op in a cached
  -- / other-character view, where the dialog's C_Bank writes would not apply.)
  if (self.atbank ~= 1) then return end
  local bankType = (self.tabData and self.tabData[bag] and self.tabData[bag].bankType)
    or self.bankType
  if (not C_Bank or not C_Bank.UpdateBankTabSettings) then
    TFuBag:Print(L["Tab settings are unavailable on this client."])
    return
  end
  -- Open the IconSelectorPopupFrameTemplate-based dialog (TBnkTabSettings.lua), which
  -- matches Blizzard's own bank tab settings: standalone window, Blizzard scrollbar, the
  -- icon-type dropdown (All/Spells/Items), the canonically-ordered icon grid, the deposit
  -- checkboxes, and the expansion filter dropdown.
  if (not TFuBnkTabSettings_Open(bankType, bag)) then
    TFuBag:Print(L["Tab settings are unavailable for this tab."])
  end
end

-- Repopulate the strip for the active view: enable/disable the type switch, lay out
-- one selector button per purchased tab, and show the buy affordance when allowed.
function Bank:RefreshTabStrip()
  self:BuildTabStrip()
  self.tabSel = self.tabSel or {}

  local CHAR = Enum.BankType and Enum.BankType.Character
  local ACCT = Enum.BankType and Enum.BankType.Account
  local avail = self.availableBankTypes or {}
  local hasChar, hasWar = false, false
  for _, t in ipairs(avail) do
    if (t == CHAR) then hasChar = true; elseif (t == ACCT) then hasWar = true; end
  end

  -- Type switch: a button shows only when its type is selectable (viewable); the
  -- active view's button is disabled ("you are here"). Hiding the non-viewable type
  -- avoids a greyed dead-end button. The strip is the anchor when neither shows.
  local cb = TFuBnkFrame.CharTabButton
  if (cb) then
    if (hasChar) then cb:Show() else cb:Hide() end
    if (cb.SetSelectedBorder) then cb:SetSelectedBorder(self.bankType == CHAR) end
  end
  local wb = TFuBnkFrame.WarbandTabButton
  if (wb) then
    if (hasWar and TFuBag.BANK_INCLUDE_WARBAND) then wb:Show() else wb:Hide() end
    if (wb.SetSelectedBorder) then wb:SetSelectedBorder(self.bankType == ACCT) end
  end

  -- Hide every known per-tab button, then lay out the active view's tabs after the
  -- rightmost visible type-switch button (or the strip's left edge if none shows).
  for _, b in pairs(TFuBnkFrame.tabButtons or {}) do b:Hide() end

  local strip = TFuBnkFrame.TabStrip
  local prev = nil
  if (wb and wb:IsShown()) then prev = wb elseif (cb and cb:IsShown()) then prev = cb end
  for _, bag in ipairs(self.bags or {}) do
    local btn = self:GetTabButton(bag)
    local d = self.tabData and self.tabData[bag]
    btn.tfuIcon:SetTexture((d and d.icon) or TAB_FALLBACK_ICON)
    btn:ClearAllPoints()
    if (prev) then
      btn:SetPoint("LEFT", prev, "RIGHT", TABBTN_GAP, 0)
    else
      btn:SetPoint("LEFT", strip, "LEFT", 0, 0)
    end
    btn:SetChecked(self.tabSel[bag] == true)
    TFuBag:UpdateBagColors(bag)   -- paint the selection border for the checked state
    btn:Show()
    prev = btn
  end

  local buy = TFuBnkFrame.BuyTabButton
  if (buy) then
    local canBuy = C_Bank and C_Bank.CanPurchaseBankTab and self.bankType ~= nil
      and C_Bank.CanPurchaseBankTab(self.bankType)
    if (canBuy) then
      -- Tell Blizzard's secure purchase OnClick which bank type to buy into.
      buy:SetAttribute("overrideBankType", self.bankType)
      buy:ClearAllPoints()
      if (prev) then
        buy:SetPoint("LEFT", prev, "RIGHT", TABBTN_GAP, 0)
      else
        buy:SetPoint("LEFT", strip, "LEFT", 0, 0)
      end
      buy:Show()
    else
      buy:Hide()
    end
  end
end

-- Switch the active bank view (Character <-> Account/Warband) and re-render.
function Bank:SetBankType(bankType)
  if (bankType == nil or bankType == self.bankType) then return; end
  self:HideAllTabButtons()
  self.bankType = bankType
  self:RebuildTabList()
  -- Character vs Warband are different category sets, so a Manual Layout snapshotted for
  -- one overlaps the other's content. While the layout is still auto (ml_auto), wipe it
  -- so UpdateWindow re-seeds cleanly for the new bank type. A hand-arranged layout
  -- (ml_auto false) is left alone -- the user owns its placement.
  local cfg = self.cfg
  if (cfg and cfg.manual_layout == 1 and cfg.legacy_edit ~= 1 and cfg.ml_auto) then
    local store = (cfg.ml_freeplace == 1) and cfg.cat_layout_free or cfg.cat_layout
    if (store) then for k in pairs(store) do store[k] = nil end end
  end
  self:UpdateWindow(TFuBag.REQ_MUST)
  -- Character vs Warband changes which bag items are deposit-eligible: repaint the
  -- inventory window so its greying tracks the active bank type.
  TFuBag:RequestUpdate(TFuInvFrame)
end

-- Toggle between the available bank types (for the interim /tbnk bank command;
-- clickable per-type tab buttons are the next stage).
function Bank:ToggleBankType()
  local avail = self.availableBankTypes or {}
  if (#avail < 2) then
    TFuBag:Print("TFuBnk: only one bank type available.")
    return
  end
  local CHAR = Enum.BankType and Enum.BankType.Character
  local ACCT = Enum.BankType and Enum.BankType.Account
  if (self.bankType == ACCT) then
    self:SetBankType(CHAR)
    TFuBag:Print("TFuBnk: showing Character bank.")
  else
    self:SetBankType(ACCT)
    TFuBag:Print("TFuBnk: showing Warband bank.")
  end
end

-- Returns the display label for the deposit button for the given bankType.
-- Uses the 12.0 global string tokens when present; falls back to plain strings.
local function DepositButtonLabel(bankType)
  local CHAR = Enum.BankType and Enum.BankType.Character
  local ACCT = Enum.BankType and Enum.BankType.Account
  if (bankType == ACCT) then
    return _G.ACCOUNT_BANK_DEPOSIT_BUTTON_LABEL or "Deposit All Warbound"
  end
  return _G.CHARACTER_BANK_DEPOSIT_BUTTON_LABEL or "Deposit All Reagents"
end

function Bank:GetDepositButtonLabel()
  return DepositButtonLabel(self.bankType)
end

-- Tooltip body for the deposit button, matched to the active bank type: the Warband
-- (Account) bank deposits all warbound-ELIGIBLE items (reagents, consumables like
-- flasks/potions/food/runes, warbound gear, ...), while the Character bank deposits
-- reagents only. The button label (above) already says "Deposit All Warbound" vs
-- "Deposit All Reagents"; this keeps the description honest too.
function Bank:GetDepositButtonDesc()
  local ACCT = Enum.BankType and Enum.BankType.Account
  if (self.bankType == ACCT) then
    return TFuBag.LOCALE["Deposits all Warbound-eligible items in your bags."]
  end
  return TFuBag.LOCALE["Deposits all Reagents in your bag."]
end

function Bank:UpdateDepositButton()
  local btn = TFuBnk_Button_DepositReagent
  if (self.atbank ~= 1) then
    btn:Hide()
    return
  end
  if (self.cfg and self.cfg["show_depositbutton"] == 0) then
    btn:Hide()
    return
  end
  local bankType = self.bankType
  local supported = bankType ~= nil
    and C_Bank and C_Bank.DoesBankTypeSupportAutoDeposit
    and C_Bank.DoesBankTypeSupportAutoDeposit(bankType)
  if (supported) then
    btn:Show()
  else
    btn:Hide()
  end
end

function Bank:UpdateBagGfx()
  local totalfree = 0;
  local totalsize = 0;

  for _, bag in ipairs(self.bags) do
    TFuBag:GetBagType(self.playerid, bag);   -- refresh cached bag-type for empty-slot categories
    TFuBag:UpdateBagColors(bag);

    local frametex = TFuBag:GetBagFrameTexture(bag);
    if (frametex) then
      frametex:SetVertexColor(1.0, 1.0, 1.0, 1.0);
      frametex:SetTexture(TFuBag:GetBagTexture(self.playerid, bag));
    end

    local free, size = TFuBag:UpdateSlots(self.playerid, bag, self.cfg["show_bag_sizes"]);
    totalfree = totalfree + free;
    totalsize = totalsize + size;
  end

  TFuBag:SetFreeStr(TFuBnkFrame_TotalText, totalfree, totalsize, self.cfg["show_bag_sizes"]);
end

function Bank:InitBagGfx()
  -- 12.0: per-tab selector buttons are built on bank open (Stage 2). Nothing to
  -- init statically; the classic bank/reagent/7-bag-slot graphics are gone.
end


function Bank.Button_HighlightToggle_OnClick(self)
  PlaySound(PlaySoundKitID and "igMainMenuOptioncheckBoxOn" or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
  if (TFuBag.SrchText) then
    TFuBag:ClearSearch();
    if (GameTooltip:GetOwner() == TFuBnk_Button_HighlightToggle) then
      if (TFuBnkFrame.hilight_new == 1) then
        TFuBag.NewbieTip(self, L["Normal"], 1.0, 1.0, 1.0,
                                 L["Stop highlighting new items."]);
      else
        TFuBag.NewbieTip(self, L["Highlight New"], 1.0, 1.0, 1.0,
                                 L["Highlight items marked as new."]);
      end
    end
    return;
  elseif (TFuBnkFrame.hilight_new == 0) then
    TFuBnkFrame.hilight_new = 1;
    if (GameTooltip:GetOwner() == TFuBnk_Button_HighlightToggle) then
      TFuBag.NewbieTip(self, L["Normal"], 1.0, 1.0, 1.0,
                               L["Stop highlighting new items."]);
    end
  else
    TFuBnkFrame.hilight_new = 0;
    if (GameTooltip:GetOwner() == TFuBnk_Button_HighlightToggle) then
      TFuBag.NewbieTip(self, L["Highlight New"], 1.0, 1.0, 1.0,
                               L["Highlight items marked as new."]);
    end
  end
  TFuBnkFrame:UpdateWindow();
end

function Bank.Button_ChangeEditMode_OnClick()
  PlaySound(PlaySoundKitID and "igMainMenuOptioncheckBoxOn" or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
  -- Mirror the inventory gear (Inv.Button_ChangeEditMode_OnClick): with Legacy Edit ON
  -- the gear toggles classic click editing; with it OFF the gear toggles Manual Layout
  -- (drag-to-arrange categories). Previously the bank only ever did edit_mode, so it had
  -- no drag-to-arrange regardless of the setting. The shared LayoutWindow ML path already
  -- handles any frame (use_ml checks cfg.manual_layout + playerid == PLAYERID).
  local cfg = TFuBnkFrame.cfg;
  if (cfg["legacy_edit"] == 1) then
    TFuBnkFrame.edit_mode = (TFuBnkFrame.edit_mode == 1) and 0 or 1;
  else
    -- Gear = lock/UNLOCK the manual layout (mirror of Inv). Unlocking activates manual
    -- layout; locking keeps it shown. Disable via "Use Manual Layout" in Options.
    TFuBnkFrame.edit_mode = 0;  -- classic edit off when using Manual Layout
    TFuBnkFrame.ml_edit = (TFuBnkFrame.ml_edit == 1) and 0 or 1;
    -- Activate manual layout on unlock; respect the user's Free Placement choice
    -- (do NOT force ml_freeplace -- both grid and free are fully supported now, and
    -- forcing it re-enabled Free Placement every time the gear was pressed).
    if (TFuBnkFrame.ml_edit == 1) then cfg["manual_layout"] = 1; end
  end

  -- Relayout (not resort): edit-mode/manual-layout only changes the layout, not
  -- categorization. Forcing a resort here scanned every item's tooltip -> major lag on a
  -- big bank.
  TFuBnkFrame._last_hilight = nil;  -- force the next edit-highlight refresh
  TFuBnkFrame.force_relayout = true;
  TFuBnkFrame:UpdateWindow(TFuBag.REQ_NONE);
end

function Bank.Button_Reload_OnClick()
  -- To avoid cleaning the bank cache, you only can reload bags at bank.
  if (TFuBnkFrame.atbank==1) then
    -- Hell, let's be paranoid
    if (TFuBnkFrame.playerid == TFuBag.PLAYERID) then
      TFuBag:ClearItmCache(TFuBnkItm[TFuBnkFrame.playerid], TFuBnkFrame.bags);
      TFuBag:ClearStackSkip(TFuBnkFrame.bags);
      TFuBag:ClearCompSkip(TFuBnkFrame.bags);

      -- Send a message to restack
      if (TFuBnkFrame.cfg["stack_resort"] == 1) then
        TFuBnkFrame.cfg["stack_once"] = 1;
      end
    end
  end

  TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
  TFuBag:PrintDEBUG("TFuBnk reloaded.");
end

function Bank.Button_DepositReagent_OnClick()
  local bankType = TFuBnkFrame.bankType
  if (bankType ~= nil and C_Bank and C_Bank.AutoDepositItemsIntoBank) then
    C_Bank.AutoDepositItemsIntoBank(bankType)
  end
end

function Bank.Button_Filter_OnClick(self)
  TFuBag:OpenFilterMenu(TFuBnkFrame, self);
end

-- Glow the filter button while any filter dimension is active (mirrors Inv).
function Bank.Button_MoveLockToggle_OnClick(self)
  PlaySound(PlaySoundKitID and "igMainMenuOptioncheckBoxOn" or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
  if (TFuBnkFrame.cfg["moveLock"] == 0) then
    TFuBnkFrame.cfg["moveLock"] = 1;
    TFuBnkLockNorm:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Unlocked-Up");
    TFuBnkLockPush:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Unlocked-Down");
    if (GameTooltip:GetOwner() == TFuBnk_Button_MoveLockToggle) then
      TFuBag.NewbieTip(self, L["Lock Window"], 1.0, 1.0, 1.0,
                               L["Prevent window from being moved by dragging it."]);
    end
  else
    TFuBnkFrame.cfg["moveLock"] = 0;
    TFuBnkLockNorm:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Locked-Up");
    TFuBnkLockPush:SetTexture("Interface\\AddOns\\tbag-fufu\\images\\LockButton-Locked-Down");
    if (GameTooltip:GetOwner() == TFuBnk_Button_MoveLockToggle) then
      TFuBag.NewbieTip(self, L["Unlock Window"], 1.0, 1.0, 1.0,
                               L["Allow window to be moved by dragging it."]);
    end
  end
end

function Bank.RightClick_DeleteItemOverride(self)
  local bag, slot, itm;
  local this = self or _G.this

  bag = this.value[TFuBag.I_BAG];
  slot = this.value[TFuBag.I_SLOT];

  if ( (bag ~= nil) and (slot ~= nil) ) then
  itm = TFuBnkItm[TFuBnkFrame.playerid][bag][slot];

  if (itm[TFuBag.I_ITEMLINK] ~= nil) then
    local id = TFuBag:GetItemID(itm[TFuBag.I_ITEMLINK]);
    if TFuBnkFrame.cfg["item_overrides"][id] ~= nil then
      TFuBnkFrame.cfg["item_overrides"][id] = nil;
      HideDropDownMenu(1);

      -- resort will force a window redraw as well
      TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
    end
  end
  end
end

function Bank.RightClick_SetItemOverride(self)
  local bag, slot, itm, new_barclass;
  local this = self or _G.this

  bag = this.value[TFuBag.I_BAG];
  slot = this.value[TFuBag.I_SLOT];
  new_barclass = this.value["barclass"];

  if ( (bag ~= nil) and (slot ~= nil) and (new_barclass ~= nil) ) then
  itm = TFuBnkItm[TFuBnkFrame.playerid][bag][slot];

  TFuBnkFrame.cfg["item_overrides"][TFuBag:GetItemID(itm[TFuBag.I_ITEMLINK])] = new_barclass;
  HideDropDownMenu(2);
  HideDropDownMenu(1);

  TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
  end
end

function Bank:SetTopLeftButton_Anchors()
  local buttons = {
    "TFuBnk_Button_HighlightToggle",
    "TFuBnk_Button_ChangeEditMode",
    "TFuBnk_Button_Reload",
    "TFuBnk_Button_Filter",
    "TFuBnk_Button_DepositReagent",
  };
  local button_left = nil;

  -- Handle user dropdown list separately...
  local dropdown = TFuBnk_UserDropdown;
  if (dropdown and dropdown:IsVisible()) then
    dropdown:ClearAllPoints();
    dropdown:SetPoint("TOPLEFT",TFuBnkFrame,"TOPLEFT",-10,-5);
    button_left = dropdown;
  end

  for _,button_name in ipairs(buttons) do
    local button = _G[button_name];
    if (button) then
      TFuBag:TrimButtonIcon(button);
      button:ClearAllPoints();
      if (button_left) then
        if (button_left == dropdown) then
          -- First button after dropdown
          button:SetPoint("TOPLEFT",button_left,"TOPRIGHT",15,-3);
        else
          -- button following another button
          button:SetPoint("TOPLEFT",button_left,"TOPRIGHT",2,0);
        end
      else
        -- First button if dropdown is hidden
        button:SetPoint("TOPLEFT",TFuBnkFrame,"TOPLEFT",9,-8);
      end
      if (button:IsVisible()) then
        button_left = button;
      end
    end
  end
end

function Bank:SetBottomLeftButton_Anchors()
  local buttons = {
    "TFuBnkFrame_Total",
    "TFuBnkFrameBagBank",
  }
  local button_left = nil;

  -- Handle search box separately (mirrors Inv:SetBottomLeftButton_Anchors).
  local search = TFuBnk_SearchBox;
  if (search and search:IsVisible()) then
    local y = 4;
    if (self.edit_mode == 1) then
      y = y + 30;
    end
    search:ClearAllPoints();
    search:SetPoint("BOTTOMLEFT",TFuBnkFrame,"BOTTOMLEFT",10,y);
    button_left = search;
  end

  for _,button_name in ipairs(buttons) do
    local button = _G[button_name];
    if (button) then
      button:ClearAllPoints();
      if (button_left) then
        if (button_left == search) then
          -- First button after search box
          button:SetPoint("BOTTOMLEFT",button_left,"TOPLEFT",0,4);
        else
          -- button following another button
          button:SetPoint("BOTTOMLEFT",button_left,"BOTTOMRIGHT",3,-1);
        end
      else
        -- First button
        local y = 12;
        if (self.edit_mode == 1) then
          y = y + 30;
        end
        button:SetPoint("BOTTOMLEFT",TFuBnkFrame,"BOTTOMLEFT",10,y);
      end
      if (button:IsVisible()) then
        button_left = button;
      end
    end
  end

  -- Figure the number of columns needed to require the bag buttons
  -- to be split into two rows
  local bags_row = 0;
  if (TFuBnkFrameBagBank:IsVisible()) then
    bags_row = bags_row + 5;
  end
  if (TFuBnkFrame_Total:IsVisible()) then
    bags_row = bags_row + 1;
  end
  if TFuBnkFrame_MoneyFrame:IsVisible() or TFuBnkFrame_TokenFrame:IsVisible() then
    bags_row = bags_row + 4;
  end

  if (self.cfg["maxColumns"] <= bags_row) then
    TFuBnkFrameBag4:ClearAllPoints()
    TFuBnkFrameBag4:SetPoint("BOTTOMLEFT",TFuBnkFrameBagBank,"TOPLEFT",0,3);
  else
    -- Now separate row required
    TFuBnkFrameBag4:ClearAllPoints()
    TFuBnkFrameBag4:SetPoint("BOTTOMLEFT",TFuBnkFrameBag3,"BOTTOMRIGHT",3,0);
  end

end

function Bank:SetBottomRightButton_Anchors()
  local buttons = {
    "TFuBnkFrame_MoneyFrame",
    "TFuBnkFrame_TokenFrame",
  }
  local button_right = nil

  for _, button_name in ipairs(buttons) do
    local button = _G[button_name]
    if button then
      button:ClearAllPoints()
      if button_right then
        button:SetPoint("BOTTOMRIGHT",button_right,"TOPRIGHT",0,-5);
      else
        local y = 5
        if self.edit_mode == 1 then
          y = y + 30
        end
        button:SetPoint("BOTTOMRIGHT",TFuBnkFrame,"BOTTOMRIGHT",5,y)
      end
      if button:IsVisible() then
        button_right = button
      end
    end
  end
end


function Bank.Toggle_DepositReagentButton()
  if (TFuBnkFrame.cfg["show_depositbutton"] == 1) then
    TFuBnkFrame.cfg["show_depositbutton"] = 0;
    TFuBnk_Button_DepositReagent:Hide();
    TFuBnkFrame:SetButton_Anchors();
  else
    TFuBnkFrame.cfg["show_depositbutton"] = 1;
    local bankType = TFuBnkFrame.bankType
    local supported = TFuBnkFrame.atbank == 1 and bankType ~= nil
      and C_Bank and C_Bank.DoesBankTypeSupportAutoDeposit
      and C_Bank.DoesBankTypeSupportAutoDeposit(bankType)
    if (supported) then
      TFuBnk_Button_DepositReagent:Show();
      TFuBnkFrame:SetButton_Anchors();
    end
  end
end

function Bank.Toggle_Money()
  if (TFuBnkFrame.cfg["show_money"] == 1) then
    TFuBnkFrame.cfg["show_money"] = 0;
    TFuBnkFrame_MoneyFrame:Hide();
    TFuBnkFrame:SetButton_Anchors();
  else
    TFuBnkFrame.cfg["show_money"] = 1;
    TFuBnkFrame_MoneyFrame:Show();
    TFuBnkFrame:SetButton_Anchors();
  end
  TFuBnkFrame:UpdateMoneyControls();
end

function Bank.Toggle_BagSlotButtons()
  -- 12.0: the bank's bag selector is the dynamic per-tab strip (Bank:BuildTabStrip), NOT the
  -- vestigial static TFuBnkFrameBag* frames -- those are kept hidden since the bank rewrite,
  -- and showing them left empty boxes on the bottom chrome. Toggle the strip instead;
  -- hiding the strip parent hides all its tab buttons regardless of RefreshTabStrip.
  if (TFuBnkFrame.cfg["show_bagbuttons"] == 1) then
    TFuBnkFrame.cfg["show_bagbuttons"] = 0;
    if (TFuBnkFrame.TabStrip) then TFuBnkFrame.TabStrip:Hide(); end
    TFuBnkFrame:SetButton_Anchors();
  else
    TFuBnkFrame.cfg["show_bagbuttons"] = 1;
    if (TFuBnkFrame.TabStrip) then TFuBnkFrame.TabStrip:Show(); end
    TFuBnkFrame:SetButton_Anchors();
  end
end


function Bank.RightClickMenu_populate(self, level)
  local bar, bag, slot;
  local info, itm, id, barclass, tmp, checked, i;
  local key, value, key2, value2;


  -------------------------------------------------------------------------------------------------
  ------------------------------- ITEM CONTEXT MENU -----------------------------------------------
  -------------------------------------------------------------------------------------------------
  if (TFuBnkFrame.RightClickMenu_mode == "item") then
  -- we have a right click on a button

  bar = TFuBnkFrame.RightClickMenu_opts[TFuBag.I_BAR];
  bag = TFuBnkFrame.RightClickMenu_opts[TFuBag.I_BAG];
  slot = TFuBnkFrame.RightClickMenu_opts[TFuBag.I_SLOT];
  itm = TFuBnkItm[TFuBnkFrame.playerid][bag][slot];
  id = TFuBag:GetItemID(itm[TFuBag.I_ITEMLINK]);

  if (level == 1) then
    -- top level of menu

    info = { ["text"] = itm[TFuBag.I_NAME], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = { ["disabled"] = 1, ["notCheckable"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = { ["text"] = string.format(L["Current Category: %s"],itm[TFuBag.I_CAT]), ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = { ["disabled"] = 1, ["notCheckable"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = { ["text"] = L["Assign item to category:"], ["hasArrow"] = 1, ["value"] = "override_placement" };
    if (TFuBnkFrame.cfg["item_overrides"][id] ~= nil) then
  info["checked"] = 1;
    end
    UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = L["Use default category assignment"],
  ["value"] = { [TFuBag.I_BAG]=bag, [TFuBag.I_SLOT]=slot },
  ["func"] = TFuBnkFrame.RightClick_DeleteItemOverride
  };
    if (TFuBnkFrame.cfg["item_overrides"][id] == nil) then
  info["checked"] = 1;
    end
    UIDropDownMenu_AddButton(info, level);

    if (TFuBnk_SHOWITEMDEBUGINFO==1) then
  info = { ["disabled"] = 1, ["notCheckable"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  info = { ["text"] = L["Debug Info: "], ["hasArrow"] = 1, ["value"] = "show_debug" };
  UIDropDownMenu_AddButton(info, level);
    end
  elseif (level == 2) then
    if ( UIDROPDOWNMENU_MENU_VALUE == "override_placement" ) then
  for i = 1, TFuBag.BAR_MAX do
  info = {
    ["text"] = string.format(L["Categories within bar %d"],i);
    ["value"] = { ["opt"]="override_placement_select", [TFuBag.I_BAG]=bag, [TFuBag.I_SLOT]=slot, ["select_bar"]=i },
    ["hasArrow"] = 1
    };
  if ( (TFuBnkFrame.cfg["item_overrides"][id] ~=
  nil) and (TFuBag:GetCat(TFuBnkFrame.cfg, TFuBnkFrame.cfg["item_overrides"][id]) == i) ) then
    info["checked"] = 1;
  end
  UIDropDownMenu_AddButton(info, level);
  end
    elseif ( UIDROPDOWNMENU_MENU_VALUE == "show_debug" ) then
  for key, value in pairs(itm) do
  if (value == nil) then
    info = { ["text"] = "|cFFFF7FFF"..key.."|r = |cFF007FFFNil|r", ["notClickable"] = 1 };
    UIDropDownMenu_AddButton(info, level);
  else
    if ( (type(value) == "number") or (type(value) == "string") ) then
  info = { ["text"] = "|cFFFF7FFF"..key.."|r = |cFF007FFF"..value.."|r", ["notClickable"] = 1 };
  UIDropDownMenu_AddButton(info, level);
    else
  info = { ["text"] = "|cFFFF7FFF"..key.."|r|cFF338FFF=>Array()|r", ["notClickable"] = 1 };
  UIDropDownMenu_AddButton(info, level);
  for key2, value2 in pairs(value) do
  info = { ["text"] = "  |cFFFF7FFF["..key2.."]|r = |cFF338FFF"..value2.."|r", ["notClickable"] = 1 };
  UIDropDownMenu_AddButton(info, level);
  end
    end
  end
  end
    end
  elseif (level == 3) then
    if ( UIDROPDOWNMENU_MENU_VALUE ~= nil ) then
  if ( UIDROPDOWNMENU_MENU_VALUE["opt"] == "override_placement_select" ) then
  for key, barclass in pairs(TFuBnkFrame.BC_LIST[UIDROPDOWNMENU_MENU_VALUE["select_bar"]]) do
    info = {
  ["text"] = barclass;
  ["value"] = { [TFuBag.I_BAG]=bag, [TFuBag.I_SLOT]=slot, ["barclass"]=barclass },
  ["func"] = TFuBnkFrame.RightClick_SetItemOverride
  };
    if (TFuBnkFrame.cfg["item_overrides"][id] == barclass) then
  info["checked"] = 1;
    end
    UIDropDownMenu_AddButton(info, level);
  end
  end
    end
  end

  -------------------------------------------------------------------------------------------------
  ------------------------ SLOT TARGET CONTEXT MENU -----------------------------------------------
  -------------------------------------------------------------------------------------------------
  elseif (TFuBnkFrame.RightClickMenu_mode == "bar") then
  -- right click on a slot
  bar = TFuBnkFrame.RightClickMenu_opts[TFuBag.I_BAR];

  -- Level 2: the per-category Layout column submenus (the only submenus in this menu).
  if (level == 2) then
    TFuBag:BarLayoutSubmenu(TFuBnkFrame, bar, level, UIDROPDOWNMENU_MENU_VALUE);
    return;
  end

  info = { ["text"] = string.format(L["|c%sBar |r|c%s%s|r"],TFuBag.C_INST,TFuBag.C_BAR,bar), ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  info = { ["disabled"] = 1, ["notCheckable"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  -- "Move" only completes via a left-click on a numbered bar button (classic edit
  -- mode only); offer it only there, else it is a dead entry in view / Manual Layout.
  if (TFuBnkFrame.edit_mode == 1) then
    for key, value in pairs(TFuBnkFrame.BC_LIST[bar]) do
      info = {
      ["text"] = string.format(L["Move: |c%s%s|r"],TFuBag.C_CAT,value);
      ["value"] = value;
      ["func"] = function(self)
    local this = self or _G.this
    TFuBnkFrame.edit_selected = (this.value);
    TFuBnkFrame.edit_hilight = (this.value);
    TFuBnkFrame:UpdateWindow();
      end
      };
      UIDropDownMenu_AddButton(info, level);
    end

    info = { ["disabled"] = 1, ["notCheckable"] = 1 };
    UIDropDownMenu_AddButton(info, level);
  end

  info = { ["text"] = L["Sort Mode:"], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  for key, value in pairs({
    [TFuBag.SORTBY_NONE] = L["No sort"],
    [TFuBag.SORTBY_NORM] = L["Sort by name"],
    [TFuBag.SORTBY_REV] = L["Sort last words first"]
    }) do

    if (TFuBag:GetGrp(TFuBnkFrame.cfg, TFuBag.G_BAR_SORT, bar) == key) then
      checked = 1;
    else
      checked = nil;
    end
    info = {
  ["text"] = value;
  ["value"] = { [TFuBag.I_BAR]=bar, ["sortby"]=key };
  ["func"] = function(self)
    local this = self or _G.this
    TFuBag:SetGrpDef(TFuBnkFrame.cfg, TFuBag.G_BAR_SORT, this.value[TFuBag.I_BAR], this.value["sortby"], 1);
    TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
  end,
  };
    TFuBag:AddMenuToggle(info, level, function() return TFuBag:GetGrp(TFuBnkFrame.cfg, TFuBag.G_BAR_SORT, bar) == key; end);
  end

  info = { ["disabled"] = 1, ["notCheckable"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  info = { ["text"] = L["Highlight new items:"], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  for key,value in pairs({
    [0] = L["Don't tag new items"],
    [1] = L["Tag new items"]
    }) do

    if (TFuBag:GetGrp(TFuBnkFrame.cfg, TFuBag.G_USE_NEW, bar) == key) then
      checked = 1;
    else
      checked = nil;
    end

    info = {
      ["text"] = value;
      ["value"] = { [TFuBag.I_BAR]=bar, ["value"]=key };
      ["func"] = function(self)
        local this = self or _G.this
        TFuBag:SetGrpDef(TFuBnkFrame.cfg, TFuBag.G_USE_NEW, this.value[TFuBag.I_BAR], this.value["value"], 1);
        TFuBnkFrame:UpdateWindow();
    end,
  };
    TFuBag:AddMenuToggle(info, level, function() return TFuBag:GetGrp(TFuBnkFrame.cfg, TFuBag.G_USE_NEW, bar) == key; end);
  end

  info = { ["disabled"] = 1, ["notCheckable"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  info = { ["text"] = L["Hide Bar:"], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  for key,value in pairs({
    [0] = L["Show items assigned to this bar"],
    [1] = L["Hide items assigned to this bar"]
    }) do

    if (TFuBag:GetGrp(TFuBnkFrame.cfg, TFuBag.G_BAR_HIDE, bar) == key) then
      checked = 1;
    else
      checked = nil;
    end

    info = {
      ["text"] = value;
      ["value"] = { [TFuBag.I_BAR]=bar, ["value"]=key };
      ["func"] = function(self)
        local this = self or _G.this
        TFuBag:SetGrpDef(TFuBnkFrame.cfg, TFuBag.G_BAR_HIDE, this.value[TFuBag.I_BAR], this.value["value"], 1);
        TFuBnkFrame:UpdateWindow();
    end,
  };
    TFuBag:AddMenuToggle(info, level, function() return TFuBag:GetGrp(TFuBnkFrame.cfg, TFuBag.G_BAR_HIDE, bar) == key; end);
  end

  info = { ["disabled"] = 1, ["notCheckable"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  info = { ["text"] = L["Color:"], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  info = TFuBag:MakeColorPickerInfo(TFuBnkFrame.cfg, "bkgr_", bar,
    string.format(L["Background Color for Bar %d"],bar), function () TFuBag:RecolorWindow(TFuBnkFrame) end);
  UIDropDownMenu_AddButton(info, level);

  info = TFuBag:MakeColorPickerInfo(TFuBnkFrame.cfg, "brdr_", bar,
    string.format(L["Border Color for Bar %d"],bar), function () TFuBag:RecolorWindow(TFuBnkFrame) end);
  UIDropDownMenu_AddButton(info, level);

  -- Per-category Layout overrides (columns / solo full-width).
  TFuBag:BarLayoutMenu(TFuBnkFrame, bar, level);

  info = { ["disabled"] = 1, ["notCheckable"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  info = {
    ["text"] = L["Print contents to chat"],
    ["func"] = function() CloseDropDownMenus(); TFuBag:PrintBarContents(TFuBnkFrame, bar); end,
    };
  UIDropDownMenu_AddButton(info, level);

  -- Hide the faint stock check "circle" on every non-toggle row so the menu shows one
  -- indicator style (our square box on toggles, nothing elsewhere).
  TFuBag:HideMenuChecksExceptToggles(level);

  -------------------------------------------------------------------------------------------------
  ------------------------ MAIN WINDOW CONTEXT MENU -----------------------------------------------
  -------------------------------------------------------------------------------------------------
  elseif (TFuBnkFrame.RightClickMenu_mode == "mainwindow") then
  if (level == 1) then

    info = { ["text"] = string.format(L["TBag v%s"],TFuBag.VERSION), ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    if (TFuBnkFrame.atbank == 0) then
      info = { ["disabled"] = 1, ["notCheckable"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      TFuBag:AddSubmenuParent({
        ["text"] = L["Select Character"],
        ["value"] = { ["opt"]="select_character" },
        }, level);
    end

    info = { ["disabled"] = 1, ["notCheckable"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    -- Toggle stack: flush-left text, an enabled toggle gets a right-column check.
    -- Highlight New Items sits at the top of the stack, above Edit Mode.
    info = {
  ["value"] = nil,
  ["func"] = TFuBnkFrame.Button_HighlightToggle_OnClick
  };
    if (TFuBag.SrchText) then
      -- With a search active this row becomes a plain "Clear Search" action.
      info["text"] = L["Clear Search"];
      info["notCheckable"] = 1;
      UIDropDownMenu_AddButton(info, level);
    else
      info["text"] = L["Highlight New Items"];
      TFuBag:AddMenuToggle(info, level, function() return TFuBnkFrame.hilight_new == 1; end);
    end

    -- Under Legacy Edit this is the classic edit_mode toggle; otherwise it toggles the
    -- Manual Layout MODE on/off (the gear button handles enter/exit edit). Mirrors Inv.
    info = {
  ["text"] = L["Edit Mode"],
  ["value"] = nil,
  ["func"] = function()
    local c = TFuBnkFrame.cfg;
    if (c["legacy_edit"] == 1) then
      TFuBnkFrame.Button_ChangeEditMode_OnClick();
    else
      c["manual_layout"] = (c["manual_layout"] == 1) and 0 or 1;
      if (c["manual_layout"] ~= 1) then TFuBnkFrame.ml_edit = 0; end  -- leaving: lock (respect Free Placement choice)
      TFuBnkFrame.force_relayout = true;
      TFuBnkFrame:UpdateWindow(TFuBag.REQ_NONE);
    end
  end
  };
    TFuBag:AddMenuToggle(info, level, function()
      return ((TFuBnkFrame.cfg["legacy_edit"] == 1 and TFuBnkFrame.edit_mode == 1)
        or (TFuBnkFrame.cfg["legacy_edit"] ~= 1 and TFuBnkFrame.cfg["manual_layout"] == 1));
      end);

    info = {
  ["text"] = L["Lock window"],
  ["value"] = nil,
  ["func"] = TFuBnkFrame.Button_MoveLockToggle_OnClick
  };
    TFuBag:AddMenuToggle(info, level, function() return TFuBnkFrame.cfg["moveLock"] == 0; end);


    info = { ["disabled"] = 1, ["notCheckable"] = 1 };
    UIDropDownMenu_AddButton(info, level);

  info = {
  ["text"] = L["Reload and Sort"],
  ["value"] = nil,
  ["func"] = TFuBnkFrame.Button_Reload_OnClick
  };
  UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = TFuBnkFrame:GetDepositButtonLabel(),
  ["value"] = nil,
  ["func"] = TFuBnkFrame.Button_DepositReagent_OnClick
  };
  UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = L["Reset NEW tag"],
  ["value"] = nil,
  ["func"] = function()
    local bag, slot, index;

    for index, bag in ipairs(TFuBnkFrame.bags) do
      if (TFuBnkFrame.cfg["show_Bag"..bag] == 1) then
        -- A cached/remote tab id in self.bags may have no item-cache entry yet
        -- (snapshot tab never populated, freshly-purchased tab); guard the per-bag
        -- table so table.getn(nil) can't error here. Mirrors UpdateWindowBody's guard.
        local pbag = TFuBnkItm[TFuBnkFrame.playerid] and TFuBnkItm[TFuBnkFrame.playerid][bag];
        if (pbag and table.getn(pbag) > 0) then
          for slot = 1, table.getn(pbag) do
            TFuBag:ResetNew(pbag[slot]);
          end
        end
      end
    end

    TFuBnkFrame:UpdateWindow();
  end
  };
    UIDropDownMenu_AddButton(info, level);

  info = { ["disabled"] = 1, ["notCheckable"] = 1 };
  UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = L["Options"],
  ["value"] = nil,
  ["func"] = function()
    -- Modern options window, opened to General -> Bank tab. The legacy panel (with the
    -- rule editor) stays reachable via /tbnk config.
    TFuBag.ModernOpt:OpenTo("general", "bank");
  end
  };
    UIDropDownMenu_AddButton(info, level);

    info = { ["disabled"] = 1, ["notCheckable"] = 1 };
    UIDropDownMenu_AddButton(info, level);


    TFuBag:AddSubmenuParent({
      ["text"] = L["Set Size"],
      ["value"] = { ["opt"]="set_scale" },
      }, level);

      info = { ["disabled"] = 1, ["notCheckable"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      TFuBag:AddSubmenuParent({
        ["text"] = L["Set Colors"],
        ["value"] = { ["opt"]="set_colors" },
        }, level);

      info = { ["disabled"] = 1, ["notCheckable"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      TFuBag:AddSubmenuParent({
        ["text"] = L["Anchor"],
        ["value"] = { ["opt"]="anchor" },
        }, level);

      info = { ["disabled"] = 1, ["notCheckable"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      TFuBag:AddSubmenuParent({
        ["text"] = L["Hide"],
        ["value"] = { ["opt"]="hide_frames" },
        }, level);

      info = { ["disabled"] = 1, ["notCheckable"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      -- Single indicator style: hide the stock check "circle" on every non-toggle row.
      TFuBag:HideMenuChecksExceptToggles(level);

    elseif (level == 2) then
      if (UIDROPDOWNMENU_MENU_VALUE ~= nil) then
        if (UIDROPDOWNMENU_MENU_VALUE["opt"] == "set_scale") then
          for _, value in ipairs(TFuBag.A_BUTTONSIZE) do
            local sz = value;
            info = {
              ["text"] = value.."x"..value;
              ["value"] = value;
              ["func"] = function(self)
                local this = self or _G.this
                if ( (type(this.value) == "number") and (this.value >= TFuBag.N_BUTTON_MIN) ) then
                    TFuBnkFrame.cfg["frameButtonSize"], TFuBnkFrame.cfg["count_font"],
                      TFuBnkFrame.cfg["count_font_x"], TFuBnkFrame.cfg["count_font_y"],
                      TFuBnkFrame.cfg["scale"] = TFuBag:NicePlacement(this.value);
                  TFuBnkFrame:CalcButtonSize(TFuBnkFrame.cfg["frameButtonSize"], TFuBnkFrame.cfg["framePad"]);
                  TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
                end
              end
            };
            TFuBag:AddMenuToggle(info, level, function()
              local d = tonumber(TFuBnkFrame.cfg["frameButtonSize"]*TFuBnkFrame.cfg["scale"] - sz);
              return (d ~= nil and d < 1.0 and d > -1.0);
            end);
          end
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "set_colors") then
          TFuBag:MakeColorMenu(TFuBnkFrame.cfg, function () TFuBag:RecolorWindow(TFuBnkFrame) end, level, TFuBnkFrame.bags);
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "anchor") then
          local function anchorRow(text, vert, horiz)
            TFuBag:AddMenuToggle({
              ["text"] = text,
              ["func"] = function() TFuBag:SetFrameAnchor(TFuBnkFrame, TFuBnkFrame.cfg, vert, horiz) end,
              }, level, function()
                return TFuBnkFrame.cfg["frameXRelativeTo"] == horiz
                   and TFuBnkFrame.cfg["frameYRelativeTo"] == vert;
              end);
          end
          anchorRow(L["TOPLEFT"],     "TOP",    "LEFT");
          anchorRow(L["TOPRIGHT"],    "TOP",    "RIGHT");
          anchorRow(L["BOTTOMLEFT"],  "BOTTOM", "LEFT");
          anchorRow(L["BOTTOMRIGHT"], "BOTTOM", "RIGHT");
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "hide_frames") then
          -- Hide toggles, square-box keep-open style (checked when show_* == 0 == hidden).
          local function hideToggle(text, toggleFunc, cfgKey)
            TFuBag:AddMenuToggle({ ["text"] = text, ["func"] = function() toggleFunc(TFuBnkFrame) end }, level,
              function() return TFuBnkFrame.cfg[cfgKey] == 0; end);
          end
          hideToggle(L["Hide Player Dropdown"],        TFuBnkFrame.Toggle_UserDropdown,        "show_userdropdown");
          hideToggle(L["Hide Highlight Button"],       TFuBnkFrame.Toggle_HighlightButton,     "show_hilightbutton");
          hideToggle(L["Hide Edit Button"],            TFuBnkFrame.Toggle_EditButton,          "show_editbutton");
          hideToggle(L["Hide Re-sort Button"],         TFuBnkFrame.Toggle_ReloadButton,        "show_reloadbutton");
          hideToggle(L["Hide Filter Button"],          TFuBnkFrame.Toggle_Filter,              "show_filterbutton");
          hideToggle(L["Hide Reagent Deposit Button"], TFuBnkFrame.Toggle_DepositReagentButton,"show_depositbutton");
          hideToggle(L["Hide Lock Button"],            TFuBnkFrame.Toggle_LockButton,          "show_lockbutton");
          hideToggle(L["Hide Close Button"],           TFuBnkFrame.Toggle_CloseButton,         "show_closebutton");
          hideToggle(L["Hide Search Box"],             TFuBnkFrame.Toggle_SearchBox,           "show_searchbox");
          hideToggle(L["Hide Total"],                  TFuBnkFrame.Toggle_Total,               "show_total");
          hideToggle(L["Hide Bag Buttons"],            TFuBnkFrame.Toggle_BagSlotButtons,      "show_bagbuttons");
          hideToggle(L["Hide Tokens"],                 TFuBnkFrame.Toggle_Token,               "show_tokens");
          hideToggle(L["Hide Money"],                  TFuBnkFrame.Toggle_Money,               "show_money");
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "select_character") then
          Bank.UserDropdown_Initialize(self, level);
        end
      end
    end
  end
  TFuBag:FixMenuFrameLevels()
end


-- Main "right click menu"
function Bank.RightClickMenu_OnLoad(self)
  UIDropDownMenu_Initialize(self, Bank.RightClickMenu_populate, "MENU");
end

Bank.WindowIsUpdating = 0;

-- Exception-safe reentrancy guard -- see Inv:UpdateWindow. A Lua error in the body
-- (e.g. a transient nil during a tab-set / bank-type transition) must not skip the
-- `WindowIsUpdating = 0` reset and wedge the bank window until /reload.
function Bank:UpdateWindow(resort_req)
  TFuBag:PrintDEBUG("Bank:UpdateWindow(): WindowIsUpdating="..Bank.WindowIsUpdating);
  if (Bank.WindowIsUpdating == 1) then
    return;
  end
  Bank.WindowIsUpdating = 1;
  local ok, err = pcall(Bank.UpdateWindowBody, self, resort_req);
  Bank.WindowIsUpdating = 0;
  if (not ok) then geterrorhandler()(err); end
end

function Bank:UpdateWindowBody(resort_req)
  local frame = TFuBnkFrame;
  local barnum;
  local cur_y;

  if ( not frame:IsVisible() ) then
    return;
  end

  -- Set the overall scale
  self:SetScale(self.cfg["scale"]);

  if (resort_req == nil) then resort_req = TFuBag.REQ_NONE; end

  -- Character-select dropdown: show whenever enabled (parity with the inventory window)
  -- so other characters' banks can be browsed from cache -- including while standing at
  -- your own banker. Live-only controls stay gated on atbank elsewhere.
  if (self.cfg["show_userdropdown"] == 0) then
    TFuBnk_UserDropdown:Hide();
  else
    TFuBnk_UserDropdown:Show();
  end

  -- SORTING

  -- Consume a message from updated craft info
  if (TFuBagCfg["trades_changed"] == 1) then
    resort_req = TFuBag.REQ_MUST;
  end
  TFuBagCfg["trades_changed"] = 0;

  -- See Inv:UpdateWindow: full recat only when categorization inputs changed.
  local force_full = (resort_req >= TFuBag.REQ_MUST)

  -- Setup stackarr and comparr
  local stackarr = TFuBag:CreateStackArr();
  local comparr = TFuBag:CreateCompArr();

  local cache_req = TFuBag:UpdateItmCache(self.cfg, self.playerid, TFuBnkItm[self.playerid], self.bags, stackarr, comparr, self.atbank);
  if resort_req == TFuBag.REQ_PART then
    resort_req = resort_req + self.CACHE_REQ
  end
  resort_req = resort_req + cache_req;

  -- Consume a message for bag stacking
  if (self.cfg["stack_once"] == 1) then
    if (self.playerid == TFuBag.PLAYERID) then
      if TFuBag:Stack(TFuBag.STACK_BNK,TFuBnkItm[self.playerid], stackarr, comparr) then
        self.cfg["stack_once"] = 0;
      end
    end
  end

  if (resort_req >= TFuBag.REQ_MUST) then
    if (force_full) then TFuBag:BumpCatGen() end
    -- The deferred-resort debt is paid here; clear it so a one-shot CACHE_REQ = REQ_MUST
    -- (e.g. set by RebuildTabList when the tab set changes) fires exactly once and does
    -- not stick high and re-sort on every later open. (Mirrors Inv:UpdateWindow.)
    self.CACHE_REQ = TFuBag.REQ_NONE
    self.BARITM = TFuBag:SortItmCache(self.cfg,
      self.playerid, TFuBnkItm[self.playerid], self.BARITM, self.bags);
    TFuBag:LayoutWindow(self)
    self.sortGen = TFuBag.catGen   -- mark categorization current (OnShow dirty check)
  elseif (self.force_resort) then
    -- Item-filter toggle: re-apply PassesItemFilter via SortItmCache and relayout,
    -- but WITHOUT a catGen bump (the filter reads cached fields, so the costly
    -- per-item tooltip recat is unnecessary -- same reasoning as force_relayout
    -- below, but the filter changes which items are placed, so a resort is needed).
    self.CACHE_REQ = TFuBag.REQ_NONE
    self.BARITM = TFuBag:SortItmCache(self.cfg,
      self.playerid, TFuBnkItm[self.playerid], self.BARITM, self.bags);
    TFuBag:LayoutWindow(self)
    self.sortGen = TFuBag.catGen
  elseif (self.force_relayout) then
    -- Relayout without resort: edit-mode toggle changes layout (bar buttons, shared
    -- height) but NOT categorization, so skip the costly SortItmCache (per-item
    -- tooltip scan) that made toggling edit mode lag on a large bank.
    TFuBag:LayoutWindow(self)
  elseif cache_req > self.CACHE_REQ then
    self.CACHE_REQ = cache_req
  end
  self.force_relayout = nil
  self.force_resort = nil

  -- Relink the button map. Use {} (never nil) for empty slots: a nil value drops the
  -- key from self.BUTTONS, so UpdateButtonHighlights' pairs() loop never visits that
  -- button and can't clear a stale spotlight left over from an item that moved away
  -- (the glow "stacking" seen when moving items via Blizzard's bank window).
  for _,bag in ipairs(self.bags) do
    for slot = 1, TFuBag:GetBagMaxItems(bag) do
      local itm = TFuBnkItm[self.playerid][bag] and TFuBnkItm[self.playerid][bag][slot]
      TFuBag.BUTTONS[TFuBag:GetBagItemButtonName(bag, slot)] = itm or {}
    end
  end

  -- BAGS, to get bag sizes below
  TFuBnkFrame:UpdateBagGfx();

  -- Update all the buttons
  for _, bag in ipairs(self.bags) do
    local size = TFuBag:GetPlayerBagCfg(self.playerid, bag, TFuBag.I_BAGSIZE);
    if (not size) then size = 0; end
    -- 12.0 bank tabs always show in Stage 1 (per-tab selector buttons are Stage 2);
    -- guard GetBagFrame, which is nil for tabs without a static selector button.
    local bagframe = TFuBag:GetBagFrame(bag)
    if (not TFuBag:IsBankTab(bag) and self.cfg["show_Bag"..bag] ~= 1
        and bagframe and not bagframe:GetChecked()) then
      size = 0
    end
    for slot = 1, size do
      TFuBag.ItemButton.Update(_G[TFuBag:GetBagItemButtonName(bag, slot)])
    end
    for slot = size+1, TFuBag:GetBagMaxItems(bag) do
      _G[TFuBag:GetBagItemButtonName(bag, slot)]:Hide();
    end
  end

  -- MONEY
  if (self.cfg["show_money"] == 1) then
    local ACCT = Enum.BankType and Enum.BankType.Account
    if (self.playerid == TFuBag.PLAYERID and self.bankType == ACCT and self.atbank == 1) then
      -- Warband view of the live player: show the WARBAND deposited balance, not
      -- character gold. MoneyTypeInfo["ACCOUNT"].UpdateFunc returns
      -- C_Bank.FetchDepositedMoney(Enum.BankType.Account). MoneyFrame_SetType does
      -- not run the frame's OnLoad, so the type switch does not by itself register
      -- ACCOUNT_MONEY; the balance stays current because MoneyFrame_UpdateMoney
      -- populates it here and UpdateWindow re-runs on the bank money events.
      MoneyFrame_SetType(TFuBnkFrame_MoneyFrame, "ACCOUNT")
      MoneyFrame_UpdateMoney(TFuBnkFrame_MoneyFrame)
    else
      local type = "STATIC"
      if (self.playerid == TFuBag.PLAYERID) then
        type = "PLAYER"
      end
      MoneyFrame_SetType(TFuBnkFrame_MoneyFrame,type)
      MoneyFrame_Update("TFuBnkFrame_MoneyFrame", TFuBag:GetMoney(self.playerid));
    end
  end

  frame:UpdateMoneyControls();
  frame:UpdateDepositButton();

  -- Don't snap-anchor while the user is mid-drag (see TInv.lua for rationale).
  if (not self.isMoving) then
    frame:ClearAllPoints();
    frame:SetPoint(self.cfg["frameYRelativeTo"]..self.cfg["frameXRelativeTo"],
      "UIParent", "BOTTOMLEFT",
      self.cfg["frame"..self.cfg["frameXRelativeTo"]] / frame:GetScale(),
      self.cfg["frame"..self.cfg["frameYRelativeTo"]] / frame:GetScale());
  end

  TFuBag:ColorFrame(self.cfg, frame, TFuBag.MAIN_BAR);

  if (self.edit_mode == 1) then
    TFuBnkFrame_ColumnsAdd:Show();
    TFuBnkFrame_ColumnsDel:Show();
  else
    TFuBnkFrame_ColumnsAdd:Hide();
    TFuBnkFrame_ColumnsDel:Hide();
  end

  -- Edit/Manual-Layout toggle button: green glow + full alpha when active, faded when off
  -- (mirrors the inventory gear so the bank shows the same active-state highlight).
  local mlbtn = TFuBnk_Button_ChangeEditMode;
  if (mlbtn) then
    if (not mlbtn.MLGlow) then
      mlbtn.MLGlow = mlbtn:CreateTexture(nil, "OVERLAY");
      mlbtn.MLGlow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border");
      mlbtn.MLGlow:SetBlendMode("ADD");
      mlbtn.MLGlow:SetVertexColor(0, 1, 0);  -- green
      mlbtn.MLGlow:SetPoint("CENTER", mlbtn, "CENTER", 0, 0);
      local w, h = mlbtn:GetSize();
      mlbtn.MLGlow:SetSize((w or 20) * 1.7, (h or 20) * 1.7);
    end
    -- Glow = gear in its ACTIVE/editing state (mirror of Inv): classic edit_mode under
    -- Legacy Edit, else the Manual Layout edit/unlock (ml_edit). Manual layout being
    -- active is persistent (menu/options checkbox), not shown by the glow.
    local edit_active;
    if (self.cfg["legacy_edit"] == 1) then
      edit_active = (self.edit_mode == 1);
    else
      edit_active = (self.ml_edit == 1);
    end
    if (edit_active) then
      mlbtn.MLGlow:Show();
      mlbtn:SetAlpha(1.0);
    else
      mlbtn.MLGlow:Hide();
      mlbtn:SetAlpha(0.4);  -- faded when off
    end
  end

  TFuBnkFrame:SetButton_Anchors();

  -- Refresh the per-item spotlight glows against the just-relinked button->item map.
  -- Without this, moving items (e.g. via Blizzard's bank window -> BAG_UPDATE ->
  -- UpdateWindow) re-sorts the buttons but leaves stale highlight textures shown on
  -- their old buttons, so the glow appeared to "stack" until a tab click finally
  -- recomputed it. UpdateButtonHighlights is light (show/hide/tint only, no rescan).
  TFuBag:UpdateButtonHighlights();
  TFuBag:UpdateFreeSlotsCell(TFuBnkFrame);
end


-- Bank:SetReplaceBank removed for the 12.0 rewrite: hijacking Blizzard's BankFrame
-- (Hide + steal its events) risks taint in 12.0 (managed UIPanel/CallbackRegistry).
-- Syndicator and Baganator never touch BankFrame; we let it open normally.


function Bank.UserDropdown_OnLoad(self)
  -- Initialize ONCE -- see Inv.UserDropdown_OnLoad: re-initializing on each OnShow hides
  -- every DropDownList frame, closing an open right-click menu when "Hide Player Dropdown"
  -- was toggled back on.
  if (not self.tbagInitialized) then
    UIDropDownMenu_Initialize(self, Bank.UserDropdown_Initialize);
    self.tbagInitialized = true;
  end
  UIDropDownMenu_SetSelectedValue(self, TFuBnkFrame.playerid);
  self.tooltip = L["You are viewing the selected player's bank."];
  UIDropDownMenu_SetWidth(self, TFuBag.USERDD_WIDTH)
  -- UIDropDownMenu_SetWidth actually adds 50 to our width, we really only want
  -- 25 to avoid the control running into our buttons on the right.
  self:SetWidth(TFuBag.USERDD_WIDTH + 25);
--  OptionsFrame_EnableDropDown(self);
end

function Bank.UserDropdown_Initialize(self, level)
  TFuBag:UserDropdown_Init(Bank.UserDropdown_OnClick,
    TFuBnkItm, TFuBnkFrame.playerid, TFuBag.REALM, level);
end

function Bank.UserDropdown_OnClick(self)
  local this = self or _G.this
  UIDropDownMenu_SetSelectedValue(TFuBnk_UserDropdown, this.value);
  if ( this.value ) then
    TFuBnkFrame:SetPlayer(this.value);
  end
  if ( not TFuBnkFrame.playerid ) then
    TFuBag:PrintDEBUG("UserDropdown_OnClick Failed");
    return;
  end
  TFuBag:PrintDEBUG("Selected Player "..TFuBnkFrame.playerid);
  -- Switching characters: rebuild the tab layout for the newly selected player from
  -- cache. RebuildTabList -> RefreshLiveFlag recomputes atbank (live only when the
  -- selection is our own character AND we are physically at a banker).
  TFuBnkFrame:RebuildTabList();
  TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
end
