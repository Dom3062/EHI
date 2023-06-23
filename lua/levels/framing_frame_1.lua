local EHI = EHI
local SF = EHI.SpecialFunctions
--[[function EHI:PaintingCount()
    --[[local paintings = managers.ehi_tracker:GetUnits("units/payday2/architecture/com_int_gallery/com_int_gallery_wall_painting_bars", 1)
    local n_of_paintings = 0
    -- 3878622f45bc7dfe => Idstring("g_important") without ID and @ at the end
    for _, painting in pairs(paintings) do
        if painting:damage()._state and painting:damage()._state.object and painting:damage()._state.object["3878622f45bc7dfe"] then
            local state = painting:damage()._state.object["3878622f45bc7dfe"].set_visibility
            -- Object at index 1 is our Idstring "3878622f45bc7dfe", no need to check that again
            -- This check is a bit different than in function EHI:LordOfWar(), because objects are going through "self:set_cat_state2()" in CoreSequenceManager.lua
            if state and state[2] then
                n_of_paintings = n_of_paintings + 1
            end
        end
    end]]
    --[[self:ShowLootCounter({ max = 9 })
    self:ShowAchievementLootCounter({
        achievement = "pink_panther",
        max = 9
    })
end]]

local min_bags = 4
if Global.game_settings.level_id == "gallery" then
    local TT = EHI.Trackers
    ---@type ParseAchievementTable
    local achievements =
    {
        cac_19 =
        {
            elements =
            {
                [100789] = { class = TT.AchievementStatus },
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

    local other =
    {
        [102437] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }, -- +5%
        [103884] = { id = "EscapeChance", special_function = SF.SetChanceFromElement } -- 100 %
    }

    EHI:ParseTriggers({
        other = other
    })

    if EHI:GetOption("show_escape_chance") then
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

---@type MissionDoorTable
local MissionDoor =
{
    -- Security doors
    [Vector3(-827.08, 115.886, 92.4429)] = 103191,
    [Vector3(-60.1138, 802.08, 92.4429)] = 103188,
    [Vector3(-140.886, -852.08, 92.4429)] = 103202
}
EHI:SetMissionDoorPosAndIndex(MissionDoor)
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