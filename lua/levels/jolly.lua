local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local Hints = EHI.Hints
local EscapeWP = { data_from_element = EHI:GetInstanceElementID(100029, 21250) }
-- Why in the flying fuck, OVK, you decided to execute the timer AFTER the dialogue has finished ?  
-- You realize how much pain this is to account for ?  
-- I'm used to bullshit, but this is next level; 10/10 for effort  
-- I hope you are super happy with what you have pulled off  
-- And I'm fucking happy I have to check EVERY FUCKING DIALOG the pilot says TO STAY ACCURATE WITH THE TIMER  
--
-- Reported in:  
-- https://steamcommunity.com/app/218620/discussions/14/3182362958583578588/
local HeliTimer = EHI.Trigger:RegisterCustomSF(function(self, trigger, ...)
    local t_correction =
    {
        [1] = 5 + 8,
        [2] = 8
    }
    if not managers.user:get_setting("mute_heist_vo") then
        local delay_fix = t_correction[trigger.dialog] or 0
        trigger.time = trigger.time + delay_fix
        if trigger.waypoint then
            trigger.waypoint.time = trigger.time
        end
    end
    if self._tracking:Exists(trigger.id) then
        self._tracking:SetTimeNoAnim(trigger.id, trigger.time)
    else
        self:CreateTracking()
    end
end)
local triggers = {
    [101644] = { time = 60, id = "BainWait", icons = { Icon.Wait }, hint = Hints.Wait },
    [EHI:GetInstanceElementID(100075, 21250)] = { time = 60 + 60 + 60 + 20, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = HeliTimer, dialog = 1, waypoint = deep_clone(EscapeWP), hint = Hints.Escape },
    [EHI:GetInstanceElementID(100076, 21250)] = { time = 60 + 60 + 20, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = HeliTimer, dialog = 2, waypoint = deep_clone(EscapeWP), hint = Hints.Escape },
    [EHI:GetInstanceElementID(100078, 21250)] = { time = 60 + 20, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF.SetTimeOrCreateTracker, waypoint = deep_clone(EscapeWP), hint = Hints.Escape },
    [100795] = { time = 5, id = "C4", icons = { Icon.C4 }, waypoint = { position_from_element = 100804 }, hint = Hints.Explosion }

    -- C4 Drop handled in CoreWorldInstanceManager
}
if EHI.IsClient then
    triggers[EHI:GetInstanceElementID(100051, 21250)] = { time = 20, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF.AddTrackerIfDoesNotExist, waypoint = deep_clone(EscapeWP), hint = Hints.Escape }
end

local other =
{
    [100217] = EHI:AddAssaultDelay({ control = 30, trigger_once = true }) -- Starting the saw early forces the assault to start
}

EHI.Mission:ParseTriggers({ mission = triggers, other = other })

EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 8000, name = "van_open" },
        { amount = 6000, name = "c4_set_up" }, -- Wall blown up
        { escape = 6000 }
    },
    loot_all = { amount = 500, text = "each_safe_secured" },
    total_xp_override =
    {
        objectives =
        {
            van_open = { times = 2 }
        },
        loot_all = { times = 4 + (2 * math.min(EHI:DifficultyIndex(), 4)) }
    }
})