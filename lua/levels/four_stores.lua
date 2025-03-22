local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local van_anim_delay = 320 / 30
local preload =
{
    { hint = EHI.Hints.LootEscape } -- Escape
}
local triggers = {
    -- Time before escape vehicle arrives
    [102492] = { run = { time = 40 + van_anim_delay } },
    [102493] = { run = { time = 30 + van_anim_delay } },
    [102494] = { run = { time = 20 + van_anim_delay } },
    [102495] = { run = { time = 50 + van_anim_delay } },
    [102496] = { run = { time = 60 + van_anim_delay } },
    [102497] = { run = { time = 70 + van_anim_delay } },
    [102498] = { run = { time = 100 + van_anim_delay } },
    [102499] = { run = { time = 90 + van_anim_delay } },
    [102511] = { run = { time = 80 + van_anim_delay } },
    [102512] = { run = { time = 110 + van_anim_delay } },
    [102513] = { run = { time = 120 + van_anim_delay } },
    [102526] = { run = { time = 130 + van_anim_delay } },
    [103592] = { run = { time = 160 + van_anim_delay } },
    [103593] = { run = { time = 180 + van_anim_delay } },
    [103594] = { run = { time = 200 + van_anim_delay } },

    [101443] = { special_function = EHI.Manager:RegisterCustomSF(function(self, ...)
        self._trackers:AddTracker({
            id = "ObjectiveSteal",
            max = 15000,
            icons = { Icon.Money },
            flash_times = 1,
            hint = "four_stores",
            class = self.Trackers.NeededValue
        })
        self._loot:AddListener("four_stores", function(loot)
            local progress = loot:get_real_total_small_loot_value()
            self._trackers:SetTrackerProgress("ObjectiveSteal", progress)
            if progress >= 15000 then
                self._loot:RemoveListener("four_stores")
            end
        end)
    end), trigger_once = true },

    [103629] = EHI:AddIncomingTurret(540/30, Vector3(0.425327, -3362.29, 254.634), nil, nil, _G.ch_settings == nil)
}
EHI.Manager:AddLoadSyncFunction(function(self)
    local objective = managers.loot:get_real_total_small_loot_value()
    if objective >= 15000 then
        return
    end
    self:Trigger(101443)
    self._trackers:SetTrackerProgress("ObjectiveSteal", objective)
end)

local CopArrivalDelay = EHI:GetValueBasedOnDifficulty({
    normal = 30,
    hard = 20,
    veryhard = 10,
    overkill_or_above = 0
})
local FirstAssaultBreak = 15 + 2.5 + 3 + 2 + 30 + 20
local other =
{
    [101167] = EHI:AddAssaultDelay({ control = FirstAssaultBreak, special_function = SF.AddTrackerIfDoesNotExist, trigger_once = true }), -- 15s (55s delay)
    [101166] = EHI:AddAssaultDelay({ control = FirstAssaultBreak - 5, special_function = SF.SetTimeOrCreateTracker, trigger_once = true }), -- 10s (65s delay)
    [101159] = EHI:AddAssaultDelay({ control = FirstAssaultBreak - 2, special_function = SF.SetTimeOrCreateTracker, trigger_once = true }) -- 13s (60s delay)
}
if CopArrivalDelay > 0 then
    other[103278] = EHI:AddAssaultDelay({ control = FirstAssaultBreak + CopArrivalDelay, trigger_once = true }) -- Full assault break; 15s (55s delay)
end
if EHI:IsEscapeChanceEnabled() then
    other[103501] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi_escape:AddEscapeChanceTracker(dropin, 30)
    end)
end
if EHI:IsLootCounterVisible() then
    other[101479] = EHI:AddLootCounter3(function(self)
        EHI:ShowLootCounterNoChecks({ max = 1, client_from_start = true })
        self._loot:WaypointFunctionCheck() -- Loot bag is present on the map, show the Loot Waypoint once escape is available (overrides default behavior down below); will also work during load sync
    end, { element = { 101006, 103234 }, check_function = function(progress, max)
        return false -- Return false because the loot bag is random => to not show Loot Waypoint once escape is available (default behavior)
    end }, function(self)
        if self:IsMissionElementDisabled(101804) and managers.loot:GetSecuredBagsAmount() == 0 then
            self:Trigger(101479)
        end
    end)
end
if EHI:GetWaypointOption("show_waypoints_escape") then
    other[102505] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 101006 } }
    other[103200] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 103234 } }
end
EHI.Manager:ParseTriggers({ mission = triggers, other = other, preload = preload }, "Escape", Icon.CarEscape)
EHI:AddXPBreakdown({
    objective =
    {
        escape =
        {
            { amount = 6000, stealth = true },
            { amount = 6000, loud = true, escape_chance = { start_chance = 30, kill_add_chance = 5 } }
        }
    },
    no_total_xp = true
})