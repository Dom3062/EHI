local EHI, EM = EHI, EHIManager
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local anim_delay = 450/30
local boat_delay = 60 + 30 + 30 + 450/30
local boat_icon = { Icon.Boat, Icon.LootDrop }
local AddToCache = EHI:GetFreeCustomSpecialFunctionID()
local GetFromCache = EHI:GetFreeCustomSpecialFunctionID()
local uno_8 = EHI:GetFreeCustomSpecialFunctionID()
local triggers = {
    [101560] = { time = 35 + 75 + 30 + boat_delay, id = "BoatLootFirst" },
    -- 101127 tracked in 101560
    [101117] = { time = 60 + 30 + boat_delay, id = "BoatLootFirst", special_function = SF.SetTimeOrCreateTracker },
    [101122] = { time = 40 + 30 + boat_delay, id = "BoatLootFirst", special_function = SF.SetTimeOrCreateTracker },
    [101119] = { time = 30 + boat_delay, id = "BoatLootFirst", special_function = SF.SetTimeOrCreateTracker },

    [100323] = { time = 50 + 23, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot },

    [101129] = { time = 180 + anim_delay, special_function = AddToCache },
    [101134] = { time = 150 + anim_delay, special_function = AddToCache },
    [101144] = { time = 130 + anim_delay, special_function = AddToCache },

    [101148] = { icons = boat_icon, special_function = GetFromCache },
    [101149] = { icons = boat_icon, special_function = GetFromCache },
    [101150] = { icons = boat_icon, special_function = GetFromCache },

    [1] = { special_function = SF.RemoveTrigger, data = { 101148, 101149, 101150, 1 }},

    [1011480] = { additional_time = 130 + anim_delay, random_time = 50 + anim_delay, id = "BoatLootDropReturnRandom", icons = boat_icon, class = TT.Inaccurate },

    [100124] = { special_function = SF.CustomCode, f = function()
        local bags = managers.ehi_tracker:CountLootbagsOnTheGround(10)
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
    local SetTrackerAccurate = EHI:GetFreeCustomSpecialFunctionID()
    local boat_return = { time = anim_delay, id = "BoatLootDropReturnRandom", id2 = "BoatLootDropReturn", id3 = "BoatLootFirst", special_function = SetTrackerAccurate }
    triggers[100470] = boat_return
    triggers[100472] = boat_return
    triggers[100474] = boat_return
    EHI:RegisterCustomSpecialFunction(SetTrackerAccurate, function(self, trigger, ...)
        if self._trackers:TrackerExists(trigger.id) then
            self._trackers:SetTrackerAccurate(trigger.id, trigger.time)
        elseif not (self._trackers:TrackerExists(trigger.id2) or self._trackers:TrackerExists(trigger.id3)) then
            self:CheckCondition(trigger)
        end
    end)
end

local achievements =
{
    uno_8 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [100124] = { status = "defend", class = TT.AchievementStatus, special_function = uno_8 },
            [102382] = { special_function = SF.SetAchievementFailed },
            [102379] = { special_function = SF.SetAchievementComplete }
        },
        cleanup_callback = function()
            EHI:UnregisterCustomSpecialFunction(uno_8)
        end
    }
}

local other =
{
    [100124] = EHI:AddLootCounter(function()
        local bags = managers.ehi_tracker:CountLootbagsOnTheGround(10)
        EHI:ShowLootCounterNoCheck({ max = bags })
    end)
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
}, "BoatLootDropReturn", boat_icon)
EHI:RegisterCustomSpecialFunction(AddToCache, function(self, trigger, ...)
    EHI._cache[trigger.id] = trigger.time
end)
EHI:RegisterCustomSpecialFunction(GetFromCache, function(self, trigger, ...)
    local t = EHI._cache[trigger.id]
    EHI._cache[trigger.id] = nil
    if t then
        trigger.time = t
        self:CheckCondition(trigger)
        trigger.time = nil
    else
        self:CheckCondition(triggers[1011480])
    end
end)
EHI:RegisterCustomSpecialFunction(uno_8, function(self, trigger, ...)
    local bags = managers.ehi_tracker:CountLootbagsOnTheGround(10)
    if bags == 12 then
        self:CheckCondition(trigger)
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
                max =
                {
                    watchdogs_bonus_xp = { times = 9 }
                }
            }
        }
    }
})