local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local BoatEscape = { Icon.Boat, Icon.Escape, Icon.LootDrop }
--local FirstAssaultDelay = { { icon = "assaultbox", color = Color(1, 1, 0) } }
local boat_anim = 614/30
local skid = { { icon = Icon.Car, color = Color("1E90FF") } }
local sand_9_buttons = { id = "sand_9_buttons", special_function = SF.IncreaseProgress }
local ExecuteIfProgressMatch = EHI:GetFreeCustomSpecialFunctionID()
local triggers = {
    -- Players spawned
    [100107] = { special_function = SF.Trigger, data = { 1001071, 1001072, 1001073, 1001074 } },
    [1001071] = { max = 10, id = "sand_9", remove_after_reaching_target = false, class = TT.AchievementProgress },
    [1001072] = { max = 3, id = "sand_9_buttons", icons = { "pd2_generic_interact" }, class = TT.Progress, special_function = SF.ShowAchievementCustom, data = "sand_9" },
    -- Counter is bugged. Teaset is counted too.
    -- Reported in:
    -- https://steamcommunity.com/app/218620/discussions/14/3182363463067457019/
    [1001073] = { special_function = SF.CustomCode, f = function()
        EHI:AddAchievementToCounter({
            achievement = "sand_9"
        })
    end },
    [1001074] = { max = 8, id = "sand_10", class = TT.AchievementProgress },
    [103161] = sand_9_buttons,
    [101369] = { special_function = ExecuteIfProgressMatch },
    [103167] = sand_9_buttons,
    [103175] = sand_9_buttons,
    [103208] = { id = "sand_9", special_function = SF.FinalizeAchievement },

    --[100129] = { time = 30, id = "FirstAssaultDelay", icons = FirstAssaultDelay, class = TT.Warning },

    [EHI:GetInstanceElementID(100045, 7100)] = { time = 5, id = "RoomHack", icons = { "wp_hack" } },

    [EHI:GetInstanceElementID(100043, 4800)] = { special_function = SF.Trigger, data = { 1000431, 1000432 } },
    [1000431] = { time = 15, id = "DoorOpenGas", icons = { "pd2_door" } },
    [1000432] = { time = 20, random_time = 5, id = "RoomGas", icons = { Icon.Teargas } },

    --[103157] = { time = 710/30, id = "SkidDriving1", icons = skid },
    [103333] = { time = 613/30, id = "SkidDriving2", icons = skid },
    [103178] = { time = 386/30, id = "SkidDriving3", icons = skid },
    [104043] = { time = 28, id = "SkidDriving4", icons = skid }, -- More accurate
    [104101] = { time = 7, id = "SkidDriving5", icons = skid }, -- 100704; More accurate
    [104102] = { time = 477/30, id = "SkidDriving6", icons = skid },
    [104233] = { time = 30, id = "SkidDriving7", icons = skid }, -- More accurate
    [104262] = { time = 549/30, id = "SkidDriving8", icons = skid },
    [104304] = { time = 40, id = "SkidDriving9", icons = skid }, -- More accurate
    [103667] = { time = 1399/30, id = "SkidDriving10", icons = skid },
    [100782] = { time = 18, id = "SkidDriving11", icons = skid }, -- More accurate
    [104227] = { time = 37, id = "SkidDriving12", icons = skid }, -- More accurate
    [104305] = { time = 25, id = "SkidDriving13", icons = skid }, -- More accurate
    [101009] = { time = 210/30, id = "RampRaise", icons = { "faster" } },
    [101799] = { time = 181/30, id = "RampLower", icons = { "faster" } },

    [104528] = { time = 22, id = "Crane", icons = { "equipment_winch_hook" } }, -- 104528 -> 100703

    [103870] = { chance = 34, id = "ReviveVlad", icons = { "equipment_defibrillator" }, class = TT.Chance, special_function = SF.AddTrackerIfDoesNotExist },
    [103871] = { id = "ReviveVlad", special_function = SF.RemoveTracker },

    [103925] = { id = "BoatEscape", icons = BoatEscape, special_function = SF.MEX_CheckIfLoud, data = { yes = 30 + boat_anim + 12 + 1, no = 19 + boat_anim + 12 + 1 } }
}
local time = 5 -- Normal
if EHI:IsBetweenDifficulties("hard", "very_hard") then
    -- Hard + Very Hard
    time = 15
elseif EHI:IsDifficulty("overkill") then
    -- OVERKILL
    time = 20
elseif EHI:IsBetweenDifficulties("mayhem", "death_wish") then
    -- Mayhem + Death Wish
    time = 30
elseif EHI:IsDifficulty("death_sentence") then
    -- Death Sentence
    time = 40
end
for _, index in pairs({8530, 9180, 9680}) do
    triggers[EHI:GetInstanceElementID(100176, index)] = { time = 30, id = "KeypadRebootECM", icons = { "restarter" } } -- ECM Jammer
    triggers[EHI:GetInstanceElementID(100210, index)] = { time = 3 + time, id = "KeypadReboot", icons = { "restarter" } }
end
for i = 105290, 105329, 1 do
    triggers[i] = { id = "sand_10", special_function = SF.IncreaseProgress }
end
for i = 16580, 16780, 100 do
    triggers[EHI:GetInstanceElementID(100057, i)] = { amount = 33, id = "ReviveVlad", special_function = SF.IncreaseChance }
end

local DisableWaypoints =
{
    -- sand_chinese_computer_hackable
    [EHI:GetInstanceElementID(100018, 15680)] = true, -- Defend
    -- Interact is in CoreWorldInstanceManager.lua
    -- sand_server_hack
    -- levels/instances/unique/sand/sand_server_hack/001 is used, others are not
    [EHI:GetInstanceElementID(100018, 14280)] = true, -- Fix
    -- Interact is in CoreWorldInstanceManager.lua
    -- sand_defibrillator
    [EHI:GetInstanceElementID(100051, 16580)] = true, -- Wait
    [EHI:GetInstanceElementID(100051, 16680)] = true, -- Wait
    [EHI:GetInstanceElementID(100051, 16780)] = true -- Wait
}

EHI:ParseTriggers(triggers)
EHI:DisableWaypoints(DisableWaypoints)
EHI:RegisterCustomSpecialFunction(ExecuteIfProgressMatch, function(...)
    local tracker = managers.ehi:GetTracker("sand_9_buttons")
    if tracker and tracker:GetProgress() == 0 then
        managers.ehi:RemoveTracker("sand_9_buttons")
        managers.ehi:SetAchievementFailed("sand_9")
    end
end)