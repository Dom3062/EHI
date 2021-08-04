local EHI = EHI
if EHI._hooks.HUDManagerPD2 then
	return
else
	EHI._hooks.HUDManagerPD2 = true
end

local level_id = Global.game_settings.level_id

local original =
{
    _setup_player_info_hud_pd2 = HUDManager._setup_player_info_hud_pd2,
    sync_set_assault_mode = HUDManager.sync_set_assault_mode,
    destroy = HUDManager.destroy,
    set_disabled = HUDManager.set_disabled,
    set_enabled = HUDManager.set_enabled
}

function HUDManager:_setup_player_info_hud_pd2(...)
    original._setup_player_info_hud_pd2(self, ...)
    self.ehi = managers.ehi
    self._tracker_waypoints = {}
    if Network:is_server() or level_id == "hvh" then
        self:add_updator("EHI_Update", callback(self.ehi, self.ehi, "update"))
    end
    local difficulty = Global.game_settings.difficulty
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
    if EHI:GetOption("show_gained_xp") and EHI:GetOption("xp_panel") == 2 and Global.game_settings.gamemode ~= "crime_spree" then
        self:AddTracker({
            id = "XPTotal",
            exclude_from_sync = true,
            class = "EHITotalXPTracker"
        })
    end
    if EHI:GetOption("show_achievement") then
        self:ShowAchievements(difficulty)
    end
    self:ShowLootCounter(difficulty)
end

function HUDManager:ShowAchievements(difficulty)
    if level_id == "cane" and EHI:IsOVKOrAbove(difficulty) then
        self.ehi:AddAchievementProgressTracker("cane_3", 100, true)
    end
    if level_id == "mex_cooking" and EHI:IsOVKOrAbove(difficulty) then
        self.ehi:AddAchievementProgressTracker("mex2_9", 25, true)
    end
    if level_id == "crojob2" then
        self.ehi:AddAchievementProgressTracker("voff_2", 2, true)
    end
    if level_id == "pal" then
        local value_max = tweak_data.achievement.loot_cash_achievements.pal_2.secured.value
        local loot_value = managers.money:get_secured_bonus_bag_value("counterfeit_money", 1)
        local max = math.ceil(value_max / loot_value)
        self.ehi:AddAchievementProgressTracker("pal_2", max, true)
    end
    if level_id == "pbr" then
        self.ehi:AddAchievementProgressTracker("berry_2", 10, true)
    end
    if level_id == "pbr2" then
        self.ehi:AddAchievementProgressTracker("voff_4", 9)
    end
    if level_id == "pex" then
        self.ehi:AddAchievementProgressTracker("pex_10", 6, true)
        self.ehi:AddAchievementProgressTracker("pex_11", 7)
    end
    if level_id == "dah" and EHI:IsOVKOrAbove(difficulty) then
        self.ehi:AddAchievementProgressTracker("dah_8", 12)
    end
    if (level_id == "alex_1" or level_id == "rat") and EHI:IsOVKOrAbove(difficulty) then
        self.ehi:AddAchievementProgressTracker("halloween_2", 7, true)
    end
    if level_id == "chas" and EHI:IsOVKOrAbove(difficulty) then
        self.ehi:AddAchievementProgressTracker("chas_10", 15, true)
    end
    if level_id == "rvd2" then
        self.ehi:AddAchievementProgressTracker("rvd_11", 19, true)
    end
    if level_id == "mus" then
        self.ehi:AddAchievementProgressTracker("bat_3", 10, true)
    end
    if level_id == "shoutout_raid" then
        self.ehi:AddAchievementProgressTracker("melt_3", 8, true)
    end
    if level_id == "dinner" and EHI:IsOVKOrAbove(difficulty) then
        self.ehi:AddAchievementProgressTracker("farm_6", 1, true, false)
    end
    if level_id == "man" then
        self.ehi:AddAchievementProgressTracker("man_4", 10)
    end
    if level_id == "arm_for" then -- Transport: Train Heist
        self.ehi:AddAchievementProgressTracker("armored_1", 20, true)
    end
    --[[if level_id == "" then
    end]]
end

function HUDManager:ShowLootCounter(difficulty)
    local max = 0
    if level_id == "spa" then
        max = 4
    elseif level_id == "friend" or level_id == "dark" then
        max = 16
    elseif level_id == "wwh" then
        max = 8
    elseif level_id == "shoutout_raid" then
        max = EHI:IsOVKOrAbove(difficulty) and 8 or 6
        if self.ehi:TrackerDoesNotExist("melt_3") then
            max = max + 8
        end
    --[[elseif level_id == "rvd1" then
        max = 6
    elseif level_id == "alex_3" then
        max = 14]]
    elseif level_id == "dinner" then
        max = self.ehi:TrackerDoesNotExist("farm_6") and 11 or 10
    elseif level_id == "pbr" then
        if self.ehi:TrackerDoesNotExist("berry_2") then
            max = 10
        end
    elseif level_id == "arm_for" then
        max = 3 + (self.ehi:TrackerDoesNotExist("armored_1") and 20 or 0)
    elseif level_id == "rusdl" then -- Cold Stones Custom Heist
        max = 20
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

function HUDManager:sync_set_assault_mode(mode, ...)
    original.sync_set_assault_mode(self, mode, ...)
    if mode == "phalanx" and EHI:GetOption("show_captain_damage_reduction") then
        self:AddTracker({
            id = "PhalanxDamageReduction",
            icons = { "buff_shield" },
            exclude_from_sync = true,
            class = "EHIChanceTracker",
        })
    else
        self.ehi:RemoveTracker("PhalanxDamageReduction")
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
    original.destroy(self, ...)
end

function HUDManager:AddTracker(params)
    self.ehi:AddTracker(params)
end

if Network:is_client() and level_id ~= "hvh" then
    original.feed_heist_time = HUDManager.feed_heist_time
    function HUDManager:feed_heist_time(time, ...)
        original.feed_heist_time(self, time, ...)
        managers.ehi:update_client(time)
    end
end

if EHI:GetOption("show_waypoints") then
    local present_timer = EHI:GetOption("show_waypoints_present_timer")
    function HUDManager:AddTrackerWaypoint(id, params)
        params.no_sync = true -- Very important here, do not sync custom waypoints to avoid confusion between players and possible crashes
        params.pause_timer = params.no_time and 3 or (params.time and 1 or 3)
        params.timer = params.pause_timer ~= 3 and params.time or nil
        params.present_timer = present_timer
        --[[
            Remaining time is calculated in HUDManager:UpdateTrackerWaypoints() due to bad inaccuracy after slowmotion
            Pause Timer values:
            0 => Running (Vanilla)
            1 => Running / Paused (Vanilla)
            2 => Paused
            3 => Not-pausauble
            Trackers are using only values 1 and 2
        ]]
        --params.distance = true
        self:add_waypoint(id, params)
        if not params.no_time then
            self._tracker_waypoints[id] = true
        end
        if params.progress then
            self:UpdateTrackerWaypointProgress(id, 0)
        end
        if params.texture then
            self:ChangeWaypointIcon(id, params.texture, params.text_rect)
        end
    end
else
    function HUDManager:AddTrackerWaypoint(id, params)
    end
end

function HUDManager:ChangeWaypointIcon(id, texture, text_rect)
    if self._tracker_waypoints[id] then
        if text_rect then
            self._hud.waypoints[id].bitmap:set_image(texture, unpack(text_rect))
        else
            self._hud.waypoints[id].bitmap:set_image(texture)
        end
    end
end

function HUDManager:RemoveTrackerWaypoint(id)
    if self._tracker_waypoints[id] then
        self._hud.waypoints[id].timer_gui:stop()
    end
    self._tracker_waypoints[id] = nil
    self:remove_waypoint(id)
end

function HUDManager:PauseTrackerWaypoint(id)
    if self._tracker_waypoints[id] and self._hud.waypoints[id].pause_timer ~= 3 then
        self._hud.waypoints[id].pause_timer = 2
        self._hud.waypoints[id].timer_gui:set_color(Color.red)
    end
end

function HUDManager:UnpauseTrackerWaypoint(id)
    if self._tracker_waypoints[id] and self._hud.waypoints[id].pause_timer ~= 3 then
        self._hud.waypoints[id].pause_timer = 1
        self._hud.waypoints[id].timer_gui:set_color(Color.white)
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

function HUDManager:UpdateTrackerWaypoints(t, dt)
    for key, _ in pairs(self._tracker_waypoints) do
        local wp = self._hud.waypoints[key]
        if wp.pause_timer == 1 then
            wp.timer = wp.timer - dt
            if wp.timer > 0 then
                wp.timer_gui:set_text(self:TrackerFormat(wp.timer))
                if wp.timer <= 10 and wp.init_data.warning and not wp.init_data.warning_animating then
                    wp.init_data.warning_animating = true
                    wp.timer_gui:animate(function(o)
                        while true do
                            local _t = 0
                            while _t < 1 do
                                _t = _t + coroutine.yield()
                                local n = 1 - math.sin(_t * 180)
                                --local r = math.lerp(1, 0, n)
                                local g = math.lerp(1, 0, n)
                                o:set_color(Color(1, g, g))
                            end
                        end
                    end)
                end
            else
                self:RemoveTrackerWaypoint(key)
            end
        end
    end
end

local function SecondsOnly(self, time)
    local t = math.floor(time * 10) / 10

	if t < 0 then
		return string.format("%d", 0)
    elseif t < 1 then
        return string.format("%.2f", time)
	elseif t < 10 then
		return string.format("%.1f", t)
	else
		return string.format("%d", t)
	end
end

local function MinutesAndSeconds(self, time)
    local t = math.floor(time * 10) / 10

	if t < 0 then
		return string.format("%d", 0)
    elseif t < 1 then
        return string.format("%.2f", time)
	elseif t < 10 then
		return string.format("%.1f", t)
	elseif t < 60 then
		return string.format("%d", t)
	else
		return string.format("%d:%02d", t / 60, t % 60)
	end
end

if EHI:GetOption("time_format") == 1 then
    HUDManager.TrackerFormat = SecondsOnly
else
    HUDManager.TrackerFormat = MinutesAndSeconds
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