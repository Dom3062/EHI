local EHI = EHI

---@class EHITweakData
EHITweakData = {}
---@param tweak_data tweak_data
function EHITweakData:new(tweak_data)
    self.default =
    {
        tracker =
        {
            size_h = 32,
            size_w = 64,
            offset = 6,
            gap = 5,
            ---@param icon string
            get_icon = function(icon)
                local ehi_icons = self.icons
                if ehi_icons[icon] then
                    local custom_icon = ehi_icons[icon]
                    return custom_icon.texture, custom_icon.texture_rect
                end
                return tweak_data.hud_icons:get_icon_or(icon, ehi_icons.default.texture, ehi_icons.default.texture_rect)
            end
        },
        buff =
        {
            size_h = 64,
            size_w = 32,
            gap = 6,
            ---@return string
            ---@return number[]
            get_icon = function(params)
                local texture, texture_rect
                local x = params.x or 0
                local y = params.y or 0
                if params.skills then
                    texture = "guis/textures/pd2/skilltree/icons_atlas"
                    texture_rect = { x * 64, y * 64, 64, 64 }
                elseif params.u100skill then
                    texture = "guis/textures/pd2/skilltree_2/icons_atlas_2"
                    texture_rect = { x * 80, y * 80, 80, 80 }
                elseif params.deck then
                    texture = "guis/" .. (params.folder and ("dlcs/" .. params.folder .. "/") or "") .. "textures/pd2/specialization/icons_atlas"
                    texture_rect = { x * 64, y * 64, 64, 64 }
                elseif params.texture then
                    texture = params.texture
                    texture_rect = params.texture_rect
                end
                return texture, texture_rect
            end
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

        hoxton_character = { texture = tweak_data.achievement.visual.bulldog_1.unlock_icons[1].texture },

        daily_secret_identity = { texture = "guis/textures/pd2_mod_ehi/icons_atlas", texture_rect = {0, 170, 64, 64} },

        ping = { texture = "guis/textures/pd2_mod_ehi/icons_atlas", texture_rect = { 224, 192, 64, 64 } }
    }
    -- Definitions for buffs and their icons
    self.buff =
    {
        Ability =
        {
            dont_show_in_menu = true,
            skill_check_after_spawn = true,
            text = "Ability",
            class = "EHIAbilityBuffTracker",
            prepopulate_options =
            {
                chico_injector = { deck_option = { deck = "kingpin", option = "injector" } },
                smoke_screen_grenade = { deck_option = { deck = "sicario", option = "smoke_bomb" } },
                damage_control = { deck_option = { deck = "stoic", option = "duration" } },
                tag_team = { deck_option = { deck = "tag_team", option = "effect" } },
                copr_ability = { deck_option = { deck = "leech", option = "ampule" } }
            },
            prepopulate_options_permanent =
            {
                chico_injector = { deck_option = { deck = "kingpin", option = "injector_persistent" } },
                smoke_screen_grenade = { deck_option = { deck = "sicario", option = "smoke_bomb_persistent" } },
                damage_control = { deck_option = { deck = "stoic", option = "duration_persistent" } },
                tag_team = { deck_option = { deck = "tag_team", option = "effect_persistent" } },
                copr_ability = { deck_option = { deck = "leech", option = "ampule_persistent" } }
            }
        },
        AbilityCooldown =
        {
            dont_show_in_menu = true,
            skill_check_after_spawn = true,
            group = "cooldown",
            class = "EHIAbilityRefreshBuffTracker",
            prepopulate_options =
            {
                chico_injector = { deck_option = { deck = "kingpin", option = "injector_cooldown" } },
                smoke_screen_grenade = { deck_option = { deck = "sicario", option = "smoke_bomb_cooldown" } },
                damage_control = { deck_option = { deck = "stoic", option = "cooldown" } },
                tag_team = { deck_option = { deck = "tag_team", option = "cooldown" } },
                pocket_ecm_jammer = { deck_option = { deck = "hacker", option = "pecm_cooldown" } },
                copr_ability = { deck_option = { deck = "leech", option = "ampule_cooldown" } }
            },
            prepopulate_options_permanent =
            {
                chico_injector = { deck_option = { deck = "kingpin", option = "injector_cooldown_persistent" } },
                smoke_screen_grenade = { deck_option = { deck = "sicario", option = "smoke_bomb_cooldown_persistent" } },
                damage_control = { deck_option = { deck = "stoic", option = "cooldown_persistent" } },
                tag_team = { deck_option = { deck = "tag_team", option = "cooldown_persistent" } },
                pocket_ecm_jammer = { deck_option = { deck = "hacker", option = "pecm_cooldown_persistent" } },
                copr_ability = { deck_option = { deck = "leech", option = "ampule_cooldown_persistent" } }
            }
        },
        Health =
        {
            deck = true,
            folder = "chico",
            text = "0",
            x = 1,
            y = 0,
            class = "EHIHealthBuffTracker",
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
        CarryInteractionCooldown =
        {
            u100skill = true,
            group = "cooldown",
            text_localize = "ehi_buffs_hint_cooldown",
            x = 4,
            y = 3,
            option = "carry_interaction_cooldown",
            permanent =
            {
                option = "carry_interaction_cooldown_persistent",
                always_show = true
            }
        },
        DodgeChance =
        {
            u100skill = true,
            x = 1,
            y = 12,
            group = "dodge",
            text_localize = "ehi_buffs_hint_dodge",
            format = "percent",
            skill_check_after_spawn = true,
            option = "dodge",
            persistent = "dodge_persistent",
            class_to_load =
            {
                prerequisite = "EHISkillRefreshBuffTracker",
                class = "EHIDodgeChanceBuffTracker"
            }
        },
        CritChance =
        {
            u100skill = true,
            x = 0,
            y = 12,
            group = "crit",
            text_localize = "ehi_buffs_hint_crit",
            format = "percent",
            skill_check_after_spawn = true,
            option = "crit",
            persistent = "crit_persistent",
            class_to_load =
            {
                prerequisite = "EHISkillRefreshBuffTracker",
                class = "EHICritChanceBuffTracker"
            }
        },
        Berserker =
        {
            u100skill = true,
            x = 2,
            y = 2,
            skill_check_after_spawn = true,
            option = "berserker",
            class_to_load =
            {
                prerequisite = "EHISkillRefreshBuffTracker",
                class = "EHIBerserkerBuffTracker"
            }
        },
        Yakuza =
        {
            deck = true,
            text = "Yakuza",
            x = 2,
            y = 7,
            deck_option =
            {
                deck = "yakuza",
                option = "irezumi",
            },
            skill_check_after_spawn = true,
            class_to_load =
            {
                prerequisite = "EHISkillRefreshBuffTracker",
                class = "EHIYakuzaBuffTracker"
            }
        },
        Reload =
        {
            skills = true,
            group = "cooldown",
            y = 9,
            option = "reload",
            permanent =
            {
                option = "reload_persistent",
                always_show = true
            }
        },
        Interact =
        {
            texture = "guis/textures/pd2/pd2_waypoints",
            texture_rect = { 224, 32, 32, 32 },
            option = "interact",
            permanent =
            {
                option = "interact_persistent",
                always_show = true
            }
        },
        ArmorRegenDelay =
        {
            u100skill = true,
            group = "cooldown",
            text_localize = "ehi_buffs_hint_regen",
            x = 2,
            y = 12,
            option = "shield_regen",
            skill_check_after_spawn = true,
            class = "EHIArmorRegenDelayBuffTracker",
            permanent =
            {
                option = "shield_regen_persistent",
                skill_check =
                {
                    skills =
                    {
                        { category = "player", upgrade = "armor_grinding" }, -- Anarchist
                        { category = "player", upgrade = "armor_to_health_conversion" } -- Stoic
                    },
                    negate = true
                }
            }
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
            },
            permanent =
            {
                option = "melee_charge_persistent",
                always_show = true,
                class_to_load =
                {
                    load_class = "EHIMeleeChargeBuffTracker",
                    class = "EHIPersistentMeleeChargeBuffTracker"
                }
            }
        },
        WeaponSwap =
        {
            skills = true,
            text = "Swap",
            group = "cooldown",
            y = 9,
            option = "weapon_swap",
            permanent =
            {
                option = "weapon_swap_persistent",
                always_show = true
            }
        },
        headshot_regen_armor_bonus =
        {
            skills = true,
            group = "cooldown",
            x = 6,
            y = 11,
            option = "bullseye",
            permanent =
            {
                option = "bullseye_persistent",
                skill_check =
                {
                    category = "player",
                    upgrade = "headshot_regen_armor_bonus"
                }
            }
        },
        revive_damage_reduction =
        {
            skills = true,
            text_localize = "ehi_buffs_hint_damage_decrease",
            group = "player_damage_reduction",
            x = 5,
            y = 7,
            option = "combat_medic",
            permanent =
            {
                option = "combat_medic_persistent",
                skill_check =
                {
                    category = "temporary",
                    upgrade = "revive_damage_reduction"
                }
            }
        },
        berserker_damage_multiplier =
        {
            skills = true,
            x = 5,
            y = 12,
            option = "swan_song",
            permanent =
            {
                option = "swan_song_persistent",
                skill_check =
                {
                    category = "temporary",
                    upgrade = "berserker_damage_multiplier"
                }
            }
        },
        dmg_multiplier_outnumbered =
        {
            skills = true,
            text_localize = "ehi_buffs_hint_damage_increase",
            group = "weapon_damage_increase",
            x = 2,
            y = 1,
            option = "underdog",
            permanent =
            {
                option = "underdog_persistent",
                skill_check =
                {
                    category = "temporary",
                    upgrade = "dmg_multiplier_outnumbered"
                }
            }
        },
        first_aid_damage_reduction =
        {
            skills = true,
            text_localize = "ehi_buffs_hint_damage_decrease",
            group = "player_damage_reduction",
            x = 1,
            y = 11,
            option = "quick_fix",
            permanent =
            {
                option = "quick_fix_persistent",
                skill_check =
                {
                    category = "temporary",
                    upgrade = "first_aid_damage_reduction"
                }
            }
        },
        UppersRangeGauge =
        {
            u100skill = true,
            x = 2,
            y = 11,
            group = "health_regen",
            skill_check_after_spawn = true,
            option = "uppers_range",
            persistent = "uppers_range_persistent",
            class_to_load =
            {
                prerequisite = "EHISkillRefreshBuffTracker",
                class = "EHIUppersRangeBuffTracker"
            }
        },
        fast_learner =
        {
            u100skill = true,
            text_localize = "ehi_buffs_hint_damage_decrease",
            group = "player_damage_reduction",
            y = 10,
            option = "painkillers",
            permanent =
            {
                option = "painkillers_persistent",
                skill_check =
                {
                    category = "player",
                    upgrade = "revive_damage_reduction_level"
                }
            }
        },
        melee_life_leech =
        {
            deck = true,
            group = "cooldown",
            x = 7,
            y = 4,
            deck_option =
            {
                deck = "infiltrator",
                option = "melee_cooldown"
            },
            permanent =
            {
                deck_option =
                {
                    deck = "infiltrator",
                    option = "melee_cooldown_persistent"
                },
                skill_check =
                {
                    category = "temporary",
                    upgrade = "melee_life_leech"
                }
            }
        },
        dmg_dampener_close_contact =
        {
            deck = true,
            group = "player_damage_reduction",
            text_localize = "ehi_buffs_hint_damage_decrease",
            x = 5,
            y = 4,
            option = "underdog",
            permanent =
            {
                option = "underdog_persistent",
                skill_check =
                {
                    category = "player",
                    upgrade = "dmg_multiplier_outnumbered"
                }
            }
        },
        loose_ammo_give_team =
        {
            deck = true,
            group = "cooldown",
            x = 5,
            y = 5,
            deck_option =
            {
                deck = "gambler",
                option = "ammo_give_out_cooldown"
            },
            permanent =
            {
                deck_option =
                {
                    deck = "gambler",
                    option = "ammo_give_out_cooldown_persistent"
                },
                skill_check =
                {
                    category = "temporary",
                    upgrade = "loose_ammo_give_team"
                }
            }
        },
        loose_ammo_restore_health =
        {
            deck = true,
            group = "cooldown",
            x = 4,
            y = 5,
            deck_option =
            {
                deck = "gambler",
                option = "regain_health_cooldown"
            },
            permanent =
            {
                deck_option =
                {
                    deck = "gambler",
                    option = "regain_health_cooldown_persistent"
                },
                skill_check =
                {
                    category = "temporary",
                    upgrade = "loose_ammo_restore_health"
                }
            }
        },
        damage_speed_multiplier =
        {
            u100skill = true,
            text_localize = "ehi_buffs_hint_movement_increase",
            group = "player_movement_increase",
            x = 10,
            y = 9,
            option = "second_wind",
            permanent =
            {
                option = "second_wind_persistent",
                skill_check =
                {
                    category = "temporary",
                    upgrade = "damage_speed_multiplier"
                },
                show_on_trigger_when_synced = true
            }
        },
        trigger_happy =
        {
            u100skill = true,
            text_localize = "ehi_buffs_hint_damage_increase",
            group = "weapon_damage_increase",
            x = 11,
            y = 2,
            option = "trigger_happy",
            permanent =
            {
                option = "trigger_happy_persistent",
                skill_check =
                {
                    category = "pistol",
                    upgrade = "stacking_hit_damage_multiplier"
                }
            }
        },
        desperado =
        {
            u100skill = true,
            text = "Acc+",
            x = 11,
            y = 1,
            option = "desperado",
            permanent =
            {
                option = "desperado_persistent",
                skill_check =
                {
                    category = "pistol",
                    upgrade = "stacked_accuracy_bonus"
                }
            }
        },
        revived_damage_resist =
        {
            u100skill = true,
            text_localize = "ehi_buffs_hint_damage_decrease",
            group = "player_damage_reduction",
            x = 11,
            y = 4,
            option = "up_you_go",
            permanent =
            {
                option = "up_you_go_persistent",
                skill_check =
                {
                    category = "temporary",
                    upgrade = "revived_damage_resist"
                }
            }
        },
        swap_weapon_faster =
        {
            u100skill = true,
            text = "Swap+",
            x = 11,
            y = 3,
            option = "running_from_death_swap",
            permanent =
            {
                option = "running_from_death_swap_persistent",
                skill_check =
                {
                    category = "temporary",
                    upgrade = "swap_weapon_faster"
                }
            }
        },
        increased_movement_speed =
        {
            u100skill = true,
            text_localize = "ehi_buffs_hint_movement_increase",
            group = "player_movement_increase",
            x = 11,
            y = 3,
            option = "running_from_death_movement",
            permanent =
            {
                option = "running_from_death_movement_persistent",
                skill_check =
                {
                    category = "temporary",
                    upgrade = "increased_movement_speed"
                }
            }
        },
        unseen_strike =
        {
            u100skill = true,
            text_localize = "ehi_buffs_hint_crit_increase",
            group = "crit",
            x = 10,
            y = 11,
            option = "unseen_strike",
            persistent = "unseen_strike_persistent",
            parent_buff =
            {
                parent = "CritChance",
                skill_check =
                {
                    category = "player",
                    upgrade = "unseen_increased_crit_chance"
                }
            },
            skill_check_after_spawn = true,
            class = "EHIForceUpdateParentBuffTracker"
        },
        unseen_strike_initial =
        {
            u100skill = true,
            group = "cooldown",
            x = 10,
            y = 11,
            option = "unseen_strike_initial",
            permanent =
            {
                option = "unseen_strike_initial_persistent",
                skill_check =
                {
                    category = "player",
                    upgrade = "unseen_increased_crit_chance"
                }
            }
        },
        melee_damage_stacking =
        {
            u100skill = true,
            x = 11,
            y = 6,
            group = "melee_damage_increase",
            text_localize = "ehi_buffs_hint_melee_damage_increase",
            format = "multiplier",
            option = "bloodthirst",
            skill_check_after_spawn = true,
            class = "EHIBloodthirstBuffTracker"
        },
        melee_kill_increase_reload_speed =
        {
            u100skill = true,
            x = 11,
            y = 6,
            text_localize = "ehi_buffs_hint_reload_increase",
            group = "increased_weapon_reload",
            option = "bloodthirst_reload",
            permanent =
            {
                option = "bloodthirst_reload_persistent",
                skill_check =
                {
                    category = "player",
                    upgrade = "melee_kill_increase_reload_speed"
                }
            }
        },
        standstill_omniscience =
        {
            skills = true,
            group = "cooldown",
            x = 6,
            y = 10,
            option = "sixth_sense_refresh",
            remove_on_alarm = true,
            permanent =
            {
                option = "sixth_sense_refresh_persistent",
                skill_check =
                {
                    category = "player",
                    upgrade = "standstill_omniscience"
                },
                stealth_check = true
            }
        },
        no_ammo_cost =
        {
            u100skill = true,
            x = 4,
            y = 5,
            option = "bulletstorm",
            permanent =
            {
                option = "bulletstorm_persistent",
                skill_check =
                {
                    category = "player",
                    upgrade = "no_ammo_cost"
                }
            }
        },
        hostage_absorption =
        {
            u100skill = true,
            x = 4,
            y = 7,
            group = "player_damage_absorption",
            option = "forced_friendship",
            permanent =
            {
                option = "forced_friendship_persistent",
                team_skill_check =
                {
                    category = "damage",
                    upgrade = "hostage_absorption"
                },
                class = "EHIPermanentGaugeBuffTracker"
            },
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
            group = "player_damage_absorption",
            x = 3,
            format = "standard",
            skill_check_after_spawn = true,
            deck_option =
            {
                deck = "maniac",
                option = "stack",
            },
            class = "EHIManiacBuffTracker"
        },
        GrinderStackCooldown =
        {
            deck = true,
            group = "cooldown",
            x = 5,
            y = 6,
            deck_option =
            {
                deck = "grinder",
                option = "stack_cooldown"
            },
            permanent =
            {
                deck_option =
                {
                    deck = "grinder",
                    option = "stack_cooldown_persistent"
                },
                skill_check =
                {
                    category = "player",
                    upgrade = "damage_to_hot"
                }
            }
        },
        GrinderRegenPeriod =
        {
            deck = true,
            x = 5,
            y = 6,
            group = "health_regen",
            deck_option =
            {
                deck = "grinder",
                option = "regen_duration"
            },
            permanent =
            {
                deck_option =
                {
                    deck = "grinder",
                    option = "regen_duration_persistent"
                },
                skill_check =
                {
                    category = "player",
                    upgrade = "damage_to_hot"
                }
            }
        },
        SicarioTwitchGauge =
        {
            deck = true,
            folder = "max",
            group = "dodge",
            text_localize = "ehi_buffs_hint_dodge_increase",
            x = 1,
            class = "EHIGaugeBuffTracker",
            format = "percent",
            deck_option =
            {
                deck = "sicario",
                option = "twitch",
            },
            permanent =
            {
                deck_option =
                {
                    deck = "sicario",
                    option = "twitch_persistent"
                },
                class = "EHIPermanentGaugeBuffTracker",
                skill_check =
                {
                    category = "player",
                    upgrade = "dodge_shot_gain"
                }
            }
        },
        SicarioTwitchCooldown =
        {
            deck = true,
            folder = "max",
            group = "cooldown",
            x = 1,
            deck_option =
            {
                deck = "sicario",
                option = "twitch_cooldown"
            },
            permanent =
            {
                deck_option =
                {
                    deck = "sicario",
                    option = "twitch_cooldown_persistent"
                },
                skill_check =
                {
                    category = "player",
                    upgrade = "dodge_shot_gain"
                }
            }
        },
        ammo_efficiency =
        {
            u100skill = true,
            x = 8,
            y = 4,
            option = "ammo_efficiency",
            permanent =
            {
                option = "ammo_efficiency_persistent",
                skill_check =
                {
                    category = "player",
                    upgrade = "head_shot_ammo_return"
                }
            }
        },
        armor_break_invulnerable =
        {
            deck = true,
            group = "cooldown",
            text_localize = "ehi_buffs_hint_immunity",
            x = 6,
            y = 1,
            deck_option =
            {
                deck = "anarchist",
                option = "immunity_cooldown"
            },
            permanent =
            {
                deck_option =
                {
                    deck = "anarchist",
                    option = "immunity_cooldown_persistent"
                },
                skill_check =
                {
                    category = "temporary",
                    upgrade = "armor_break_invulnerable"
                }
            }
        },
        damage_to_armor =
        {
            deck = true,
            group = "cooldown",
            folder = "opera",
            y = 1,
            deck_option =
            {
                deck = "anarchist",
                option = "kill_armor_regen_cooldown"
            },
            permanent =
            {
                deck_option =
                {
                    deck = "anarchist",
                    option = "kill_armor_regen_cooldown_persistent"
                },
                skill_check =
                {
                    category = "player",
                    upgrade = "damage_to_armor"
                }
            }
        },
        single_shot_fast_reload =
        {
            u100skill = true,
            text_localize = "ehi_buffs_hint_reload_increase",
            group = "increased_weapon_reload",
            x = 8,
            y = 3,
            option = "aggressive_reload",
            permanent =
            {
                option = "aggressive_reload_persistent",
                skill_check =
                {
                    category = "player",
                    upgrade = "single_shot_fast_reload"
                }
            }
        },
        overkill_damage_multiplier =
        {
            skills = true,
            text_localize = "ehi_buffs_hint_damage_increase",
            group = "weapon_damage_increase",
            x = 3,
            y = 2,
            option = "overkill",
            permanent =
            {
                option = "overkill_persistent",
                skill_check =
                {
                    category = "temporary",
                    upgrade = "overkill_damage_multiplier"
                }
            }
        },
        morale_boost =
        {
            skills = true,
            group = "cooldown",
            x = 4,
            y = 9,
            option = "inspire_basic",
            permanent =
            {
                option = "inspire_basic_persistent",
                skill_check =
                {
                    category = "player",
                    upgrade = "morale_boost"
                }
            }
        },
        long_dis_revive =
        {
            u100skill = true,
            group = "cooldown",
            x = 4,
            y = 9,
            option = "inspire_ace",
            permanent =
            {
                option = "inspire_ace_persistent",
                skill_check =
                {
                    category = "cooldown",
                    upgrade = "long_dis_revive"
                }
            }
        },
        DireNeed =
        {
            u100skill = true,
            text = "Stagger",
            no_progress = true,
            x = 10,
            y = 8,
            option = "dire_need",

        },
        Immunity =
        {
            deck = true,
            x = 6,
            deck_option =
            {
                deck = "anarchist",
                option = "immunity"
            },
            permanent =
            {
                deck_option =
                {
                    deck = "anarchist",
                    option = "immunity_persistent"
                },
                skill_check =
                {
                    category = "temporary",
                    upgrade = "armor_break_invulnerable"
                }
            }
        },
        UppersCooldown =
        {
            u100skill = true,
            group = "cooldown",
            x = 2,
            y = 11,
            option = "uppers",
            permanent =
            {
                option = "uppers_persistent",
                always_show = true
            }
        },
        armor_grinding =
        {
            deck = true,
            folder = "opera",
            deck_option =
            {
                deck = "anarchist",
                option = "continuous_armor_regen"
            },
            permanent =
            {
                deck_option =
                {
                    deck = "anarchist",
                    option = "continuous_armor_regen_persistent"
                },
                skill_check =
                {
                    category = "player",
                    upgrade = "armor_grinding"
                }
            }
        },
        HealthRegen =
        {
            skills = true,
            x = 2,
            y = 10,
            group = "health_regen",
            option = "hostage_taker_muscle",
            persistent = "hostage_taker_muscle_persistent",
            skill_check_after_spawn = true,
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
            text = "Stored",
            group = "health_regen",
            deck_option =
            {
                deck = "expresident",
                option = "stored_health"
            },
            skill_check_after_spawn = true,
            format = "damage",
            class = "EHIExPresidentBuffTracker"
        },
        BikerBuff =
        {
            deck = true,
            folder = "wild",
            deck_option =
            {
                deck = "biker",
                option = "kill_counter",
            },
            permanent =
            {
                option_true = true,
                skill_check =
                {
                    skills =
                    {
                        { category = "player", upgrade = "wild_health_amount" },
                        { category = "player", upgrade = "wild_armor_amount" }
                    }
                },
                class_to_load =
                {
                    load_class = "EHIBikerBuffTracker",
                    class = "EHIBikerBuffTracker"
                }
            }
        },
        TagTeamAbsorption =
        {
            deck = true,
            folder = "ecp",
            text = "Absorption",
            x = 2,
            group = "player_damage_absorption",
            deck_option =
            {
                deck = "tag_team",
                option = "absorption"
            },
            format = "damage",
            class = "EHIGaugeBuffTracker",
            permanent =
            {
                deck_option =
                {
                    deck = "tag_team",
                    option = "absorption_persistent"
                },
                skill_check =
                {
                    category = "player",
                    upgrade = "tag_team_damage_absorption"
                },
                class = "EHIPermanentGaugeBuffTracker"
            }
        },
        pocket_ecm_kill_dodge =
        {
            deck = true,
            folder = "joy",
            group = "dodge",
            x = 3,
            text_localize = "ehi_buffs_hint_dodge_increase",
            parent_buff =
            {
                parent = "DodgeChance",
                skill_check =
                {
                    category = "temporary",
                    upgrade = "pocket_ecm_kill_dodge"
                }
            },
            skill_check_after_spawn = true,
            class = "EHIForceUpdateParentBuffTracker",
            deck_option =
            {
                deck = "hacker",
                option = "pecm_dodge",
                persistent = "pecm_dodge_persistent"
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
            },
            remove_on_alarm = true,
            permanent =
            {
                deck_option =
                {
                    deck = "hacker",
                    option = "pecm_jammer_persistent"
                },
                skill_check =
                {
                    category = "player",
                    upgrade = "pocket_ecm_jammer_base"
                }
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
            },
            activate_on_alarm = true,
            permanent =
            {
                deck_option =
                {
                    deck = "hacker",
                    option = "pecm_feedback_persistent"
                },
                skill_check =
                {
                    category = "player",
                    upgrade = "pocket_ecm_jammer_base"
                }
            }
        },
        headshot_regen_health_bonus =
        {
            deck = true,
            folder = "mrwi",
            group = "cooldown",
            x = 1,
            deck_option =
            {
                deck = "copycat",
                option = "head_games_cooldown"
            },
            permanent =
            {
                deck_option =
                {
                    deck = "copycat",
                    option = "head_games_cooldown_persistent"
                },
                skill_check =
                {
                    category = "player",
                    upgrade = "headshot_regen_health_bonus"
                }
            }
        },
        mrwi_health_invulnerable =
        {
            deck = true,
            folder = "mrwi",
            text_localize = "ehi_buffs_hint_immunity",
            x = 3,
            deck_option =
            {
                deck = "copycat",
                option = "grace_period"
            },
            permanent =
            {
                deck_option =
                {
                    deck = "copycat",
                    option = "grace_period_persistent"
                },
                skill_check =
                {
                    category = "temporary",
                    upgrade = "mrwi_health_invulnerable"
                }
            }
        },
        primary_reload_secondary =
        {
            deck = true,
            folder = "mrwi",
            text = "Primary",
            deck_option =
            {
                deck = "copycat",
                option = "primary_reload_secondary"
            },
            permanent =
            {
                option_true = true,
                skill_check =
                {
                    category = "player",
                    upgrade = "primary_reload_secondary"
                },
                class = "EHIPermanentGaugeBuffTracker"
            }
        },
        DamageAbsorption =
        {
            skills = true,
            x = 6,
            y = 4,
            group = "player_damage_absorption",
            text = "Absorption",
            skill_check_after_spawn = true,
            option = "damage_absorption",
            persistent = "damage_absorption_persistent",
            class_to_load =
            {
                prerequisite = "EHISkillRefreshBuffTracker",
                class = "EHIDamageAbsorptionBuffTracker"
            }
        },
        DamageReduction =
        {
            skills = true,
            x = 6,
            y = 4,
            group = "player_damage_reduction",
            text = "Reduction",
            format = "percent",
            skill_check_after_spawn = true,
            option = "damage_reduction",
            persistent = "damage_reduction_persistent",
            class_to_load =
            {
                prerequisite = "EHISkillRefreshBuffTracker",
                class = "EHIDamageReductionBuffTracker"
            }
        }
    }
    self.buff.standstill_omniscience_initial = deep_clone(self.buff.standstill_omniscience)
    self.buff.standstill_omniscience_initial.option = "sixth_sense_initial"
    self.buff.standstill_omniscience_initial.permanent.option = "sixth_sense_initial_persistent"
    self.buff.standstill_omniscience_highlighted = deep_clone(self.buff.standstill_omniscience)
    self.buff.standstill_omniscience_highlighted.group = nil
    self.buff.standstill_omniscience_highlighted.option = "sixth_sense_marked"
    self.buff.standstill_omniscience_highlighted.permanent.option = "sixth_sense_marked_persistent"
    self.buff.standstill_omniscience_highlighted.permanent.class = "EHIPermanentGaugeBuffTracker"
    self.buff.standstill_omniscience_highlighted.class = "EHIGaugeBuffTracker"
    self.buff.morale_boost_reload = deep_clone(self.buff.morale_boost)
    self.buff.morale_boost_reload.text_localize = "ehi_buffs_hint_reload_increase"
    self.buff.morale_boost_reload.group = "increased_weapon_reload"
    self.buff.morale_boost_reload.option = "inspire_reload"
    self.buff.morale_boost_reload.permanent.option = "inspire_reload_persistent"
    self.buff.morale_boost_reload.permanent.skill_check = nil
    self.buff.morale_boost_reload.permanent.show_on_trigger = true
    self.buff.morale_boost_movement = deep_clone(self.buff.morale_boost_reload)
    self.buff.morale_boost_movement.text_localize = "ehi_buffs_hint_movement_increase"
    self.buff.morale_boost_movement.group = "player_movement_increase"
    self.buff.morale_boost_movement.option = "inspire_movement"
    self.buff.morale_boost_movement.permanent.option = "inspire_movement_persistent"
    self.buff.team_crew_inspire = deep_clone(self.buff.long_dis_revive)
    self.buff.team_crew_inspire.text = "AI"
    self.buff.team_crew_inspire.option = "inspire_ai"
    self.buff.team_crew_inspire.permanent.option = "inspire_ai_persistent"
    self.buff.team_crew_inspire.permanent.skill_check = nil
    self.buff.team_crew_inspire.permanent.team_ai_skill_check =
    {
        category = "ability",
        upgrade = "crew_inspire"
    }
    self.buff.reload_weapon_faster = deep_clone(self.buff.swap_weapon_faster)
    self.buff.reload_weapon_faster.text_localize = "ehi_buffs_hint_reload_increase"
    self.buff.reload_weapon_faster.group = "increased_weapon_reload"
    self.buff.reload_weapon_faster.option = "running_from_death_reload"
    self.buff.reload_weapon_faster.permanent.option = "running_from_death_reload_persistent"
    self.buff.mrwi_health_invulnerable_cooldown = deep_clone(self.buff.mrwi_health_invulnerable)
    self.buff.mrwi_health_invulnerable_cooldown.group = "cooldown"
    self.buff.mrwi_health_invulnerable_cooldown.text_localize = "ehi_buffs_hint_cooldown"
    self.buff.mrwi_health_invulnerable_cooldown.deck_option.option = "grace_period_cooldown"
    self.buff.mrwi_health_invulnerable_cooldown.permanent.deck_option.option = "grace_period_cooldown_persistent"
    self.buff.secondary_reload_primary = deep_clone(self.buff.primary_reload_secondary)
    self.buff.secondary_reload_primary.text = "Secondary"
    self.buff.secondary_reload_primary.deck_option.option = "secondary_reload_primary"
    self.buff.secondary_reload_primary.permanent.skill_check.upgrade = "secondary_reload_primary"
    -- Buff redirect for buffs that use more than just one ID
    self.buff_redirect =
    {
        chico_injector = "Ability", -- Kingpin Injector
        smoke_screen_grenade = "Ability", -- Sicario Smoke Bomb
        damage_control = "Ability", -- Stoic's Hip Flask
        tag_team_effect = "Ability", -- Gas Dispenser
        copr_ability = "Ability" -- Leech Ampule
    }
    self.functions =
    {
        achievements =
        {
            -- I Do What I Do Best, I Take Scores
            armored_4 = function()
                if EHI:CanShowAchievement2("armored_4", "show_achievements_other") and EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) then
                    local armored_4 = tweak_data.achievement.complete_heist_achievements.i_take_scores
                    EHI:AddOnSpawnedExtendedCallback(function(ingame, job, level, from_beginning)
                        if table.contains(armored_4.jobs, job) and managers.blackmarket:equipped_mask().mask_id == armored_4.mask and from_beginning then
                            local progress = EHI:GetAchievementProgress("armored_4_stat")
                            EHI:AddCallback(EHI.CallbackMessage.MissionEnd, function(success)
                                if success and progress < 15 and managers.job:on_last_stage() then
                                    managers.hud:custom_ingame_popup_text(managers.localization:to_upper_text("achievement_armored_4"), tostring(progress + 1) .. "/15", EHI:GetAchievementIconString("armored_4"))
                                end
                            end)
                        end
                    end)
                end
            end,
            -- The only one that is true  
            -- The one that had many names  
            -- The one that survived  
            -- The one who declared himself the hero
            ---@param id string Achievement ID
            eng_X = function(id)
                if EHI:CanShowAchievement2(id, "show_achievements_other") then
                    local id_stat = id .. "_stats"
                    local progress = EHI:GetAchievementProgress(id_stat) + 1
                    managers.ehi_hook:HookAchievementAwardProgress(id, function(am, stat, value)
                        if stat == id_stat and progress < 5 then
                            managers.hud:custom_ingame_popup_text(managers.localization:to_upper_text("achievement_" .. id), tostring(progress) .. "/5", EHI:GetAchievementIconString(id))
                        end
                    end)
                end
            end,
            -- A Good Haul
            uno_1 = function()
                local achievement = tweak_data.achievement.complete_heist_achievements.uno_1
                if not table.contains(achievement.jobs, managers.job:current_real_job_id()) then
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
            end
        },
        ShowNumberOfLootbagsOnTheGround = function()
            local max = EHI.Mission._utils:CountLootbagsOnTheGround()
            if max > 0 then
                EHI:ShowLootCounterNoCheck({ max = max })
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
        ---Checks provided deposit boxes that are scripted to have loot
        ---@param boxes number[]
        GetNumberOfLootInADepositBoxesInWall = function(boxes)
            local result = 0
            for _, box in ipairs(boxes) do
                result = result + self._count_amount_of_loot_in_deposit(box)
            end
            return result
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
            for _, l in ipairs(loot or { "gold", "money", "art" }) do -- "art" = jewelry
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
    self.icons.daily_hangover = { texture = path, texture_rect = preplanning:get_type_texture_rect(preplanning.types.chca_spiked_drink.icon) }
    tweak_data.hud_icons.daily_hangover = self.icons.daily_hangover
    self.__color_redirect =
    {
        [Color.blue] = Color(0, 1, 1) -- Aqua as Blue can be hardly visible on some surfaces
    }
    self.__language_format =
    {
        -- Default language format (even for English)
        default =
        {
            percent = function()
                return "%"
            end,
            percent_format = function()
                return "%%"
            end,
            equipment = function()
                ---@param charges number
                return function(charges)
                    return string.format("%g %s left", charges, charges > 1 and "uses" or "use")
                end
            end
        },
        czech =
        {
            percent = function()
                return " %"
            end,
            percent_format = function()
                return " %%"
            end,
            equipment = function()
                ---@param charges number
                return function(charges)
                    return string.format("%s %g použití", math.within(charges, 2, 4) and "Zbývají" or "Zbývá", charges)
                end
            end
        }
    }
    self:_classic_heisting_u24_tweaks()
    return self
end

---Checks if graphic group `grp_wpn` is set (mission script calls both `state_visible` and `state_hide` during level init)
---@param weapon_id number
function EHITweakData._count_weapon_loot(weapon_id)
    local weapon = managers.worlddefinition:get_unit(weapon_id) --[[@as UnitCarry?]]
    local damage = weapon and weapon:damage()
    local state = damage and damage._state and damage._state.graphic_group and damage._state.graphic_group.grp_wpn
    return state and state[1] == "set_visibility" and state[2]
end

---Checks money, coke and gold and other loot which uses "var_hidden"
---@param loot_id number
function EHITweakData._count_other_loot(loot_id)
    local loot = managers.worlddefinition:get_unit(loot_id) --[[@as UnitCarry?]]
    local damage = loot and loot:damage()
    local variables = damage and damage._variables
    return variables and variables.var_hidden == 0
end

---@param deposit_id number
function EHITweakData._count_loot_in_deposit(deposit_id)
    local deposit = managers.worlddefinition:get_unit(deposit_id) --[[@as UnitCarry?]]
    local damage = deposit and deposit:damage()
    local variables = damage and damage._variables
    return variables and variables.var_random == 0
end

function EHITweakData._count_amount_of_loot_in_deposit(deposit_id)
    local deposit = managers.worlddefinition:get_unit(deposit_id) --[[@as UnitCarry?]]
    local damage = deposit and deposit:damage()
    local variables = damage and damage._variables
    return variables and variables.var_amount or 0
end

function EHITweakData:_populate_buff_color_table()
    return {
        { texture_color = "red", icon_color = Color.red },
        { texture_color = "orange", icon_color = Color(255, 255, 106, 0) / 255 },
        { texture_color = "green", icon_color = Color.green },
        { texture_color = "yellow", icon_color = Color.yellow },
        { texture_color = "blue", icon_color = Color.blue },
        { texture_color = "cyan", icon_color = Color(255, 0, 255, 255) / 255 },
        { texture_color = "pink", icon_color = Color(255, 255, 0, 220) / 255 },
        { texture_color = "purple", icon_color = Color(255, 178, 0, 255) / 255 },
        { texture_color = "violet", icon_color = Color(255, 127, 0, 255) / 255 },
        { texture_color = "magenta", icon_color = Color(255, 255, 0, 255) / 255 },
        { texture_color = "azure", icon_color = Color(255, 0, 128, 255) / 255 },
        { texture_color = "brown", icon_color = Color(255, 165, 42, 42) / 255 },
        { texture_color = "crimson", icon_color = Color(255, 220, 20, 60) / 255 },
        { texture_color = "salmon", icon_color = Color(255, 250, 128, 114) / 255 },
        { texture_color = "gold", icon_color = Color(255, 255, 215, 0) / 255 },
        { texture_color = "turquoise", icon_color = Color(255, 64, 224, 208) / 255 }
    }
end

function EHITweakData._populate_buff_group_table()
    return { "cooldown", "weapon_damage_increase", "melee_damage_increase", "player_damage_reduction", "player_damage_absorption", "increased_weapon_reload", "player_movement_increase", "dodge", "crit", "health_regen" }
end

---@param i number
function EHITweakData:GetBuffColorFromIndex(i)
    self.__buffs_color = self.__buffs_color or self:_populate_buff_color_table()
    local entry = i and self.__buffs_color[i - 1]
    if entry then
        return entry.icon_color, entry.texture_color
    end
    return Color.white, "white"
end

---@param texture string
function EHITweakData:GetIconColorFromTextureColor(texture)
    self.__buffs_color = self.__buffs_color or self:_populate_buff_color_table()
    for _, tbl in ipairs(self.__buffs_color) do
        if tbl.texture_color == texture then
            return tbl.icon_color
        end
    end
    return Color.white
end

function EHITweakData:GetSelectedBuffColors()
    local data = {} ---@type table<string, { texture_color: string, icon_color: Color }>
    for _, group in ipairs(self._populate_buff_group_table()) do
        local color, texture = self:GetBuffColorFromIndex(EHI:GetOption("buffs_group_color_" .. group))
        data[group] = { texture_color = texture, icon_color = color }
    end
    data.default = { texture_color = "white", icon_color = Color.white }
    return data
end

function EHITweakData:_classic_heisting_u24_tweaks()
    if not _G.ch_settings then
        return
    end
    -- Change buff icons to something else as the buff icon is empty
    self.buff.MeleeCharge.y = 0
    -- Change texture atlas as the U100 Atlas is not used
    self.buff.no_ammo_cost.skills = true
end

---@param color Color
function EHITweakData:ColorRedirect(color)
    return self.__color_redirect[color] or color
end

---@param language string?
function EHITweakData:GetLanguageFormat(language)
    language = language or "default"
    return self.__language_format[language] or self.__language_format.default
end