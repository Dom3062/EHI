local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local Heli = 30 + 23 + 5
local Truck = 40
if EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) then
    Heli = 3 + 60 + 23 + 5
    Truck = 60
end
local triggers = {
    [102177] = { time = Heli, id = "Heli", icons = Icon.HeliDropBag, hint = Hints.Winch }, -- Time before Bile arrives

    [106013] = { time = Truck, id = "Truck", icons = { Icon.Car }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists, hint = Hints.Defend },
    [106017] = { id = "Truck", special_function = SF.PauseTracker },

    [104299] = { time = 5, id = "C4GasStation", icons = { Icon.C4 }, hint = Hints.Explosion, waypoint = { position_from_element = 104603 } },

    -- Calls with Commissar
    [101388] = { time = 8.5 + 6, id = "FirstCall", icons = { Icon.Phone }, hint = Hints.Wait },
    [101389] = { time = 10.5 + 8, id = "SecondCall", icons = { Icon.Phone }, hint = Hints.Wait },
    [103385] = { time = 8.5 + 5, id = "LastCall", icons = { Icon.Phone }, hint = Hints.Wait },

    [101218] = { id = "ThugsKill", icons = { Icon.Kill }, class = TT.Progress, hint = Hints.Kills, special_function = EHI.Trigger:RegisterCustomSF(function(self, trigger, ...)
        trigger.max = managers.enemy:GetNumberOfEnemies()
        self:CreateTracking()
    end) },
    [105158] = { id = "ThugsKill", special_function = SF.IncreaseProgressMax },
    [105206] = { id = "ThugsKill", special_function = SF.IncreaseProgress }
}
if EHI.Mission._SHOW_MISSION_TRACKERS_TYPE.cheaty then
    EHI.Mission:LoadTracker("EHINameTracker")
    ---@param self EHIMissionElementTrigger
    ---@param area_name string
    local function AddTracker(self, area_name)
        if self._trackers:DoesNotExist("District") then
            self._trackers:AddTracker({
                id = "District",
                name = area_name,
                icons = { "sidebar_question" }, -- Map with question mark icon (unused in-game)
                hint = "mia_1_location",
                half_size = true,
                class = "EHINameTracker"
            })
        end
    end
    -- After third call
    triggers[100396] = { arg = "Downtown", special_function = SF.CustomCode2, f = AddTracker }
    triggers[100551] = { arg = "Georgetown", special_function = SF.CustomCode2, f = AddTracker }
    triggers[100558] = { arg = "West End", special_function = SF.CustomCode2, f = AddTracker }
    triggers[100559] = { arg = "Foggy Bottom", special_function = SF.CustomCode2, f = AddTracker }
    triggers[100642] = { arg = "Shaw", special_function = SF.CustomCode2, f = AddTracker }
    triggers[105065] = { id = "District", special_function = SF.RemoveTracker }
    if EHI.IsClient then
        -- Reminder
        triggers[101779] = { arg = "Downtown", special_function = SF.CustomCode2, f = AddTracker }
        triggers[101780] = { arg = "Georgetown", special_function = SF.CustomCode2, f = AddTracker }
        triggers[101781] = { arg = "West End", special_function = SF.CustomCode2, f = AddTracker }
        triggers[101782] = { arg = "Foggy Bottom", special_function = SF.CustomCode2, f = AddTracker }
        triggers[101783] = { arg = "Shaw", special_function = SF.CustomCode2, f = AddTracker }
    end
end
if EHI.IsClient then
    triggers[104955] = EHI:ClientCopyTrigger(triggers[106013], { time = 30 })
end
if EHI:CanShowAchievement2("pig_3", "show_achievements_melee") then -- Do You Like Hurting Other People?
    EHI:AddOnSpawnedExtendedCallback(function(self, job, level, from_beginning)
        if job == "mia" and self:EHIHasMeleeEquipped("baseballbat") then
            self:EHIAddAchievementTrackerFromStat("pig_3_stats")
        end
    end)
end

local other =
{
    [101937] = EHI:AddAssaultDelay({ control = 10 + 1 + 40, special_function = SF.AddTimeByPreplanning, data = { id = 100191, yes = 75, no = 45 } })
}
if EHI:IsLootCounterVisible() then
    local MethlabIndex = { 7800, 8200, 8600 }
    local money = EHI:GetValueBasedOnDifficulty({
        normal = 5,
        hard = 4,
        veryhard = 4,
        overkill = 3,
        mayhem_or_above = 2
    })
    local function GetNumberOfMethBags()
        for _, index in ipairs(MethlabIndex) do
            local unit_id = EHI:GetInstanceUnitID(100068, index) -- Acid 3
            if managers.game_play_central:IsMissionUnitEnabled(unit_id) then
                return 3
            end
        end
        for _, index in ipairs(MethlabIndex) do
            local unit_id = EHI:GetInstanceUnitID(100067, index) -- Acid 2
            if managers.game_play_central:IsMissionUnitEnabled(unit_id) then
                return 2
            end
        end
        -- If third or second acid is not found in either methlab instance, return one possible bag
        -- No need to check Caustic Soda and Hydrogen Chloride, they spawn with Muriatic Acid
        return 1
    end
    local Methbags = 0
    local MethbagsCooked = 0
    local MethbagsPossibleToSpawn = 19
    local MethlabExploded = false
    other[101218] = EHI:AddLootCounter2(function()
        Methbags = GetNumberOfMethBags()
        EHI:ShowLootCounterNoChecks({
            max = money + Methbags,
            -- 19 + 2 // 19 boxes of contrabant, that can spawn chemicals (up to 4); 2 cars with possible loot
            max_random = 19 + 2,
            unknown_random = true
        })
    end, { element = { 100168, 100245, 100459, 100609 }, present_timer = 0 })
    -- Basement
    local UnknownRandomLootSpawned = EHI:AddCustomCode(function(self)
        self._loot:IncreaseLootCounterProgressMax()
    end)
    -- Coke
    for i = 102832, 102841, 1 do
        other[i] = UnknownRandomLootSpawned
    end
    -- Weapons
    for i = 104498, 104506, 1 do
        other[i] = UnknownRandomLootSpawned
    end
    other[101204] = EHI:AddCustomCode(function(self)
        self._loot:SetUnknownRandomLoot()
    end)
    -- Meth
    ---@param self EHIMissionElementTrigger
    ---@param id number
    local function PossibleMethbagSpawned(self, id)
        if MethlabExploded then
            return
        end
        Methbags = Methbags + 1
        MethbagsPossibleToSpawn = MethbagsPossibleToSpawn - 1
        self._loot:RandomLootSpawnedCheck(id, true)
    end
    ---@param id number
    local function NoMethBagSpawned(id)
        if MethlabExploded then
            managers.ehi_loot:RandomLootDeclined()
            return
        end
        MethbagsPossibleToSpawn = MethbagsPossibleToSpawn - 1
        managers.ehi_loot:RandomLootDeclinedCheck(id)
    end
    ---@param id number
    local function DelayedRejection(id)
        if MethlabExploded then
            return
        end
        managers.ehi_loot:AddDelayedLootDeclinedCheck(id, NoMethBagSpawned)
    end
    for i = 9000, 16200, 400 do
        managers.mission:add_runned_unit_sequence_trigger(EHI:GetInstanceUnitID(100008, i), "interact", function()
            DelayedRejection(i)
        end)
        other[EHI:GetInstanceElementID(100015, i)] = { special_function = SF.CustomCode2, f = PossibleMethbagSpawned, arg = i } -- Chemicals for meth
    end
    -- Methlab exploded
    local BlockMeth = EHI:AddCustomCode(function(self)
        if Methbags == 0 then -- Dropin; impossible to tell how many bags were cooked
            return
        end
        self._loot:DecreaseLootCounterProgressMax(Methbags - MethbagsCooked)
        self._loot:DecreaseLootCounterMaxRandom(MethbagsPossibleToSpawn)
        MethlabExploded = true
    end)
    local function CookingDone()
        MethbagsCooked = MethbagsCooked + 1
    end
    for _, index in ipairs(MethlabIndex) do
        other[EHI:GetInstanceElementID(100158, index)] = BlockMeth
        other[EHI:GetInstanceElementID(100159, index)] = { special_function = SF.CustomCode, f = CookingDone }
    end
    -- Cars
    local CarLootBlocked = false
    local CarLootNumber = 2
    other[100724] = EHI:AddCustomCode(function(self)
        CarLootBlocked = true
        self._loot:DecreaseLootCounterMaxRandom(CarLootNumber)
    end)
    local CarLootBlockedTrigger = EHI:AddCustomCode(function(self)
        if CarLootBlocked then
            return
        end
        CarLootNumber = CarLootNumber - 1
        self._loot:RandomLootDeclined()
    end)
    -- All cars; does not get triggered when maximum has been reached
    other[100721] = EHI:AddCustomCode(function(self)
        self._loot:RandomLootSpawned()
    end)
    -- units/payday2/vehicles/str_vehicle_car_sedan_2_burned/str_vehicle_car_sedan_2_burned/001
    other[100523] = CarLootBlockedTrigger -- Empty money bundle, taken weapons or body spawned
    other[100550] = CarLootBlockedTrigger -- Car set on fire -- 103846
    other[106837] = CarLootBlockedTrigger -- Nothing spawned
    -- units/payday2/vehicles/str_vehicle_car_crossover_burned/str_vehicle_car_crossover_burned/001
    other[100849] = CarLootBlockedTrigger -- Money should spawn, but ElementEnableUnit does not have any unit to spawn and bag counter goes up by 1
    -- units/payday2/vehicles/str_vehicle_car_sedan_2_burned/str_vehicle_car_sedan_2_burned/006
    other[100918] = CarLootBlockedTrigger -- Nothing spawned
    other[100912] = CarLootBlockedTrigger -- Empty money bundle, taken weapons or body spawned
    other[100553] = CarLootBlockedTrigger -- Car set on fire
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100159] = { chance = 100, time = 30 + 20, recheck_t = 20 + 20, id = "Snipers", class = TT.Sniper.TimedChance }
    other[104026] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
    other[105008] = { id = "Snipers", special_function = EHI.Trigger:RegisterCustomSF(function(self, trigger, element, ...) ---@param element ElementLogicChanceOperator
        local id = trigger.id
        local chance = element._values.chance
        if self._trackers:Exists(id) then
            self._trackers:SetChance(id, chance)
            self._trackers:CallFunction(id, "SnipersKilled")
        else
            local t = 20 + 20
            self._trackers:AddTracker({
                id = id,
                time = t,
                recheck_t = t,
                chance = chance,
                class = TT.Sniper.TimedChance
            })
        end
    end) } -- 20%
    other[105024] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +10%
    other[104289] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[104303] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI.Mission:ParseTriggers({
    mission = triggers,
    other = other,
    loot_removal_triggers = { 104475, 106825, 106826, 106827 } -- Loot removal (Fire); coke, meth, money, weapon
})
local money = EHI:GetValueBasedOnDifficulty({
    normal = 5,
    hard = 4,
    veryhard = 4,
    overkill = 3,
    mayhem_or_above = 2
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 4000, name = "hm1_mobsters_killed" },
        { amount = 4000, name = "hm1_cars_destroyed" },
        { amount = 4000, name = "hm1_gas_station_destroyed" },
        { amount = 4000, name = "hm1_hatch_open" },
        { amount = 6000, name = "hm1_correct_barcode_scanned" },
        { amount = 500, name = "hm1_meth_cooked", optional = true },
        { escape = 4000 }
    },
    loot_all = 1000,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                objectives =
                {
                    hm1_meth_cooked = { min = 0, max = 7 }
                },
                loot_all = { max = money + 7 + 3 + 2 } -- Money + 7 meth bags (3 (max; random) in methlab, up to 4 in basement) + 3 coke/weapons + 2 random loot from cars
            }
        }
    }
})