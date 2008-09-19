TBag = CreateFrame("Frame","TBag",UIParent)
TBag:RegisterEvent("VARIABLES_LOADED")
TBag.WoTLK = select(4,GetBuildInfo()) >= 30000
