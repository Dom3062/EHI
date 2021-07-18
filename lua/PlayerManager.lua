if EHI._hooks.PlayerManager then
	return
else
	EHI._hooks.PlayerManager = true
end

local original =
{
    spawn_smoke_screen = PlayerManager.spawn_smoke_screen
}

if EHI:GetOption("show_gained_xp") and Global.game_settings and Global.game_settings.gamemode and Global.game_settings.gamemode ~= "crime_spree" and Global.load_level then
    function PlayerManager:SetInfamyBonus()
        managers.experience:SetInfamyBonus(math.max(0, self:get_infamy_exp_multiplier() - 1))
    end
end

function PlayerManager:spawn_smoke_screen(position, normal, grenade_unit, ...)
    original.spawn_smoke_screen(self, position, normal, grenade_unit, ...)
    if grenade_unit:base():thrower_unit() then
        local key, color_id
        if alive(grenade_unit:base():thrower_unit()) then
            key = tostring(grenade_unit:base():thrower_unit():key())
            color_id = managers.criminals:character_color_id_by_unit(grenade_unit:base():thrower_unit())
        else
            key = "ThrowerUnitInCustody_" .. TimerManager:game():time()
            color_id = #tweak_data.chat_colors
        end
	    local color = tweak_data.chat_colors[color_id] or Color.white
        managers.ehi:AddTracker({
            id = "SmokeScreenGrenade_" .. key,
            time = tweak_data.projectiles.smoke_screen_grenade.duration,
            icons = {
                {
                    icon = "smoke",
                    color = color
                }
            }
        })
    end
end