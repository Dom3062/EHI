local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
---@type ParseTriggerTable
local triggers = {
    [100322] = { time = 120, id = "Fuel", icons = { Icon.Oil }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists, waypoint = { data_from_element_and_remove_vanilla_waypoint = EHI:GetInstanceElementID(100038, 8075) }, hint = EHI.Hints.FuelTransfer },
    [100323] = { id = "Fuel", special_function = SF.PauseTracker }
}

if EHI.IsClient then
    triggers[100047] = EHI:ClientCopyTrigger(triggers[100322], { time = 60 })
    triggers[100049] = EHI:ClientCopyTrigger(triggers[100322], { time = 30 })
end

local DisableWaypoints = {}

for i = 6850, 7525, 225 do
    DisableWaypoints[EHI:GetInstanceElementID(100021, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100022, i)] = true -- Fix
end

---@type ParseAchievementTable
local achievements =
{
    wwh_9 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100012] = { status = EHI.Const.Trackers.Achievement.Status.Defend, class = TT.Achievement.Status },
            [101250] = { special_function = SF.SetAchievementFailed },
            [100082] = { special_function = SF.SetAchievementComplete },
        }
    },
    wwh_10 =
    {
        elements =
        {
            [100946] = { max = 4, class = TT.Achievement.Progress },
            [101226] = { special_function = SF.IncreaseProgress }
        }
    }
}
if EHI:CanShowAchievement2("cac_27", "show_achievements_weapon") then -- "Global Warming"
    EHI:AddOnSpawnedExtendedCallback(function(self, job, level, from_beginning)
        if job == "wwh" then
            local cac_27 = tweak_data.achievement.complete_heist_achievements.cac_27
            if managers.challenge:check_equipped_team(cac_27) then
                managers.ehi_unlockable:AddAchievementStatusTracker("cac_27")
                local function fail()
                    managers.ehi_unlockable:SetAchievementFailed("cac_27")
                    EHI:Unhook("cac_27__used_weapon")
                    EHI:Unhook("cac_27_killed_by_anyone")
                    EHI:Unhook("cac_27_set_outfit_string")
                end
                Hooks:PostHook(StatisticsManager, "_used_weapon", "EHI_cac_27__used_weapon", function(stat, weapon_id)
                    if tweak_data:get_raw_value("weapon", stat:create_unified_weapon_name(weapon_id), "categories", 1) ~= "flamethrower" then
                        fail()
                    end
                end)
                Hooks:PostHook(StatisticsManager, "killed_by_anyone", "EHI_cac_27_killed_by_anyone", function(stat, data, ...)
                    local _, throwable_id = stat:_get_name_id_and_throwable_id(data.weapon_unit)
                    if data.variant == "melee" or data.variant == "explosion" or data.is_molotov or throwable_id then
                        fail()
                    end
                end)
                Hooks:PostHook(NetworkPeer, "set_outfit_string", "EHI_cac_27_set_outfit_string", function(...)
                    managers.ehi_unlockable:SetAchievementStatus("cac_27", managers.challenge:check_equipped_team(cac_27) and "ok" or "fail")
                end)
            end
        end
    end)
end

local other =
{
    [100946] = EHI:AddAssaultDelay({}) -- 30s
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100374] = { id = "Snipers", single_sniper = true, remaining_snipers = 8, class = TT.Sniper.Count }
    other[100375] = { id = "Snipers", sniper_count = 2, remaining_snipers = 8, class = TT.Sniper.Count }
    other[100376] = { id = "Snipers", sniper_count = 3, remaining_snipers = 8, class = TT.Sniper.Count }
    other[100513] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
    other[100516] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100517] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI.Mission:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    assault = { diff = 1 }
})
EHI.Waypoint:DisableTimerWaypoints(DisableWaypoints)
local wp_params = { element = {} }
for i = 1050, 3525, 225 do
    if i ~= 2175 then -- Different instance
        table.insert(wp_params.element, EHI:GetInstanceElementID(100031, i))
    end
end
EHI:ShowLootCounter({ max = 8 }, wp_params)
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 2000, name = "alaskan_deal_crew_saved" },
        { amount = 5000, name = "alaskan_deal_captain_reached_boat" },
        { amount = 6000, name = "alaskan_deal_boat_fueled" },
        { escape = 1000 }
    },
    loot =
    {
        money = 400,
        weapon = 600
    },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot =
                {
                    money = { max = 4 },
                    weapon = { max = 4 }
                }
            }
        }
    }
})