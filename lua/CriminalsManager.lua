local EHI = EHI
if EHI:CheckLoadHook("CriminalsManager") then
    return
end

---@class CriminalsManager.CharacterData
---@field taken boolean
---@field data { ai: boolean }

---@class CriminalsManager
---@field _characters CriminalsManager.CharacterData[]
---@field character_by_name fun(self: self, name: string): CriminalsManager.CharacterData?
---@field character_color_id_by_unit fun(self: self, unit: UnitPlayer|UnitTeamAI): number?
---@field character_peer_id_by_name fun(self: self, name: string): number?
---@field character_peer_id_by_unit fun(self: self, unit: UnitPlayer|UnitTeamAI): number?

if EHI:IsRunningBB() then
    Hooks:PostHook(CriminalsManager, "add_character", "EHI_CriminalsManager_add_character", function(self, name) ---@param name string
        local character = self:character_by_name(name)
        if character and character.taken and character.data.ai then
            managers.ehi_experience:IncreaseAlivePlayers()
            managers.ehi_experience:CallRefreshPlayerCountListener()
        end
    end)
    Hooks:PostHook(CriminalsManager, "set_unit", "EHI_CriminalsManager_set_unit",
    ---@param name string
    ---@param unit UnitPlayer|UnitTeamAI
    function(self, name, unit)
        local character = self:character_by_name(name)
        if character and character.taken and character.data.ai and not unit:base().is_local_player then
            managers.ehi_experience:IncreaseAlivePlayers()
            managers.ehi_experience:CallRefreshPlayerCountListener()
        end
    end)
    Hooks:PreHook(CriminalsManager, "_remove", "EHI_CriminalsManager_remove", function(self, id) ---@param id number
        local char_data = self._characters[id]
        if char_data.data.ai then
            managers.ehi_experience:DecreaseAlivePlayers()
            managers.ehi_experience:CallRefreshPlayerCountListener()
        end
    end)
elseif EHI:IsRunningUsefulBots() then
    managers.ehi_experience:SetCriminalsListener(true)
elseif not Global.game_settings.single_player then
    managers.ehi_experience:SetCriminalsListener()
end