-- $Id$
-- Implementation of the base templates for various buttons.

local _G = getfenv(0)
local TFuBag = _G.TFuBag
local L = TFuBag.LOCALE

-- Generic itembutton implementation
TFuBag.ItemButton = {}
local ItemButton = TFuBag.ItemButton

function ItemButton:OnEnter()
  local itm = TFuBag:GetItmFromFrame(TFuBag.BUTTONS, self)
  if not itm or not next(itm) then return end
  local mainFrame = TFuBag:GetButtonMainFrame(self)
  local bar, bag, slot = itm[TFuBag.I_BAR], itm[TFuBag.I_BAG], itm[TFuBag.I_SLOT]
  local cat, link = itm[TFuBag.I_CAT], itm[TFuBag.I_ITEMLINK]
  local charges = itm[TFuBag.I_CHARGES]
  local suffix = itm[TFuBag.I_LINKSUFFIX]
  local pet = link and link:sub(1,10) == "battlepet:"
  local isLive = TFuBag:IsLive(mainFrame)

  if mainFrame.edit_selected == "" then
    mainFrame.edit_hilight = cat
  end

  -- Tool Tip Anchor
  if self:GetLeft() < GetScreenWidth()/2 then
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  else
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
  end

  local hasCooldown, repairCost
  if not link then
    if mainFrame.edit_mode == 1 then
      GameTooltip:ClearLines()
      GameTooltip:AddLine(L["Empty Slot"], 1,1,1)
    else
      GameTooltip:Hide()
      return
    end
  else
    hasCooldown, repairCost = TFuBag:SetInventoryItem(GameTooltip, mainFrame.playerid,
                                                    link, bag, slot, suffix)
  end

  -- Set charges if remote viewing, Blizzard's code does it otherwise.
  if charges and not isLive then
    GameTooltip:AddLine(string.format(L["%d |4Charge:Charges;"], tonumber(charges)),
                        255,255,255,1)
    GameTooltip:Show()
  end

  if isLive then
    if InRepairMode() and (repairCost and repairCost > 0) then
      GameTooltip:AddLine(REPAIR_COST, 1, 1, 1)
      SetTooltipMoney(GameTooltip, repairCost)
      GameTooltip:Show()
    elseif MerchantFrame:IsVisible() then
      ShowContainerSellCursor(bag, slot)
    elseif itm[TFuBag.I_READABLE] then
      ShowInspectCursor()
    end
  end

  if IsModifiedClick("COMPAREITEMS") then
    GameTooltip_ShowCompareItem()
  end

  if pet then
    GameTooltip:SetOwner(BattlePetTooltip, "ANCHOR_BOTTOM")
  end

  if mainFrame.edit_mode == 1 then
    if cat then
      if mainFrame.edit_selected ~= "" then
        GameTooltip:AddLine(" ", 0,0,0)
        GameTooltip:AddLine(string.format(L["|c%sLeft click to move category |r|c%s%s|r|c%s to bar |r|c%s%s|r"],TFuBag.C_INST,TFuBag.C_CAT,mainFrame.edit_selected,TFuBag.C_INST,TFuBag.C_BAR,bar))
      else
        GameTooltip:AddLine(" ", 0,0,0)
        GameTooltip:AddLine(string.format(L["|c%sLeft click to select category to move:|r |c%s%s|r"],TFuBag.C_INST,TFuBag.C_CAT,cat))
        if link then
          GameTooltip:AddLine(L["Right click to assign this item to a different category"], 1,0,0)
        end
      end
    else
      GameTooltip:AddLine(" ", 0,0,0)
      GameTooltip:AddLine(L["Item has no category"], 1,0,0 )
    end
  end

  if mainFrame.cfg.spotlight_hover == 1 then
    local bagFrameSpot = TFuBag:GetBagFrameSpotlight(bag)
    -- 12.0 warband bank tabs have no per-tab selector/spotlight frame yet (Stage 2).
    if bagFrameSpot then
      local r, g, b, a = TFuBag:GetColor(mainFrame.cfg, "bag_"..bag)
      bagFrameSpot:SetVertexColor(r, g, b, a)
      bagFrameSpot:Show()
    end
  end

  if mainFrame.edit_mode == 1 then
    GameTooltip:Show()
    TFuBag:RefreshEditHighlight(mainFrame)
  end

end

-- Lightweight edit-mode category highlight: dim displayed item buttons that aren't in
-- the hovered/selected category (edit_hilight), full alpha for those that are. Used in
-- place of a full UpdateWindow on hover/leave -- the old code rebuilt the entire window
-- on every OnEnter/OnLeave, which made scrolling in edit mode lag badly on a large bank
-- (the cursor crosses many buttons). Skips work when the highlight hasn't changed.
function TFuBag:RefreshEditHighlight(mainFrame)
  if (mainFrame.edit_mode ~= 1) then return end
  local hl = mainFrame.edit_hilight or ""
  if (mainFrame._last_hilight == hl) then return end
  mainFrame._last_hilight = hl
  for buttonname, itm in pairs(self.BUTTONS) do
    if (itm and next(itm)) then
      local b = _G[buttonname]
      if (b and b:IsShown()) then
        b:SetAlpha((itm[self.I_CAT] ~= hl) and 0.25 or 1)
      end
    end
  end
end

function ItemButton:OnLeave()
  local itm = TFuBag:GetItmFromFrame(TFuBag.BUTTONS, self)
  local mainFrame = TFuBag:GetButtonMainFrame(self)

  if mainFrame.edit_selected == "" then
    mainFrame.edit_hilight = ""
  end

  if GameTooltip:IsOwned(self) then
    GameTooltip:Hide()
    BattlePetTooltip:Hide()
    ResetCursor()
  end

  -- itm[I_BAG] is nil for an empty-slot placeholder (the bank maps empties to {}, which
  -- is truthy but has no I_BAG); guard so GetBagFrameSpotlight isn't called with nil.
  if itm and itm[TFuBag.I_BAG] then
    local spotlight = TFuBag:GetBagFrameSpotlight(itm[TFuBag.I_BAG])
    if spotlight then spotlight:Hide() end
  end

  if mainFrame.edit_mode == 1 then
    TFuBag:RefreshEditHighlight(mainFrame)
  end
end

function ItemButton:OnClick(button)
  local itm = TFuBag:GetItmFromFrame(TFuBag.BUTTONS, self)
  if not itm or not next(itm) then return end
  local mainFrame = TFuBag:GetButtonMainFrame(self)
  if mainFrame.edit_mode ~= 1 then return end

  local bar, bag, slot = itm[TFuBag.I_BAR], itm[TFuBag.I_BAG], itm[TFuBag.I_SLOT]
  local cat = itm[TFuBag.I_CAT]

  if button == "LeftButton" then
    if (mainFrame.edit_selected == "") then
      -- you clicked, we selected
      mainFrame.edit_selected = cat
      mainFrame.edit_hilight = cat
    else
      -- we got a click, and we already had one selected.  let's move the items
      TFuBag:SetCatBar(mainFrame.cfg, mainFrame.edit_selected, bar, 1);

      mainFrame.edit_selected = "";
      mainFrame.edit_hilight = cat

      -- resort will force a window update
      mainFrame:UpdateWindow(TFuBag.REQ_MUST);
    end
  elseif ( button == "RightButton" ) then
    HideDropDownMenu(1);
    mainFrame.RightClickMenu_mode = "item";
    mainFrame.RightClickMenu_opts = {
      [TFuBag.I_BAR] = bar,
      [TFuBag.I_BAG] = bag,
      [TFuBag.I_SLOT] = slot
    };
    ToggleDropDownMenu(1, nil, mainFrame.RightClickMenu, self:GetName(), -50, 0);
  end
end

-- Pre-click hook. Runs BEFORE the inherited (secure) ContainerFrameItemButtonMixin
-- OnClick, which we deliberately do NOT replace: replacing it with an insecure Lua
-- <OnClick> put tbag on the call stack and tainted the protected
-- C_Container.UseContainerItem inside Blizzard's handler, so using a consumable
-- raised ADDON_ACTION_FORBIDDEN. The button keeps Blizzard's untainted OnClick for
-- use/pickup; this hook only adds our one extra behavior.
--
-- That behavior: a plain right-click deposit from the bags, while our bank window is
-- open at the bank, must follow the bank view WE are showing. Blizzard's default
-- deposits to whichever bank its own (replaced) UI thinks is active -- which lands
-- character-bank items in the warband bank, especially with collapse off. We redirect
-- to the currently-viewed bank via the SortItmCache free-slot target. PickupContainerItem
-- and DepositToFreeSlot are unprotected (taint-safe); the deposit empties the clicked
-- slot, so the inherited OnClick that fires next is a no-op on that now-empty slot.
function ItemButton.PreClick(self, button)
  if (button == "RightButton"
      and not (IsShiftKeyDown() or IsControlKeyDown() or IsAltKeyDown())
      and TFuBnkFrame and TFuBnkFrame:IsShown()
      and TFuBag:IsLive(TFuBnkFrame)
      and TFuBnkFrame.dropBag and TFuBnkFrame.dropSlot) then
    local mainFrame = TFuBag:GetButtonMainFrame(self)
    if (mainFrame == TFuInvFrame) then
      local itm = TFuBag:GetItmFromFrame(TFuBag.BUTTONS, self)
      if (itm and next(itm) and itm[TFuBag.I_ITEMLINK]) then
        PickupContainerItem(itm[TFuBag.I_BAG], itm[TFuBag.I_SLOT])
        TFuBag:DepositToFreeSlot(TFuBnkFrame)   -- routes to the VIEWED bank
      end
    end
  end
end

-- Handles lock updates.  Takes an itm and mainFrame parameter
-- which allows it to short circuit getting the frames itm and mainFrame
-- such as when it is called from ItemButton.Update.
-- Dramatic dark wash over the whole button for deposit-ineligible items (mirrors
-- Blizzard's bag "item context" dim: a ~0.8 black overlay), so ineligible vs eligible is
-- obvious -- icon desaturation alone was too subtle. The overlay sits on ARTWORK (above
-- the icon, below the OVERLAY-layer count/stock text) so the stack count stays readable.
function ItemButton.SetDepositDim(self, on)
  local ov = self.tfuDimOverlay
  if (not ov) then
    if (not on) then return end
    ov = self:CreateTexture(nil, "ARTWORK", nil, 7)
    ov:SetColorTexture(0, 0, 0, 0.8)
    ov:SetAllPoints(self)
    self.tfuDimOverlay = ov
  end
  ov:SetShown(on and true or false)
end

-- Subtle grey wash over poor-quality ("junk" / vendor-trash) items, so their throwaway
-- status reads at a glance even away from a merchant (the JunkIcon coin only appears at a
-- vendor). Light alpha on ARTWORK sublayer 6 -- below the deposit dim (sublayer 7) so a
-- black wash wins when an item is BOTH junk and deposit-ineligible, and below the
-- OVERLAY-layer count/stock text so the stack count stays readable. A pooled button reused
-- for a non-junk item clears it (ItemButton.Update calls this every refresh).
function ItemButton.SetJunkTint(self, on)
  local ov = self.tfuJunkTint
  if (not ov) then
    if (not on) then return end
    ov = self:CreateTexture(nil, "ARTWORK", nil, 6)
    ov:SetColorTexture(0.5, 0.5, 0.5, 0.4)
    ov:SetAllPoints(self)
    self.tfuJunkTint = ov
  end
  ov:SetShown(on and true or false)
end

function ItemButton.UpdateLock(self, itm, mainFrame)
  if not itm then itm = TFuBag:GetItmFromFrame(TFuBag.BUTTONS, self) end
  if not itm or not next(itm) then return end
  if not mainFrame then mainFrame = TFuBag:GetButtonMainFrame(self) end

  -- Another player's view never appears locked or deposit-dimmed. Clear BOTH the
  -- desaturation and the dim: SetItemButtonTexture (run in ItemButton.Update before
  -- this) does NOT reset SetDesaturated, so a button greyscaled while live would keep
  -- stale greyscale when re-rendered for a cached alt (dropdown switch) without this.
  -- Mirrors the bank-tab branch below.
  if not TFuBag:IsLive(mainFrame) then
    SetItemButtonDesaturated(self, false);
    TFuBag.ItemButton.SetDepositDim(self, false);
    return;
  end

  -- 12.0 bank tabs: GetContainerItemInfo reports items as "locked" when the warband
  -- bank is opened remotely (e.g. a distance inhibitor) -- greying already-deposited
  -- items even though they're fine. Bank tab items aren't mid-move in normal use, so
  -- never lock-desaturate them (matches the at-banker appearance, where locked=false).
  if TFuBag:IsBankTab(itm[TFuBag.I_BAG]) then
    SetItemButtonDesaturated(self, false);
    TFuBag.ItemButton.SetDepositDim(self, false);
    return;
  end

  local _,_,locked,_,_ = GetContainerItemInfo(itm[TFuBag.I_BAG],itm[TFuBag.I_SLOT])
  -- While a live bank session is open, dim bag items that can't go into the active bank
  -- type (e.g. soulbound gear when the Warband bank is open). Warbound-eligible items
  -- (reagents, flasks/potions/food/runes, warbound gear, etc.) stay full-colour. Restores
  -- the stock "deposit eligibility" shading our custom bag window otherwise loses.
  local ineligible = TFuBag:IsItemBankIneligible(itm[TFuBag.I_BAG], itm[TFuBag.I_SLOT])
  SetItemButtonDesaturated(self, (locked or ineligible) and true or false, 0.5, 0.5, 0.5);
  TFuBag.ItemButton.SetDepositDim(self, ineligible);
end

-- Crafting-quality tier badge (the small Tier 1/2/3 atlas Blizzard shows top-left on
-- reagents/crafted items with a profession quality). Blizzard's SetItemCraftingQualityOverlay
-- (Blizzard_ItemButton) does the work: it queries C_TradeSkillUI for the item's reagent/
-- crafted quality, lazily creates self.ProfessionQualityOverlay, sets the tier atlas, and
-- (via UpdateCraftedProfessionsQualityShown) shows reagent quality always + crafted-gear
-- quality when the professions UI is open -- exactly the default-bag behaviour. It manages
-- ONLY that badge, not the rarity border, so it leaves our own rarity colouring alone. We
-- hide a stale badge on non-quality items / empty slots so a pooled button can't keep one.
function ItemButton.UpdateQualityOverlay(self, itemlink)
  if (type(SetItemCraftingQualityOverlay) ~= "function") then return end
  SetItemCraftingQualityOverlay(self, itemlink)  -- itemlink nil for an empty slot -> isProfessionItem=false
  if (self.ProfessionQualityOverlay and not self.isProfessionItem) then
    self.ProfessionQualityOverlay:Hide()
  end
end

-- Handles cooldown updates.  Takes an itm and mainFrame paramenter
-- which allows it to short circuit getting the frames itm and mainFrame
-- such as when it is called from ItemButton.Update.
function ItemButton.UpdateCooldown(self, itm, mainFrame)
  local cooldownFrame = _G[self:GetName().."Cooldown"]
  if not cooldownFrame then return end
  if not itm then itm = TFuBag:GetItmFromFrame(TFuBag.BUTTONS, self) end
  if not itm or not next(itm) then return end
  if not mainFrame then mainFrame = TFuBag:GetButtonMainFrame(self) end
  local start, duration, enable = 0, 0, false

  if itm[TFuBag.I_ITEMLINK] and TFuBag:IsLive(mainFrame) then
    start, duration, enable = GetContainerItemCooldown(itm[TFuBag.I_BAG], itm[TFuBag.I_SLOT])
  end
  CooldownFrame_Set(cooldownFrame, start, duration, enable)
  cooldownFrame:SetScale(TFuBag.COOLDOWN_SCALE)
end

function ItemButton.Update(self)
  local mainFrame = TFuBag:GetButtonMainFrame(self)
  local cfg = mainFrame.cfg
  local playerid = mainFrame.playerid
  local hilight_new = mainFrame.hilight_new
  local itm = TFuBag:GetItmFromFrame(TFuBag.BUTTONS, self)
  -- Unmapped button: HIDE it (don't just bail) so it can't ghost at a stale spot.
  if not itm or not next(itm) then self:Hide(); return end
  local bag, slot = itm[TFuBag.I_BAG], itm[TFuBag.I_SLOT]
  local isEmptySlot = (not itm[TFuBag.I_ITEMLINK] or itm[TFuBag.I_ITEMLINK] == "")
  -- Empty slots are collected into the dedicated EMPTY_BAR and drawn as one "Empty" box
  -- at the bottom of the window (SortItmCache). collapse_empty OFF tiles every empty
  -- there (real per-slot buttons, shown as dim slot icons). collapse_empty ON shows only
  -- the single representative empty (mainFrame._emptyRep) with the free-slot count; every
  -- other empty button hides here (also kills emptied-slot ghosts when items move).
  if (isEmptySlot and cfg.collapse_empty == 1) then
    local rep = mainFrame._emptyRep
    if not (rep and rep.bag == bag and rep.slot == slot) then
      self:Hide(); return
    end
  end
  -- Item filter: when a filter is active, hide the items it excludes. SortItmCache
  -- already skipped them (no layout slot), so this also stops a filtered-out item
  -- from ghosting at its previous position when the always-run button pass would
  -- otherwise Show() it. (No-op when no filter is active: PassesItemFilter -> true.)
  if not TFuBag:PassesItemFilter(mainFrame, itm) then
    self:Hide(); return
  end
  local ic_start, ic_duration, ic_enable, texture

  -- Get the various frames.
  local framename = self:GetName()
  -- 12.0: ItemButton intrinsic children expose parentKeys (icon/Count/Stock),
  -- not reliable $parent global names; prefer the parentKey, fall back to global.
  local frame_texture = self.icon or _G[framename.."IconTexture"]
  local frame_font = self.Count or _G[framename.."Count"]
  local frame_stock = self.Stock or _G[framename.."Stock"]
  local editFrame = _G[framename.."_EditButton"]
  local questTexture = _G[framename.."IconQuestTexture"]

  -- Hide buttons attached to bars which are marked to be hidden
  -- unless of course it is set to a forced show.
  if TFuBag:GetGrp(cfg, TFuBag.G_BAR_HIDE, itm[TFuBag.I_BAR]) == 1 and
     not TFuBag.FORCED_SHOW[TFuBag:BagSlotToString(bag, slot)] then
    self:Hide()
    return
  else
    self:Show()
  end

  -- Set the texture for for the button
  local itemlink = itm[TFuBag.I_ITEMLINK]
  if itemlink then
    frame_texture:SetAlpha(1)
    if itemlink:sub(1,5) == "item:" then
      texture = GetItemIcon(itm[TFuBag.I_ITEMLINK])
    elseif itemlink:sub(1,9) == "keystone:" then
      texture = GetItemIcon(TFuBag:KeystoneItemID(itemlink))
    elseif itemlink:sub(1,10) == "battlepet:" then
      local _, _, _, speciesID = TFuBag:GetItemID(itemlink)
      _, texture = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
    end
  else
    if cfg.show_bag_icons == 1 then
      texture = TFuBag:GetBagTexture(playerid, bag)
    end
    frame_texture:SetAlpha(0.35)
  end
  SetItemButtonTexture(self, texture)

  -- Crafting-quality tier badge (top-left), like the default bag UI.
  TFuBag.ItemButton.UpdateQualityOverlay(self, itemlink)

  -- Handle quest overlays
  if itm[TFuBag.I_QUEST_ID] and not itm[TFuBag.I_QUEST_ACTIVE] then
    questTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG)
    questTexture:Show()
  elseif itm[TFuBag.I_QUEST_ID] or itm[TFuBag.I_QUEST_ITEM] then
    questTexture:SetTexture(TEXTURE_ITEM_QUEST_BORDER)
    questTexture:Show()
  else
    questTexture:Hide()
  end

  if (itm[TFuBag.I_RARITY] and itm[TFuBag.I_RARITY] == LE_ITEM_QUALITY_POOR and
      not itm[TFuBag.I_NOVALUE] and MerchantFrame:IsShown()) then
    self.JunkIcon:Show()
  else
    self.JunkIcon:Hide()
  end

  -- Grey tint on poor-quality items so junk reads at a glance, vendor or not.
  TFuBag.ItemButton.SetJunkTint(self,
    (not isEmptySlot) and itm[TFuBag.I_RARITY] == LE_ITEM_QUALITY_POOR)

  SetItemButtonCount(self, itm[TFuBag.I_COUNT])
  -- Collapsed empty representative (the only empty button shown): overlay the free-slot
  -- count so the single bottom box reads as "N free slots".
  if (isEmptySlot and cfg.collapse_empty == 1) then
    SetItemButtonCount(self, mainFrame.freeSlots or 0)
  end

  if mainFrame.edit_mode == 1 then
    -- we should be hilighting an entire class of item
    if itm[TFuBag.I_CAT] ~= mainFrame.edit_hilight then
      -- dim this item
        self:SetAlpha(0.25)
    else
      -- hilight this item
      self:SetAlpha(1)
    end
    editFrame:Show()
  else
    -- no hilights, just do your normal work
    local age = time() - itm[TFuBag.I_TIMESTAMP]
    if TFuBag:GetGrp(cfg, TFuBag.G_USE_NEW, itm[TFuBag.I_BAR]) == 1 and
       itm[TFuBag.I_ITEMLINK] and itm[TFuBag.I_TIMESTAMP] > 1 and
       age < 60*cfg.newItemTimeout then
      -- item is still new, display the new text.
      frame_stock:SetText(cfg[itm[TFuBag.I_NEWSTR]])
      if age < 60*cfg.recentTimeout then
        TFuBag:ColorFont(cfg, frame_stock, frame_font, "recentitem")
      else
        TFuBag:ColorFont(cfg, frame_stock, frame_font, "newitem")
      end
      frame_stock:Show()
      self:SetAlpha(1)
    else
      frame_stock:Hide()
      if mainFrame.hilight_new == 1 then
        -- We're hilighting new items and the item isn't new
        -- or we would be in the above if statement not this else.
        self:SetAlpha(0.25)
      else
          self:SetAlpha(1)
      end
    end

    if TFuBag.SrchText then
      if TFuBag:ItemMatchesSearch(itm) then
        -- Matched to normal alpha (name OR category keyword, e.g. profession)
        self:SetAlpha(1)
      else
        -- No match: dim hard so matches stand out (heavier than the 0.25 used
        -- for new-item / edit-mode dimming, since a search wants strong contrast)
        self:SetAlpha(0.1)
      end
    end

    if cfg.show_rarity_color == 1 then
      TFuBag:SetRarityColor(itm[TFuBag.I_RARITY], framename)
    else
      TFuBag:SetRarityColor(nil, framename)
    end

    editFrame:Hide()
  end

  -- Handle desaturation update for locked status
  TFuBag.ItemButton.UpdateLock(self, itm, mainFrame)

  -- resize and position fonts
  frame_font:SetTextHeight(math.ceil(cfg.count_font)) -- count, bottomright
  frame_font:ClearAllPoints()
  frame_font:SetPoint("BOTTOMRIGHT", framename, "BOTTOMRIGHT", 0-cfg.count_font_x, cfg.count_font_y)

  frame_stock:SetTextHeight(math.ceil(cfg.new_font)) -- stock, topleft
  frame_stock:ClearAllPoints()
  frame_stock:SetPoint("TOPLEFT", framename, "TOPLEFT", cfg.count_font_x/2,
                       0-cfg.count_font_y)

  -- Update the cooldown
  TFuBag.ItemButton.UpdateCooldown(self, itm, mainFrame)
end

-- Bar buttons used in edit mode to reference a bar.
TFuBag.BarButton = {}
local BarButton = TFuBag.BarButton

function BarButton:OnLoad()
  self:RegisterForClicks("LeftButtonUp", "RightButtonUp")

  -- The old ItemButtonTemplate "$parentStock" fontstring is gone in 12.0; fall
  -- back to the modern Count element and no-op if neither exists.
  local stock = _G[self:GetName().."Stock"] or _G[self:GetName().."Count"] or self.Count
  if stock then
    stock:SetFont("Fonts\\ARIALN.TTF", 18, "OUTLINE")
    stock:SetTextColor(1,0,0.25,1)
    stock:SetJustifyH("CENTER")
    stock:ClearAllPoints()
    stock:SetAllPoints()
    stock:Show()
  end
end


function BarButton:OnEnter()
  -- The bar button is parented to the scroll Container (TInv/TBnk create it under
  -- invContainer), so self:GetParent() is NOT the main window -- walk up to the frame
  -- carrying .cfg, same fix ItemButton:OnClick uses. Without this, edit_mode reads nil
  -- here and the handler bails (no tooltip; clicking a bar location never moves).
  local mainFrame = TFuBag:GetButtonMainFrame(self)
  if not mainFrame or mainFrame.edit_mode ~= 1 then return end
  local bar = self:GetID()

  GameTooltip:SetOwner(self, "ANCHOR_LEFT")
  GameTooltip:ClearLines()

  if mainFrame.edit_selected ~= "" then
    GameTooltip:AddLine(string.format("|c%sLeft click to move category |r|c%s%s|r|c%s to bar |r|c%s%s|r",TFuBag.C_INST,TFuBag.C_CAT,mainFrame.edit_selected,TFuBag.C_INST,TFuBag.C_BAR,bar));
  else
    GameTooltip:AddLine(string.format("|c%sBar |r|c%s%s|r",TFuBag.C_INST,TFuBag.C_BAR,bar));
    GameTooltip:AddLine(" ");
    for key, value in pairs(mainFrame.BC_LIST[bar]) do
      GameTooltip:AddLine(string.format("|c%s%s|r",TFuBag.C_CAT,value));
    end
    GameTooltip:AddLine(" ");
    GameTooltip:AddLine(L["Right click for options"], 0.85,0.85,0.85, 1.0);
  end
  GameTooltip:Show();
end

function BarButton:OnLeave()
  if GameTooltip:IsOwned(self) then
    GameTooltip:Hide()
    ResetCursor()
  end
end

function BarButton:OnClick(button)
  -- Parented to the scroll Container, not the main window -- resolve the real main
  -- frame (the one with .cfg) so edit_mode/edit_selected read correctly. self:GetParent()
  -- returned the Container, whose edit_mode is nil, so every click returned early here
  -- and category moves did nothing.
  local mainFrame = TFuBag:GetButtonMainFrame(self)
  if not mainFrame or mainFrame.edit_mode ~= 1 then return end
  local bar = self:GetID()

  if button == "LeftButton" then
    if mainFrame.edit_selected ~= "" then
      TFuBag:SetCatBar(mainFrame.cfg, mainFrame.edit_selected, bar, 1)

      mainFrame.edit_selected = ""
      mainFrame.edit_hilight = ""

      TFuBag:BuildBarClassList(mainFrame.BC_LIST, mainFrame.cfg)

      mainFrame:UpdateWindow(TFuBag.REQ_MUST)
    end
  elseif button =="RightButton" then
    HideDropDownMenu(1)
    mainFrame.RightClickMenu_mode = "bar"
    mainFrame.RightClickMenu_opts = {
      [TFuBag.I_BAR] = bar
    }
    ToggleDropDownMenu(1, nil, mainFrame.RightClickMenu, self:GetName(), -50, 0)
  end
end

TFuBag.BagButton = {}
local BagButton = TFuBag.BagButton

function BagButton:OnLoad()
  self:RegisterForDrag("LeftButton")
  self:RegisterForClicks("LeftButtonUp", "RightButtonUp")

  -- Stock frame from ItemButtonTemplate is used here for
  -- the counts on the bag.  Adjust it to center the numbers.
  -- The old ItemButtonTemplate "$parentStock" fontstring is gone in 12.0; fall
  -- back to the modern Count element and no-op if neither exists.
  local stock = _G[self:GetName().."Stock"] or _G[self:GetName().."Count"] or self.Count
  if stock then
    stock:SetFont("Fonts\\ARIALN.TTF", 18, "OUTLINE")
    stock:SetJustifyH("CENTER")
    stock:ClearAllPoints()
    stock:SetAllPoints()
    stock:Show()
  end

  -- Neutralize the placeholder ItemAnim Model. ItemAnimTemplate is gone in 12.0 and nothing
  -- RegisterEvents ITEM_PUSH, so this Model never animates -- but as a child of the bag
  -- button it renders an empty 3D viewport whenever the button is shown, and re-showing it
  -- (toggling Hide Bag Buttons off->on) forces WoW's model render path, which can evict
  -- world/terrain textures until the window closes. Hiding it leaves nothing to render.
  local anim = _G[self:GetName().."ItemAnim"]
  if anim then anim:Hide() end
end

function BagButton:OnEnter()
  local bag = self:GetID()
  local mainFrame = self:GetParent()

  GameTooltip:SetOwner(self, "ANCHOR_LEFT");
  GameTooltip:ClearLines();
  if bag == BANK_CONTAINER then
    GameTooltip:SetText(L["The Bank"], 1.0, 1.0, 1.0)
    GameTooltip:Show()
    return
  elseif bag == BACKPACK_CONTAINER then
    GameTooltip:SetText(BACKPACK_TOOLTIP, 1.0, 1.0, 1.0)
    GameTooltip:Show()
    return
  elseif bag == REAGENTBANK_CONTAINER then
    if TFuBag:IsReagentBankUnlocked(mainFrame.playerid) then
      GameTooltip:SetText(REAGENT_BANK, 1.0, 1.0, 1.0);
    else
      GameTooltip:SetText(L["Purchasable Reagent Bank"], 1.0, 1.0, 1.0)
      -- GetReagentBankCost was removed in 12.0 (no reagent bank). Guard the call.
      if mainFrame.atbank == 1 and GetReagentBankCost then
        SetTooltipMoney(GameTooltip, GetReagentBankCost())
      end
    end
    GameTooltip:Show()
    return
  elseif mainFrame.playerid == TFuBag.PLAYERID and
    GameTooltip:SetInventoryItem("player", ContainerIDToInventoryID(bag)) then
    GameTooltip:Show()
    return
  else
    local itemlink = TFuBag:GetPlayerBagCfg(mainFrame.playerid, bag, TFuBag.I_ITEMLINK)
    if (itemlink and itemlink ~= "") then
      local level = TFuBag:GetPlayerInfo(mainFrame.playerid,TFuBag.G_BASIC)[TFuBag.S_LEVEL] or
                    UnitLevel("player")
      itemlink = itemlink..":"..level
      GameTooltip:SetHyperlink(itemlink)
      GameTooltip:Show()
      return
    end
  end

  -- Empty bag slots
  if TFuBag:Member(TFuBag.Bnk_Bags,bag) then
    local numSlots = TFuBag:GetNumBankSlots(mainFrame.playerid)

    if bag <= numSlots + 4 then
      SetItemButtonTextureVertexColor(self, 1,0, 1.0, 1.0, 1.0)
      GameTooltip:AddLine(BANK_BAG, 1.0, 1.0, 1.0)
    else
      SetItemButtonTextureVertexColor(self, 1,0, 0.1, 0.1, 1.0)
      GameTooltip:AddLine(BANK_BAG_PURCHASE, 1.0, 1.0, 1.0)
      if mainFrame.atbank == 1 then
        SetTooltipMoney(GameTooltip, GetBankSlotCost(numSlots))
      end
    end
  else
    GameTooltip:SetText(EQUIP_CONTAINER, 1.0, 1.0, 1.0)
  end
  GameTooltip:Show()
end

function BagButton:OnLeave()
  if GameTooltip:IsOwned(self) then
    GameTooltip:Hide()
    ResetCursor()
  end
end

function BagButton:OnClick(button,down,drag)
  local bag = self:GetID()
  local mainFrame = self:GetParent()
  local isLive = TFuBag:IsLive(mainFrame)
  local isBagShown = mainFrame.cfg["show_Bag"..bag] == 1
  local itm = TFuBag:GetPlayerBag(mainFrame.playerid,bag)

  -- Right-click an equippable bag slot (not the backpack) with an empty cursor: open a
  -- context menu (currently just "Empty bag"). Left-click keeps the show/highlight toggle.
  if (button == "RightButton" and bag > 0 and not CursorHasItem()
      and isLive and mainFrame.RightClickMenu) then
    HideDropDownMenu(1)
    mainFrame.RightClickMenu_mode = "bagslot"
    mainFrame.RightClickMenu_opts = { [TFuBag.I_BAG] = bag }
    ToggleDropDownMenu(1, nil, mainFrame.RightClickMenu, self:GetName(), -50, 0)
    return
  end

  -- (Classic-bank "buy reagent bank" / "buy bank bag slot" click paths removed for
  -- 12.0: the static classic bag-slot buttons are permanently hidden by Bank:init and
  -- the tab-as-container model has no purchasable bag slots. The removed block also held
  -- an insecure write to Blizzard's secure BankFrame.nextSlotCost -- a latent taint vector.)

  -- Handle putting items in the bag
  if isLive and CursorHasItem() then
    TFuBag:PutItemInBag(bag)
    if not drag then
      -- If this is a drag receive then don't toggle the check.
      self:SetChecked(not self:GetChecked())
    end
    return
  end

  -- Empty bag slot do nothing, has to follow the above to allow equiping
  -- of bags.
  if bag > 0 and (not itm[TFuBag.I_ITEMLINK] or itm[TFuBag.I_ITEMLINK] == "") then
    self:SetChecked(not self:GetChecked())
    return
  end

  -- Handle linking of the bags
  if IsModifiedClick("CHATLINK") then
    local hyperlink = TFuBag:MakeHyperlink(itm[TFuBag.I_ITEMLINK], itm[TFuBag.I_NAME],
                                         itm[TFuBag.I_RARITY],
                                         TFuBag:GetPlayerInfo(mainFrame.playerid,
                                         TFuBag.G_BASIC)[TFuBag.S_LEVEL] or UnitLevel("player"),
                                         itm[TFuBag.I_LINKSUFFIX])
    if hyperlink and ChatEdit_InsertLink(hyperlink) then
      self:SetChecked(not self:GetChecked())
      return
    end
  end

  if not isBagShown then
    mainFrame:UpdateWindow(TFuBag.REQ_MUST)
  end
  TFuBag:UpdateButtonHighlights()
end

function BagButton:OnDrag()
  local bag = self:GetID()
  if bag <= 0 then return end
  local mainFrame = self:GetParent()
  local isLive = TFuBag:IsLive(mainFrame)

  if not isLive then return end
  PickupBagFromSlot(ContainerIDToInventoryID(bag))
  -- Remember which equipped bag is now on the cursor so a window-body drop doesn't try to
  -- stow it into one of its OWN (now-free) slots -> Blizzard "a bag can't go in itself".
  TFuBag.cursorBagId = bag
end

-- Used for the ItemAnim subframe to trigger the animation
-- for a received item.  Have to dulicate the Blizzard
-- implementation since we uniformly use bag ids and
-- they mix and match bag ids with inventory ids.
function BagButton:ItemAnimOnEvent(event, invid, texture)
  if event == "ITEM_PUSH" then
    local bag = self:GetParent():GetID()
    local id
    if bag > 0 then
      id = ContainerIDToInventoryID(bag)
    else
      id = bag
    end

    if id == invid then
      self:ReplaceIconTexture(texture)
      self:SetSequence(0)
      self:SetSequenceTime(0,0)
      self:Show()
    end
  end
end

TFuBag.ColumnsButton = {}
local ColumnsButton = TFuBag.ColumnsButton

function ColumnsButton:OnLoad()
  local name = self:GetName()
  local offset = 24

  if name:match("ColumnsAdd") then
    self:SetText(L["<++>"])
  else
    self:SetText(L[">--<"])
    offset = offset * -1
  end
  self:SetPoint("CENTER",self:GetParent(),"CENTER",offset,0)
end

function ColumnsButton:OnClick(button, down)
  local mainFrame = self:GetParent()

  PlaySound(PlaySoundKitID and "igMainMenuOptioncheckBoxOn" or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
  if self:GetText() == L["<++>"] then
    mainFrame:IncreaseColumns()
  else
    mainFrame:DecreaseColumns()
  end
end

function ColumnsButton:OnEnter()
  local normal, newbie

  if self:GetText() == L["<++>"] then
    normal = L["Increase Window Size"]
    newbie = L["Increase the number of columns displayed"]
  else
    normal = L["Decrease Window Size"]
    newbie = L["Decrease the number of columns displayed"]
  end

  GameTooltip:SetOwner(self, "ANCHOR_LEFT")
  TFuBag.NewbieTip(self, normal, 1.0, 1.0, 1.0, newbie)
end

function ColumnsButton:OnLeave()
  GameTooltip:Hide()
  ResetCursor()
end
