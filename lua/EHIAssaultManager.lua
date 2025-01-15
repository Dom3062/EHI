---@class EHIAssaultManagerSyncData
---@field diff number

local EHI = EHI
---@class EHIAssaultManager
EHIAssaultManager = {}
EHIAssaultManager._sync_anticipation_start = "EHI_AM_SyncAnticipationStart"
EHIAssaultManager._sync_sustain_start = "EHI_AM_SyncSustainStart"
EHIAssaultManager._sync_endless_stop = "EHI_AM_SyncEndlessStop"
---@param ehi_tracker EHITrackerManager
function EHIAssaultManager:new(ehi_tracker)
    self._trackers = ehi_tracker
    self._diff = 0
    return self
end

function EHIAssaultManager.GetTrackerName()
    if EHI:CombineAssaultDelayAndAssaultTime() then
        return "Assault"
    end
    return EHI:GetOption("show_assault_delay_tracker") and "AssaultDelay" or "AssaultTime"
end

---@param manager EHIManager
function EHIAssaultManager:init_finalize(manager)
    self._internal = manager:CreateInternal("assault")
    self._is_skirmish = tweak_data.levels:IsLevelSkirmish()
    local combine = EHI:CombineAssaultDelayAndAssaultTime()
    self._anticipation =
    {
        sync_f = (EHI.IsHost or self._is_skirmish) and "SyncAnticipationColor" or "SyncAnticipation",
        t = 30 -- Get it from tweak_data; although `HUDManager:sync_start_anticipation_music()` checks if the time is less than 30s; Time is disabled in Holdout as the time is accurate enough even for clients
    }
    self._assault_delay =
    {
        blocked = not (combine or EHI:GetOption("show_assault_delay_tracker")),
        name = combine and "Assault" or "AssaultDelay",
        delete_on_assault = not combine,
        hint = combine and "assault" or "assault_delay"
    }
    self._assault_time =
    {
        blocked = not (combine or EHI:GetOption("show_assault_time_tracker")),
        name = combine and "Assault" or "AssaultTime",
        delete_on_delay = not combine,
        show_endless_assault = true,
        hint = combine and "assault" or "assault_time"
    }
    self:AddAssaultTypeChangedCallback(function(mode, element_id)
        if self._blocked_wave_mode_elements and self._blocked_wave_mode_elements[element_id] then
            return
        end
        self._endless_assault = mode == "endless"
        local data
        if not self._endless_assault then
            if EHI.IsHost then
                local ai_state = managers.groupai:state()
                local assault_data = ai_state._task_data.assault or {}
                local current_state = assault_data.phase
                local assault_values = tweak_data.group_ai[tweak_data.levels:GetGroupAIState()].assault
                if current_state then
                    data = {
                        state = current_state
                    }
                    if current_state == "build" then
                        data.t_correction = assault_values.build_duration - (assault_data.phase_end_t - ai_state._t)
                    elseif current_state == "sustain" then
                        local t = ai_state._t
                        data.sustain_original_t = assault_data.phase_end_t - t
                        data.sustain_t = ai_state:assault_phase_end_time() - t
                    end
                    self._trackers:SyncTable(self._sync_endless_stop, data)
                end
            elseif self._synced_from_host then
                return
            end
        end
        self._trackers:CallFunction(self._assault_time.name, "SetEndlessAssault", self._endless_assault, data)
    end)
    if not self._assault_time.blocked then
        self:AddAssaultModeChangedCallback(function(mode)
            if mode == "phalanx" then
                self._trackers:CallFunction(self._assault_time.name, "CaptainArrived")
            else
                self._trackers:CallFunction(self._assault_time.name, "CaptainDefeated")
            end
            self._endless_assault = nil
        end)
        -- Crime Spree
        EHI:AddOnSpawnedCallback(function()
            local modifier = managers.modifiers:GetModifier("ModifierAssaultExtender", "crime_spree")
            if modifier then
                local tracker = EHIAssaultTracker or {}
                tracker._cs_duration = modifier:value("duration") * 0.01
                tracker._cs_deduction = modifier:value("deduction") * 0.01
                tracker._cs_max_hostages = modifier:value("max_hostages")
                tracker._cs_assault_extender = true
                local function f()
                    self._trackers:CallFunction(self._assault_time.name, "OnMinionCountChanged")
                end
                EHI:AddCallback(EHI.CallbackMessage.OnMinionAdded, f)
                EHI:AddCallback(EHI.CallbackMessage.OnMinionKilled, f)
            end
        end)
        manager:AddEventListener("EHIAssaultManager", "AssaultOnSustain", function(duration)
            self:OnEnterSustain(duration)
        end)
    end
    if EHI.IsHost then
        ---@class EHISustainListenerModifier : BaseModifier
        local EHISustainListenerModifier = class(BaseModifier)
        ---@param duration number
        function EHISustainListenerModifier:OnEnterSustainPhase(duration)
            manager:NotifyInternalListeners("AssaultOnSustain", "assault", "sustain_t", duration)
            manager._assault._internal.sustain_app_t = managers.game_play_central:get_heist_timer()
            if not manager._assault._is_skirmish then
                manager:SyncTable(manager._assault._sync_sustain_start, { t = duration })
            end
        end
        managers.modifiers:add_modifier(EHISustainListenerModifier, "EHI")
    else
        if not self._assault_delay.blocked then
            manager:AddReceiveHook(self._sync_anticipation_start, function(data, sender)
                local tbl = json.decode(data)
                self:AnticipationStartHost(tbl.t)
            end)
        end
        if not self._is_skirmish and (not self._assault_time.blocked or EHI:GetOption("show_captain_spawn_chance")) then
            manager:AddReceiveHook(self._sync_sustain_start, function(data, sender)
                local tbl = json.decode(data)
                manager:NotifyInternalListeners("AssaultOnSustain", "assault", "sustain_t", tbl.t)
            end)
        end
        manager:AddReceiveHook(self._sync_endless_stop, function(data, sender)
            self._trackers:CallFunction(self._assault_time.name, "SetEndlessAssault", false, json.decode(data))
        end)
    end
    EHI:AddCallback(EHI.CallbackMessage.SyncAssaultDiff, callback(self, self, "SetDiff"))
end

---@param hud HUDManager
function EHIAssaultManager:init_hud(hud)
    self._hud = hud
    self._control_info_f = function(_, data)
        self._trackers:CallFunction(self._assault_delay.name, "SetHostages", data.nr_hostages)
    end
    Hooks:PostHook(hud, "set_control_info", "EHI_Assault_set_control_info", self._control_info_f)
end

---@param params ParseTriggersTable.assault?
function EHIAssaultManager:Parse(params)
    if not params then
        return
    end
    self:SetDiff(params.diff or 0)
    self._force_assault_start = params.force_assault_start
    if params.wave_move_elements_block then
        self._blocked_wave_mode_elements = table.list_to_set(params.wave_move_elements_block)
    end
    if params.fake_assault_block then
        self._assault_block = true
        EHI:AddOnAlarmCallback(callback(self, self, "SetAssaultBlock", false))
    end
end

---@param diff number
function EHIAssaultManager:SetDiff(diff)
    if self._diff == diff then
        return
    end
    self._diff = diff
    self:CallFunction("UpdateDiff", diff)
end

---@param block boolean
---@param t number
function EHIAssaultManager:SetControlStateBlock(block, t)
    self._control_block = block
    if self._trackers:TrackerExists(self._assault_delay.name) then
        self._trackers:CallFunction(self._assault_delay.name, "SetControlStateBlock", block, t)
    elseif not block then
        self:StartAssaultCountdown(t, true)
    end
end

---@param t number
---@param block_if_exists boolean?
function EHIAssaultManager:StartAssaultCountdown(t, block_if_exists)
    if self._assault_delay.blocked or self._control_block or self._internal.is_assault then
        return
    elseif block_if_exists and self._trackers:TrackerExists(self._assault_delay.name) then
        return
    end
    self._trackers:AddTracker({
        id = self._assault_delay.name,
        time = t,
        diff_visual = self._diff,
        hint = self._assault_delay.hint,
        class = EHI.Trackers.Assault
    }, 0)
end

---@param t number
function EHIAssaultManager:AnticipationStartHost(t)
    self._trackers:CallFunction(self._assault_delay.name, "StartAnticipation", t)
end

---@param t number
function EHIAssaultManager:SyncAnticipationStartHost(t)
    self._trackers:SyncTable(self._sync_anticipation_start, { t = t })
end

function EHIAssaultManager:AnticipationStart()
    if self._assault_delay.blocked then
        return
    end
    self._trackers:CallFunction(self._assault_delay.name, self._anticipation.sync_f, self._anticipation.t)
    EHI:Unhook("Assault_set_control_info")
end

function EHIAssaultManager:AssaultStart()
    EHI:Unhook("Assault_set_control_info")
    if self._assault_delay.delete_on_assault then
        self._trackers:ForceRemoveTracker(self._assault_delay.name)
    end
    if not self._internal.is_assault and self._assault_start_callback then
        self._assault_start_callback:dispatch()
    end
    if self._assault_time.blocked or (self._endless_assault and not self._assault_time.show_endless_assault) or self._internal.is_assault or self._assault_block then
        self._internal.is_assault = true
        if self._force_assault_start and not self._endless_assault then
            self._trackers:CallFunction(self._assault_time.name, "AssaultStart", self._diff)
        end
        return
    elseif self._trackers:TrackerExists(self._assault_time.name) then
        if self._endless_assault then
            self._trackers:CallFunction(self._assault_time.name, "CalculateDifficultyRamp", self._diff)
            self._trackers:CallFunction(self._assault_time.name, "SetEndlessAssault", true)
        else
            self._trackers:CallFunction(self._assault_time.name, "AssaultStart", self._diff)
        end
    elseif self._diff > 0 or self._is_skirmish then
        self._trackers:AddTracker({
            id = self._assault_time.name,
            assault = true,
            diff = self._diff,
            endless_assault = self._endless_assault,
            hint = self._assault_time.hint,
            current_assault_number = self._current_assault_number,
            class = EHI.Trackers.Assault
        }, 0)
    end
    self._internal.is_assault = true
end

---@param f function
function EHIAssaultManager:AddAssaultStartCallback(f)
    if not self._assault_start_callback then
        self._assault_start_callback = CallbackEventHandler:new()
    end
    self._assault_start_callback:add(f)
end

function EHIAssaultManager:AssaultEnd()
    if self._internal.is_assault and self._assault_end_callback then
        self._assault_end_callback:dispatch()
    end
    self._internal.is_assault = false
    if self._is_skirmish then
        self._current_assault_number = (self._current_assault_number or 0) + 1
    end
    if self._assault_time.delete_on_delay or self._endless_assault then
        self._trackers:ForceRemoveTracker(self._assault_time.name)
    end
    if self._assault_block or self._assault_delay.blocked then
        return
    elseif self._trackers:TrackerExists(self._assault_delay.name) and not self._assault_delay.delete_on_assault then
        local f = self._control_block and "AssaultEndWithBlock" or "AssaultEnd"
        self._trackers:CallFunction(self._assault_delay.name, f, self._diff)
    elseif self._diff > 0 and not self._control_block then
        self._trackers:AddTracker({
            id = self._assault_delay.name,
            diff = self._diff,
            hint = self._assault_delay.hint,
            current_assault_number = self._current_assault_number,
            class = EHI.Trackers.Assault
        }, 0)
    end
    Hooks:PostHook(self._hud, "set_control_info", "EHI_Assault_set_control_info", self._control_info_f)
end

---@param f function
function EHIAssaultManager:AddAssaultEndCallback(f)
    if not self._assault_end_callback then
        self._assault_end_callback = CallbackEventHandler:new()
    end
    self._assault_end_callback:add(f)
end

---@param f fun(mode: "normal"|"endless", element_id: number)
function EHIAssaultManager:AddAssaultTypeChangedCallback(f)
    if not self._assault_type_changed_callback then
        self._assault_type_changed_callback = CallbackEventHandler:new()
    end
    self._assault_type_changed_callback:add(f)
end

---@param mode "normal"|"endless"
---@param element_id number
function EHIAssaultManager:CallAssaultTypeChangedCallback(mode, element_id)
    if self._assault_type_changed_callback then
        self._assault_type_changed_callback:dispatch(mode, element_id)
    end
end

---@param f fun(mode: "normal"|"phalanx")
function EHIAssaultManager:AddAssaultModeChangedCallback(f)
    if not self._assault_mode_changed_callback then
        self._assault_mode_changed_callback = CallbackEventHandler:new()
    end
    self._assault_mode_changed_callback:add(f)
end

---@param mode "normal"|"phalanx"
function EHIAssaultManager:CallAssaultModeChangedCallback(mode)
    if self._assault_mode_changed_callback then
        self._assault_mode_changed_callback:dispatch(mode)
    end
end

---@param assault_number number
---@param in_assault boolean
function EHIAssaultManager:SetCurrentAssaultNumber(assault_number, in_assault)
    if not self._is_skirmish then
        return
    elseif assault_number == 0 or not in_assault then
        assault_number = assault_number + 1
    end
    self._current_assault_number = assault_number
    self:CallFunction("SetProgress", assault_number)
end

---@param t number
function EHIAssaultManager:OnEnterSustain(t)
    self._trackers:CallFunction(self._assault_time.name, "OnEnterSustain", t)
end

---@param block boolean?
function EHIAssaultManager:SetAssaultBlock(block)
    self._assault_block = block
    if block then
        self:CallFunction("PoliceActivityBlocked")
    end
end

---@param f string
function EHIAssaultManager:CallFunction(f, ...)
    self._trackers:CallFunction("Assault", f, ...)
    self._trackers:CallFunction("AssaultDelay", f, ...)
    self._trackers:CallFunction("AssaultTime", f, ...)
end

function EHIAssaultManager:TrackerExists()
    return self._trackers:TrackerExists("Assault") or self._trackers:TrackerExists("AssaultDelay") or self._trackers:TrackerExists("AssaultTime")
end

---@param data SyncData
function EHIAssaultManager:save(data)
    if not self._is_skirmish then
        local state = {}
        state.diff = self._diff
        data.EHIAssaultManager = state
    end
end

---@param data SyncData
function EHIAssaultManager:load(data)
    local state = data.EHIAssaultManager
    if state then
        self._diff = state.diff
        self._anticipation.sync_f = "SyncAnticipationColor"
        self._synced_from_host = true
    end
end