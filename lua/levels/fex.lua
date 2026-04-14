local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local triggers = {
    -- Van Escape, 2 possible car escape scenarions here, the longer is here, the shorter is in WankerCar
    [101638] = { time = 1 + 60 + 900/30 + 5, id = "CarEscape", icons = Icon.CarEscape, hint = Hints.LootEscape },
    -- Wanker car
    [EHI:GetInstanceElementID(100029, 27580)] = { time = 610/30 + 2, id = "CarEscape", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape },

    -- In CoreWorldInstanceManager:
    -- Mayan Door Open
    -- Exploding car
    -- Thermite in Front Game
    -- Thermite in Wine Cellar Door
    -- Safe Hack
    -- Heli Escape
}
if EHI.Mission._SHOW_MISSION_TRIGGERS_TYPE.cheaty then
    EHI.Mission:LoadClass("EHICodeTracker")
    triggers[102820] = EHI:AddCustomCode(function(self)
        if self._cache.fex_CodeSeen then
            return
        end
        local paper_unit = managers.worlddefinition:get_unit(EHI:GetInstanceElementID(100140, self._params.second_item and 3750 or 3550))
        if not paper_unit then
            return
        end
        local code = {}
        for i = 1, 4, 1 do
            local c = {}
            for j = 1, 10, 1 do
                c[j] = Idstring(string.format("g_%d_%d", i, j - 1))
            end
            code[i] = c
        end
        if self._mission._SHOW_MISSION_TRACKERS_TYPE.cheaty then
            self._trackers:AddTracker({
                id = "WineCellarCode",
                class = self.Trackers.Code
            })
        end
        if self._mission._SHOW_MISSION_WAYPOINTS_TYPE.cheaty then
            self._waypoints:AddWaypoint("WineCellarCode", {
                position = paper_unit:position(),
                icon = "code",
                class = self.Waypoints.Code
            })
        end
        for i, code_body in ipairs(code) do
            for j, object in ipairs(code_body) do
                if paper_unit:get_object(object):visibility() then -- If code is visible
                    self._tracking:Call("WineCellarCode", "SetCodePart", i, tostring(j - 1), 4)
                    break
                end
            end
        end
        self._cache.fex_CodeSeen = true
    end, true)
    triggers[103041] = EHI:CopyTrigger(triggers[102820], { second_item = true })
    triggers[EHI:GetInstanceElementID(100047, 2850)] = { id = "WineCellarCode", special_function = SF.RemoveTracker }
end

EHI:ShowAchievementLootCounter({
    achievement = "fex_10",
    job_pass = managers.job:current_job_id() == "fex",
    max = 21,
    load_sync = function(self)
        self._loot:SyncSecuredLootInAchievement("fex_10")
    end,
    show_loot_counter = true,
    loot_counter_on_fail = true,
    silent_failed_on_alarm = true,
    waypoint_loot_counter = { element = { 100233, 100020, 102656, 102735, 102010 } }
})

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 60 })
}
if EHI:GetLoadSniperTrackers() then
    other[100015] = { id = "Snipers", class = TT.Sniper.Count, trigger_once = true, single_player = EHI:IsDifficultyOrBelow(EHI.Difficulties.OVERKILL) }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[102850] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
end
managers.ehi_hudlist:CallRightListItemFunction("Unit", "EnablePersistentSniperItem")

EHI.Mission:ParseTriggers({
    mission = triggers,
    other = other
})
local stealth_objectives =
{
    { amount = 1000, name = "mex4_found_bulucs_office" },
    { amount = 1000, name = "mex4_found_inner_sanctum" },
    { amount = 1000, name = "mex4_discover_keycard_holder_mask_list", optional = true },
    { amount = 1000, name = "mex4_found_keycard", optional = true },
    { amount = 1000, name = "mex4_inner_sanctum_open" },
    { amount = 1000, name = "mex4_codex_room_open" },
    { amount = 10000, name = "mex4_bulucs_office_open" },
    { amount = 1000, name = "mex4_interacted_with_safe" },
    { amount = 2000, name = "mex4_contact_list_stolen" }
}
local loud_objectives =
{
    { amount = 1000, name = "mex4_found_bulucs_office" },
    { amount = 2000, name = "mex4_found_inner_sanctum" },
    { amount = 2000, name = "mex4_found_all_bomb_parts_hack_start" },
    { amount = 2000, name = "mex4_inner_sanctum_open_bomb" },
    { amount = 3000, name = "mex4_saw_placed" },
    { amount = 3000, name = "saw_done" },
    { amount = 4000, name = "mex4_bulucs_office_open" },
    { amount = 1000, name = "mex4_interacted_with_safe" },
    { escape = 1000 }
}
local total_xp_override =
{
    params =
    {
        min_max =
        {
            loot_all = { min = 0, max = 21 }
        }
    }
}
EHI:AddXPBreakdown({
    plan =
    {
        custom =
        {
            {
                name = "stealth",
                additional_name = "mex4_car_escape",
                plan =
                {
                    objectives = stealth_objectives,
                    loot_all = { amount = 500 },
                    total_xp_override = total_xp_override
                },
                objectives_override =
                {
                    add_objectives =
                    {
                        { amount = 2000, name = "mex4_found_car_keys" },
                        { escape = 2000, ghost_bonus = tweak_data.levels:GetLevelStealthBonus() }
                    }
                }
            },
            {
                name = "stealth",
                additional_name = "mex4_boat_escape",
                plan =
                {
                    objectives = stealth_objectives,
                    loot_all = { amount = 500 },
                    total_xp_override = total_xp_override
                },
                objectives_override =
                {
                    add_objectives =
                    {
                        { escape = 1000, ghost_bonus = tweak_data.levels:GetLevelStealthBonus() }
                    }
                }
            },
            {
                name = "loud",
                additional_name = "mex4_car_escape",
                plan =
                {
                    objectives = loud_objectives,
                    loot_all = { amount = 500 },
                    total_xp_override = total_xp_override
                },
                objectives_override =
                {
                    add_objectives_with_pos =
                    {
                        { objective = { amount = 1000, name = "mex4_contact_list_stolen_car_escape" }, pos = 9 },
                        { objective = { amount = 1000, name = "mex4_turret_discovered_car_escape" }, pos = 10 },
                        { objective = { amount = 3000, name = "mex4_turret_destroyed_car_escape" }, pos = 11 }
                    }
                }
            },
            {
                name = "loud",
                additional_name = "mex4_heli_escape",
                plan =
                {
                    objectives = loud_objectives,
                    loot_all = { amount = 500 },
                    total_xp_override = total_xp_override
                },
                objectives_override =
                {
                    add_objectives_with_pos =
                    {
                        { objective = { amount = 3000, name = "mex4_flare_lit_heli_escape" }, pos = 9 }
                    }
                }
            }
        }
    }
})