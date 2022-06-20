EHIcac33Tracker = class(EHIAchievementNotificationTracker)
EHIcac33Tracker.IncreaseProgress = EHIProgressTracker.IncreaseProgress
EHIcac33Tracker.FormatProgress = EHIProgressTracker.Format
function EHIcac33Tracker:init(panel, params)
    self._progress = 0
    self._max = 200
    EHIcac33Tracker.super.init(self, panel, params)
end

function EHIcac33Tracker:OverridePanel(params)
    self._progress_text = self._time_bg_box:text({
        name = "progress",
        text = self:FormatProgress(),
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w(),
        h = self._time_bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = params.text_color or Color.white,
        visible = false
    })
    self:FitTheText(self._progress_text)
end

function EHIcac33Tracker:Activate()
    self._progress_text:set_visible(true)
    self._text:set_visible(false)
end

function EHIcac33Tracker:SetProgress(progress)
    if self._progress ~= progress and not self._disable_counting then
        self._progress = progress
        self._progress_text:set_text(self:FormatProgress())
        self:FitTheText(self._progress_text)
        self:AnimateBG(1)
        if self._progress == self._max then
            self:SetCompleted()
        end
    end
end

function EHIcac33Tracker:SetCompleted()
    EHIcac33Tracker.super.SetCompleted(self)
    self._disable_counting = true
    self._progress_text:set_color(Color.green)
    self._progress = 200
    self._progress_text:set_text(self:FormatProgress())
end

function EHIcac33Tracker:SetFailed()
    EHIcac33Tracker.super.SetFailed(self)
    self._disable_counting = true
    self._progress_text:set_color(Color.red)
end

local EHI = EHI
EHI.AchievementTrackers.EHIcac33Tracker = true
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Activate_cac_33 = EHI:GetFreeCustomSpecialFunctionID()
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local dw_and_above = EHI:IsDifficultyOrAbove("death_wish")
local thermite = { time = 300/30, id = "ThermiteSewerGrate", icons = { Icon.Fire } }
local ring = { id = "voff_4", special_function = SF.IncreaseProgress }
local triggers = {
    [102504] = { id = "cac_33", status = "land", class = "EHIcac33Tracker", condition = show_achievement and dw_and_above, exclude_from_sync = true },
    [103486] = { id = "cac_33", status = "ok", special_function = SF.SetAchievementStatus },
    [103479] = { id = "cac_33", special_function = SF.SetAchievementComplete },
    [103475] = { id = "cac_33", special_function = SF.SetAchievementFailed },
    [103487] = { id = "cac_33", special_function = Activate_cac_33 },
    [103477] = { id = "cac_33", special_function = SF.IncreaseProgress },
    [101897] = { time = 60, id = "LockeSecureHeli", icons = { Icon.Heli, Icon.Winch } }, -- Time before Locke arrives with heli to pickup the money
    [102452] = { id = "jerry_4", special_function = SF.SetAchievementComplete },
    [102453] = { special_function = SF.Trigger, data = { 1024531, 1024532 } },
    [1024531] = { id = "jerry_3", class = TT.AchievementNotification, condition = show_achievement and ovk_and_up },
    [1024532] = { time = 83, id = "jerry_4", class = TT.Achievement, condition = show_achievement and ovk_and_up },
    [102816] = { id = "jerry_3", special_function = SF.SetAchievementFailed },
    [101314] = { id = "jerry_3", special_function = SF.SetAchievementComplete },

    [103248] = ring,

    [101985] = thermite, -- First grate
    [101984] = thermite -- Second grate
}
for i = 103252, 103339, 3 do
    triggers[i] = ring
end

EHI:ParseTriggers(triggers)
EHI:ShowAchievementLootCounter({
    achievement = "voff_4",
    max = 9,
    exclude_from_sync = true,
    no_counting = true
})
EHI:RegisterCustomSpecialFunction(Activate_cac_33, function(id, trigger, element, enabled)
    managers.ehi:CallFunction(trigger.id, "Activate")
end)
if show_achievement then
    EHI:AddLoadSyncFunction(function(self)
        self:SetTrackerProgressRemaining("voff_4", self:CountInteractionAvailable("ring_band"))
    end)
end