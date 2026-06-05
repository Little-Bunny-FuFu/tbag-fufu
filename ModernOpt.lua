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
  -- No template value label -- an editable box (below) shows AND sets the value.
  local fmt = {}

  -- Editable value field to the right of the track: type a number + Enter to set the
  -- value directly (clamped to range, snapped to step). Reflects drags live.
  local eb = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
  eb:SetAutoFocus(false)
  eb:SetNumeric(true)
  eb:SetMaxLetters(5)
  eb:SetJustifyH("CENTER")
  eb:SetSize(46, 18)
  eb:SetPoint("LEFT", sl, "RIGHT", 14, 0)

  local applying = false
  local function snap(v)
    if (not v) then return nil end
    if (v < minV) then v = minV elseif (v > maxV) then v = maxV end
    return minV + math.floor((v - minV) / step + 0.5) * step
  end
  local function showBox(v) eb:SetText(tostring(v)); eb:SetCursorPosition(0) end

  sl:Init(get(), minV, maxV, steps, fmt)
  showBox(get())
  sl:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged, function(_, value)
    if (applying) then return end
    set(value)
    showBox(value)
  end, parent)
  eb:SetScript("OnEnterPressed", function(self)
    local v = snap(tonumber(self:GetText()))
    if (v) then
      applying = true
      set(v)
      sl:Init(v, minV, maxV, steps, fmt)  -- move the slider to the typed value
      applying = false
      showBox(v)
    else
      showBox(get())  -- invalid: revert to current
    end
    self:ClearFocus()
  end)
  eb:SetScript("OnEscapePressed", function(self) showBox(get()); self:ClearFocus() end)

  sl.tfuRefresh = function() sl:Init(get(), minV, maxV, steps, fmt); showBox(get()) end
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

-- Single-line text field with a left label. get() -> string, set(string) on commit
-- (Enter or focus loss); Escape reverts to the stored value. maxLetters caps input.
function MO:EditBox(parent, y, label, maxLetters, width, get, set)
  local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  fs:SetPoint("TOPLEFT", parent, "TOPLEFT", PAD, -(y + 4))
  fs:SetText(label)

  local eb = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
  eb:SetAutoFocus(false)
  eb:SetSize(width or 90, 20)
  eb:SetPoint("TOPLEFT", parent, "TOPLEFT", PAD + 220, -y)
  if (maxLetters and maxLetters > 0) then eb:SetMaxLetters(maxLetters) end
  eb:SetText(get() or "")
  eb:SetCursorPosition(0)
  local function commit() set(eb:GetText() or "") end
  eb:SetScript("OnEnterPressed", function(self) commit(); self:ClearFocus() end)
  eb:SetScript("OnEscapePressed", function(self) self:SetText(get() or ""); self:ClearFocus() end)
  eb:SetScript("OnEditFocusLost", function() commit() end)
  eb.tfuRefresh = function() eb:SetText(get() or ""); eb:SetCursorPosition(0) end
  return eb, y + 24 + ROW_GAP
end

-- Inventory | Bank target toggle for the Categories / Grouping / Armor panels.
-- Reflects the shared TFuBag.optTarget; the selected window's button is disabled.
-- onSwitch() runs after the target changes (rebuild/refresh the section). Returns
-- the sync closure so callers can register it for re-sync on section show.
function MO:WindowToggle(parent, y, onSwitch)
  local invBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  invBtn:SetSize(90, 20); invBtn:SetText("Inventory")
  invBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", PAD, -y)
  local bankBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  bankBtn:SetSize(90, 20); bankBtn:SetText("Bank")
  bankBtn:SetPoint("LEFT", invBtn, "RIGHT", 6, 0)
  local function sync()
    local hasBank = (TFuBnkFrame and TFuBnkFrame.cfg ~= nil)
    if (TFuBag.optTarget == "bank" and not hasBank) then TFuBag:SetOptTarget("inv") end
    local bank = (TFuBag.optTarget == "bank")
    invBtn:SetEnabled(bank)
    bankBtn:SetEnabled(not bank and hasBank)
  end
  invBtn:SetScript("OnClick", function() TFuBag:SetOptTarget("inv"); sync(); if (onSwitch) then onSwitch() end end)
  bankBtn:SetScript("OnClick", function() TFuBag:SetOptTarget("bank"); sync(); if (onSwitch) then onSwitch() end end)
  sync()
  return invBtn, bankBtn, sync
end

-- Scrollable list region (classic ScrollFrameTemplate: built-in scrollbar + mouse wheel).
-- Returns (scrollFrame, scrollChild). Callers lay rows out top-down in the child and set
-- child:SetHeight(totalContentHeight) to enable scrolling. width/height size the viewport.
function MO:ScrollList(parent, x, y, width, height)
  local sf = CreateFrame("ScrollFrame", nil, parent, "ScrollFrameTemplate")
  sf:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
  -- ScrollFrameTemplate anchors its scrollbar ~22px to the RIGHT of the frame, so a
  -- list sized to the full panel width pushes the bar outside the window. Clamp the
  -- width to leave room for the bar inside the parent (skipped if the parent isn't
  -- measured yet -- the explicit width then stands).
  local pw = parent:GetWidth()
  if (pw and pw > 0) then
    local maxW = pw - x - 26
    if (maxW > 0 and width > maxW) then width = maxW end
  end
  -- Clamp the height so the list never butts against the panel bottom: leave a slight
  -- gap below it (matches the other sections). Skipped if the parent isn't measured yet.
  local ph = parent:GetHeight()
  if (ph and ph > 0) then
    local maxH = ph - y - 12
    if (maxH > 0 and height > maxH) then height = maxH end
  end
  sf:SetSize(width, height)
  -- Rounded backdrop so the list region reads as a distinct panel with soft corners.
  -- A BackdropTemplate frame BEHIND the scroll frame (extended right to cover the
  -- scrollbar column), one level below sf so the list content + bar render on top.
  local bg = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  bg:SetFrameLevel(parent:GetFrameLevel())
  bg:SetPoint("TOPLEFT", sf, "TOPLEFT", -4, 4)
  bg:SetPoint("BOTTOMRIGHT", sf, "BOTTOMRIGHT", 22, -4)
  bg:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 14,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
  })
  bg:SetBackdropColor(0, 0, 0, 0.30)
  bg:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.7)
  -- Center the scrollbar in the right gutter with top/bottom margins, so it does not
  -- butt the rounded top/bottom corners (the template anchors it flush to the top).
  local sbar = sf.ScrollBar
  if (sbar) then
    sbar:ClearAllPoints()
    sbar:SetPoint("TOP", sf, "TOPRIGHT", 11, -18)
    sbar:SetPoint("BOTTOM", sf, "BOTTOMRIGHT", 11, 18)
  end
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

  -- Vertical divider between the nav column and the content panel (two-pane look).
  local vdiv = f:CreateTexture(nil, "ARTWORK")
  vdiv:SetColorTexture(0.5, 0.5, 0.5, 0.35)
  vdiv:SetWidth(1)
  vdiv:SetPoint("TOPLEFT", f, "TOPLEFT", NAV_WIDTH + 11, -32)
  vdiv:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", NAV_WIDTH + 11, 14)

  -- Thin rule under the section title, separating it from the controls below.
  local trule = content:CreateTexture(nil, "ARTWORK")
  trule:SetColorTexture(0.5, 0.5, 0.5, 0.35)
  trule:SetHeight(1)
  trule:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, -24)
  trule:SetPoint("TOPRIGHT", content, "TOPRIGHT", -4, -24)

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
  -- Also point the per-window Categories/Grouping/Armor panels at the originating
  -- window, so opening Options from the bank edits the bank's config.
  if (which) then TFuBag:SetOptTarget(which) end
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
  local function edit(label, key, maxlen, apply)
    local c, ny = self:EditBox(child, yy, label, maxlen, 90,
      function() return cfg[key] end,
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
  chk("Hide Non-Matching Items During Search (off = dim them)", "search_hide")

  _, ny = self:Header(child, yy, "Behavior"); yy = ny
  chk("Auto Stack", "stack_auto")
  chk("Stack on Re-sort", "stack_resort")
  -- One toggle for the arrange mode. ON = drag-to-arrange (manual layout via the gear);
  -- OFF = legacy click editing. This is the legacy_edit flag inverted. The companion
  -- "Free Placement" box below (ml_freeplace) only makes sense while drag is on, so it
  -- is greyed when drag is off -- which is what prevents the old broken combo (a stale
  -- legacy_edit=1 silently breaking drag) rather than parking it on a separate panel.
  -- Manual-layout option chain: "Drag to arrange" (legacy_edit) is the top switch;
  -- "Use Manual Layout" (manual_layout) is meaningful only in drag mode; "Free
  -- Placement" (ml_freeplace) only when manual layout is active. Greying enforces this.
  local manualChk, freeplaceChk
  local function gateManual()
    local dragMode = (cfg.legacy_edit ~= 1)
    if (manualChk) then
      if (manualChk.SetEnabled) then manualChk:SetEnabled(dragMode) end
      manualChk:SetAlpha(dragMode and 1 or 0.4)
    end
    if (freeplaceChk) then
      local on = dragMode and (cfg.manual_layout == 1)
      if (freeplaceChk.SetEnabled) then freeplaceChk:SetEnabled(on) end
      freeplaceChk:SetAlpha(on and 1 or 0.4)
    end
  end
  do
    local c, ny = self:Checkbox(child, yy, "Drag to arrange categories (off = legacy click editing)",
      function() return cfg.legacy_edit ~= 1 end,
      function(v) cfg.legacy_edit = v and 0 or 1; gateManual(); force() end)
    track(c); yy = ny
  end
  do
    -- The gear toggles edit/unlock; this is the persistent on/off for whether the
    -- arranged layout is used at all. Turning it off returns to auto-flow and locks.
    local c, ny = self:Checkbox(child, yy, "Use Manual Layout (off = auto-arrange categories)",
      function() return cfg.manual_layout == 1 end,
      function(v)
        cfg.manual_layout = v and 1 or 0
        if (not v) then frame.ml_edit = 0 end  -- leaving manual layout: lock
        gateManual(); force()
      end)
    manualChk = c; track(c); yy = ny
  end
  do
    local c, ny = self:Checkbox(child, yy, "Free Placement within Manual Layout (off = snap to grid)",
      function() return cfg.ml_freeplace == 1 end,
      function(v) cfg.ml_freeplace = v and 1 or 0; force() end)
    freeplaceChk = c; track(c); yy = ny
  end
  gateManual()
  track({ tfuRefresh = gateManual })  -- re-grey whenever the panel is shown
  chk("Profession Bags precede Sorting", "special_bag_sort")
  chk("Split Reagents by Profession (original TBag style)", "reagent_split")
  chk("Trade Creation precedes Sorting (reopen window)", "trade_created_sort")

  if (frame == TFuInvFrame) then
    chk("Alt Key Auto-Pickup", "alt_pickup")
    chk("Alt Key Auto-Panel", "alt_panel")
  end

  -- New-item tag text + timeouts (the tag shown on items picked up since last view).
  -- TAG_MAX (legacy) was 10 chars; inlined here so this does not depend on TBagOpt.lua.
  _, ny = self:Header(child, yy, "New Item Tags"); yy = ny
  edit("New Tag Text", TFuBag.V_NEWON, 10)
  edit("Increased Tag Text", TFuBag.V_NEWPLUS, 10)
  edit("Decreased Tag Text", TFuBag.V_NEWMINUS, 10)
  sld("New Tag Timeout (minutes)", "newItemTimeout", 0, 24 * 60, 15)
  sld("Recent Tag Timeout (minutes)", "recentTimeout", 0, 60, 5)

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

  -- Inventory | Bank target toggle (categories are per-window). Sits above both
  -- sub-views; switching rebuilds the list for the newly selected window.
  local _, _, syncTgl = MO:WindowToggle(sf, 6, function() MO:ShowSection("categories") end)
  track({ tfuRefresh = syncTgl })

  -- Two stacked sub-frames filling the content area BELOW the toggle: the category
  -- LIST view and the per-category rule EDIT view. Exactly one is shown at a time.
  local listView = CreateFrame("Frame", nil, sf); track(listView)
  listView:SetPoint("TOPLEFT", sf, "TOPLEFT", 0, -28)
  listView:SetPoint("BOTTOMRIGHT", sf, "BOTTOMRIGHT", 0, 0)
  local editView = CreateFrame("Frame", nil, sf); track(editView)
  editView:SetPoint("TOPLEFT", sf, "TOPLEFT", 0, -28)
  editView:SetPoint("BOTTOMRIGHT", sf, "BOTTOMRIGHT", 0, 0)
  editView:Hide()

  local rebuildList     -- forward decls
  local openEditor

  -- Compact one-line summary of a rule's match fields for the editor list.
  -- r = { [1]=name,[2]=keyword,[3]=tooltip,[4]=type,[5]=subtype,[6]=special }.
  local function fmtRule(r)
    local parts = {}
    if (r[3] ~= "") then parts[#parts + 1] = 'tip:"' .. r[3] .. '"' end
    if (r[4] ~= "") then parts[#parts + 1] = "type:" .. r[4] end
    if (r[5] ~= "") then parts[#parts + 1] = "sub:" .. r[5] end
    if (r[2] ~= "") then parts[#parts + 1] = "kw:" .. r[2] end
    local s = (#parts > 0) and table.concat(parts, "   ") or "(no match fields \226\128\148 inert)"
    if (r[6] == "ci") then s = s .. "  (ci)"
    elseif (r[6] == "psplit") then s = s .. "  (psplit)" end
    return s
  end

  ------------------------------------------------------------------ LIST VIEW
  do
    local y = 8  -- the content-title (top) already shows "Categories"
    MO:Label(listView, y, "Uncheck to disable a category; Edit to rename, reorder, or change its rules.")
    y = y + 16
    MO:Label(listView, y, "Delete removes it; Add makes a category from text found in the tooltip.")
    y = y + 24

    -- Add-category form: name + tooltip-match text + Add button (one row).
    local nameEB = CreateFrame("EditBox", nil, listView, "InputBoxTemplate")
    nameEB:SetSize(130, 20); nameEB:SetAutoFocus(false)
    nameEB:SetPoint("TOPLEFT", listView, "TOPLEFT", PAD + 6, -y)
    local nlab = listView:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    nlab:SetPoint("BOTTOMLEFT", nameEB, "TOPLEFT", -4, 2); nlab:SetText("New category")

    local matchEB = CreateFrame("EditBox", nil, listView, "InputBoxTemplate")
    matchEB:SetSize(180, 20); matchEB:SetAutoFocus(false)
    matchEB:SetPoint("LEFT", nameEB, "RIGHT", 16, 0)
    local mlab = listView:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    mlab:SetPoint("BOTTOMLEFT", matchEB, "TOPLEFT", -4, 2); mlab:SetText("Match text (in tooltip)")

    local addBtn = CreateFrame("Button", nil, listView, "UIPanelButtonTemplate")
    addBtn:SetSize(60, 22); addBtn:SetText("Add")
    addBtn:SetPoint("LEFT", matchEB, "RIGHT", 12, 0)
    addBtn:SetScript("OnClick", function()
      if (TFuBag:AddCategory(nameEB:GetText(), matchEB:GetText())) then
        nameEB:SetText(""); matchEB:SetText(""); nameEB:ClearFocus(); matchEB:ClearFocus()
        rebuildList()
      else
        UIErrorsFrame:AddMessage("Enter a category name and match text.", 1, 0.3, 0.3)
      end
    end)
    y = y + 30

    -- Scrollable list: checkbox + name + Edit + Delete per distinct category.
    local listW, listH, rowH = 520, 300, 24
    local sfl, child = MO:ScrollList(listView, PAD, y, listW, listH)

    -- Scroll the list so the row for `name` is visible (roughly centred). Used after a
    -- type-a-number move so the category doesn't appear to vanish when it jumps to a
    -- position outside the current scroll window. maxS is computed from the child height
    -- directly (GetVerticalScrollRange can lag a frame behind a rebuild).
    local function scrollToCat(name)
      local cats = TFuBag:GetCategoryList()
      local idx
      for i, c in ipairs(cats) do if (c.name == name) then idx = i; break end end
      if (not idx) then return end
      local s = (idx - 1) * rowH - (listH / 2) + rowH
      local maxS = math.max(0, child:GetHeight() - listH)
      if (s < 0) then s = 0 elseif (s > maxS) then s = maxS end
      sfl:SetVerticalScroll(s)
    end

    -- Move a category one step and scroll the list by one row in the same direction,
    -- so the moved category stays under the cursor and repeated clicks walk it through
    -- the list (otherwise the swapped neighbour slides under the stationary cursor and
    -- the next click moves it back).
    local function nudge(name, dir)
      if (not name) then return end
      local before = sfl:GetVerticalScroll()
      if (TFuBag:MoveCategory(name, dir)) then
        rebuildList()
        local s = before + dir * rowH
        local maxS = sfl:GetVerticalScrollRange()
        if (s < 0) then s = 0 elseif (s > maxS) then s = maxS end
        sfl:SetVerticalScroll(s)
      end
    end

    local pool = {}
    local unsortedRow   -- pinned catch-all row, created lazily below
    local function getRow(i)
      local r = pool[i]
      if (not r) then
        r = {}
        -- Editable priority number: type a new position + Enter to move the category
        -- there (everything below renumbers); the up/down arrows nudge it one step.
        r.num = CreateFrame("EditBox", nil, child, "InputBoxTemplate")
        r.num:SetSize(30, 20); r.num:SetAutoFocus(false)
        r.num:SetNumeric(true); r.num:SetMaxLetters(3); r.num:SetJustifyH("CENTER")
        r.num:SetScript("OnEscapePressed", function(self) self:ClearFocus(); rebuildList() end)
        r.num:SetScript("OnEnterPressed", function(self)
          local n = tonumber(self:GetText())
          local cat = r.tfuCat
          self:ClearFocus()
          if (n and cat) then TFuBag:MoveCategoryToPosition(cat, n) end
          rebuildList()
          if (cat) then scrollToCat(cat) end  -- reveal it at its new position
        end)
        r.cb = CreateFrame("CheckButton", nil, child, "UICheckButtonTemplate")
        r.cb:SetSize(22, 22)
        r.fs = r.cb:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        r.fs:SetPoint("LEFT", r.cb, "RIGHT", 4, 0)
        r.fs:SetWidth(listW - 310); r.fs:SetJustifyH("LEFT")
        -- Scroll-arrow templates carry real up/down arrow art (the plain button font
        -- has no glyph for the triangle characters, so they rendered blank).
        r.up = CreateFrame("Button", nil, child, "UIPanelScrollUpButtonTemplate")
        r.up:SetSize(24, 24)
        r.up:SetScript("OnClick", function() nudge(r.tfuCat, -1) end)
        r.down = CreateFrame("Button", nil, child, "UIPanelScrollDownButtonTemplate")
        r.down:SetSize(24, 24)
        r.down:SetScript("OnClick", function() nudge(r.tfuCat, 1) end)
        r.edit = CreateFrame("Button", nil, child, "UIPanelButtonTemplate")
        r.edit:SetSize(44, 20); r.edit:SetText("Edit")
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
        r.tfuCat = c.name
        r.num:ClearAllPoints(); r.num:SetPoint("TOPLEFT", child, "TOPLEFT", 8, yoff - 1)
        r.num:SetText(tostring(i)); r.num:SetCursorPosition(0)
        r.cb:ClearAllPoints(); r.cb:SetPoint("TOPLEFT", child, "TOPLEFT", 44, yoff)
        r.fs:SetText(c.name)
        r.cb.tfuCat = c.name
        r.cb:SetChecked(c.enabled)
        r.cb:SetScript("OnClick", function(self)
          TFuBag:SetCategoryEnabled(self.tfuCat, self:GetChecked() and true or false)
        end)
        r.up:ClearAllPoints();   r.up:SetPoint("TOPLEFT", child, "TOPLEFT", listW - 206, yoff)
        r.down:ClearAllPoints(); r.down:SetPoint("TOPLEFT", child, "TOPLEFT", listW - 180, yoff)
        r.edit:ClearAllPoints(); r.edit:SetPoint("TOPLEFT", child, "TOPLEFT", listW - 150, yoff)
        r.edit.tfuCat = c.name
        r.edit:SetScript("OnClick", function(self) openEditor(self.tfuCat) end)
        r.del:ClearAllPoints(); r.del:SetPoint("TOPLEFT", child, "TOPLEFT", listW - 90, yoff)
        r.del.tfuCat = c.name
        r.del:SetScript("OnClick", function(self)
          StaticPopup_Show("TBAG_DELETE_CATEGORY", self.tfuCat, nil,
            { name = self.tfuCat, after = rebuildList })
        end)
        r.num:Show(); r.cb:Show(); r.fs:Show(); r.up:Show(); r.down:Show(); r.edit:Show(); r.del:Show()
      end
      for i = #cats + 1, #pool do
        pool[i].num:Hide(); pool[i].cb:Hide(); pool[i].up:Hide()
        pool[i].down:Hide(); pool[i].edit:Hide(); pool[i].del:Hide()
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
  end

  ------------------------------------------------------------------ EDIT VIEW
  local curName              -- category currently being edited
  local editingIdx           -- rule index open in the field editor (nil = closed)
  local rebuildEditor        -- forward decl (reorder / rule changes refresh it)

  -- Header row: Back (left). Priority reorder lives on the main category list.
  local backBtn = CreateFrame("Button", nil, editView, "UIPanelButtonTemplate")
  backBtn:SetSize(70, 22); backBtn:SetText("< Back")
  backBtn:SetPoint("TOPLEFT", editView, "TOPLEFT", PAD, -4)
  backBtn:SetScript("OnClick", function()
    editView:Hide(); rebuildList(); listView:Show()
  end)

  -- Category title + rename row.
  local titleFS = editView:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  titleFS:SetPoint("TOPLEFT", editView, "TOPLEFT", PAD, -34)

  local nameLbl = editView:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
  nameLbl:SetPoint("TOPLEFT", editView, "TOPLEFT", PAD + 6, -58)
  nameLbl:SetText("Rename category")
  local renameEB = CreateFrame("EditBox", nil, editView, "InputBoxTemplate")
  renameEB:SetSize(180, 20); renameEB:SetAutoFocus(false)
  renameEB:SetPoint("TOPLEFT", editView, "TOPLEFT", PAD + 6, -72)
  local renameBtn = CreateFrame("Button", nil, editView, "UIPanelButtonTemplate")
  renameBtn:SetSize(70, 22); renameBtn:SetText("Rename")
  renameBtn:SetPoint("LEFT", renameEB, "RIGHT", 10, 1)
  renameBtn:SetScript("OnClick", function()
    local newName = renameEB:GetText()
    if (TFuBag:RenameCategory(curName, newName)) then
      curName = strtrim(newName); renameEB:ClearFocus(); rebuildEditor()
    else
      UIErrorsFrame:AddMessage("Rename failed: name is blank, unchanged, or already in use.", 1, 0.3, 0.3)
    end
  end)

  local rulesLbl = editView:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  rulesLbl:SetPoint("TOPLEFT", editView, "TOPLEFT", PAD, -102)
  rulesLbl:SetText("Match rules (first match wins; all route items to this category):")

  -- Scrollable rule list.
  local rlW, rlH, rrowH = 510, 150, 24
  local rsf, rchild = MO:ScrollList(editView, PAD, 120, rlW, rlH)

  local addRuleBtn = CreateFrame("Button", nil, editView, "UIPanelButtonTemplate")
  addRuleBtn:SetSize(90, 22); addRuleBtn:SetText("+ Add rule")
  addRuleBtn:SetPoint("TOPLEFT", editView, "TOPLEFT", PAD, -(120 + rlH + 8))

  -- Rule field editor (hidden until a rule's Edit is clicked).
  local fe = CreateFrame("Frame", nil, editView)
  fe:SetPoint("TOPLEFT", editView, "TOPLEFT", PAD, -(120 + rlH + 38))
  fe:SetPoint("RIGHT", editView, "RIGHT", -PAD, 0)
  fe:SetHeight(110)
  fe:Hide()
  local feTitle = fe:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
  feTitle:SetPoint("TOPLEFT", fe, "TOPLEFT", 0, 0)
  feTitle:SetText("Edit rule (fill at least one match field):")

  local function field(label, x, yy, w)
    local lab = fe:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    lab:SetPoint("TOPLEFT", fe, "TOPLEFT", x, -yy)
    lab:SetText(label)
    local eb = CreateFrame("EditBox", nil, fe, "InputBoxTemplate")
    eb:SetSize(w, 20); eb:SetAutoFocus(false)
    eb:SetPoint("TOPLEFT", fe, "TOPLEFT", x + 6, -(yy + 14))
    return eb
  end
  local kwEB  = field("Keyword", 0,   18, 90)
  local ttEB  = field("Tooltip text", 130, 18, 320)
  local tyEB  = field("Item type", 0,   58, 130)
  local stEB  = field("Item subtype", 200, 58, 200)

  local ciChk = CreateFrame("CheckButton", nil, fe, "UICheckButtonTemplate")
  ciChk:SetSize(22, 22)
  ciChk:SetPoint("TOPLEFT", fe, "TOPLEFT", 0, -94)
  local ciLbl = ciChk:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  ciLbl:SetPoint("LEFT", ciChk, "RIGHT", 2, 0)
  ciLbl:SetText("Tooltip match is case-insensitive")

  local saveRuleBtn = CreateFrame("Button", nil, fe, "UIPanelButtonTemplate")
  saveRuleBtn:SetSize(70, 22); saveRuleBtn:SetText("Save")
  saveRuleBtn:SetPoint("TOPRIGHT", fe, "TOPRIGHT", -84, -92)
  local cancelRuleBtn = CreateFrame("Button", nil, fe, "UIPanelButtonTemplate")
  cancelRuleBtn:SetSize(70, 22); cancelRuleBtn:SetText("Cancel")
  cancelRuleBtn:SetPoint("LEFT", saveRuleBtn, "RIGHT", 8, 0)

  local function closeFieldEditor()
    editingIdx = nil; fe:Hide()
  end
  cancelRuleBtn:SetScript("OnClick", closeFieldEditor)
  saveRuleBtn:SetScript("OnClick", function()
    if (not editingIdx) then return end
    local ok = TFuBag:UpdateRule(editingIdx, curName,
      { kwEB:GetText(), ttEB:GetText(), tyEB:GetText(), stEB:GetText() },
      ciChk:GetChecked() and true or false)
    if (ok) then closeFieldEditor(); rebuildEditor()
    else UIErrorsFrame:AddMessage("Rule needs at least one match field (tooltip/type/subtype/keyword).", 1, 0.3, 0.3) end
  end)

  local function openFieldEditor(rule)
    editingIdx = rule.idx
    kwEB:SetText(rule[2]); ttEB:SetText(rule[3]); tyEB:SetText(rule[4]); stEB:SetText(rule[5])
    ciChk:SetChecked(rule[6] == "ci")
    feTitle:SetText("Edit rule " .. (rule[6] == "psplit" and "(profession split \226\128\148 case flag locked):" or ":"))
    fe:Show()
  end

  addRuleBtn:SetScript("OnClick", function()
    local newIdx = TFuBag:AddRuleToCategory(curName)
    if (newIdx) then
      rebuildEditor()
      -- open the field editor on the freshly added (inert) rule so the user fills it in
      for _, r in ipairs(TFuBag:GetCategoryRules(curName)) do
        if (r.idx == newIdx) then openFieldEditor(r); break end
      end
    end
  end)

  -- Rule-row pool for the editor list.
  local rpool = {}
  local function getRRow(i)
    local r = rpool[i]
    if (not r) then
      r = {}
      r.fs = rchild:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
      r.fs:SetPoint("TOPLEFT", rchild, "TOPLEFT", 4, 0)  -- repositioned per rebuild
      r.fs:SetWidth(rlW - 130); r.fs:SetJustifyH("LEFT")
      r.edit = CreateFrame("Button", nil, rchild, "UIPanelButtonTemplate")
      r.edit:SetSize(44, 20); r.edit:SetText("Edit")
      r.del = CreateFrame("Button", nil, rchild, "UIPanelButtonTemplate")
      r.del:SetSize(24, 20); r.del:SetText("X")
      rpool[i] = r
    end
    return r
  end

  rebuildEditor = function()
    titleFS:SetText('Editing category: "' .. (curName or "") .. '"')
    renameEB:SetText(curName or "")
    local rules = TFuBag:GetCategoryRules(curName)
    for i, rule in ipairs(rules) do
      local r = getRRow(i)
      local yoff = -((i - 1) * rrowH) - 2
      r.fs:ClearAllPoints(); r.fs:SetPoint("TOPLEFT", rchild, "TOPLEFT", 4, yoff)
      r.fs:SetText(fmtRule(rule))
      r.edit:ClearAllPoints(); r.edit:SetPoint("TOPLEFT", rchild, "TOPLEFT", rlW - 110, yoff)
      r.edit:SetScript("OnClick", function() openFieldEditor(rule) end)
      r.del:ClearAllPoints(); r.del:SetPoint("TOPLEFT", rchild, "TOPLEFT", rlW - 56, yoff)
      r.del:SetScript("OnClick", function()
        if (TFuBag:DeleteRule(rule.idx, curName)) then
          closeFieldEditor()
          if (#TFuBag:GetCategoryRules(curName) == 0) then
            -- category emptied (no rules left): drop back to the list
            editView:Hide(); rebuildList(); listView:Show()
          else
            rebuildEditor()
          end
        end
      end)
      r.fs:Show(); r.edit:Show(); r.del:Show()
    end
    for i = #rules + 1, #rpool do
      rpool[i].fs:Hide(); rpool[i].edit:Hide(); rpool[i].del:Hide()
    end
    rchild:SetHeight(math.max(rlH, #rules * rrowH + 8))
  end

  openEditor = function(name)
    curName = name
    closeFieldEditor()
    rebuildEditor()
    listView:Hide(); editView:Show()
  end

  rebuildList()
  -- On section re-show, always return to the list view (the editor's indices may be
  -- stale after other panels changed the rule list) and rebuild it. Attached to a
  -- TRACKED control (listView) because ShowSection only calls tfuRefresh on the
  -- frame's registered controls, not on the section frame itself.
  listView.tfuRefresh = function() closeFieldEditor(); editView:Hide(); listView:Show(); rebuildList() end
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
  local _, _, syncTgl = MO:WindowToggle(sf, y, function() MO:ShowSection("grouping") end)
  track({ tfuRefresh = syncTgl })
  y = y + 26
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

MO:RegisterSection("armor", "Armor", function(sf, MO)
  local function track(c) sf.controls[#sf.controls + 1] = c; return c end

  local y = 8  -- the content-title (top) already shows "Armor"
  local _, _, syncTgl = MO:WindowToggle(sf, y, function() MO:ShowSection("armor") end)
  track({ tfuRefresh = syncTgl })
  y = y + 26

  local enable = MO:Checkbox(sf, y, "Group armor by equip slot",
    function() return TFuBag:GetArmorGroupEnabled() end,
    function(v) TFuBag:SetArmorGroupEnabled(v) end)
  track(enable); y = y + 26 + ROW_GAP

  local split = MO:Checkbox(sf, y, "Separate by bind (BoE / Soulbound / Warbound)",
    function() return TFuBag:GetArmorBindSplit() end,
    function(v) TFuBag:SetArmorBindSplit(v) end)
  track(split); y = y + 26 + ROW_GAP

  MO:Label(sf, y, "Point several slots at the same group to merge them onto one bar.")
  y = y + 22

  -- Presets.
  local b1 = MO:Button(sf, y, "All Separate", 110, function()
    TFuBag:ApplyArmorPreset("separate"); MO:ShowSection("armor")
  end)
  track(b1)
  local b2 = CreateFrame("Button", nil, sf, "UIPanelButtonTemplate")
  b2:SetPoint("TOPLEFT", sf, "TOPLEFT", PAD + 120, -y)
  b2:SetSize(140, 22)
  b2:SetText("All in One Bar")
  b2:SetScript("OnClick", function()
    TFuBag:ApplyArmorPreset("onebar"); MO:ShowSection("armor")
  end)
  track(b2)
  y = y + 22 + ROW_GAP + 6

  -- Per-slot group dropdowns. 15 slots overflow the panel, so they live in a
  -- scroll region. Targets = every slot (merge onto another slot's group) plus a
  -- single combined "All Armor" bar.
  local targets = {}
  for _, m in ipairs(TFuBag.ARMOR_SLOTS) do
    targets[#targets + 1] = { text = m.label, value = m.sub }
  end
  targets[#targets + 1] = { text = "All Armor (one bar)", value = "ARMOR" }

  local listW, listH = 540, 300
  local sfl, child = MO:ScrollList(sf, PAD, y, listW, listH)
  track(sfl)

  local colX = { 6, 6 + 268 }
  local colY = { 6, 6 }
  for i, m in ipairs(TFuBag.ARMOR_SLOTS) do
    local col = (i <= 8) and 1 or 2
    local sub = m.sub
    local dd, ny = MO:Dropdown(child, colY[col], m.label, 170, targets,
      function() return TFuBag:GetArmorGroup(sub) end,
      function(v) TFuBag:SetArmorGroup(sub, v) end,
      colX[col])
    track(dd)
    colY[col] = ny
  end
  child:SetHeight(math.max(colY[1], colY[2]) + 8)
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

-- Confirm before deleting a profile (its saved settings are lost; a character that
-- used it falls back to "default" on next login). %s = profile name.
StaticPopupDialogs["TBAG_DELETE_PROFILE"] = {
  text = "Delete profile \"%s\"?\nIts saved window settings are removed. Any character using it falls back to the default profile on next login.",
  button1 = YES,
  button2 = NO,
  OnAccept = function(_, data)
    if (data and data.name) then TFuBag.Profiles.DeleteProfile(TFuBag.db, data.name) end
    if (data and data.after) then data.after() end
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
}

-- Profiles: switch between, create, and delete per-character config profiles. The
-- current profile shows in a label (it may be just-created and not yet persisted,
-- so it is not necessarily in profiles[]); the switch list includes it, delete
-- excludes it. Lists refresh on show and after every action via sf.controls.
MO:RegisterSection("profiles", "Profiles", function(sf, MO)
  local P  = TFuBag.Profiles
  local db = TFuBag.db
  if (not (P and db)) then
    MO:Label(sf, 8, "Profiles are not available."); return
  end
  local function track(c) sf.controls[#sf.controls + 1] = c; return c end
  local function refreshAll()
    for _, c in ipairs(sf.controls) do if (c.tfuRefresh) then c.tfuRefresh() end end
  end
  local function curName() return P.GetCurrentProfileName(db) or TFuBag.DEFAULT_PROFILE end

  local y = 8

  -- Current profile (refreshed on show / after any action).
  local curFS = sf:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  curFS:SetPoint("TOPLEFT", sf, "TOPLEFT", PAD, -y)
  curFS.tfuRefresh = function() curFS:SetText("Current profile:  |cffffd200" .. curName() .. "|r") end
  track(curFS)
  y = y + 20 + ROW_GAP

  -- Switch: lists every profile (plus the current even if not yet persisted).
  local switchOpts = {}
  local function fillSwitch()
    wipe(switchOpts)
    local sv, cur, seen, names = P.GetSavedVariables(db), curName(), {}, {}
    for name in pairs(sv.profiles) do seen[name] = true; names[#names + 1] = name end
    if (not seen[cur]) then names[#names + 1] = cur end
    table.sort(names)
    for _, n in ipairs(names) do switchOpts[#switchOpts + 1] = { text = n, value = n } end
  end
  fillSwitch()
  local switchDD
  switchDD, y = MO:Dropdown(sf, y, "Switch to:", 220, switchOpts,
    function() return curName() end,
    function(v) if (v ~= curName()) then P.SetProfile(db, v); refreshAll() end end)
  switchDD.tfuRefresh = function() fillSwitch(); switchDD:GenerateMenu() end
  track(switchDD)
  y = y + ROW_GAP

  -- Create a new profile (optionally cloning the current one), then switch to it.
  y = select(2, MO:Label(sf, y, "Create a new profile:"))
  local copyFrom = true
  y = select(2, MO:Checkbox(sf, y, "Copy the current profile's settings into the new one",
    function() return copyFrom end, function(v) copyFrom = v end))
  local nameEB
  nameEB, y = MO:EditBox(sf, y, "Name:", 40, 200, function() return "" end, function() end)
  y = select(2, MO:Button(sf, y, "Create + switch", 160, function()
    local name = strtrim(nameEB:GetText() or "")
    if (name ~= "") then
      P.SetProfile(db, name, copyFrom)
      nameEB:SetText("")
      refreshAll()
    end
  end))
  y = y + ROW_GAP

  -- Delete a profile (never the one in use; confirmed).
  y = select(2, MO:Label(sf, y, "Delete a profile:"))
  local selectedToDelete
  local deleteOpts = {}
  local function fillDelete()
    wipe(deleteOpts)
    local sv, cur, valid = P.GetSavedVariables(db), curName(), false
    local names = {}
    for name in pairs(sv.profiles) do if (name ~= cur) then names[#names + 1] = name end end
    table.sort(names)
    for _, n in ipairs(names) do
      deleteOpts[#deleteOpts + 1] = { text = n, value = n }
      if (n == selectedToDelete) then valid = true end
    end
    if (not valid) then selectedToDelete = nil end
  end
  fillDelete()
  local deleteDD
  deleteDD, y = MO:Dropdown(sf, y, "Delete profile:", 220, deleteOpts,
    function() return selectedToDelete end,
    function(v) selectedToDelete = v; deleteDD:GenerateMenu() end)
  deleteDD.tfuRefresh = function() fillDelete(); deleteDD:GenerateMenu() end
  track(deleteDD)
  y = select(2, MO:Button(sf, y, "Delete selected", 160, function()
    if (selectedToDelete) then
      StaticPopup_Show("TBAG_DELETE_PROFILE", selectedToDelete, nil,
        { name = selectedToDelete, after = refreshAll })
    end
  end))
  y = y + ROW_GAP

  -- Help note.
  local note = sf:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
  note:SetPoint("TOPLEFT", sf, "TOPLEFT", PAD, -y)
  note:SetWidth(470)
  note:SetJustifyH("LEFT")
  note:SetText("Each character remembers which profile it uses. Window layout, columns, "
    .. "categories, colours and behaviour are per profile; the profession / reagent "
    .. "database and saved searches are shared across all profiles.")
end)

-- Temporary opener for testing the new UI before the swap.
SLASH_TFUMODOPT1 = "/tbmodopts"
SlashCmdList["TFUMODOPT"] = function() TFuBag.ModernOpt:Toggle() end
