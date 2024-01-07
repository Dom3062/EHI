local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local SetTimeIfEnabled = EHI:RegisterCustomSF(function(self, trigger, element, enabled)
    if enabled then
        if self._trackers:TrackerExists(trigger.id) then
            self._trackers:SetTrackerTime(trigger.id, trigger.time)
        else
            self:CheckCondition(trigger)
        end
    end
end)
local EscapeWaypoint = { id = EHI:GetInstanceElementID(100043, 2900), special_function = EHI:RegisterCustomSF(function(self, trigger, ...)
    trigger.data.distance = true
    trigger.data.state = "sneak_present"
    trigger.data.present_timer = 0
    trigger.data.no_sync = true
    local e = managers.mission:get_element_by_id(trigger.id --[[@as number]])
    trigger.data.position = e and e._values.position or Vector3()
    managers.hud:add_waypoint(trigger.id, trigger.data)
end), data = { icon = Icon.Car } }
local triggers = {
    [100918] = { time = 11 + 3.5 + 100 + 1330/30, id = "Escape", icons = Icon.CarEscape, hint = Hints.LootEscape },
    [101892] = EscapeWaypoint,
    [101727] = { time = 1283/30, id = "Escape", icons = Icon.CarEscape, special_function = SetTimeIfEnabled, hint = Hints.LootEscape },
    [101933] = EscapeWaypoint,
    [101706] = { time = 895/30, id = "Escape", icons = Icon.CarEscape, special_function = SetTimeIfEnabled, hint = Hints.LootEscape },
    [101394] = EscapeWaypoint,
    [105792] = { time = 20, id = "FireApartment1", icons = { Icon.Fire, Icon.Wait }, hint = Hints.Wait },
    [105804] = { time = 20, id = "FireApartment2", icons = { Icon.Fire, Icon.Wait }, hint = Hints.Wait },
    [105824] = { time = 20, id = "FireApartment3", icons = { Icon.Fire, Icon.Wait }, hint = Hints.Wait },
    [105840] = { time = 20, id = "FireApartment4", icons = { Icon.Fire, Icon.Wait }, hint = Hints.Wait }
}

if EHI:IsClient() then
    triggers[101748] = { time = 1330/30, id = "Escape", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape }
end

---@type ParseAchievementTable
local achievements =
{
    peta_2 =
    {
        elements =
        {
            [EHI:GetInstanceElementID(100010, 2900)] = { time = 60, class = TT.Achievement.Base },
            [EHI:GetInstanceElementID(100080, 2900)] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 60 + 30 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    local sniper_count = EHI:GetValueBasedOnDifficulty({
        veryhard_or_below = 2,
        overkill_or_above = 3
    })
    other[100015] = { chance = 10, time = 1 + 10 + 25, on_fail_refresh_t = 25, on_success_refresh_t = 20 + 10 + 25, id = "Snipers", class = TT.Sniper.Loop, sniper_count = sniper_count }
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

local GoatsToSecure = EHI:GetValueBasedOnDifficulty({
    normal = 5,
    hard = 7,
    veryhard = 10,
    overkill = 13,
    mayhem_or_above = 15
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 3000, name = "gs_start", optional = true }, -- 2 * 1500
        { amount = 1500, name = "gs_drill_open_store" },
        { amount = 1500, name = "gs_turn_off_powerbox" },
        { amount = 1500, name = "gs_clear_fire_debris" },
        { amount = 1500, name = "gs_saw_lightpost" }
    },
    loot_all = { amount = 1500, text = "each_goat_secured" },
    total_xp_override =
    {
        params =
        {
            objectives =
            {
                gs_clear_fire_debris = { times = 2 }
            },
            loot_all = { times = GoatsToSecure }
        }
    }
})
if EHI:IsHost() then
    managers.ehi_experience:MissionXPAwarded(3000)
end