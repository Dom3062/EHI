local EHI = EHI
if EHI:CheckLoadHook("GameSetup") then
    return
end
EHI.Mission = blt.vm.dofile(EHI.LuaPath .. "mission/EHIMissionElementTrigger.lua")
EHI.Trigger = EHIMissionElementTrigger:__post_init()
EHI.Element = blt.vm.dofile(EHI.LuaPath .. "mission/EHIMissionElementOverride.lua")
EHI.Waypoint = blt.vm.dofile(EHI.LuaPath .. "mission/EHIMissionElementWaypoint.lua")
EHI.Unit = blt.vm.dofile(EHI.LuaPath .. "mission/EHIMissionUnit.lua")

local redirect =
{
    branchbank = "firestarter_3",
    branchbank_gold = "firestarter_3",
    branchbank_cash = "firestarter_3",
    branchbank_deposit = "firestarter_3",
    watchdogs_1_night = "watchdogs_1",
    watchdogs_2_day = "watchdogs_2",
    welcome_to_the_jungle_1_night = "welcome_to_the_jungle_1",
    election_day_3_skip1 = "election_day_3",
    election_day_3_skip2 = "election_day_3",
    escape_cafe_day = "escape_cafe",
    escape_overpass_night = "escape_overpass",
    escape_park_day = "escape_park",
    gallery = "framing_frame_1",
    crojob3_night = "crojob3",
    skm_arena = "skm_base",
    skm_cas = "skm_base",
    skm_watchdogs_stage2 = "skm_base",
    -- Custom Missions
    ratdaylight = "levels/rat",
    lid_cookoff_methslaves = "levels/rat",
    roberts_v2 = "levels/roberts",
    ["Henry's Rock (Better Spawns)"] = "levels/des",
    sahv2 = "levels/sah",
    ["Auction Edit"] = "levels/sah",
    ["Auction Heist No Rain"] = "levels/sah",
    ["Auction Edit Rain"] = "levels/sah",
    fexbetterspawns = "levels/fex",
    slaughter_house_new = "levels/dinner"
}

local custom_levels =
{
    ratdaylight = true, -- Rats (Daylight)
    ["Triad Takedown Yacht Heist"] = true, -- Triad Takedown Yacht Heist; Saw defend wp; needs removal
    ttr_yct_lvl = true, -- Triad Takedown Remastered Custom Heist; Hack PC wp; needs removal
    ruswl = true, -- Scorched Earth Custom Heist
    rusdl = true, -- Cold Stones Custom Heist
    crimepunishlvl = true, -- Crime and Punishment Custom Heist; Drill wps + C4 wp; needs removal
    RogueCompany = true, -- Yaeger - Rogue Company Custom Heist
    hunter_party = true, -- Hunter and Hunted (Party) Day 1
    hunter_departure = true, -- Hunter and Hunted (Departure) Day 2
    hunter_fall = true, -- Hunter and Hunted (Fall) Day 3
    constantine_harbor_lvl = true, -- Harboring a Grudge
    --lit1 = true, -- California Heat
    --lit2 = true, -- California Heat (Bonus Mission)
    -- Constantine Scores
    constantine_smackdown_lvl = true, -- Smackdown
    constantine_smackdown2_lvl = true, -- Truck Hustle
    constantine_ondisplay_lvl = true, -- On Display
    constantine_apartment_lvl = true, -- Concrete Jungle
    --[[Smugglers Den (Loud and Stealth)
    Aurora Club (Loud and Stealth)]]
    constantine_butcher_lvl = true, -- Butchers Bay
    constantine_policestation_lvl = true, -- Precinct Raid
    --[[Kozlov Mansion (Loud and Stealth)
    Blood in the Water (Loud and Stealth)
    Gunrunners Clubhouse (Loud Only)
    In the Crosshairs (Stealth Only)
    Murky Airpot (Loud Only)
    Scarlett Resort (Loud and Stealth)
    Penthouse Crasher (Loud Only)
    Golden Shakedown (Loud and Stealth)
    Early Bird (Loud Only)
    Cartel Transport: Construction Site (Loud Only)
    Cartel Transport: Train (Loud Only)
    Dance with the Devil (Loud Only)
    Cartel Transport: Downtown (Loud Only)
    Welcome to the Jungle (Loud Only)
    Fiesta (Loud Only)
    Showdown (Loud Only)
    ]]
    --Tonis2 = true, -- Triple Threat
    --dwn1 = true -- Deep Inside
    street_new = true, -- Heat Street Rework (Heat Street True Classic in-game)
    office_strike = true, -- Office Strike
    tonmapjam22l = true, -- Hard Cash
    SJamBank = true, -- Branch Bank Initiative
    roberts_v2 = true, -- GO Bank Remastered
    lvl_friday = true, -- Crashing Capitol
    ["Henry's Rock (Better Spawns)"] = true,
    sahv2 = true,
    ["Auction Edit"] = true,
    ["Auction Heist No Rain"] = true,
    ["Auction Edit Rain"] = true,
    fexbetterspawns = true,
    slaughter_house_new = true
}

Hooks:PostHook(GameSetup, "init_finalize", "EHI_GameSetup_init_finalize", function(...)
    EHI.Sync = managers.ehi_sync
    EHI:CallCallbackOnce(EHI.CallbackMessage.InitFinalize)
    local level_id = Global.game_settings.level_id
    if redirect[level_id] then -- Also applies to custom missions
        dofile(string.format("%s%s%s.lua", EHI.LuaPath, "levels/", redirect[level_id]))
    elseif custom_levels[level_id] then
        dofile(EHI.LuaPath .. "core_beardlib.lua")
        dofile(string.format("%s%s%s.lua", EHI.LuaPath, "custom_levels/", level_id))
    else
        local file = io.open(string.format("%s%s%s.lua", EHI.LuaPath, "levels/", level_id))
        if file then
            loadstring(file:read("*a"))()
            file:close()
        end
    end
    EHI.Mission:InitElements()
    EHI.Element:OverrideElements()
    EHI.Waypoint:GameInit()
    redirect = nil
    custom_levels = nil
    EHI.Sync = nil
    Hooks:RemovePostHook("EHI_GameSetup_init_finalize")
end)

Hooks:PreHook(GameSetup, "load", "EHI_GameSetup_load_Pre", function(self, data, ...) ---@param data SyncData
    EHI.Unit:FinalizeUnitsClient()
    managers.ehi_assault:load(data)
    managers.ehi_sync:load_pre(data)
end)

Hooks:PostHook(GameSetup, "load", "EHI_GameSetup_load_Post", function(self, data, ...) ---@param data SyncData
    EHI.Element:OverrideElements()
    managers.ehi_sync:load_post(data)
    EHI.Mission:load()
    EHI.Waypoint:GameInitClient()
    EHI.Trigger:load(data)
    managers.ehi_loot:load(data)
    managers.ehi_phalanx:load(data)
end)

Hooks:PostHook(GameSetup, "save", "EHI_GameSetup_save_Post", function(self, data, ...) ---@param data SyncData
    EHI.Trigger:save(data)
    managers.ehi_assault:save(data)
    managers.ehi_loot:save(data)
    managers.ehi_phalanx:save(data)
    managers.ehi_sync:save(data)
end)