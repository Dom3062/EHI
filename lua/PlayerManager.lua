if EHI._hooks.PlayerManager then
	return
else
	EHI._hooks.PlayerManager = true
end

local _f_spawn_smoke_screen = PlayerManager.spawn_smoke_screen
function PlayerManager:spawn_smoke_screen(position, normal, grenade_unit, has_dodge_bonus)
    _f_spawn_smoke_screen(self, position, normal, grenade_unit, has_dodge_bonus)
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