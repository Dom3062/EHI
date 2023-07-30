local EHI = EHI
local Icon = EHI.Icons
EHIdailycakeTracker = class(EHIDailyTracker)
EHIdailycakeTracker.FormatProgress = EHIProgressTracker.Format
EHIdailycakeTracker.IncreaseProgress = EHIProgressTracker.IncreaseProgress
function EHIdailycakeTracker:init(panel, params)
    self._max = 4
    self._progress = 0
    EHIdailycakeTracker.super.init(self, panel, params)
end

function EHIdailycakeTracker:OverridePanel()
    self._panel:set_w(self._panel:w() * 2)
    self._bg_box:set_w(self._bg_box:w() * 2)
    self._progress_text = self._bg_box:text({
        name = "text2",
        text = self:FormatProgress(),
        align = "center",
        vertical = "center",
        w = self._bg_box:w() / 2,
        h = self._bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = self._text_color
    })
    self:FitTheText(self._progress_text)
    self._progress_text:set_left(0)
    self._text:set_left(self._progress_text:right())
    if self._icon1 then
        self._icon1:set_x(self._icon1:x() * 2)
    end
end

function EHIdailycakeTracker:SetProgress(progress)
    if self._progress ~= progress and not self._disable_counting then
        self._progress = progress
        self._progress_text:set_text(self:FormatProgress())
        self:FitTheText(self._progress_text)
        self:AnimateBG()
        if self._progress == self._max then
            self:SetCompleted()
        end
    end
end

function EHIdailycakeTracker:SetCompleted()
    if not self._status then
        self._status = "completed"
        self._progress_text:set_color(Color.green)
        self:SetStatusText("finish", self._progress_text)
        self._disable_counting = true
    end
end
EHI.DailyTrackers.EHIdailycakeTracker = true

local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    [100891] = { additional_time = 320/30 + 5, random_time = 5, id = "EMPBombDrop", icons = { Icon.Goto } },

    [EHI:GetInstanceElementID(100019, 3150)] = { time = 90, id = "Scan", icons = { "mad_scan" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [EHI:GetInstanceElementID(100049, 3150)] = { id = "Scan", special_function = SF.PauseTracker },
    [EHI:GetInstanceElementID(100030, 3150)] = { id = "Scan", special_function = SF.RemoveTracker }, -- Just in case

    [EHI:GetInstanceElementID(100013, 1350)] = { time = 120, id = "EMP", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [EHI:GetInstanceElementID(100023, 1350)] = { id = "EMP", special_function = SF.PauseTracker }
}
if EHI:IsClient() then
    triggers[101410] = { id = "Scan", special_function = SF.RemoveTracker } -- Just in case
end

---@type ParseAchievementTable
local achievements =
{
    mad_2 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100547] = { status = "no_down", class = TT.AchievementStatus },
            [101400] = { special_function = SF.SetAchievementFailed },
            [101823] = { special_function = SF.SetAchievementComplete }
        }
    },
    cac_13 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100547] = { status = "defend", class = TT.AchievementStatus },
            [101925] = { special_function = SF.SetAchievementFailed },
            [101924] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local dailies =
{
    daily_cake =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [101906] = { time = 1200, class = "EHIdailycakeTracker" },
            [101898] = { special_function = SF.SetAchievementComplete },
            [EHI:GetInstanceElementID(100038, 3150)] = { special_function = SF.IncreaseProgress }
        }
    }
}

local DisableWaypoints =
{
    [EHI:GetInstanceElementID(100112, 7315)] = true, -- Defend
    [EHI:GetInstanceElementID(100112, 7615)] = true, -- Defend
    [EHI:GetInstanceElementID(100113, 7315)] = true, -- Fix
    [EHI:GetInstanceElementID(100113, 7615)] = true -- Fix
}
EHI:DisableWaypoints(DisableWaypoints)
EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    daily = dailies
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 3000, name = "boiling_point_radar_blown_up" },
        { amount = 5000, name = "pc_hack" },
        { amount = 5000, name = "boiling_point_emp_triggered" },
        { amount = 1000, name = "boiling_point_gas_off_hand_taken" },
        { amount = 5000, name = "boiling_point_scan_finished" },
        { amount = 6000, name = "boiling_point_grabbed_server" },
        { escape = 6000 }
    },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                objectives =
                {
                    boiling_point_scan_finished = { max = 4 }
                }
            }
        }
    }
})