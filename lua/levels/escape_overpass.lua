local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local AddToCache = EHI:GetFreeCustomSpecialFunctionID()
local GetFromCache = EHI:GetFreeCustomSpecialFunctionID()
local triggers = {
    [101148] = { id = "you_shall_not_pass", class = TT.AchievementStatus },
    [102471] = { id = "you_shall_not_pass", special_function = SF.SetAchievementFailed },
    [100426] = { id = "you_shall_not_pass", special_function = SF.SetAchievementComplete },
    [101145] = { time = 180, special_function = GetFromCache, icons = { "pd2_question", Icon.Escape, Icon.LootDrop } },
    [101158] = { time = 240, special_function = GetFromCache, icons = { "pd2_question", Icon.Escape, Icon.LootDrop } },
    [101977] = { special_function = AddToCache, data = { icon = Icon.Heli } },
    [101978] = { special_function = AddToCache, data = { icon = Icon.Heli } },
    [101979] = { special_function = AddToCache, data = { icon = Icon.Car } },
}

if Network:is_client() then
    triggers[101515] = { time = 175, icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101532] = { time = 115, icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[102089] = { time = 60, icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101521] = { time = 30, icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101513] = { time = 175, icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101534] = { time = 115, icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[102090] = { time = 60, icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101571] = { time = 30, icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist }
end

EHI:ParseTriggers(triggers, "Escape")
EHI:RegisterCustomSpecialFunction(AddToCache, function(id, trigger, ...)
    EHI._cache[trigger.id] = trigger.data
end)
EHI:RegisterCustomSpecialFunction(GetFromCache, function(id, trigger, ...)
    local data = EHI._cache[trigger.id]
    EHI._cache[trigger.id] = nil
    if data and data.icon then
        trigger.icons[1] = data.icon
    end
    EHI:CheckCondition(id)
end)