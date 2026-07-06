-- tbag-fufu: retail 12.0 (Interface 120000) API compatibility shims.
--
-- This revival fork's code was written against Legion 7.3 globals. Blizzard has
-- since moved or removed many of those APIs into the C_* namespaces. This file
-- re-exposes the old globals (mapped to their modern equivalents) so the many
-- existing call sites keep working without per-site edits. It is loaded FIRST
-- in the .toc, before any addon code runs.
--
-- Every mapping below is verified against wow-ui-source 12.0; see the full
-- breakdown in tbag-fufu-12.0-api-audit.md. Phase B revival groundwork.

-- ---------------------------------------------------------------------------
-- Container API -> C_Container (10.0). Signature-stable funcs are 1:1 aliases.
-- ---------------------------------------------------------------------------
local C = C_Container
if C then
  GetContainerNumSlots     = C.GetContainerNumSlots
  GetContainerNumFreeSlots = C.GetContainerNumFreeSlots
  GetContainerItemLink     = C.GetContainerItemLink
  GetContainerItemCooldown = C.GetContainerItemCooldown
  PickupContainerItem      = C.PickupContainerItem
  SplitContainerItem       = C.SplitContainerItem
  UseContainerItem         = C.UseContainerItem
  ContainerIDToInventoryID = C.ContainerIDToInventoryID
  -- Vendor sell-cursor (coin shown when hovering a sellable item at a merchant). The bare
  -- global was moved into C_Container in 10.0; without this alias ItemButton.OnEnter calls
  -- a nil value at a vendor ("attempt to call a nil value", spammed during Sell All Junk).
  ShowContainerSellCursor  = C.ShowContainerSellCursor

  -- 8.0+: GetContainerItemInfo returns a ContainerItemInfo struct instead of
  -- positional values. Re-expose the Legion positional order TBag reads.
  -- Struct field order verified: ContainerDocumentation.lua:761-771.
  function GetContainerItemInfo(bag, slot)
    local i = C.GetContainerItemInfo(bag, slot)
    if not i then return nil end
    return i.iconFileID, i.stackCount, i.isLocked, i.quality, i.isReadable,
           i.hasLoot, i.hyperlink, i.isFiltered, i.hasNoValue, i.itemID, i.isBound
  end
  -- ItemQuestInfo struct: ContainerDocumentation.lua:812-814.
  function GetContainerItemQuestInfo(bag, slot)
    local i = C.GetContainerItemQuestInfo(bag, slot)
    if not i then return nil end
    return i.isQuestItem, i.questID, i.isActive
  end
end

-- MAX_CONTAINER_ITEMS (removed Blizzard global) was used as the fallback
-- bag-size cap in GetBagMaxItems / CreateDummyBag; restore it generously
-- (50 matches the working TBag-Inventory-Only reference port's hardcoded cap).
MAX_CONTAINER_ITEMS = MAX_CONTAINER_ITEMS or 50

-- LE_ITEM_QUALITY_* enum globals were removed in retail (replaced by Enum.ItemQuality.*).
-- TBag's merchant junk-coin overlay compares item rarity against LE_ITEM_QUALITY_POOR; with
-- the global nil that test was always false, so the coin never appeared on grey items.
LE_ITEM_QUALITY_POOR = LE_ITEM_QUALITY_POOR or (Enum and Enum.ItemQuality and Enum.ItemQuality.Poor)

-- ---------------------------------------------------------------------------
-- AddOn API -> C_AddOns (11.0).
-- ---------------------------------------------------------------------------
if C_AddOns then
  LoadAddOn     = LoadAddOn     or C_AddOns.LoadAddOn
  IsAddOnLoaded = IsAddOnLoaded or C_AddOns.IsAddOnLoaded
end

-- ---------------------------------------------------------------------------
-- Item API -> C_Item. The globals are CVar-gated in 12.0; alias to be safe.
-- ---------------------------------------------------------------------------
if C_Item then
  GetItemInfo         = C_Item.GetItemInfo
  GetItemInfoInstant  = C_Item.GetItemInfoInstant
  GetItemQualityColor = C_Item.GetItemQualityColor
  GetItemFamily       = C_Item.GetItemFamily
  -- GetItemIcon was removed; its successor (GetItemIconByID) takes an itemID,
  -- but TBag passes item links. GetItemInfoInstant accepts a link/id/name and
  -- returns the icon fileID as its 5th value.
  function GetItemIcon(item)
    return (select(5, C_Item.GetItemInfoInstant(item)))
  end
end

-- ---------------------------------------------------------------------------
-- Currency API -> C_CurrencyInfo (10.0). GetCurrencyListInfo now returns a
-- CurrencyInfo struct; re-expose the Legion positional order Tokens.lua reads.
-- Struct fields verified: CurrencyInfoDocumentation.lua CurrencyInfo (line 681+).
-- ---------------------------------------------------------------------------
if C_CurrencyInfo then
  GetCurrencyListSize = C_CurrencyInfo.GetCurrencyListSize
  ExpandCurrencyList  = C_CurrencyInfo.ExpandCurrencyList
  function GetCurrencyListInfo(index)
    local i = C_CurrencyInfo.GetCurrencyListInfo(index)
    if not i then return nil end
    return i.name, i.isHeader, i.isHeaderExpanded, i.isTypeUnused,
           i.isShowInBackpack, i.quantity, i.iconFileID
  end
end

-- ---------------------------------------------------------------------------
-- Bank: the classic-bank API is GONE in 12.0 (account-bank/warband replaced it).
-- The bank module (TFuBnk) HAS since been rewritten against C_Bank and is loaded
-- in the .toc (TBnk.xml / TBnkTabSettings.lua). These historical constants + safe
-- no-op stubs only neutralize the few LEGACY classic-bank call sites still present
-- in the core files (GetNumBankSlots / IsReagentBankUnlocked / DepositReagentBank /
-- Bank*ButtonIDToInvSlotID); the C_Bank rewrite does not rely on them -- they just
-- keep those legacy paths from nil-crashing. See tbag-fufu-12.0-api-audit.md.
-- ---------------------------------------------------------------------------
BANK_CONTAINER        = BANK_CONTAINER        or -1
REAGENTBANK_CONTAINER = REAGENTBANK_CONTAINER or -3
if not IsReagentBankUnlocked         then function IsReagentBankUnlocked() return false end end
if not GetNumBankSlots               then function GetNumBankSlots() return 0, false end end
if not GetBankSlotCost               then function GetBankSlotCost() return 0 end end
if not DepositReagentBank            then function DepositReagentBank() end end
if not BankButtonIDToInvSlotID       then function BankButtonIDToInvSlotID() return 0 end end
if not ReagentBankButtonIDToInvSlotID then function ReagentBankButtonIDToInvSlotID() return 0 end end

-- (No CloseBankFrame stub: the bare global was removed in 12.0 and tbag no longer
-- calls it -- MainFrame:OnHide now calls C_Bank.CloseBankFrame() directly to end the
-- live session when the bank window closes at a banker. "Session live" is read off
-- BankFrame:IsShown() (Bank:IsBankSessionLive).)

-- ---------------------------------------------------------------------------
-- Spell API -> C_Spell (11.0). The bare global GetSpellInfo was removed; the
-- deDE/ruRU locale files (and localization.template.lua) call it 16x each at
-- file scope for localized profession names and consume only return value 1
-- (the name). Without this shim those clients get a load-time Lua error and
-- lose all translations. C_Spell.GetSpellName returns exactly the name
-- (SpellDocumentation.lua:439).
-- ---------------------------------------------------------------------------
if not GetSpellInfo and C_Spell and C_Spell.GetSpellName then
  function GetSpellInfo(spellID)
    return C_Spell.GetSpellName(spellID)
  end
end
