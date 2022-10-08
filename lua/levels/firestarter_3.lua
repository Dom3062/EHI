local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {}
local achievements = {}
local other = {}
local level_id = Global.game_settings.level_id
if level_id == "firestarter_3" then
    local dw_and_above = EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish)
    triggers = {
        [102144] = { time = 90, id = "MoneyBurn", icons = { Icon.Fire, Icon.Money } }
    }
    achievements =
    {
        [102144] = { status = "ok", id = "slakt_5", class = TT.AchievementStatus, difficulty_pass = dw_and_above },
        [102146] = { status = "finish", id = "slakt_5", special_function = SF.SetAchievementStatus },
        [105237] = { id = "slakt_5", special_function = SF.SetAchievementComplete },
        [105235] = { id = "slakt_5", special_function = SF.SetAchievementFailed }
    }
else
    -- Branchbank: Random, Branchbank: Gold, Branchbank: Cash, Branchbank: Deposit
    EHI:ShowAchievementBagValueCounter({
        achievement = "uno_1",
        value = tweak_data.achievement.complete_heist_achievements.uno_1.bag_loot_value,
        remove_after_reaching_target = false,
        counter =
        {
            check_type = EHI.LootCounter.CheckType.ValueOfBags
        }
    })
    if EHI:GetOption("show_escape_chance") then
        other = {
            [103306] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
        }
        EHI:AddOnAlarmCallback(function(dropin)
            local start_chance = 5
            if managers.mission:check_mission_filter(2) or managers.mission:check_mission_filter(3) then -- Cash or Gold
                start_chance = 15 -- 5 (start_chance) + 10
            end
            managers.ehi:AddEscapeChanceTracker(dropin, start_chance)
        end)
    end
end
triggers[101425] = { time = 24 + 7, id = "TeargasIncoming1", icons = { Icon.Teargas, "pd2_generic_look" }, class = TT.Warning }
triggers[105611] = { time = 24 + 7, id = "TeargasIncoming2", icons = { Icon.Teargas, "pd2_generic_look" }, class = TT.Warning }

achievements[101539] = { status = "bring", id = "voff_1", class = TT.AchievementStatus, difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) }
achievements[105686] = { id = "voff_1", special_function = SF.SetAchievementComplete }
achievements[105691] = { status = "finish", id = "voff_1", special_function = SF.SetAchievementStatus } -- Entered area again
achievements[105694] = { status = "finish", id = "voff_1", special_function = SF.SetAchievementStatus } -- Both secured
achievements[105698] = { status = "bring", id = "voff_1", special_function = SF.SetAchievementStatus } -- Left the area
achievements[105704] = { id = "voff_1", special_function = SF.SetAchievementFailed } -- Killed

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

local tbl =
{
    --units/payday2/equipment/gen_interactable_lance_large/gen_interactable_lance_large
    [104674] = { remove_vanilla_waypoint = true, waypoint_id = 102633 },
    [104466] = { remove_vanilla_waypoint = true, waypoint_id = 102752 }
}
EHI:UpdateUnits(tbl)

if not EHI:ShowMissionAchievements() then
    return
end
local dog_haters =
{
    [Idstring("units/payday2/characters/civ_male_dog_abuser_1/civ_male_dog_abuser_1"):key()] = true,
    [Idstring("units/payday2/characters/civ_male_dog_abuser_2/civ_male_dog_abuser_2"):key()] = true
}
EHI:AddLoadSyncFunction(function(self)
    local dog_haters_unit = {}
    local count = 0
    local civies = managers.enemy:all_civilians()
    for _, data in pairs(civies or {}) do
        local name_key = data.unit:name():key()
        if dog_haters[name_key] then
            count = count + 1
            dog_haters_unit[count] = data.unit
            dog_haters[name_key] = nil
        end
        if count == 2 then
            break
        end
    end
    if count ~= 2 then
        return
    end
    -- Exit areas share the same space
    local secure_area_1 = managers.mission:get_element_by_id(105674) -- ´dog_abuse_trigger_enter_001´ ElementAreaTrigger 105674
    local secure_area_2 = managers.mission:get_element_by_id(105678) -- ´dog_abuse_trigger_enter_002´ ElementAreaTrigger 105678
    local secure_area_3 = managers.mission:get_element_by_id(105679) -- ´dog_abuse_trigger_enter_003´ ElementAreaTrigger 105679
    if not (secure_area_1 and secure_area_2 and secure_area_3) then
        return
    end
    EHI:Trigger(101177)
    local pos_1 = dog_haters_unit[1]:position()
    local pos_2 = dog_haters_unit[2]:position()
    if (secure_area_1:_is_inside(pos_1) and secure_area_1:_is_inside(pos_2)) or
        (secure_area_2:_is_inside(pos_1) and secure_area_2:_is_inside(pos_2)) or
        (secure_area_3:_is_inside(pos_1) and secure_area_3:_is_inside(pos_2)) then
        self:SetAchievementStatus("voff_1", "finish")
    end
end)
EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
    if EHI:IsHost() or managers.ehi:GetStartedFromBeginning() then
        local function fail(...)
            managers.ehi:SetAchievementFailed("voff_1")
        end
        local civies = managers.enemy:all_civilians()
        for _, data in pairs(civies or {}) do
            local name_key = data.unit:name():key()
            if dog_haters[name_key] then
                data.unit:base():add_destroy_listener("EHI_" .. tostring(name_key), fail)
            end
        end
    end
end)