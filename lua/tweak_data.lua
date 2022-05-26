local EHI = EHI
if EHI._hooks.tweak_data then
	return
else
	EHI._hooks.tweak_data = true
end

tweak_data.ehi =
{
    color =
    {
        Inaccurate = Color(255, 255, 165, 0) / 255,
        DrillAutorepair = Color(255, 137, 209, 254) / 255
    },
    icons =
    {
        default = { texture = "guis/textures/pd2/pd2_waypoints", texture_rect = {96, 64, 32, 32} },

        faster = { texture = "guis/textures/pd2/skilltree/drillgui_icon_faster" },
        silent = { texture = "guis/textures/pd2/skilltree/drillgui_icon_silent" },
        restarter = { texture = "guis/textures/pd2/skilltree/drillgui_icon_restarter" },
        xp = { texture = "guis/textures/pd2/blackmarket/xp_drop" },

        heli = { texture = "guis/textures/pd2_mod_ehi/heli" },
        mad_scan = { texture = "guis/textures/pd2_mod_ehi/mad_scan" },
        boat = { texture = "guis/textures/pd2_mod_ehi/boat" },
        enemy = { texture = "guis/textures/pd2_mod_ehi/enemy" },
        piggy = { texture = "guis/textures/pd2_mod_ehi/piggy" },
        assaultbox = { texture = "guis/textures/pd2_mod_ehi/assaultbox" },
        deployables = { texture = "guis/textures/pd2_mod_ehi/deployables" },
        padlock = { texture = "guis/textures/pd2_mod_ehi/padlock" },
        arrow_up = { texture = "guis/textures/pd2_mod_ehi/arrow_up" },

        reload = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {0, 576, 64, 64} },
        smoke = { texture = "guis/dlcs/max/textures/pd2/specialization/icons_atlas", texture_rect = {0, 0, 64, 64} },
        teargas = { texture = "guis/dlcs/drm/textures/pd2/crime_spree/modifiers_atlas_2", texture_rect = {128, 256, 128, 128} },
        gage = { texture = "guis/dlcs/gage_pack_jobs/textures/pd2/endscreen/gage_assignment" },
        hostage = { texture = "guis/textures/pd2/hud_icon_hostage" },
        buff_shield = { texture = "guis/textures/pd2/hud_buff_shield" },

        doctor_bag = { texture = "guis/textures/pd2/blackmarket/icons/deployables/outline/doctor_bag" },
        ammo_bag = { texture = "guis/textures/pd2/blackmarket/icons/deployables/outline/ammo_bag" },
        first_aid_kit = { texture = "guis/textures/pd2/blackmarket/icons/deployables/outline/first_aid_kit" },
        bodybags_bag = { texture = "guis/textures/pd2/blackmarket/icons/deployables/outline/bodybags_bag" },
        frag_grenade = { texture = tweak_data.hud_icons.frag_grenade.texture, texture_rect = tweak_data.hud_icons.frag_grenade.texture_rect },

        minion = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {384, 512, 64, 64} },
        heavy = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {192, 64, 64, 64} },
        sniper = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {384, 320, 64, 64} },
        camera_loop = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {256, 128, 64, 64} },
        pager_icon = { texture = "guis/textures/pd2/specialization/icons_atlas", texture_rect = {64, 256, 64, 64} },

        ecm_jammer = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {64, 256, 64, 64} },
        ecm_feedback = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {384, 128, 64, 64} },

        hoxton_character = { texture = "guis/dlcs/trk/textures/pd2/old_hoxton_unlock_icon" }
    },
    -- Definitions for buffs and their icons
    buff =
    {
        DodgeChance =
        {
            u100skill = true,
            x = 1,
            y = 12,
            class = "EHIDodgeChanceTracker",
            activate_after_spawn = true
        },
        Reload =
        {
            skills = true,
            bad = true,
            y = 9
        },
        Interact =
        {
            texture = "guis/textures/pd2/pd2_waypoints",
            texture_rect = {224, 32, 32, 32}
        },
        ArmorRegenDelay =
        {
            skills = true,
            bad = true,
            x = 6,
            y = 4
        },
        MeleeCharge =
        {
            skills = true,
            x = 4,
            y = 12,
            class = "EHIMeleeChargeBuffTracker"
        },
        headshot_regen_armor_bonus =
        {
            skills = true,
            bad = true,
            x = 6,
            y = 11
        },
        combat_medic_damage_multiplier =
        {
            skills = true,
            x = 5,
            y = 7
        },
        berserker_damage_multiplier =
        {
            skills = true,
            x = 5,
            y = 12
        },
        dmg_multiplier_outnumbered =
        {
            skills = true,
            text = "Dmg+",
            x = 2,
            y = 1
        },
        first_aid_damage_reduction =
        {
            skills = true,
            text = "Dmg-",
            x = 1,
            y = 11
        },
        UppersRangeGauge =
        {
            u100skill = true,
            x = 2,
            y = 11,
            check_after_spawn = true,
            class = "EHIUppersRangeTracker"
        },
        fast_learner =
        {
            u100skill = true,
            text = "Dmg-",
            y = 10
        },
        melee_life_leech =
        {
            deck = true,
            bad = true,
            x = 5,
            y = 4
        },
        dmg_dampener_close_contact =
        {
            deck = true,
            x = 5,
            y = 4
        },
        loose_ammo_give_team =
        {
            deck = true,
            bad = true,
            x = 5,
            y = 5
        },
        loose_ammo_restore_health =
        {
            deck = true,
            bad = true,
            x = 4,
            y = 5
        },
        damage_speed_multiplier =
        {
            u100skill = true,
            text = "Mov+",
            x = 10,
            y = 9,
        },
        revived_damage_resist =
        {
            u100skill = true,
            text = "Dmg-",
            x = 11,
            y = 4,
        },
        swap_weapon_faster =
        {
            u100skill = true,
            text = "Spd+",
            x = 11,
            y = 3,
        },
        increased_movement_speed =
        {
            u100skill = true,
            text = "Mov+",
            x = 11,
            y = 3,
        },
        unseen_strike =
        {
            u100skill = true,
            text = "Crit+",
            x = 10,
            y = 11,
        },
        melee_damage_stacking =
        {
            u100skill = true,
            x = 11,
            y = 6,
            format = "percent",
            class = "EHIGaugeBuffTracker"
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
            y = 5
        },
        ManiacStackTicks =
        {
            deck = true,
            folder = "coco"
        },
        ManiacDecayTicks =
        {
            deck = true,
            folder = "coco",
            x = 2
        },
        ManiacAccumulatedStacks =
        {
            deck = true,
            folder = "coco",
            x = 3,
            class = "EHIGaugeBuffTracker",
            format = "percent"
        },
        GrinderStackCooldown =
        {
            deck = true,
            bad = true,
            x = 5,
            y = 6
        },
        GrinderRegenPeriod =
        {
            deck = true,
            x = 5,
            y = 6
        },
        SicarioTwitchGauge =
        {
            deck = true,
            folder = "max",
            x = 1,
            class = "EHIGaugeBuffTracker",
            format = "percent"
        },
        SicarioTwitchCooldown =
        {
            deck = true,
            folder = "max",
            bad = true,
            x = 1
        },
        ammo_efficiency =
        {
            u100skill = true,
            x = 8,
            y = 4
        },
        armor_break_invulnerable =
        {
            deck = true,
            bad = true,
            x = 6,
            y = 1
        },
        single_shot_fast_reload =
        {
            u100skill = true,
            x = 8,
            y = 3
        },
        overkill_damage_multiplier =
        {
            skills = true,
            text = "Dmg+",
            x = 3,
            y = 2
        },
        long_dis_revive =
        {
            u100skill = true,
            bad = true,
            x = 4,
            y = 9
        },
        Immunity =
        {
            deck = true,
            x = 6
        },
        UppersCooldown =
        {
            u100skill = true,
            bad = true,
            x = 2,
            y = 11
        },
        armor_grinding =
        {
            deck = true,
            folder = "opera"
        },
        HealthRegen =
        {
            skills = true,
            x = 2,
            y = 10,
            class = "EHIHostageTakerMuscleRegenBuffTracker"
        },
        BikerBuff =
        {
            deck = true,
            folder = "wild",
            class = "EHIBikerBuffTracker",
            check_after_spawn = true
        },
        chico_injector =
        {
            deck = true,
            folder = "chico"
        },
        SmokeScreen =
        {
            deck = true,
            folder = "max"
        },
        damage_control =
        {
            deck = true,
            folder = "myh",
            class = "EHIStoicTracker"
        },
        damage_control_cooldown =
        {
            deck = true,
            folder = "myh",
            y = 1
        },
        pocket_ecm_kill_dodge =
        {
            deck = true,
            folder = "joy",
            x = 3
        },
        TagTeamEffect =
        {
            deck = true,
            folder = "ecp",
            y = 1
        },
        HackerJammerEffect =
        {
            skills = true,
            x = 6,
            y = 3
        },
        HackerFeedbackEffect =
        {
            skills = true,
            x = 6,
            y = 2
        },
        copr_ability =
        {
            deck = true,
            folder = "copr"
        }
    }
}

tweak_data.ehi.buff.team_crew_inspire = EHI:DeepClone(tweak_data.ehi.buff.long_dis_revive)
tweak_data.ehi.buff.team_crew_inspire.text = "AI"
tweak_data.ehi.buff.reload_weapon_faster = EHI:DeepClone(tweak_data.ehi.buff.swap_weapon_faster)
tweak_data.ehi.buff.reload_weapon_faster.text = "Rld+"
tweak_data.ehi.buff.chico_injector_cooldown = EHI:DeepClone(tweak_data.ehi.buff.chico_injector)
tweak_data.ehi.buff.chico_injector_cooldown.bad = true
tweak_data.ehi.buff.tag_team_cooldown = EHI:DeepClone(tweak_data.ehi.buff.chico_injector_cooldown)
tweak_data.ehi.buff.tag_team_cooldown.folder = "ecp"
tweak_data.ehi.buff.pocket_ecm_jammer_cooldown = EHI:DeepClone(tweak_data.ehi.buff.chico_injector_cooldown)
tweak_data.ehi.buff.pocket_ecm_jammer_cooldown.folder = "joy"
tweak_data.ehi.buff.copr_ability_cooldown = EHI:DeepClone(tweak_data.ehi.buff.chico_injector_cooldown)
tweak_data.ehi.buff.copr_ability_cooldown.folder = "copr"

-- Debug
tweak_data.ehi.buff.debug_1 = EHI:DeepClone(tweak_data.ehi.buff.chico_injector)
tweak_data.ehi.buff.debug_2 = EHI:DeepClone(tweak_data.ehi.buff.pocket_ecm_jammer_cooldown)
tweak_data.ehi.buff.debug_3 = EHI:DeepClone(tweak_data.ehi.buff.chico_injector_cooldown)
tweak_data.ehi.buff.debug_4 = EHI:DeepClone(tweak_data.ehi.buff.team_crew_inspire)

tweak_data.hud_icons.EHI_XP = { texture = tweak_data.ehi.icons.xp.texture }
tweak_data.hud_icons.EHI_Gage = { texture = tweak_data.ehi.icons.gage.texture }
tweak_data.hud_icons.EHI_Boat = { texture = tweak_data.ehi.icons.boat.texture .. "_waypoint", texture_rect = { 0, 0, 32, 32 } }
tweak_data.hud_icons.EHI_Heli = { texture = tweak_data.ehi.icons.heli.texture .. "_waypoint", texture_rect = { 0, 0, 32, 32 } }