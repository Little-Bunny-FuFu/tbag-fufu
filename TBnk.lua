-- $Id$

local _G = getfenv(0)
local TFuBag = _G.TFuBag
TFuBag.Bank = {}
local Bank = TFuBag.Bank

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

  self.cfg = TFuBagCfg["Bnk"]
  local cfg = self.cfg
  self.atbank = 0

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
-- BankFrame hijack -> no taint. Run on BANKFRAME_OPENED + BANK_TABS_CHANGED + switch.
function Bank:RebuildTabList()
  local prevBags = self.bags or {}
  local ids = {}
  local data = {}
  local available = {}

  local CHAR = Enum.BankType and Enum.BankType.Character
  local ACCT = Enum.BankType and Enum.BankType.Account

  -- Purchased tabs per type (nil = none purchased yet -- still selectable if viewable).
  local charTabs = FetchTabsFor(CHAR)
  local warTabs = nil
  local warViewable = false
  if (TFuBag.BANK_INCLUDE_WARBAND and ACCT ~= nil) then
    local locked = C_Bank and C_Bank.FetchBankLockedReason
      and C_Bank.FetchBankLockedReason(ACCT)
    if (locked == nil) then
      warTabs = FetchTabsFor(ACCT)
      warViewable = IsBankViewable(ACCT, warTabs)
    end
  end
  local tabsByType = {}
  if (CHAR ~= nil) then tabsByType[CHAR] = charTabs; end
  if (ACCT ~= nil) then tabsByType[ACCT] = warTabs; end

  -- A type is SELECTABLE (shown + clickable) if viewable, even with zero tabs -- so an
  -- empty Character bank is reachable to buy a first tab. Order: Character, Warband.
  if (IsBankViewable(CHAR, charTabs)) then available[#available + 1] = CHAR; end
  if (warViewable) then available[#available + 1] = ACCT; end

  local function selectable(t)
    if (t == nil) then return false; end
    for _, a in ipairs(available) do if (a == t) then return true; end end
    return false
  end

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
    if (not _G[fname]) then
      local f = CreateFrame("Frame", fname, parent, "TFuBagainerFrameTemplate")
      f:SetID(bag)
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
local TYPEBTN_W = 74
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
  -- Start the tab row past the free-slots cell that overlays the Total: the square cell
  -- overhangs the Total ~4.5px each side, +~4px gap (matches the Warband->tab gap).
  strip:SetPoint("BOTTOMLEFT", TFuBnkFrame_Total, "BOTTOMRIGHT", 9, 0)
  TFuBnkFrame.TabStrip = strip

  -- Character / Warband view switch. Keep the CharTabButton/WarbandTabButton field
  -- names (MainFrame:OnHide and /tbnk reference them); just reparent + re-anchor.
  local cb = CreateFrame("Button", "TFuBnkFrame_CharTabButton", strip, "UIPanelButtonTemplate")
  cb:SetSize(TYPEBTN_W, TABBTN_SIZE)
  cb:SetText(L["Character"])
  cb:SetPoint("LEFT", strip, "LEFT", 0, 0)
  cb:SetScript("OnClick", function() TFuBnkFrame:SetBankType(Enum.BankType.Character); end)
  TFuBnkFrame.CharTabButton = cb

  local wb = CreateFrame("Button", "TFuBnkFrame_WarbandTabButton", strip, "UIPanelButtonTemplate")
  wb:SetSize(TYPEBTN_W, TABBTN_SIZE)
  wb:SetText(L["Warband"])
  wb:SetPoint("LEFT", cb, "RIGHT", TABBTN_GAP, 0)
  wb:SetScript("OnClick", function() TFuBnkFrame:SetBankType(Enum.BankType.Account); end)
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
  local dep = CreateFrame("Button", "TFuBnkFrame_MoneyDepositButton", strip, "UIPanelButtonTemplate")
  dep:SetSize(TYPEBTN_W, TABBTN_SIZE)
  dep:SetText(BANK_DEPOSIT_MONEY_BUTTON_LABEL or L["Deposit"])
  dep:SetScript("OnClick", function()
    StaticPopup_Hide("BANK_MONEY_WITHDRAW")
    if (StaticPopup_Visible("BANK_MONEY_DEPOSIT")) then
      StaticPopup_Hide("BANK_MONEY_DEPOSIT")
      return
    end
    StaticPopup_Show("BANK_MONEY_DEPOSIT", nil, nil, { bankType = Enum.BankType.Account })
  end)
  dep:Hide()
  TFuBnkFrame.MoneyDepositButton = dep

  local wdr = CreateFrame("Button", "TFuBnkFrame_MoneyWithdrawButton", strip, "UIPanelButtonTemplate")
  wdr:SetSize(TYPEBTN_W, TABBTN_SIZE)
  wdr:SetText(BANK_WITHDRAW_MONEY_BUTTON_LABEL or L["Withdraw"])
  wdr:SetScript("OnClick", function()
    StaticPopup_Hide("BANK_MONEY_DEPOSIT")
    if (StaticPopup_Visible("BANK_MONEY_WITHDRAW")) then
      StaticPopup_Hide("BANK_MONEY_WITHDRAW")
      return
    end
    StaticPopup_Show("BANK_MONEY_WITHDRAW", nil, nil, { bankType = Enum.BankType.Account })
  end)
  wdr:Hide()
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

  wdr:ClearAllPoints()
  wdr:SetPoint("RIGHT", TFuBnkFrame_MoneyFrame, "LEFT", -6, 0)
  dep:ClearAllPoints()
  dep:SetPoint("RIGHT", wdr, "LEFT", -4, 0)
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

-- The class-deposit flags Blizzard's own tab settings menu exposes as checkboxes
-- (BankFrame.xml:93-146 settingFlag KeyValues). Each row: { Enum field, L key }.
-- Built lazily so an absent Enum field (older client) is simply skipped.
local function BuildDepositFlagDefs()
  local F = Enum and Enum.BagSlotFlags
  if (not F) then return {} end
  local defs = {}
  local function add(field, label)
    if (F[field] ~= nil) then defs[#defs + 1] = { flag = F[field], label = label } end
  end
  add("ClassEquipment",       L["Assign Equipment"])
  add("ClassConsumables",     L["Assign Consumables"])
  add("ClassProfessionGoods", L["Assign Profession Goods"])
  add("ClassReagents",        L["Assign Reagents"])
  add("ClassJunk",            L["Assign Junk"])
  add("ClassQuestItems",      L["Assign Quest Items"])
  add("DisableAutoSort",      L["Ignore this tab when cleaning up bags"])
  return defs
end

-- Fetch the live BankTabData for one tab id within a bank type (taint-safe read).
local function FetchTabData(bankType, tabID)
  if (bankType == nil or tabID == nil) then return nil end
  if (not C_Bank or not C_Bank.FetchPurchasedBankTabData) then return nil end
  local ok, tabs = pcall(C_Bank.FetchPurchasedBankTabData, bankType)
  if (not ok or not tabs) then return nil end
  for _, t in ipairs(tabs) do
    if (t and t.ID == tabID) then return t end
  end
  return nil
end

-- Create the self-owned dialog once. All children are addon-created; no secure
-- object is referenced. Returns the dialog frame.
function Bank:CreateTabSettingsDialog()
  if (TFuBnkFrame.TabSettingsDialog) then return TFuBnkFrame.TabSettingsDialog end

  local d = CreateFrame("Frame", "TFuBnkFrame_TabSettingsDialog", TFuBnkFrame,
    "BackdropTemplate")
  d:SetSize(360, 470)
  d:SetPoint("CENTER", TFuBnkFrame, "CENTER", 0, 0)
  d:SetFrameStrata("DIALOG")
  d:EnableMouse(true)
  d:SetMovable(true)
  d:RegisterForDrag("LeftButton")
  d:SetScript("OnDragStart", function(f) f:StartMoving() end)
  d:SetScript("OnDragStop", function(f) f:StopMovingOrSizing() end)
  if (d.SetBackdrop) then
    d:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
      tile = true, tileSize = 32, edgeSize = 32,
      insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
  end

  local title = d:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", d, "TOP", 0, -16)
  title:SetText(L["Bank Tab Settings"])
  d.Title = title

  -- Current-icon preview.
  local iconBtn = CreateFrame("Button", nil, d)
  iconBtn:SetSize(40, 40)
  iconBtn:SetPoint("TOPLEFT", d, "TOPLEFT", 24, -48)
  local iconTex = iconBtn:CreateTexture(nil, "ARTWORK")
  iconTex:SetAllPoints()
  iconTex:SetTexture(TAB_FALLBACK_ICON)
  iconBtn.tex = iconTex
  local iconBorder = iconBtn:CreateTexture(nil, "OVERLAY")
  iconBorder:SetPoint("TOPLEFT", -2, 2)
  iconBorder:SetPoint("BOTTOMRIGHT", 2, -2)
  iconBorder:SetColorTexture(1, 1, 1, 0.25)
  d.IconPreview = iconBtn

  -- Name edit box.
  local nameLabel = d:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  nameLabel:SetPoint("TOPLEFT", iconBtn, "TOPRIGHT", 14, -2)
  nameLabel:SetText(L["Name"])
  local nameBox = CreateFrame("EditBox", "TFuBnkFrame_TabSettingsName", d, "InputBoxTemplate")
  nameBox:SetAutoFocus(false)
  nameBox:SetSize(220, 20)
  nameBox:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 4, -4)
  nameBox:SetMaxLetters(20)
  nameBox:SetScript("OnEscapePressed", function(b) b:ClearFocus() end)
  nameBox:SetScript("OnEnterPressed", function(b) b:ClearFocus() end)
  d.NameBox = nameBox

  -- Deposit-flag checkboxes.
  local flagsHeader = d:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  flagsHeader:SetPoint("TOPLEFT", iconBtn, "BOTTOMLEFT", 0, -10)
  flagsHeader:SetText(L["Auto-Deposit Settings"])
  d.flagChecks = {}
  local defs = BuildDepositFlagDefs()
  local anchor = flagsHeader
  for i, def in ipairs(defs) do
    local cb = CreateFrame("CheckButton", "TFuBnkFrame_TabSettingsFlag"..i, d,
      "UICheckButtonTemplate")
    cb:SetSize(22, 22)
    if (i == 1) then
      cb:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -6)
    else
      cb:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -2)
    end
    local lbl = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    lbl:SetPoint("LEFT", cb, "RIGHT", 2, 0)
    lbl:SetText(def.label)
    cb.settingFlag = def.flag
    d.flagChecks[i] = cb
    anchor = cb
  end

  -- Icon grid (self-owned, IconDataProvider-backed). A small paged grid; the user
  -- clicks an icon to select it for this tab. No secure data involved.
  local GRID_COLS, GRID_ROWS = 10, 4
  local CELL = 26
  local gridHeader = d:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  gridHeader:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -12)
  gridHeader:SetText(L["Choose an Icon"])
  d.IconGridButtons = {}
  local prevRow = nil
  for r = 1, GRID_ROWS do
    local prevCol = nil
    for c = 1, GRID_COLS do
      local idx = (r - 1) * GRID_COLS + c
      local b = CreateFrame("Button", nil, d)
      b:SetSize(CELL, CELL)
      if (c == 1) then
        if (r == 1) then
          b:SetPoint("TOPLEFT", gridHeader, "BOTTOMLEFT", 0, -6)
        else
          b:SetPoint("TOPLEFT", prevRow, "BOTTOMLEFT", 0, -2)
        end
        prevRow = b
      else
        b:SetPoint("LEFT", prevCol, "RIGHT", 2, 0)
      end
      local tex = b:CreateTexture(nil, "ARTWORK")
      tex:SetPoint("TOPLEFT", 1, -1)
      tex:SetPoint("BOTTOMRIGHT", -1, 1)
      b.tex = tex
      local sel = b:CreateTexture(nil, "OVERLAY")
      sel:SetAllPoints()
      sel:SetColorTexture(1, 0.82, 0, 0.5)
      sel:Hide()
      b.sel = sel
      local hl = b:CreateTexture(nil, "HIGHLIGHT")
      hl:SetAllPoints()
      hl:SetColorTexture(1, 1, 1, 0.2)
      b:SetScript("OnClick", function(self)
        local fileID = self.iconFileID
        if (fileID == nil) then return end
        TFuBnkFrame:TabSettings_SelectIcon(fileID)
      end)
      d.IconGridButtons[idx] = b
      prevCol = b
    end
  end

  -- Grid pager.
  local prevBtn = CreateFrame("Button", nil, d, "UIPanelButtonTemplate")
  prevBtn:SetSize(60, 20)
  prevBtn:SetText(L["Prev"])
  prevBtn:SetPoint("TOPLEFT", prevRow, "BOTTOMLEFT", 0, -8)
  prevBtn:SetScript("OnClick", function() TFuBnkFrame:TabSettings_ChangePage(-1) end)
  d.PrevPageButton = prevBtn

  local pageLabel = d:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  pageLabel:SetPoint("LEFT", prevBtn, "RIGHT", 8, 0)
  d.PageLabel = pageLabel

  local nextBtn = CreateFrame("Button", nil, d, "UIPanelButtonTemplate")
  nextBtn:SetSize(60, 20)
  nextBtn:SetText(L["Next"])
  nextBtn:SetPoint("LEFT", pageLabel, "RIGHT", 8, 0)
  nextBtn:SetScript("OnClick", function() TFuBnkFrame:TabSettings_ChangePage(1) end)
  d.NextPageButton = nextBtn

  -- OK / Cancel.
  local okBtn = CreateFrame("Button", nil, d, "UIPanelButtonTemplate")
  okBtn:SetSize(100, 22)
  okBtn:SetText(L["Okay"] or OKAY)
  okBtn:SetPoint("BOTTOMRIGHT", d, "BOTTOM", -4, 16)
  okBtn:SetScript("OnClick", function() TFuBnkFrame:TabSettings_Apply() end)
  d.OkButton = okBtn

  local cancelBtn = CreateFrame("Button", nil, d, "UIPanelButtonTemplate")
  cancelBtn:SetSize(100, 22)
  cancelBtn:SetText(L["Cancel"] or CANCEL)
  cancelBtn:SetPoint("BOTTOMLEFT", d, "BOTTOM", 4, 16)
  cancelBtn:SetScript("OnClick", function() d:Hide() end)
  d.CancelButton = cancelBtn

  d:SetScript("OnHide", function(f)
    if (f.iconProvider and f.iconProvider.Release) then
      f.iconProvider:Release()
      f.iconProvider = nil
    end
  end)

  d.GRID_COLS, d.GRID_ROWS = GRID_COLS, GRID_ROWS
  d:Hide()
  TFuBnkFrame.TabSettingsDialog = d
  return d
end

-- Selecting an icon in the grid: record the chosen fileID and update the preview +
-- selection highlight.
function Bank:TabSettings_SelectIcon(fileID)
  local d = TFuBnkFrame.TabSettingsDialog
  if (not d) then return end
  d.selectedIcon = fileID
  if (d.IconPreview and d.IconPreview.tex) then
    d.IconPreview.tex:SetTexture(fileID)
  end
  self:TabSettings_RefreshGridSelection()
end

-- Highlight the grid cell matching the current selection (if visible on this page).
function Bank:TabSettings_RefreshGridSelection()
  local d = TFuBnkFrame.TabSettingsDialog
  if (not d) then return end
  for _, b in ipairs(d.IconGridButtons) do
    if (b.sel) then
      if (d.selectedIcon ~= nil and b.iconFileID == d.selectedIcon) then
        b.sel:Show()
      else
        b.sel:Hide()
      end
    end
  end
end

-- Render one page of icons from the IconDataProvider into the grid.
function Bank:TabSettings_RenderGrid()
  local d = TFuBnkFrame.TabSettingsDialog
  if (not d or not d.iconProvider) then return end
  local perPage = d.GRID_COLS * d.GRID_ROWS
  local total = d.iconProvider:GetNumIcons() or 0
  local maxPage = math.max(0, math.floor((total - 1) / perPage))
  if (d.page == nil or d.page < 0) then d.page = 0 end
  if (d.page > maxPage) then d.page = maxPage end

  local base = d.page * perPage
  for i = 1, perPage do
    local b = d.IconGridButtons[i]
    local iconIndex = base + i
    if (iconIndex <= total) then
      local fileID = d.iconProvider:GetIconByIndex(iconIndex)
      b.iconFileID = fileID
      b.tex:SetTexture(fileID)
      b:Show()
    else
      b.iconFileID = nil
      b.tex:SetTexture(nil)
      b:Hide()
    end
  end

  if (d.PageLabel) then
    d.PageLabel:SetText((d.page + 1).." / "..(maxPage + 1))
  end
  if (d.PrevPageButton) then
    if (d.page > 0) then d.PrevPageButton:Enable() else d.PrevPageButton:Disable() end
  end
  if (d.NextPageButton) then
    if (d.page < maxPage) then d.NextPageButton:Enable() else d.NextPageButton:Disable() end
  end
  self:TabSettings_RefreshGridSelection()
end

function Bank:TabSettings_ChangePage(delta)
  local d = TFuBnkFrame.TabSettingsDialog
  if (not d) then return end
  d.page = (d.page or 0) + delta
  self:TabSettings_RenderGrid()
end

-- Right-click tab settings: open our own taint-safe dialog pre-filled from the tab's
-- live BankTabData, apply via the public C_Bank.UpdateBankTabSettings on OK.
function Bank:OpenTabSettings(bag)
  local bankType = (self.tabData and self.tabData[bag] and self.tabData[bag].bankType)
    or self.bankType
  local tabData = FetchTabData(bankType, bag)
  if (not tabData) then
    TFuBag:Print(L["Tab settings are unavailable for this tab."])
    return
  end
  if (not C_Bank or not C_Bank.UpdateBankTabSettings) then
    TFuBag:Print(L["Tab settings are unavailable on this client."])
    return
  end

  local d = self:CreateTabSettingsDialog()
  d.editBankType = bankType
  d.editTabID = bag

  d.NameBox:SetText(tabData.name or "")
  d.NameBox:SetCursorPosition(0)

  d.selectedIcon = tabData.icon
  if (d.IconPreview and d.IconPreview.tex) then
    d.IconPreview.tex:SetTexture(tabData.icon or TAB_FALLBACK_ICON)
  end

  local flags = tabData.depositFlags or 0
  d.origDepositFlags = flags
  for _, cb in ipairs(d.flagChecks or {}) do
    if (cb.settingFlag) then
      cb:SetChecked(FlagsUtil and FlagsUtil.IsSet(flags, cb.settingFlag) or false)
    end
  end

  -- (Re)build the icon provider and seed the page to the tab's current icon.
  if (d.iconProvider and d.iconProvider.Release) then d.iconProvider:Release() end
  d.iconProvider = nil
  if (IconDataProviderMixin and CreateAndInitFromMixin and IconDataProviderIconType) then
    local ok, provider = pcall(CreateAndInitFromMixin, IconDataProviderMixin,
      IconDataProviderIconType.Item, false)
    if (ok and provider) then d.iconProvider = provider end
  end
  d.page = 0
  if (d.iconProvider and tabData.icon) then
    local idx = d.iconProvider:GetIndexOfIcon(tabData.icon)
    if (idx and idx > 0) then
      d.page = math.floor((idx - 1) / (d.GRID_COLS * d.GRID_ROWS))
    end
  end
  self:TabSettings_RenderGrid()

  d:Show()
  d:Raise()
end

-- Assemble the settings from the dialog and apply via the public API, then close.
function Bank:TabSettings_Apply()
  local d = TFuBnkFrame.TabSettingsDialog
  if (not d) then return end
  local bankType, tabID = d.editBankType, d.editTabID
  if (bankType == nil or tabID == nil) then d:Hide(); return end

  local tabName = d.NameBox:GetText() or ""
  local tabIcon = d.selectedIcon or TAB_FALLBACK_ICON

  -- Preserve deposit-flag bits we do not expose (notably the expansion-filter
  -- ExpansionCurrent/Legacy bits that can be set via Blizzard's own bank UI): start
  -- from the tab's current mask, clear only the checkbox-managed bits, then OR the
  -- checked ones back in. Rebuilding from 0 would silently wipe those filters.
  local depositFlags = d.origDepositFlags or 0
  if (FlagsUtil) then
    for _, cb in ipairs(d.flagChecks or {}) do
      if (cb.settingFlag) then
        depositFlags = FlagsUtil.Combine(depositFlags, cb.settingFlag, false)
      end
    end
    for _, cb in ipairs(d.flagChecks or {}) do
      if (cb.settingFlag and cb:GetChecked()) then
        depositFlags = FlagsUtil.Combine(depositFlags, cb.settingFlag, true)
      end
    end
  end

  C_Bank.UpdateBankTabSettings(bankType, tabID, tabName, tabIcon, depositFlags)
  d:Hide()
  -- Refresh is also driven by BANK_TAB_SETTINGS_UPDATED, but rebuild immediately so
  -- the strip/tooltips reflect the new name/icon without waiting on the event.
  self:RebuildTabList()
  if (self.atbank == 1) then self:UpdateWindow(TFuBag.REQ_MUST) end
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
    if (hasChar and self.bankType ~= CHAR) then cb:Enable() else cb:Disable() end
  end
  local wb = TFuBnkFrame.WarbandTabButton
  if (wb) then
    if (hasWar and TFuBag.BANK_INCLUDE_WARBAND) then wb:Show() else wb:Hide() end
    if (hasWar and self.bankType ~= ACCT) then wb:Enable() else wb:Disable() end
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
  self:UpdateWindow(TFuBag.REQ_MUST)
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
      if (TFuBnkFrame.highlight_new == 1) then
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
  if (TFuBnkFrame.edit_mode == 0) then
    TFuBnkFrame.edit_mode = 1;
  else
    TFuBnkFrame.edit_mode = 0;
  end

  -- Relayout (not resort): edit-mode only changes the layout, not categorization.
  -- Forcing a resort here scanned every item's tooltip -> major lag on a big bank.
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

function Bank.SlotTargetButton_OnClick(self, button)
  local bar, tmp;

  if (TFuBnkFrame.edit_mode == 1) then
  for tmp in string.gmatch(self:GetName(), "TFuBnkFrame_SlotTarget_(%d+)") do
    bar = tonumber(tmp);
  end

  if ( (bar == nil) or (bar < 1) or (bar > TFuBag.BAR_MAX) ) then
    return;
  end

  if ( button == "LeftButton" ) then
    if (TFuBnkFrame.edit_selected ~= "") then
  -- we got a click, and we already had one selected.  let's move the items
  TFuBag:SetCatBar(TFuBnkFrame.cfg, TFuBnkFrame.edit_selected, bar, 1);

  TFuBnkFrame.edit_selected = "";
  TFuBnkFrame.edit_hilight = "";

  TFuBag:BuildBarClassList(TFuBnkFrame.BC_LIST, TFuBnkFrame.cfg);

    -- resort will force a window redraw as well
      TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
    end

  elseif ( button == "RightButton" ) then
    HideDropDownMenu(1);
    TFuBnkFrame.RightClickMenu_mode = "bar";
    TFuBnkFrame.RightClickMenu_opts = {
  [TFuBag.I_BAR] = bar
  };
    ToggleDropDownMenu(1, nil, TFuBnkFrame_RightClickMenu, self:GetName(), -50, 0);

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
    button = _G[button_name];
    if (button) then
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

function Bank:SetTopRightButton_Anchors()
  local buttons = {
    "TFuBnk_Button_Close",
    "TFuBnk_Button_MoveLockToggle",
  }
  local button_right = nil;

  for _,button_name in ipairs(buttons) do
    local button = _G[button_name];
    if (button) then
      if (button_right) then
        button:SetPoint("TOPRIGHT",button_right,"TOPLEFT",10,0);
      else
        button:SetPoint("TOPRIGHT",TFuBnkFrame,"TOPRIGHT",0,0);
      end
      if (button:IsVisible()) then
        button_right = button;
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

  for _,button_name in ipairs(buttons) do
    button = _G[button_name];
    if (button) then
      button:ClearAllPoints();
      if (button_left) then
        -- button following another button
        button:SetPoint("BOTTOMLEFT",button_left,"BOTTOMRIGHT",3,-1);
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
    button = _G[button_name]
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

function Bank:SetButton_Anchors()
  self:SetTopLeftButton_Anchors();
  self:SetTopRightButton_Anchors();
  self:SetBottomLeftButton_Anchors();
  self:SetBottomRightButton_Anchors();
  TFuBag:LayoutWindow(self)
end


function Bank.Toggle_CloseButton()
  if (TFuBnkFrame.cfg["show_closebutton"] == 1) then
    TFuBnkFrame.cfg["show_closebutton"] = 0;
    TFuBnk_Button_Close:Hide();
    TFuBnkFrame:SetButton_Anchors();
  else
    TFuBnkFrame.cfg["show_closebutton"] = 1;
    TFuBnk_Button_Close:Show();
    TFuBnkFrame:SetButton_Anchors();
  end
end

function Bank.Toggle_LockButton()
  if (TFuBnkFrame.cfg["show_lockbutton"] == 1) then
    TFuBnkFrame.cfg["show_lockbutton"] = 0;
    TFuBnk_Button_MoveLockToggle:Hide();
    TFuBnkFrame:SetButton_Anchors();
  else
    TFuBnkFrame.cfg["show_lockbutton"] = 1;
    TFuBnk_Button_MoveLockToggle:Show();
    TFuBnkFrame:SetButton_Anchors();
  end
end

function Bank.Toggle_HighlightButton()
  if (TFuBnkFrame.cfg["show_hilightbutton"] == 1) then
    TFuBnkFrame.cfg["show_hilightbutton"] = 0;
    TFuBnk_Button_HighlightToggle:Hide();
    TFuBnkFrame:SetButton_Anchors();
  else
    TFuBnkFrame.cfg["show_hilightbutton"] = 1;
    TFuBnk_Button_HighlightToggle:Show();
    TFuBnkFrame:SetButton_Anchors();
  end
end

function Bank.Toggle_EditButton()
  if (TFuBnkFrame.cfg["show_editbutton"] == 1) then
    TFuBnkFrame.cfg["show_editbutton"] = 0;
    TFuBnk_Button_ChangeEditMode:Hide();
    TFuBnkFrame:SetButton_Anchors();
  else
    TFuBnkFrame.cfg["show_editbutton"] = 1;
    TFuBnk_Button_ChangeEditMode:Show();
    TFuBnkFrame:SetButton_Anchors();
  end
end

function Bank.Toggle_ReloadButton()
  if (TFuBnkFrame.cfg["show_reloadbutton"] == 1) then
    TFuBnkFrame.cfg["show_reloadbutton"] = 0;
    TFuBnk_Button_Reload:Hide();
    TFuBnkFrame:SetButton_Anchors();
  else
    TFuBnkFrame.cfg["show_reloadbutton"] = 1;
    TFuBnk_Button_Reload:Show();
    TFuBnkFrame:SetButton_Anchors();
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

function Bank.Toggle_UserDropdown()
  if (TFuBnkFrame.cfg["show_userdropdown"] == 1) then
    TFuBnkFrame.cfg["show_userdropdown"] = 0;
    TFuBnk_UserDropdown:Hide();
    TFuBnkFrame:SetButton_Anchors();
  else
    TFuBnkFrame.cfg["show_userdropdown"] = 1;
    TFuBnk_UserDropdown:Show();
    TFuBnkFrame:SetButton_Anchors();
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

function Bank.Toggle_Token()
  if (TFuBnkFrame.cfg["show_tokens"] == 1) then
    TFuBnkFrame.cfg["show_tokens"] = 0;
    TFuBnkFrame_TokenFrame:Hide();
    TFuBnkFrame:SetButton_Anchors();
  else
    TFuBnkFrame.cfg["show_tokens"] = 1;
    TFuBnkFrame_TokenFrame:Show();
    TFuBnkFrame:SetButton_Anchors();
  end
end

function Bank.Toggle_BagSlotButtons()
  if (TFuBnkFrame.cfg["show_bagbuttons"] == 1) then
    TFuBnkFrame.cfg["show_bagbuttons"] = 0;
    TFuBnkFrameBag1:Hide();
    TFuBnkFrameBag2:Hide();
    TFuBnkFrameBag3:Hide();
    TFuBnkFrameBag4:Hide();
    TFuBnkFrameBag5:Hide();
    TFuBnkFrameBag6:Hide();
    TFuBnkFrameBag7:Hide();
    TFuBnkFrameBagBank:Hide();
    TFuBnkFrameBagReagent:Hide();
    TFuBnkFrame:SetButton_Anchors();
  else
    TFuBnkFrame.cfg["show_bagbuttons"] = 1;
    TFuBnkFrameBag1:Show();
    TFuBnkFrameBag2:Show();
    TFuBnkFrameBag3:Show();
    TFuBnkFrameBag4:Show();
    TFuBnkFrameBag5:Show();
    TFuBnkFrameBag6:Show();
    TFuBnkFrameBag7:Show();
    TFuBnkFrameBagBank:Show();
    TFuBnkFrameBagReagent:Show();
    TFuBnkFrame:SetButton_Anchors();
   end
end

function Bank.Toggle_Total()
  if (TFuBnkFrame.cfg["show_total"] == 1) then
    TFuBnkFrame.cfg["show_total"] = 0;
    TFuBnkFrame_Total:Hide();
    TFuBnkFrame:SetButton_Anchors();
  else
    TFuBnkFrame.cfg["show_total"] = 1;
    TFuBnkFrame_Total:Show();
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

    info = { ["text"] = itm[TFuBag.I_NAME], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);

    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = { ["text"] = string.format(L["Current Category: %s"],itm[TFuBag.I_CAT]), ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);

    info = { ["disabled"] = 1 };
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
  info = { ["disabled"] = 1 };
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

  info = { ["text"] = string.format(L["|c%sBar |r|c%s%s|r"],TFuBag.C_INST,TFuBag.C_BAR,bar), ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
  UIDropDownMenu_AddButton(info, level);

  info = { ["disabled"] = 1 };
  UIDropDownMenu_AddButton(info, level);

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

  info = { ["disabled"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  info = { ["text"] = L["Sort Mode:"], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
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
  ["checked"] = checked
  };
    UIDropDownMenu_AddButton(info, level);
  end

  info = { ["disabled"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  info = { ["text"] = L["Highlight new items:"], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
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
  ["checked"] = checked
  };
    UIDropDownMenu_AddButton(info, level);
  end

  info = { ["disabled"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  info = { ["text"] = L["Hide Bar:"], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
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
  ["checked"] = checked
  };
    UIDropDownMenu_AddButton(info, level);
  end

  info = { ["disabled"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  info = { ["text"] = L["Color:"], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
  UIDropDownMenu_AddButton(info, level);

  info = TFuBag:MakeColorPickerInfo(TFuBnkFrame.cfg, "bkgr_", bar,
    string.format(L["Background Color for Bar %d"],bar), function () TFuBag:RecolorWindow(TFuBnkFrame) end);
  UIDropDownMenu_AddButton(info, level);

  info = TFuBag:MakeColorPickerInfo(TFuBnkFrame.cfg, "brdr_", bar,
    string.format(L["Border Color for Bar %d"],bar), function () TFuBag:RecolorWindow(TFuBnkFrame) end);
  UIDropDownMenu_AddButton(info, level);

  -------------------------------------------------------------------------------------------------
  ------------------------ MAIN WINDOW CONTEXT MENU -----------------------------------------------
  -------------------------------------------------------------------------------------------------
  elseif (TFuBnkFrame.RightClickMenu_mode == "mainwindow") then
  if (level == 1) then

    info = { ["text"] = string.format(L["TBag v%s"],TFuBag.VERSION), ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);

    if (TFuBnkFrame.atbank == 0) then
      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Select Character"];
        ["value"] = { ["opt"]="select_character" },
        ["hasArrow"] = 1
        };
      UIDropDownMenu_AddButton(info, level);
    end

    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = L["Edit Mode"],
  ["value"] = nil,
  ["func"] = TFuBnkFrame.Button_ChangeEditMode_OnClick
  };
    if (TFuBnkFrame.edit_mode == 1) then
      info["checked"] = 1;
    end
    UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = L["Lock window"],
  ["value"] = nil,
  ["func"] = TFuBnkFrame.Button_MoveLockToggle_OnClick
  };
    if (TFuBnkFrame.cfg["moveLock"] == 0) then
  info["checked"] = 1;
    end
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

    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = {
  ["value"] = nil,
  ["func"] = TFuBnkFrame.Button_HighlightToggle_OnClick
  };
    if (TFuBag.SrchText) then
      info["text"] = L["Clear Search"];
    else
      info["text"] = L["Highlight New Items"];
      if (TFuBnkFrame.hilight_new == 1) then
        info["checked"] = 1;
      end
    end
    UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = L["Reset NEW tag"],
  ["value"] = nil,
  ["func"] = function()
    local bag, slot, index;

    for index, bag in ipairs(TFuBnkFrame.bags) do
      if (TFuBnkFrame.cfg["show_Bag"..bag] == 1) then
        if (table.getn(TFuBnkItm[TFuBnkFrame.playerid][bag]) > 0) then
          for slot = 1, table.getn(TFuBnkItm[TFuBnkFrame.playerid][bag]) do
            TFuBag:ResetNew(TFuBnkItm[TFuBnkFrame.playerid][bag][slot]);
          end
        end
      end
    end

    TFuBnkFrame:UpdateWindow();
  end
  };
    UIDropDownMenu_AddButton(info, level);

  info = { ["disabled"] = 1 };
  UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = L["Advanced Configuration"],
  ["value"] = nil,
  ["func"] = function()
    TFuBnk_OptsFrame:Show();
  end
  };
    UIDropDownMenu_AddButton(info, level);

    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);


    info = {
      ["text"] = L["Set Size"];
      ["value"] = { ["opt"]="set_scale" },
      ["hasArrow"] = 1
    };
    UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Set Colors"];
        ["value"] = { ["opt"]="set_colors" },
        ["hasArrow"] = 1
        };
      UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Anchor"];
        ["value"] = { ["opt"]="anchor" },
        ["hasArrow"] = 1
        };
      UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Hide"];
        ["value"] = { ["opt"]="hide_frames" },
        ["hasArrow"] = 1
        };
      UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);


    elseif (level == 2) then
      if (UIDROPDOWNMENU_MENU_VALUE ~= nil) then
        if (UIDROPDOWNMENU_MENU_VALUE["opt"] == "set_scale") then
          for _, value in ipairs(TFuBag.A_BUTTONSIZE) do
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
            if (tonumber(TFuBnkFrame.cfg["frameButtonSize"]*TFuBnkFrame.cfg["scale"] - value)
      < 1.0) and (tonumber(TFuBnkFrame.cfg["frameButtonSize"]*TFuBnkFrame.cfg["scale"] - value)
      > -1.0) then
              info["checked"] = 1;
            end
            UIDropDownMenu_AddButton(info, level);
          end
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "set_colors") then
          TFuBag:MakeColorMenu(TFuBnkFrame.cfg, function () TFuBag:RecolorWindow(TFuBnkFrame) end, level, TFuBnkFrame.bags);
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "anchor") then
          info = {
            ["text"] = L["TOPLEFT"];
            ["func"] = function ()
                         TFuBag:SetFrameAnchor (TFuBnkFrame,TFuBnkFrame.cfg,"TOP","LEFT")
                       end;
            };
          if (TFuBnkFrame.cfg["frameXRelativeTo"] == "LEFT" and
              TFuBnkFrame.cfg["frameYRelativeTo"] == "TOP") then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["TOPRIGHT"];
            ["func"] = function ()
                         TFuBag:SetFrameAnchor (TFuBnkFrame,TFuBnkFrame.cfg,"TOP","RIGHT")
                       end;
            };
          if (TFuBnkFrame.cfg["frameXRelativeTo"] == "RIGHT" and
              TFuBnkFrame.cfg["frameYRelativeTo"] == "TOP") then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["BOTTOMLEFT"];            ["func"] = function ()
                         TFuBag:SetFrameAnchor (TFuBnkFrame,TFuBnkFrame.cfg,"BOTTOM","LEFT")
                       end;
            };
          if (TFuBnkFrame.cfg["frameXRelativeTo"] == "LEFT" and
              TFuBnkFrame.cfg["frameYRelativeTo"] == "BOTTOM") then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["BOTTOMRIGHT"];
            ["func"] = function ()
                         TFuBag:SetFrameAnchor (TFuBnkFrame,TFuBnkFrame.cfg,"BOTTOM","RIGHT")
                       end;
            };
          if (TFuBnkFrame.cfg["frameXRelativeTo"] == "RIGHT" and
              TFuBnkFrame.cfg["frameYRelativeTo"] == "BOTTOM") then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "hide_frames") then
          info = {
            ["text"] = L["Hide Player Dropdown"];
            ["func"] = TFuBnkFrame.Toggle_UserDropdown;
            ["keepShownOnClick"] = 1;
            };
          if (TFuBnkFrame.cfg["show_userdropdown"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Highlight Button"];
            ["func"] = TFuBnkFrame.Toggle_HighlightButton;
            ["keepShownOnClick"] = 1;
            };
          if (TFuBnkFrame.cfg["show_hilightbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Edit Button"];
            ["func"] = TFuBnkFrame.Toggle_EditButton;
            ["keepShownOnClick"] = 1;
           };
          if (TFuBnkFrame.cfg["show_editbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Re-sort Button"];
            ["func"] = TFuBnkFrame.Toggle_ReloadButton;
            ["keepShownOnClick"] = 1;
            };
          if (TFuBnkFrame.cfg["show_reloadbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Reagent Deposit Button"];
            ["func"] = TFuBnkFrame.Toggle_DepositReagentButton;
            ["keepShownOnClick"] = 1;
            };
          if (TFuBnkFrame.cfg["show_depositbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Lock Button"];
            ["func"] = TFuBnkFrame.Toggle_LockButton;
            ["keepShownOnClick"] = 1;
            };
          if (TFuBnkFrame.cfg["show_lockbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Close Button"];
            ["func"] = TFuBnkFrame.Toggle_CloseButton;
            ["keepShownOnClick"] = 1;
            };
          if (TFuBnkFrame.cfg["show_closebutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Total"];
            ["func"] = TFuBnkFrame.Toggle_Total;
            ["keepShownOnClick"] = 1;
            };
          if (TFuBnkFrame.cfg["show_total"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Bag Buttons"];
            ["func"] = TFuBnkFrame.Toggle_BagSlotButtons;
            ["keepShownOnClick"] = 1;
            };
          if (TFuBnkFrame.cfg["show_bagbuttons"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Tokens"];
            ["func"] = TFuBnkFrame.Toggle_Token;
            ["keepShownOnClick"] = 1;
            };
          if (TFuBnkFrame.cfg["show_tokens"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Money"];
            ["func"] = TFuBnkFrame.Toggle_Money;
            ["keepShownOnClick"] = 1;
            };
          if (TFuBnkFrame.cfg["show_money"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
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

function Bank:UpdateWindow(resort_req)
  local frame = TFuBnkFrame;
  local barnum;
  local cur_y;

  TFuBag:PrintDEBUG("Bank:UpdateWindow(): WindowIsUpdating="..Bank.WindowIsUpdating);

  if (Bank.WindowIsUpdating == 1) then
    return;
  end
  Bank.WindowIsUpdating = 1;

  if ( not frame:IsVisible() ) then
    Bank.WindowIsUpdating = 0;
    return;
  end

  -- Set the overall scale
  self:SetScale(self.cfg["scale"]);

  if (resort_req == nil) then resort_req = TFuBag.REQ_NONE; end

  -- Show some things only when we are at then bank
  if (self.atbank == 1 or self.cfg["show_userdropdown"] == 0) then
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
    -- The deferred-resort debt is paid here; clear it so a one-shot CACHE_REQ = REQ_MUST
    -- (e.g. set by RebuildTabList when the tab set changes) fires exactly once and does
    -- not stick high and re-sort on every later open. (Mirrors Inv:UpdateWindow.)
    self.CACHE_REQ = TFuBag.REQ_NONE
    self.BARITM = TFuBag:SortItmCache(self.cfg,
      self.playerid, TFuBnkItm[self.playerid], self.BARITM, self.bags);
    TFuBag:LayoutWindow(self)
  elseif (self.force_relayout) then
    -- Relayout without resort: edit-mode toggle changes layout (bar buttons, shared
    -- height) but NOT categorization, so skip the costly SortItmCache (per-item
    -- tooltip scan) that made toggling edit mode lag on a large bank.
    TFuBag:LayoutWindow(self)
  elseif cache_req > self.CACHE_REQ then
    self.CACHE_REQ = cache_req
  end
  self.force_relayout = nil

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
      -- C_Bank.FetchDepositedMoney(Enum.BankType.Account), and the frame already
      -- registered ACCOUNT_MONEY in SmallMoneyFrame_OnLoad, so it self-refreshes on
      -- deposit/withdraw. MoneyFrame_UpdateMoney populates it now (on view switch).
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

  TFuBnkFrame:SetButton_Anchors();

  -- Refresh the per-item spotlight glows against the just-relinked button->item map.
  -- Without this, moving items (e.g. via Blizzard's bank window -> BAG_UPDATE ->
  -- UpdateWindow) re-sorts the buttons but leaves stale highlight textures shown on
  -- their old buttons, so the glow appeared to "stack" until a tab click finally
  -- recomputed it. UpdateButtonHighlights is light (show/hide/tint only, no rescan).
  TFuBag:UpdateButtonHighlights();
  TFuBag:UpdateFreeSlotsCell(TFuBnkFrame);

  Bank.WindowIsUpdating = 0;
end


-- Bank:SetReplaceBank removed for the 12.0 rewrite: hijacking Blizzard's BankFrame
-- (Hide + steal its events) risks taint in 12.0 (managed UIPanel/CallbackRegistry).
-- Syndicator and Baganator never touch BankFrame; we let it open normally.


function Bank.UserDropdown_OnLoad(self)
  UIDropDownMenu_Initialize(self, Bank.UserDropdown_Initialize);
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
  -- Show in whatever state the cache was in before
  TFuBnkFrame.atbank = 0;
  TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST);
end
