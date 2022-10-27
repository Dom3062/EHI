local EHI = EHI
if EHI._hooks.HUDManagerPD2 then
	return
else
	EHI._hooks.HUDManagerPD2 = true
end

if not (Global.game_settings and Global.game_settings.level_id) then
    return
end

local level_id = Global.game_settings.level_id

local original =
{
    _setup_player_info_hud_pd2 = HUDManager._setup_player_info_hud_pd2,
    destroy = HUDManager.destroy,
    mark_cheater = HUDManager.mark_cheater,
    set_disabled = HUDManager.set_disabled,
    set_enabled = HUDManager.set_enabled
}

local EHIWaypoints = EHI:GetOption("show_waypoints")
local server = EHI:IsHost()

function HUDManager:_setup_player_info_hud_pd2(...)
    original._setup_player_info_hud_pd2(self, ...)
    local hud = self:script(PlayerBase.PLAYER_INFO_HUD_PD2)
    self.ehi = managers.ehi
    self.ehi_waypoint = managers.ehi_waypoint
    self.ehi_waypoint:SetPlayerHUD(hud, self._workspaces.overlay.saferect, self._gui)
    self._tracker_waypoints = {}
    if server or level_id == "hvh" then
        self:add_updator("EHI_Update", callback(self.ehi, self.ehi, "update"))
        if EHIWaypoints then
            self:add_updator("EHI_Waypoint_Update", callback(self.ehi_waypoint, self.ehi_waypoint, "update"))
        end
    elseif EHIWaypoints then
        self:add_updator("EHI_Waypoint_dt_update", callback(self.ehi_waypoint, self.ehi_waypoint, "update_dt"))
    end
    if _G.IS_VR then
        self.ehi:SetPanel(hud.panel)
    end
    if EHI:GetOption("show_buffs") then
        local buff = managers.ehi_buff
        self:add_updator("EHI_Buff_Update", callback(buff, buff, "update"))
        buff:init_finalize(hud)
    end
    local level_tweak_data = tweak_data.levels[level_id]
    if level_tweak_data and level_tweak_data.team_ai_off then
        return
    end
    if EHI:GetOption("show_enemy_count_tracker") then
        self.ehi:AddTracker({
            id = "EnemyCount",
            icons = { "enemy" },
            flash = false,
            class = EHI.Trackers.Counter
        })
    end
    if level_tweak_data.ghost_bonus or level_tweak_data.ghost_required or level_tweak_data.ghost_required_visual or level_id == "welcome_to_the_jungle_2" then
        -- In case the heist will require stealth completion but does not have XP bonus
        -- Big Oil Day 2 is exception to this rule because guards have pagers
        if EHI:GetOption("show_pager_tracker") then
            local base = tweak_data.player.alarm_pager.bluff_success_chance_w_skill
            if server then
                local function remove_chance()
                    self.ehi:RemoveTracker("pagers_chance")
                end
                for _, value in pairs(base) do
                    if value > 0 and value < 1 then
                        -- Random Chance
                        self.ehi:AddTracker({
                            id = "pagers_chance",
                            chance = EHI:RoundChanceNumber(base[1] or 0),
                            icons = { EHI.Icons.Pager },
                            class = EHI.Trackers.Chance
                        })
                        EHI:AddOnAlarmCallback(remove_chance)
                        return
                    end
                end
            end
            local function remove()
                self.ehi:RemoveTracker("pagers")
            end
            local max = 0
            for _, value in pairs(base) do
                if value > 0 then
                    max = max + 1
                end
            end
            self.ehi:AddTracker({
                id = "pagers",
                max = max,
                icons = { EHI.Icons.Pager },
                set_color_bad_when_reached = true,
                class = EHI.Trackers.Progress
            })
            if max == 0 then
                self.ehi:CallFunction("pagers", "SetBad")
            end
            EHI:AddOnAlarmCallback(remove)
        end
        if EHI:GetOption("show_bodybags_counter") then
            self.ehi:AddTracker({
                id = "BodybagsCounter",
                icons = { "equipment_body_bag" },
                class = EHI.Trackers.Counter
            })
            local function remove()
                self.ehi:RemoveTracker("BodybagsCounter")
            end
            EHI:AddOnAlarmCallback(remove)
        end
    end
    if EHI:GetOption("show_gained_xp") and EHI:GetOption("xp_panel") == 2 and Global.game_settings.gamemode ~= "crime_spree" and not EHI:IsOneXPElementHeist(level_id) then
        self.ehi:AddTracker({
            id = "XPTotal",
            class = "EHITotalXPTracker"
        })
    end
end

if EHI:GetOption("show_captain_damage_reduction") then
    original.sync_set_assault_mode = HUDManager.sync_set_assault_mode
    function HUDManager:sync_set_assault_mode(mode, ...)
        original.sync_set_assault_mode(self, mode, ...)
        if mode == "phalanx" then
            self.ehi:AddTracker({
                id = "PhalanxDamageReduction",
                icons = { "buff_shield" },
                class = EHI.Trackers.Chance,
            })
        else
            self.ehi:RemoveTracker("PhalanxDamageReduction")
        end
    end
end

function HUDManager:mark_cheater(peer_id, ...)
    original.mark_cheater(self, peer_id, ...)
    if managers.experience.RecalculateSkillXPMultiplier then
        managers.experience:RecalculateSkillXPMultiplier()
    end
end

function HUDManager:set_disabled(...)
    original.set_disabled(self, ...)
    self.ehi:HidePanel()
end

function HUDManager:set_enabled(...)
    original.set_enabled(self, ...)
    self.ehi:ShowPanel()
end

function HUDManager:destroy(...)
    self.ehi:destroy()
    self.ehi_waypoint:destroy()
    original.destroy(self, ...)
end

if EHI:IsClient() and level_id ~= "hvh" then
    original.feed_heist_time = HUDManager.feed_heist_time
    if EHIWaypoints then
        function HUDManager:feed_heist_time(time, ...)
            original.feed_heist_time(self, time, ...)
            self.ehi:update_client(time)
            self.ehi_waypoint:update_client(time)
        end
    else
        function HUDManager:feed_heist_time(time, ...)
            original.feed_heist_time(self, time, ...)
            self.ehi:update_client(time)
        end
    end
end

function HUDManager:UpdateTrackerWaypointProgress(id, progress)
    if self._tracker_waypoints[id] then
        local wp = self._hud.waypoints[id]
        wp.init_data.progress = wp.init_data.progress + progress
        if wp.init_data.progress >= wp.init_data.max then
            self:RemoveTrackerWaypoint(id)
        else
            wp.timer_gui:set_text(wp.init_data.progress .. "/" .. wp.init_data.max)
        end
    end
end

function HUDManager:IncreaseTrackerWaypointProgress(id, increase)
    self:UpdateTrackerWaypointProgress(id, increase or 1)
end

if EHI:GetOption("show_assault_delay_tracker") then
    local SyncFunction = EHI:IsHost() and "SyncAnticipationColor" or "SyncAnticipation"
    local anticipation_delay = 30 -- Get it from tweak_data
    local function VerifyHostageHesitationDelay()
    end
    local function set_assault_delay(self, data)
        self.ehi:CallFunction("AssaultDelay", "SetHostages", data.nr_hostages > 0)
    end
    original.sync_start_anticipation_music = HUDManager.sync_start_anticipation_music
    function HUDManager:sync_start_anticipation_music(...)
        original.sync_start_anticipation_music(self, ...)
        self.ehi:CallFunction("AssaultDelay", SyncFunction, anticipation_delay)
        EHI:Unhook("AssaultDelay_set_control_info")
    end
    original.sync_start_assault = HUDManager.sync_start_assault
    function HUDManager:sync_start_assault(assault_number, ...)
        original.sync_start_assault(self, assault_number, ...)
        self.ehi:RemoveTracker("AssaultDelay")
        EHI:Unhook("AssaultDelay_set_control_info")
    end
    original.sync_end_assault = HUDManager.sync_end_assault
    function HUDManager:sync_end_assault(result, ...)
        original.sync_end_assault(self, result, ...)
        if EHI._cache.diff then
            self.ehi:AddTracker({
                id = "AssaultDelay",
                compute_time = true,
                diff = EHI._cache.diff,
                class = EHI.Trackers.AssaultDelay
            })
            EHI:HookWithID(HUDManager, "set_control_info", "EHI_AssaultDelay_set_control_info", set_assault_delay)
        end
    end
    EHI:HookWithID(HUDManager, "set_control_info", "EHI_AssaultDelay_set_control_info", set_assault_delay)
    VerifyHostageHesitationDelay()
end

function HUDManager:ShowAchievementStartedPopup(id, beardlib)
    if beardlib then
        self:custom_ingame_popup_text("ACHIEVEMENT STARTED!", EHI._cache[id], "ehi_" .. id)
    else
        self:custom_ingame_popup_text("ACHIEVEMENT STARTED!", managers.localization:to_upper_text("achievement_" .. id), EHI:GetAchievementIconString(id))
    end
end

function HUDManager:ShowAchievementFailedPopup(id, beardlib)
    if beardlib then
        self:custom_ingame_popup_text("ACHIEVEMENT FAILED!", EHI._cache[id], "ehi_" .. id)
    else
        self:custom_ingame_popup_text("ACHIEVEMENT FAILED!", managers.localization:to_upper_text("achievement_" .. id), EHI:GetAchievementIconString(id))
    end
end

function HUDManager:ShowTrophyStartedPopup(id)
    self:custom_ingame_popup_text("TROPHY STARTED!", managers.localization:to_upper_text(id), "milestone_trophy")
end

function HUDManager:ShowTrophyFailedPopup(id)
    self:custom_ingame_popup_text("TROPHY FAILED!", managers.localization:to_upper_text(id), "milestone_trophy")
end

function HUDManager:ShowDailyStartedPopup(id)
    local icon = tweak_data.ehi.icons[id] and id or "milestone_trophy"
    self:custom_ingame_popup_text("DAILY SIDE JOB STARTED!", managers.localization:to_upper_text(id), icon)
end

function HUDManager:ShowDailyFailedPopup(id)
    local icon = tweak_data.ehi.icons[id] and id or "milestone_trophy"
    self:custom_ingame_popup_text("DAILY SIDE JOB FAILED!", managers.localization:to_upper_text(id), icon)
end

function HUDManager:Debug(id)
    local dt = 0
    if self._ehi_debug_time then
        local new_time = TimerManager:game():time()
        dt = new_time - self._ehi_debug_time
        self._ehi_debug_time = new_time
    else
        self._ehi_debug_time = TimerManager:game():time()
    end
    managers.chat:_receive_message(1, "[EHI]", "ID: " .. tostring(id) .. "; dt: " .. dt, Color.white)
end

function HUDManager:DebugElement(id, element)
    managers.chat:_receive_message(1, "[EHI]", "ID: " .. tostring(id) .. "; Element: " .. tostring(element), Color.white)
end

function HUDManager:DebugBaseElement(id, instance_index, continent_index, element)
    managers.chat:_receive_message(1, "[EHI]", "ID: " .. tostring(EHI:GetBaseUnitID(id, instance_index, continent_index or 100000)) .. "; Element: " .. tostring(element), Color.white)
end

function HUDManager:DebugBaseElement2(base_id, instance_index, continent_index, element, instance_name)
    managers.chat:_receive_message(1, "[EHI]", "Base ID: " .. tostring(EHI:GetBaseUnitID(base_id, instance_index, continent_index or 100000)) .. "; ID: " .. tostring(base_id) .. "; Element: " .. tostring(element) .. "; Instance: " .. tostring(instance_name), Color.white)
end

local animation = { start_t = {}, end_t = {} }
function HUDManager:DebugAnimation(id, type)
    if type == "start" then
        animation.start_t[id] = TimerManager:game():time()
    else -- "end"
        animation.end_t[id] = TimerManager:game():time()
    end
    if animation.start_t[id] and animation.end_t[id] then
        local diff = animation.end_t[id] - animation.start_t[id]
        managers.chat:_receive_message(1, "[EHI]", "Animation: " .. tostring(id) .. "; Time: " .. tostring(diff), Color.white)
        animation.end_t[id] = nil
        animation.start_t[id] = nil
    end
end

local last_id = ""
function HUDManager:DebugAnimation2(id, type)
    if id then
        last_id = id
    end
    self:DebugAnimation(last_id, type)
    if type == "end" then
        last_id = ""
    end
end