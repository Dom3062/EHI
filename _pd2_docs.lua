---@meta
--[[
    This file is not loaded, it is here to provide code completion in VSCode
]]

---
--- Aliases
---
---@alias UnitObject UnitPlayer|UnitEnemy|UnitTeamAI|UnitCivilian|UnitBase
---@param obj (Unit|Workspace|PanelBaseObject)?
---@return boolean
function alive(obj)
end

_G.Global = {}
---@class World
---@field find_units fun(self: self, ...): Unit[]
---@field find_units_quick fun(self: self, ...): Unit[]
---@field make_slot_mask fun(self: self, ...: number): SlotMask
_G.World = {}
---@class tweak_data
_G.TweakData = {}
---@class tweak_data
---@field chat_colors Color[]
---@field get_raw_value fun(self: self, ...): any
---@field get_value fun(self: self, ...): any
_G.tweak_data = {}
---@class AchievementsTweakData
_G.AchievementsTweakData = {}
---@class AchievementsTweakData
_G.tweak_data.achievement = {
    gonna_find_them_all = 1,
    no_we_cant = {
        stat = "armored_10_stat",
        mask = "obama"
    },
    witch_doctor = {
        stat = "halloween_4_stats",
        mask = "witch"
    },
    its_alive_its_alive = {
        stat = "halloween_5_stats",
        mask = "frank"
    },
    relation_with_bulldozer = {
        stat = "armored_8_stat",
        mask = "clinton"
    },
    pump_action = {
        stat = "halloween_6_stats",
        mask = "pumpkin_king"
    },
    cant_hear_you_scream = {
        stat = "halloween_7_stats",
        mask = "venomorph"
    },
    fire_in_the_hole = {
        stat = "gage_9_stats",
        grenade = {
            "frag",
            "frag_com",
            "concussion",
            "dada_com",
            "fir_com"
        }
    }
}
---@class AchievementsTweakData.complete_heist_achievements
_G.tweak_data.achievement.complete_heist_achievements = {
    in_soviet_russia = {
        contract = "vlad",
        stat = "halloween_10_stats",
        mask = "bear",
        difficulty = overkill_and_above
    },
    i_take_scores = {
        stat = "armored_4_stat",
        mask = "heat",
        difficulty = overkill_and_above,
        jobs = {
            "arm_cro",
            "arm_und",
            "arm_hcm",
            "arm_par",
            "arm_fac"
        }
    },
    tango_3 = {
        award = "tango_achieve_3",
        difficulty = veryhard_and_above,
        killed_by_blueprint = {
            blueprint = "wpn_fps_upg_o_spot",
            amount = 200
        }
    },
    uno_1 = {
        award = "uno_1",
        bag_loot_value = 400000,
        jobs = {
            "branchbank_prof",
            "branchbank_gold_prof",
            "branchbank_cash",
            "branchbank_deposit"
        }
    },
    tawp_1 = {
        mask = "flm",
        award = "tawp_1",
        job = "help",
        difficulty = normal_and_above,
        specials_killed = {
            {
                enemy = "spooc",
                count = 1
            }
        }
    },
    daily_classics = {
        trophy_stat = "daily_classics",
        jobs = {
            "red2",
            "flat",
            "dinner",
            "pal",
            "man",
            "run",
            "glace",
            "dah",
            "nmh"
        }
    },
    daily_discord = {
        converted_cops = 1,
        trophy_stat = "daily_discord"
    }
}
---@class AchievementsTweakData.enemy_kill_achievements
_G.tweak_data.achievement.enemy_kill_achievements = {
    im_not_a_crook = {
        weapon = "s552",
        stat = "armored_7_stat",
        enemy = "sniper",
        mask = "nixon"
    },
    fool_me_once = {
        weapon = "m45",
        stat = "armored_9_stat",
        mask = "bush",
        enemy_tags_any = {
            "shield"
        }
    },
    wanted = {
        weapon = "ak5",
        stat = "gage_1_stats",
        mask = "goat"
    },
    three_thousand_miles = {
        weapon = "p90",
        stat = "gage_2_stats",
        mask = "panda"
    },
    commando = {
        weapon = "aug",
        stat = "gage_3_stats",
        mask = "pitbull"
    },
    public_enemies = {
        weapon = "colt_1911",
        stat = "gage_4_stats",
        mask = "eagle"
    },
    akm4_shootout = {
        is_cop = true,
        stat = "ameno_08_stats",
        weapons = {
            "ak74",
            "akm",
            "akm_gold",
            "saiga",
            "rpk",
            "amcar",
            "new_m4",
            "m16",
            "akmsu",
            "olympic",
            "flint"
        }
    },
    grv_3 = {
        stat = "grv_3_stats",
        weapons = {
            "siltstone",
            "flint",
            "coal"
        }
    },
    pxp1_1 = {
        kill = true,
        stat = "pxp1_1_stats",
        difficulties = overkill_and_above,
        grenade_types = {
            "wpn_prj_four",
            "launcher_poison",
            "launcher_poison_ms3gl_conversion",
            "launcher_poison_gre_m79",
            "launcher_poison_m32",
            "launcher_poison_groza",
            "launcher_poison_china",
            "launcher_poison_arbiter",
            "launcher_poison_slap",
            "launcher_poison_contraband"
        },
        player_style = {
            variation = "default",
            style = "scrub"
        }
    }
}
---@class AchievementsTweakData.enemy_melee_hit_achievements
_G.tweak_data.achievement.enemy_melee_hit_achievements = {
    steel_2 = {
        award = "steel_2",
        result = "death",
        melee_weapons = {
            "morning",
            "buck",
            "beardy",
            "great"
        },
        enemy_kills = {
            enemy = "shield",
            count = 10
        }
    },
    sawp_1 = {
        is_not_civilian = true,
        result = "death",
        stat = "sawp_stat",
        melee_weapons = {
            "taser",
            "zeus"
        },
        player_style = {
            variation = "default",
            style = "cable_guy"
        },
        difficulty = overkill_and_above
    },
    pxp1_1 = {
        is_not_civilian = true,
        result = "death",
        stat = "pxp1_1_stats",
        difficulty = overkill_and_above,
        melee_weapons = {
            "cqc",
            "fear"
        },
        player_style = {
            variation = "default",
            style = "scrub"
        }
    }
}
---@class AchievementsTweakData.grenade_achievements
_G.tweak_data.achievement.grenade_achievements = {
        bada_boom = {
            kill = true,
            grenade_type = "launcher_frag",
            count = 4,
            award = "gage5_2"
        },
        artillery_barrage = {
            kill = true,
            grenade_type = "launcher_frag",
            distance = 4000,
            stat = "gage5_5_stats"
        },
        boom_shakalaka = {
            kill = true,
            flying_strike = true,
            award = "gage5_7",
            enemy = "spooc",
            grenade_type = "launcher_frag"
        },
        not_invited = {
            timer = 10,
            grenade_type = "launcher_frag_m32",
            award = "grill_3",
            kill_count = 10
        },
        threemite = {
            kill = true,
            grenade_type = "dynamite",
            count = 3,
            award = "scorpion_2"
        },
        steel_3 = {
            kill = true,
            grenade_type = "wpn_prj_jav",
            award = "steel_3",
            enemy = "spooc"
        },
        pim_2 = {
            kill = true,
            is_civilian = false,
            success = true,
            job = "dark",
            crouching = true,
            stat = "pim_2_stats"
        },
        tango_2 = {
            kill = true,
            stat = "tango_2_stats",
            enemy = "sniper",
            grenade_type = "launcher_frag_arbiter"
        },
        any_kills = {
            kill = true,
            challenge_stat = "any_kills"
        },
        any_sniper_kills = {
            kill = true,
            enemy = "sniper",
            challenge_stat = "any_sniper_kills"
        },
        any_shield_kills = {
            kill = true,
            challenge_stat = "any_shield_kills",
            enemy_tags_any = {
                "shield"
            }
        },
        any_taser_kills = {
            kill = true,
            enemy = "taser",
            challenge_stat = "any_taser_kills"
        },
        any_tank_kills = {
            kill = true,
            challenge_stat = "any_tank_kills",
            enemy_tags_any = {
                "tank"
            }
        },
        any_spooc_kills = {
            kill = true,
            enemy = "spooc",
            challenge_stat = "any_spooc_kills"
        },
        trophy_special_kills = {
            kill = true,
            trophy_stat = "trophy_special_kills",
            enemy_tags_any = {
                "special"
            }
        },
        trophy_ace = {
            kill = true,
            trophy_stat = "trophy_ace",
            grenade_type = "wpn_prj_ace",
            difficulties = overkill_and_above
        },
        trophy_washington = {
            kill = true,
            trophy_stat = "trophy_washington"
        },
        trophy_medic = {
            kill = true,
            trophy_stat = "trophy_medic",
            enemies = {
                "medic"
            }
        },
        daily_grenades = {
            kill = true,
            trophy_stat = "daily_grenades",
            grenade_type = "frag",
            is_civilian = false
        },
        daily_grenades_community = {
            kill = true,
            trophy_stat = "daily_grenades",
            grenade_type = "frag_com",
            is_civilian = false
        },
        daily_grenades_dynamite = {
            kill = true,
            trophy_stat = "daily_grenades",
            grenade_type = "dynamite",
            is_civilian = false
        },
        daily_grenades_dada = {
            kill = true,
            trophy_stat = "daily_grenades",
            grenade_type = "dada_com",
            is_civilian = false
        },
        explosive_kills = {
            kill = true,
            explosive = true,
            challenge_stat = "explosive_kills"
        },
        cac_1 = {
            kill = true,
            grenade_type = "launcher_frag_slap",
            distance = 4000,
            enemy = "sniper",
            award = "cac_1"
        },
        cac_35 = {
            player_state = "driving",
            stat = "cac_35_stats",
            enemy_tags_all = {
                "law"
            }
        },
        dec21_02 = {
            kill = true,
            stat = "dec21_02_stat",
            explosive = false
        },
        pxp1_1 = {
            kill = true,
            stat = "pxp1_1_stats",
            difficulties = overkill_and_above,
            grenade_types = {
                "wpn_prj_four",
                "launcher_poison",
                "launcher_poison_ms3gl_conversion",
                "launcher_poison_gre_m79",
                "launcher_poison_m32",
                "launcher_poison_groza",
                "launcher_poison_china",
                "launcher_poison_arbiter",
                "launcher_poison_slap",
                "launcher_poison_contraband"
            },
            player_style = {
                variation = "default",
                style = "scrub"
            }
        },
        pxp2_3 = {
            kill = true,
            stat = "pxp2_3_stats",
            grenade_type = "poison_gas_grenade",
            difficulties = overkill_and_above
        },
        cg22_personal_1 = {
            grenade_type = "xmas_snowball",
            stat = "cg22_personal_1",
            mutators = {
                "MutatorCG22"
            }
        }
    }
---@class AchievementsTweakData.loot_cash_achievements
_G.tweak_data.achievement.loot_cash_achievements = {
    pal_2 = {
        award = "pal_2",
        job = "pal",
        secured = {
            carry_id = "counterfeit_money",
            value = 1000000
        }
    },
    daily_mortage = {
        trophy_stat = "daily_mortage",
        is_dropin = false,
        jobs = {
            "family"
        },
        secured = {
            carry_id = "diamonds",
            total_amount = 16
        }
    },
    daily_candy = {
        trophy_stat = "daily_candy",
        secured = {
            {
                amount = 1,
                carry_id = {
                    "coke",
                    "coke_light",
                    "coke_pure",
                    "present",
                    "yayo"
                }
            }
        }
    },
    daily_lodsofemone = {
        trophy_stat = "daily_lodsofemone",
        secured = {
            carry_id = "money",
            amount = 1
        }
    }
}
---@class AchievementsTweakData.collection_achievements
_G.tweak_data.achievement.collection_achievements = {
    xm20_1 = {
        award = "xm20_1",
        collection = {
            "present_mex",
            "present_bex",
            "present_pex",
            "present_fex"
        }
    },
    pent_11 = {
        award = "pent_11",
        collection = {
            "tea_chas",
            "tea_sand",
            "tea_chca",
            "tea_pent"
        }
    },
    lrfo_1 = {
        award = "lrfo_1",
        collection = {
            "LRON_played",
            "LRTW_played",
            "LRTH_played",
            "LRFO_played"
        }
    }
}
_G.tweak_data.hud = {}
---@class tweak_data.screen_colors
---@field button_stage_1 Color
---@field button_stage_2 Color
---@field button_stage_3 Color
---@field event_color Color
---@field ghost_color Color
---@field heat_cold_color Color
---@field heat_warm_color Color
---@field important_1 Color
---@field text Color
---@field pro_color Color
---@field risk Color
_G.tweak_data.screen_colors = {}
---@class CarryTweakData
---@field types table<string, { move_speed_modifier: number, jump_modifier: number, can_run: boolean, throw_distance_multiplier: number }>
---@field small_loot table<string, number>
---@field [string] { name_id: string, is_unique_loot: boolean, type: string, skip_exit_secure: boolean }
_G.tweak_data.carry = {}
---@class DOTTweakData
---@field get_dot_data fun(self: self, tweak_name: string): table?
_G.tweak_data.dot = {}
---@class EHITweakData
_G.tweak_data.ehi = {}
---@class EquipmentsTweakData
_G.tweak_data.equipments = {
    ammo_bag = {
        deploy_time = 2,
        use_function_name = "use_ammo_bag",
        dummy_unit = "units/payday2/equipment/gen_equipment_ammobag/gen_equipment_ammobag_dummy_unit",
        text_id = "debug_ammo_bag",
        icon = "equipment_ammo_bag",
        description_id = "des_ammo_bag",
        visual_object = "g_ammobag",
        quantity = {
            1
        }
    }
}
---@class GageAssignmentTweakData
---@field get_experience_multiplier fun(self: self, ratio: number): number
---@field get_num_assignment_units fun(self: self): number
_G.tweak_data.gage_assignment = {}
---@class GuiTweakData
---@field stats_present_multiplier number
_G.tweak_data.gui = {}
---@class GroupAITweakData
_G.tweak_data.group_ai = {
    difficulty_curve_points = {
        0.5
    },
    phalanx = {
        vip = {
            damage_reduction = {
                max = 0.5,
                start = 0.1,
                increase_intervall = 5,
                increase = 0.05
            }
        },
        spawn_chance = {
            decrease = 0, -- 0/0.7/1
            start = 0, -- 0/0.01/0.05
            respawn_delay = 0, -- 120/300000
            increase = 0, -- 0/0.09
            max = 0 -- 0/1
        },
        check_spawn_intervall = 120,
        chance_increase_intervall = 120
    }
}
---@class HudIconsTweakData
---@field [string] { texture: string, texture_rect: { number: x, number: y, number: w, number: h } }
---@field get_icon_or fun(self: self, icon_id: string, ...): string, { number: x, number: y, number: w, number: h } If the provided icon is not found, `...` is returned
---@field get_icon_data fun(self: self, icon_id: string, default_rect: { number: x, number: y, number: w, number: h }? ): string, { number: x, number: y, number: w, number: h }
_G.tweak_data.hud_icons = {}
---@class LootDropTweakData
_G.tweak_data.lootdrop = {}
---@class LootDropTweakData.global_values
---@field [string] { color: Color }
_G.tweak_data.lootdrop.global_values = {}
---@class MenuTweakData
---@field medium_font string
---@field pd2_small_font string
---@field pd2_small_font_size number
---@field pd2_medium_font string
---@field pd2_large_font string
---@field pd2_large_font_id Idstring
---@field pd2_large_font_size number
_G.tweak_data.menu = {}
---@class PlayerTweakData
---@field SUSPICION_OFFSET_LERP number
---@field alarm_pager PlayerTweakData.alarm_pager
---@field damage PlayerTweakData.damage
---@field omniscience PlayerTweakData.omniscience
_G.tweak_data.player = {}
---@class PlayerTweakData.alarm_pager
---@field bluff_success_chance_w_skill number[]
_G.tweak_data.alarm_pager = {}
---@class PlayerTweakData.damage
---@field automatic_respawn_time number?
_G.tweak_data.player.damage = {
    base_respawn_time_penalty = 5,
    DODGE_INIT = 0,
    respawn_time_penalty = 30
}
---@class PlayerTweakData.omniscience
---@field start_t number
---@field target_resense_t number
_G.tweak_data.player.damage.omniscience = {}
---@class PrePlanningTweakData
---@field get_type_texture_rect fun(self: self, num: number): { number: x, number: y, number: w, number: h }
---@field types table
_G.tweak_data.preplanning = {
    gui = {
        type_icons_path = "guis/dlcs/deep/textures/pd2/pre_planning/preplan_icon_types"
    }
}
---@class UpgradesTweakData
---@field values UpgradesTweakData.values
_G.tweak_data.upgrades = {
    ammo_bag_base = 4,
    bodybag_crate_base = 3,
    copr_high_damage_multiplier = { 20, 2 },
    doctor_bag_base = 2,
    ecm_feedback_retrigger_interval = 240,
    ecm_jammer_base_battery_life = 20,
    first_aid_kit = {
        first_aid_kit_auto_recovery = { 500 }
    },
    max_cocaine_stacks_per_tick = 240,
    sentry_gun_base_ammo = 100,
    sentry_gun_base_armor = 10,
    player_damage_health_ratio_threshold = 0.5,
    wild_max_triggers_per_time = 4
}
---@class UpgradesTweakData.values
---@field player UpgradesTweakData.values.player
---@field team UpgradesTweakData.values.team
---@field temporary UpgradesTweakData.values.temporary
_G.tweak_data.upgrades.values = {}
---@class UpgradesTweakData.values.player
_G.tweak_data.upgrades.values.player = {
    copr_activate_bonus_health_ratio = { 0.4 },
    copr_kill_life_leech = { 2, 2 },
    copr_out_of_health_move_slow = { 0.2 },
    copr_static_damage_ratio = { 0.2, 0.1 },
    copr_speed_up_on_kill = { 1 },
    damage_control_cooldown_drain = {
        { 0, 1 },
        { 35, 2 }
    },
    dodge_shot_gain = {
        { 0.2, 4 }
    },
    chico_injector_low_health_multiplier = {
        { 0.5, 0.25 }
    },
    chico_injector_health_to_speed = {
        { 5, 1 }
    },
    melee_damage_stacking = {
        {
            max_multiplier = 16,
            melee_multiplier = 1
        }
    },
    pocket_ecm_jammer_base = {
        {
            affects_cameras = true,
            cooldown_drain = 6,
            affects_pagers = true,
            feedback_interval = 1,
            duration = 6,
            feedback_range = 2500
        }
    },
    pocket_ecm_heal_on_kill = { 2 },
    smoke_screen_ally_dodge_bonus = { 0.1 },
    tag_team_base = {
        {
            kill_health_gain = 1.5,
            radius = 0.6,
            distance = 18,
            kill_extension = 1.3,
            duration = 12,
            tagged_health_gain_ratio = 0.5
        }
    },
    tag_team_cooldown_drain = {
        {
            tagged = 0,
            owner = 2
        },
        {
            tagged = 2,
            owner = 2
        }
    },
    tag_team_damage_absorption = {
        {
            kill_gain = 0.2,
            max = 2
        }
    }
}
---@class UpgradesTweakData.values.team
_G.tweak_data.upgrades.values.team = {
    crew_throwable_regen = { 35 },
    hostage_absorption = { 0.05 },
    hostage_absorption_limit = 8,
    pocket_ecm_heal_on_kill = { 1 }
}
---@class UpgradesTweakData.values.temporary
_G.tweak_data.upgrades.values.temporary = {
    copr_ability = {
        { true, 6 },
        { true, 10 }
    },
    first_aid_damage_reduction = {
        { 0.9, 120 }
    },
    chico_injector = {
        { 0.75, 6 }
    },
    pocket_ecm_kill_dodge = {
        { 0.2, 30, 1 }
    }
}
---@class managers
_G.managers = {}
---@type boolean
_G.IS_VR = ...
---@class AmmoBagBase
_G.AmmoBagBase = {}
---@class AmmoBagInteractionExt : UseInteractionExt
---@field _unit UnitAmmoDeployable
_G.AmmoBagInteractionExt = {}
---@class BaseInteractionExt
---@field _active boolean
---@field _materials U_Material[]
---@field _add_string_macros fun(self: self, macros: table<string, string>)
---@field active fun(self: self): boolean
_G.BaseInteractionExt = {}
---@class BlackMarketGui
_G.BlackMarketGui = {}
---@class BaseNetworkSession
_G.BaseNetworkSession = {}
---@class CarryData
_G.CarryData = {}
---@class CustomAmmoBagBase : AmmoBagBase
_G.CustomAmmoBagBase = {}
---@class GrenadeCrateBase
_G.GrenadeCrateBase = {}
---@class GrenadeCrateInteractionExt
_G.GrenadeCrateInteractionExt = {}
---@class CallbackEventHandler
---@field new fun(self: self): self
---@field add fun(self: self, func: function)
---@field dispatch fun(self: self, ...)
---@field clear fun(self: self)
---@field remove fun(self: self, func: function)
_G.CallbackEventHandler = {}
---@class CarryTweakData
_G.CarryTweakData = {}
---@class CoreWorldInstanceManager
_G.CoreWorldInstanceManager = {}
---@class CivilianDamage
_G.CivilianDamage = {}
---@class CopDamage
_G.CopDamage = {}
---@class Drill
_G.Drill = {}
---@class ECMJammerBase
_G.ECMJammerBase = {}
---@class ElementExperience : MissionScriptElement
---@field super MissionScriptElement
---@field _values ElementExperience._values
_G.ElementExperience = {}
---@class ElementJobValue : MissionScriptElement
---@field super MissionScriptElement
---@field _values ElementJobValue._values
_G.ElementJobValue = {}
---@class ElementWaypoint : MissionScriptElement
---@field super MissionScriptElement
---@field _values ElementWaypoint._values
_G.ElementWaypoint = {}
---@class EventListenerHolder
---@field new fun(self: self): self
---@field add fun(self: self, key: string|number, event_types: table|string|number, clbk: function)
---@field call fun(self: self, event: string|number, ...)
---@field remove fun(self: self, key: string|number)
---@field has_listeners_for_event fun(self: self, event: string): table?
_G.EventListenerHolder = {}
---@class FirstAidKitBase
_G.FirstAidKitBase = {}
---@class TimerGui
_G.TimerGui = {}
---@class DigitalGui
_G.DigitalGui = {}
---@class ExperienceManager
_G.ExperienceManager = {}
---@class GamePlayCentralManager
_G.GamePlayCentralManager = {}
---@class GroupAITweakData
_G.GroupAITweakData = {
    enemy_spawn_groups = {
        marshal_squad = {
            spawn_cooldown = 60,
            max_nr_simultaneous_groups = 2,
            initial_spawn_delay = 90,
            amount = {
                2,
                2
            },
            spawn = {
                {
                    respawn_cooldown = 30,
                    amount_min = 1,
                    rank = 2,
                    freq = 1,
                    unit = "marshal_shield",
                    tactics = self._tactics.marshal_shield
                },
                {
                    respawn_cooldown = 30,
                    amount_min = 1,
                    rank = 1,
                    freq = 1,
                    unit = "marshal_marksman",
                    tactics = self._tactics.marshal_marksman
                }
            },
            spawn_point_chk_ref = table.list_to_set({
                "tac_shield_wall",
                "tac_shield_wall_ranged",
                "tac_shield_wall_charge"
            })
        }
    }
}
---@class GroupAIStateBase
_G.GroupAIStateBase = {}
---@class IngameWaitingForPlayersState
_G.IngameWaitingForPlayersState = {}
---@class JobManager
_G.JobManager = {}
---@class LevelsTweakData
---@field get_default_team_ID fun(self: self, type: string): string
_G.LevelsTweakData = {}
---@class LobbyCodeMenuComponent
---@field _panel Panel
_G.LobbyCodeMenuComponent = {}
---@class LootManager
_G.LootManager = {}
---@class ListenerHolder
---@field _listeners table<string, function>?
---@field new fun(self: self): self
---@field add fun(self: self, key: string, clbk: function)
---@field call fun(self: self, ...)
---@field remove fun(self: self, key: string)
_G.ListenerHolder = {}
---@class CriminalsManager
_G.CriminalsManager = {}
---@class EnemyManager
_G.EnemyManager = {}
---@class PlayerManager
_G.PlayerManager = {}
---@class PlayerDamage
_G.PlayerDamage = {}
---@class PrePlanningManager
_G.PrePlanningManager = {}
---@class GageAssignmentManager
_G.GageAssignmentManager = {}
---@class HUDManager
_G.HUDManager = {}
---@class HUDMissionBriefing
_G.HUDMissionBriefing = {}
---@class HUDHeistTimer
---@field _enabled boolean
---@field _last_time number
---@field _timer_text PanelText
---@field _heist_timer_panel Panel
_G.HUDHeistTimer = {}
---@class ObjectInteractionManager
---@field _interactive_units UnitWithInteraction[]
_G.ObjectInteractionManager = {}
---@class MissionAssetsManager
_G.MissionAssetsManager = {}
---@class MissionBriefingGui
_G.MissionBriefingGui = {}
---@class ModifiersManager
_G.ModifiersManager = {}
---@class MoneyManager
_G.MoneyManager = {}
---@class mvector3
---@field distance fun(vec1: Vector3, vec2: Vector3): number
---@field dot fun(cam_fwd: number|Vector3, test_vec: Vector3): number
---@field normalize fun(vec: Vector3)
---@field set fun(vec1: Vector3, vec2: Vector3) Sets `vec2` into `vec1`
---@field set_z fun(vec: Vector3, z: number) Sets `z` in `vec`
_G.mvector3 = {}
---@class NetworkPeer
_G.NetworkPeer = {}
---@class PlayerMovement
---@field _stamina number
---@field current_state fun(self: self): PlayerStandard?
---@field crouching fun(self: self): boolean
---@field m_head_pos fun(self: self): Vector3
---@field m_head_rot fun(self: self): Rotation
---@field running fun(self: self): boolean
---@field zipline_unit fun(self: self): UnitZipline
_G.PlayerMovement = {}
---@class SkirmishTweakData
_G.SkirmishTweakData = {}
---@class StatisticsManager
---@field _get_boom_guns fun(self: self): string[]
---@field _get_name_id_and_throwable_id fun(self: self, weapon_unit: UnitWeapon): string?, string?
---@field is_dropin fun(self: self): boolean
---@field session_hit_accuracy fun(self: self): number
---@field started_session_from_beginning fun(self: self): boolean
_G.StatisticsManager = {}
---@class TeamAIBase : CopBase
---@field _loadout { skill: string?, ability: string? }?
---@field _unit UnitTeamAI
---@field _registered boolean
_G.TeamAIBase = {}
---@class TradeManager
_G.TradeManager = {}
---@class UseInteractionExt : BaseInteractionExt
---@field _unit UnitCarry
---@field super BaseInteractionExt
_G.UseInteractionExt = {}
---@class VehicleDrivingExt
_G.VehicleDrivingExt = {}
---@class WorldDefinition
_G.WorldDefinition = {}
---@class ZipLine
_G.ZipLine = {}
---@param o table? Can be used to provide `self` to the callback function
---@param base_callback_class table
---@param base_callback_func_name string
---@param base_callback_param any?
---@return function
_G.callback = function(o, base_callback_class, base_callback_func_name, base_callback_param)
end
---@return Vector3
---@overload fun(x: number, y: number, z: number): Vector3
_G.Vector3 = function()
end
---@return Rotation
---@overload fun(x: number, y: number): Rotation
---@overload fun(x: number, y: number, z: number): Rotation
---@overload fun(x: number, y: number, z: number, w: number): Rotation
_G.Rotation = function()
end

---Has to be called in an animation
---@param seconds number
---@param f fun(lerp: number, t: number)
---@param fixed_dt number?
_G.over = function(seconds, f, fixed_dt)
end

---Has to be called in an animation
---@param seconds number
---@param fixed_dt number?
_G.wait = function(seconds, fixed_dt)
end

---@class _G.Color
---@overload fun(): Color
---@overload fun(r: number, g: number, b: number): Color
---@overload fun(a: number, r: number, g: number, b: number): Color
---@overload fun(hex: string): Color
---@operator div(number): Color
---@operator div(integer): Color
---@field black Color
---@field red Color
---@field white Color
---@field green Color
---@field yellow Color
_G.Color = {}

---@class _G.Idstring
---@overload fun(path_or_name: string): Idstring
_G.Idstring = {}

---@class Vector3
---@operator sub(self): Vector3
---@field length fun(self: self): number
---@field with_y fun(self: self, y: number): Vector3

---@class Rotation
---@field y fun(self: self): number

---@class Camera
---@field position fun(self: self): Vector3
---@field rotation fun(self: self): Rotation

---@class SyncData
---@field EHIAssaultManager EHIAssaultManagerSyncData
---@field EHILootManager LootCounterTable
---@field EHIManager EHIManagerSyncData
---@field EHISyncManager EHISyncManagerSyncData
---@field EHIPhalanxManager EHIPhalanxManagerSyncData

---@generic T
---@param TC T
---@return T
_G.deep_clone = function(TC)
end
CoreTable.deep_clone = _G.deep_clone

---@generic T: table
---@param super T? A base class which `class` will derive from
---@return T
function class(super)
end

---@generic T
---@param category string
---@param upgrade string
---@return table|number
---@overload fun(self: self, category: string, upgrade: string, default: `T`): T|table|number
function PlayerManager:upgrade_value(category, upgrade)
end

---@param category string
---@param upgrade string
---@return number
---@overload fun(self: self, category: string, upgrade: string, default: number): number
function PlayerManager:upgrade_level(category, upgrade)
end

---@class TextureRect
---@field [1] number X
---@field [2] number Y
---@field [3] number W
---@field [4] number H

---@class Vector3
---@field x number
---@field y number
---@field z number

---@class Color
---@operator div(integer): Color
---@operator div(number): Color
---@field r number
---@field red number
---@field g number
---@field green number
---@field b number
---@field blue number
---@field unpack fun(self: self): r: number, g: number, b: number
---@field with_alpha fun(self: self, alpha: number): self

---@class Idstring
---@field key fun(self: self): string
---@field t fun(self: self): string Returns self formatted as @ID<16 byte hex>@; Example: `@IDe166f63494083d58@`

---@class ElementAreaTrigger : MissionScriptElement
---@field _is_inside fun(self: self, position: Vector3): boolean

---@class ElementCounterFilter : MissionScriptElement
---@field _values_ok fun(self: self): boolean

---@class ElementFilter : MissionScriptElement
---@field _check_difficulty fun(self: self): boolean
---@field _check_mode fun(self: self): boolean

---@class ElementLogicChance : MissionScriptElement
---@field _values ElementLogicChanceOperatorValues
---@field add_trigger fun(self: self, id: any, outcome: "success"|"fail", callback: function)

---@class ElementLogicChanceOperator : MissionScriptElement
---@field _values ElementLogicChance._values

---@class ElementLogicChance._values : MissionScriptElement._values
---@field chance number

---@class ElementWaypoint._values : MissionScriptElement._values
---@field only_in_civilian boolean
---@field only_on_instigator boolean
---@field icon string
---@field text_id string

---@class ElementTimer : MissionScriptElement
---@field super MissionScriptElement
---@field _timer number

---@class ElementSpecialObjective._values : MissionScriptElement._values
---@field so_action string

---@class ElementSpecialObjective : MissionScriptElement
---@field super MissionScriptElement
---@field _values ElementSpecialObjective._values

---@class ElementExperience._values : MissionScriptElement._values
---@field amount number

---@class ElementJobValue._values : MissionScriptElement._values
---@field value number
---@field key string
---@field save boolean

---@class MissionScriptElement._values
---@field amount number `ElementCounter` | `ElementCounterOperator`
---@field enabled boolean
---@field position Vector3
---@field rotation Rotation

---@class MissionScriptElement
---@field _id number
---@field _editor_name string
---@field counter_value fun(self: self): number `ElementCounter`
---@field enabled fun(self: self): boolean
---@field value fun(self: self, value: string): any
---@field id fun(self: self): number
---@field editor_name fun(self: self): string
---@field on_executed function
---@field _is_inside fun(self: self, position: Vector3): boolean `ElementAreaReportTrigger `
---@field _values_ok fun(self: self): boolean `ElementStopwatchFilter`
---@field _values MissionScriptElement._values
---@field _calc_base_delay fun(self: self): number
---@field _calc_element_delay fun(self: self, params: table): number
---@field _timer number `ElementTimerOperator`

---@class MissionScript
---@field element fun(self: self, id: number): MissionScriptElement?

---@param color string
---@param opacity number?
function BaseInteractionExt:set_contour(color, opacity)
end

---@class BlackMarketManager
---@field equipped_grenade fun(self: self): string
---@field equipped_grenade_allows_pickups fun(self: self): boolean
---@field equipped_mask fun(self: self): { mask_id: string }
---@field equipped_melee_weapon fun(self: self): string
---@field equipped_primary fun(self: self): EquippedWeaponData
---@field equipped_player_style fun(self: self): string
---@field equipped_secondary fun(self: self): EquippedWeaponData
---@field equipped_suit_variation fun(self: self): string
---@field get_suspicion_offset_of_local fun(self: self, lerp: number, ignore_armor_kit: boolean?): number
---@field outfit_string fun(self: self): table

---@class CoreEnvironmentControllerManager
---@field _current_flashbang number

---@class ControllerWrapper
---@field add_trigger fun(self: self, connection_name: string, func: function)
---@field enable fun(self: self)
---@field destroy fun(self: self)
---@field get_input_axis fun(self: self, connection_name: string): Vector3
---@field get_input_bool fun(self: self, connection_name: string): boolean
---@field get_input_pressed fun(self: self, connection_name: string): boolean

---@class ControllerManager
---@field create_controller fun(self: self, name: string, index: number?, debug: boolean?, prio: number?): ControllerWrapper
---@field get_settings fun(self: self, wrapper_type: string): unknown

---@class CoroutineManager
---@field _buffer table

---@class CrimeSpreeManager
---@field is_active fun(self: self): boolean

---@class CustomSafehouseManager
---@field get_daily_challenge fun(self: self): CustomSafehouseManager._global.daily
---@field is_trophy_unlocked fun(self: self, id: string): boolean
---@field uno_achievement_challenge fun(self: self): UnoAchievementChallenge

---@class CustomSafehouseManager._global.daily
---@field id string
---@field state "unstarted"|"seen"|"accepted"|"completed"|"rewarded"
---@field trophy table

---@class EnvironmentEffectsManager
---@field _mission_effects table<number, boolean>

---@class GuiDataManager
---@field create_fullscreen_workspace fun(self: self): Workspace
---@field create_fullscreen_16_9_workspace fun(self: self): Workspace 16:9
---@field destroy_workspace fun(self: self, ws: Workspace)
---@field layout_fullscreen_workspace fun(self: self, ws: Workspace)
---@field safe_to_full fun(self: self, in_x: number, in_y: number): number, number
---@field safe_to_full_16_9 fun(self: self, in_x: number, in_y: number): number, number
---@field full_to_safe fun(self: self, in_x: number, in_y: number): number, number
---@field full_scaled_size fun(self: self): { x: number, y: number, w: number, h: number }

---@class GrenadeCrateInteractionExt : UseInteractionExt
---@field _unit UnitGrenadeDeployable

---@class GroupAIManager
---@field state fun(self: self): GroupAIStateBase

---@class ChallengeManager
---@field can_progress_challenges fun(self: self): boolean
---@field get_active_challenge fun(self: self, id: string, key: string?): table?
---@field get_all_active_challenges fun(self: self): table<string, ChallengeManager.get_all_active_challenges?>
---@field get_challenge fun(self: self, id: string, key: string?): table?
---@field has_active_challenges fun(self: self, id: string, key: string?): boolean

---@class ChallengeManager.get_all_active_challenges
---@field completed boolean
---@field id string

---@class ChatManager
---@field _receive_message fun(self: self, channel_id: number, name: string, message: string, color: Color, icon: string?)

---@class GameState
---@field at_enter fun(self: self, previous_state: self)
---@field at_exit fun(self: self, next_state: self)
---@field name fun(self: self): string

---@class IngameWaitingForPlayersState : GameState

---@class MissionManager
---@field _scripts table<string, MissionScript> All running scripts in a mission
---@field add_global_event_listener fun(self: self, key: string, event_types: string[], clbk: function)
---@field add_runned_unit_sequence_trigger fun(self: self, unit_id: number, sequence: string, callback: function)
---@field check_mission_filter fun(self: self, value: number): boolean
---@field get_element_by_id fun(self: self, id: number): MissionScriptElement?
---@field get_saved_job_value fun(self: self, key: string): number
---@field remove_global_event_listener fun(self: self, key: string)

---@class MenuManager
---@field _input_enabled boolean
---@field _open_menus table
---@field is_pc_controller fun(self: self): boolean Returns `true` if the game was started by mouse or keyboard

---@class MenuComponentManager
---@field _mission_briefing_gui MissionBriefingGui
---@field post_event fun(self: self, event: string, unique: boolean?)

---@class BaseModifier
---@field _type string
---@field value fun(self: self, id: string): number

---@class MoneyManager
---@field get_secured_bonus_bag_value fun(self: self, carry_id: string, multiplier: number): number

---@class MousePointerManager
---@field convert_fullscreen_16_9_mouse_pos fun(self: self, in_x: number, in_y: number): number, number
---@field get_id fun(self: self): number Creates and returns a new mouse pointer id to use
---@field modified_fullscreen_16_9_mouse_pos fun(self: self): x: number, y: number
---@field set_pointer_image fun(self: self, type: "arrow"|"link"|"hand"|"grab")
---@field use_mouse fun(self: self, params: table, position: number?)
---@field remove_mouse fun(self: self, id: number)

---@class MutatorsManager
---@field are_achievements_disabled fun(self: self): boolean
---@field can_mutators_be_active fun(self: self): boolean
---@field get_experience_reduction fun(self: self): number
---@field is_mutator_active fun(self: self, mutator: table): boolean

---@class NetworkAccountBase
---@field get_stat fun(self: self, key: string): number

---@class NetworkManager
---@field account NetworkAccountBase
---@field add_event_listener fun(self: self, key: string, event_types: string, clbk: function)
---@field session fun(self: self): BaseNetworkSession
---@field remove_event_listener fun(self: self, key: string)

---@class PerpetualEventManager
---@field get_holiday_tactics fun(self: self): string

---@class SavefileManager
---@field add_load_done_callback fun(self: self, callback_func: function)
---@field add_load_sequence_done_callback_handler fun(self: self, callback_func: function)

---@class SkirmishManager
---@field current_wave_number fun(self: self): number

---@class SlotMask
---@operator add(self): self
---@operator add(number): self

---@class SlotManager
---@field get_mask fun(self: self, ...: string): SlotMask

---@class UnoAchievementChallenge
---@field challenge fun(self: self): string[]?
---@field challenge_completed fun(self: self): boolean

---@class ViewportManager
---@field add_resolution_changed_func fun(self: self, func: function): function
---@field get_current_camera fun(self: self): Camera
---@field remove_resolution_changed_func fun(self: self, func: function)

---@class WeaponFactoryManager
---@field get_ammo_data_from_weapon fun(self: self, factory_id: string, blueprint: table): table?

---@class managers Global table of all managers in the game
---@field assets MissionAssetsManager
---@field blackmarket BlackMarketManager
---@field controller ControllerManager
---@field criminals CriminalsManager
---@field crime_spree CrimeSpreeManager
---@field custom_safehouse CustomSafehouseManager
---@field ehi_manager EHIManager
---@field ehi_tracker EHITrackerManager
---@field ehi_waypoint EHIWaypointManager
---@field ehi_buff EHIBuffManager
---@field ehi_trade EHITradeManager
---@field ehi_escape EHIEscapeChanceManager
---@field ehi_deployable EHIDeployableManager
---@field ehi_assault EHIAssaultManager
---@field ehi_experience EHIExperienceManager
---@field ehi_unlockable EHIUnlockableManager
---@field ehi_phalanx EHIPhalanxManager
---@field ehi_timer EHITimerManager
---@field ehi_loot EHILootManager
---@field ehi_sync EHISyncManager
---@field ehi_hook EHIHookManager
---@field enemy EnemyManager
---@field environment_controller CoreEnvironmentControllerManager
---@field environment_effects EnvironmentEffectsManager
---@field experience ExperienceManager
---@field gage_assignment GageAssignmentManager
---@field game_play_central GamePlayCentralManager
---@field groupai GroupAIManager
---@field gui_data GuiDataManager
---@field hud HUDManager
---@field challenge ChallengeManager
---@field chat ChatManager
---@field interaction ObjectInteractionManager
---@field job JobManager
---@field menu MenuManager
---@field menu_component MenuComponentManager
---@field mission MissionManager
---@field modifiers ModifiersManager
---@field money MoneyManager
---@field mouse_pointer MousePointerManager
---@field mutators MutatorsManager
---@field network NetworkManager
---@field localization LocalizationManager
---@field loot LootManager
---@field perpetual_event PerpetualEventManager
---@field player PlayerManager
---@field preplanning PrePlanningManager
---@field savefile SavefileManager
---@field skirmish SkirmishManager
---@field slot SlotManager
---@field statistics StatisticsManager
---@field trade TradeManager
---@field viewport ViewportManager
---@field weapon_factory WeaponFactoryManager
---@field worlddefinition WorldDefinition
---@field world_instance CoreWorldInstanceManager

---@class BlackMarketTweakData
---@field melee_weapons { [string]: { attack_allowed_expire_t: number?, stats: { charge_time: number }, type: string } }

---@class CharacterTweakData._string_.Enemy : table
---@field has_alarm_pager boolean

---@class CharacterTweakData._string_.Civilian : table
---@field intimidateable boolean
---@field is_escort boolean
---@field no_civ_penalty boolean

---@class CharacterTweakData
---@field [string] CharacterTweakData._string_.Enemy|CharacterTweakData._string_.Civilian

---@class tweak_data.criminals
---@field characters tweak_data.criminals.characters[]
---@field character_names string[]

---@class tweak_data.criminals.characters
---@field name string
---@field order number
---@field static_data { voice: string, ai_mask_id: string, ai_character_id: string, ssuffix: string }
---@field body_g_object Idstring

---@class tweak_data.projectiles
---@field [string] table?

---@class tweak_data Global table of all configuration data
---@field achievement AchievementsTweakData
---@field blackmarket BlackMarketTweakData
---@field carry CarryTweakData
---@field character CharacterTweakData
---@field criminals tweak_data.criminals
---@field dot DOTTweakData
---@field ehi EHITweakData
---@field experience_manager table
---@field gage_assignment GageAssignmentTweakData
---@field gui GuiTweakData
---@field group_ai GroupAITweakData
---@field hud_icons HudIconsTweakData
---@field levels LevelsTweakData
---@field menu MenuTweakData
---@field mutators table
---@field player PlayerTweakData
---@field preplanning PrePlanningTweakData
---@field projectiles tweak_data.projectiles
---@field skirmish SkirmishTweakData
---@field upgrades UpgradesTweakData

---@class TimerManager
---@field time fun(self: self): number

---@class Global.game_settings
---@field difficulty string
---@field gamemode string
---@field level_id string
---@field single_player boolean
---@field team_ai boolean

---@class Global.statistics_manager
---@field playing_from_start boolean

---@class Global
---@field achievment_manager table
---@field block_update_outfit_information boolean
---@field editor_mode boolean Only in `Beardlib Editor`
---@field load_level boolean
---@field hud_disabled boolean
---@field game_settings Global.game_settings
---@field mission_manager table
---@field statistics_manager Global.statistics_manager
---@field wallet_panel Panel?

---@class Gui
---@field create_world_workspace fun(self: self, w: number, h: number, x: Vector3, y: Vector3, z: Vector3): Workspace
---@field destroy_workspace fun(self: self, ws: Workspace)

---@class World
---@field newgui fun(self: self): Gui

---@class _G Global
---@field Global Global
---@field World World
---@field managers managers Global table of all managers in the game
---@field tweak_data tweak_data Global table of all configuration data
---@field PrintTableDeep fun(tbl: table, maxDepth: integer?, allowLogHeavyTables: boolean?, customNameForInitialLog: string?, tablesToIgnore: table|string?, skipFunctions: boolean?) Recursively prints tables; depends on mod: https://modworkshop.net/mod/34161
---@field PrintTable fun(tbl: table) Prints tables, provided by SuperBLT

---@class mathlib
---@field round fun(n: number, precision: number?): number Rounds number with precision
---@field clamp fun(number: number, min: number, max: number): number Returns `number` clamped to the inclusive range of `min` and `max`
---@field rand fun(a: number, b: number?): number If `b` is provided, returns random number between `a` and `b`. Otherwise returns number between `0` and `a`
---@field mod fun(n: number, div: number): number Returns remainder of a division
---@field within fun(x: number, min: number, max: number): boolean Returns `true` or `false` if `x` is within (inclusive) `min` and `max`

---Linearly interpolates between `a` and `b` by `lerp`
---@generic T
---@param a T
---@param b T
---@param lerp number
---@return T
function math.lerp(a, b, lerp)
end

---@class tablelib
---@field size fun(tbl: table): number Returns number of elements in the table
---@field count fun(v: table, func: fun(item: any, key: any): boolean): number
---@field contains fun(v: table, e: any): boolean Returns `true` or `false` if `e` value exists in the table
---@field index_of fun(v: table, e: string): integer Returns `index` of the element when found, otherwise `-1` is returned
---@field get_vector_index fun(v: table, e: any): number?
---@field empty fun(v: table): boolean
---@field has fun(v: table, k: any): boolean Returns `true` or `false` if `k` key exists in the table
---@field delete fun(v: table, e: any) `v` is expected as list

---Maps values as keys with value `true`
---@generic K
---@param list K[]
---@return table<K, true>
function table.list_to_set(list)
end

---Returns `key name` if value exists
---@generic K, V
---@param map table<K, V>
---@param wanted_key_value V
---@return K?
function table.get_key(map, wanted_key_value)
end

---Returns random value from a list
---@generic T
---@param t T[]
---@return T
function table.random(t)
end

---@generic K, V
---@param t table<K, V>
---@return K
function table.random_key(t)
end

---@class string
---@field key fun(self: self): string Returns Idstring

---@class ContourExt
---@field _contour_list table?

---@class InteractionExt
---@field tweak_data string
---@field active fun(self: self): boolean
---@field interact_position fun(self: self): Vector3

---@class PlayerBase
---@field is_local_player boolean
---@field upgrade_value fun(self: self, category: string, upgrade: string): any|table|number|boolean

---@class HuskPlayerBase : PlayerBase

---@class PlayerInventory
---@field equipped_unit fun(self: self): UnitWeapon

---@class HuskPlayerInventory : PlayerInventory

---@class HuskPlayerMovement
---@field current_state fun(self: self): self
---@field m_head_pos fun(self: self): Vector3
---@field m_head_rot fun(self: self): Rotation

---@class PlayerStandard
---@field _state_data PlayerStandard._state_data

---@class PlayerStandard._state_data
---@field in_steelsight boolean

---@class CopBase : UnitBase
---@field _unit UnitEnemy
---@field _tweak_table string
---@field has_tag fun(self: self, tag: string): boolean

---@class HuskCopBase : CopBase

---@class CopBrain
---@field _logic_data table
---@field converted fun(self: self): boolean
---@field is_hostage fun(self: self): boolean

---@class HuskCopBrain
---@field converted fun(self: self): boolean
---@field is_hostage fun(self: self): boolean
---@field sync_converted fun(self: self): boolean

---@class CopDamage
---@field _all_event_types string[]
---@field _health number
---@field _HEALTH_INIT number
---@field _health_max number
---@field _ON_STUN_ACCURACY_DECREASE number
---@field _ON_STUN_ACCURACY_DECREASE_TIME number
---@field _unit UnitEnemy
---@field add_listener fun(self: self, key: string, events: string|string[]?, clbk: function) Adds listener to the unit itself
---@field dead fun(self: self): boolean
---@field health_ratio fun(self: self): number
---@field immortal boolean
---@field is_civilian fun(type: string): boolean
---@field register_listener fun(key: string, event_types: string|string[], clbk: function) Adds listener to all units
---@field remove_listener fun(self: self, key: string)
---@field unregister_listener fun(key: string)

---@class HuskCopDamage : CopDamage

---@class CopMovement
---@field m_head_pos fun(self: self): Vector3

---@class HuskCopMovement : CopMovement

---@class CivilianBase : CopBase
---@field _unit UnitCivilian
---@field unintimidateable boolean

---@class HuskCivilianBase : HuskCopBase
---@field _unit UnitCivilian
---@field unintimidateable boolean

---@class CivilianDamage : CopDamage
---@field _unit UnitCivilian

---@class HuskCivilianDamage : HuskCopDamage
---@field _unit UnitCivilian

---@class HuskTeamAIBase : HuskCopBase
---@field _unit UnitTeamAI

---@class C_Vehicle
---@field velocity fun(self: self): Vector3

---@class RaycastWeaponBase
---@field selection_index fun(self: self): number

---@class C_UnitOOBB
---@field center fun(self: self): number
---@field size fun(self: self): { x: number, y: number, z: number }
---@field x fun(self: self): number
---@field y fun(self: self): number
---@field z fun(self: self): number

---@class Unit
---@field alive fun(): boolean
---@field editor_id fun(): number
---@field get_object fun(self: self, name: Idstring): U_Object
---@field key fun(): string
---@field material_config fun(): Idstring
---@field name fun(): Idstring Returns name as a path to the unit; Example: `units/payday2/equipment/gen_equipment_grenade_crate/gen_equipment_explosives_case`
---@field parent fun(): UnitBase?
---@field position fun(self: self): Vector3
---@field rotation fun(self: self): Rotation
---@field oobb fun(self: self): C_UnitOOBB Object Oriented Bounding Box
---@field set_extension_update_enabled fun(self: self, class_name: Idstring, state: boolean)

---@class UnitBase : Unit
---@field add_destroy_listener fun(self: self, key: string, clbk: fun(unit: Unit))
---@field damage fun(): UnitDamage
---@field in_slot fun(self: self, slotmask: number): boolean
---@field remove_destroy_listener fun(self: self, key: string)

---@class UnitDamage
---@field _variables table
---@field _state table

---@class UnitCarry : UnitBase
---@field carry_data fun(): CarryData
---@field interaction fun(): UseInteractionExt

---@class UnitTimer : UnitBase
---@field base fun(): Drill
---@field timer_gui fun(): TimerGui
---@field interaction fun(): InteractionExt
---@field mission_door_device fun(): MissionDoorDevice?

---@class UnitDigitalTimer : UnitBase
---@field digital_gui fun(): DigitalGui

---@class UnitPlayer : UnitBase
---@field base fun(): PlayerBase|HuskPlayerBase
---@field character_damage fun(): PlayerDamage|HuskPlayerDamage
---@field inventory fun(): PlayerInventory|HuskPlayerInventory
---@field movement fun(): PlayerMovement|HuskPlayerMovement

---@class UnitTeamAI : UnitBase
---@field base fun(): TeamAIBase|HuskTeamAIBase

---@class UnitEnemy : UnitBase
---@field base fun(): CopBase|HuskCopBase
---@field brain fun(): CopBrain|HuskCopBrain
---@field contour fun(): ContourExt
---@field character_damage fun(): CopDamage|HuskCopDamage
---@field movement fun(): CopMovement|HuskCopMovement

---@class UnitCivilian : UnitEnemy
---@field base fun(): CivilianBase|HuskCivilianBase
---@field character_damage fun(): CivilianDamage|HuskCivilianDamage

---@class UnitVehicle : UnitBase
---@field vehicle fun(): C_Vehicle C++ method

---@class UnitWithInteraction : UnitBase
---@field interaction fun(): InteractionExt

---@class UnitWeapon : UnitBase
---@field base fun(): RaycastWeaponBase

---@class UnitZipline : UnitBase
---@field zipline fun(): ZipLine

---@class UnitDeployable : UnitBase
---@field SetCountThisUnit fun(self: self) EHI added function
---@field SetIgnoreChild fun(self: self) EHI added function

---@class UnitAmmoDeployable : UnitDeployable
---@field base fun(): AmmoBagBase
---@field interaction fun(): AmmoBagInteractionExt

---@class UnitGrenadeDeployable : UnitDeployable
---@field base fun(): GrenadeCrateBase
---@field interaction fun(): GrenadeCrateInteractionExt

---@class UnitECM : UnitBase
---@field base fun(): ECMJammerBase

---@class UnitFAKDeployable : UnitDeployable
---@field base fun(): FirstAidKitBase

---@class U_Object : UnitBase

---@class U_Material
---@field set_variable fun(self: self, material_name: Idstring, value: any)

---@class LocalizationManager
---@field btn_macro fun(self: self, button: string, to_upper: boolean?, nil_if_empty: boolean?): string
---@field get_default_macro fun(self: self, macro: string): string
---@field exists fun(self: self, string_id: string): boolean SuperBLT only
---@field text fun(self: self, string_id: string, macros: table?): string
---@field to_upper_text fun(self: self, string_id: string, macros: table?): string

---@class Workspace
---@field show fun(self: self)
---@field hide fun(self: self)
---@field panel fun(self: self): Panel
---@field connect_keyboard fun(self: self, keyboard: userdata)
---@field world_to_screen fun(self: self, cam: Camera, pos: Vector3): Vector3

---@class PanelBaseObject
---@field x fun(self: self): number
---@field set_x fun(self: self, x: number)
---@field y fun(self: self): number
---@field set_y fun(self: self, y: number)
---@field w fun(self: self): number
---@field set_w fun(self: self, w: number)
---@field h fun(self: self): number
---@field set_h fun(self: self, h: number)
---@field top fun(self: self): number Returns `y`
---@field set_top fun(self: self, top: number)
---@field bottom fun(self: self): number Returns `y + h`
---@field set_bottom fun(self: self, bottom: number)
---@field left fun(self: self): number Returns `x`
---@field set_left fun(self: self, left: number)
---@field right fun(self: self): number Returns `x + w`
---@field set_right fun(self: self, right: number)
---@field center fun(self: self): x: number, y: number
---@field set_center fun(self: self, x: number, y: number)
---@field center_x fun(self: self): number
---@field set_center_x fun(self: self, center_x: number)
---@field center_y fun(self: self): number
---@field set_center_y fun(self: self, center_y: number)
---@field set_position fun(self: self, x: number, y: number)
---@field set_leftbottom fun(self: self, left: number, bottom: number)
---@field set_righttop fun(self: self, right: number, top: number)
---@field set_rightbottom fun(self: self, right: number, bottom: number)
---@field alpha fun(self: self) : number
---@field set_alpha fun(self: self, alpha: number)
---@field stop fun(self: self, anim_thread: thread?) If `anim_thread` is not provided, the function stops all current active animations
---@field animate fun(self: self, f: fun(o: self, ...: any?), ...:any?): thread
---@field set_size fun(self: self, w: number, h: number)
---@field size fun(self: self): w: number, h: number
---@field visible fun(self: self): boolean
---@field set_visible fun(self: self, visible: boolean)
---@field parent fun(self: self): Panel
---@field color fun(self: self): Color
---@field set_color fun(self: self, color: Color)
---@field inside fun(self: self, x: number, y: number): boolean Returns `true` or `false` if provided `x` and `y` are inside the object
---@field shape fun(self: self): x: number, y: number, w: number, h: number
---@field set_shape fun(self: self, x: number, y: number, w: number, h: number)
---@field set_blend_mode fun(self: self, mode: "add"|"normal")
---@field show fun(self: self)
---@field hide fun(self: self)
---@field name fun(self: self): string

---@class PanelBaseObject_Params
---@field name string
---@field layer integer
---@field x number
---@field y number
---@field w number
---@field h number
---@field visible boolean

---@class PanelText_Params : PanelBaseObject_Params
---@field align "center"|"right"|"left"
---@field blend_mode "normal"|"add"
---@field text string
---@field font_size number
---@field font string Idstring
---@field color Color
---@field vertical "center"|"top"
---@field wrap boolean
---@field word_wrap boolean

---@class PanelBitmap_Params : PanelBaseObject_Params
---@field texture string
---@field text_rect number[]
---@field render_template "VertexColorTexturedRadial"|"VertexColorTexturedBlur3D"
---@field color Color
---@field rotation number In degrees
---@field alpha number
---@field blend_mode "add"|"normal"

---@class PanelRectangle_Params : PanelBaseObject_Params
---@field alpha number
---@field blend_mode "normal"|"add"
---@field halign "grow"|"left"|"right"
---@field valign "grow"|"top"|"bottom"
---@field color Color

---@class Panel_Params : PanelBaseObject_Params
---@field alpha number
---@field rotation number In degrees

---@class Panel : PanelBaseObject
---@field color nil Does not exist in Panel
---@field set_color nil Does not exist in Panel
---@field child fun(self: self, child_name: string): PanelBaseObject?
---@field remove fun(self: self, child_name: PanelBaseObject)
---@field text fun(self: self, params: PanelText_Params): PanelText
---@field bitmap fun(self: self, params: PanelBitmap_Params): PanelBitmap
---@field rect fun(self: self, params: PanelRectangle_Params): PanelRectangle
---@field panel fun(self: self, params: Panel_Params): self
---@field children fun(self: self): PanelBaseObject[] Returns an ipairs table of all items created on the panel
---@field clear fun(self: self) Removes all children in the panel

---@class PanelText : PanelBaseObject
---@field set_text fun(self: self, text: string)
---@field text_rect fun(self: self): x: number, y: number, w: number, h: number Returns rectangle of the text
---@field font_size fun(self: self): number
---@field set_font fun(self: self, font: Idstring)
---@field set_font_size fun(self: self, font_size: number)
---@field text fun(self: self): string

---@class PanelBitmap : PanelBaseObject
---@field set_image fun(self: self, texture_path: string, texture_rect_x: number?, texture_rect_y: number?, texture_rect_w: number?, texture_rect_h: number?)
---@field set_texture_rect fun(self: self, x: number, y: number, w: number, h: number)

---@class PanelRectangle : PanelBaseObject

---@class Waypoint
---@field init_data WaypointInitData
---@field bitmap PanelBitmap
---@field bitmap_world PanelBitmap VR only
---@field timer_gui PanelText
---@field distance PanelText
---@field arrow PanelBitmap
---@field position Vector3
---@field size Vector3

---@class WaypointInitData
---@field distance boolean
---@field present_timer number
---@field position Vector3
---@field text string
---@field icon string
---@field state "dirty"|"sneak_present"|"present_ended"|"present"|"offscreen"|"onscreen"?

---@class EquippedWeaponData
---@field blueprint table
---@field factory_id string
---@field weapon_id string