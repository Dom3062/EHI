---@class EHIPhalanxManagerSyncData
---@field time_check number
---@field chance_start number
---@field chance_increase number
---@field chance_max number

local EHI = EHI
---@class EHIPhalanxManager
local EHIPhalanxManager = {}
EHIPhalanxManager._no_endless_assault_check = table.set("pbr2")
EHIPhalanxManager._requires_manual_on_exec = table.set("dinner", "slaughter_house_new")
EHIPhalanxManager._disabled_in_levels = table.set("born")
EHIPhalanxManager._counter_trigger = EHI.IsClient and 3 or 2
EHIPhalanxManager._first_assault = true
---@param trackers EHITrackerManager
---@param hook EHIHookManager
---@param assault EHIAssaultManager
function EHIPhalanxManager:init_finalize(trackers, hook, assault)
    self._trackers = trackers
    self._hook = hook
    self._assault = assault
    self._phalanx_spawn_chance = tweak_data.group_ai.phalanx.spawn_chance or {}
    self._phalanx_spawn_time_check = tweak_data.group_ai.phalanx.check_spawn_intervall or 120
end

---@param element_so ElementSpecialObjective
function EHIPhalanxManager:OnSOPhalanxCreated(element_so)
    local level_id = Global.game_settings.level_id
    if self._disabled_in_levels[level_id] then
        return
    elseif self._requires_manual_on_exec[level_id] then
        self:LoadHooks()
        self._hook:HookElement(element_so, function(element, ...)
            if EHI.IsHost and not element._values.enabled then
                return
            end
            self:OnPhalanxAdded(true)
        end)
    else
        self:LoadHooks()
        self:OnPhalanxAdded()
    end
end

function EHIPhalanxManager:LoadHooks()
    if self.__hooked or tweak_data.levels:IsLevelSkirmish() then
        return
    end
    self.__hooked = true
    if EHI:GetOptionAndLoadTracker("show_captain_damage_reduction") then
        Hooks:PostHook(GroupAIStateBesiege, "set_phalanx_damage_reduction_buff", "EHI_EHIPhalanxManager_GroupAIStateBesiege_set_phalanx_damage_reduction", function(group_ai, damage_reduction, ...) ---@param damage_reduction number?
            self._trackers:SetChancePercent("PhalanxDamageReduction", damage_reduction or 0)
        end)
        self._assault:AddAssaultModeChangedCallback(function(mode)
            if mode == "phalanx" then
                self._trackers:AddTracker({
                    id = "PhalanxDamageReduction",
                    class = "EHIPhalanxDamageReductionTracker",
                })
            else
                self._trackers:ForceRemoveTracker("PhalanxDamageReduction")
            end
        end)
    end
    if EHI:GetOptionAndLoadTracker("show_captain_spawn_chance") then
        self._tracker_enabled = true
        EHI:AddOnAlarmCallback(function(dropin)
            self:SwitchToLoudMode(dropin)
        end)
    end
end

---@param manual boolean?
function EHIPhalanxManager:OnPhalanxAdded(manual)
    if self._so_phalanx or tweak_data.levels:IsLevelSkirmish() then
        return
    end
    self._so_phalanx = true
    if self._alarm and manual then
        self._first_assault = false
        self:ReduceCounter() -- Reduce the counter because Captain Winters is activated now; due to Mission Script
    end
    self:ReduceCounter()
    if EHI.IsHost and managers.modifiers:IsModifierActive("ModifierAssaultExtender", "crime_spree") and not self._tracker_enabled then
        local assault_state = ""
        Hooks:PostHook(GroupAIStateBesiege, "_upd_assault_task", "EHI_EHIPhalanxManager_upd_assault_task", function(state, ...)
            local phase = state._task_data.assault.phase
            if phase and phase ~= "anticipation" and assault_state ~= phase then
                if phase == "fade" then
                    managers.ehi_sync:SyncData("EHI_EHIPhalanxChanceTracker_sync_fade_state", "true")
                end
                assault_state = phase
            end
        end)
        self._assault:AddAssaultModeChangedCallback(function(mode)
            if mode == "phalanx" then
                Hooks:RemovePostHook("EHI_EHIPhalanxManager_upd_assault_task")
                assault_state = nil ---@diagnostic disable-line
            end
        end)
    end
end

---@param dropin boolean
function EHIPhalanxManager:SwitchToLoudMode(dropin)
    if self._alarm or not self._tracker_enabled or dropin then
        self._alarm = true
        return
    end
    self._alarm = true
    self:ReduceCounter()
end

function EHIPhalanxManager:ReduceCounter()
    if self._counter_trigger <= 0 then
        return
    end
    self._counter_trigger = self._counter_trigger - 1
    if self._counter_trigger == 0 then
        self:AddTracker()
    end
end

function EHIPhalanxManager:AddTracker()
    if self:IsPhalanxDisabled() or self._tracker_created then
        return
    end
    local assault_extender = managers.modifiers:IsModifierActive("ModifierAssaultExtender", "crime_spree")
    self._tracker_created = true
    self._trackers:AddTracker({
        id = "CaptainChance",
        time = self._phalanx_spawn_time_check,
        chance = self._phalanx_spawn_chance.start * 100,
        chance_increase = self._phalanx_spawn_chance.increase * 100,
        first_assault = self._first_assault,
        assault_extender = assault_extender,
        class = "EHIPhalanxChanceTracker"
    })
    self._assault:AddAssaultModeChangedCallback(function(mode)
        if mode == "phalanx" then
            self._trackers:ForceRemoveTracker("CaptainChance")
            self._assault:RemoveOnSustainListener("EHIPhalanxManager")
        end
    end)
    if not assault_extender then
        self._assault:AddOnSustainListener("EHIPhalanxManager", function(duration)
            self._trackers:CallFunction("CaptainChance", "OnEnterSustain", duration)
        end)
    end
    self._assault:AddAssaultStartCallback(function()
        self._trackers:CallFunction("CaptainChance", "AssaultStart")
    end)
    self._assault:AddAssaultEndCallback(function()
        self._trackers:CallFunction("CaptainChance", "AssaultEnd")
    end)
    if not self._no_endless_assault_check[Global.game_settings.level_id] then
        self._assault:AddAssaultTypeChangedCallback(function(mode, element_id)
            self._trackers:CallFunction("CaptainChance", "SetEndlessAssault", mode == "endless")
        end)
    end
end

if EHI.IsClient or EHI:IsModInstalled("Allow Winters Spawn Offline", "Offyerrocker") then
    function EHIPhalanxManager:IsPhalanxDisabled()
        return self._phalanx_spawn_chance.max == 0
    end
else
    function EHIPhalanxManager:IsPhalanxDisabled()
        return Global.game_settings.single_player or self._phalanx_spawn_chance.max == 0
    end
end

---@param data SyncData
function EHIPhalanxManager:save(data)
    if tweak_data.levels:IsLevelSkirmish() or not self._so_phalanx then
        return
    end
    local state = {}
    state.time_check = self._phalanx_spawn_time_check
    state.chance_start = self._phalanx_spawn_chance.start
    state.chance_increase = self._phalanx_spawn_chance.increase
    state.chance_max = self._phalanx_spawn_chance.max
    data.EHIPhalanxManager = state
end

---@param data SyncData
function EHIPhalanxManager:load(data)
    local state = data.EHIPhalanxManager
    if state then
        self._phalanx_spawn_time_check = state.time_check
        self._phalanx_spawn_chance.start = state.chance_start
        self._phalanx_spawn_chance.increase = state.chance_increase
        self._phalanx_spawn_chance.max = state.chance_max
        self:ReduceCounter()
    end
end

return EHIPhalanxManager