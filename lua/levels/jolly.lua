local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local c4_drop = { time = 120 + 25 + 0.25 + 2, id = "C4Drop", icons = Icon.HeliDropC4 }
local c4_wp = Vector3(0, 0, 50)
local vectors =
{ -- The rotation is taken directly from the game by Lua (it is not the same as in the decompiled mission script)
    [26550] = EHI:GetInstanceElementPosition(Vector3(1175.0, -1375.0, -12.6262), c4_wp, Rotation(-44.9999, 0, 0)),
    [26650] = EHI:GetInstanceElementPosition(Vector3(6325.0, 2325.0, 0.0), c4_wp, Rotation(0, 0, -0)),
    [26750] = EHI:GetInstanceElementPosition(Vector3(2425.0, 4325.0, 1201.0), c4_wp, Rotation(44.9999, 0, -0)),
    [26850] = EHI:GetInstanceElementPosition(Vector3(925.0, 10575.0, -12.6262), c4_wp, Rotation(-135, 0, -0)),
    [26950] = EHI:GetInstanceElementPosition(Vector3(1550.0, 925.0, 1200.0), c4_wp, Rotation(135, 0, -0))
}
local SF_HeliTimer = EHI:GetFreeCustomSpecialFunctionID()
local triggers = {
    -- Why in the flying fuck, OVK, you decided to execute the timer AFTER the dialogue has finished ?
    -- You realize how much pain this is to account for ?
    -- I'm used to bullshit, but this is next level; 10/10 for effort
    -- I hope you are super happy with what you have pulled off
    -- And I'm fucking happy I have to check EVERY FUCKING DIALOG the pilot says TO STAY ACCURATE WITH THE TIMER
    --
    -- Reported in:
    -- https://steamcommunity.com/app/218620/discussions/14/3182362958583578588/
    [1] = {
        [1] = 5 + 8,
        [2] = 8
    },
    [101644] = { time = 60, id = "BainWait", icons = { Icon.Wait } },
    [EHI:GetInstanceElementID(100075, 21250)] = { time = 60 + 60 + 60 + 20, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF_HeliTimer, dialog = 1 },
    [EHI:GetInstanceElementID(100076, 21250)] = { time = 60 + 60 + 20, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF_HeliTimer, dialog = 2 },
    [100795] = { time = 5, id = "C4", icons = { "pd2_c4" } },

    [101240] = c4_drop,
    [101241] = c4_drop,
    [101242] = c4_drop,
    [101243] = c4_drop,
    [101249] = c4_drop,
}
for i = 26550, 26950, 100 do
    triggers[EHI:GetInstanceElementID(100003, i)] = { id = EHI:GetInstanceElementID(100021, i), special_function = SF.ShowWaypoint, data = { icon = "pd2_c4", position = vectors[i] }}
end

if Network:is_client() then
    triggers[EHI:GetInstanceElementID(100078, 21250)] = { time = 60 + 20, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[EHI:GetInstanceElementID(100051, 21250)] = { time = 20, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF.AddTrackerIfDoesNotExist }
end

EHI:ParseTriggers(triggers)
EHI:RegisterCustomSpecialFunction(SF_HeliTimer, function(id, trigger, element, enabled)
    if not managers.user:get_setting("mute_heist_vo") then
        local delay_fix = triggers[1][trigger.dialog] or 0
        trigger.time = trigger.time + delay_fix
    end
    if managers.ehi:TrackerExists(trigger.id) then
        managers.ehi:SetTrackerTimeNoAnim(trigger.id, trigger.time)
    else
        EHI:CheckCondition(id)
    end
end)