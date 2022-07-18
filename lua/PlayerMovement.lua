local EHI = EHI

if EHI._hooks.PlayerMovement then
    return
else
    EHI._hooks.PlayerMovement = true
end

if not EHI:GetOption("show_buffs") then
    return
end

local original =
{
    init = PlayerMovement.init
}

function PlayerMovement:init(unit, ...)
    original.init(self, unit, ...)
    if self._rally_skill_data and self._rally_skill_data.morale_boost_delay_t then
        local _t = self._rally_skill_data
        self._rally_skill_data = {}
        local _mt = {
            __index = function(table, key)
                return _t[key]
            end,
            __newindex = function(table, key, value)
                _t[key] = value
                if key == "morale_boost_delay_t" then
                    local t = value - managers.player:player_timer():time()
                    managers.ehi_buff:AddBuff("morale_boost", t)
                end
            end
        }
        setmetatable(self._rally_skill_data, _mt)
    end
end