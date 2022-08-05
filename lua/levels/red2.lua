EHIcac10Tracker = class(EHIAchievementTracker)
EHIcac10Tracker._update = false
EHIcac10Tracker.FormatProgress = EHIProgressTracker.Format
EHIcac10Tracker.IncreaseProgress = EHIProgressTracker.IncreaseProgress
EHIcac10Tracker.IncreaseProgressMax = EHIProgressTracker.IncreaseProgressMax
function EHIcac10Tracker:init(panel, params)
    self._max = 0
    self._progress = 0
    EHIcac10Tracker.super.init(self, panel, params)
end

function EHIcac10Tracker:OverridePanel(params)
    self._panel:set_w(self._panel:w() * 2)
    self._time_bg_box:set_w(self._time_bg_box:w() * 2)
    self._progress_text = self._time_bg_box:text({
        name = "text2",
        text = self:FormatProgress(),
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w() / 2,
        h = self._time_bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = params.text_color or Color.white
    })
    self:FitTheText(self._progress_text)
    self._progress_text:set_left(0)
    self._text:set_left(self._progress_text:right())
    if self._icon1 then
        self._icon1:set_x(self._icon1:x() * 2)
    end
end

function EHIcac10Tracker:AnimateWarning()
    if self._text and alive(self._text) then
        local progress = self._progress_text
        self._text:animate(function(o)
            while true do
                local t = 0
                while t < 1 do
                    t = t + coroutine.yield()
                    local n = 1 - sin(t * 180)
                    --local r = lerp(1, 0, n)
                    local g = lerp(1, 0, n)
                    local c = Color(1, g, g)
                    o:set_color(c)
                    progress:set_color(c)
                end
            end
        end)
    end
end

function EHIcac10Tracker:SetProgressMax(max)
    self._max = max
    self._progress_text:set_text(self:FormatProgress())
end

function EHIcac10Tracker:SetProgress(progress)
    if self._progress ~= progress and not self._disable_counting then
        self._progress = progress
        self._progress_text:set_text(self:FormatProgress())
        self:FitTheText(self._progress_text)
        self:AnimateBG()
    end
end

function EHIcac10Tracker:SetCompleted(force)
    if (self._progress == self._max and not self._status) or force then
        self._exclude_from_sync = true
        self._status = "completed"
        self._text:stop()
        self:SetTextColor(Color.green)
        self._fade_time = 5
        self._fade = true
        self._disable_counting = true
        self._achieved_popup_showed = true
    end
end

function EHIcac10Tracker:SetTextColor(color)
    EHIcac10Tracker.super.SetTextColor(self, color)
    self._progress_text:set_color(color)
end

EHIgreen1Tracker = class(EHIProgressTracker)
function EHIgreen1Tracker:SetCompleted(force)
    EHIgreen1Tracker.super.SetCompleted(self, force)
    self._disable_counting = false
end

function EHIgreen1Tracker:SetProgress(progress)
    EHIgreen1Tracker.super.SetProgress(self, progress)
    EHI:Log("green_1 -> Progress: " .. tostring(progress))
end

local EHI = EHI
EHI.AchievementTrackers.EHIcac10Tracker = true
EHI.AchievementTrackers.EHIgreen1Tracker = true
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local CF = EHI.ConditionFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local RemoveTriggerAndStartAchievementCountdown = EHI:GetFreeCustomSpecialFunctionID()
local green_1_decrease = { id = "green_1", special_function = SF.DecreaseProgress }
local triggers = {
    [101299] = { time = 300, id = "Thermite", icons = { Icon.Fire }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1012991 } },
    [1012991] = { time = 90, id = "ThermiteShorterTime", icons = { Icon.Fire, Icon.Wait }, class = TT.Warning }, -- Triggered by 101299
    [101325] = { special_function = SF.TriggerIfEnabled, data = { 1013251, 1013252 } },
    [1013251] = { time = 180, id = "Thermite", icons = { Icon.Fire }, special_function = SF.SetTimeOrCreateTracker },
    [1013252] = { id = "ThermiteShorterTime", special_function = SF.RemoveTracker },
    [103373] = { special_function = SF.Trigger, data = { --[[1033731,]] 1033732 } },
    --[1033731] = { max = 6, id = "green_1", class = "EHIgreen1Tracker", remove_after_reaching_target = false, exclude_from_sync = true },
    [1033732] = { time = 817, id = "green_3", class = TT.Achievement },
    [107072] = { id = "cac_10", special_function = SF.SetAchievementComplete },
    [101544] = { id = "cac_10", special_function = RemoveTriggerAndStartAchievementCountdown },
    [101341] = { time = 30, id = "cac_10", class = "EHIcac10Tracker", difficulty_pass = ovk_and_up, condition_function = CF.IsLoud },
    [107066] = { id = "cac_10", special_function = SF.IncreaseProgressMax },
    [107067] = { id = "cac_10", special_function = SF.IncreaseProgress },
    [101684] = { time = 5.1, id = "C4", icons = { Icon.C4 } },
    [102567] = { id = "green_3", special_function = SF.SetAchievementFailed },
    [102153] = { id = "green_1", special_function = SF.IncreaseProgress },
    [102333] = green_1_decrease,
    [102539] = green_1_decrease,
    [106684] = { max = 70, id = "LootCounter", special_function = SF.IncreaseProgressMax }
}
local DisableWaypoints = {}
for i = 0, 300, 100 do
    -- Hacking PC (repair icon)
    DisableWaypoints[EHI:GetInstanceElementID(100024, i)] = true
end

EHI:ParseTriggers(triggers)
EHI:DisableWaypoints(DisableWaypoints)
EHI:RegisterCustomSpecialFunction(RemoveTriggerAndStartAchievementCountdown, function(id, ...)
    managers.ehi:StartTrackerCountdown("cac_10")
    EHI:UnhookTrigger(id)
end)
EHI:ShowLootCounter({ max = 14 })
if show_achievement then
    EHI:AddLoadSyncFunction(function(self)
        if EHI.ConditionFunctions.IsStealth() then
            self:AddTimedAchievementTracker("green_3", 817)
        end
    end)
end

local tbl = {}
for i = 0, 300, 100 do
    --levels/instances/unique/red/red_hacking_computer
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b
    tbl[EHI:GetInstanceElementID(100000, i)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100018, i) }
end
for i = 6000, 6200, 200 do
    --levels/instances/unique/red/red_gates
    --units/payday2/equipment/gen_interactable_lance_large/gen_interactable_lance_large
    tbl[EHI:GetInstanceElementID(100006, i)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100014, i) }
end
EHI:UpdateUnits(tbl)