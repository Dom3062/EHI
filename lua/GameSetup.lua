local EHI = EHI
if EHI._hooks.GameSetup then
	return
else
	EHI._hooks.GameSetup = true
end

local original =
{
    init_finalize = GameSetup.init_finalize,
    save = GameSetup.save,
    load = GameSetup.load
}

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
    crojob3_night = "crojob3",
    -- Custom Missions
    ratdaylight = "levels/rat"
}

local levels =
{
    short2_stage2b = true, -- Basic Mission: Loud - Plan B
    jewelry_store = true, -- Jewelry Store
    branchbank = true, -- Branchbank: Random
    branchbank_gold = true, -- Branchbank: Gold
    branchbank_cash = true, -- Branchbank: Cash
    branchbank_deposit = true, -- Branchbank: Deposit
    kosugi = true, -- Shadow Raid
    roberts = true, -- GO Bank
    family = true, -- Diamond Store
    arm_cro = true, -- Transport: Crossroads
    arm_fac = true, -- Transport: Harbor -- Missing wps
    arm_hcm = true, -- Transport: Downtown
    arm_par = true, -- Transport: Park -- Missing wps
    arm_und = true, -- Transport: Underpass -- Missing wps
    arm_for = true, -- Transport: Train Heist -- Additional wps; removal needed
    mallcrasher = true, -- Mallcrasher
    four_stores = true, -- Four Stores
    pines = true, -- White Xmas; missing wps
    ukrainian_job = true, -- Ukrainian Job
    shoutout_raid = true, -- Meltdown
    jolly = true, -- Aftershock; fix the escape heli timer; addional wps on saws, removal needed
    nightclub = true, -- Nightclub
    moon = true, -- Stealing Xmas
    watchdogs_1 = true, -- Watchdogs Day 1; missing wps
    watchdogs_1_night = true, -- Watchdogs Day 1 (Night)
    watchdogs_2_day = true, -- Watchdogs Day 2 (Day)
    watchdogs_2 = true, -- Watchdogs Day 2
    firestarter_1 = true, -- Firestarter Day 1
    firestarter_2 = true, -- Firestarter Day 2
    firestarter_3 = true, -- Firestarter Day 3
    alex_1 = true, -- Rats Day 1
    alex_2 = true, -- Rats Day 2
    alex_3 = true, -- Rats Day 3
    welcome_to_the_jungle_1 = true, -- Big Oil Day 1
    welcome_to_the_jungle_1_night = true, -- Big Oil Day 1 (Night)
    welcome_to_the_jungle_2 = true, -- Big Oil Day 2; PC Hack waypoint; remove
    -- framing_frame_1 == true, -- Framing Frame Day 1; Drill security door waypoint; removal needed (MissionDoor)
    framing_frame_2 = true, -- Framing Frame Day 2
    framing_frame_3 = true, -- Framing Frame Day 3; PC Hack waypoint; removal needed
    election_day_1 = true, -- Election Day 1
    election_day_3 = true, -- Election Day 2 Plan C
    election_day_3_skip1 = true,
    election_day_3_skip2 = true,
    escape_cafe = true, -- Escape: Cafe
    escape_cafe_day = true, -- Escape: Cafe (Day)
    escape_overpass = true, -- Escape: Overpass; Appears to be unused
    escape_overpass_night = true, -- Escape: Overpass (Night)
    escape_park = true, -- Escape: Park; missing escape wp
    escape_park_day = true, -- Escape: Park (Day)
    escape_street = true, -- Escape: Street
    big = true, -- Big Bank; "Dance with lasers" achievement visible on all escapes
    mia_1 = true, -- Hotline Miami Day 1
    mia_2 = true, -- Hotline Miami Day 2
    hox_1 = true, -- Hoxton Breakout Day 1; Hacking PC wp; remove
    hox_2 = true, -- Hoxton Breakout Day 2; Various door wps -> MissionDoor class
    hox_3 = true, -- Hoxton Revenge; Drill vault wp; removal needed + add heli wps
    mus = true, -- The Diamond; Defend + Fix wp when hacking the barrier
    arena = true, -- The Alesso Heist; Hacking PC wp, needs removal
    kenaz = true, -- Golden Grin Casino; Defend BFD wp, needs removal + add C4 timer
    crojob2 = true, -- The Bomb: Dockyard
    crojob3 = true, -- The Bomb: Forest
    crojob3_night = true, -- The Bomb: Forest (Night)
    friend = true, -- Scarface Mansion
    pal = true, -- Counterfeit; Objective waypoints, needs removal
    red2 = true, -- First World Bank
    rat = true, -- Cook Off
    dark = true, -- Murky Station; No elements yet
    mad = true, -- Boiling Point
    peta = true, -- Goat Simulator Heist Day 1; Drill door (saw most likely too) wp; needs removal
    peta2 = true, -- Goat Simulator Heist Day 2; Drill door wp; needs removal -> MissionDoor class
    cane = true, -- Santa's Workshop
    cage = true, -- Car Shop
    born = true, -- The Biker Heist Day 1; Door drill/safe wps; removal needed -> MissionDoor class
    chew = true, -- The Biker Heist Day 2
    chill_combat = true, -- Safehouse Raid
    flat = true, -- Panic Room
    help = true, -- Prison Nightmare; Drill defend wp, needs removal; add C4 drop-off location wp
    spa = true, -- Brooklyn 10-10; Drill objective wp, needs removal
    fish = true, -- The Yacht Heist
    man = true, -- Undercover; Saw car objective wp, needs removal
    dinner = true, -- Slaughterhouse; Safe drill objective wp, needs removal
    nail = true, -- Lab Rats
    pbr = true, -- Beneath the Mountain
    pbr2 = true, -- Birth of Sky
    run = true, -- Heat Street
    glace = true, -- Green Bridge
    wwh = true, -- Alaskan Deal; Saw defend + repair wps; needs removal
    dah = true, -- Diamond Heist
    hvh = true, -- Cursed Kill Room
    rvd1 = true, -- Reservoir Dogs Heist Day 2; Add pink car wps; Add escape car wps; Fix the longer escape duration
    rvd2 = true, -- Reservoir Dogs Heist Day 1; Add C4 timer (vault + escape)
    brb = true, -- Brooklyn Bank; Add C4 timer (2nd floor + in vault); Remove defend the drill wp
    tag = true, -- Breakin' Feds
    des = true, -- Henry's Rock; Remove defend+fix (probably too) wp on hacking objective, Add red button achievement
    sah = true, -- Shacklethorne Auction; Remove defend+fix (probably too) wp on hacking objective, Add heli wp
    bph = true, -- Hell's Island
    nmh = true, -- No Mercy; Remove saw door wp
    vit = true, -- The White House
    mex = true, -- Border Crossing
    mex_cooking = true, -- Border Crystals
    bex = true, -- San Martín Bank; Remove vault wp; Add "Silencioso y Codicioso" achievement
    pex = true, -- Breakfast in Tijuana
    fex = true, -- Buluc's Mansion
    chas = true, -- Dragon Heist
    sand = true, -- Ukrainian Prisoner Heist
    chca = true, -- Black Cat Heist
    Fourth_and_last_heist_in_City_of_Gold_campaign = true
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
    constantine_harbor_lvl = true -- Harboring a Grudge
}

function GameSetup:init_finalize(...)
    original.init_finalize(self, ...)
    local level_id = Global.game_settings.level_id
    if levels[level_id] then
        local fixed_name = redirect[level_id] or level_id
        dofile(EHI.LuaPath .. "levels/" .. fixed_name .. ".lua")
    end
    if custom_levels[level_id] then
        local fixed_path = redirect[level_id] or ("custom_levels/" .. level_id)
        dofile(EHI.LuaPath .. fixed_path .. ".lua")
    end
    EHI:InitElements()
    EHI:DisableWaypointsOnInit()
end

function GameSetup:save(data, ...)
    original.save(self, data, ...)
    managers.ehi:save(data)
end

function GameSetup:load(data, ...)
    EHI:FinalizeUnitsClient()
    managers.ehi:load(data)
    original.load(self, data, ...)
    managers.ehi:LoadSync()
    EHI:SyncLoad()
end