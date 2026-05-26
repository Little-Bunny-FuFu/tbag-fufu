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
-- Bank: the classic-bank API is GONE in 12.0 (account-bank/warband replaced
-- it). The bank module (TFuBnk) is gated OFF in the .toc pending a ground-up
-- rewrite. These historical constants + safe no-op stubs keep the bag/inventory
-- side from nil-crashing on bank code paths that still live in the core files.
-- TODO(bank rewrite): replace with real C_Bank-backed implementations and
-- re-enable TBnk.xml / TBnkOpts.xml in the .toc. See tbag-fufu-12.0-api-audit.md.
-- ---------------------------------------------------------------------------
BANK_CONTAINER        = BANK_CONTAINER        or -1
REAGENTBANK_CONTAINER = REAGENTBANK_CONTAINER or -3
if not IsReagentBankUnlocked         then function IsReagentBankUnlocked() return false end end
if not GetNumBankSlots               then function GetNumBankSlots() return 0, false end end
if not GetBankSlotCost               then function GetBankSlotCost() return 0 end end
if not DepositReagentBank            then function DepositReagentBank() end end
if not BankButtonIDToInvSlotID       then function BankButtonIDToInvSlotID() return 0 end end
if not ReagentBankButtonIDToInvSlotID then function ReagentBankButtonIDToInvSlotID() return 0 end end

-- Bag-slot count globals the bank/inventory loops iterate (changed/removed in
-- 12.0). Fallbacks keep `for i=1,NUM_*` loops from erroring on nil. CloseBankFrame
-- (called from MainFrame.lua) is stubbed only if Blizzard removed the global.
NUM_BAG_SLOTS    = NUM_BAG_SLOTS    or NUM_TOTAL_EQUIPPED_BAG_SLOTS or 4
NUM_BANKBAGSLOTS = NUM_BANKBAGSLOTS or 0
if not CloseBankFrame then function CloseBankFrame() end end
