local EHI = EHI
if EHI._hooks.IngameWaitingForPlayersState then
    return
else
    EHI._hooks.IngameWaitingForPlayersState = true
end

local primary, secondary, is_stealth = nil, nil, false

local function HasWeaponEquipped(weapon_id)
    local primary_id = primary.weapon_id
    local secondary_id = secondary.weapon_id
    local pass, primary_selection, secondary_selection = false, false, false
    if primary_id == weapon_id then
        pass = true
        primary_selection = true
    end
    if secondary_id == weapon_id then
        pass = true
        secondary_selection = true
    end
    return pass, primary_selection, secondary_selection
end

local function HasWeaponTypeEquipped(type)
    local primary_category = tweak_data.weapon[primary.weapon_id] and tweak_data.weapon[primary.weapon_id].categories[1] or "no_category"
    local secondary_category = tweak_data.weapon[secondary.weapon_id] and tweak_data.weapon[secondary.weapon_id].categories[1] or "no_category"
    if primary_category == type or secondary_category == type then
        return true
    end
    return false
end

local function HasMeleeEquipped(melee_id)
    return managers.blackmarket:equipped_melee_weapon() == melee_id
end

local function HasMeleeTypeEquipped(type)
    local melee = managers.blackmarket:equipped_melee_weapon()
    local melee_tweak = tweak_data.blackmarket.melee_weapons[melee]
    if melee_tweak and melee_tweak.type and melee_tweak.type == type then
        return true
    end
    return false
end

local function HasPlayerStyleEquipped(player_style_id)
    return managers.blackmarket:equipped_player_style() == player_style_id
end

local function HasSuitVariationEquipped(variation_id)
    return managers.blackmarket:equipped_suit_variation() == variation_id
end

local function CheckWeaponsBlueprint(blueprint)
    local function CheckWeaponBlueprint(weapon_data)
        --_G.PrintTable(weapon_data.blueprint or {})
        if table.contains(weapon_data.blueprint or {}, blueprint) then
            return true
        end
        return false
    end
    local pass, primary_pass, secondary_pass = false, false, false
    if CheckWeaponBlueprint(primary) then
        pass = true
        primary_pass = true
    end
    if CheckWeaponBlueprint(secondary) then
        pass = true
        secondary_pass = true
    end
    return pass, primary_pass, secondary_pass
end

local function ArbiterHasStandardAmmo(primary_index)
    local weapon
    if primary_index then
        weapon = managers.blackmarket:equipped_primary()
    else
        weapon = managers.blackmarket:equipped_secondary()
    end
    local t = managers.weapon_factory:get_ammo_data_from_weapon(weapon.factory_id, weapon.blueprint)
    return table.size(t or {}) == 0 -- Standard ammo type is not returned in the array, only the ammo upgrades
end

local function AddGageTracker()
    if EHI:GetOption("show_gage_tracker") and managers.ehi:TrackerDoesNotExist("Gage") and EHI._cache.GagePackages and EHI._cache.GagePackages > 0 then
        local max = tweak_data.gage_assignment:get_num_assignment_units() or 1
        managers.ehi:AddTracker({
            id = "Gage",
            icons = { "gage" },
            progress = EHI._cache.GagePackagesProgress or 0,
            exclude_from_sync = true,
            max = max,
            class = "EHIProgressTracker"
        })
    end
end

local function CreateProgressTracker(id, progress, max, dont_flash, remove_after_reaching_target, icons)
    managers.ehi:AddTracker({
        id = id,
        progress = progress,
        max = max,
        icons = icons or EHI:GetAchievementIcon(id),
        exclude_from_sync = true,
        dont_flash = dont_flash,
        flash_times = 1,
        remove_after_reaching_target = remove_after_reaching_target,
        class = "EHIProgressTracker"
    })
end

local function HookKillFunctionNoCivilian(achievement, weapon_id)
    EHI:HookWithID(StatisticsManager, "killed", "EHI_" .. achievement .. "_killed", function (self, data)
        if data.variant ~= "melee" and not CopDamage.is_civilian(data.name) then
            local name_id, _ = self:_get_name_id_and_throwable_id(data.weapon_unit)
            if name_id == weapon_id then
                managers.ehi:IncreaseTrackerProgress(achievement)
            end
        end
    end)
end

local function HookKillFunctionRequiredEnemyKill(achievement, weapon_id, enemy)
    EHI:HookWithID(StatisticsManager, "killed", "EHI_" .. achievement .. "_killed", function (self, data)
        if data.variant ~= "melee" and data.name == enemy then
            local name_id, _ = self:_get_name_id_and_throwable_id(data.weapon_unit)
            if name_id == weapon_id then
                managers.ehi:IncreaseTrackerProgress(achievement)
            end
        end
    end)
end

local function ShowTrackerInLoud(f)
    if is_stealth then
        EHI:AddOnAlarmCallback(f)
    else
        f()
    end
end

local function HookRequiredWeaponKill(primary_index, secondary_index)
    if primary_index and secondary_index then
    end
end

local original =
{
    at_exit = IngameWaitingForPlayersState.at_exit
}
function IngameWaitingForPlayersState:at_exit(...)
    original.at_exit(self, ...)
    if not Global.hud_disabled then
        managers.ehi:ShowPanel()
    end
    AddGageTracker()
    --[[if level == "flat" and EHI:IsAchievementLocked("flat_5") then
        managers.ehi:AddTracker({
            id = "flat_5",
            icons = { "C_Classics_H_PanicRoom_DontYouDare" },
            exclude_from_sync = true,
            dont_flash = true,
            class = "EHIChanceTracker"
        })
    else]]
    if not EHI:GetOption("show_achievement") or EHI._cache.AreAchievementsDisabled then
        return
    end
    primary = managers.blackmarket:equipped_primary()
    secondary = managers.blackmarket:equipped_secondary()
    is_stealth = managers.groupai:state():whisper_mode()
    local level = Global.game_settings.level_id
    local difficulty = Global.game_settings.difficulty
    local mask_id = managers.blackmarket:equipped_mask().mask_id
    if EHI:IsAchievementLocked2("halloween_4") and mask_id == tweak_data.achievement.witch_doctor.mask then -- "Witch Doctor" achievement
        CreateProgressTracker("halloween_4", EHI:GetAchievementProgress("halloween_4_stats"), 50, false, true)
        EHI:HookWithID(ReviveInteractionExt, "interact", "EHI_halloween_4_revive", function(self, reviving_unit)
            managers.ehi:IncreaseTrackerProgress("halloween_4")
        end)
    end
    if EHI:IsAchievementLocked2("halloween_5") and mask_id == tweak_data.achievement.its_alive_its_alive.mask then -- "It's Alive! IT'S ALIVE!" achievement
        CreateProgressTracker("halloween_5", EHI:GetAchievementProgress("halloween_5_stats"), 25, false, true)
        EHI:HookWithID(PlayerDamage, "damage_tase", "EHI_halloween_5_tased", function(self, attack_data)
            if self._god_mode or not self._tase_data then
                return
            end
            if attack_data.attacker_unit and attack_data.attacker_unit:alive() and attack_data.attacker_unit:base()._tweak_table == "taser" then
                managers.ehi:IncreaseTrackerProgress("halloween_5")
            end
        end)
    end
    if EHI:IsAchievementLocked2("halloween_6") and mask_id == tweak_data.achievement.pump_action.mask and HasWeaponTypeEquipped("shotgun") then -- "Pump-Action" achievement
        CreateProgressTracker("halloween_6", EHI:GetAchievementProgress("halloween_6_stats"), 666, false, true)
        EHI:HookWithID(StatisticsManager, "killed", "EHI_halloween_6_killed", function (_, data)
            if data.variant ~= "melee" and data.weapon_unit and data.weapon_unit:base():is_category("shotgun") and not CopDamage.is_civilian(data.name) then
                managers.ehi:IncreaseTrackerProgress("halloween_6")
            end
        end)
    end
    if EHI:IsAchievementLocked2("halloween_7") and mask_id == tweak_data.achievement.cant_hear_you_scream.mask then -- "No One Can Hear You Scream" achievement
        if is_stealth then
            CreateProgressTracker("halloween_7", EHI:GetAchievementProgress("halloween_7_stats"), 50, false, true)
            EHI:HookWithID(StatisticsManager, "killed", "EHI_halloween_7_killed", function (_, data)
                if data.variant == "melee" and not CopDamage.is_civilian(data.name) then
                    managers.ehi:IncreaseTrackerProgress("halloween_7")
                end
            end)
            EHI:AddOnAlarmCallback(function()
                EHI:Unhook("halloween_7_killed") -- "Includes 'EHI_'"
                managers.ehi:RemoveTracker("halloween_7")
            end)
        end
    end
    if EHI:IsAchievementLocked2("halloween_8") then -- "The Pumpkin King Made Me Do It!" achievement
        local pass, _, _ = HasWeaponEquipped("usp")
        if pass then
            CreateProgressTracker("halloween_8", EHI:GetAchievementProgress("halloween_8_stats"), 666, false, true)
            HookKillFunctionNoCivilian("halloween_8", "usp")
        end
    end
    if EHI:IsAchievementLocked2("armored_5") then -- "License to Kill" achievement
        local pass, _, _ = HasWeaponEquipped("ppk")
        if pass then
            CreateProgressTracker("armored_5", EHI:GetAchievementProgress("armored_5_stat"), 378, false, true)
            HookKillFunctionNoCivilian("armored_5", "ppk")
        end
    end
    if EHI:IsAchievementLocked2("armored_7") and mask_id == tweak_data.achievement.enemy_kill_achievements.im_not_a_crook.mask then -- "I'm Not a Crook!" achievement
        local pass, _, _ = HasWeaponEquipped("s552")
        if pass then
            local function f()
                CreateProgressTracker("armored_7", EHI:GetAchievementProgress("armored_7_stat"), 69, false, true)
                HookKillFunctionRequiredEnemyKill("armored_7", "s552", "sniper")
            end
            ShowTrackerInLoud(f)
        end
    end
    if EHI:IsAchievementLocked2("armored_8") and mask_id == tweak_data.achievement.relation_with_bulldozer.mask then -- "I Did Not Have Sexual Relations With That Bulldozer" achievement
        local function f()
            CreateProgressTracker("armored_8", EHI:GetAchievementProgress("armored_8_stat"), 7, false, true)
            EHI:HookWithID(StatisticsManager, "trade", "EHI_armored_8_traded", function(...)
                managers.ehi:IncreaseTrackerProgress("armored_8")
            end)
        end
        ShowTrackerInLoud(f)
    end
    if EHI:IsAchievementLocked2("armored_9") and mask_id == tweak_data.achievement.enemy_kill_achievements.fool_me_once.mask then -- "Fool Me Once, Shame on -Shame on You. Fool Me - You Can't Get Fooled Again" achievement
        local pass, _, _ = HasWeaponEquipped("m45")
        if pass then
            local function f()
                CreateProgressTracker("armored_9", EHI:GetAchievementProgress("armored_9_stat"), 95, false, true)
                HookKillFunctionRequiredEnemyKill("armored_9", "m45", "shield")
            end
            ShowTrackerInLoud(f)
        end
    end
    if EHI:IsAchievementLocked2("gage_1") and mask_id == tweak_data.achievement.enemy_kill_achievements.wanted.mask then -- "Wanted" achievement
        local pass, _, _ = HasWeaponEquipped("ak5")
        if pass then
            CreateProgressTracker("gage_1", EHI:GetAchievementProgress("gage_1_stats"), 100, false, true)
            HookKillFunctionNoCivilian("gage_1", "ak5")
        end
    end
    if EHI:IsAchievementLocked2("gage_2") and mask_id == tweak_data.achievement.enemy_kill_achievements.three_thousand_miles.mask then -- "3000 Miles to the Safe House" achievement
        local pass, _, _ = HasWeaponEquipped("p90")
        if pass then
            CreateProgressTracker("gage_2", EHI:GetAchievementProgress("gage_2_stats"), 100, false, true)
            HookKillFunctionNoCivilian("gage_2", "p90")
        end
    end
    if EHI:IsAchievementLocked2("gage_3") and mask_id == tweak_data.achievement.enemy_kill_achievements.commando.mask then -- "Commando" achievement
        local pass, _, _ = HasWeaponEquipped("aug")
        if pass then
            CreateProgressTracker("gage_3", EHI:GetAchievementProgress("gage_3_stats"), 100, false, true)
            HookKillFunctionNoCivilian("gage_2", "aug")
        end
    end
    if EHI:IsAchievementLocked2("gage_4") and mask_id == tweak_data.achievement.enemy_kill_achievements.public_enemies.mask then -- "Public Enemies" achievement
        local pass, _, _ = HasWeaponEquipped("m45")
        if pass then
            CreateProgressTracker("gage_4", EHI:GetAchievementProgress("gage_4_stats"), 100, false, true)
            HookKillFunctionNoCivilian("gage_4", "aug")
        end
    end
    if EHI:IsAchievementLocked2("gage_5") then -- "Inception" achievement
        local pass, _, _ = HasWeaponEquipped("scar")
        if pass then
            CreateProgressTracker("gage_5", EHI:GetAchievementProgress("gage_5_stats"), 100, false, true)
            HookKillFunctionNoCivilian("gage_5", "scar")
        end
    end
    if EHI:IsAchievementLocked2("gage_6") then -- "Hard Corps" achievement
        local pass, _, _ = HasWeaponEquipped("mp7")
        if pass then
            CreateProgressTracker("gage_6", EHI:GetAchievementProgress("gage_6_stats"), 100, false, true)
            HookKillFunctionNoCivilian("gage_6", "mp7")
        end
    end
    if EHI:IsAchievementLocked2("gage_7") then -- "Above the Law" achievement
        local pass, _, _ = HasWeaponEquipped("p226")
        if pass then
            CreateProgressTracker("gage_7", EHI:GetAchievementProgress("gage_7_stats"), 100, false, true)
            HookKillFunctionNoCivilian("gage_7", "p226")
        end
    end
    if EHI:IsAchievementLocked2("gage2_5") and HasWeaponTypeEquipped("lmg") then -- "The Eighth and Final Rule" achievement
        local function f()
            CreateProgressTracker("gage2_5", 0, 220, false, true)
            EHI:HookWithID(StatisticsManager, "killed", "EHI_gage2_5_killed", function (self, data)
                if data.variant ~= "melee" and data.weapon_unit and data.weapon_unit:base():is_category("lmg") and not CopDamage.is_civilian(data.name) then
                    managers.ehi:IncreaseTrackerProgress("gage2_5")
                end
            end)
        end
        ShowTrackerInLoud(f)
    end
    if EHI:IsOVKOrAbove(difficulty) and EHI:IsAchievementLocked2("gage2_9") and HasMeleeTypeEquipped("knife") then -- "I Ain't Got Time to Bleed" achievement
        local function f()
            CreateProgressTracker("gage2_9", EHI:GetAchievementProgress("gage2_9_stats"), 15, false, true)
            EHI:HookWithID(StatisticsManager, "killed", "EHI_gage2_5_killed", function (self, data)
                if data.variant == "melee" and managers.player:player_unit():character_damage():health_ratio() <= 0.25 and (data.name == "fbi_swat" or data.name == "fbi_heavy_swat") then
                    managers.ehi:IncreaseTrackerProgress("gage2_9")
                end
            end)
        end
        ShowTrackerInLoud(f)
    end
    if EHI:DifficultyToIndex(difficulty) >= 4 and EHI:IsAchievementLocked2("gage3_2") then -- "The Man With the Golden Gun" achievement
        local pass, _, _ = HasWeaponEquipped("akm_gold")
        if pass then
            local function f()
                CreateProgressTracker("gage3_2", EHI:GetAchievementProgress("gage3_2_stats"), 6, false, true)
                EHI:HookWithID(StatisticsManager, "killed", "EHI_gage3_2_killed", function (self, data)
                    if data.variant ~= "melee" and data.name == "tank" and (data.stats_name and data.stats_name == "tank_skull") then
                        local name_id, _ = self:_get_name_id_and_throwable_id(data.weapon_unit)
                        if name_id == "akm_gold" then
                            managers.ehi:IncreaseTrackerProgress("gage3_2")
                        end
                    end
                end)
            end
            ShowTrackerInLoud(f)
        end
    end
    if EHI:IsAchievementLocked2("gage3_6") and HasWeaponTypeEquipped("snp") then
        if EHI:IsAchievementLocked2("gage3_3") then -- "Lord of the Flies" achievement
            CreateProgressTracker("gage3_3", EHI:GetAchievementProgress("gage3_3_stats"), 50, false, true)
        end
        if EHI:IsAchievementLocked2("gage3_4") then -- "Arachne's Curse" achievement
            CreateProgressTracker("gage3_4", EHI:GetAchievementProgress("gage3_4_stats"), 100, false, true)
        end
        if EHI:IsAchievementLocked2("gage3_5") then -- "Pest Control" achievement
            CreateProgressTracker("gage3_5", EHI:GetAchievementProgress("gage3_5_stats"), 250, false, true)
        end
        CreateProgressTracker("gage3_6", EHI:GetAchievementProgress("gage3_6_stats"), 500, false, true) -- "Seer of Death" achievement
        EHI:HookWithID(StatisticsManager, "killed", "EHI_gage3_3-6_killed", function (self, data)
            if data.variant ~= "melee" and data.weapon_unit and data.weapon_unit:base():is_category("snp") and not CopDamage.is_civilian(data.name) and data.head_shot then
                managers.ehi:IncreaseTrackerProgress("gage3_3")
                managers.ehi:IncreaseTrackerProgress("gage3_4")
                managers.ehi:IncreaseTrackerProgress("gage3_5")
                managers.ehi:IncreaseTrackerProgress("gage3_6")
            end
        end)
    end
    if EHI:IsAchievementLocked2("gage3_11") then -- "Dodge This" achievement
        local pass, _, _ = HasWeaponEquipped("m95")
        if pass then
            local function f()
                CreateProgressTracker("gage3_11", EHI:GetAchievementProgress("gage3_11_stats"), 10, false, true)
                EHI:HookWithID(StatisticsManager, "killed", "EHI_gage3_11_killed", function (self, data)
                    if data.variant ~= "melee" and data.head_shot and data.name == "spooc" then
                        local name_id, _ = self:_get_name_id_and_throwable_id(data.weapon_unit)
                        if name_id == "m95" then
                            managers.ehi:IncreaseTrackerProgress("gage3_11")
                        end
                    end
                end)
            end
            ShowTrackerInLoud(f)
        end
    end
    if EHI:IsAchievementLocked2("gage3_12") then -- "Surprise Motherfucker" achievement
        local pass, _, _ = HasWeaponEquipped("m95")
        if pass then
            local function f()
                CreateProgressTracker("gage3_12", EHI:GetAchievementProgress("gage3_12_stats"), 10, false, true)
                HookKillFunctionRequiredEnemyKill("gage3_12", "m95", "tank")
            end
            ShowTrackerInLoud(f)
        end
    end
    if EHI:IsAchievementLocked2("gage3_14") then -- "Return to Sender" achievement
        local pass, _, _ = HasWeaponEquipped("msr")
        if pass then
            local function f()
                CreateProgressTracker("gage3_14", EHI:GetAchievementProgress("gage3_14_stats"), 25, false, true)
                HookKillFunctionRequiredEnemyKill("gage3_14", "msr", "sniper")
            end
            ShowTrackerInLoud(f)
        end
    end
    if EHI:IsAchievementLocked2("gage3_17") then -- "Public Enemy No. 1" achievement
        local pass, _, _ = HasWeaponEquipped("msr")
        if pass then
            local function f()
                CreateProgressTracker("gage3_17", EHI:GetAchievementProgress("gage3_17_stats"), 250, false, true)
                HookKillFunctionNoCivilian("gage3_17", "msr")
            end
            ShowTrackerInLoud(f)
        end
    end
    --[[if EHI:IsAchievementLocked2("gage4_3") then -- "Swing Dancing" achievement
        CreateProgressTracker("gage4_3", 0, 50, false, true)
        EHI:HookWithID(StatisticsManager, "killed", "EHI_gage4_3_killed", function (self, data)
            if data.variant == "melee" then
                if not CopDamage.is_civilian(data.name) then
                    managers.ehi:IncreaseTrackerProgress("gage4_3")
                end
            else
                managers.ehi:SetAchievementFailed("gage4_3")
                EHI:Unhook("gage4_3_killed")
            end
        end)
    end]]
    if EHI:IsAchievementLocked2("gage4_6") and HasWeaponTypeEquipped("shotgun") then -- "Knock, Knock" achievement
        local pass, primary_index, secondary_index = CheckWeaponsBlueprint("wpn_fps_upg_a_slug")
        if pass then
            local function f()
                CreateProgressTracker("gage4_6", EHI:GetAchievementProgress("gage4_6_stats"), 50, false, true)
            end
            if primary_index and secondary_index then
                local primary_weapon = primary.weapon_id
                local secondary_weapon = secondary.weapon_id
                EHI:HookWithID(StatisticsManager, "killed", "EHI_gage4_6_killed", function (self, data)
                    if data.variant ~= "melee" and data.name == "shield" then
                        local name_id, _ = self:_get_name_id_and_throwable_id(data.weapon_unit)
                        if name_id == primary_weapon or name_id == secondary_weapon then
                            managers.ehi:IncreaseTrackerProgress("gage4_6")
                        end
                    end
                end)
            else
                local weapon_required = nil
                if primary_index then
                    weapon_required = primary.weapon_id
                else
                    weapon_required = secondary.weapon_id
                end
                HookKillFunctionRequiredEnemyKill("gage4_6", weapon_required, "shield")
            end
            ShowTrackerInLoud(f)
        end
    end
    if EHI:IsAchievementLocked2("gage4_8") and HasWeaponTypeEquipped("shotgun") then -- "Clay Pigeon Shooting" achievement
        local pass, primary_index, secondary_index = CheckWeaponsBlueprint("wpn_fps_upg_a_piercing")
        if pass then
            local function f()
                CreateProgressTracker("gage4_8", EHI:GetAchievementProgress("gage4_8_stats"), 10, false, true)
                if primary_index and secondary_index then
                    local primary_weapon = primary.weapon_id
                    local secondary_weapon = secondary.weapon_id
                    EHI:HookWithID(StatisticsManager, "killed", "EHI_gage4_8_killed", function (self, data)
                        if data.variant ~= "melee" and data.name == "sniper" then
                            local name_id, _ = self:_get_name_id_and_throwable_id(data.weapon_unit)
                            if name_id == primary_weapon or name_id == secondary_weapon then
                                managers.ehi:IncreaseTrackerProgress("gage4_8")
                            end
                        end
                    end)
                else
                    local weapon_required = nil
                    if primary_index then
                        weapon_required = primary.weapon_id
                    else
                        weapon_required = secondary.weapon_id
                    end
                    HookKillFunctionRequiredEnemyKill("gage4_8", weapon_required, "sniper")
                end
            end
            ShowTrackerInLoud(f)
        end
    end
    if EHI:IsAchievementLocked2("gage4_10") and HasWeaponTypeEquipped("shotgun") then -- "Bang for the Buck" achievement
        local pass, primary_index, secondary_index = CheckWeaponsBlueprint("wpn_fps_upg_a_custom")
        local pass2, primary_index2, secondary_index2 = CheckWeaponsBlueprint("wpn_fps_upg_a_custom_free")
        if pass or pass2 then
            local function f()
                CreateProgressTracker("gage4_10", EHI:GetAchievementProgress("gage4_10_stats"), 10, false, true)
                if (primary_index or primary_index2) and (secondary_index or secondary_index2) then
                    local primary_weapon = primary.weapon_id
                    local secondary_weapon = secondary.weapon_id
                    EHI:HookWithID(StatisticsManager, "killed", "EHI_gage4_10_killed", function (self, data)
                        if data.variant ~= "melee" and data.name == "tank" then
                            local name_id, _ = self:_get_name_id_and_throwable_id(data.weapon_unit)
                            if name_id == primary_weapon or name_id == secondary_weapon then
                                managers.ehi:IncreaseTrackerProgress("gage4_10")
                            end
                        end
                    end)
                else
                    local weapon_required = nil
                    if primary_index or primary_index2 then
                        weapon_required = primary.weapon_id
                    else
                        weapon_required = secondary.weapon_id
                    end
                    HookKillFunctionRequiredEnemyKill("gage4_10", weapon_required, "tank")
                end
            end
            ShowTrackerInLoud(f)
        end
    end
    if EHI:IsAchievementLocked2("gage5_1") then -- "Precision Aiming" achievement
        local pass, primary_index, secondary_index = HasWeaponEquipped("g3")
        if pass then
            local function f()
                CreateProgressTracker("gage5_1", EHI:GetAchievementProgress("gage5_1_stats"), 25, false, true)
                if primary_index and secondary_index then
                    local primary_weapon = primary.weapon_id
                    local secondary_weapon = secondary.weapon_id
                    EHI:HookWithID(StatisticsManager, "killed", "EHI_gage5_1_killed", function (self, data)
                        if data.variant ~= "melee" and data.name == "tank" then
                            local name_id, _ = self:_get_name_id_and_throwable_id(data.weapon_unit)
                            if name_id == primary_weapon or name_id == secondary_weapon then
                                managers.ehi:IncreaseTrackerProgress("gage5_1")
                            end
                        end
                    end)
                else
                    local weapon_required = nil
                    if primary_index then
                        weapon_required = primary.weapon_id
                    else
                        weapon_required = secondary.weapon_id
                    end
                    HookKillFunctionRequiredEnemyKill("gage5_1", weapon_required, "tank")
                end
            end
            ShowTrackerInLoud(f)
        end
    end
    if EHI:IsAchievementLocked2("gage5_8") and HasMeleeEquipped("dingdong") then -- "Hammertime" achievement
        CreateProgressTracker("gage5_8", EHI:GetAchievementProgress("gage5_8_stats"), 25, false, true)
        EHI:HookWithID(StatisticsManager, "killed", "EHI_gage5_8_killed", function (self, data)
            if data.variant == "melee" and CopDamage.is_gangster(data.name) then
                managers.ehi:IncreaseTrackerProgress("gage5_8")
            end
        end)
    end
    if EHI:IsAchievementLocked2("gage5_9") then -- "Rabbit Hunting" achievement
        local pass, primary_index, secondary_index = HasWeaponEquipped("galil")
        if pass then
            local function f()
                CreateProgressTracker("gage5_9", EHI:GetAchievementProgress("gage5_9_stats"), 10, false, true)
                if primary_index and secondary_index then
                    local primary_weapon = primary.weapon_id
                    local secondary_weapon = secondary.weapon_id
                    EHI:HookWithID(StatisticsManager, "killed", "EHI_gage5_9_killed", function (self, data)
                        if data.variant ~= "melee" and data.name == "spooc" then
                            local name_id, _ = self:_get_name_id_and_throwable_id(data.weapon_unit)
                            if name_id == primary_weapon or name_id == secondary_weapon then
                                managers.ehi:IncreaseTrackerProgress("gage5_9")
                            end
                        end
                    end)
                else
                    local weapon_required = nil
                    if primary_index then
                        weapon_required = primary.weapon_id
                    else
                        weapon_required = secondary.weapon_id
                    end
                    HookKillFunctionRequiredEnemyKill("gage5_9", weapon_required, "spooc")
                end
            end
            ShowTrackerInLoud(f)
        end
    end
    if EHI:IsAchievementLocked2("gage5_10") then -- "Tour de Clarion" achievement
        local pass, primary_index, secondary_index = HasWeaponEquipped("famas")
        if pass then
            CreateProgressTracker("gage5_10", EHI:GetAchievementProgress("gage5_10_stats"), 200, false, true)
            if primary_index and secondary_index then
                local primary_weapon = primary.weapon_id
                local secondary_weapon = secondary.weapon_id
                EHI:HookWithID(StatisticsManager, "killed", "EHI_gage5_10_killed", function (self, data)
                    if data.variant ~= "melee" and not CopDamage.is_civilian(data.name) then
                        local name_id, _ = self:_get_name_id_and_throwable_id(data.weapon_unit)
                        if name_id == primary_weapon or name_id == secondary_weapon then
                            managers.ehi:IncreaseTrackerProgress("gage5_10")
                        end
                    end
                end)
            else
                local weapon_required = nil
                if primary_index then
                    weapon_required = primary.weapon_id
                else
                    weapon_required = secondary.weapon_id
                end
                HookKillFunctionNoCivilian("gage5_10", weapon_required)
            end
        end
    end
    if EHI:IsAchievementLocked2("eagle_2") and HasMeleeEquipped("fairbair") then -- "Special Operations Execution" achievement
        if is_stealth then
            CreateProgressTracker("eagle_2", EHI:GetAchievementProgress("eagle_2_stats"), 25, false, true)
            EHI:HookWithID(StatisticsManager, "killed", "EHI_eagle_2_killed", function (_, data)
                if data.variant == "melee" and not CopDamage.is_civilian(data.name) then
                    managers.ehi:IncreaseTrackerProgress("eagle_2")
                end
            end)
            EHI:AddOnAlarmCallback(function()
                EHI:Unhook("eagle_2_killed") -- "Includes 'EHI_'"
                managers.ehi:RemoveTracker("eagle_2")
            end)
        end
    end
    if EHI:IsAchievementLocked2("ameno_8") then -- "The Collector" achievement
        local needed_weapons = tweak_data.achievement.enemy_kill_achievements.akm4_shootout.weapons
        local primary_pass = table.index_of(needed_weapons, primary.weapon_id) ~= -1
        local secondary_pass = table.index_of(needed_weapons, secondary.weapon_id) ~= -1
        if primary_pass or secondary_pass then
            CreateProgressTracker("ameno_8", EHI:GetAchievementProgress("ameno_08_stats"), 100, false, true)
            EHI:HookWithID(StatisticsManager, "killed", "EHI_ameno_8_killed", function (self, data)
                if data.variant ~= "melee" and CopDamage.is_cop(data.name) then
                    local name_id, _ = self:_get_name_id_and_throwable_id(data.weapon_unit)
                    if table.index_of(needed_weapons, name_id) ~= -1 then
                        managers.ehi:IncreaseTrackerProgress("ameno_8")
                    end
                end
            end)
        end
    end
    if EHI:IsAchievementLocked2("turtles_1") then -- "Names Are for Friends, so I Don't Need One" achievement
        local pass, _, _ = HasWeaponEquipped("wa2000")
        if pass then
            CreateProgressTracker("turtles_1", 0, 11, false, true)
            EHI:HookWithID(StatisticsManager, "killed", "EHI_turtles_1_killed", function (self, data)
                if data.variant ~= "melee" and not CopDamage.is_civilian(data.name) then
                    local name_id, _ = self:_get_name_id_and_throwable_id(data.weapon_unit)
                    if name_id == "wa2000" then
                        managers.ehi:IncreaseTrackerProgress("turtles_1")
                    end
                end
            end)
            EHI:Hook(RaycastWeaponBase, "on_reload", function(self, amount)
                if self:get_name_id() == "wa2000" then
                    managers.ehi:SetTrackerProgress("turtles_1", 0)
                end
            end)
        end
    end
    if EHI:IsAchievementLocked2("turtles_2") then -- "Swiss Cheese" achievement
        local pass, _, _ = HasWeaponEquipped("polymer")
        if pass then
            CreateProgressTracker("turtles_2", 0, 100, false, true)
            HookKillFunctionNoCivilian("turtles_2", "polymer")
        end
    end
    if EHI:IsAchievementLocked2("steel_2") then -- "Their Armor Is Thick and Their Shields Broad" achievement
        local melee_required = tweak_data.achievement.enemy_melee_hit_achievements.steel_2.melee_weapons
        local pass = table.index_of(melee_required, managers.blackmarket:equipped_melee_weapon()) ~= -1
        if pass then
            CreateProgressTracker("steel_2", 0, 10, false, true)
            EHI:HookWithID(StatisticsManager, "killed", "EHI_steel_2_killed", function (self, data)
                if data.variant == "melee" and data.name == "shield" then
                    managers.ehi:IncreaseTrackerProgress("steel_2")
                end
            end)
        end
    end
    if EHI:IsAchievementLocked2("pim_1") and EHI:IsOVKOrAbove(Global.game_settings.difficulty) then -- "Nothing Personal" achievement
        local pass, _, _ = HasWeaponEquipped("desertfox")
        if pass then
            local function f()
                CreateProgressTracker("pim_1", EHI:GetAchievementProgress("pim_1_stats"), 30, false, true)
                HookKillFunctionRequiredEnemyKill("pim_1", "desertfox", "sniper")
            end
            ShowTrackerInLoud(f)
        end
    end
    if EHI:IsAchievementLocked2("tango_achieve_2") then -- "Let Them Fly" achievement
        local pass, primary_index, _ = HasWeaponEquipped("arbiter")
        local pass2 = ArbiterHasStandardAmmo(primary_index)
        if pass and pass2 then
            local function f()
                CreateProgressTracker("tango_achieve_2", EHI:GetAchievementProgress("tango_2_stats"), 50, false, true)
                HookKillFunctionRequiredEnemyKill("tango_achieve_2", "arbiter", "sniper")
            end
            ShowTrackerInLoud(f)
        end
    end
    if EHI:DifficultyToIndex(difficulty) >= 2 and EHI:IsAchievementLocked2("tango_achieve_3") then -- "The Reckoning" achievement
        local pass, primary_index, secondary_index = CheckWeaponsBlueprint(tweak_data.achievement.complete_heist_achievements.tango_3.killed_by_blueprint.blueprint)
        if pass then
            CreateProgressTracker("tango_achieve_3", 0, 200, false, false)
            if primary_index and secondary_index then
                local primary_weapon = primary.weapon_id
                local secondary_weapon = secondary.weapon_id
                EHI:HookWithID(StatisticsManager, "killed", "EHI_tango_achieve_3_killed", function (self, data)
                    if data.variant ~= "melee" and not CopDamage.is_civilian(data.name) then
                        local name_id, _ = self:_get_name_id_and_throwable_id(data.weapon_unit)
                        if name_id == primary_weapon or name_id == secondary_weapon then
                            managers.ehi:IncreaseTrackerProgress("tango_achieve_3")
                        end
                    end
                end)
            else
                local weapon_required = nil
                if primary_index then
                    weapon_required = primary.weapon_id
                else
                    weapon_required = secondary.weapon_id
                end
                HookKillFunctionNoCivilian("tango_achieve_3", weapon_required)
            end
        end
    end
    if EHI:IsAchievementLocked2("grv_2") then -- "Spray Control" achievement
        local pass, _, _ = HasWeaponEquipped("coal")
        if pass then
            CreateProgressTracker("grv_2", 0, 32, false, true)
            EHI:HookWithID(StatisticsManager, "killed", "EHI_grv_2_killed", function (self, data)
                if data.variant ~= "melee" and not CopDamage.is_civilian(data.name) then
                    local name_id, _ = self:_get_name_id_and_throwable_id(data.weapon_unit)
                    if name_id == "coal" then
                        managers.ehi:IncreaseTrackerProgress("grv_2")
                    end
                end
            end)
            EHI:Hook(RaycastWeaponBase, "on_reload", function(self, amount)
                if self:get_name_id() == "coal" then
                    managers.ehi:SetTrackerProgress("grv_2", 0)
                end
            end)
        end
    end
    if EHI:IsAchievementLocked2("grv_3") then -- "Have Nice Day!" achievement
        local weapons_required = tweak_data.achievement.enemy_kill_achievements.grv_3.weapons
        local pass = table.index_of(weapons_required, primary.weapon_id) ~= -1
        local pass2 = table.index_of(weapons_required, secondary.weapon_id) ~= -1
        if pass or pass2 then
            CreateProgressTracker("grv_3", EHI:GetAchievementProgress("grv_3_stats"), 300, false, true)
            EHI:HookWithID(StatisticsManager, "killed", "EHI_grv_3_killed", function (self, data)
                if data.variant ~= "melee" and not CopDamage.is_civilian(data.name) then
                    local name_id, _ = self:_get_name_id_and_throwable_id(data.weapon_unit)
                    if table.index_of(weapons_required, name_id) ~= -1 then
                        managers.ehi:IncreaseTrackerProgress("grv_3")
                    end
                end
            end)
        end
    end
    if EHI:IsAchievementLocked2("cac_2") then -- "Human Sentry Gun" achievement
        local pass, _, _ = CheckWeaponsBlueprint("wpn_fps_upg_bp_lmg_lionbipod")
        if pass then
            local function f()
                local enemy_killed_key = "EHI_cac_2_enemy_killed"
                CreateProgressTracker("cac_2", 0, 20, false, true)
                local function on_enemy_killed(...)
                    managers.ehi:IncreaseTrackerProgress("cac_2")
                end
                local function on_player_state_changed(state_name)
                    managers.ehi:SetTrackerProgress("cac_2", 0)
                    if state_name == "bipod" then
                        managers.player:register_message(Message.OnEnemyKilled, enemy_killed_key, on_enemy_killed)
                    else
                        managers.player:unregister_message(Message.OnEnemyKilled, enemy_killed_key)
                    end
                end
                managers.player:register_message("player_state_changed", "EHI_cac_2_state_changed_key", on_player_state_changed)
                ShowTrackerInLoud(f)
            end
        end
    end
    if EHI:IsAchievementLocked2("cac_3") then -- "Denied" achievement
        local function f()
            CreateProgressTracker("cac_3", EHI:GetAchievementProgress("cac_3_stats"), 30, false, true)
            managers.player:register_message("flash_grenade_destroyed", "EHI_cac_3_flash_destroyed", function(attacker_unit)
                local local_player = managers.player:player_unit()
                if local_player and attacker_unit == local_player then
                    managers.ehi:IncreaseTrackerProgress("cac_3")
                end
            end)
            ShowTrackerInLoud(f)
        end
    end
    if EHI:IsAchievementLocked2("gsu_01") and HasMeleeEquipped("spoon") then -- "For all you legends" achievement
        CreateProgressTracker("gsu_01", EHI:GetAchievementProgress("gsu_stat"), 100, false, true)
        EHI:HookWithID(StatisticsManager, "killed", "EHI_gsu_01_killed", function (self, data)
            if data.variant == "melee" and not CopDamage.is_civilian(data.name) then
                managers.ehi:IncreaseTrackerProgress("gsu_01")
            end
        end)
    end
    if EHI:IsAchievementLocked2("sawp_1") and EHI:IsOVKOrAbove(Global.game_settings.difficulty) then -- "Buzzbomb" achievement
        local achievement_data = tweak_data.achievement.enemy_melee_hit_achievements.sawp_1
        local melee_pass = table.index_of(achievement_data.melee_weapons, managers.blackmarket:equipped_melee_weapon()) ~= -1
        local player_style_pass = HasPlayerStyleEquipped(achievement_data.player_style.style)
        local variation_pass = HasSuitVariationEquipped(achievement_data.player_style.variation)
        if melee_pass and player_style_pass and variation_pass then
            CreateProgressTracker("sawp_1", EHI:GetAchievementProgress("sawp_stat"), 200, false, true)
            EHI:HookWithID(StatisticsManager, "killed", "EHI_sawp_1_killed", function (self, data)
                if data.variant == "melee" and not CopDamage.is_civilian(data.name) then
                    managers.ehi:IncreaseTrackerProgress("sawp_1")
                end
            end)
        end
    end
    if level == "nightclub" then
        if EHI:IsAchievementLocked2("gage2_3") and HasMeleeEquipped("fists") then -- "The Eighth and Final Rule" achievement
            local function f()
                CreateProgressTracker("gage2_3", EHI:GetAchievementProgress("gage2_3_stats"), 50, false, true)
                EHI:HookWithID(StatisticsManager, "killed", "EHI_gage2_3_killed", function (self, data)
                    if data.variant == "melee" and CopDamage.is_cop(data.name) then
                        managers.ehi:IncreaseTrackerProgress("gage2_3")
                    end
                end)
            end
            ShowTrackerInLoud(f)
        end
        if EHI:IsAchievementLocked2("gage4_7") and HasMeleeEquipped("shovel") then -- "Every day I'm Shovelin'" achievement
            local function f()
                CreateProgressTracker("gage4_7", EHI:GetAchievementProgress("gage4_7_stats"), 25, false, true)
                EHI:HookWithID(StatisticsManager, "killed", "EHI_gage4_7_killed", function (self, data)
                    if data.variant == "melee" and CopDamage.is_cop(data.name) then
                        managers.ehi:IncreaseTrackerProgress("gage4_7")
                    end
                end)
            end
            ShowTrackerInLoud(f)
        end
    end
    if (level == "mia_1" or level == "mia_2") and EHI:IsAchievementLocked2("pig_3") and HasMeleeEquipped("baseballbat") then -- "Do You Like Hurting Other People?" achievement
        CreateProgressTracker("pig_3", EHI:GetAchievementProgress("pig_3_stats"), 30, false, true)
        EHI:HookWithID(StatisticsManager, "killed", "EHI_gage5_10_killed", function (self, data)
            if data.variant == "melee" and CopDamage.is_gangster(data.name) then
                managers.ehi:IncreaseTrackerProgress("pig_3")
            end
        end)
    end
    if level == "mad" and EHI:IsAchievementLocked2("pim_3") and EHI:IsOVKOrAbove(Global.game_settings.difficulty) then -- "UMP for Me, UMP for You" achievement
        local pass, _, _ = HasWeaponEquipped("schakal")
        if pass then
            CreateProgressTracker("pim_3", EHI:GetAchievementProgress("pim_3_stats"), 45, false, true)
            EHI:HookWithID(StatisticsManager, "killed", "EHI_pim_3_killed", function (self, data)
                if data.variant ~= "melee" and table.index_of(tweak_data.achievement.enemy_kill_achievements.pim_3.enemies, data.name) ~= -1 then
                    local name_id, _ = self:_get_name_id_and_throwable_id(data.weapon_unit)
                    if name_id == "schakal" then
                        managers.ehi:IncreaseTrackerProgress("pim_3")
                    end
                end
            end)
        end
    end
    if level == "help" and EHI:IsAchievementLocked2("tawp_1") and EHI:DifficultyToIndex(Global.game_settings.difficulty) >= 2 and mask_id == tweak_data.achievement.complete_heist_achievements.tawp_1.mask then -- "Cloaker Charmer" achievement
        CreateProgressTracker("tawp_1", 0, 1, false, false)
        EHI:HookWithID(StatisticsManager, "killed", "EHI_tawp_1_killed", function (self, data)
            if data.name == "spooc" then
                managers.ehi:IncreaseTrackerProgress("tawp_1")
            end
        end)
    end
    if (level == "rvd1" or level == "rvd2") and EHI:IsAchievementLocked2("rvd_12") and EHI:IsOVKOrAbove(Global.game_settings.difficulty) and HasMeleeEquipped("clean") then
        CreateProgressTracker("rvd_12", EHI:GetAchievementProgress("rvd_12_stats"), 92, false, true)
        EHI:HookWithID(StatisticsManager, "killed", "EHI_rvd_12_killed", function (self, data)
            if data.variant == "melee" and table.index_of(tweak_data.achievement.enemy_kill_achievements.pim_3.enemies, data.name) ~= -1 then
                managers.ehi:IncreaseTrackerProgress("rvd_12")
            end
        end)
    end
    if level == "bph" and EHI:IsAchievementLocked2("bph_9") and EHI:IsOVKOrAbove(Global.game_settings.difficulty) and HasMeleeEquipped("toothbrush") then -- "Prison Rules, Bitch!" achievement
        CreateProgressTracker("bph_9", EHI:GetAchievementProgress("bph_9_stat"), 13, false, true)
        EHI:HookWithID(StatisticsManager, "killed", "EHI_bph_9_killed", function (self, data)
            if data.variant == "melee" then
                managers.ehi:IncreaseTrackerProgress("bph_9")
            end
        end)
    end
    if level == "sand" and EHI:IsOVKOrAbove(difficulty) and EHI:IsAchievementLocked2("sand_11") and HasWeaponTypeEquipped("snp") then -- "This Calls for a Round of Sputniks!" achievement
        CreateProgressTracker("sand_11_kills", 0, 100, true, false, { "C_JiuFeng_H_UkrainianPrisoner_ThisCallForARound", "C_All_H_All_AllJobs_D0" })
        managers.ehi:AddTracker({
            id = "sand_11_accuracy",
            icons = { "C_JiuFeng_H_UkrainianPrisoner_ThisCallForARound", "pd2_kill" },
            exclude_from_sync = true,
            dont_flash = true,
            class = "EHIChanceTracker"
        })
        EHI:HookWithID(StatisticsManager, "killed", "EHI_sand_11_killed", function (_, data)
            if data.variant ~= "melee" and data.weapon_unit and data.weapon_unit:base():is_category("snp") then
                managers.ehi:IncreaseTrackerProgress("sand_11_kills")
            end
        end)
        EHI:HookWithID(StatisticsManager, "shot_fired", "EHI_sand_11_accuracy", function(self, data)
            managers.ehi:SetChance("sand_11_accuracy", self:session_hit_accuracy())
        end)
    end
end