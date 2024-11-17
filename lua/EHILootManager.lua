local EHI = EHI

---@class EHILootManager : EHIBaseManager
---@field super EHIBaseManager
---@field new fun(self: self, ehi_tracker: EHITrackerManager): self
---@field _loot_counter_sync_data LootCounterTable
EHILootManager = class(EHIBaseManager)
EHILootManager._sync_lm_add_loot_counter = "EHI_LM_AddLootCounter"
EHILootManager._sync_lm_update_loot_counter = "EHI_LM_SyncUpdateLootCounter"

---@param ehi_tracker EHITrackerManager
function EHILootManager:init(ehi_tracker)
    self._trackers = ehi_tracker
    self._delay_popups = true
    self:CreateEventListener()
end

function EHILootManager:init_finalize()
    if EHI:IsClient() and EHI:GetOption("show_loot_counter") then
        self:AddReceiveHook(self._sync_lm_add_loot_counter, function(data, sender)
            local params = json.decode(data)
            self:ShowLootCounter(params.max, params.max_random, 0, params.offset)
            self:AddListener(true)
        end)
        self:AddReceiveHook(self._sync_lm_update_loot_counter, function(data, sender)
            local params = json.decode(data)
            if params.type == "IncreaseMaxRandom" then
                self:IncreaseLootCounterMaxRandom(params.random)
            elseif params.type == "RandomLootSpawned" then
                self:RandomLootSpawned(params.random)
            elseif params.type == "RandomLootDeclined" then
                self:RandomLootDeclined(params.random)
            end
        end)
    end
end

function EHILootManager:Spawned()
    self._delay_popups = nil
end

---Shows Loot Counter, needs to be hooked to count correctly
---@param max number?
---@param max_random number?
---@param max_xp_bags number?
---@param offset number?
---@param unknown_random boolean?
---@param no_max boolean?
---@param max_bags_for_level table?
function EHILootManager:ShowLootCounter(max, max_random, max_xp_bags, offset, unknown_random, no_max, max_bags_for_level)
    if max_bags_for_level then
        self._trackers:AddTracker({
            id = "LootCounter",
            xp_params = max_bags_for_level,
            loot_parent = self,
            class = "EHILootMaxTracker"
        })
    else
        if no_max then
            unknown_random = false
        end
        self._trackers:AddTracker({
            id = "LootCounter",
            max = max or 0,
            max_random = max_random or 0,
            max_xp_bags = max_xp_bags or 0,
            offset = offset or 0,
            unknown_random = unknown_random,
            loot_parent = self,
            class = no_max and "EHILootCountTracker" or "EHILootTracker"
        })
    end
end

---Shows Loot Counter, needs to be hooked to count correctly
---@param max number?
---@param max_random number?
---@param offset number?
function EHILootManager:SyncShowLootCounter(max, max_random, offset)
    self:ShowLootCounter(max, max_random, 0, offset)
    self:SetSyncData({
        max = max or 0,
        max_random = max_random or 0,
        offset = offset or 0
    })
    if not self._delay_popups then
        self:SyncTable(self._sync_lm_add_loot_counter, self._loot_counter_sync_data)
    end
end

---@param no_sync_load boolean?
function EHILootManager:AddListener(no_sync_load)
    if not self:HasEventListener("LootCounter") then
        local BagsOnly = EHI.Const.LootCounter.CheckType.BagsOnly
        self:AddEventListener("LootCounter", function(loot)
            self._trackers:SetTrackerProgress("LootCounter", loot:EHIReportProgress(BagsOnly))
        end)
        -- If sync load is disabled, the counter needs to be updated via `EHIManager:AddLoadSyncFunction()` to properly show number of secured loot
        -- Usually done in heists which have additional loot that spawns depending on random chance; example: Red Diamond in Diamond Heist (Classic)
        if not no_sync_load then
            ---@param loot LootManager
            EHI:AddCallback(EHI.CallbackMessage.LootLoadSync, function(loot)
                self._trackers:SetTrackerSyncData("LootCounter", loot:EHIReportProgress(BagsOnly))
            end)
        end
    end
end

---@param params AchievementLootCounterTable|AchievementBagValueCounterTable
---@param endless_counter boolean?
function EHILootManager:AddAchievementListener(params, endless_counter)
    local check_type, loot_type, f = EHI.Const.LootCounter.CheckType.BagsOnly, nil, nil
    if params.counter then
        check_type = params.counter.check_type or EHI.Const.LootCounter.CheckType.BagsOnly
        loot_type = params.counter.loot_type
        f = params.counter.f
    end
    if endless_counter then
        self:AddEventListener(params.achievement, function(loot)
            if f then
                loot:EHIReportProgress(check_type, loot_type, f)
            else
                self._trackers:SetTrackerProgress(params.achievement, loot:EHIReportProgress(check_type, loot_type))
            end
        end)
    else
        self:AddEventListener(params.achievement, function(loot)
            if f then
                loot:EHIReportProgress(check_type, loot_type, f)
            else
                local progress = loot:EHIReportProgress(check_type, loot_type)
                self._trackers:SetTrackerProgress(params.achievement, progress)
                if progress >= (params.max or params.value) then
                    self:RemoveEventListener(params.achievement)
                end
            end
        end)
    end
    if not (params.load_sync or params.no_sync) then
        ---@param loot LootManager
        EHI:AddCallback(EHI.CallbackMessage.LootLoadSync, function(loot)
            if f then
                loot:EHIReportProgress(check_type, loot_type, f)
            else
                self._trackers:SetTrackerSyncData(params.achievement, loot:EHIReportProgress(check_type, loot_type))
            end
        end)
    end
end

---@param f fun(loot: LootManager)
function EHILootManager:AddEventListener(id, f)
    EHILootManager.super.AddEventListener(self, id, EHI.CallbackMessage.LootSecured, f)
end

function EHILootManager:SecuredMissionLoot()
    self._trackers:CallFunction("LootCounter", "SecuredMissionLoot")
end

---@param tracker_id string? Defaults to `LootCounter` if not provided
function EHILootManager:SyncSecuredLoot(tracker_id)
    local id = tracker_id or "LootCounter"
    self._trackers:SetTrackerSyncData(id, managers.loot:GetSecuredBagsAmount())
end

---@param id number
---@param callback function?
function EHILootManager:AddDelayedLootDeclinedCheck(id, callback)
    self._trackers:CallFunction("LootCounter", "AddDelayedLootDeclinedCheck", id, callback)
end

---@param max number?
function EHILootManager:IncreaseLootCounterProgressMax(max)
    self._trackers:IncreaseTrackerProgressMax("LootCounter", max)
end

---@param max number?
function EHILootManager:DecreaseLootCounterProgressMax(max)
    self._trackers:DecreaseTrackerProgressMax("LootCounter", max)
end

---@param progress number?
function EHILootManager:IncreaseLootCounterMaxRandom(progress)
    self._trackers:CallFunction("LootCounter", "IncreaseMaxRandom", progress)
end

---@param progress number?
function EHILootManager:DecreaseLootCounterMaxRandom(progress)
    self._trackers:CallFunction("LootCounter", "DecreaseMaxRandom", progress)
end

---@param max_random number?
function EHILootManager:SetLootCounterMaxRandom(max_random)
    self._trackers:CallFunction("LootCounter", "SetMaxRandom", max_random)
end

---@param id string|number Element ID
---@param force boolean? Force loot spawn event if the element does not have `fail` state (desync workaround)
function EHILootManager:RandomLootSpawnedCheck(id, force)
    self._trackers:CallFunction("LootCounter", "RandomLootSpawnedCheck", id, force)
end

---@param id string|number Element ID
function EHILootManager:RandomLootDeclinedCheck(id)
    self._trackers:CallFunction("LootCounter", "RandomLootDeclinedCheck", id)
end

---@param random number?
function EHILootManager:RandomLootSpawned(random)
    self._trackers:CallFunction("LootCounter", "RandomLootSpawned", random)
end

---@param random number?
function EHILootManager:RandomLootDeclined(random)
    self._trackers:CallFunction("LootCounter", "RandomLootDeclined", random)
end

---@param state boolean?
function EHILootManager:SetUnknownRandomLoot(state)
    self._trackers:CallFunction("LootCounter", "SetUnknownRandomLoot", state)
end

---@param count number
function EHILootManager:SetCountOfArmoredTransports(count)
    self._trackers:CallFunction("LootCounter", "SetCountOfArmoredTransports", count)
end

function EHILootManager:RandomLootSpawnedInTransport()
    self._trackers:CallFunction("LootCounter", "RandomLootSpawnedInTransport")
end

function EHILootManager:RandomLootDeclinedInTransport()
    self._trackers:CallFunction("LootCounter", "RandomLootDeclinedInTransport")
end

function EHILootManager:ExplosionInTransport()
    self._trackers:CallFunction("LootCounter", "ExplosionInTransport")
end

---@param data table
function EHILootManager:SetSyncData(data)
    self._loot_counter_sync_data = data
end

---@param data table
function EHILootManager:SetSyncDataAndSync(data)
    self:SetSyncData(data)
    self:SyncTable(self._sync_lm_add_loot_counter, data)
end

---@param random number?
function EHILootManager:SyncRandomLootSpawned(random)
    self:RandomLootSpawned(random)
    local sync_data = self._loot_counter_sync_data
    if sync_data then
        local n = random or 1
        sync_data.max = sync_data.max + n
        sync_data.max_random = sync_data.max_random - n
        self:SyncTable(self._sync_lm_update_loot_counter, { type = "RandomLootSpawned", random = n })
    end
end

---@param random number?
function EHILootManager:SyncRandomLootDeclined(random)
    self:RandomLootDeclined(random)
    local sync_data = self._loot_counter_sync_data
    if sync_data then
        local n = random or 1
        sync_data.max_random = sync_data.max_random - n
        self:SyncTable(self._sync_lm_update_loot_counter, { type = "RandomLootDeclined", random = n })
    end
end


---@param random number?
function EHILootManager:SyncIncreaseLootCounterMaxRandom(random)
    self:IncreaseLootCounterMaxRandom(random)
    local sync_data = self._loot_counter_sync_data
    if sync_data then
        local n = random or 1
        sync_data.max_random = sync_data.max_random + n
        self:SyncTable(self._sync_lm_update_loot_counter, { type = "IncreaseMaxRandom", random = n })
    end
end

---@param sequence_triggers table<number, LootCounterTable.SequenceTriggersTable>
function EHILootManager:AddSequenceTriggers(sequence_triggers)
    if not next(sequence_triggers) then
        return
    end
    local function IncreaseMax(...)
        self:SyncRandomLootSpawned()
    end
    local function DecreaseRandom(...)
        self:SyncRandomLootDeclined()
    end
    for unit_id, sequences in pairs(sequence_triggers) do
        for _, sequence in ipairs(sequences.loot or {}) do
            managers.mission:add_runned_unit_sequence_trigger(unit_id, sequence, IncreaseMax)
        end
        for _, sequence in ipairs(sequences.no_loot or {}) do
            managers.mission:add_runned_unit_sequence_trigger(unit_id, sequence, DecreaseRandom)
        end
    end
end

---@param data SyncData
function EHILootManager:load(data)
    local load_data = data.EHILootManager
    if load_data and EHI:IsLootCounterVisible() then
        load_data.client_from_start = true
        load_data.no_sync_load = true
        EHI:ShowLootCounterNoChecks(load_data)
        self:SyncSecuredLoot()
    end
end

---@param data SyncData
function EHILootManager:save(data)
    if self._loot_counter_sync_data then
        data.EHILootManager = deep_clone(self._loot_counter_sync_data)
    end
end