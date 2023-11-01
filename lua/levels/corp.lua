---@class EHIcorp9Tracker : EHIColoredCodesTracker, EHIAchievementTracker
---@field super EHIColoredCodesTracker
EHIcorp9Tracker = class(EHIColoredCodesTracker)
EHIcorp9Tracker._forced_icons = EHI:GetAchievementIcon("corp_9")
EHIcorp9Tracker._update = false
EHIcorp9Tracker._popup_type = "achievement"
EHIcorp9Tracker._forced_hint_text = "achievement_corp_9"
EHIcorp9Tracker._show_started = EHIAchievementTracker._show_started
EHIcorp9Tracker._show_failed = EHIAchievementTracker._show_failed
EHIcorp9Tracker._show_desc = EHIAchievementTracker._show_desc
EHIcorp9Tracker.ShowStartedPopup = EHIAchievementTracker.ShowStartedPopup
EHIcorp9Tracker.ShowAchievementDescription = EHIAchievementTracker.ShowAchievementDescription
---@param panel Panel
---@param params EHITracker_params
---@param parent_class EHITrackerManager
function EHIcorp9Tracker:init(panel, params, parent_class)
    self._hint_showed = true
    params.hint_vanilla_localization = true
    EHIcorp9Tracker.super.init(self, panel, params, parent_class)
    if self._show_started then
        self:ShowStartedPopup()
    end
    if self._show_desc then
        self:ShowAchievementDescription()
    end
end

function EHIcorp9Tracker:OverridePanel()
    EHIcorp9Tracker.super.OverridePanel(self)
    self._text4 = self:CreateText({
        name = "text4",
        status_text = "find",
        h = self._icon_size_scaled,
        color = Color.yellow
    })
    self._text:set_visible(false)
    self._text2:set_visible(false)
    self._text3:set_visible(false)
end

function EHIcorp9Tracker:LaptopInteracted()
    self:SetStatusText("push", self._text4)
    self:AnimateBG()
end

function EHIcorp9Tracker:FindCodesStarted()
    self._text:set_visible(true)
    self._text2:set_visible(true)
    self._text3:set_visible(true)
    self._text4:set_visible(false)
    self:AnimateBG()
end

function EHIcorp9Tracker:SetCompleted()
    EHIAchievementTracker.SetCompleted(self)
    self._text2:set_color(Color.green)
    self._text3:set_color(Color.green)
    self:AddTrackerToUpdate()
    self._achieved = true
end

function EHIcorp9Tracker:SetFailed()
    if self._achieved then
        return
    end
    EHIAchievementTracker.SetFailed(self)
    self._text2:set_color(Color.red)
    self._text3:set_color(Color.red)
end

---@class EHIcorp12Tracker : EHIAchievementTracker
EHIcorp12Tracker = class(EHIAchievementTracker)
EHIcorp12Tracker._forced_icons = EHI:GetAchievementIcon("corp_12")
function EHIcorp12Tracker:SetMPState()
    if self._mp then
        return
    end
    self._text:stop()
    self._time_warning = false
    self._time = self._time - 180
    self._check_anim_progress = self._time <= 10
    self._mp = true
end

local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local OVKorAbove = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
---@type ParseTriggerTable
local triggers =
{
    [102406] = { additional_time = 22 + 6, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.GetElementTimerAccurate, element = 102401, hint = Hints.LootEscape },

    [EHI:GetInstanceElementID(100018, 12190)] = { time = 10, id = "Thermite", icons = { Icon.Fire }, hint = Hints.Thermite }
}
if EHI:IsClient() then
    triggers[102406].client = { time = OVKorAbove and 30 or 15, random_time = 15 }
end

local corp_11_StartVariable = true
local corp_11_SetFailed = EHI:RegisterCustomSpecialFunction(function(self, trigger, element, enabled)
    if enabled then
        self._trackers:SetAchievementFailed("corp_11")
        corp_11_StartVariable = false
    end
end)
---@type ParseAchievementTable
local achievements =
{
    corp_9 =
    {
        elements =
        {
            [100107] = { class = "EHIcorp9Tracker", condition_function = function()
                local value = managers.mission:get_saved_job_value("usb_train")
                return value == 1
            end },
            [EHI:GetInstanceElementID(100010, 14610)] = { special_function = SF.CallCustomFunction, f = "LaptopInteracted" },
            [103518] = { special_function = SF.CallCustomFunction, f = "FindCodesStarted" },
            [103045] = { special_function = SF.SetAchievementComplete },
            [EHI:GetInstanceElementID(100021, 11090)] = { special_function = SF.SetAchievementFailed } -- Lab destroyed with C4
        },
        cleanup_callback = function()
            EHIcorp9Tracker = nil ---@diagnostic disable-line
        end,
        parsed_callback = function()
            for i = 102867, 102869, 1 do
                for j = 0, 9, 1 do
                    managers.mission:add_runned_unit_sequence_trigger(i, "set_red_0" .. tostring(j), function(...)
                        managers.ehi_tracker:CallFunction("corp_9", "SetCode", "red", j)
                    end)
                end
            end
            for i = 102870, 102872, 1 do
                for j = 0, 9, 1 do
                    managers.mission:add_runned_unit_sequence_trigger(i, "set_green_0" .. tostring(j), function(...)
                        managers.ehi_tracker:CallFunction("corp_9", "SetCode", "green", j)
                    end)
                end
            end
            for i = 102873, 102875, 1 do
                for j = 0, 9, 1 do
                    managers.mission:add_runned_unit_sequence_trigger(i, "set_blue_0" .. tostring(j), function(...)
                        managers.ehi_tracker:CallFunction("corp_9", "SetCode", "blue", j)
                    end)
                end
            end
        end
    },
    corp_10 =
    {
        difficulty_pass = OVKorAbove,
        elements =
        {
            [103043] = { max = 50, class = TT.Achievement.Progress },
            [103482] = { special_function = SF.IncreaseProgress },
            [103487] = { special_function = SF.SetAchievementFailed }
        }
    },
    corp_11 =
    {
        elements =
        {
            [102728] = { icons = EHI:GetAchievementIcon("corp_11"), special_function = EHI:RegisterCustomSpecialFunction(function(self, trigger, ...)
                if corp_11_StartVariable then
                    self._trackers:AddTracker({
                        id = "corp_11",
                        time = 60,
                        icons = trigger.icons,
                        class = TT.Achievement.Base
                    })
                end
            end) },
            [102683] = { special_function = corp_11_SetFailed },
            [102741] = { special_function = SF.SetAchievementComplete }
        }
    },
    corp_12 =
    {
        difficulty_pass = OVKorAbove,
        elements =
        {
            -- SP (MP has 240s)
            [100107] = { time = 420, class = "EHIcorp12Tracker", special_function = SF.AddTrackerIfDoesNotExist },
            [102739] = { special_function = EHI:RegisterCustomSpecialFunction(function(self, ...)
                if EHI.ConditionFunctions.IsLoud() then
                    return
                end
                if self._trackers:TrackerDoesNotExist("corp_12") then
                    self._trackers:AddTracker({
                        id = "corp_12",
                        time = 420,
                        class = "EHIcorp12Tracker"
                    })
                end
                self._trackers:CallFunction("corp_12", "SetMPState")
            end) },
            [102014] = { special_function = SF.SetAchievementFailed }, -- Alarm
            [102736] = { special_function = SF.SetAchievementFailed }, -- Civilian killed
            [102740] = { special_function = SF.SetAchievementComplete }
        },
        cleanup_callback = function()
            EHIcorp12Tracker = nil ---@diagnostic disable-line
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
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100015] = { id = "Snipers", class = TT.Sniper.Count, trigger_times = 1 }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

local tbl =
{
    [EHI:GetInstanceUnitID(100023, 12190)] = { remove_vanilla_waypoint = EHI:GetInstanceElementID(100050, 12190) }
}
EHI:UpdateUnits(tbl)

local DisableWaypoints =
{
    [EHI:GetInstanceElementID(100031, 12610)] = true, -- Defend
    [EHI:GetInstanceElementID(100056, 12610)] = true, -- Fix
    [EHI:GetInstanceElementID(100031, 12710)] = true, -- Defend
    [EHI:GetInstanceElementID(100056, 12710)] = true -- Fix
}
EHI:DisableWaypoints(DisableWaypoints)
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 5000, name = "texas3_evidences_found" },
        { amount = 5000, name = "texas3_prototype_secured" },
        { amount = 5000, name = "texas3_documents_secured" },
        { amount = 5000, name = "texas3_lab_destroyed" },
        { amount = 2000, name = "texas3_escape_1" },
        { amount = 1000, name = "texas3_escape_2" }
    },
    loot_all = 500,
    total_xp_override =
    {
        params =
        {
            min =
            {
                objectives =
                {
                    texas3_evidences_found = true,
                    texas3_prototype_secured = true,
                    texas3_documents_secured = true,
                    texas3_lab_destroyed = true,
                    texas3_escape_2 = true
                },
                loot_all = { times = 4 }
            },
            no_max = true
        }
    }
})