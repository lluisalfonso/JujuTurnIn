local addonName, addonTable = ...
addonTable.Constants = {}
local C = addonTable.Constants

C.NPC_ID = 10307 -- Witch Doctor Mau'ari

-- Strict mapping of Blizzard Quest IDs and their respective Item IDs (E'kos)
C.Quests = {
    [4801] = { name = "Frostsaber E'ko",   juju = "Juju Flurry", title = "Juju Flurry", ekoID = 12430 },
    [4802] = { name = "Winterfall E'ko",   juju = "Juju Power",  title = "Juju Power",  ekoID = 12431 },
    [4803] = { name = "Shardtooth E'ko",   juju = "Juju Ember",  title = "Juju Ember",  ekoID = 12432 },
    [4804] = { name = "Chillwind E'ko",    juju = "Juju Chill",  title = "Juju Chill",  ekoID = 12434 },
    [4805] = { name = "Ice Thistle E'ko",  juju = "Juju Escape", title = "Juju Escape", ekoID = 12435 },
    [4806] = { name = "Frostmaul E'ko",    juju = "Juju Might",  title = "Juju Might",  ekoID = 12436 },
    [4807] = { name = "Wildkin E'ko",      juju = "Juju Guile",  title = "Juju Guile",  ekoID = 12433 },
}