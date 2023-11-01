local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers

local other = {}

local min_bags = 4
if Global.game_settings.level_id == "gallery" then
    ---@type ParseAchievementTable
    local achievements =
    {
        cac_19 =
        {
            elements =
            {
                [100789] = { class = TT.Achievement.Status },
                [104288] = { special_function = SF.SetAchievementComplete },
                [104290] = { special_function = SF.SetAchievementFailed }, -- Alarm
                [102860] = { special_function = SF.SetAchievementFailed } -- Painting flushed
            }
        }
    }
    if TheFixes then
        local Preventer = TheFixesPreventer or {}
        if not Preventer.achi_masterpiece then -- Fixed
            managers.mission:add_global_event_listener("EHI_ArtGallery_TheFixes", { "TheFixes_AchievementFailed" }, function(id)
                if id == "cac_19" then
                    managers.ehi_tracker:SetAchievementFailed(id)
                end
            end)
            achievements.cac_19.cleanup_callback = function()
                managers.mission:remove_global_event_listener("EHI_ArtGallery_TheFixes")
            end
        end
    end

    EHI:ParseTriggers({
        achievement = achievements
    })

    min_bags = 6
else -- Framing Frame Day 1
    EHI:ShowAchievementLootCounter({
        achievement = "pink_panther",
        max = 9,
        show_finish_after_reaching_target = true,
        failed_on_alarm = true,
        triggers =
        {
            [102860] = { special_function = SF.SetAchievementFailed } -- Painting flushed
        }
    })

    if EHI:GetOption("show_escape_chance") then
        other[102437] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement } -- +5%
        other[103884] = { id = "EscapeChance", special_function = SF.SetChanceFromElement } -- 100 %
        EHI:AddOnAlarmCallback(function(dropin)
            managers.ehi_escape:AddEscapeChanceTracker(dropin, 25)
        end)
    end
end

EHI:ShowLootCounter({
    max = 9,
    triggers =
    {
        [102860] = { special_function = SF.DecreaseProgressMax } -- Painting flushed
    },
    load_sync = function(self)
        local max_reduction = 0
        if self:IsMissionElementDisabled(104285) then
            max_reduction = max_reduction + 1
        end
        if self:IsMissionElementDisabled(104286) then
            max_reduction = max_reduction + 1
        end
        self._trackers:DecreaseLootCounterProgressMax(max_reduction)
        self._trackers:SyncSecuredLoot()
    end
})

if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[103331] = { id = "Snipers", chance = 10, time = 15, recheck_t = 30, class = TT.Sniper.TimedChanceOnce }
    other[103829] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess", arg = { 2 } }
    other[103828] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[103785] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[103761] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({ other = other })

---@type MissionDoorTable
local MissionDoor =
{
    -- Security doors
    [Vector3(-827.08, 115.886, 92.4429)] = 103191,
    [Vector3(-60.1138, 802.08, 92.4429)] = 103188,
    [Vector3(-140.886, -852.08, 92.4429)] = 103202
}
EHI:SetMissionDoorData(MissionDoor)
local xp_override =
{
    params =
    {
        min_max =
        {
            loot_all = { min = min_bags, max = 9 }
        }
    }
}
EHI:AddXPBreakdown({
    tactic =
    {
        stealth =
        {
            objectives =
            {
                { escape = 2000 }
            },
            loot_all = 500,
            total_xp_override = xp_override
        },
        loud =
        {
            objectives =
            {
                { amount = 6000, name = "pc_hack" },
                { escape = 2000 }
            },
            loot_all = 500,
            total_xp_override = xp_override
        }
    }
})