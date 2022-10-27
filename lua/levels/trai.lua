local EHI = EHI
local Icon = EHI.Icons
local WinchFix = { Icon.Winch, Icon.Fix }
if EHI:GetOption("show_one_icon") then
    WinchFix = { Icon.Fix }
end
EHICraneFixChanceTracker = class(EHIWarningTracker)
EHICraneFixChanceTracker._forced_icons = WinchFix
EHICraneFixChanceTracker.AnimateWarning = EHITimerTracker.AnimateCompletion
EHICraneFixChanceTracker.FormatChance = EHIChanceTracker.Format
EHICraneFixChanceTracker.IncreaseChance = EHIChanceTracker.IncreaseChance
EHICraneFixChanceTracker.SetFailed = EHIAchievementTracker.SetFailed
function EHICraneFixChanceTracker:init(panel, params)
    self._chance = 30
    params.time = 33
    EHICraneFixChanceTracker.super.init(self, panel, params)
end

function EHICraneFixChanceTracker:OverridePanel(params)
    self._panel:set_w(self._panel:w() * 2)
    self._time_bg_box:set_w(self._time_bg_box:w() * 2)
    self._chance_text = self._time_bg_box:text({
        name = "text2",
        text = self:FormatChance(),
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w() / 2,
        h = self._icon_size_scaled,
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = params.text_color or Color.white
    })
    self:FitTheText(self._chance_text)
    self._chance_text:set_left(self._text:right())
    if self._icon1 then
        self._icon1:set_x(self._time_bg_box:w() + self._gap_scaled)
    end
    if self._icon2 then
        local initial_size = self._icon1 and self._icon_gap_size_scaled or 0
        self._icon2:set_x(self._time_bg_box:w() + initial_size + self._gap_scaled)
    end
end

function EHICraneFixChanceTracker:SetChance(amount)
    if amount < 0 then
        amount = 0
    end
    self._chance = amount
    self._chance_text:set_text(self:FormatChance())
    self:AnimateBG()
end

local SF = EHI.SpecialFunctions
local TT = EHI.Trackers

local triggers =
{
    [100975] = { time = 5, id = "C4Pipeline", icons = { Icon.C4 } },

    [102011] = { time = 5, id = "Thermite", icons = { Icon.Fire } },

    [101098] = { time = 5 + 7 + 2, id = "WalkieTalkie", icons = { Icon.Pager } },

    [103130] = { time = 10, id = "LocomotiveRefuel", icons = { Icon.Water } },

    [EHI:GetInstanceElementID(100024, 11650)] = { time = 25, id = "Turntable", icon = { Icon.Loop }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [EHI:GetInstanceElementID(100025, 11650)] = { id = "Turntable", special_function = SF.PauseTracker },

    [EHI:GetInstanceElementID(100089, 22250)] = { time = 0.1 + 400/30, id = "CraneLowerHooks", icons = { Icon.Winch } },
    [EHI:GetInstanceElementID(100010, 22250)] = { time = 400/30 + 105 + 2 + 400/30, id = "CraneMove", icons = { Icon.Winch }, class = TT.Pausable },
    [EHI:GetInstanceElementID(100047, 22250)] = { id = "CraneMove", special_function = SF.PauseTracker },
    [EHI:GetInstanceElementID(100059, 22250)] = { id = "CraneMove", special_function = SF.UnpauseTracker },
    [EHI:GetInstanceElementID(100060, 22250)] = { id = "CraneMove", special_function = SF.PauseTracker },
    [EHI:GetInstanceElementID(100046, 22250)] = { id = "CraneFixChance", class = "EHICraneFixChanceTracker", trigger_times = 1 },
    [EHI:GetInstanceElementID(100035, 22250)] = { id = "CraneFixChance", special_function = SF.IncreaseChanceFromElement }, -- +10%
    [EHI:GetInstanceElementID(100039, 22250)] = { id = "CraneFixChance", special_function = SF.SetAchievementFailed } -- Players need to fix the crane, runs once (Won't trigger "ACHIEVEMENT FAILED!" popup)
}

local other =
{
    [100109] = { time = 50 + 30, id = "AssaultDelay", class = TT.AssaultDelay, condition = EHI:GetOption("show_assault_delay_tracker") }
}

EHI:ParseTriggers({
    mission = triggers,
    other = other
})