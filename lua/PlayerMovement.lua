if EHI:CheckLoadHook("PlayerMovement") or not EHI:GetOption("show_buffs") then
    return
end

local original =
{
    init = PlayerMovement.init
}
PlayerMovement.__ehi_inspire_basic = EHI:GetBuffOption("inspire_basic") --[[@as boolean]]
function PlayerMovement:init(...)
    original.init(self, ...)
    managers.ehi_buff:CallFunction("Stamina", "Spawned", self._stamina)
    if self.__ehi_inspire_basic and self._rally_skill_data and self._rally_skill_data.morale_boost_delay_t then
        local _t = self._rally_skill_data
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
        self._rally_skill_data = setmetatable({}, _mt)
    end
end

if (EHI:GetBuffOption("inspire_reload") or EHI:GetBuffOption("inspire_movement")) and not Global.game_settings.single_player then
    original.on_morale_boost = PlayerMovement.on_morale_boost
    function PlayerMovement:on_morale_boost(...)
        original.on_morale_boost(self, ...)
        local t = tweak_data.upgrades.morale_boost_time
        managers.ehi_buff:AddBuff("morale_boost_reload", t)
        managers.ehi_buff:AddBuff("morale_boost_movement", t)
    end
end

if EHI:GetBuffOption("stamina") then
    original._max_stamina = PlayerMovement._max_stamina
    function PlayerMovement:_max_stamina(...)
        local max_stamina = original._max_stamina(self, ...)
        managers.ehi_buff:CallFunction("Stamina", "SetMaxStamina", max_stamina)
        return max_stamina
    end
    original._change_stamina = PlayerMovement._change_stamina
    function PlayerMovement:_change_stamina(...)
        original._change_stamina(self, ...)
        managers.ehi_buff:AddGauge("Stamina", self._stamina)
    end
end