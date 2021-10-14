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
    }
}