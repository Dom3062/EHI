local EHI = EHI
if EHI:CheckLoadHook("HUDManagerPD2") then
    return
end

local original =
{
    sync_set_assault_mode = HUDManager.sync_set_assault_mode,
    destroy = HUDManager.destroy,
    set_disabled = HUDManager.set_disabled,
    set_enabled = HUDManager.set_enabled,
    sync_start_assault = HUDManager.sync_start_assault,
    sync_end_assault = HUDManager.sync_end_assault
}

Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "EHI_HUDManager_setup_player_info_hud_pd2", function(hud, ...)
    local server = EHI.IsHost
    local panel = hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel
    local trackers = managers.ehi_tracker
    local waypoints = managers.ehi_waypoint
    managers.ehi_assault:init_hud(hud)
    local tracking = managers.ehi_tracking
    local show_mission_triggers = EHI.Mission._SHOW_MISSION_TRIGGERS
    local level_id = Global.game_settings.level_id
    local trackers_visible = EHI:GetOption("show_trackers")
    local waypoints_visible = EHI:GetOption("show_waypoints")
    if waypoints_visible then
        waypoints:SetPlayerHUD(panel, hud._saferect, hud._gui)
    end
    if server or EHI.HeistTimerIsInverted then
        if (trackers_visible and waypoints_visible) or show_mission_triggers then
            hud:AddEHIUpdator("EHITracking_Update", tracking)
        elseif waypoints_visible then
            hud:AddEHIUpdator("EHIWaypoints_Update", waypoints, "update2")
        elseif trackers_visible then
            hud:AddEHIUpdator("EHITrackers_Update", trackers)
        end
    else
        original.feed_heist_time = hud.feed_heist_time
        if (trackers_visible and waypoints_visible) or show_mission_triggers then
            function HUDManager:feed_heist_time(time, ...)
                original.feed_heist_time(self, time, ...)
                tracking:update_client(time)
            end
        elseif waypoints_visible then
            function HUDManager:feed_heist_time(time, ...)
                original.feed_heist_time(self, time, ...)
                waypoints:update_client(time)
            end
        elseif trackers_visible then
            function HUDManager:feed_heist_time(time, ...)
                original.feed_heist_time(self, time, ...)
                trackers:update_client(time)
            end
        end
    end
    function HUDManager:destroy(...)
        tracking:destroy()
        original.destroy(self, ...)
    end
    if _G.IS_VR and (trackers_visible or show_mission_triggers) then
        trackers:SetPanel(panel)
    end
    if EHI:GetOption("show_buffs") then
        managers.ehi_buff = blt.vm.dofile(EHI.LuaPath .. "EHIBuffManager.lua")
        managers.ehi_buff:init_finalize(hud, panel)
    end
    if tweak_data.levels:IsLevelSafehouse(level_id) then
        return
    elseif tweak_data.levels:IsStealthAvailable(level_id) and trackers_visible then
        if EHI:GetOption("show_pager_tracker") then
            local base = tweak_data.player.alarm_pager.bluff_success_chance
            if server then
                for _, value in ipairs(base) do
                    if value > 0 and value < 1 then
                        -- Random Chance
                        trackers:AddTracker({
                            id = "PagersChance",
                            chance = math.ehi_round_chance(base[1] or 0),
                            icons = { EHI.Icons.Pager },
                            hint = "pager_chance",
                            remove_on_alarm = true,
                            class = EHI.Trackers.Chance
                        })
                        return
                    end
                end
            end
            local max = 0
            for _, value in ipairs(base) do
                if value > 0 then
                    max = max + 1
                end
            end
            if max > 0 then
                trackers:AddTracker({
                    id = "Pagers",
                    max = EHI.ModUtils:SELH_GetModifiedPagerCount(max),
                    icons = { EHI.Icons.Pager },
                    set_color_bad_when_reached = true,
                    hint = "pager_counter",
                    remove_on_alarm = true,
                    class = EHI.Trackers.Progress
                })
                if _G.ch_settings then
                    EHI:AddOnSpawnedCallback(function()
                        if managers.player:has_category_upgrade("player", "corpse_alarm_pager_bluff") then
                            trackers:IncreaseProgressMax("Pagers", 2)
                        end
                    end)
                end
            end
        end
        if EHI:GetOption("show_bodybags_counter") then
            trackers:AddTracker({
                id = "BodybagsCounter",
                icons = { "equipment_body_bag" },
                hint = "bodybags_counter",
                remove_on_alarm = true,
                class = EHI.Trackers.Counter
            })
        end
    end
    if EHI:GetOption("show_floating_health_bar") then
        dofile(EHI.LuaPath .. "EHIHealthFloatManager.lua")
        EHIHealthFloatManager:new(hud, panel)
    end
    if EHI:GetOption("show_floating_damage_popup") then
        dofile(EHI.LuaPath .. "EHIDamageFloatManager.lua")
        EHIDamageFloatManager:new(hud)
    end
    if EHI:GetOption("show_floating_text") then
        dofile(EHI.LuaPath .. "EHITextFloatManager.lua")
        EHITextFloatManager:new(panel, hud._saferect)
    end
    if EHI:GetOption("show_end_game_stats") and not Global.game_settings.single_player then
        dofile(EHI.LuaPath .. "EHIEndGameStats.lua")
        EHIEndGameStats:new()
    end
    if not Global.game_settings.single_player and EHI:GetOptionAndLoadTracker("show_ping_tracker") then
        trackers:PreloadTracker({
            id = "PlayerPing",
            class = "EHIPlayerPingTracker"
        })
    end
end)

---@param id string
---@param class table
---@param update_loop_fun_name string?
function HUDManager:AddEHIUpdator(id, class, update_loop_fun_name)
    local update = update_loop_fun_name or "update"
    if not class[update] then
        EHI:Log(string.format("Class with ID '%s' is missing '%s' function!", id, update))
        return
    elseif not self._ehi_updators then
        self._ehi_updators = {}
        EHI:AddCallback(EHI.CallbackMessage.MissionEnd, function()
            for _id, _class in pairs(self._ehi_updators or {}) do
                self:remove_updator(_id)
                if _class.update_last then
                    _class:update_last(true)
                end
            end
            self._ehi_updators = nil
        end)
    end
    self._ehi_updators[id] = class
    self:add_updator(id, callback(class, class, update))
end

---@param id string
function HUDManager:RemoveEHIUpdator(id)
    if self._ehi_updators then
        self:remove_updator(id)
        self._ehi_updators[id] = nil
    end
end

---@param mode string
function HUDManager:sync_set_assault_mode(mode, ...)
    original.sync_set_assault_mode(self, mode, ...)
    managers.ehi_assault:CallAssaultModeChangedCallback(mode)
end

function HUDManager:set_disabled(...)
    original.set_disabled(self, ...)
    EHI:CallCallback(EHI.CallbackMessage.HUDVisibilityChanged, false)
end

function HUDManager:set_enabled(...)
    original.set_enabled(self, ...)
    EHI:CallCallback(EHI.CallbackMessage.HUDVisibilityChanged, true)
end

if EHI:GetOption("show_assault_delay_tracker") then
    original.sync_start_anticipation_music = HUDManager.sync_start_anticipation_music
    function HUDManager:sync_start_anticipation_music(...)
        original.sync_start_anticipation_music(self, ...)
        managers.ehi_assault:AnticipationStart()
    end
end

function HUDManager:sync_start_assault(...)
    original.sync_start_assault(self, ...)
    managers.ehi_assault:AssaultStart()
end

function HUDManager:sync_end_assault(...)
    original.sync_end_assault(self, ...)
    managers.ehi_assault:AssaultEnd()
end

---@param id string
---@param beardlib boolean?
function HUDManager:ShowAchievementStartedPopup(id, beardlib)
    if beardlib then
        self:custom_ingame_popup_text("ACHIEVEMENT STARTED!", EHI._cache.Beardlib[id].name, "ehi_" .. id)
    else
        self:custom_ingame_popup_text("ACHIEVEMENT STARTED!", managers.localization:to_upper_text("achievement_" .. id), EHI:GetAchievementIconString(id))
    end
end

---@param id string
---@param beardlib boolean?
function HUDManager:ShowAchievementFailedPopup(id, beardlib)
    if beardlib then
        self:custom_ingame_popup_text("ACHIEVEMENT FAILED!", EHI._cache.Beardlib[id].name, "ehi_" .. id)
    else
        self:custom_ingame_popup_text("ACHIEVEMENT FAILED!", managers.localization:to_upper_text("achievement_" .. id), EHI:GetAchievementIconString(id))
    end
end

---@param id string
---@param beardlib boolean?
function HUDManager:ShowAchievementDescription(id, beardlib)
    if beardlib then
        local Achievement = EHI._cache.Beardlib[id]
        managers.chat:_receive_message(1, Achievement.name, Achievement.objective, Color.white)
    else
        managers.chat:_receive_message(1, managers.localization:text("achievement_" .. id), managers.localization:text("achievement_" .. id .. "_desc"), Color.white)
    end
end

---@param id string
function HUDManager:ShowTrophyStartedPopup(id)
    self:custom_ingame_popup_text("TROPHY STARTED!", managers.localization:to_upper_text(id), "milestone_trophy")
end

---@param id string
function HUDManager:ShowTrophyFailedPopup(id)
    self:custom_ingame_popup_text("TROPHY FAILED!", managers.localization:to_upper_text(id), "milestone_trophy")
end

---@param id string
function HUDManager:ShowTrophyDescription(id)
    managers.chat:_receive_message(1, managers.localization:text(id), managers.localization:text(id .. "_objective"), Color.white)
end

---@param id string
---@param daily_job boolean
---@param desc string? Custom challenge description
---@param icon string?
function HUDManager:ShowSideJobStartedPopup(id, daily_job, desc, icon)
    local text = desc or (daily_job and ("menu_challenge_" .. id) or id)
    icon = icon or tweak_data.ehi.icons[id] and id or "milestone_trophy"
    self:custom_ingame_popup_text("DAILY SIDE JOB STARTED!", managers.localization:to_upper_text(text), icon)
end

---@param id string
---@param daily_job boolean
---@param desc string? Custom challenge description
---@param icon string?
function HUDManager:ShowSideJobFailedPopup(id, daily_job, desc, icon)
    local text = desc or (daily_job and ("menu_challenge_" .. id) or id)
    icon = icon or tweak_data.ehi.icons[id] and id or "milestone_trophy"
    self:custom_ingame_popup_text("DAILY SIDE JOB FAILED!", managers.localization:to_upper_text(text), icon)
end

---@param id string
---@param daily_job boolean?
---@param desc string? Custom challenge description
function HUDManager:ShowSideJobDescription(id, daily_job, desc)
    local text = desc or (daily_job and ("menu_challenge_" .. id) or id)
    local objective = daily_job and ((desc or ("menu_challenge_" .. id)) .. "_desc") or (id .. "_objective")
    managers.chat:_receive_message(1, managers.localization:text(text), managers.localization:text(objective), Color.white)
end

---@param id string
function HUDManager:ShowEventStartedPopup(id)
    self:custom_ingame_popup_text("EVENT STARTED!", managers.localization:to_upper_text("menu_" .. id), "milestone_trophy")
end

---@param id string
---@param desc string
function HUDManager:ShowEventDescription(id, desc)
    managers.chat:_receive_message(1, managers.localization:text("menu_" .. id), managers.localization:text(desc), Color.white)
end

---@param single_sniper boolean?
---@param icon string?
function HUDManager:ShowSnipersSpawned(single_sniper, icon)
    local id = single_sniper and "SNIPER!" or "SNIPERS!"
    local desc = single_sniper and "ehi_popup_sniper_spawned" or "ehi_popup_snipers_spawned"
    self:custom_ingame_popup_text(id, managers.localization:text(desc), icon or "EHI_Sniper")
end

---@param logic_started boolean?
---@param icon string?
function HUDManager:ShowSniperLogic(logic_started, icon)
    local id = logic_started and "SNIPER_LOGIC_START" or "SNIPER_LOGIC_END"
    local desc = logic_started and "ehi_popup_sniper_logic_started" or "ehi_popup_sniper_logic_ended"
    self:custom_ingame_popup_text(id, managers.localization:text(desc), icon or "EHI_Sniper")
end

if EHI.debug.created_waypoints then
    Hooks:PostHook(HUDManager, "add_waypoint", "EHI_Debug_add_waypoint", function(self, id, ...) ---@param id string|number
        EHI:LogWithCurrentFile("Created waypoint with ID: " .. tostring(id))
    end)
end