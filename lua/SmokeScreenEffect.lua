if EHI:CheckLoadHook("SmokeScreenEffect") then
    return
end
local show_tracker, show_waypoint = EHI:GetShowTrackerAndWaypoint("show_mission_trackers", "show_waypoints_mission")
local buffs = EHI:GetBuffAndBuffDeckOption("sicario", "smoke_bomb")
local original_init = SmokeScreenEffect.init
---@param position Vector3
---@param normal number math.UP
---@param time number
---@param has_dodge_bonus boolean
---@param grenade_unit Unit?
function SmokeScreenEffect:init(position, normal, time, has_dodge_bonus, grenade_unit, ...)
    original_init(self, position, normal, time, has_dodge_bonus, grenade_unit, ...)
    local key, color_id
    if grenade_unit and alive(grenade_unit:base():thrower_unit()) then
        local thrower = grenade_unit:base():thrower_unit()
        key = self._mine and "Mine" or tostring(thrower:key())
        color_id = managers.criminals:character_color_id_by_unit(thrower)
    else
        key = "ThrowerUnitInCustody_" .. TimerManager:game():time()
        color_id = #tweak_data.chat_colors
    end
    local id = "SmokeScreenGrenade_" .. key
    if show_tracker and managers.ehi_tracker:CallFunction2(id, "SetTime", time) then
        managers.ehi_tracker:AddTracker({
            id = id,
            time = time,
            icons = {
                {
                    icon = "smoke",
                    peer_id = color_id or 0
                }
            },
            hint = "sicario_smoke_bomb"
        })
    end
    if show_waypoint and managers.ehi_waypoint:CallFunction2(id, "SetTime", time) then
        managers.ehi_waypoint:AddWaypoint(id, {
            time = time,
            icon = "smoke",
            position = position,
            color = tweak_data.chat_colors[color_id or 0]
        })
    end
    if self._mine and buffs then
        managers.ehi_buff:AddBuff("smoke_screen_grenade", time)
    end
end