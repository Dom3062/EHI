local EHI = EHI
if EHI:CheckLoadHook("CriminalsManager") or EHI:IsXPTrackerHidden() then
    return
end

---@class CriminalsManager_CharacterData
---@field taken boolean
---@field data { ai: boolean }

---@class CriminalsManager
---@field _characters CriminalsManager_CharacterData[]
---@field character_by_name fun(self: self, name: string): CriminalsManager_CharacterData?
---@field character_color_id_by_unit fun(self: self, unit: UnitPlayer|UnitTeamAI): number?
---@field character_peer_id_by_unit fun(self: self, unit: UnitPlayer|UnitTeamAI): number?

if EHI:IsRunningBB() then
    EHI:HookWithID(CriminalsManager, "add_character", "EHI_CriminalsManager_add_character",
    ---@param self CriminalsManager
    ---@param name string
    function(self, name)
        local character = self:character_by_name(name)
        if character and character.taken and character.data.ai then
            managers.ehi_experience:IncreaseAlivePlayers()
        end
    end)
    EHI:HookWithID(CriminalsManager, "set_unit", "EHI_CriminalsManager_set_unit",
    ---@param self CriminalsManager
    ---@param name string
    ---@param unit UnitPlayer|UnitTeamAI
    function(self, name, unit)
        local character = self:character_by_name(name)
        if character and character.taken and character.data.ai and not unit:base().is_local_player then
            managers.ehi_experience:IncreaseAlivePlayers()
        end
    end)
    EHI:PreHookWithID(CriminalsManager, "_remove", "EHI_CriminalsManager_remove",
    ---@param self CriminalsManager
    ---@param id number
    function(self, id)
        local char_data = self._characters[id]
        if char_data.data.ai then
            managers.ehi_experience:DecreaseAlivePlayers()
        end
    end)
elseif EHI:IsRunningUsefulBots() then
    local function Query(...)
        managers.ehi_experience:QueryAmountOfAllPlayers()
    end
    EHI:Hook(CriminalsManager, "add_character", Query)
    EHI:Hook(CriminalsManager, "set_unit", Query)
    EHI:Hook(CriminalsManager, "on_peer_left", Query)
    EHI:Hook(CriminalsManager, "_remove", Query)
elseif not Global.game_settings.single_player then
    local Query
    if EHI:IsRunningUsefulBots() then
        Query = function(...)
            managers.ehi_experience:QueryAmountOfAllPlayers()
        end
        EHI:Hook(CriminalsManager, "_remove", Query)
    else
        Query = function(...)
            managers.ehi_experience:QueryAmountOfAlivePlayers()
        end
    end
    EHI:Hook(CriminalsManager, "add_character", Query)
    EHI:Hook(CriminalsManager, "set_unit", Query)
    EHI:Hook(CriminalsManager, "on_peer_left", Query)
end