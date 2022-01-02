if not Global.load_level then
    return
end

if EHI._hooks.CriminalsManager then
    return
else
    EHI._hooks.CriminalsManager = true
end

if EHI:IsXPTrackerDisabled() then
    return
end

local original =
{
    add_character = CriminalsManager.add_character,
    set_unit = CriminalsManager.set_unit
}

if BB and BB.grace_period and Global.game_settings.single_player and Global.game_settings.team_ai then
    function CriminalsManager:add_character(name, unit, peer_id, ai, ai_loadout, ...)
        original.add_character(self, name, unit,peer_id, ai, ai_loadout, ...)
        local character = self:character_by_name(name)
        if character and unit and not unit:base().is_local_player then
            managers.experience:IncreaseAlivePlayers()
        end
    end

    function CriminalsManager:set_unit(name, unit, ai_loadout, ...)
        original.set_unit(self, name, unit, ai_loadout, ...)
        local character = self:character_by_name(name)
        if character and character.taken and character.data.ai and not unit:base().is_local_player then
            managers.experience:IncreaseAlivePlayers()
        end
    end

    original._remove = CriminalsManager._remove
    function CriminalsManager:_remove(id, ...)
        local char_data = self._characters[id]
        if char_data.data.ai then
            managers.experience:DecreaseAlivePlayers()
        end
        original._remove(self, id, ...)
    end
    return
elseif not Global.game_settings.single_player then
    local function Query(...)
        managers.experience:QueryAmountOfAlivePlayers()
    end
    EHI:Hook(CriminalsManager, "add_character", Query)
    EHI:Hook(CriminalsManager, "set_unit", Query)
    EHI:Hook(CriminalsManager, "on_peer_left", Query)
end