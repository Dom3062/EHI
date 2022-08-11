local Color = Color
EHIsand11Tracker = class(EHIProgressTracker)
function EHIsand11Tracker:init(panel, params)
    params.icons = EHI:GetAchievementIcon("sand_11")
    params.max = 100
    params.remove_after_reaching_target = false
    self._chance = 0
    EHIsand11Tracker.super.init(self, panel, params)
end

function EHIsand11Tracker:OverridePanel(params)
    self._panel:set_w(self._panel:w() * 2)
    self._time_bg_box:set_w(self._time_bg_box:w() * 2)
    self._text_chance = self._time_bg_box:text({
        name = "time_text",
        text = self:FormatChance(),
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w() / 2,
        h = self._time_bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
        font_size = self._panel:h() * self._text_scale,
        color = params.text_color or Color.white
    })
    self._text_chance:set_right(self._time_bg_box:right())
    if self._icon1 then
        self._icon1:set_x(self._icon1:x() * 2)
    end
end

EHIsand11Tracker.FormatChance = EHIChanceTracker.Format

function EHIsand11Tracker:SetChance(amount)
    self._chance = amount
    self._text_chance:set_text(self:FormatChance())
    if amount >= 100 then
        self._text_chance:set_color(Color.green)
    else
        self._text_chance:set_color(Color.white)
    end
end

local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local boat_anim = 614/30 + 12 + 1
local skid = { { icon = Icon.Car, color = Color("1E90FF") } }
local triggers = {
    --[100129] = { time = 30, id = "AssaultDelay", class = TT.AssaultDelay },

    [EHI:GetInstanceElementID(100045, 7100)] = { time = 5, id = "RoomHack", icons = { Icon.PCHack } },

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
    [101009] = { time = 210/30, id = "RampRaise", icons = { Icon.Wait } },
    [101799] = { time = 181/30, id = "RampLower", icons = { Icon.Wait } },

    [104528] = { time = 22, id = "Crane", icons = { "equipment_winch_hook" } }, -- 104528 -> 100703

    [103870] = { chance = 34, id = "ReviveVlad", icons = { "equipment_defibrillator" }, class = TT.Chance, special_function = SF.AddTrackerIfDoesNotExist },
    [103871] = { id = "ReviveVlad", special_function = SF.RemoveTracker },

    [103925] = { id = "BoatEscape", icons = Icon.BoatEscape, special_function = SF.SetTimeIfLoudOrStealth, data = { yes = 30 + boat_anim, no = 19 + boat_anim } }
}
local time = 5 -- Normal
if EHI:IsBetweenDifficulties(EHI.Difficulties.Hard, EHI.Difficulties.VeryHard) then
    -- Hard + Very Hard
    time = 15
elseif EHI:IsDifficulty(EHI.Difficulties.OVERKILL) then
    -- OVERKILL
    time = 20
elseif EHI:IsBetweenDifficulties(EHI.Difficulties.Mayhem, EHI.Difficulties.DeathWish) then
    -- Mayhem + Death Wish
    time = 30
elseif EHI:IsDifficulty(EHI.Difficulties.DeathSentence) then
    -- Death Sentence
    time = 40
end
for _, index in ipairs({8530, 9180, 9680}) do
    triggers[EHI:GetInstanceElementID(100176, index)] = { time = 30, id = "KeypadRebootECM", icons = { Icon.Loop } } -- ECM Jammer
    triggers[EHI:GetInstanceElementID(100210, index)] = { time = 3 + time, id = "KeypadReboot", icons = { Icon.Loop } }
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

local sand_9_buttons = { id = "sand_9_buttons", special_function = SF.IncreaseProgress }
local ExecuteIfProgressMatch = EHI:GetFreeCustomSpecialFunctionID()
local achievements =
{
    -- Players spawned
    [100107] = { special_function = SF.Trigger, data = { 1001071, 1001072, 1001073, 1001074 } },
    [1001071] = { max = 10, id = "sand_9", remove_after_reaching_target = false, class = TT.AchievementProgress },
    [1001072] = { max = 3, id = "sand_9_buttons", icons = { Icon.Interact }, class = TT.Progress, special_function = SF.ShowAchievementCustom, data = "sand_9" },
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
    [103208] = { id = "sand_9", special_function = SF.FinalizeAchievement }
}

EHI:ParseTriggers(triggers, achievements)
EHI:DisableWaypoints(DisableWaypoints)
EHI:RegisterCustomSpecialFunction(ExecuteIfProgressMatch, function(...)
    local tracker = managers.ehi:GetTracker("sand_9_buttons")
    if tracker and tracker:GetProgress() == 0 then
        managers.ehi:RemoveTracker("sand_9_buttons")
        managers.ehi:SetAchievementFailed("sand_9")
    end
end)

local tbl =
{
    --levels/instances/unique/sand/sand_computer_hackable
    --units/pd2_dlc_sand/equipment/sand_interactable_hack_computer/sand_interactable_hack_computer
    [EHI:GetInstanceElementID(100140, 18680)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100034, 18680) },

    --levels/instances/unique/sand/sand_swat_van_drillable
    --units/payday2/equipment/gen_interactable_drill_small/gen_interactable_drill_small_no_jam
    [EHI:GetInstanceElementID(100022, 15380)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100023, 15380) },

    --levels/instances/unique/sand/sand_computer_code_display
    --units/pd2_dlc_sand/equipment/sand_interactable_rotating_code_computer/sand_interactable_rotating_code_computer
    [EHI:GetInstanceElementID(100150, 9030)] = { remove_on_pause = true, remove_on_alarm = true },

    --levels/instances/unique/sand/sand_server_hack
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b
    [EHI:GetInstanceElementID(100037, 14280)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100017, 14280) },

    --levels/instances/unique/sand/sand_chinese_computer_hackable
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b
    [EHI:GetInstanceElementID(100037, 15680)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100017, 15680) },

    --levels/instances/unique/sand/sand_defibrillator
    --units/pd2_dlc_sand/equipment/sand_interactable_defibrillator/sand_interactable_defibrillator
    [EHI:GetInstanceElementID(100009, 16580)] = { icons = { Icon.Power } },
    [EHI:GetInstanceElementID(100009, 16680)] = { icons = { Icon.Power } },
    [EHI:GetInstanceElementID(100009, 16780)] = { icons = { Icon.Power } }
}
EHI:UpdateUnits(tbl)