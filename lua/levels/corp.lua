local EHI = EHI
EHIcorp12Tracker = class(EHIAchievementTracker)
EHIcorp12Tracker.AnimateWarning2 = EHIWarningTracker.AnimateWarning
function EHIcorp12Tracker:init(panel, params)
    params.time = 420 -- SP (MP has 240s)
    EHIcorp12Tracker.super.init(self, panel, params)
    self._mp_time = 240
end

function EHIcorp12Tracker:OverridePanel()
    self._text2 = self._time_bg_box:text({ -- MP text
        name = "text2",
        text = self:Format(),
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w(),
        h = self._icon_size_scaled,
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = self._text_color,
        visible = false
    })
end

function EHIcorp12Tracker:update(t, dt)
    EHIcorp12Tracker.super.update(self, t, dt)
    self:update2(dt)
end

function EHIcorp12Tracker:update2(dt)
    local t = self._time
    local _t = self._mp_time - dt
    self._time = _t
    self._mp_time = _t
    self._text2:set_text(self:Format())
    self._time = t
    if _t <= 10 and self._warning2_started then
        self._warning2_started = true
        self:AnimateWarning2(self._text2)
    end
end

function EHIcorp12Tracker:SetMPState()
    self._text2:set_visible(true)
    self._text1:set_visible(false)
    if self._mp_time <= 0 then
        self:SetFailed()
    end
end

function EHIcorp12Tracker:delete()
    if self._text2 and alive(self._text2) then
        self._text2:stop()
    end
    EHIcorp12Tracker.super.delete(self)
end

EHI.AchievementTrackers.EHIcorp12Tracker = true
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local OVKorAbove = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers =
{
    [102406] = { additional_time = 22 + 6, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.GetElementTimerAccurate, element = 102401 }
}
if EHI:IsClient() then
    local escape_time = 15
    if OVKorAbove then
        escape_time = 30
    end
    triggers[102406].time = escape_time
    triggers[102406].random_time = 15
    triggers[102406].delay_only = true
    EHI:AddSyncTrigger(102406, triggers[102406])
end

local corp_10_SetCounterToZero = EHI:GetFreeCustomSpecialFunctionID()
local corp_11_Start = EHI:GetFreeCustomSpecialFunctionID()
local corp_11_SetFailed = EHI:GetFreeCustomSpecialFunctionID()
local corp_11_StartVariable = true
local achievements =
{
    corp_10 =
    {
        difficulty_pass = OVKorAbove,
        elements =
        {
            [103043] = { max = 50, class = TT.AchievementProgress },
            [103482] = { special_function = SF.IncreaseProgress },
            [103487] = { special_function = corp_10_SetCounterToZero }
        }
    },
    corp_11 =
    {
        elements =
        {
            [102728] = { icons = EHI:GetAchievementIcon("corp_11"), special_function = corp_11_Start },
            [102683] = { special_function = corp_11_SetFailed },
            [102741] = { special_function = SF.SetAchievementComplete }
        }
    },
    corp_12 =
    {
        difficulty_pass = OVKorAbove,
        elements =
        {
            [100107] = { class = "EHIcorp12Tracker" },
            [102739] = { special_function = SF.CustomCode, f = function()
                managers.ehi:CallFunction("corp_12", "SetMPState")
            end },
            [102014] = { special_function = SF.SetAchievementFailed }, -- Alarm
            [102736] = { special_function = SF.SetAchievementFailed } -- Civilian killed
        },
        cleanup_callback = function()
            EHIcorp12Tracker = nil
        end
    }
}
for i = 102699, 102712, 1 do
    achievements.corp_11.elements[i] = { special_function = corp_11_SetFailed }
end

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 45 + 30 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:RegisterCustomSpecialFunction(corp_10_SetCounterToZero, function(...)
    managers.ehi:SetTrackerProgress("corp_10", 0)
end)
EHI:RegisterCustomSpecialFunction(corp_11_Start, function(trigger, ...)
    if corp_11_StartVariable then
        managers.ehi:AddTracker({
            id = "corp_11",
            time = 60,
            icons = trigger.icons,
            class = TT.Achievement
        })
    end
end)
EHI:RegisterCustomSpecialFunction(corp_11_SetFailed, function(...)
    managers.ehi:SetAchievementFailed("corp_11")
    corp_11_StartVariable = false
end)

local tbl =
{
    [EHI:GetInstanceUnitID(100023, 12190)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100050, 12190) }
}
EHI:UpdateUnits(tbl)

local DisableWaypoints =
{
    [EHI:GetInstanceElementID(100031, 12610)] = true, -- Defend
    [EHI:GetInstanceElementID(100056, 12610)] = true, -- Fix
    [EHI:GetInstanceElementID(100031, 12710)] = true, -- Defend
    [EHI:GetInstanceElementID(100056, 12710)] = true, -- Fix
}
EHI:DisableWaypoints(DisableWaypoints)