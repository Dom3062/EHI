---@class daily_cake : EHISideJobTracker, EHIProgressTracker
---@field super EHISideJobTracker
local daily_cake = class(EHISideJobTracker)
daily_cake.FormatProgress = EHIProgressTracker.FormatProgress
daily_cake.IncreaseProgress = EHIProgressTracker.IncreaseProgress
daily_cake.SetProgress = EHIProgressTracker.SetProgress
function daily_cake:OverridePanel()
    self._max = 4
    self._progress = 0
    self:SetBGSize()
    self._progress_text = self:CreateText({
        text = self:FormatProgress(),
        w = self._bg_box:w() / 2,
        left = 0,
        FitTheText = true
    })
    self._text:set_left(self._progress_text:right())
end

function daily_cake:SetCompleted(force)
    if not self._status then
        self._status = "completed"
        self._progress_text:set_color(Color.green)
        self:SetStatusText("finish", self._progress_text)
        self._disable_counting = true
    elseif force then
        self._text:set_color(Color.green)
        self:DelayForcedDelete()
    end
end

function daily_cake:DelayForcedDelete()
    self.update = self.update_fade
    daily_cake.super.DelayForcedDelete(self)
end

local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local Status = EHI.Const.Trackers.Achievement.Status
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    [100891] = { additional_time = 320/30 + 5, random_time = 5, id = "EMPBombDrop", icons = { Icon.Goto }, hint = Hints.mad_Bomb }
}

---@type ParseAchievementTable
local achievements =
{
    mad_2 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100547] = { status = Status.NoDown, class = TT.Achievement.Status },
            [101400] = { special_function = SF.SetAchievementFailed },
            [101823] = { special_function = SF.SetAchievementComplete }
        }
    },
    cac_13 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100189] = { status = "mad_body", condition_function = EHI.ConditionFunctions.PlayingFromStart, class = TT.Achievement.Status },
            [EHI:GetInstanceElementID(100007, 3150)] = { status = "mad_body", special_function = SF.SetAchievementStatus }, -- Body scanned, next one
            [EHI:GetInstanceElementID(100013, 3150)] = { status = Status.Defend, special_function = SF.SetAchievementStatus }, -- Body placed
            [EHI:GetInstanceElementID(100033, 3150)] = { special_function = SF.SetAchievementFailed }, -- Server picked with less bodies scanned than required
            [101925] = { special_function = SF.SetAchievementFailed }, -- Stopped or power went down
            [101924] = { special_function = SF.SetAchievementComplete }
        }
    }
}
if EHI:CanShowAchievement2("pim_3", "show_achievements_weapon") and ovk_and_up then -- "UMP for Me, UMP for You"
    EHI:AddOnSpawnedExtendedCallback(function(self, job, level, from_beginning)
        if level == "mad" and self:EHIHasWeaponTypeEquipped("smg") then
            self:EHIAddAchievementTrackerFromStat("pim_3_stats")
        end
    end)
end

local other =
{
    [100547] = EHI:AddAssaultDelay({})
}

local sidejob =
{
    daily_cake =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [101906] = { time = 1200, class_table = daily_cake },
            [101898] = { special_function = SF.SetAchievementComplete },
            [EHI:GetInstanceElementID(100038, 3150)] = { special_function = SF.IncreaseProgress }
        }
    }
}

EHI.Mission:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    sidejob = sidejob
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