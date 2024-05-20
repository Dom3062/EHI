local EHI = EHI
if EHI:CheckLoadHook("NetworkPeer") then
    return
end

if EHI:IsHost() then
    local save = NetworkPeer.save
    function NetworkPeer:save(data, ...)
        save(self, data, ...)
        if self:is_host() then
            local ehi_state = {}
            ehi_state.has_useful_bots = UsefulBots ~= nil
            ehi_state.has_bots_enabled = Global.game_settings.team_ai
            data.ehi_state = ehi_state
        end
    end
else
    local load = NetworkPeer.load
    function NetworkPeer:load(data, ...)
        load(self, data, ...)
        local ehi_state = data.ehi_state
        if ehi_state and ehi_state.has_useful_bots then
            EHI._cache.HostHasUsefulBots = true
            EHI._cache.HostHasBots = ehi_state.has_bots_enabled
            local briefing = managers.menu_component and managers.menu_component._mission_briefing_gui
            if briefing and briefing.RefreshXPOverview then
                briefing:RefreshXPOverview()
            end
            if EHI:IsXPTrackerEnabledAndVisible() then
                managers.ehi_experience:SetAIOnDeathListener()
                managers.ehi_experience:SetCriminalsListener(true)
            end
        end
    end
end