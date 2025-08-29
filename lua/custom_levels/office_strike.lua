local EHI = EHI
local Icons = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local Status = EHI.Const.Trackers.Achievement.Status
local OVKorAbove = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
---@type ParseTriggerTable
local triggers = {
    --heli_escape_OFF
    [200534] = { special_function = EHI.Trigger:RegisterCustomSyncedSF(function(self, ...)
        self._SyncedSFF.office_strike_escape = "Van"
    end) },
    [200148] = { id = "Escape", special_function = EHI.Trigger:RegisterCustomSF(function(self, trigger, ...)
        if not EHI:IsPlayingFromStart() then -- Not playing from the start, try to determine the escape vehicle
            if self._utils:IsMissionElementDisabled(200171) then -- Heli show sequence is disabled, Van escape it is
                self._SyncedSFF.office_strike_escape = "Van"
            end
        end
        local t, icons, element
        if self._SyncedSFF.office_strike_escape == "Heli" then
            t = 50 + 25 + 6
            icons = Icons.HeliEscape
            element = 200179
        else -- Van
            t = 80
            icons = Icons.CarEscape
            element = 200178
        end
        trigger.time = t
        trigger.icons = icons
        if trigger.waypoint then
            trigger.waypoint.time = t
            trigger.waypoint.icon = icons[1]
            trigger.waypoint.position = self._mission:GetElementPositionOrDefault(element)
        end
        self:CreateTracker()
    end), waypoint = {}, hint = Hints.LootEscape }
}
EHI.Trigger._SyncedSFF.office_strike_escape = "Heli"

---@type ParseAchievementTable
local achievements =
{
    os_powerup =
    {
        difficulty_pass = OVKorAbove,
        elements =
        {
            [200134] = { status = Status.Defend, class = TT.Achievement.Status },
            [100604] = { special_function = SF.SetAchievementComplete },
            [100621] = { special_function = SF.SetAchievementFailed }
        }
    },
    os_terroristswin =
    {
        difficulty_pass = OVKorAbove,
        elements =
        {
            [200106] = { status = Status.Defend, class = TT.Achievement.Status },
            [100606] = { special_function = SF.SetAchievementComplete },
            [100630] = { special_function = SF.SetAchievementFailed }
        }
    },
    os_clearedout =
    {
        difficulty_pass = OVKorAbove,
        elements =
        {
            [200106] = { max = 18, class = TT.Achievement.Progress, special_function = SF.AddAchievementToCounter, data = {
                counter =
                {
                    loot_type = "money"
                }
            }}
        },
        preparse_callback = function(data)
            local trigger = { special_function = SF.DecreaseProgressMax }
            for i = 200502, 200519, 1 do
                data.elements[i] = trigger
            end
        end
    }
}
EHI:PreparseBeardlibAchievements(achievements, "os_achievements")

local other =
{
    [200018] = EHI:AddAssaultDelay({ control = 5 })
}
if EHI:IsLootCounterVisible() then
    other[200106] = EHI:AddLootCounter2(function()
        local servers = EHI:IsMayhemOrAbove() and 2 or 1
        EHI:ShowLootCounterNoChecks({ max = servers + 18, client_from_start = true })
    end, { element = { 200178, 200541 } })
    for i = 200502, 200519, 1 do
        other[i] = EHI:AddCustomCode(function(self)
            self._loot:DecreaseLootCounterProgressMax()
        end)
    end
    other[100092] = EHI:AddCustomCode(function(self)
        self._loot:IncreaseLootCounterProgressMax(5)
    end)
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    -- ! element is Sniper ID (ElementSpawnEnemyDummy)
    local AddToRespawnFromDeath = EHI.Trigger:RegisterCustomSF(function(self, trigger, ...)
        self._trackers:CallFunction("Snipers", "AddToRespawnFromDeath", trigger.element, trigger.time or 65)
    end)
    other[200021] = { special_function = EHI.Trigger:RegisterCustomSF(function(self, ...)
        self._trackers:AddTracker({
            id = "Snipers",
            class = "EHISniperLoopBufferTracker"
        })
        self._trackers:CallFunction("Snipers", "AddToRespawnInitial", 200051, 60)
        self._trackers:CallFunction("Snipers", "AddToRespawnInitial", 200061, 60)
    end), trigger_once = true }
    other[200053] = { element = 200051, special_function = AddToRespawnFromDeath }
    other[200062] = { element = 200061, special_function = AddToRespawnFromDeath }
    other[200588] = { count = 3, id = "Snipers", special_function = SF.IncreaseCounter } -- 3 additional snipers spawned; 0s delay
    other[200079] = { element = 200064, special_function = AddToRespawnFromDeath }
    other[200490] = { element = 200489, special_function = AddToRespawnFromDeath }
    other[200493] = { element = 200492, special_function = AddToRespawnFromDeath }
    other[200139] = { special_function = EHI.Trigger:RegisterCustomSF(function(self, ...)
        self._trackers:CallFunction("Snipers", "AddToRespawnInitial", 100512, 25)
        self._trackers:CallFunction("Snipers", "AddToRespawnInitial", 100515, 25)
    end), trigger_once = true }
    other[100513] = { time = 55, element = 100512, special_function = AddToRespawnFromDeath }
    other[100516] = { time = 55, element = 100515, special_function = AddToRespawnFromDeath }
end

local tbl =
{
    [100241] = { remove_vanilla_waypoint = 200163 },
    [102736] = { remove_vanilla_waypoint = 200175 },
    [103138] = { remove_vanilla_waypoint = 200306 },
    [102770] = { remove_vanilla_waypoint = 200307 },
    [102774] = { remove_vanilla_waypoint = 200308 },
    [102775] = { remove_vanilla_waypoint = 200309 },
    [102776] = { remove_vanilla_waypoint = 200310 }
}
EHI.Unit:UpdateUnits(tbl)
EHI:SetMissionDoorData({
    [Vector3(945.08, 3403.11, 92.4429)] = 200160
})

EHI.Mission:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objective =
    {
        escape = 16000
    },
    loot =
    {
        master_server = 2500,
        money = 850
    },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot =
                {
                    master_server = { min_max = EHI:IsMayhemOrAbove() and 2 or 1 },
                    money = { max = 15 } -- 3 always and 3 random
                }
            }
        }
    }
})