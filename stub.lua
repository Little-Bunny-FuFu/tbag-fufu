-- $Id$
TBag = CreateFrame("Frame","TBag",UIParent)
TBag:RegisterEvent("VARIABLES_LOADED")
TBag.wrath_310 = select(4,GetBuildInfo()) >= 30100
TBag.cata_400 = select(4,GetBuildInfo()) >= 40000
