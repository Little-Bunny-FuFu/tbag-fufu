-- ModernOpt.lua -- rewritten options UI (modern Blizzard styling).
-- Phase 1: window shell + left-nav sections + a control factory of real
-- Blizzard-styled controls (checkbox, stepper-slider, dropdown, button, header).
-- The old TInv/TBnk options frames stay live until the rewrite is complete and
-- swapped in. Open with /tinv modopts (temporary, for testing the new UI).

local _G = getfenv(0)
local TFuBag = _G.TFuBag
local L = TFuBag.LOCALE

TFuBag.ModernOpt = TFuBag.ModernOpt or {}
local MO = TFuBag.ModernOpt

-- Layout constants
local PAD = 16            -- content inset
local ROW_GAP = 8         -- vertical gap between stacked controls
local NAV_WIDTH = 150
local WIN_W, WIN_H = 720, 520

-- Confirm before deleting a category (recoverable via /tinv resetsorts, but destructive
-- enough to confirm). %s = category name; data = { name=, after=rebuildList }.
StaticPopupDialogs["TBAG_DELETE_CATEGORY"] = {
  text = "Delete category \"%s\"?\nIts sorting rules are removed and its items fall back to type sorting. (/tinv resetsorts restores the defaults.)",
  button1 = YES,
  button2 = NO,
  OnAccept = function(_, data)
    if (data and data.name) then TFuBag:DeleteCategory(data.name) end
    if (data and data.after) then data.after() end
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
}

-----------------------------------------------------------------------
-- Control factory. Each builder takes (parent, y, ...) and returns the
-- control plus the next y cursor (controls stack top-down; y grows downward
-- as a positive offset subtracted from the content top).
-----------------------------------------------------------------------

-- A bold section header.
function MO:Header(parent, y, text)
  local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  fs:SetPoint("TOPLEFT", parent, "TOPLEFT", PAD, -y)
  fs:SetText(text)
  return fs, y + 24 + ROW_GAP
end

-- Plain label line.
function MO:Label(parent, y, text)
  local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  fs:SetPoint("TOPLEFT", parent, "TOPLEFT", PAD, -y)
  fs:SetText(text)
  return fs, y + 16 + ROW_GAP
end

-- Real checkbox. get() -> bool, set(bool) called on toggle.
function MO:Checkbox(parent, y, label, get, set)
  local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
  cb:SetPoint("TOPLEFT", parent, "TOPLEFT", PAD, -y)
  cb:SetSize(24, 24)
  -- Own label FontString (template label-region names vary across versions).
  local fs = cb:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  fs:SetPoint("LEFT", cb, "RIGHT", 4, 0)
  fs:SetText(label)
  cb:SetChecked(get() and true or false)
  cb:SetScript("OnClick", function(self)
    set(self:GetChecked() and true or false)
  end)
  cb.tfuRefresh = function() cb:SetChecked(get() and true or false) end
  return cb, y + 26 + ROW_GAP
end

-- Stepper slider (MinimalSliderWithSteppersTemplate). Integer steps.
function MO:Slider(parent, y, label, minV, maxV, step, get, set)
  local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  fs:SetPoint("TOPLEFT", parent, "TOPLEFT", PAD, -y)
  fs:SetText(label)

  local sl = CreateFrame("Frame", nil, parent, "MinimalSliderWithSteppersTemplate")
  sl:SetPoint("TOPLEFT", parent, "TOPLEFT", PAD, -(y + 18))
  sl:SetWidth(280)
  local steps = math.floor((maxV - minV) / step + 0.5)
  local fmt = {
    [MinimalSliderWithSteppersMixin.Label.Right] = function(v) return tostring(v) end,
  }
  sl:Init(get(), minV, maxV, steps, fmt)
  sl:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged, function(_, value)
    set(value)
  end, parent)
  sl.tfuRefresh = function() sl:Init(get(), minV, maxV, steps, fmt) end
  return sl, y + 18 + 30 + ROW_GAP
end

-- Dropdown (WowStyle1DropdownTemplate). options = array of {text=, value=}.
-- get() -> current value, set(value) on pick.
function MO:Dropdown(parent, y, label, width, options, get, set, xPos)
  xPos = xPos or PAD
  local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  fs:SetPoint("TOPLEFT", parent, "TOPLEFT", xPos, -y)
  fs:SetText(label)

  local dd = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
  dd:SetPoint("TOPLEFT", parent, "TOPLEFT", xPos, -(y + 16))
  dd:SetWidth(width or 200)
  dd:SetupMenu(function(_, root)
    for _, opt in ipairs(options) do
      root:CreateRadio(opt.text,
        function() return get() == opt.value end,
        function() set(opt.value); end,
        opt.value)
    end
  end)
  dd.tfuRefresh = function() dd:GenerateMenu() end
  return dd, y + 16 + 26 + ROW_GAP
end

-- Push button.
function MO:Button(parent, y, text, width, onClick)
  local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  b:SetPoint("TOPLEFT", parent, "TOPLEFT", PAD, -y)
  b:SetSize(width or 140, 22)
  b:SetText(text)
  b:SetScript("OnClick", onClick)
  return b, y + 22 + ROW_GAP
end

-- Scrollable list region (classic ScrollFrameTemplate: built-in scrollbar + mouse wheel).
-- Returns (scrollFrame, scrollChild). Callers lay rows out top-down in the child and set
-- child:SetHeight(totalContentHeight) to enable scrolling. width/height size the viewport.
function MO:ScrollList(parent, x, y, width, height)
  local sf = CreateFrame("ScrollFrame", nil, parent, "ScrollFrameTemplate")
  sf:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
  sf:SetSize(width, height)
  -- A faint backdrop so the list region reads as a distinct panel.
  local bg = sf:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints(sf)
  bg:SetColorTexture(0, 0, 0, 0.25)
  local child = CreateFrame("Frame", nil, sf)
  child:SetSize(width, height)   -- height is reset by the caller to the content height
  sf:SetScrollChild(child)
  sf.child = child
  return sf, child, y + height + ROW_GAP
end

-----------------------------------------------------------------------
-- Window shell
-----------------------------------------------------------------------

MO.sections = {}   -- { {key=, title=, build=function(contentFrame)} }

function MO:RegisterSection(key, title, build)
  self.sections[#self.sections + 1] = { key = key, title = title, build = build }
end

-- Each section gets its own container frame, built once (lazily) and then just
-- shown/hidden. Controls register themselves in container.controls so their
-- values can be re-synced from cfg every time the section is shown.
function MO:GetSectionFrame(section)
  if (not section.frame) then
    local sf = CreateFrame("Frame", nil, self.content)
    sf:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, -28)
    sf:SetPoint("BOTTOMRIGHT", self.content, "BOTTOMRIGHT", 0, 0)
    sf:Hide()
    sf.controls = {}
    section.frame = sf
    section.build(sf, self)
  end
  return section.frame
end

function MO:ShowSection(key)
  if (not key) then return end
  for _, s in ipairs(self.sections) do
    if (s.frame) then s.frame:Hide() end
  end
  for _, navbtn in ipairs(self.navButtons) do
    navbtn:SetEnabled(navbtn.sectionKey ~= key)
  end
  for _, s in ipairs(self.sections) do
    if (s.key == key) then
      self.contentTitle:SetText(s.title)
      local sf = self:GetSectionFrame(s)
      for _, c in ipairs(sf.controls) do
        if (c.tfuRefresh) then c.tfuRefresh() end
      end
      sf:Show()
      self.currentSection = key
      break
    end
  end
end

function MO:CreateWindow()
  if (self.frame) then return self.frame end

  local f = CreateFrame("Frame", "TFuModernOptFrame", UIParent, "ButtonFrameTemplate")
  f:SetSize(WIN_W, WIN_H)
  f:SetPoint("CENTER")
  f:SetFrameStrata("HIGH")
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving)
  f:SetScript("OnDragStop", f.StopMovingOrSizing)
  -- Closing the options auto-applies any category/grouping/filter changes: re-sort
  -- visible bag windows now, and flag hidden ones to re-sort on their next open
  -- (so the user never has to trigger a manual resort).
  f:SetScript("OnHide", function()
    for _, frame in ipairs({ TFuInvFrame, TFuBnkFrame }) do
      if (frame) then
        if (frame:IsVisible()) then
          frame:UpdateWindow(TFuBag.REQ_MUST)
        else
          frame.needsResort = true
        end
      end
    end
  end)
  if (f.SetTitle) then f:SetTitle("TBag Options") end
  -- ButtonFrameTemplate shows a portrait; give it the bag icon.
  if (f.PortraitContainer and f.PortraitContainer.portrait) then
    f.PortraitContainer.portrait:SetTexture("Interface\\Icons\\INV_Misc_Bag_08")
  end
  -- Hide the bottom money/inset money region the template may add.
  if (_G["TFuModernOptFrameInset"]) then _G["TFuModernOptFrameInset"]:Hide() end
  tinsert(UISpecialFrames, "TFuModernOptFrame")  -- closable with Escape
  self.frame = f

  -- Left nav column. Start below the template's portrait icon (top-left) so the first
  -- nav button is not covered by it.
  local nav = CreateFrame("Frame", nil, f)
  nav:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -64)
  nav:SetSize(NAV_WIDTH, WIN_H - 96)
  self.nav = nav

  -- Content panel: anchored to the frame (not the nav) so it stays at the top regardless
  -- of where the nav column starts.
  local content = CreateFrame("Frame", nil, f)
  content:SetPoint("TOPLEFT", f, "TOPLEFT", NAV_WIDTH + 16, -28)
  content:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -12, 12)
  self.content = content

  self.contentTitle = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  self.contentTitle:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, -4)

  -- Nav buttons, one per section.
  self.navButtons = {}
  local ny = 0
  for _, s in ipairs(self.sections) do
    local b = CreateFrame("Button", nil, nav, "UIPanelButtonTemplate")
    b:SetPoint("TOPLEFT", nav, "TOPLEFT", 0, -ny)
    b:SetSize(NAV_WIDTH, 24)
    b:SetText(s.title)
    b.sectionKey = s.key
    b:SetScript("OnClick", function() MO:ShowSection(s.key) end)
    self.navButtons[#self.navButtons + 1] = b
    ny = ny + 28
  end

  -- CreateFrame shows by default; start hidden so the first /tbmodopts opens it
  -- (otherwise Toggle sees it already shown and hides it -- the "twice" bug).
  f:Hide()
  return f
end

function MO:Toggle()
  self:CreateWindow()
  if (self.frame:IsShown()) then
    self.frame:Hide()
  else
    self.frame:Show()
    self:ShowSection(self.currentSection or (self.sections[1] and self.sections[1].key))
  end
end

-- Open (not toggle) to a specific section, optionally pre-selecting the General Inv|Bank
-- tab. Used by the bag windows' right-click "Options" so the bank opens to General/Bank
-- and the inventory to General/Inv. requestedWindow is consumed by the General section's
-- refresh.
function MO:OpenTo(sectionKey, which)
  self:CreateWindow()
  self.requestedWindow = which
  if (not self.frame:IsShown()) then self.frame:Show() end
  self:ShowSection(sectionKey or (self.sections[1] and self.sections[1].key))
end

-----------------------------------------------------------------------
-- General section: full parity with the old Advanced Configuration panel,
-- per-window (an Inventory|Bank toggle shows one of two scroll panels, each
-- built against that window's cfg). Grouped under Sizing / Bag Contents /
-- Display / Behavior sub-headers.
-----------------------------------------------------------------------

-- Build every General control for one window's cfg into a scrollable panel.
-- Returns the ScrollFrame; its .controls list is re-synced on show.
function MO:GeneralContent(parent, x, y, w, h, frame)
  local sfl, child = self:ScrollList(parent, x, y, w, h)
  local cfg = frame.cfg
  local controls = {}
  sfl.controls = controls
  local function track(c) controls[#controls + 1] = c; return c end
  local function force() frame:UpdateWindow(TFuBag.REQ_MUST) end
  local function resize()
    frame:CalcButtonSize(cfg.frameButtonSize, cfg.framePad)
    frame:UpdateWindow(TFuBag.REQ_MUST)
  end
  local yy = 6

  local function chk(label, key, apply)
    local c, ny = self:Checkbox(child, yy, label,
      function() return cfg[key] == 1 end,
      function(v) cfg[key] = v and 1 or 0; (apply or force)() end)
    track(c); yy = ny
  end
  local function sld(label, key, mn, mx, st, apply)
    local c, ny = self:Slider(child, yy, label, mn, mx, st,
      function() return cfg[key] or mn end,
      function(v) cfg[key] = v; (apply or force)() end)
    track(c); yy = ny
    return c
  end

  local _, ny = self:Header(child, yy, "Sizing"); yy = ny

  -- Legacy column/row sizing toggle. ON = the two sliders below drive the layout (the
  -- window grows vertically only and never exceeds the column count). OFF = dynamic:
  -- the window is resizable and categories reflow to fill it, so the sliders are inert
  -- (greyed). [Stage 1: the toggle + gating; the resize grip + reflow follow.]
  local colSlider, barSlider
  local function gateSliders()
    local on = (cfg.legacy_sizing == 1)
    for _, s in ipairs({ colSlider, barSlider }) do
      if (s) then
        if (s.SetEnabled) then s:SetEnabled(on) end
        s:SetAlpha(on and 1 or 0.4)
      end
    end
  end
  local lc; lc, ny = self:Checkbox(child, yy,
    "Legacy column/row sizing (off = resizable, auto-arranged window)",
    function() return cfg.legacy_sizing == 1 end,
    function(v) cfg.legacy_sizing = v and 1 or 0; gateSliders(); force() end)
  track(lc); yy = ny

  colSlider = sld("Item Columns", "maxColumns", TFuBag.NUMCOL_MIN, TFuBag.NUMCOL_MAX, 1)
  barSlider = sld("Horizontal Bars", "bar_x", 1, TFuBag.NUMCOL_MAX, 1)
  gateSliders()
  track({ tfuRefresh = gateSliders })  -- re-grey the sliders whenever the panel is shown
  do  -- scale is stored 0-1; expose as a 10-100% slider
    local c; c, ny = self:Slider(child, yy, "Window Scale (%)", 10, 100, 5,
      function() return math.floor((cfg.scale or 1) * 100 + 0.5) end,
      function(v) cfg.scale = v / 100; force() end)
    track(c); yy = ny
  end
  sld("Item Button Size", "frameButtonSize", TFuBag.N_BUTTON_MIN, TFuBag.N_BUTTON_MAX, 1, resize)
  sld("Item Button Padding", "framePad", 0, TFuBag.N_SPACE_MAX, 1, resize)
  sld("Spacing - X Button", "frameXSpace", 0, TFuBag.N_SPACE_MAX, 1, resize)
  sld("Spacing - Y Button", "frameYSpace", 0, TFuBag.N_SPACE_MAX, 1, resize)
  sld("Spacing - X Pool", "frameXPool", 0, TFuBag.N_SPACE_MAX, 1, resize)
  sld("Spacing - Y Pool", "frameYPool", 0, TFuBag.N_SPACE_MAX, 1, resize)
  sld("Category Spacing", "cat_spacing", 0, TFuBag.N_CATSPACE_MAX, 1, resize)
  sld("Count Font Size", "count_font", TFuBag.N_FONT_MIN, TFuBag.N_FONT_MAX, 1, resize)
  sld("Count Placement - X", "count_font_x", 0, TFuBag.N_BUTTON_MAX, 1, resize)
  sld("Count Placement - Y", "count_font_y", 0, TFuBag.N_BUTTON_MAX, 1, resize)
  sld("New Tag Font Size", "new_font", TFuBag.N_FONT_MIN, TFuBag.N_FONT_MAX, 1, resize)

  _, ny = self:Header(child, yy, "Bag Contents"); yy = ny
  for _, bag in ipairs(frame.bags or {}) do
    chk(string.format("Show %s", TFuBag:GetBagDispName(bag)), "show_Bag" .. bag)
  end

  _, ny = self:Header(child, yy, "Display"); yy = ny
  chk("Show Size on Bag Count", "show_bag_sizes")
  chk("Show Bag Icons on Empty Slots", "show_bag_icons")
  chk("Collapse Empty Slots (one cell + free count)", "collapse_empty")
  chk("Spotlight Open or Selected Bags", "spotlight_open")
  chk("Spotlight Mouseover", "spotlight_hover")
  chk("Show Item Rarity Color", "show_rarity_color")
  chk("Show Category Names", "show_cat_names")
  chk("Show Header/Footer Lines", "show_chrome_lines")

  _, ny = self:Header(child, yy, "Behavior"); yy = ny
  chk("Auto Stack", "stack_auto")
  chk("Stack on Re-sort", "stack_resort")
  -- One toggle for the arrange mode. ON = drag-to-arrange (manual layout via the gear);
  -- OFF = legacy click editing. This is the legacy_edit flag inverted -- exposing it and
  -- ml_freeplace as two peer boxes let an inconsistent combo (legacy_edit=1) silently
  -- break drag, which is what "drag to arrange doesn't work" was. (Free-vs-grid placement,
  -- ml_freeplace, stays on the legacy /config panel.)
  do
    local c, ny = self:Checkbox(child, yy, "Drag to arrange categories (off = legacy click editing)",
      function() return cfg.legacy_edit ~= 1 end,
      function(v) cfg.legacy_edit = v and 0 or 1; force() end)
    track(c); yy = ny
  end
  chk("Profession Bags precede Sorting", "special_bag_sort")
  chk("Split Reagents by Profession (original TBag style)", "reagent_split")
  chk("Trade Creation precedes Sorting (reopen window)", "trade_created_sort")

  if (frame == TFuInvFrame) then
    chk("Alt Key Auto-Pickup", "alt_pickup")
    chk("Alt Key Auto-Panel", "alt_panel")
  end

  child:SetHeight(math.max(h, yy + 8))
  return sfl
end

MO:RegisterSection("general", "General", function(sf, MO)
  if (not (TFuInvFrame and TFuInvFrame.cfg)) then
    MO:Label(sf, 8, "Inventory window not initialised yet."); return
  end
  local y = 8  -- the content-title (top) already shows "General"

  -- Inventory | Bank toggle.
  local invBtn = CreateFrame("Button", nil, sf, "UIPanelButtonTemplate")
  invBtn:SetSize(110, 22); invBtn:SetText("Inventory")
  invBtn:SetPoint("TOPLEFT", sf, "TOPLEFT", PAD, -y)
  local bankBtn = CreateFrame("Button", nil, sf, "UIPanelButtonTemplate")
  bankBtn:SetSize(110, 22); bankBtn:SetText("Bank")
  bankBtn:SetPoint("LEFT", invBtn, "RIGHT", 8, 0)
  y = y + 30

  -- Two pre-built panels; the toggle shows one. Bank panel only if the bank cfg exists.
  local invScroll = MO:GeneralContent(sf, PAD, y, 520, 300, TFuInvFrame)
  local bankScroll = (TFuBnkFrame and TFuBnkFrame.cfg)
    and MO:GeneralContent(sf, PAD, y, 520, 300, TFuBnkFrame) or nil

  local function refresh(scrollObj)
    if (scrollObj and scrollObj.controls) then
      for _, c in ipairs(scrollObj.controls) do
        if (c.tfuRefresh) then c.tfuRefresh() end
      end
    end
  end
  local function showWindow(which)
    local inv = (which ~= "bank")
    invBtn:SetEnabled(not inv); bankBtn:SetEnabled(inv and bankScroll ~= nil)
    if (inv or not bankScroll) then
      if (bankScroll) then bankScroll:Hide() end
      invScroll:Show(); refresh(invScroll); sf.tfuCurrent = "inv"
    else
      invScroll:Hide(); bankScroll:Show(); refresh(bankScroll); sf.tfuCurrent = "bank"
    end
  end
  invBtn:SetScript("OnClick", function() showWindow("inv") end)
  bankBtn:SetScript("OnClick", function() showWindow("bank") end)
  showWindow("inv")

  -- Re-sync the visible panel whenever the section is shown. Honor a requested window
  -- (set by MO:OpenTo when the bag/bank right-click menu opened Options) so it lands on
  -- the originating window's tab, then clear the request.
  sf.controls[#sf.controls + 1] = { tfuRefresh = function()
    local w = MO.requestedWindow or sf.tfuCurrent or "inv"
    MO.requestedWindow = nil
    showWindow(w)
  end }
end)

MO:RegisterSection("categories", "Categories", function(sf, MO)
  local function track(c) sf.controls[#sf.controls + 1] = c; return c end

  local y = 8  -- the content-title (top) already shows "Categories"
  MO:Label(sf, y, "Uncheck to disable a category (its items fall back to type sorting).")
  y = y + 16
  MO:Label(sf, y, "Delete removes it; Add makes a category from text found in the tooltip.")
  y = y + 24

  local rebuildList   -- forward declaration (Add/Delete refresh the list)

  -- Add-category form: name + tooltip-match text + Add button (one row).
  local nameEB = CreateFrame("EditBox", nil, sf, "InputBoxTemplate")
  nameEB:SetSize(130, 20); nameEB:SetAutoFocus(false)
  nameEB:SetPoint("TOPLEFT", sf, "TOPLEFT", PAD + 6, -y)
  local nlab = sf:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
  nlab:SetPoint("BOTTOMLEFT", nameEB, "TOPLEFT", -4, 2); nlab:SetText("New category")

  local matchEB = CreateFrame("EditBox", nil, sf, "InputBoxTemplate")
  matchEB:SetSize(180, 20); matchEB:SetAutoFocus(false)
  matchEB:SetPoint("LEFT", nameEB, "RIGHT", 16, 0)
  local mlab = sf:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
  mlab:SetPoint("BOTTOMLEFT", matchEB, "TOPLEFT", -4, 2); mlab:SetText("Match text (in tooltip)")

  local addBtn = CreateFrame("Button", nil, sf, "UIPanelButtonTemplate")
  addBtn:SetSize(60, 22); addBtn:SetText("Add")
  addBtn:SetPoint("LEFT", matchEB, "RIGHT", 12, 0)
  addBtn:SetScript("OnClick", function()
    if (TFuBag:AddCategory(nameEB:GetText(), matchEB:GetText())) then
      nameEB:SetText(""); matchEB:SetText(""); nameEB:ClearFocus(); matchEB:ClearFocus()
      if (rebuildList) then rebuildList() end
    else
      UIErrorsFrame:AddMessage("Enter a category name and match text.", 1, 0.3, 0.3)
    end
  end)
  y = y + 30

  -- Scrollable list: checkbox + name + Delete per distinct category.
  local listW, listH, rowH = 520, 300, 24
  local sfl, child = MO:ScrollList(sf, PAD, y, listW, listH)
  track(sfl)

  -- Reusable row pool (rebuilt on Add/Delete and on section re-show).
  local pool = {}
  local unsortedRow   -- pinned catch-all row, created lazily below
  local function getRow(i)
    local r = pool[i]
    if (not r) then
      r = {}
      r.cb = CreateFrame("CheckButton", nil, child, "UICheckButtonTemplate")
      r.cb:SetSize(22, 22)
      r.fs = r.cb:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
      r.fs:SetPoint("LEFT", r.cb, "RIGHT", 4, 0)
      r.del = CreateFrame("Button", nil, child, "UIPanelButtonTemplate")
      r.del:SetSize(54, 20); r.del:SetText("Delete")
      pool[i] = r
    end
    return r
  end

  rebuildList = function()
    local cats = TFuBag:GetCategoryList()
    for i, c in ipairs(cats) do
      local r = getRow(i)
      local yoff = -((i - 1) * rowH) - 2
      r.cb:ClearAllPoints(); r.cb:SetPoint("TOPLEFT", child, "TOPLEFT", 4, yoff)
      r.fs:SetText(c.name)
      r.cb.tfuCat = c.name
      r.cb:SetChecked(c.enabled)
      r.cb:SetScript("OnClick", function(self)
        TFuBag:SetCategoryEnabled(self.tfuCat, self:GetChecked() and true or false)
      end)
      r.del:ClearAllPoints(); r.del:SetPoint("TOPLEFT", child, "TOPLEFT", listW - 90, yoff)
      r.del.tfuCat = c.name
      r.del:SetScript("OnClick", function(self)
        StaticPopup_Show("TBAG_DELETE_CATEGORY", self.tfuCat, nil,
          { name = self.tfuCat, after = rebuildList })
      end)
      r.cb:Show(); r.fs:Show(); r.del:Show()
    end
    for i = #cats + 1, #pool do
      pool[i].cb:Hide(); pool[i].del:Hide()
    end
    -- Pinned catch-all row (read-only): UNKNOWN is the hardcoded fallback applied only
    -- when no rule matches, so it can't be disabled, deleted, or reordered -- always last.
    if (not unsortedRow) then
      unsortedRow = CreateFrame("CheckButton", nil, child, "UICheckButtonTemplate")
      unsortedRow:SetSize(22, 22)
      unsortedRow:SetChecked(true); unsortedRow:Disable()
      local fs = unsortedRow:CreateFontString(nil, "ARTWORK", "GameFontDisable")
      fs:SetPoint("LEFT", unsortedRow, "RIGHT", 4, 0)
      fs:SetText((L["UNKNOWN"] or "Unsorted") .. "  (catch-all \226\128\148 always last)")
    end
    unsortedRow:ClearAllPoints()
    unsortedRow:SetPoint("TOPLEFT", child, "TOPLEFT", 4, -(#cats * rowH) - 2)
    unsortedRow:Show()
    child:SetHeight(math.max(listH, (#cats + 1) * rowH + 8))
  end

  rebuildList()
  sfl.tfuRefresh = rebuildList
end)

MO:RegisterSection("grouping", "Grouping", function(sf, MO)
  local function track(c) sf.controls[#sf.controls + 1] = c; return c end

  -- Build the shared target list once: each material category + Trade Goods.
  local targets = {}
  for _, m in ipairs(TFuBag.MATERIAL_SUBTYPES) do
    targets[#targets + 1] = { text = m.cat, value = m.cat }
  end
  targets[#targets + 1] = { text = "Trade Goods", value = L["TRADE_GOODS"] }

  local y = 8  -- the content-title (top) already shows "Grouping"
  MO:Label(sf, y, "Point several materials at the same group to merge them onto one bar.")
  y = y + 22

  -- Presets.
  local b1 = MO:Button(sf, y, "All Separate", 110, function()
    TFuBag:ApplyGroupPreset("separate"); MO:ShowSection("grouping")
  end)
  track(b1)
  local b2 = CreateFrame("Button", nil, sf, "UIPanelButtonTemplate")
  b2:SetPoint("TOPLEFT", sf, "TOPLEFT", PAD + 120, -y)
  b2:SetSize(140, 22)
  b2:SetText("All in One Bar")
  b2:SetScript("OnClick", function()
    TFuBag:ApplyGroupPreset("onebar"); MO:ShowSection("grouping")
  end)
  track(b2)
  y = y + 22 + ROW_GAP + 6

  -- Per-material group dropdowns, two columns of six.
  local colX = { PAD, PAD + 280 }
  local colY = { y, y }
  for i, m in ipairs(TFuBag.MATERIAL_SUBTYPES) do
    local col = (i <= 6) and 1 or 2
    local sub = m.sub
    local dd, ny = MO:Dropdown(sf, colY[col], sub, 170, targets,
      function() return TFuBag:GetMaterialGroup(sub) end,
      function(v) TFuBag:SetMaterialGroup(sub, v) end,
      colX[col])
    track(dd)
    colY[col] = ny
  end
end)

MO:RegisterSection("filters", "Filters", function(sf, MO)
  local function track(c) sf.controls[#sf.controls + 1] = c; return c end
  local y = 8  -- the content-title (top) already shows "Filters"
  MO:Label(sf, y, "Apply loads a saved filter into both windows. Live filtering and")
  y = y + 16
  MO:Label(sf, y, "'Save current filter as...' live on the funnel button in each window.")
  y = y + 22

  local listW, listH, rowH = 520, 320, 26
  local sfl, child = MO:ScrollList(sf, PAD, y, listW, listH)
  track(sfl)

  local empty = child:CreateFontString(nil, "ARTWORK", "GameFontDisable")
  empty:SetPoint("TOPLEFT", child, "TOPLEFT", 8, -8)
  empty:SetText("No saved filters yet \226\128\148 use the funnel button \226\134\146 Save current filter as...")

  local pool = {}
  local rebuild
  local function getRow(i)
    local r = pool[i]
    if (not r) then
      r = {}
      r.fs = child:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
      r.apply = CreateFrame("Button", nil, child, "UIPanelButtonTemplate")
      r.apply:SetSize(60, 20); r.apply:SetText("Apply")
      r.del = CreateFrame("Button", nil, child, "UIPanelButtonTemplate")
      r.del:SetSize(60, 20); r.del:SetText("Delete")
      pool[i] = r
    end
    return r
  end

  rebuild = function()
    local list = TFuBag:GetUserFilters()
    empty:SetShown(#list == 0)
    for i, e in ipairs(list) do
      local r = getRow(i)
      local yoff = -((i - 1) * rowH) - 4
      r.fs:ClearAllPoints(); r.fs:SetPoint("TOPLEFT", child, "TOPLEFT", 6, yoff - 3)
      r.fs:SetText(e.name)
      r.apply:ClearAllPoints(); r.apply:SetPoint("TOPLEFT", child, "TOPLEFT", listW - 200, yoff)
      r.apply.entry = e
      r.apply:SetScript("OnClick", function(self)
        if (TFuInvFrame) then TFuBag:ApplyUserFilter(TFuInvFrame, self.entry) end
        if (TFuBnkFrame) then TFuBag:ApplyUserFilter(TFuBnkFrame, self.entry) end
      end)
      r.del:ClearAllPoints(); r.del:SetPoint("TOPLEFT", child, "TOPLEFT", listW - 130, yoff)
      r.del.fname = e.name
      r.del:SetScript("OnClick", function(self)
        TFuBag:DeleteUserFilter(self.fname); rebuild()
      end)
      r.fs:Show(); r.apply:Show(); r.del:Show()
    end
    for i = #list + 1, #pool do
      pool[i].fs:Hide(); pool[i].apply:Hide(); pool[i].del:Hide()
    end
    child:SetHeight(math.max(listH, #list * rowH + 12))
  end

  rebuild()
  sfl.tfuRefresh = rebuild
end)

-- Temporary opener for testing the new UI before the swap.
SLASH_TFUMODOPT1 = "/tbmodopts"
SlashCmdList["TFUMODOPT"] = function() TFuBag.ModernOpt:Toggle() end
