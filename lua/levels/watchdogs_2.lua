local EHI, EM = EHI, EHIManager
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local WT = EHI.Waypoints
local Hints = EHI.Hints
local anim_delay = 450/30
local boat_delay = 60 + 30 + 30 + 450/30
local boat_icon = { Icon.Boat, Icon.LootDrop }
local AddToCache = EHI:GetFreeCustomSFID()
local GetFromCache = EHI:GetFreeCustomSFID()
local BoatPos = 0
local WPPos =
{
    [7] = Vector3(2991.02, 3771, -58),
    [8] = Vector3(5466, 202, -84),
    [9] = Vector3(3859, -2798, -74.5352)
}
---@param self EHIManager
---@param trigger ElementTrigger
local function waypoint_f(self, trigger)
    if BoatPos == 0 then
        return
    end
    self._waypoints:AddWaypoint(trigger.id, {
        time = trigger.time,
        icon = Icon.LootDrop,
        position = WPPos[BoatPos],
        class = trigger.additional_time and WT.Inaccurate
    })
end
local function SetBoatPos(pos)
    BoatPos = pos
end
local SetBoatPosFromElement = EHI:RegisterCustomSF(function(self, trigger, element, ...)
    BoatPos = element._values.amount + 6
end)
---@type ParseTriggerTable
local triggers = {
    [101560] = { time = 35 + 75 + 30 + boat_delay, id = "BoatLootFirst", waypoint_f = waypoint_f, hint = Hints.Loot },
    -- 101127 tracked in 101560
    [101117] = { time = 60 + 30 + boat_delay, id = "BoatLootFirst", special_function = SF.SetTimeOrCreateTracker, waypoint_f = waypoint_f, hint = Hints.Loot },
    [101122] = { time = 40 + 30 + boat_delay, id = "BoatLootFirst", special_function = SF.SetTimeOrCreateTracker, waypoint_f = waypoint_f, hint = Hints.Loot },
    [101119] = { time = 30 + boat_delay, id = "BoatLootFirst", special_function = SF.SetTimeOrCreateTracker, waypoint_f = waypoint_f, hint = Hints.Loot },

    [100474] = { special_function = SF.CustomCode, f = SetBoatPos, arg = 7 },
    [100472] = { special_function = SF.CustomCode, f = SetBoatPos, arg = 8 },
    [100470] = { special_function = SF.CustomCode, f = SetBoatPos, arg = 9 },

    [101553] = { special_function = SetBoatPosFromElement }, -- 1
    [101554] = { special_function = SetBoatPosFromElement }, -- 2
    [101555] = { special_function = SetBoatPosFromElement }, -- 3 

    [100323] = { time = 50 + 23, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, hint = Hints.Escape },

    [101129] = { time = 180 + anim_delay, special_function = AddToCache },
    [101134] = { time = 150 + anim_delay, special_function = AddToCache },
    [101144] = { time = 130 + anim_delay, special_function = AddToCache },

    [101148] = { icons = boat_icon, special_function = GetFromCache, waypoint_f = waypoint_f },
    [101149] = { icons = boat_icon, special_function = GetFromCache, waypoint_f = waypoint_f },
    [101150] = { icons = boat_icon, special_function = GetFromCache, waypoint_f = waypoint_f },

    [1] = { special_function = SF.RemoveTrigger, data = { 101148, 101149, 101150, 1 }},

    [1011480] = { additional_time = 130 + anim_delay, random_time = 50 + anim_delay, id = "BoatLootDropReturnRandom", icons = boat_icon, waypoint_f = waypoint_f, hint = Hints.Loot },

    [100124] = { special_function = SF.CustomCode, f = function()
        local bags = managers.ehi_manager:CountLootbagsOnTheGround(10)
        if bags % 4 == 0 then -- 4/8/12
            local trigger = bags - 3
            EHI:AddCallback(EHI.CallbackMessage.LootSecured, function(self)
                if self:GetSecuredBagsAmount() == trigger then
                    EM:Trigger(1)
                end
            end)
        end
    end}
}
if EHI:IsClient() then
    local boat_return = { time = anim_delay, id = "BoatLootDropReturnRandom", id2 = "BoatLootDropReturn", id3 = "BoatLootFirst", special_function = EHI:RegisterCustomSF(function(self, trigger, ...)
        if self:Exists(trigger.id) then
            self:SetAccurate(trigger.id, trigger.time)
        elseif not (self:Exists(trigger.id2) or self:Exists(trigger.id3)) then
            self:CheckCondition(trigger)
        end
    end), waypoint_f = waypoint_f, hint = Hints.Loot }
    triggers[100686] = boat_return
    triggers[100695] = boat_return
    triggers[100704] = boat_return
end

---@type ParseAchievementTable
local achievements =
{
    uno_8 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [100124] = { status = "defend", class = TT.Achievement.Status, special_function = EHI:RegisterCustomSF(function(self, trigger, ...)
                local bags = self:CountLootbagsOnTheGround(10)
                if bags == 12 then
                    self:CheckCondition(trigger)
                end
            end) },
            [102382] = { special_function = SF.SetAchievementFailed },
            [102379] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [100124] = EHI:AddLootCounter(function()
        local bags = managers.ehi_manager:CountLootbagsOnTheGround(10)
        EHI:ShowLootCounterNoCheck({ max = bags })
    end),
    [103696] = EHI:AddAssaultDelay({ time = 5 + 15 + 30 })
}
if EHI:GetOption("show_sniper_tracker") then
    other[100457] = { time = 23 + 1, id = "Snipers", icons = { "snipers" }, class = TT.Warning, hint = Hints.EnemySnipers }
    if EHI:GetOption("show_sniper_spawned_popup") then
        other[100528] = { special_function = SF.CustomCode, f = function()
            managers.hud:ShowSnipersSpawned() -- 2 snipers spawn
        end}
    end
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
}, "BoatLootDropReturn", boat_icon)
EHI:RegisterCustomSF(AddToCache, function(self, trigger, ...)
    EHI._cache[trigger.id] = trigger.time
end)
EHI:RegisterCustomSF(GetFromCache, function(self, trigger, ...)
    local t = EHI._cache[trigger.id]
    EHI._cache[trigger.id] = nil
    if t then
        trigger.time = t --[[@as number]]
        self:CheckCondition(trigger)
        trigger.time = nil
    else
        self:CheckCondition(triggers[1011480])
    end
end)
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 1500, name = "watchdogs_bonus_xp" },
        { escape = 12000 },
    },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                objectives =
                {
                    watchdogs_bonus_xp = { max = 9 }
                }
            }
        }
    }
})