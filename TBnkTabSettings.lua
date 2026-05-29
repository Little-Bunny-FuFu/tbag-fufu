-- Bank Tab Settings dialog, rebuilt on Blizzard's IconSelectorPopupFrameTemplate so the
-- icon grid, scrollbar, icon-type dropdown (All/Spells/Items), name box and selected-icon
-- preview match Blizzard's own bank/macro pickers exactly. On top of the template we add
-- the deposit-setting checkboxes and the expansion-filter dropdown, mirroring Blizzard's
-- BankPanelTabSettingsMenu (BankFrame.lua/.xml). Settings are applied through the public
-- C_Bank.UpdateBankTabSettings -- we never read or write Blizzard's secure bank objects,
-- so this stays taint-safe.
--
-- The frame TFuBnk_TabSettingsDialog (mixin = TFuBnkTabSettingsMixin, inherits
-- IconSelectorPopupFrameTemplate) is declared in TBnkTabSettings.xml. This file must load
-- BEFORE that XML so the mixin global exists when the frame is created.

TFuBnkTabSettingsMixin = {}

-- Deposit-assignment checkboxes Blizzard exposes for bank tabs (BankFrame.xml:93-141).
-- Note Blizzard's bank menu intentionally omits ClassQuestItems -- we match that. Labels
-- use Blizzard's own global strings with literal fallbacks if a string is absent.
local function GetAssignDefs()
  local F = Enum and Enum.BagSlotFlags
  if (not F) then return {} end
  local defs = {}
  local function add(field, label)
    if (F[field] ~= nil) then defs[#defs + 1] = { flag = F[field], label = label } end
  end
  add("ClassEquipment",       _G.BANK_TAB_ASSIGN_EQUIPMENT_CHECKBOX or "Equipment")
  add("ClassConsumables",     _G.BANK_TAB_ASSIGN_CONSUMABLES_CHECKBOX or "Consumables")
  add("ClassProfessionGoods", _G.BANK_TAB_ASSIGN_PROFESSION_GOODS_CHECKBOX or "Profession Goods")
  add("ClassReagents",        _G.BANK_TAB_ASSIGN_REAGENTS_CHECKBOX or "Reagents")
  add("ClassJunk",            _G.BANK_TAB_ASSIGN_JUNK_CHECKBOX or "Junk")
  return defs
end

-- Expansion filter values, mirroring BankTabExpansionFilterTypes (BankFrame.lua:1490).
local function GetExpansionDefs()
  local F = Enum and Enum.BagSlotFlags
  return {
    { value = 0, label = _G.BANK_TAB_EXPANSION_FILTER_ALL or "All Expansions" },
    { value = (F and F.ExpansionCurrent) or 0,
      label = _G.BANK_TAB_EXPANSION_FILTER_CURRENT or "Current Expansion Only" },
    { value = (F and F.ExpansionLegacy) or 0,
      label = _G.BANK_TAB_EXPANSION_FILTER_LEGACY or "Previous Expansions Only" },
  }
end

-- Bitmask of every expansion bit, so we can clear them before OR-ing the chosen one.
local function ExpansionMask()
  local F = Enum and Enum.BagSlotFlags
  local m = 0
  if (F) then
    if (F.ExpansionCurrent) then m = bit.bor(m, F.ExpansionCurrent) end
    if (F.ExpansionLegacy) then m = bit.bor(m, F.ExpansionLegacy) end
  end
  return m
end

-- Build the deposit-settings checkboxes + expansion dropdown in the space the template
-- leaves between the name/icon-type row and the (re-anchored) icon grid. Created in Lua
-- (not by inheriting Blizzard's BankFrame virtual templates, which may be unloaded at our
-- load time).
function TFuBnkTabSettingsMixin:BuildDepositControls()
  local box = self.BorderBox
  if (not box) then return end

  self.assignChecks = {}
  local TOP = -74
  local F = Enum and Enum.BagSlotFlags

  -- Three columns mirroring Blizzard's BankTabDepositSettingsMenu (BankFrame.xml):
  --   Col 1 (x=24)  Assignment    -> expansion-filter dropdown
  --   Col 2 (x=150) Assign to tab -> class checkboxes in two sub-columns
  --   Col 3 (x=380) Filters       -> ignore-on-cleanup checkbox

  -- Column 1: expansion-filter dropdown.
  local exHeader = box:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
  exHeader:SetPoint("TOPLEFT", box, "TOPLEFT", 24, TOP)
  exHeader:SetText(_G.BANK_TAB_ASSIGN_EXPANSION_HEADER or "Assignment:")
  local dd = CreateFrame("DropdownButton", nil, box, "WowStyle1DropdownTemplate")
  dd:SetWidth(120)
  dd:SetPoint("TOPLEFT", exHeader, "BOTTOMLEFT", -2, -4)
  self.expansionValue = 0
  local exDefs = GetExpansionDefs()
  local function isSel(v) return self.expansionValue == v end
  local function setSel(v) self.expansionValue = v end
  dd:SetupMenu(function(_, root)
    for _, d in ipairs(exDefs) do
      root:CreateRadio(d.label, isSel, setSel, d.value)
    end
  end)
  self.ExpansionDropdown = dd

  -- Column 2: class-assignment checkboxes (two sub-columns).
  local asHeader = box:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
  asHeader:SetPoint("TOPLEFT", box, "TOPLEFT", 150, TOP)
  asHeader:SetText(_G.BANK_TAB_DEPOSIT_SETTINGS_HEADER or "Assign to tab:")
  local function mkCheck(def, x, y)
    local cb = CreateFrame("CheckButton", nil, box, "UICheckButtonTemplate")
    cb:SetSize(22, 22)
    cb:SetPoint("TOPLEFT", asHeader, "BOTTOMLEFT", x, y)
    local lbl = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    lbl:SetPoint("LEFT", cb, "RIGHT", 2, 0)
    lbl:SetText(def.label)
    cb.settingFlag = def.flag
    self.assignChecks[#self.assignChecks + 1] = cb
  end
  local defs = GetAssignDefs()
  if (defs[1]) then mkCheck(defs[1], 0, -2) end
  if (defs[2]) then mkCheck(defs[2], 0, -26) end
  if (defs[3]) then mkCheck(defs[3], 0, -50) end
  if (defs[4]) then mkCheck(defs[4], 120, -2) end
  if (defs[5]) then mkCheck(defs[5], 120, -26) end

  -- Column 3: ignore-on-cleanup (DisableAutoSort); long label wraps in a narrow width.
  if (F and F.DisableAutoSort) then
    local flHeader = box:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    flHeader:SetPoint("TOPLEFT", box, "TOPLEFT", 380, TOP)
    flHeader:SetText(_G.BANK_TAB_CLEANUP_SETTINGS_HEADER or "Filters:")
    local cb = CreateFrame("CheckButton", nil, box, "UICheckButtonTemplate")
    cb:SetSize(22, 22)
    cb:SetPoint("TOPLEFT", flHeader, "BOTTOMLEFT", 0, -2)
    local lbl = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    lbl:SetPoint("TOPLEFT", cb, "TOPRIGHT", 2, -2)
    lbl:SetWidth(108)
    lbl:SetJustifyH("LEFT")
    lbl:SetText(_G.BANK_TAB_IGNORE_IN_CLEANUP_CHECKBOX or "Ignore this tab when cleaning up bags")
    cb.settingFlag = F.DisableAutoSort
    self.assignChecks[#self.assignChecks + 1] = cb
  end
end

-- Push the inherited icon grid (and its label/type-dropdown) down to make room for the
-- deposit controls above, then grow the window. Mirrors Blizzard's OverrideInheritedAnchoring.
function TFuBnkTabSettingsMixin:RelayoutForDepositControls()
  self:SetHeight(594)
  if (self.IconSelector) then
    self.IconSelector:ClearAllPoints()
    self.IconSelector:SetPoint("TOPLEFT", self.BorderBox, "TOPLEFT", 21, -196)
  end
  if (self.BorderBox and self.BorderBox.IconSelectionText) then
    self.BorderBox.IconSelectionText:ClearAllPoints()
    self.BorderBox.IconSelectionText:SetPoint("BOTTOMLEFT", self.IconSelector, "TOPLEFT", 0, 10)
  end
  if (self.BorderBox and self.BorderBox.IconTypeDropdown and self.IconSelector) then
    self.BorderBox.IconTypeDropdown:ClearAllPoints()
    self.BorderBox.IconTypeDropdown:SetPoint("BOTTOMRIGHT", self.IconSelector, "TOPRIGHT", -33, 0)
  end
end

function TFuBnkTabSettingsMixin:OnLoad()
  IconSelectorPopupFrameTemplateMixin.OnLoad(self)
  self:BuildDepositControls()
  self:RelayoutForDepositControls()

  -- The inherited BorderBox is a nine-slice with no layout applied here, so the window
  -- would render fully transparent. Add a guaranteed solid backing now (so the dialog is
  -- always visible); the Blizzard nine-slice border is applied in OnShow once its layout
  -- is registered (Blizzard_UIPanels_Game loads with the bank).
  local bg = self:CreateTexture(nil, "BACKGROUND")
  bg:SetPoint("TOPLEFT", self, "TOPLEFT", 6, -6)
  bg:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -6, 6)
  bg:SetColorTexture(0.05, 0.05, 0.06, 0.94)
  self.tfuBackground = bg

  local border = CreateFrame("Frame", nil, self, "DialogBorderTemplate")
  self.tfuBorder = border

  -- Don't auto-grab keyboard focus on open: otherwise the name edit box swallows /slash
  -- commands and chat until the user presses Escape. They can click the box to rename.
  if (self.BorderBox and self.BorderBox.IconSelectorEditBox) then
    self.BorderBox.IconSelectorEditBox:SetAutoFocus(false)
  end

  -- Make the window draggable by its body (empty areas / header). Child controls
  -- consume their own clicks, so dragging starts only on the frame's own surface.
  self:SetMovable(true)
  self:RegisterForDrag("LeftButton")
  self:SetScript("OnDragStart", self.StartMoving)
  self:SetScript("OnDragStop", self.StopMovingOrSizing)
end

function TFuBnkTabSettingsMixin:OnShow()
  IconSelectorPopupFrameTemplateMixin.OnShow(self)
  self.iconDataProvider = self:RefreshIconDataProvider()

  -- Link the ScrollBoxSelector grid to the icon data provider. The selector defaults to
  -- an empty array provider, so without this the grid is blank. SetSelectionsDataProvider
  -- (getByIndex, getNum) also triggers UpdateSelections to build the grid.
  self.IconSelector:SetSelectionsDataProvider(
    function(index) return self.iconDataProvider:GetIconByIndex(index) end,
    function() return self.iconDataProvider:GetNumIcons() end)

  -- Clicking a grid icon updates the selected-icon preview, which OkayButton_OnClick
  -- reads back via GetIconTexture (mirrors MacroPopupFrameMixin:OnShow).
  self.IconSelector:SetSelectedCallback(function(_, icon)
    self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(icon)
  end)

  self:Update()
  self:SetIconFilter(IconSelectorPopupFrameIconFilterTypes.All)

  -- Float at FULLSCREEN_DIALOG and raise once on open. Deliberately NOT toplevel: a
  -- toplevel frame re-raises itself (and its dropdown children) on every mouse click,
  -- which would bump this frame's level above the dropdown menu the click just opened
  -- (the menu's level = dropdown level + 500, Menu.lua) and bury it. Without toplevel the
  -- menu's +500 lands above us. NOT TOOLTIP either: the menu mirrors a TOOLTIP owner's
  -- strata and would then lose to this frame. The background/border (added in OnLoad) is
  -- what makes the window visible -- strata was never the visibility problem.
  self:SetFrameStrata("FULLSCREEN_DIALOG")
  self:ClearAllPoints()
  self:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  self:Raise()
end

function TFuBnkTabSettingsMixin:OnHide()
  IconSelectorPopupFrameTemplateMixin.OnHide(self)
  if (self.BorderBox and self.BorderBox.IconSelectorEditBox) then
    self.BorderBox.IconSelectorEditBox:ClearFocus()
  end
  if (self.iconDataProvider ~= nil) then
    self.iconDataProvider:Release()
    self.iconDataProvider = nil
  end
  self.selectedTabData = nil
end

-- Blizzard's exact provider for bank tabs: all icon types, canonical order, ? at index 1.
function TFuBnkTabSettingsMixin:RefreshIconDataProvider()
  if (self.iconDataProvider == nil) then
    self.iconDataProvider = CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.None)
  end
  return self.iconDataProvider
end

-- Pre-fill name, selected icon, deposit checkboxes and expansion dropdown from the tab.
function TFuBnkTabSettingsMixin:Update()
  local tabData = self.selectedTabData
  if (not tabData) then return end

  if (self.BorderBox and self.BorderBox.IconSelectorEditBox) then
    self.BorderBox.IconSelectorEditBox:SetText(tabData.name or "")
  end

  local icon = tabData.icon
  if (icon and self.iconDataProvider) then
    local index = self.iconDataProvider:GetIndexOfIcon(icon)
    if (index and index > 0) then
      self.IconSelector:SetSelectedIndex(index)
      self.IconSelector:ScrollToSelectedIndex()
    end
  end
  if (self.BorderBox and self.BorderBox.SelectedIconArea) then
    self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(icon)
  end

  local flags = tabData.depositFlags or 0
  for _, cb in ipairs(self.assignChecks or {}) do
    if (cb.settingFlag) then
      cb:SetChecked(FlagsUtil.IsSet(flags, cb.settingFlag))
    end
  end

  -- Seed the expansion dropdown from whichever expansion bit is set.
  self.expansionValue = 0
  local F = Enum and Enum.BagSlotFlags
  if (F) then
    if (F.ExpansionCurrent and FlagsUtil.IsSet(flags, F.ExpansionCurrent)) then
      self.expansionValue = F.ExpansionCurrent
    elseif (F.ExpansionLegacy and FlagsUtil.IsSet(flags, F.ExpansionLegacy)) then
      self.expansionValue = F.ExpansionLegacy
    end
  end
  if (self.ExpansionDropdown) then self.ExpansionDropdown:GenerateMenu() end
end

-- Assemble depositFlags exactly like Blizzard's GetNewTabDepositFlags: each checkbox's
-- flag by its checked state, plus the chosen expansion bit.
function TFuBnkTabSettingsMixin:GetNewTabDepositFlags()
  local depositFlags = 0
  for _, cb in ipairs(self.assignChecks or {}) do
    if (cb.settingFlag) then
      depositFlags = FlagsUtil.Combine(depositFlags, cb.settingFlag, cb:GetChecked())
    end
  end
  -- Clear all expansion bits, then set the selected one (if any).
  depositFlags = FlagsUtil.Combine(depositFlags, ExpansionMask(), false)
  if (self.expansionValue and self.expansionValue ~= 0) then
    depositFlags = FlagsUtil.Combine(depositFlags, self.expansionValue, true)
  end
  return depositFlags
end

function TFuBnkTabSettingsMixin:OkayButton_OnClick()
  local tabData = self.selectedTabData
  if (tabData and C_Bank and C_Bank.UpdateBankTabSettings) then
    local name = self.BorderBox.IconSelectorEditBox:GetText() or ""
    local icon = self.BorderBox.SelectedIconArea.SelectedIconButton:GetIconTexture()
    local flags = self:GetNewTabDepositFlags()
    C_Bank.UpdateBankTabSettings(tabData.bankType, tabData.ID, name, icon, flags)
  end
  IconSelectorPopupFrameTemplateMixin.OkayButton_OnClick(self)
  if (TFuBnkFrame and TFuBnkFrame.RebuildTabList) then
    TFuBnkFrame:RebuildTabList()
    if (TFuBnkFrame.atbank == 1) then TFuBnkFrame:UpdateWindow(TFuBag.REQ_MUST) end
  end
end

function TFuBnkTabSettingsMixin:CancelButton_OnClick()
  IconSelectorPopupFrameTemplateMixin.CancelButton_OnClick(self)
end

-- Entry point used by Bank:OpenTabSettings. Fetches the live tab data (taint-safe read),
-- stores it, and shows the dialog (OnShow drives Update).
function TFuBnkTabSettings_Open(bankType, tabID)
  local frame = TFuBnk_TabSettingsDialog
  if (not frame) then return false end
  if (not (C_Bank and C_Bank.UpdateBankTabSettings and C_Bank.FetchPurchasedBankTabData)) then
    return false
  end
  local ok, tabs = pcall(C_Bank.FetchPurchasedBankTabData, bankType)
  if (not ok or type(tabs) ~= "table") then return false end
  local found = nil
  for _, t in ipairs(tabs) do
    if (t.ID == tabID) then found = t; break; end
  end
  if (not found) then return false end

  frame.selectedTabData = found
  if (frame:IsShown()) then
    frame:Hide()
  end
  frame:Show()
  return true
end
