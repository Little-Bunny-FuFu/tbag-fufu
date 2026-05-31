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

  -- Left nav column.
  local nav = CreateFrame("Frame", nil, f)
  nav:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -28)
  nav:SetSize(NAV_WIDTH, WIN_H - 60)
  self.nav = nav

  -- Content panel (right of nav).
  local content = CreateFrame("Frame", nil, f)
  content:SetPoint("TOPLEFT", nav, "TOPRIGHT", 8, 0)
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

-----------------------------------------------------------------------
-- Proof-of-concept "General" section (smoke test of the controls).
-- Ports a few inventory settings so the modern look can be validated in-game
-- before the full section build-out. Uses TFuInvFrame.cfg.
-----------------------------------------------------------------------

MO:RegisterSection("general", "General", function(sf, MO)
  local cfg = TFuInvFrame and TFuInvFrame.cfg
  local function track(c) sf.controls[#sf.controls + 1] = c; return c end
  local y = 8

  if (not cfg) then
    MO:Label(sf, y, "Inventory window not initialised yet."); return
  end

  local _, ny = MO:Header(sf, y, "Inventory \226\128\148 General"); y = ny

  local sc; sc, ny = MO:Slider(sf, y, "Window Scale", 10, 100, 5,
    function() return math.floor((cfg.scale or 1) * 100 + 0.5) end,
    function(v) cfg.scale = v / 100; TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST) end)
  track(sc); y = ny

  local col; col, ny = MO:Slider(sf, y, "Item Columns", TFuBag.NUMCOL_MIN or 1, TFuBag.NUMCOL_MAX or 20, 1,
    function() return cfg.maxColumns or 8 end,
    function(v) cfg.maxColumns = v; TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST) end)
  track(col); y = ny

  local cb; cb, ny = MO:Checkbox(sf, y, "Collapse empty slots into one cell",
    function() return cfg.collapse_empty == 1 end,
    function(v) cfg.collapse_empty = v and 1 or 0; TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST) end)
  track(cb); y = ny

  local cb2; cb2, ny = MO:Checkbox(sf, y, "Show rarity color border",
    function() return cfg.show_rarity_color == 1 end,
    function(v) cfg.show_rarity_color = v and 1 or 0; TFuInvFrame:UpdateWindow(TFuBag.REQ_MUST) end)
  track(cb2); y = ny
end)

MO:RegisterSection("categories", "Categories", function(sf, MO)
  local function track(c) sf.controls[#sf.controls + 1] = c; return c end

  local _, y = MO:Header(sf, 8, "Enable / Disable Categories")
  MO:Label(sf, y, "Uncheck a category to turn off its sorting rules; its items then fall")
  y = y + 16
  MO:Label(sf, y, "back to plain item-type sorting. Applies to both bag and bank windows.")
  y = y + 20

  -- Scrollable checkbox list, one row per distinct category (first-occurrence order).
  local listW, listH, rowH = 520, 360, 24
  local sfl, child = MO:ScrollList(sf, PAD, y, listW, listH)
  track(sfl)

  local cats = TFuBag:GetCategoryList()
  local rows = {}
  for i, c in ipairs(cats) do
    local name = c.name
    local cb = CreateFrame("CheckButton", nil, child, "UICheckButtonTemplate")
    cb:SetSize(22, 22)
    cb:SetPoint("TOPLEFT", child, "TOPLEFT", 4, -((i - 1) * rowH))
    local fs = cb:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    fs:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    fs:SetText(name)
    cb:SetChecked(TFuBag:IsCategoryEnabled(name))
    cb:SetScript("OnClick", function(self)
      TFuBag:SetCategoryEnabled(name, self:GetChecked() and true or false)
    end)
    cb.tfuCat = name
    rows[#rows + 1] = cb
  end
  child:SetHeight(math.max(listH, #cats * rowH + 8))

  -- Re-sync every checkbox when the section is re-shown (e.g. after a /reset).
  sfl.tfuRefresh = function()
    for _, cb in ipairs(rows) do
      cb:SetChecked(TFuBag:IsCategoryEnabled(cb.tfuCat))
    end
  end
end)

MO:RegisterSection("grouping", "Grouping", function(sf, MO)
  local function track(c) sf.controls[#sf.controls + 1] = c; return c end

  -- Build the shared target list once: each material category + Trade Goods.
  local targets = {}
  for _, m in ipairs(TFuBag.MATERIAL_SUBTYPES) do
    targets[#targets + 1] = { text = m.cat, value = m.cat }
  end
  targets[#targets + 1] = { text = "Trade Goods", value = L["TRADE_GOODS"] }

  local _, y = MO:Header(sf, 8, "Material Grouping")
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
  local _, ny = MO:Header(sf, 8, "Filters")
  MO:Label(sf, ny, "Filter dimensions and saved-filter management land here next.")
end)

-- Temporary opener for testing the new UI before the swap.
SLASH_TFUMODOPT1 = "/tbmodopts"
SlashCmdList["TFUMODOPT"] = function() TFuBag.ModernOpt:Toggle() end
