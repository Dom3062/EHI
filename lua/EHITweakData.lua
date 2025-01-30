---@class EHITweakData
EHITweakData = {}
---@param tweak_data tweak_data
function EHITweakData:new(tweak_data)
    local EHI = EHI
    local Icon = EHI.Icons
    self.default =
    {
        tracker =
        {
            size_h = 32,
            size_w = 64,
            offset = 6,
            gap = 5
        },
        buff =
        {
            size_h = 64,
            size_w = 32,
            gap = 6
        }
    }
    self.colors =
    {
        WaterColor = Color("D4F1F9"),
        CarBlue = Color("1E90FF")
    }
    self.icons =
    {
        default = { texture = "guis/textures/pd2/pd2_waypoints", texture_rect = {96, 64, 32, 32} },

        faster = { texture = "guis/textures/pd2/skilltree/drillgui_icon_faster" },
        silent = { texture = "guis/textures/pd2/skilltree/drillgui_icon_silent" },
        restarter = { texture = "guis/textures/pd2/skilltree/drillgui_icon_restarter" },

        xp = { texture = "guis/textures/pd2/blackmarket/xp_drop" },

        mad_scan = { texture = "guis/textures/pd2_mod_ehi/icons_atlas", texture_rect = {0, 0, 85, 85} },
        boat = { texture = "guis/textures/pd2_mod_ehi/icons_atlas", texture_rect = {0, 85, 85, 85} },
        enemy = { texture = "guis/textures/pd2_mod_ehi/icons_atlas", texture_rect = {213, 85, 64, 64} },
        piggy = { texture = "guis/textures/pd2_mod_ehi/icons_atlas", texture_rect = {85, 0, 85, 85} },
        assaultbox = { texture = "guis/textures/pd2_mod_ehi/icons_atlas", texture_rect = {96, 213, 32, 32} },
        deployables = { texture = "guis/textures/pd2_mod_ehi/icons_atlas", texture_rect = {85, 85, 128, 128} },
        padlock = { texture = "guis/textures/pd2_mod_ehi/icons_atlas", texture_rect = {64, 213, 32, 32} },
        turret = { texture = "guis/textures/pd2_mod_ehi/icons_atlas", texture_rect = {170, 0, 85, 85} },

        reload = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {0, 576, 64, 64} },
        smoke = { texture = "guis/dlcs/max/textures/pd2/specialization/icons_atlas", texture_rect = {0, 0, 64, 64} },
        teargas = { texture = "guis/dlcs/drm/textures/pd2/crime_spree/modifiers_atlas_2", texture_rect = {128, 256, 128, 128} },
        gage = { texture = "guis/dlcs/gage_pack_jobs/textures/pd2/endscreen/gage_assignment" },
        hostage = { texture = "guis/textures/pd2/hud_icon_hostage" },
        civilians = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {384, 448, 64, 64} },
        buff_shield = { texture = "guis/textures/pd2/hud_buff_shield" },

        doctor_bag = { texture = "guis/textures/pd2/blackmarket/icons/deployables/outline/doctor_bag" },
        ammo_bag = { texture = "guis/textures/pd2/blackmarket/icons/deployables/outline/ammo_bag" },
        first_aid_kit = { texture = "guis/textures/pd2/blackmarket/icons/deployables/outline/first_aid_kit" },
        bodybags_bag = { texture = "guis/textures/pd2/blackmarket/icons/deployables/outline/bodybags_bag" },

        minion = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {384, 512, 64, 64} },
        heavy = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {192, 64, 64, 64} },
        sniper = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {384, 320, 64, 64} },
        camera_loop = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {256, 128, 64, 64} },
        pager_icon = tweak_data.hud_icons.crime_spree_civs_killed,

        ecm_jammer = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {64, 256, 64, 64} },
        ecm_feedback = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {384, 128, 64, 64} },

        hoxton_character = { texture = "guis/dlcs/trk/textures/pd2/old_hoxton_unlock_icon" }
    }
    -- Broken units to be "fixed" during mission load
    self.units =
    {
        -- Doctor Bags
        ["units/payday2/props/stn_prop_medic_firstaid_box/stn_prop_medic_firstaid_box"] = { f = "SetDeployableOffset" }, -- CustomDoctorBagBase / cabinet 1
        ["units/pd2_dlc_casino/props/cas_prop_medic_firstaid_box/cas_prop_medic_firstaid_box"] = { f = "SetDeployableOffset" }, -- CustomDoctorBagBase / cabinet 2
        -- Ammo
        ["units/payday2/props/stn_prop_armory_shelf_ammo/stn_prop_armory_shelf_ammo"] = { f = "SetDeployableOffset" },
        ["units/pd2_dlc_spa/props/spa_prop_armory_shelf_ammo/spa_prop_armory_shelf_ammo"] = { f = "SetDeployableOffset" },
        ["units/pd2_dlc_hvh/props/hvh_prop_armory_shelf_ammo/hvh_prop_armory_shelf_ammo"] = { f = "SetDeployableOffset" },

        ["units/pd2_dlc_chas/equipment/chas_interactable_c4/chas_interactable_c4"] = { icons = { Icon.C4 }, warning = true, hint = EHI.Hints.Explosion },
        ["units/pd2_dlc_chas/equipment/chas_interactable_c4_placeable/chas_interactable_c4_placeable"] = { icons = { Icon.C4 }, f = "chasC4" },
        ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_01"] = { ignore_visibility = true },
        ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_02"] = { ignore_visibility = true },
        ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_03"] = { ignore_visibility = true },

        ["units/world/props/suburbia_hackbox/suburbia_hackbox"] = { icons = { Icon.Tablet } },
        ["units/pd2_dlc_dah/props/dah_prop_hack_box/dah_prop_hack_ipad_unit"] = { icons = { Icon.Tablet } },
        ["units/pd2_dlc_sah/props/sah_interactable_hackbox/sah_interactable_hackbox"] = { icons = { Icon.Tablet } },
        ["units/pd2_dlc_vit/props/vit_prop_hacking_device/vit_prop_hacking_device"] = { icons = { Icon.Tablet } },
        ["units/pd2_dlc_pent/props/pent_prop_hacking_device/pent_prop_hacking_device"] = { icons = { Icon.Tablet } },
        ["units/pd2_dlc_trai/props/trai_int_prop_hacking_device/trai_int_prop_hacking_device"] = { icons = { Icon.Tablet } }
    }
    -- Definitions for buffs and their icons
    self.buff =
    {
        Health =
        {
            deck = true,
            folder = "chico",
            text = "0",
            x = 1,
            y = 0,
            class = "EHIGaugeBuffTracker",
            format = "damage",
            option = "health"
        },
        Armor =
        {
            u100skill = true,
            x = 2,
            y = 12,
            class = "EHIGaugeBuffTracker",
            format = "damage",
            option = "armor"
        },
        DodgeChance =
        {
            u100skill = true,
            x = 1,
            y = 12,
            text = "Dodge",
            format = "percent",
            activate_after_spawn = true,
            option = "dodge",
            persistent = "dodge_persistent",
            class_to_load =
            {
                prerequisite = "EHISkillRefreshBuffTracker",
                class = "EHIDodgeChanceBuffTracker"
            },
            enable_in_loud = true
        },
        CritChance =
        {
            u100skill = true,
            x = 0,
            y = 12,
            text = "Crit",
            format = "percent",
            activate_after_spawn = true,
            option = "crit",
            persistent = "crit_persistent",
            class_to_load =
            {
                prerequisite = "EHISkillRefreshBuffTracker",
                class = "EHICritChanceBuffTracker"
            },
            enable_in_loud = true
        },
        Berserker =
        {
            skills = true,
            x = 2,
            y = 2,
            check_after_spawn = true,
            option = "berserker",
            persistent = "berserker_persistent",
            class_to_load =
            {
                prerequisite = "EHISkillRefreshBuffTracker",
                class = "EHIBerserkerBuffTracker"
            }
        },
        Reload =
        {
            skills = true,
            bad = true,
            y = 9,
            option = "reload"
        },
        Interact =
        {
            texture = "guis/textures/pd2/pd2_waypoints",
            texture_rect = { 224, 32, 32, 32 },
            option = "interact"
        },
        ArmorRegenDelay =
        {
            skills = true,
            bad = true,
            x = 6,
            y = 4,
            option = "shield_regen"
        },
        MeleeCharge =
        {
            skills = true,
            x = 4,
            y = 12,
            option = "melee_charge",
            class_to_load =
            {
                load_class = "EHIMeleeChargeBuffTracker",
                class = "EHIMeleeChargeBuffTracker"
            }
        },
        headshot_regen_armor_bonus =
        {
            skills = true,
            bad = true,
            x = 6,
            y = 11,
            option = "bullseye"
        },
        combat_medic_damage_multiplier =
        {
            skills = true,
            x = 5,
            y = 7,
            option = "combat_medic"
        },
        berserker_damage_multiplier =
        {
            skills = true,
            x = 5,
            y = 12,
            option = "swan_song"
        },
        dmg_multiplier_outnumbered =
        {
            skills = true,
            text = "Dmg+",
            x = 2,
            y = 1,
            option = "underdog"
        },
        first_aid_damage_reduction =
        {
            skills = true,
            text = "Dmg-",
            x = 1,
            y = 11,
            option = "quick_fix"
        },
        UppersRangeGauge =
        {
            u100skill = true,
            x = 2,
            y = 11,
            check_after_spawn = true,
            option = "uppers_range",
            class_to_load =
            {
                prerequisite = "EHISkillRefreshBuffTracker",
                class = "EHIUppersRangeBuffTracker"
            }
        },
        fast_learner =
        {
            u100skill = true,
            text = "Dmg-",
            y = 10,
            option = "painkillers"
        },
        melee_life_leech =
        {
            deck = true,
            bad = true,
            x = 7,
            y = 4,
            deck_option =
            {
                deck = "infiltrator",
                option = "melee_cooldown"
            }
        },
        dmg_dampener_close_contact =
        {
            deck = true,
            x = 5,
            y = 4,
            option = "underdog"
        },
        loose_ammo_give_team =
        {
            deck = true,
            bad = true,
            x = 5,
            y = 5,
            deck_option =
            {
                deck = "gambler",
                option = "ammo_give_out_cooldown"
            }
        },
        loose_ammo_restore_health =
        {
            deck = true,
            bad = true,
            x = 4,
            y = 5,
            deck_option =
            {
                deck = "gambler",
                option = "regain_health_cooldown"
            }
        },
        damage_speed_multiplier =
        {
            u100skill = true,
            text = "Mov+",
            x = 10,
            y = 9,
            option = "second_wind"
        },
        trigger_happy =
        {
            u100skill = true,
            text = "Dmg+",
            x = 11,
            y = 2,
            option = "trigger_happy"
        },
        desperado =
        {
            u100skill = true,
            text = "Acc+",
            x = 11,
            y = 1,
            option = "desperado"
        },
        revived_damage_resist =
        {
            u100skill = true,
            text = "Dmg-",
            x = 11,
            y = 4,
            option = "up_you_go"
        },
        swap_weapon_faster =
        {
            u100skill = true,
            text = "Spd+",
            x = 11,
            y = 3,
            option = "running_from_death_reload"
        },
        increased_movement_speed =
        {
            u100skill = true,
            text = "Mov+",
            x = 11,
            y = 3,
            option = "running_from_death_movement"
        },
        unseen_strike =
        {
            u100skill = true,
            text = "Crit+",
            x = 10,
            y = 11,
            option = "unseen_strike",
        },
        unseen_strike_initial =
        {
            u100skill = true,
            bad = true,
            x = 10,
            y = 11,
            option = "unseen_strike_initial",
        },
        melee_damage_stacking =
        {
            u100skill = true,
            x = 11,
            y = 6,
            format = "multiplier",
            class = "EHIGaugeBuffTracker",
            option = "bloodthirst"
        },
        melee_kill_increase_reload_speed =
        {
            u100skill = true,
            x = 11,
            y = 6,
            text = "Rld+",
            option = "bloodthirst_reload"
        },
        standstill_omniscience_initial =
        {
            skills = true,
            bad = true,
            x = 6,
            y = 10
        },
        standstill_omniscience =
        {
            skills = true,
            bad = true,
            x = 6,
            y = 10
        },
        standstill_omniscience_highlighted =
        {
            skills = true,
            x = 6,
            y = 10,
            class = "EHIGaugeBuffTracker"
        },
        bullet_storm =
        {
            u100skill = true,
            x = 4,
            y = 5,
            option = "bulletstorm"
        },
        hostage_absorption =
        {
            u100skill = true,
            x = 4,
            y = 7,
            class = "EHIGaugeBuffTracker"
        },
        ManiacStackTicks =
        {
            deck = true,
            folder = "coco",
            deck_option =
            {
                deck = "maniac",
                option = "stack_convert_rate"
            }
        },
        ManiacDecayTicks =
        {
            deck = true,
            folder = "coco",
            x = 2,
            deck_option =
            {
                deck = "maniac",
                option = "stack_decay"
            }
        },
        ManiacAccumulatedStacks =
        {
            deck = true,
            folder = "coco",
            x = 3,
            format = "percent",
            check_after_spawn = true,
            deck_option =
            {
                deck = "maniac",
                option = "stack",
                persistent = "stack_persistent"
            },
            class = "EHIManiacBuffTracker"
        },
        GrinderStackCooldown =
        {
            deck = true,
            bad = true,
            x = 5,
            y = 6,
            deck_option =
            {
                deck = "grinder",
                option = "stack_cooldown"
            }
        },
        GrinderRegenPeriod =
        {
            deck = true,
            x = 5,
            y = 6,
            deck_option =
            {
                deck = "grinder",
                option = "regen_duration"
            }
        },
        SicarioTwitchGauge =
        {
            deck = true,
            folder = "max",
            x = 1,
            class = "EHIGaugeBuffTracker",
            format = "percent",
            deck_option =
            {
                deck = "sicario",
                option = "twitch"
            }
        },
        SicarioTwitchCooldown =
        {
            deck = true,
            folder = "max",
            bad = true,
            x = 1,
            deck_option =
            {
                deck = "sicario",
                option = "twitch_cooldown"
            }
        },
        ammo_efficiency =
        {
            u100skill = true,
            x = 8,
            y = 4,
            option = "ammo_efficiency"
        },
        armor_break_invulnerable =
        {
            deck = true,
            bad = true,
            x = 6,
            y = 1,
            deck_option =
            {
                deck = "anarchist",
                option = "immunity_cooldown"
            }
        },
        damage_to_armor =
        {
            deck = true,
            bad = true,
            folder = "opera",
            y = 1,
            deck_option =
            {
                deck = "anarchist",
                option = "kill_armor_regen_cooldown"
            }
        },
        single_shot_fast_reload =
        {
            u100skill = true,
            text = "Rld+",
            x = 8,
            y = 3,
            option = "aggressive_reload"
        },
        overkill_damage_multiplier =
        {
            skills = true,
            text = "Dmg+",
            x = 3,
            y = 2,
            option = "overkill"
        },
        morale_boost =
        {
            skills = true,
            bad = true,
            x = 4,
            y = 9,
            option = "inspire_basic"
        },
        long_dis_revive =
        {
            u100skill = true,
            bad = true,
            x = 4,
            y = 9,
            option = "inspire_ace"
        },
        DireNeed =
        {
            u100skill = true,
            text = "Stagger",
            no_progress = true,
            x = 10,
            y = 8,
            option = "dire_need"
        },
        Immunity =
        {
            deck = true,
            x = 6,
            deck_option =
            {
                deck = "anarchist",
                option = "immunity"
            }
        },
        UppersCooldown =
        {
            u100skill = true,
            bad = true,
            x = 2,
            y = 11,
            option = "uppers"
        },
        armor_grinding =
        {
            deck = true,
            folder = "opera",
            deck_option =
            {
                deck = "anarchist",
                option = "continuous_armor_regen"
            }
        },
        HealthRegen =
        {
            skills = true,
            x = 2,
            y = 10,
            option = "hostage_taker_muscle",
            check_after_spawn = true,
            class = "EHIHealthRegenBuffTracker"
        },
        crew_throwable_regen =
        {
            texture = tweak_data.hud_icons.skill_7.texture,
            texture_rect = tweak_data.hud_icons.skill_7.texture_rect,
            class = "EHIGaugeBuffTracker",
            option = "regen_throwable_ai"
        },
        Stamina =
        {
            skills = true,
            x = 7,
            y = 3,
            class = "EHIStaminaBuffTracker",
            format = "percent",
            option = "stamina"
        },
        ExPresident =
        {
            deck = true,
            x = 3,
            y = 7,
            deck_option =
            {
                deck = "expresident",
                option = "stored_health"
            },
            check_after_spawn = true,
            format = "damage",
            class = "EHIExPresidentBuffTracker"
        },
        BikerBuff =
        {
            deck = true,
            folder = "wild",
            check_after_spawn = true,
            deck_option =
            {
                deck = "biker",
                option = "kill_counter",
                persistent = "kill_counter_persistent"
            },
            class_to_load =
            {
                load_class = "EHIBikerBuffTracker",
                class = "EHIBikerBuffTracker"
            }
        },
        chico_injector =
        {
            deck = true,
            folder = "chico",
            deck_option =
            {
                deck = "kingpin",
                option = "injector"
            }
        },
        smoke_screen_grenade =
        {
            deck = true,
            folder = "max",
            deck_option =
            {
                deck = "sicario",
                option = "smoke_bomb"
            }
        },
        damage_control =
        {
            deck = true,
            folder = "myh",
            class = "EHIStoicBuffTracker",
            deck_option =
            {
                deck = "stoic",
                option = "duration"
            }
        },
        TagTeamEffect =
        {
            deck = true,
            folder = "ecp",
            y = 1,
            deck_option =
            {
                deck = "tag_team",
                option = "effect"
            },
            class = "EHITagTeamBuffTracker"
        },
        pocket_ecm_kill_dodge =
        {
            deck = true,
            folder = "joy",
            x = 3,
            text = "Dodge+",
            class = "EHIHackerTemporaryDodgeBuffTracker",
            deck_option =
            {
                deck = "hacker",
                option = "pecm_dodge",
            }
        },
        HackerJammerEffect =
        {
            skills = true,
            x = 6,
            y = 3,
            deck_option =
            {
                deck = "hacker",
                option = "pecm_jammer"
            }
        },
        HackerFeedbackEffect =
        {
            skills = true,
            x = 6,
            y = 2,
            deck_option =
            {
                deck = "hacker",
                option = "pecm_feedback"
            }
        },
        copr_ability =
        {
            deck = true,
            folder = "copr",
            deck_option =
            {
                deck = "leech",
                option = "ampule"
            }
        },
        headshot_regen_health_bonus =
        {
            deck = true,
            folder = "mrwi",
            bad = true,
            x = 1,
            deck_option =
            {
                deck = "copycat",
                option = "head_games_cooldown"
            }
        },
        mrwi_health_invulnerable =
        {
            deck = true,
            folder = "mrwi",
            x = 3,
            deck_option =
            {
                deck = "copycat",
                option = "grace_period"
            }
        },
        DamageAbsorption =
        {
            skills = true,
            x = 6,
            y = 4,
            text = "Absorption",
            activate_after_spawn = true,
            option = "damage_absorption",
            persistent = "damage_absorption_persistent",
            class_to_load =
            {
                prerequisite = "EHISkillRefreshBuffTracker",
                class = "EHIDamageAbsorptionBuffTracker"
            },
            enable_in_loud = true
        },
        DamageReduction =
        {
            skills = true,
            x = 6,
            y = 4,
            text = "Reduction",
            format = "percent",
            activate_after_spawn = true,
            option = "damage_reduction",
            persistent = "damage_reduction_persistent",
            class_to_load =
            {
                prerequisite = "EHISkillRefreshBuffTracker",
                class = "EHIDamageReductionBuffTracker"
            },
            enable_in_loud = true
        }
    }
    self.buff.team_crew_inspire = deep_clone(self.buff.long_dis_revive)
    self.buff.team_crew_inspire.text = "AI"
    self.buff.team_crew_inspire.option = "inspire_ai"
    self.buff.reload_weapon_faster = deep_clone(self.buff.swap_weapon_faster)
    self.buff.reload_weapon_faster.text = "Rld+"
    self.buff.chico_injector_cooldown = deep_clone(self.buff.chico_injector)
    self.buff.chico_injector_cooldown.bad = true
    self.buff.chico_injector_cooldown.deck_option.option = "injector_cooldown"
    self.buff.chico_injector_cooldown.class = "EHIReplenishThrowableBuffTracker"
    self.buff.smoke_screen_grenade_cooldown = deep_clone(self.buff.chico_injector_cooldown)
    self.buff.smoke_screen_grenade_cooldown.folder = "max"
    self.buff.smoke_screen_grenade_cooldown.deck_option.deck = "sicario"
    self.buff.smoke_screen_grenade_cooldown.deck_option.option = "smoke_bomb_cooldown"
    self.buff.TagTeamAbsorption = deep_clone(self.buff.TagTeamEffect)
    self.buff.TagTeamAbsorption.deck_option.option = "absorption"
    self.buff.TagTeamAbsorption.x = 2
    self.buff.TagTeamAbsorption.y = 0
    self.buff.TagTeamAbsorption.text = "Absorption"
    self.buff.TagTeamAbsorption.format = "damage"
    self.buff.TagTeamAbsorption.class = "EHIGaugeBuffTracker"
    self.buff.tag_team_cooldown = deep_clone(self.buff.chico_injector_cooldown)
    self.buff.tag_team_cooldown.folder = "ecp"
    self.buff.tag_team_cooldown.deck_option.deck = "tag_team"
    self.buff.tag_team_cooldown.deck_option.option = "cooldown"
    self.buff.damage_control_cooldown = deep_clone(self.buff.damage_control)
    self.buff.damage_control_cooldown.bad = true
    self.buff.damage_control_cooldown.y = 1
    self.buff.damage_control_cooldown.deck_option.option = "cooldown"
    self.buff.damage_control_cooldown.class = "EHIReplenishThrowableBuffTracker"
    self.buff.pocket_ecm_jammer_cooldown = deep_clone(self.buff.chico_injector_cooldown)
    self.buff.pocket_ecm_jammer_cooldown.folder = "joy"
    self.buff.pocket_ecm_jammer_cooldown.deck_option.deck = "hacker"
    self.buff.pocket_ecm_jammer_cooldown.deck_option.option = "pecm_cooldown"
    self.buff.copr_ability_cooldown = deep_clone(self.buff.copr_ability)
    self.buff.copr_ability_cooldown.bad = true
    self.buff.copr_ability_cooldown.deck_option.option = "ampule_cooldown"
    self.buff.copr_ability_cooldown.class = "EHIReplenishThrowableBuffTracker"
    self.buff.mrwi_health_invulnerable_cooldown = deep_clone(self.buff.mrwi_health_invulnerable)
    self.buff.mrwi_health_invulnerable_cooldown.bad = true
    self.buff.mrwi_health_invulnerable_cooldown.deck_option.option = "grace_period_cooldown"
    self.functions =
    {
        ---@param check_job? boolean
        uno_1 = function(check_job)
            local achievement = tweak_data.achievement.complete_heist_achievements.uno_1
            if check_job and not table.contains(achievement.jobs, managers.job:current_job_id()) then
                return
            end
            EHI:ShowAchievementBagValueCounter({
                achievement = achievement.award,
                value = achievement.bag_loot_value,
                show_finish_after_reaching_target = true,
                counter =
                {
                    check_type = EHI.Const.LootCounter.CheckType.ValueOfBags
                }
            })
        end,
        ShowNumberOfLootbagsOnTheGround = function()
            local max = managers.ehi_manager:CountLootbagsOnTheGround()
            if max > 0 then
                EHI:ShowLootCounterNoCheck({ max = max, client_from_start = true })
            end
        end,
        ---Checks if graphic group `grp_wpn` is set (mission script calls both `state_visible` and `state_hide` during level init)
        ---@param weapons number[]
        GetNumberOfVisibleWeapons = function(weapons)
            return table.list_count(weapons, self._count_weapon_loot)
        end,
        ---Checks if graphic group `grp_wpn` is not set (mission script calls only `state_hide` during level init)
        ---@param from_weapon number
        ---@param to_weapon number
        GetNumberOfVisibleWeapons2 = function(from_weapon, to_weapon)
            local n = 0
            local world = managers.worlddefinition
            for i = from_weapon, to_weapon, 1 do
                local weapon = world:get_unit(i) ---@cast weapon UnitCarry
                local damage = weapon and weapon:damage()
                local group = damage and damage._state and damage._state.graphic_group
                if not (group and group.grp_wpn) then
                    n = n + 1
                end
            end
            return n
        end,
        ---Checks money, coke and gold and other loot which uses "var_hidden"
        ---@param loot number[]
        GetNumberOfVisibleOtherLoot = function(loot)
            return table.list_count(loot, self._count_other_loot)
        end,
        ---Checks provided deposit boxes that are scripted to spawn loot when opened
        ---@param from_box number
        ---@param to_box number
        GetNumberOfDepositBoxesWithLoot = function(from_box, to_box)
            local n = 0
            for i = from_box, to_box, 1 do
                if self._count_loot_in_deposit(i) then
                    n = n + 1
                end
            end
            return n
        end,
        ---Checks provided deposit boxes that are scripted to spawn loot when opened
        ---@param boxes number[]
        GetNumberOfDepositBoxesWithLoot2 = function(boxes)
            return table.list_count(boxes, self._count_loot_in_deposit)
        end,
        ---@param truck_id number
        ---@param loot string[]?
        HookArmoredTransportUnit = function(truck_id, loot)
            local exploded
            local function GarbageFound()
                managers.ehi_loot:SyncRandomLootDeclined()
            end
            local function LootFound()
                managers.ehi_loot:SyncRandomLootSpawned()
            end
            local function LootFoundExplosionCheck()
                if exploded then
                    GarbageFound()
                    return
                end
                managers.ehi_loot:SyncRandomLootSpawned()
            end
            managers.mission:add_runned_unit_sequence_trigger(truck_id, "set_exploded", function()
                exploded = true
            end)
            for _, l in ipairs(loot or { "gold", "money", "art" }) do
                for i = 1, 9, 1 do
                    local sequence = string.format("spawn_loot_%s_%d", l, i)
                    if i <= 2 then -- Explosion can disable this loot
                        managers.mission:add_runned_unit_sequence_trigger(truck_id, sequence, LootFoundExplosionCheck)
                    else
                        managers.mission:add_runned_unit_sequence_trigger(truck_id, sequence, LootFound)
                    end
                end
            end
            for i = 1, 9, 1 do
                managers.mission:add_runned_unit_sequence_trigger(truck_id, "spawn_loot_empty_" .. tostring(i), GarbageFound)
            end
        end,
        ---@param self table
        ---@return string
        FormatSecondsOnly = function(self)
            local t = math.floor(self._time * 10) / 10
            if t < 0 then
                return string.format("%d", 0)
            elseif t < 1 then
                return string.format("%.2f", self._time)
            elseif t < 10 then
                return string.format("%.1f", t)
            else
                return string.format("%d", t)
            end
        end,
        ---@param self table
        ---@return string
        ShortFormatSecondsOnly = function(self)
            local t = math.floor(self._time * 10) / 10
            if t < 0 then
                return string.format("%d", 0)
            elseif t < 10 then
                return string.format("%.1f", t)
            else
                return string.format("%d", t)
            end
        end,
        ---@param _ any Unused
        ---@param time number
        ---@return string
        ReturnSecondsOnly = function(_, time)
            local t = math.floor(time * 10) / 10
            if t < 0 then
                return string.format("%d", 0)
            elseif t < 1 then
                return string.format("%.2f", time)
            elseif t < 10 then
                return string.format("%.1f", t)
            else
                return string.format("%d", t)
            end
        end,
        ---@param _ any Unused
        ---@param time number
        ---@return string
        ReturnShortFormatSecondsOnly = function(_, time)
            local t = math.floor(time * 10) / 10
            if t < 0 then
                return string.format("%d", 0)
            elseif t < 10 then
                return string.format("%.1f", t)
            else
                return string.format("%d", t)
            end
        end,
        ---@param self table
        ---@return string
        FormatMinutesAndSeconds = function(self)
            local t = math.floor(self._time * 10) / 10
            if t < 0 then
                return string.format("%d", 0)
            elseif t < 1 then
                return string.format("%.2f", self._time)
            elseif t < 10 then
                return string.format("%.1f", t)
            elseif t < 60 then
                return string.format("%d", t)
            else
                return string.format("%d:%02d", t / 60, t % 60)
            end
        end,
        ---@param self table
        ---@return string
        ShortFormatMinutesAndSeconds = function(self)
            local t = math.floor(self._time * 10) / 10
            if t < 0 then
                return string.format("%d", 0)
            elseif t < 10 then
                return string.format("%.1f", t)
            elseif t < 60 then
                return string.format("%d", t)
            else
                return string.format("%d:%02d", t / 60, t % 60)
            end
        end,
        ---@param _ any Unused
        ---@param time number
        ---@return string
        ReturnMinutesAndSeconds = function(_, time)
            local t = math.floor(time * 10) / 10
            if t < 0 then
                return string.format("%d", 0)
            elseif t < 1 then
                return string.format("%.2f", time)
            elseif t < 10 then
                return string.format("%.1f", t)
            elseif t < 60 then
                return string.format("%d", t)
            else
                return string.format("%d:%02d", t / 60, t % 60)
            end
        end,
        ---@param _ any Unused
        ---@param time number
        ---@return string
        ReturnShortFormatMinutesAndSeconds = function(_, time)
            local t = math.floor(time * 10) / 10
            if t < 0 then
                return string.format("%d", 0)
            elseif t < 10 then
                return string.format("%.1f", t)
            elseif t < 60 then
                return string.format("%d", t)
            else
                return string.format("%d:%02d", t / 60, t % 60)
            end
        end
    }
    tweak_data.hud_icons.EHI_XP = { texture = self.icons.xp.texture }
    tweak_data.hud_icons.EHI_Gage = { texture = self.icons.gage.texture }
    tweak_data.hud_icons.EHI_Minion = self.icons.minion
    tweak_data.hud_icons.EHI_Loot = tweak_data.hud_icons.pd2_loot
    tweak_data.hud_icons.EHI_Sniper = self.icons.sniper
    local preplanning = tweak_data.preplanning
    local path = preplanning.gui.type_icons_path
    do
        local text_rect_blimp = preplanning:get_type_texture_rect(preplanning.types.kenaz_faster_blimp.icon)
        text_rect_blimp[1] = text_rect_blimp[1] + text_rect_blimp[3] -- Add the negated "w" value so it will correctly show blimp
        text_rect_blimp[3] = -text_rect_blimp[3] -- Flip the image so it will face correctly
        self.icons.blimp = { texture = path, texture_rect = text_rect_blimp }
    end
    self.icons.heli = { texture = path, texture_rect = preplanning:get_type_texture_rect(preplanning.types.kenaz_ace_pilot.icon) }
    tweak_data.hud_icons.EHI_Heli = self.icons.heli
    self.icons.oil = { texture = path, texture_rect = preplanning:get_type_texture_rect(preplanning.types.kenaz_drill_improved_cooling_system.icon) }
    self.icons.zipline_bag = { texture = path, texture_rect = preplanning:get_type_texture_rect(preplanning.types.corp_zipline_north.icon) }
    self.icons.tablet = { texture = path, texture_rect = preplanning:get_type_texture_rect(preplanning.types.crojob2_manifest.icon) }
    self.icons.code = { texture = path, texture_rect = preplanning:get_type_texture_rect(84) } -- Code, currently unused -> hardcoded number
    if EHI:GetUnlockableAndOption("show_dailies") then
        self.icons.daily_hangover = { texture = path, texture_rect = preplanning:get_type_texture_rect(preplanning.types.chca_spiked_drink.icon) }
        tweak_data.hud_icons.daily_hangover = self.icons.daily_hangover
    end
    return self
end

---Checks if graphic group `grp_wpn` is set (mission script calls both `state_visible` and `state_hide` during level init)
---@param weapon_id number
function EHITweakData._count_weapon_loot(weapon_id)
    local weapon = managers.worlddefinition:get_unit(weapon_id) --[[@as UnitCarry?]]
    local damage = weapon and weapon:damage()
    local state = damage and damage._state and damage._state.graphic_group and damage._state.graphic_group.grp_wpn
    if state and state[1] == "set_visibility" and state[2] then
        return true
    end
end

---Checks money, coke and gold and other loot which uses "var_hidden"
---@param loot_id number
function EHITweakData._count_other_loot(loot_id)
    local loot = managers.worlddefinition:get_unit(loot_id) --[[@as UnitCarry?]]
    local damage = loot and loot:damage()
    if damage and damage._variables and damage._variables.var_hidden == 0 then
        return true
    end
end

---@param deposit_id number
function EHITweakData._count_loot_in_deposit(deposit_id)
    local deposit = managers.worlddefinition:get_unit(deposit_id) --[[@as UnitCarry?]]
    local damage = deposit and deposit:damage()
    if damage and damage._variables and damage._variables.var_random == 0 then
        return true
    end
end