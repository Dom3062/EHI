local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
if EHI:GetTrackerOrWaypointOption("show_mission_trackers", "show_waypoints_mission") then
    local show_tracker, show_waypoint = EHI:GetShowTrackerAndWaypoint("show_mission_trackers", "show_waypoints_mission")
    for _, id in ipairs({ 101405, 101432, 100896, 101031, 101032, 101406 }) do
        managers.mission:add_runned_unit_sequence_trigger(id, "interact", function(unit)
            local t = 300 / 30
            if show_tracker then
                managers.ehi_tracker:AddTracker({
                    id = tostring(id),
                    time = t,
                    icons = { Icon.Fire },
                    hint = EHI.Hints.Thermite
                })
            end
            if show_waypoint then
                managers.ehi_waypoint:AddWaypoint(tostring(id), {
                    time = t,
                    icon = Icon.Fire,
                    position = EHI.Mission:GetUnitPositionOrDefault(id)
                })
            end
        end)
    end
end

local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
---@type ParseAchievementTable
local achievements =
{
    jerry_3 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [102453] = { class = TT.Achievement.Status },
            [102816] = { special_function = SF.SetAchievementFailed },
            [101314] = { special_function = SF.SetAchievementComplete }
        }
    },
    jerry_4 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [102453] = { time = 83, class = TT.Achievement.Base },
            [102452] = { special_function = SF.SetAchievementComplete }
        }
    },
    cac_33 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish),
        elements =
        {
            [102504] = { status = "land", flash_times = 1 },
            [103479] = { special_function = SF.SetAchievementComplete },
            [103475] = { special_function = SF.SetAchievementFailed },
            [103487] = { special_function = SF.CallCustomFunction, f = "Activate" },
            [103477] = { special_function = SF.IncreaseProgress }
        },
        preparse_callback = function(data)
            ---@class cac_33 : EHIAchievementStatusTracker, EHIProgressTracker
            ---@field super EHIAchievementStatusTracker
            local cac_33 = class(EHIAchievementStatusTracker)
            cac_33.IncreaseProgress = EHIProgressTracker.IncreaseProgress
            cac_33.FormatProgress = EHIProgressTracker.FormatProgress
            cac_33.SetProgress = EHIProgressTracker.SetProgress
            function cac_33:post_init(params)
                cac_33.super.post_init(self, params)
                self._progress = 0
                self._max = 200
                self._progress_text = self:CreateText({
                    text = self:FormatProgress(),
                    visible = false,
                    FitTheText = true
                })
            end
            function cac_33:Activate()
                self._progress_text:show()
                self._text:hide()
            end
            function cac_33:SetCompleted()
                cac_33.super.SetCompleted(self)
                self._disable_counting = true
                self._progress_text:set_color(Color.green)
            end
            function cac_33:SetFailed()
                cac_33.super.SetFailed(self)
                self._disable_counting = true
                self._progress_text:set_color(Color.red)
            end
            data.elements[102504].class_table = cac_33
        end
    }
}

local other =
{
    [100653] = EHI:AddAssaultDelay({ control = 2 + 15, trigger_once = true })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100161] = { chance = 10, time = 10 + 25, on_fail_refresh_t = 25, on_success_refresh_t = 20 + 10 + 25, id = "Snipers", class = TT.Sniper.Loop, sniper_count = 3 }
    other[100153] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100159] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100155] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100152] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100156] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100148] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100146] = { id = "Snipers", special_function = SF.DecreaseCounter }
end
if EHI:GetOption("show_captain_spawn_chance") then
    other[103489] = EHI:AddCustomCode(function(self)
        self._trackers:ForceRemoveTracker("CaptainChance")
    end)
end

EHI.Mission:ParseTriggers({
    achievement = achievements,
    other = other
})
local ring = { special_function = SF.IncreaseProgress }
local voff_4_triggers =
{
    [103248] = ring
}
for i = 103252, 103339, 3 do
    voff_4_triggers[i] = ring
end
EHI:ShowAchievementLootCounter({
    achievement = "voff_4",
    job_pass = managers.job:current_job_id() == "pbr2",
    max = 9,
    triggers = voff_4_triggers,
    load_sync = function(self)
        self._trackers:SetProgressRemaining("voff_4", self._utils:CountInteractionAvailable("ring_band"))
    end
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 3000, name = "bos_cargo_door_open" },
        { amount = 3000, name = "bos_money_released" },
        { amount = 2500, name = "bos_money_pallet_found" },
        { amount = 500, name = "flare" },
        { amount = 700, name = "bos_found_scattered_money" },
        { amount = 1500, name = "bos_heli_picked_up_money" },
        { escape = 6000 }
    },
    total_xp_override =
    {
        objectives =
        {
            bos_money_pallet_found = { times = 3 },
            flare = { times = 3 },
            bos_found_scattered_money = { times = 8 },
            bos_heli_picked_up_money = { times = 3 }
        }
    }
})