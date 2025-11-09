local EHI = EHI
if EHI:CheckLoadHook("IngameWaitingForPlayersState") then
    return
end

local gage3_13_levels =
{
    pbr = true,
    shoutout_raid = true,
    pent = true
}

-- Daily challenges activated in ChallengeManager
local challenges =
{
    any_25_spooc_kills = { progress_id = "any_spooc_kills", icon = "Other_H_Any_Holy", loud_only = true, check = { enemy_check = "spooc" } },
    any_25_shield_kills = { progress_id = "any_shield_kills", icon = "Other_H_Any_Maximum", loud_only = true, check = { enemy_check = "shield" } },
    any_25_tank_kills = { progress_id = "any_tank_kills", icon = "heavy", loud_only = true, check = { enemy_check = "tank" } },
    any_25_taser_kills = { progress_id = "any_taser_kills", loud_only = true, check = { enemy_check = "taser" } },
    any_25_sniper_kills = { progress_id = "any_sniper_kills", icon = "sniper", loud_only = true },
    any_50_headshot_kills = { progress_id = "any_headshot_kills" },
    any_300_kills = { progress_id = "any_kills", icon = "C_All_H_All_AllJobs_D0" },
    melee_35_kills = { progress_id = "melee_kills", icon = "Other_H_Any_IAintGotTime" },
    any_6_jobs = { progress_id = "any_jobs", icon = "pd2_escape", check_on_completion = true, do_not_track = true },
    dentist_4_jobs = { progress_id = "dentist_jobs", check_on_completion = true, contact = "the_dentist", contact_short_name = "dentist", do_not_track = true },
    butcher_4_jobs = { progress_id = "butcher_jobs", check_on_completion = true, contact = "the_butcher", contact_short_name = "butcher", do_not_track = true },
    elephant_4_jobs = { progress_id = "elephant_jobs", check_on_completion = true, contact = "the_elephant", contact_short_name = "elephant", do_not_track = true },
    hector_4_jobs = { progress_id = "hector_jobs", check_on_completion = true, contact = "hector", do_not_track = true },
    vlad_4_jobs = { progress_id = "vlad_jobs", check_on_completion = true, contact = "vlad", do_not_track = true },
    bain_4_jobs = { progress_id = "bain_jobs", check_on_completion = true, contact = "bain", do_not_track = true },
    assault_rifle_100_kills = { progress_id = "assault_rifle_kills", check = { weapon_type = "assault_rifle" } },
    shotgun_100_kills = { progress_id = "shotgun_kills", check = { weapon_type = "shotgun" } },
    smg_100_kills = { progress_id = "smg_kills", check = { weapon_type = "smg" } },
    pistol_100_kills = { progress_id = "pistol_kills", check = { weapon_type = "pistol" } },
    lmg_100_kills = { progress_id = "lmg_kills", check = { weapon_type = "lmg" } },
    sniper_100_kills = { progress_id = "sniper_kills", check = { weapon_type = "snp" } }
}
challenges.any_100_headshot_kills = challenges.any_50_headshot_kills
challenges.melee_100_kills = deep_clone(challenges.melee_35_kills)
challenges.melee_35_kills.desc = "menu_challenge_melee_kills"
for _, challenge in pairs(challenges) do
    if challenge.contact then
        challenge.icon = string.format("C_%s_H_All_AllDiffs_D0", select(1, string.gsub(challenge.contact_short_name or challenge.contact, "^%l", string.upper)))
    end
end

-- Daily challenges activated in CustomSafehouseManager
local sh_dailies =
{
    daily_hangover = { track = true, icon = "daily_hangover", check = { melee = "whiskey" } }, -- Kill with a bottle
    daily_lodsofemone = { hook_secured = true, achievement_icon = "cac_30" }, -- Secure money
    daily_classics = { hook_end = true, icon = "C_Classics_H_All_AllDiffs_D0" }, -- Complete Classics
    daily_discord = { hook_end = true, achievement_icon = "cac_11" }, -- Finish heists with at least 1 convert
    daily_grenades = { track = true, check = { grenades = { "frag", "frag_com", "dada_com", "dynamite" } } }, -- Kill with grenades
    daily_honorable = { track = true, icon = "Other_H_Any_IAintGotTime" }, -- Melee to death surrendered enemies
    daily_candy = { hook_secured = true, first_entry = true } -- Secure cocaine
}

-- Event Challenges active in SideJobEventManager  
-- Max seems hardcoded in EventJobsTweakData
local events =
{
    cg22_1 = { objective =
        {
            { check = { grenade = "xmas_snowball", mutator = "MutatorCG22" }, stat = "cg22_personal_1" },
            { check = { weapon_type = "snp" }, stat = "cg22_post_objective_1" }
        }
    }
}

local primary, secondary, melee, grenade, is_stealth = nil, nil, nil, nil, false ---@type EquippedWeaponData, EquippedWeaponData, string, string, boolean
local VeryHardOrAbove = EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard)
local OVKOrAbove = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local stats = {}

---@param id string Achievement ID
---@param stat string Achievement stat
function IngameWaitingForPlayersState:EHIAddToStats(id, stat)
    stats[stat] = id
end

---@param weapon_id string
local function HasWeaponEquipped(weapon_id)
    return primary.weapon_id == weapon_id or secondary.weapon_id == weapon_id
end

---@param type string
function IngameWaitingForPlayersState:EHIHasPrimaryWeaponTypeEquipped(type)
    local primary_categories = tweak_data.weapon[primary.weapon_id] and tweak_data.weapon[primary.weapon_id].categories or {}
    return table.contains(primary_categories, type)
end

---@param type string
function IngameWaitingForPlayersState:EHIHasWeaponTypeEquipped(type)
    local primary_categories = tweak_data.weapon[primary.weapon_id] and tweak_data.weapon[primary.weapon_id].categories or {}
    local secondary_categories = tweak_data.weapon[secondary.weapon_id] and tweak_data.weapon[secondary.weapon_id].categories or {}
    return table.contains(primary_categories, type) or table.contains(secondary_categories, type)
end

---@param melee_id string
function IngameWaitingForPlayersState:EHIHasMeleeEquipped(melee_id)
    return melee == melee_id
end

---@param type string
local function HasMeleeTypeEquipped(type)
    local melee_tweak = tweak_data.blackmarket.melee_weapons[melee]
    return melee_tweak and melee_tweak.type and melee_tweak.type == type
end

---@param grenade_id string
local function HasGrenadeEquipped(grenade_id)
    return grenade == grenade_id
end

local function HasNonExplosiveGrenadeEquipped()
    local projectile = tweak_data.blackmarket.projectiles[grenade]
    local tweak = tweak_data.projectiles[grenade]
    if projectile and tweak then
        if projectile.ability then
            return false
        elseif not projectile.is_explosive then
            return tweak.damage and tweak.damage > 0
        end
    end
    return false
end

---@param player_style_id string
local function HasPlayerStyleEquipped(player_style_id)
    return managers.blackmarket:equipped_player_style() == player_style_id
end

---@param variation_id string
local function HasSuitVariationEquipped(variation_id)
    return managers.blackmarket:equipped_suit_variation() == variation_id
end

---@param blueprint string
local function WeaponsContainBlueprint(blueprint)
    ---@param weapon_data EquippedWeaponData
    local function CheckWeaponBlueprint(weapon_data)
        return table.contains(weapon_data.blueprint or {}, blueprint)
    end
    return CheckWeaponBlueprint(primary) or CheckWeaponBlueprint(secondary)
end

---@param blueprint string
local function CheckWeaponsBlueprint(blueprint)
    ---@param weapon_data EquippedWeaponData
    local function CheckWeaponBlueprint(weapon_data)
        return table.contains(weapon_data.blueprint or {}, blueprint)
    end
    return CheckWeaponBlueprint(primary), CheckWeaponBlueprint(secondary)
end

local function ArbiterHasStandardAmmo()
    local function WeaponHasStandardAmmo(factory_id, blueprint)
        local t = managers.weapon_factory:get_ammo_data_from_weapon(factory_id, blueprint)
        return table.ehi_size(t) == 0 -- Standard ammo type is not returned in the array, only the ammo upgrades
    end
    if primary.weapon_id == "arbiter" and WeaponHasStandardAmmo(primary.factory_id, primary.blueprint) then
        return true
    end
    if secondary.weapon_id == "arbiter" and WeaponHasStandardAmmo(secondary.factory_id, secondary.blueprint) then
        return true
    end
    return false
end

local function HasViperGrenadesOnLauncherEquipped()
    local function HasViperAmmo(factory_id, blueprint)
        local t = managers.weapon_factory:get_ammo_data_from_weapon(factory_id, blueprint)
        if ehi_next(t) then ---@cast t -?
            return table.contains(t, "launcher_poison") or table.contains(t, "launcher_poison_ms3gl_conversion")
        end
        return false
    end
    return HasViperAmmo(primary.factory_id, primary.blueprint) or HasViperAmmo(secondary.factory_id, secondary.blueprint)
end

---@param firemode string
local function WeaponsContainFiremode(firemode)
    ---@param weapon_id string
    local function FireModeExists(weapon_id)
        local tweak_data = tweak_data.weapon[weapon_id]
        if not tweak_data then
            return false
        end
        local firemode_data = tweak_data.fire_mode_data
        if not firemode_data then
            return false
        end
        if firemode_data[firemode] then
            return true
        end
        local firemode_toggable = firemode_data.toggable
        if not firemode_toggable then
            return false
        end
        return table.contains(firemode_toggable, firemode)
    end
    return FireModeExists(primary.weapon_id) or FireModeExists(secondary.weapon_id)
end

---@param id string
---@param progress number
---@param max number
---@param dont_flash_bg boolean?
---@param show_finish_after_reaching_target boolean?
---@param status_is_overridable boolean?
---@param remove_on_alarm boolean?
function IngameWaitingForPlayersState:EHIAddAchievementTracker(id, progress, max, dont_flash_bg, show_finish_after_reaching_target, status_is_overridable, remove_on_alarm)
    managers.ehi_tracker:AddTracker({
        id = id,
        progress = progress,
        max = max,
        icons = EHI:GetAchievementIcon(id),
        flash_bg = not dont_flash_bg,
        flash_times = 1,
        show_finish_after_reaching_target = show_finish_after_reaching_target,
        status_is_overridable = status_is_overridable,
        remove_on_alarm = remove_on_alarm,
        no_failure = true,
        class = EHI.Trackers.Achievement.Progress
    })
end

local persistent_stat_unlocks = tweak_data.achievement.persistent_stat_unlocks
---@param id_stat string
---@param remove_on_alarm boolean?
---@param dont_flash_bg boolean?
---@param show_finish_after_reaching_target boolean?
---@param status_is_overridable boolean?
function IngameWaitingForPlayersState:EHIAddAchievementTrackerFromStat(id_stat, remove_on_alarm, dont_flash_bg, show_finish_after_reaching_target, status_is_overridable)
    local achievement = persistent_stat_unlocks[id_stat] or {}
    local stat = achievement[1]
    if not stat then
        EHI:Log("No statistics found for achievement with stat: " .. tostring(id_stat))
        return
    end
    if not stat.at then
        EHI:Log("No maximum is defined in statistics with stat: " .. tostring(id_stat))
        return
    end
    if not stat.award then
        EHI:Log("No achievement ID is defined in statistics with stat: " .. tostring(id_stat))
        return
    end
    stats[id_stat] = stat.award
    self:EHIAddAchievementTracker(stat.award, EHI:GetAchievementProgress(id_stat), stat.at, dont_flash_bg, show_finish_after_reaching_target, status_is_overridable, remove_on_alarm)
end

---@param id string
---@param progress number
---@param max number
---@param daily_job boolean?
---@param desc string? Custom challenge description
---@param icon string?
local function AddDailyProgressTracker(id, progress, max, daily_job, desc, icon)
    managers.ehi_tracker:AddTracker({
        id = id,
        daily_job = daily_job,
        progress = progress,
        max = max,
        icons = { icon or EHI.Icons.Trophy },
        flash_bg = true,
        flash_times = 1,
        no_failure = true,
        desc = desc,
        class = EHI.Trackers.SideJob.Progress
    })
end

---Challenges active in ChallengeManager
---@param id string
---@param desc string? Custom challenge description
---@param progress_id string?
---@param icon string?
local function AddDailyChallengeTracker(id, desc, progress_id, icon)
    local progress, max = EHI:GetDailyChallengeProgressAndMax(id, progress_id)
    AddDailyProgressTracker(id, progress, max, true, desc, icon)
end

---Challenges active in CustomSafehouseManager
---@param id string
---@param progress_id string?
---@param icon string?
local function AddDailySHChallengeTracker(id, progress_id, icon)
    local progress, max = EHI:GetSHSideJobProgressAndMax(id, progress_id)
    AddDailyProgressTracker(id, progress, max, false, nil, icon)
end

---@param f function
function IngameWaitingForPlayersState:EHIShowTrackerInLoud(f)
    if is_stealth then
        EHI:AddOnAlarmCallback(f)
    else
        f()
    end
end

---@param id string
---@param progress number
---@param max number
local function ShowPopup(id, progress, max)
    managers.hud:custom_ingame_popup_text(managers.localization:to_upper_text("achievement_" .. id), tostring(progress) .. "/" .. tostring(max), EHI:GetAchievementIconString(id))
end

local pxp1_1_checked = false
-- "Plague Doctor" achievement
---@param self IngameWaitingForPlayersState
local function pxp1_1(self)
    if pxp1_1_checked then
        return
    elseif EHI:IsAchievementLocked2("pxp1_1") then
        local grenade_data = tweak_data.achievement.grenade_achievements.pxp1_1
        local grenade_pass = table.index_of(grenade_data.grenade_types, grenade) ~= -1
        local enemy_kills_data = tweak_data.achievement.enemy_kill_achievements.pxp1_1
        local melee_pass = table.index_of(tweak_data.achievement.enemy_melee_hit_achievements.pxp1_1.melee_weapons, melee) ~= -1
        local player_style_pass = HasPlayerStyleEquipped(grenade_data.player_style.style)
        local variation_pass = HasSuitVariationEquipped(grenade_data.player_style.variation)
        if (grenade_pass or WeaponsContainBlueprint(enemy_kills_data.parts) or melee_pass or HasViperGrenadesOnLauncherEquipped()) and player_style_pass and variation_pass then
            self:EHIAddAchievementTrackerFromStat("pxp1_1_stats")
        end
    end
    pxp1_1_checked = true
end

local _f_at_exit = IngameWaitingForPlayersState.at_exit
---@param next_state GameState
function IngameWaitingForPlayersState:at_exit(next_state, ...)
    _f_at_exit(self, next_state, ...)
    if not game_state_machine:verify_game_state(GameStateFilters.any_ingame_playing, next_state:name()) then --- Don't do anything if host disconnected before spawn / closed game in Singleplayer
        challenges = nil
        sh_dailies = nil
        events = nil
        return
    end
    EHI:CallCallback(EHI.CallbackMessage.HUDVisibilityChanged, not Global.hud_disabled)
    EHI:CallCallbackOnce("Spawned")
    if EHI._cache.UnlockablesAreDisabled or GunGameGame or TIM then -- Twitch Integration Mod
        challenges = nil
        sh_dailies = nil
        events = nil
        return
    end
    primary = managers.blackmarket:equipped_primary()
    secondary = managers.blackmarket:equipped_secondary()
    melee = managers.blackmarket:equipped_melee_weapon()
    grenade = managers.blackmarket:equipped_grenade()
    is_stealth = managers.groupai:state():whisper_mode()
    local level = Global.game_settings.level_id
    local mask_id = managers.blackmarket:equipped_mask().mask_id
    local from_beginning = managers.statistics:started_session_from_beginning()
    EHI:CallCallbackOnce("Spawned2", self, managers.job:current_real_job_id(), level, from_beginning)
    if level == "safehouse" or level == "chill" then
        if EHI:GetUnlockableAndOption("show_achievements") and EHI:GetUnlockableOption("show_achievements_other") then
            if EHI:IsAchievementLocked("ovk_3") and HasWeaponEquipped("m134") and (level == "chill" or level == "safehouse") then -- "Oh, That's How You Do It" achievement
                -- Only tracked in Safehouse to prevent tracker spam in heists
                ---@class EHIovk3Tracker : EHIAchievementUnlockTracker
                ---@field super EHIAchievementUnlockTracker
                local EHIovk3Tracker = class(EHIAchievementUnlockTracker)
                EHIovk3Tracker._forced_icons = EHI:GetAchievementIcon("ovk_3")
                function EHIovk3Tracker:Reset()
                    self:SetTime(25)
                    self._fade_time = 5
                    self:StopAndSetTextColor(Color.white)
                    self.update = EHIovk3Tracker.super.update
                end
                Hooks:PostHook(RaycastWeaponBase, "start_shooting", "EHI_ovk_3_start_shooting", function(self, ...)
                    if self._shooting and self:get_name_id() == "m134" and managers.ehi_tracker:CallFunction2("ovk_3", "Reset") then
                        managers.ehi_tracker:AddTracker({
                            id = "ovk_3",
                            time = 25,
                            status_is_overridable = false,
                            class_table = EHIovk3Tracker
                        })
                    end
                end)
                Hooks:PostHook(RaycastWeaponBase, "stop_shooting", "EHI_ovk_3_stop_shooting", function(...)
                    managers.ehi_unlockable:SetAchievementFailed("ovk_3")
                end)
                Hooks:PostHook(AchievmentManager, "award", "EHI_ovk_3_award", function(am, id)
                    if id == "ovk_3" then
                        Hooks:RemovePostHook("EHI_ovk_3_start_shooting")
                        Hooks:RemovePostHook("EHI_ovk_3_stop_shooting")
                        Hooks:RemovePostHook("EHI_ovk_3_award")
                    end
                end)
            end
        end
        challenges = nil
        sh_dailies = nil
        events = nil
        return
    end
    if EHI:GetUnlockableAndOption("show_achievements") then
        if EHI:GetUnlockableOption("show_achievements_weapon") then -- Kill with weapons (primary or secondary)
            if EHI:IsAchievementLocked2("halloween_6") and mask_id == tweak_data.achievement.pump_action.mask and self:EHIHasWeaponTypeEquipped("shotgun") then -- "Pump-Action" achievement
                self:EHIAddAchievementTrackerFromStat("halloween_6_stats")
            end
            if EHI:IsAchievementLocked2("halloween_8") and HasWeaponEquipped("usp") then -- "The Pumpkin King Made Me Do It!" achievement
                self:EHIAddAchievementTrackerFromStat("halloween_8_stats")
            end
            if EHI:IsAchievementLocked2("armored_5") and HasWeaponEquipped("ppk") then -- "License to Kill" achievement
                self:EHIAddAchievementTrackerFromStat("armored_5_stat")
            end
            if EHI:IsAchievementLocked2("armored_7") and HasWeaponEquipped("s552") and mask_id == tweak_data.achievement.enemy_kill_achievements.im_not_a_crook.mask then -- "I'm Not a Crook!" achievement
                local function f()
                    self:EHIAddAchievementTrackerFromStat("armored_7_stat")
                end
                self:EHIShowTrackerInLoud(f)
                stats.armored_7_stat = "armored_7"
            end
            if EHI:IsAchievementLocked2("armored_9") and HasWeaponEquipped("m45") and mask_id == tweak_data.achievement.enemy_kill_achievements.fool_me_once.mask then -- "Fool Me Once, Shame on -Shame on You. Fool Me - You Can't Get Fooled Again" achievement
                local function f()
                    self:EHIAddAchievementTrackerFromStat("armored_9_stat")
                end
                self:EHIShowTrackerInLoud(f)
                stats.armored_9_stat = "armored_9"
            end
            if EHI:IsAchievementLocked2("gage_1") and HasWeaponEquipped("ak5") and mask_id == tweak_data.achievement.enemy_kill_achievements.wanted.mask then -- "Wanted" achievement
                self:EHIAddAchievementTrackerFromStat("gage_1_stats")
            end
            if EHI:IsAchievementLocked2("gage_2") and HasWeaponEquipped("p90") and mask_id == tweak_data.achievement.enemy_kill_achievements.three_thousand_miles.mask then -- "3000 Miles to the Safe House" achievement
                self:EHIAddAchievementTrackerFromStat("gage_2_stats")
            end
            if EHI:IsAchievementLocked2("gage_3") and HasWeaponEquipped("aug") and mask_id == tweak_data.achievement.enemy_kill_achievements.commando.mask then -- "Commando" achievement
                self:EHIAddAchievementTrackerFromStat("gage_3_stats")
            end
            if EHI:IsAchievementLocked2("gage_4") and HasWeaponEquipped("colt_1911") and mask_id == tweak_data.achievement.enemy_kill_achievements.public_enemies.mask then -- "Public Enemies" achievement
                self:EHIAddAchievementTrackerFromStat("gage_4_stats")
            end
            if EHI:IsAchievementLocked2("gage_5") and HasWeaponEquipped("scar") then -- "Inception" achievement
                self:EHIAddAchievementTrackerFromStat("gage_5_stats")
            end
            if EHI:IsAchievementLocked2("gage_6") and HasWeaponEquipped("mp7") then -- "Hard Corps" achievement
                self:EHIAddAchievementTrackerFromStat("gage_6_stats")
            end
            if EHI:IsAchievementLocked2("gage_7") and HasWeaponEquipped("p226") then -- "Above the Law" achievement
                self:EHIAddAchievementTrackerFromStat("gage_7_stats")
            end
            if EHI:IsAchievementLocked2("gage2_5") and self:EHIHasWeaponTypeEquipped("lmg") then -- "The Eighth and Final Rule" achievement
                self:EHIAddAchievementTracker("gage2_5", 0, 220)
                Hooks:PostHook(StatisticsManager, "killed", "EHI_gage2_5_killed", function(_, data)
                    if data.variant ~= "melee" and data.weapon_unit and data.weapon_unit:base().is_category and data.weapon_unit:base():is_category("lmg") and not CopDamage.is_civilian(data.name) then
                        managers.ehi_tracker:IncreaseProgress("gage2_5")
                    end
                end)
            end
            if EHI:IsAchievementLocked2("gage3_6") and self:EHIHasWeaponTypeEquipped("snp") then
                if EHI:IsAchievementLocked2("gage3_3") then -- "Lord of the Flies" achievement
                    self:EHIAddAchievementTrackerFromStat("gage3_3_stats")
                end
                if EHI:IsAchievementLocked2("gage3_4") then -- "Arachne's Curse" achievement
                    self:EHIAddAchievementTrackerFromStat("gage3_4_stats")
                end
                if EHI:IsAchievementLocked2("gage3_5") then -- "Pest Control" achievement
                    self:EHIAddAchievementTrackerFromStat("gage3_5_stats")
                end
                self:EHIAddAchievementTrackerFromStat("gage3_6_stats") -- "Seer of Death" achievement
            end
            if EHI:IsAchievementLocked2("gage3_7") and HasWeaponEquipped("m95") then -- "Far, Far Away" achievement
                self:EHIAddAchievementTrackerFromStat("gage3_7_stats")
            end
            if EHI:IsAchievementLocked2("gage3_10") and HasWeaponEquipped("r93") then -- "Maximum Penetration" achievement
                self:EHIAddAchievementTrackerFromStat("gage3_10_stats")
            end
            if EHI:IsAchievementLocked2("gage3_11") and HasWeaponEquipped("m95") then -- "Dodge This" achievement
                local function f()
                    self:EHIAddAchievementTrackerFromStat("gage3_11_stats")
                end
                self:EHIShowTrackerInLoud(f)
                stats.gage3_11_stats = "gage3_11"
            end
            if EHI:IsAchievementLocked2("gage3_12") and HasWeaponEquipped("m95") then -- "Surprise Motherfucker" achievement
                local function f()
                    self:EHIAddAchievementTrackerFromStat("gage3_12_stats")
                end
                self:EHIShowTrackerInLoud(f)
                stats.gage3_12_stats = "gage3_12"
            end
            if EHI:IsAchievementLocked2("gage3_13") and self:EHIHasWeaponTypeEquipped("snp") then -- "Didn't See That Coming Did You?" achievement
                for _, unit in ipairs(ZipLine.ziplines) do
                    if unit:zipline():is_usage_type_person() then
                        local progress = EHI:GetAchievementProgress("gage3_13_stats")
                        if gage3_13_levels[level] then
                            Hooks:PostHook(AchievmentManager, "award_progress", "EHI_gage3_13_AwardProgress", function(am, stat, value)
                                if stat == "gage3_13_stats" then
                                    progress = progress + (value or 1)
                                    if progress >= 10 then
                                        Hooks:RemovePostHook("EHI_gage3_13_AwardProgress")
                                        return
                                    end
                                    ShowPopup("gage3_13", progress, 10)
                                end
                            end)
                        else
                            self:EHIAddAchievementTracker("gage3_13", progress, 10)
                            stats.gage3_13_stats = "gage3_13"
                        end
                        break
                    end
                end
            end
            if EHI:IsAchievementLocked2("gage3_14") and HasWeaponEquipped("msr") then -- "Return to Sender" achievement
                local function f()
                    self:EHIAddAchievementTrackerFromStat("gage3_14_stats")
                end
                self:EHIShowTrackerInLoud(f)
                stats.gage3_14_stats = "gage3_14"
            end
            if EHI:IsAchievementLocked2("gage3_15") and HasWeaponEquipped("r93") then -- "You Can't Hide" achievement
                self:EHIAddAchievementTrackerFromStat("gage3_15_stats")
            end
            if EHI:IsAchievementLocked2("gage3_16") and HasWeaponEquipped("msr") then -- "Double Kill" achievement
                self:EHIAddAchievementTrackerFromStat("gage3_16_stats")
            end
            if EHI:IsAchievementLocked2("gage3_17") and HasWeaponEquipped("msr") then -- "Public Enemy No. 1" achievement
                self:EHIAddAchievementTrackerFromStat("gage3_17_stats")
            end
            if EHI:IsAchievementLocked2("gage4_6") and self:EHIHasWeaponTypeEquipped("shotgun") and WeaponsContainBlueprint("wpn_fps_upg_a_slug") then -- "Knock, Knock" achievement
                local function f()
                    self:EHIAddAchievementTrackerFromStat("gage4_6_stats")
                end
                self:EHIShowTrackerInLoud(f)
                stats.gage4_6_stats = "gage4_6"
            end
            if EHI:IsAchievementLocked2("gage4_8") and self:EHIHasWeaponTypeEquipped("shotgun") and WeaponsContainBlueprint("wpn_fps_upg_a_piercing") then -- "Clay Pigeon Shooting" achievement
                local function f()
                    self:EHIAddAchievementTrackerFromStat("gage4_8_stats")
                end
                self:EHIShowTrackerInLoud(f)
                stats.gage4_8_stats = "gage4_8"
            end
            if EHI:IsAchievementLocked2("gage4_10") and self:EHIHasWeaponTypeEquipped("shotgun") and (WeaponsContainBlueprint("wpn_fps_upg_a_custom") or WeaponsContainBlueprint("wpn_fps_upg_a_custom_free")) then -- "Bang for the Buck" achievement
                local function f()
                    self:EHIAddAchievementTrackerFromStat("gage4_10_stats")
                end
                self:EHIShowTrackerInLoud(f)
                stats.gage4_10_stats = "gage4_10"
            end
            if EHI:IsAchievementLocked2("gage5_1") and HasWeaponEquipped("g3") then -- "Precision Aiming" achievement
                local function f()
                    self:EHIAddAchievementTrackerFromStat("gage5_1_stats")
                end
                self:EHIShowTrackerInLoud(f)
                stats.gage5_1_stats = "gage5_1"
            end
            if EHI:IsAchievementLocked2("gage5_5") and HasWeaponEquipped("gre_m79") then -- "Artillery Barrage" achievement
                self:EHIAddAchievementTrackerFromStat("gage5_5_stats")
            end
            if EHI:IsAchievementLocked2("gage5_9") and HasWeaponEquipped("galil") then -- "Rabbit Hunting" achievement
                local function f()
                    self:EHIAddAchievementTrackerFromStat("gage5_9_stats")
                end
                self:EHIShowTrackerInLoud(f)
                stats.gage5_9_stats = "gage5_9"
            end
            if EHI:IsAchievementLocked2("gage5_10") and HasWeaponEquipped("famas") then -- "Tour de Clarion" achievement
                self:EHIAddAchievementTrackerFromStat("gage5_10_stats")
            end
            if EHI:IsAchievementLocked2("eagle_1") and HasWeaponEquipped("mosin") then -- "Death From Below" achievement
                local function f()
                    self:EHIAddAchievementTrackerFromStat("eagle_1_stats")
                end
                self:EHIShowTrackerInLoud(f)
                stats.eagle_1_stats = "eagle_1"
            end
            if EHI:IsAchievementLocked2("ameno_8") then -- "The Collector" achievement
                local needed_weapons = tweak_data.achievement.enemy_kill_achievements.akm4_shootout.weapons
                local primary_pass = table.index_of(needed_weapons, primary.weapon_id) ~= -1
                local secondary_pass = table.index_of(needed_weapons, secondary.weapon_id) ~= -1
                if primary_pass or secondary_pass then
                    self:EHIAddAchievementTrackerFromStat("ameno_08_stats")
                end
            end
            if EHI:IsAchievementLocked2("turtles_1") and HasWeaponEquipped("wa2000") then -- "Names Are for Friends, so I Don't Need One" achievement
                self:EHIAddAchievementTracker("turtles_1", 0, 11)
                managers.ehi_hook:HookKillFunction("turtles_1", "wa2000", true)
                Hooks:PostHook(RaycastWeaponBase, "on_reload", "EHI_RaycastWeaponBase_on_reload", function(self, amount)
                    if self:get_name_id() == "wa2000" then
                        managers.ehi_tracker:SetProgress("turtles_1", 0)
                    end
                end)
            end
            if EHI:IsAchievementLocked2("turtles_2") and HasWeaponEquipped("polymer") then -- "Swiss Cheese" achievement
                self:EHIAddAchievementTracker("turtles_2", 0, 100)
                managers.ehi_hook:HookKillFunction("turtles_2", "polymer")
            end
            if EHI:IsAchievementLocked2("tango_achieve_2") and HasWeaponEquipped("arbiter") and ArbiterHasStandardAmmo() then -- "Let Them Fly" achievement
                local function f()
                    self:EHIAddAchievementTrackerFromStat("tango_2_stats")
                end
                self:EHIShowTrackerInLoud(f)
                stats.tango_2_stats = "tango_achieve_2"
            end
            if EHI:IsAchievementLocked2("grv_2") and HasWeaponEquipped("coal") then -- "Spray Control" achievement
                self:EHIAddAchievementTracker("grv_2", 0, 32)
                managers.ehi_hook:HookKillFunction("grv_2", "coal", true)
                Hooks:PostHook(RaycastWeaponBase, "on_reload", "EHI_RaycastWeaponBase_on_reload", function(self, amount)
                    if self:get_name_id() == "coal" then
                        managers.ehi_tracker:SetProgress("grv_2", 0)
                    end
                end)
            end
            if EHI:IsAchievementLocked2("grv_3") then -- "Have Nice Day!" achievement
                local weapons_required = tweak_data.achievement.enemy_kill_achievements.grv_3.weapons
                local pass = table.index_of(weapons_required, primary.weapon_id) ~= -1
                local pass2 = table.index_of(weapons_required, secondary.weapon_id) ~= -1
                if pass or pass2 then
                    self:EHIAddAchievementTrackerFromStat("grv_3_stats")
                end
            end
            if EHI:IsAchievementLocked2("cac_2") and WeaponsContainBlueprint("wpn_fps_upg_bp_lmg_lionbipod") then -- "Human Sentry Gun" achievement
                self:EHIShowTrackerInLoud(function()
                    local enemy_killed_key = "EHI_cac_2_enemy_killed"
                    self:EHIAddAchievementTracker("cac_2", 0, 20)
                    local function on_enemy_killed(...)
                        managers.ehi_tracker:IncreaseProgress("cac_2")
                    end
                    managers.player:register_message("player_state_changed", "EHI_cac_2_state_changed_key", function(state_name)
                        managers.ehi_tracker:SetProgress("cac_2", 0)
                        if state_name == "bipod" then
                            managers.player:register_message(Message.OnEnemyKilled, enemy_killed_key, on_enemy_killed)
                        else
                            managers.player:unregister_message(Message.OnEnemyKilled, enemy_killed_key)
                        end
                    end)
                end)
            end
            if EHI:IsAchievementLocked2("pxp2_1") and HasWeaponEquipped("hailstorm") and WeaponsContainFiremode("volley") then -- "Field Test" achievement
                self:EHIAddAchievementTrackerFromStat("pxp2_1_stats")
            end
            if EHI:IsAchievementLocked2("pxp2_2") and (HasWeaponEquipped("sko12") or HasWeaponEquipped("x_sko12")) then -- "Heister With A Shotgun" achievement
                self:EHIAddAchievementTrackerFromStat("pxp2_2_stats")
            end
            if VeryHardOrAbove then
                if EHI:IsAchievementLocked2("tango_achieve_3") and not self:check_is_dropin() then -- "The Reckoning" achievement
                    local primary_index, secondary_index = CheckWeaponsBlueprint(tweak_data.achievement.complete_heist_achievements.tango_3.killed_by_blueprint.blueprint)
                    if primary_index and secondary_index then
                        ---@class EHItango_achieve_3Tracker : EHIAchievementProgressTracker
                        ---@field super EHIAchievementProgressTracker
                        local EHItango_achieve_3Tracker = class(EHIAchievementProgressTracker)
                        EHItango_achieve_3Tracker._forced_icons = EHI:GetAchievementIcon("tango_achieve_3")
                        function EHItango_achieve_3Tracker:pre_init(...)
                            self._kills =
                            {
                                primary = 0,
                                secondary = 0
                            }
                            self._weapon_id = 0
                            EHItango_achieve_3Tracker.super.pre_init(self, ...)
                        end
                        ---@param id number
                        function EHItango_achieve_3Tracker:WeaponSwitched(id)
                            if self._weapon_id == id then
                                return
                            end
                            local previous_weapon_id = self._weapon_id
                            self._weapon_id = id
                            local current_selection = id == 0 and "secondary" or "primary"
                            local previous_selection = previous_weapon_id == 0 and "secondary" or "primary"
                            self._kills[previous_selection] = self._progress
                            self._progress = self._kills[current_selection]
                            self:SetAndFitTheText()
                            self:AnimateBG(1)
                        end
                        function EHItango_achieve_3Tracker:SetCompleted(...)
                            EHItango_achieve_3Tracker.super.SetCompleted(self, ...)
                            if self._status == "completed" then
                                managers.player:unregister_message(Message.OnSwitchWeapon, "EHI_tango_achieve_3")
                            end
                        end
                        managers.ehi_tracker:AddTracker({
                            id = "tango_achieve_3",
                            progress = 0,
                            max = 200,
                            flash_times = 1,
                            show_finish_after_reaching_target = true,
                            class_table = EHItango_achieve_3Tracker
                        })
                        managers.ehi_hook:HookKillFunction("tango_achieve_3", primary.weapon_id, true)
                        managers.ehi_hook:HookKillFunction("tango_achieve_3", secondary.weapon_id, true)
                        managers.player:register_message(Message.OnSwitchWeapon, "EHI_tango_achieve_3", function()
                            local player = managers.player:local_player()
                            if not player then
                                return
                            end
                            local weapon = player:inventory():equipped_unit():base():selection_index()
                            if weapon and (weapon == 1 or weapon == 2) then
                                managers.ehi_tracker:CallFunction("tango_achieve_3", "WeaponSwitched", weapon - 1)
                            end
                        end)
                    elseif primary_index or secondary_index then
                        self:EHIAddAchievementTracker("tango_achieve_3", 0, 200)
                        managers.ehi_hook:HookKillFunction("tango_achieve_3", primary_index and primary.weapon_id or secondary.weapon_id, true)
                    end
                end
            end
            if OVKOrAbove then
                if EHI:IsAchievementLocked2("pim_1") and self:EHIHasWeaponTypeEquipped("snp") then -- "Nothing Personal" achievement
                    local function f()
                        self:EHIAddAchievementTrackerFromStat("pim_1_stats")
                    end
                    self:EHIShowTrackerInLoud(f)
                    stats.pim_1_stats = "pim_1"
                end
                pxp1_1(self)
            end
            if EHI:IsDifficultyOrAbove(EHI.Difficulties.Mayhem) and EHI:IsAchievementLocked2("gage3_2") and HasWeaponEquipped("akm_gold") then -- "The Man With the Golden Gun" achievement
                local function f()
                    self:EHIAddAchievementTrackerFromStat("gage3_2_stats")
                end
                self:EHIShowTrackerInLoud(f)
                stats.gage3_2_stats = "gage3_2"
            end
        end
        if EHI:GetUnlockableOption("show_achievements_melee") then -- Kill with melee
            if EHI:IsAchievementLocked2("halloween_7") and mask_id == tweak_data.achievement.cant_hear_you_scream.mask and is_stealth then -- "No One Can Hear You Scream" achievement
                self:EHIAddAchievementTrackerFromStat("halloween_7_stats", true)
            end
            if EHI:IsAchievementLocked2("gage5_8") and self:EHIHasMeleeEquipped("dingdong") then -- "Hammertime" achievement
                self:EHIAddAchievementTrackerFromStat("gage5_8_stats")
            end
            if EHI:IsAchievementLocked2("eagle_2") and self:EHIHasMeleeEquipped("fairbair") and is_stealth then -- "Special Operations Execution" achievement
                self:EHIAddAchievementTrackerFromStat("eagle_2_stats", true)
            end
            if EHI:IsAchievementLocked2("steel_2") then -- "Their Armor Is Thick and Their Shields Broad" achievement
                local melee_required = tweak_data.achievement.enemy_melee_hit_achievements.steel_2.melee_weapons
                local pass = table.index_of(melee_required, melee) ~= -1
                if pass then
                    self:EHIAddAchievementTracker("steel_2", 0, 10)
                    Hooks:PostHook(StatisticsManager, "killed", "EHI_steel_2_killed", function(_, data)
                        if data.variant == "melee" and data.name == "shield" then
                            managers.ehi_tracker:IncreaseProgress("steel_2")
                        end
                    end)
                end
            end
            if EHI:IsAchievementLocked2("gsu_01") and self:EHIHasMeleeEquipped("spoon") then -- "For all you legends" achievement
                self:EHIAddAchievementTrackerFromStat("gsu_stat")
            end
            if OVKOrAbove then
                if EHI:IsAchievementLocked2("gage2_9") and HasMeleeTypeEquipped("knife") then -- "I Ain't Got Time to Bleed" achievement
                    local function f()
                        self:EHIAddAchievementTrackerFromStat("gage2_9_stats")
                    end
                    self:EHIShowTrackerInLoud(f)
                    stats.gage2_9_stats = "gage2_9"
                end
                if EHI:IsAchievementLocked2("sawp_1") then -- "Buzzbomb" achievement
                    local achievement_data = tweak_data.achievement.enemy_melee_hit_achievements.sawp_1
                    local melee_pass = table.index_of(achievement_data.melee_weapons, melee) ~= -1
                    local player_style_pass = HasPlayerStyleEquipped(achievement_data.player_style.style)
                    local variation_pass = HasSuitVariationEquipped(achievement_data.player_style.variation)
                    if melee_pass and player_style_pass and variation_pass then
                        self:EHIAddAchievementTrackerFromStat("sawp_stat")
                    end
                end
                pxp1_1(self)
            end
        end
        if EHI:GetUnlockableOption("show_achievements_grenade") then -- Kill with grenades
            if EHI:IsAchievementLocked2("gage_9") then -- "Fire in the Hole!" achievement
                for _, eligible_grenade in ipairs(tweak_data.achievement.fire_in_the_hole.grenade) do
                    if grenade == eligible_grenade then
                        local progress = EHI:GetAchievementProgress("gage_9_stats")
                        managers.ehi_hook:HookAchievementAwardProgress("gage_9", function(am, stat, value)
                            if stat == "gage_9_stats" then
                                progress = progress + (value or 1)
                                if progress >= 100 then
                                    Hooks:RemovePostHook("EHI_gage_9_AchievementManager_award_progress")
                                    return
                                end
                                ShowPopup("gage_9", progress, 100)
                            end
                        end)
                        break
                    end
                end
            end
            if EHI:IsAchievementLocked2("dec21_02") and HasNonExplosiveGrenadeEquipped() then -- "Gift Giver" achievement
                self:EHIAddAchievementTrackerFromStat("dec21_02_stat")
            end
            if OVKOrAbove then
                pxp1_1(self)
                if EHI:IsAchievementLocked2("pxp2_3") and HasGrenadeEquipped("poison_gas_grenade") then -- "Snake Charmer" achievement
                    self:EHIAddAchievementTrackerFromStat("pxp2_3_stats")
                end
            end
        end
        if EHI:GetUnlockableOption("show_achievements_other") then
            if EHI:IsAchievementLocked2("halloween_4") and mask_id == tweak_data.achievement.witch_doctor.mask then -- "Witch Doctor" achievement
                self:EHIAddAchievementTrackerFromStat("halloween_4_stats")
            end
            if EHI:IsAchievementLocked2("halloween_5") and mask_id == tweak_data.achievement.its_alive_its_alive.mask then -- "It's Alive! IT'S ALIVE!" achievement
                local function f()
                    self:EHIAddAchievementTrackerFromStat("halloween_5_stats")
                end
                self:EHIShowTrackerInLoud(f)
                stats.halloween_5_stats = "halloween_5"
            end
            if EHI:IsAchievementLocked2("armored_8") and mask_id == tweak_data.achievement.relation_with_bulldozer.mask then -- "I Did Not Have Sexual Relations With That Bulldozer" achievement
                local function f()
                    self:EHIAddAchievementTrackerFromStat("armored_8_stat")
                end
                self:EHIShowTrackerInLoud(f)
                stats.armored_8_stat = "armored_8"
            end
            if EHI:IsAchievementLocked2("armored_10") and mask_id == tweak_data.achievement.no_we_cant.mask then -- "Affordable Healthcare" achievement
                local progress = EHI:GetAchievementProgress("armored_10_stat")
                managers.ehi_hook:HookAchievementAwardProgress("armored_10", function(am, stat, value)
                    if stat == "armored_10_stat" and progress < 61 then
                        progress = progress + (value or 1)
                        ShowPopup("armored_10", progress, 61)
                    end
                end)
            end
            if EHI:IsAchievementLocked2("gmod_1") then -- "Praying Mantis" achievement
                local progress = EHI:GetAchievementProgress("gmod_1_stats")
                managers.ehi_hook:HookAchievementAwardProgress("gmod_1", function(am, stat, value)
                    if stat == "gmod_1_stats" then
                        progress = progress + value
                        if progress < 5 then
                            ShowPopup("gmod_1", progress, 5)
                        end
                    end
                end)
            end
            if EHI:IsAchievementLocked2("gmod_2") then -- "Bullseye" achievement
                local progress = EHI:GetAchievementProgress("gmod_2_stats")
                managers.ehi_hook:HookAchievementAwardProgress("gmod_2", function(am, stat, value)
                    if stat == "gmod_2_stats" then
                        progress = progress + value
                        if progress < 10 then
                            ShowPopup("gmod_2", progress, 10)
                        end
                    end
                end)
            end
            if EHI:IsAchievementLocked2("gmod_3") then -- "My Spider Sense is Tingling" achievement
                local progress = EHI:GetAchievementProgress("gmod_3_stats")
                managers.ehi_hook:HookAchievementAwardProgress("gmod_3", function(am, stat, value)
                    if stat == "gmod_3_stats" then
                        progress = progress + value
                        if progress < 15 then
                            ShowPopup("gmod_3", progress, 15)
                        end
                    end
                end)
            end
            if EHI:IsAchievementLocked2("gmod_4") then -- "Eagle Eyes" achievement
                local progress = EHI:GetAchievementProgress("gmod_4_stats")
                managers.ehi_hook:HookAchievementAwardProgress("gmod_4", function(am, stat, value)
                    if stat == "gmod_4_stats" then
                        progress = progress + value
                        if progress < 20 then
                            ShowPopup("gmod_4", progress, 20)
                        end
                    end
                end)
            end
            if EHI:IsAchievementLocked2("gmod_5") then -- "Like A Boy Killing Snakes" achievement
                local progress = EHI:GetAchievementProgress("gmod_5_stats")
                managers.ehi_hook:HookAchievementAwardProgress("gmod_5", function(am, stat, value)
                    if stat == "gmod_5_stats" then
                        progress = progress + value
                        if progress < 25 then
                            ShowPopup("gmod_5", progress, 25)
                        end
                    end
                end)
            end
            if EHI:IsAchievementLocked2("gmod_6") then -- "There and Back Again" achievement
                Hooks:PostHook(GageAssignmentManager, "_give_rewards", "EHI_gmod_6_achievement", function(gam, assignment, ...)
                    local progress = 0
                    for _, dvalue in pairs(gam._global.completed_assignments) do
                        if Application:digest_value(dvalue, false) >= tweak_data.achievement.gonna_find_them_all then
                            progress = progress + 1
                        end
                    end
                    if progress < 5 then
                        ShowPopup("gmod_6", progress, 5)
                    end
                end)
            end
            if EHI:IsAchievementLocked2("cac_3") then -- "Denied" achievement
                local progress = EHI:GetAchievementProgress("cac_3_stats")
                managers.ehi_hook:HookAchievementAwardProgress("cac_3", function(am, stat, value)
                    if stat == "cac_3_stats" then
                        progress = progress + (value or 1)
                        if progress < 30 then
                            ShowPopup("cac_3", progress, 30)
                        end
                    end
                end)
            end
            if EHI:IsAchievementLocked2("cac_34") then -- "Lieutenant Colonel" achievement
                local progress = EHI:GetAchievementProgress("cac_34_stats")
                managers.ehi_hook:HookAchievementAwardProgress("cac_34", function(am, stat, value)
                    if stat == "cac_34_stats" then
                        progress = progress + (value or 1)
                        if progress < 300 then
                            ShowPopup("cac_34", progress, 300)
                        end
                    end
                end)
            end
            if OVKOrAbove then
                if EHI:IsAchievementLocked2("halloween_10") and managers.job:current_contact_id() == "vlad" and mask_id == tweak_data.achievement.complete_heist_achievements.in_soviet_russia.mask and from_beginning then -- From Russia With Love
                    local progress = EHI:GetAchievementProgress("halloween_10_stats")
                    EHI:AddCallback(EHI.CallbackMessage.MissionEnd, function(success)
                        if success and progress < 25 and managers.job:on_last_stage() then
                            ShowPopup("halloween_10", progress + 1, 25)
                        end
                    end)
                end
            end
        end
    end
    if EHI:GetUnlockableAndOption("show_dailies") then
        local active_sh_daily
        local current_daily = managers.custom_safehouse:get_daily_challenge()
        if current_daily and not (current_daily.state == "completed" or current_daily.state == "rewarded") then
            active_sh_daily = current_daily.id
        end
        local sh_daily = active_sh_daily and sh_dailies and sh_dailies[active_sh_daily]
        if sh_daily and managers.custom_safehouse:can_progress_trophies(active_sh_daily) then
            local all_pass = true
            if sh_daily.check then
                if sh_daily.check.melee and not self:EHIHasMeleeEquipped(sh_daily.check.melee) then
                    all_pass = false
                elseif sh_daily.check.grenades and not table.contains(sh_daily.check.grenades, grenade) then
                    all_pass = false
                end
            end
            if all_pass then
                local icon = sh_daily.achievement_icon and EHI:GetAchievementIconString(sh_daily.achievement_icon) or sh_daily.icon
                if sh_daily.track then
                    AddDailySHChallengeTracker(active_sh_daily, nil, icon)
                    Hooks:PostHook(CustomSafehouseManager, "award", string.format("EHI_%s_AwardProgress", active_sh_daily), function(csm, id)
                        if id == active_sh_daily then
                            managers.ehi_tracker:IncreaseProgress(active_sh_daily)
                        end
                    end)
                elseif sh_daily.hook_secured then
                    local data
                    if sh_daily.first_entry then
                        data = tweak_data.achievement.loot_cash_achievements[active_sh_daily].secured[1]
                    else
                        data = tweak_data.achievement.loot_cash_achievements[active_sh_daily].secured
                    end
                    managers.ehi_hook:HookSecuredBag(active_sh_daily, data, icon or "milestone_trophy")
                elseif sh_daily.hook_end then
                    managers.ehi_hook:HookMissionEndCSMAward(active_sh_daily, icon)
                end
            end
        end
        if managers.challenge:can_progress_challenges() and challenges then
            for _, challenge in pairs(managers.challenge:get_all_active_challenges()) do
                local c = challenges[challenge.id or ""]
                if c and not challenge.completed and (not c.check or (c.check.weapon_type and self:EHIHasWeaponTypeEquipped(c.check.weapon_type)) or (c.check.enemy_check and tweak_data.group_ai:IsSpecialEnemyAllowedToSpawn(c.check.enemy_check))) then
                    if c.icon then
                        local icon = tweak_data.hud_icons[c.icon] or tweak_data.ehi.icons[c.icon]
                        tweak_data.ehi.icons[challenge.id] = icon
                        tweak_data.hud_icons[challenge.id] = icon
                    end
                    if c.check_on_completion then
                        if not c.contact or managers.job:current_contact_id() == c.contact then
                            EHI:AddCallback(EHI.CallbackMessage.MissionEnd, function(success) ---@param success boolean
                                if success and managers.job:on_last_stage() and from_beginning then
                                    local progress, max = EHI:GetDailyChallengeProgressAndMax(challenge.id, c.progress_id)
                                    local new_progress = progress + 1
                                    if new_progress < max then
                                        managers.hud:custom_ingame_popup_text(managers.localization:to_upper_text("menu_challenge_" .. challenge.id), tostring(new_progress) .. "/" .. tostring(max), c.icon)
                                    end
                                end
                            end)
                        end
                    elseif c.loud_only then
                        self:EHIShowTrackerInLoud(function()
                            AddDailyChallengeTracker(challenge.id, c.desc, c.progress_id, c.icon)
                        end)
                    else
                        AddDailyChallengeTracker(challenge.id, c.desc, c.progress_id, c.icon)
                    end
                    if not c.do_not_track then
                        managers.ehi_hook:HookChallengeAwardProgress(challenge.id, function(am, stat, value)
                            if stat == c.progress_id then
                                managers.ehi_tracker:IncreaseProgress(challenge.id, value)
                            end
                        end)
                    end
                end
            end
        end
    end
    if EHI:GetUnlockableAndOption("show_events") and managers.event_jobs:can_progress() and events then
        for id, data in pairs(events) do
            local c = managers.event_jobs:get_challenge(id)
            if c and not c.completed then
                local objective, first_objective, second_objective = data.objective, false, false
                if objective[1].check then
                    first_objective = HasGrenadeEquipped(objective[1].check.grenade) and managers.mutators:is_mutator_active(managers.mutators:get_mutator_from_id(objective[1].check.mutator))
                else
                    first_objective = true
                end
                if objective[2].check then
                    second_objective = self:EHIHasWeaponTypeEquipped(objective[2].check.weapon_type)
                else
                    second_objective = true
                end
                if first_objective and second_objective then
                    local o1, o2 = objective[1], objective[2]
                    local p1, m1 = EHI:GetEventMissionProgressAndMax(c, o1.stat)
                    local p2, m2 = EHI:GetEventMissionProgressAndMax(c, o2.stat)
                    managers.ehi_unlockable:AddEventTrackerWithBothObjectives(id, m1, p1, o1.stat, m2, p2, o2.stat)
                    managers.ehi_hook:HookAchievementAwardProgress(o1.stat, function(am, stat, value)
                        if stat == o1.stat or stat == o2.stat then
                            managers.ehi_tracker:IncreaseGroupProgress(id, stat, value)
                        end
                    end)
                elseif first_objective or second_objective then
                    local objective_to_track = first_objective and objective[1] or objective[2]
                    local progress, max = EHI:GetEventMissionProgressAndMax(c, objective_to_track.stat)
                    managers.ehi_unlockable:AddEventProgressTracker(id, objective_to_track.stat, max, progress)
                    managers.ehi_hook:HookAchievementAwardProgress(id, function(am, stat, value)
                        if stat == objective_to_track.stat then
                            managers.ehi_tracker:IncreaseProgress(id, value)
                        end
                    end)
                end
            end
        end
    end
    challenges = nil
    sh_dailies = nil
    events = nil
    for stat_id, id in pairs(stats) do
        managers.ehi_hook:HookAchievementAwardProgress(id, function(am, stat, value)
            if stat == stat_id then
                managers.ehi_tracker:IncreaseProgress(id, value)
            end
        end)
    end
end