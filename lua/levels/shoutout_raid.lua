local EHI = EHI
EHIVaultTemperatureTracker = class(EHITracker)
EHIVaultTemperatureTracker._forced_icons = { EHI.Icons.Vault }
function EHIVaultTemperatureTracker:init(panel, params)
    params.time = 500
    self._synced_time = 0
    self._tick = 0.1
    EHIVaultTemperatureTracker.super.init(self, panel, params)
end

function EHIVaultTemperatureTracker:CheckTime(time)
    if self._synced_time == 0 then
        self._time = (50 - time) * 10
    else
        local new_tick = time - self._synced_time
        if new_tick ~= self._tick then
            self._time = ((50 - time) / (new_tick * 10)) * 10
            self._tick = new_tick
        end
    end
    self._synced_time = time
end

EHIVaultTemperatureWaypoint = class(EHIWaypoint)
EHIVaultTemperatureWaypoint.CheckTime = EHIVaultTemperatureTracker.CheckTime
function EHIVaultTemperatureWaypoint:init(waypoint, params)
    EHIVaultTemperatureWaypoint.super.init(self, waypoint, params)
    self._synced_time = 0
    self._tick = 0.1
end

local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local trophy = {
    [100107] = { time = 420, id = "trophy_longfellow", class = TT.Trophy, condition = ovk_and_up }
}

EHI:ParseTriggers({
    mission = {},
    trophy = trophy
})
if EHI:ShowMissionAchievements() then
    EHI:ShowAchievementLootCounter({
        achievement = "melt_3",
        max = 8,
        counter =
        {
            check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
            loot_type = { "coke", "gold", "money", "weapon", "weapons" }
        }
    })
end

local max = 6 -- Normal to Very Hard; Mission Loot
if ovk_and_up then
    max = 8
end
EHI:ShowLootCounter({
    max = max,
    additional_loot = 8
}) -- 14 or 16

local tbl =
{
    --levels/instances/unique/shout_container_vault
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    [EHI:GetInstanceElementID(100014, 2850)] = { ignore = true }
}
EHI:UpdateUnits(tbl)