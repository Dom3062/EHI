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
local server = Network:is_server()

function HUDManager:_setup_player_info_hud_pd2(...)
    original._setup_player_info_hud_pd2(self, ...)
    self.ehi = managers.ehi
    local ehi_waypoint = managers.ehi_waypoint
    ehi_waypoint:SetPlayerHUD(self:script(PlayerBase.PLAYER_INFO_HUD_PD2), self._workspaces.overlay.saferect, self._gui)
    self._tracker_waypoints = {}
    if server or level_id == "hvh" then
        self:add_updator("EHI_Update", callback(self.ehi, self.ehi, "update"))
        if EHIWaypoints then
            self:add_updator("EHI_Waypoint_Update", callback(ehi_waypoint, ehi_waypoint, "update"))
        end
    elseif EHIWaypoints then
        self:add_updator("EHI_Waypoint_dt_update", callback(ehi_waypoint, ehi_waypoint, "update_dt"))
    end
    local level_tweak_data = tweak_data.levels[level_id]
    if level_tweak_data and level_tweak_data.team_ai_off then
        return
    end
    if EHI:GetOption("show_enemy_count_tracker") then
        self:AddTracker({
            id = "EnemyCount",
            exclude_from_sync = true,
            class = "EHICountTracker"
        })
    end
    if EHI:GetOption("show_pager_tracker") then
        local base = tweak_data.player.alarm_pager.bluff_success_chance_w_skill
        if server then
            local random_chance = false
            for _, value in pairs(base) do
                if value > 0 and value < 1 then
                    random_chance = true
                    break
                end
            end
            if random_chance then
                self:AddTracker({
                    id = "pagers_chance",
                    chance = EHI:RoundChanceNumber(base[1] or 0),
                    icons = { "pagers_used" },
                    exclude_from_sync = true,
                    class = "EHIChanceTracker"
                })
                return
            end
        end
        local max = 0
        for _, value in pairs(base) do
            if value > 0 then
                max = max + 1
            end
        end
        self:AddTracker({
            id = "pagers",
            max = max,
            icons = { "pagers_used" },
            set_color_bad_when_reached = true,
            exclude_from_sync = true,
            class = "EHIProgressTracker"
        })
        if max == 0 then
            self.ehi:CallFunction("pagers", "SetBad")
        end
    end
    if EHI:GetOption("show_gained_xp") and EHI:GetOption("xp_panel") == 2 and Global.game_settings.gamemode ~= "crime_spree" and not EHI:IsOneXPElementHeist(level_id) then
        self:AddTracker({
            id = "XPTotal",
            exclude_from_sync = true,
            class = "EHITotalXPTracker"
        })
    end
    if EHI:GetOption("show_achievement") and not EHI._cache.AchievementsAreDisabled then
        self:ShowAchievements()
    end
    self:ShowLootCounter()
end

function HUDManager:ShowAchievements()
    if level_id == "mex_cooking" and EHI:IsDifficultyOrAbove("overkill") then
        self.ehi:AddAchievementProgressTracker("mex2_9", 25, 0, true)
    end
    if level_id == "dah" and EHI:IsDifficultyOrAbove("overkill") then
        self.ehi:AddAchievementProgressTracker("dah_8", 12, 0)
    end
    if level_id == "chas" and EHI:IsDifficultyOrAbove("overkill") then
        self.ehi:AddAchievementProgressTracker("chas_10", 15, 0, true)
    end
    --[[if level_id == "shoutout_raid" then
        self.ehi:AddAchievementProgressTracker("melt_3", 8, true)
    end]]
    --[[if level_id == "arm_for" then -- Transport: Train Heist
        self.ehi:AddAchievementProgressTracker("armored_1", 20, true)
    end]]
end

function HUDManager:ShowLootCounter()
    local max = 0
    --[[if level_id == "shoutout_raid" then
    --elseif level_id == "shoutout_raid" then
        max = EHI:IsDifficultyOrAbove("overkill") and 8 or 6
        if self.ehi:TrackerDoesNotExist("melt_3") then
            max = max + 8
        end]]
    --[[elseif level_id == "rvd1" then
        max = 6
    elseif level_id == "alex_3" then
        max = 14]]
    --elseif level_id == "arm_for" then
        --max = 3 + (self.ehi:TrackerDoesNotExist("armored_1") and 20 or 0)
    if level_id == "rusdl" then -- Cold Stones Custom Heist
    --elseif level_id == "rusdl" then -- Cold Stones Custom Heist
        max = 20
    elseif level_id == "hunter_departure" and not (EHI:GetOption("show_achievement") or EHI._cache.AchievementsAreDisabled) then -- Hunter and Hunted (Departure) Day 2 Custom Heist
        max = 21
    end
    if max == 0 then
        return
    end
    self:AddTracker({
        id = "LootCounter",
        max = max,
        icons = { "pd2_loot" },
        exclude_from_sync = true,
        class = "EHIProgressTracker"
    })
end

if EHI:GetOption("show_captain_damage_reduction") then
    original.sync_set_assault_mode = HUDManager.sync_set_assault_mode
    function HUDManager:sync_set_assault_mode(mode, ...)
        original.sync_set_assault_mode(self, mode, ...)
        if mode == "phalanx" then
            self:AddTracker({
                id = "PhalanxDamageReduction",
                icons = { "buff_shield" },
                exclude_from_sync = true,
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
    managers.ehi:HidePanel()
end

function HUDManager:set_enabled(...)
    original.set_enabled(self, ...)
    managers.ehi:ShowPanel()
end

function HUDManager:destroy(...)
    self.ehi:destroy()
    managers.ehi_waypoint:destroy()
    original.destroy(self, ...)
end

function HUDManager:AddTracker(params)
    self.ehi:AddTracker(params)
end

if Network:is_client() and level_id ~= "hvh" then
    original.feed_heist_time = HUDManager.feed_heist_time
    if EHIWaypoints then
        function HUDManager:feed_heist_time(time, ...)
            original.feed_heist_time(self, time, ...)
            managers.ehi:update_client(time)
            managers.ehi_waypoint:update_client(time)
        end
    else
        function HUDManager:feed_heist_time(time, ...)
            original.feed_heist_time(self, time, ...)
            managers.ehi:update_client(time)
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