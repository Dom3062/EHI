---@class EHILootSharedMaster : EHIBaseMaster
---@field super EHIBaseMaster
---@field new fun(self: self, params: EHITracker.params): self
EHILootSharedMaster = class(EHIBaseMaster)
EHILootSharedMaster._SHOW_POPUP = EHI:GetOption("show_all_loot_secured_popup")
---@param params EHITracker.params
function EHILootSharedMaster:init(params)
    EHILootSharedMaster.super.init(self, params)
    self._achievement_id = params.achievement_id
    self._max = params.max or 0
    self._progress = params.progress or 0
    self._mission_loot = 0
    self._offset = params.offset or 0
    self._max_random = params.max_random or 0
    self._stay_on_screen = self._max_random > 0
    self._max_xp_bags = params.max_xp_bags or 0
    self._unknown_random = params.unknown_random
    self._loot_id = {}
    self._loot_check_delay = {} ---@type table<number, { t: number, callback: fun(id: number)? }>
    self._loot_check_n = 0
end

function EHILootSharedMaster:post_init()
end

function EHILootSharedMaster:GetListenerID()
    return self._achievement_id or self._id
end

if EHI:GetOption("variable_random_loot_format") == 1 then
    function EHILootSharedMaster:Format()
        if self._max_xp_bags > 0 then
            local max = math.min(self._max, self._max_xp_bags)
            return self._progress .. "/" .. max
        elseif self._max_random > 0 then
            local max = self._max + self._max_random
            if self._unknown_random then
                return self._progress .. "/" .. self._max .. "-" .. max .. "?+?"
            else
                return self._progress .. "/" .. self._max .. "-" .. max .. "?"
            end
        elseif self._unknown_random then
            return self._progress .. "/" .. self._max .. "+?"
        end
        return self._progress .. "/" .. self._max
    end
elseif EHI:GetOption("variable_random_loot_format") == 2 then
    function EHILootSharedMaster:Format()
        if self._max_xp_bags > 0 then
            local max = math.min(self._max, self._max_xp_bags)
            return self._progress .. "/" .. max
        elseif self._max_random > 0 then
            local max = self._max + self._max_random
            if self._unknown_random then
                return self._progress .. "/" .. max .. "?+?"
            else
                return self._progress .. "/" .. max .. "?"
            end
        elseif self._unknown_random then
            return self._progress .. "/" .. self._max .. "+?"
        end
        return self._progress .. "/" .. self._max
    end
else
    function EHILootSharedMaster:Format()
        if self._max_xp_bags > 0 then
            local max = math.min(self._max, self._max_xp_bags)
            return self._progress .. "/" .. max
        elseif self._max_random > 0 then
            if self._unknown_random then
                return self._progress .. "/" .. self._max .. "+" .. self._max_random .. "?+?"
            else
                return self._progress .. "/" .. self._max .. "+" .. self._max_random .. "?"
            end
        elseif self._unknown_random then
            return self._progress .. "/" .. self._max .. "+?"
        end
        return self._progress .. "/" .. self._max
    end
end

---@param silent_update boolean?
function EHILootSharedMaster:DispatchUpdate(silent_update)
    self._tracking:Call(self._id, "SetText", self:Format(), silent_update)
end

function EHILootSharedMaster:SetOnlyLootCounterMode()
    self._only_loot_counter = true
end

function EHILootSharedMaster:IsRunningInOnlyLootCounterMode()
    return self._only_loot_counter
end

---@param f (fun(progress: number, max: number): boolean)?
function EHILootSharedMaster:AddWaypointFunctionCheck(f)
    self._waypoint_function_check = f
end

function EHILootSharedMaster:RunWaypointFunctionCheck()
    if self._waypoint_function_check then
        return self._waypoint_function_check(self._progress, self._max)
    end
    return true
end

---@param f fun(progress: number, max: number): boolean
function EHILootSharedMaster:AddWaypointRemoveFunctionCheck(f)
    self._waypoint_remove_function_check = f
end

function EHILootSharedMaster:RunWaypointRemoveFunctionCheck()
    if self._waypoint_remove_function_check then
        return self._waypoint_remove_function_check(self._progress, self._max)
    end
    return true
end

---@param dt number
function EHILootSharedMaster:update(dt)
    for id, data in pairs(self._loot_check_delay) do
        data.t = data.t - dt
        if data.t <= 0 then
            self._loot_check_delay[id] = nil
            self._loot_check_n = self._loot_check_n - 1
            if self._loot_check_n <= 0 then
                self:RemoveFromUpdate()
            end
            self:RandomLootDeclinedCheck(id)
            if data.callback then
                data.callback(id)
            end
        end
    end
end

---@param id number
---@param callback fun(id: number)?
function EHILootSharedMaster:AddDelayedLootDeclinedCheck(id, callback)
    self._loot_check_delay[id] = { t = 2, callback = callback }
    if self._loot_check_n == 0 then
        self:AddToUpdate()
    end
    self._loot_check_n = self._loot_check_n + 1
end

---@param progress number
---@param silent_update boolean?
function EHILootSharedMaster:SetProgress(progress, silent_update)
    local fixed_progress = progress + self._mission_loot - self._offset
    local original_max = self._max
    if self._max_xp_bags > 0 then
        self._max = math.min(self._max, self._max_xp_bags)
    end
    if self._progress ~= fixed_progress and not self._disable_counting then
        self._progress = fixed_progress
        self:DispatchUpdate(silent_update)
        if self._progress == self._max then
            self:SetCompleted()
        end
    end
    self._max = original_max
end

function EHILootSharedMaster:SetCompleted()
    self._disable_counting = true
    if self._stay_on_screen then
        self._tracking:Call(self._id, "SetCompleted", true)
        return
    elseif self._SHOW_POPUP and not self._popup_showed and not self._achievement_id then
        self._popup_showed = true
        local xp_text = self._max_xp_bags > 0 and "ehi_popup_all_xp_loot_secured" or "ehi_popup_all_loot_secured"
        managers.hud:custom_ingame_popup_text("LOOT COUNTER", managers.localization:text(xp_text), "EHI_Loot")
    end
    self:delete_listener()
end

---@param max number
function EHILootSharedMaster:SetProgressMax(max)
    if self._max_xp_bags > 0 and self._max_xp_bags >= max then
        self._max_xp_bags = 0
        self._tracking:Call(self._id, "MaxNoLongerLimited")
    end
    self._max = max
    self:DispatchUpdate()
    self._disable_counting = nil
    self:VerifyStatus()
end

---@param max number?
function EHILootSharedMaster:IncreaseProgressMax(max)
    self:SetProgressMax(self._max + (max or 1))
end

---@param max number?
function EHILootSharedMaster:DecreaseProgressMax(max)
    self:SetProgressMax(self._max - (max or 1))
end

function EHILootSharedMaster:VerifyStatus()
    self._stay_on_screen = self._max_random > 0 or self._unknown_random
    if self._progress == self._max then
        self:SetCompleted()
    end
end

---@param random number?
function EHILootSharedMaster:RandomLootSpawned(random)
    if self._max_random <= 0 or (random and random <= 0) then
        return
    elseif self._progress == self._max then
        self._tracking:Call(self._id, "MaxNoLongerLimited")
    end
    local n = random or 1
    self._max_random = self._max_random - n
    self:IncreaseProgressMax(n)
end

---@param random number?
function EHILootSharedMaster:RandomLootDeclined(random)
    if self._max_random <= 0 or (random and random <= 0) then
        return
    end
    self._max_random = self._max_random - (random or 1)
    self:SetProgressMax(self._max)
end

---@param max number?
function EHILootSharedMaster:SetMaxRandom(max)
    self._max_random = max or 0
    self:SetProgressMax(self._max)
end

---@param progress number?
function EHILootSharedMaster:IncreaseMaxRandom(progress)
    self:SetMaxRandom(self._max_random + (progress or 1))
end

---@param progress number?
function EHILootSharedMaster:DecreaseMaxRandom(progress)
    self:SetMaxRandom(self._max_random - (progress or 1))
end

---@param id number
---@param force boolean? This is here to combat desync, use it if element does not have `fail` state
function EHILootSharedMaster:RandomLootSpawnedCheck(id, force)
    if self._loot_id[id] then
        if force then
            self:IncreaseProgressMax()
        end
        return
    end
    self._loot_id[id] = true
    self:RandomLootSpawned()
end

---@param id number
function EHILootSharedMaster:RandomLootDeclinedCheck(id)
    if self._loot_id[id] then
        return
    end
    self._loot_id[id] = true
    self:RandomLootDeclined()
end

---@param random_spawned number
---@param random_total number
function EHILootSharedMaster:RandomLootSpawnedAndDeclined(random_spawned, random_total)
    local diff = random_total - random_spawned
    if diff < 0 then
        return
    end
    self:RandomLootSpawned(random_spawned)
    self:RandomLootDeclined(diff)
end

---@param state boolean?
function EHILootSharedMaster:SetUnknownRandomLoot(state)
    if state == self._unknown_random then
        return
    end
    self._unknown_random = state
    self._tracking._trackers:CallFunction(self._id, "UpdateUnknownLoot", state)
    self:DispatchUpdate()
end

function EHILootSharedMaster:SecuredMissionLoot()
    local progress = self._progress - self._mission_loot + self._offset
    self._mission_loot = self._mission_loot + 1
    self:SetProgress(progress)
end

---@param count number
function EHILootSharedMaster:SetCountOfArmoredTransports(count)
    self._n_of_loot_in_transports = count * 9
    self._n_of_loot_in_one_transport = 9
end

function EHILootSharedMaster:RandomLootSpawnedInTransport()
    if self._n_of_loot_in_transports <= 0 then
        return
    end
    self:RandomLootSpawned()
    self._n_of_loot_in_transports = self._n_of_loot_in_transports - 1
    self._n_of_loot_in_one_transport = self._n_of_loot_in_one_transport - 1
    if self._n_of_loot_in_one_transport == 0 and self._n_of_loot_in_transports > 0 then
        self._n_of_loot_in_one_transport = 9
    end
end

function EHILootSharedMaster:RandomLootDeclinedInTransport()
    if self._n_of_loot_in_transports <= 0 then
        return
    end
    self:RandomLootDeclined()
    self._n_of_loot_in_transports = self._n_of_loot_in_transports - 1
    self._n_of_loot_in_one_transport = self._n_of_loot_in_one_transport - 1
    if self._n_of_loot_in_one_transport == 0 and self._n_of_loot_in_transports > 0 then
        self._n_of_loot_in_one_transport = 9
    end
end

function EHILootSharedMaster:ExplosionInTransport()
    while self._n_of_loot_in_one_transport ~= 9 and self._n_of_loot_in_transports > 0 do
        self:RandomLootDeclinedInTransport()
    end
    if self._n_of_loot_in_transports <= 0 and self._n_of_loot_in_one_transport > 0 then
        self:RandomLootDeclined(self._n_of_loot_in_one_transport)
        self._n_of_loot_in_one_transport = 0
    end
end

---Called during GameSetup:load()
---@param progress number
---@param set_progress_remaining boolean?
function EHILootSharedMaster:SetSyncData(progress, set_progress_remaining)
    if set_progress_remaining then
        progress = self._max - progress
    end
    if progress >= self._max then
        self:delete_listener(true)
    else
        self:SetProgress(progress, true)
    end
end

---@param silent_removal boolean?
function EHILootSharedMaster:delete_listener(silent_removal)
    if silent_removal then
        self._tracking:Remove(self._id)
        self._loot._waypoint_element = nil
    else
        self._tracking:Call(self._id, "SetCompleted")
    end
    self._loot:RemoveLootMaster(self._id)
end

---@class EHILootCountSharedMaster : EHILootSharedMaster
---@field super EHILootSharedMaster
EHILootCountSharedMaster = class(EHILootSharedMaster)
function EHILootCountSharedMaster:Format()
    return tostring(self._progress)
end

---@class EHILootMaxSharedMaster : EHILootSharedMaster
---@field super EHILootSharedMaster
---@field new fun(self: self, params: EHITracker.params): self
EHILootMaxSharedMaster = class(EHILootSharedMaster)
function EHILootMaxSharedMaster:init(params)
    EHILootMaxSharedMaster.super.init(self, params)
    self._show_progress_on_finish = true
    self._params = params.xp_params or {} ---@type LootCounterTable.MaxBagsForMaxLevel
    self._refresh_max = 5
    self._stay_on_screen = true
    local function refresh(alive_players) ---@param alive_players integer
        self:Refresh()
    end
    managers.ehi_experience:AddRefreshPlayerCountListener(refresh)
    EHI:AddCallback(EHI.CallbackMessage.SyncGagePackagesCount, refresh)
    EHI:AddOnCustodyCallback(refresh)
    EHI:AddOnSpawnedCallback(function()
        self:AddToUpdate()
    end)
end

function EHILootMaxSharedMaster:post_init()
    if EHI.IsClient then
        self._loot:AddSyncListener(function(loot)
            self._offset = loot:GetSecuredBagsAmount()
        end)
    end
end

function EHILootMaxSharedMaster:update(dt)
    if self._refresh_max then
        self._refresh_max = self._refresh_max - dt
        if self._refresh_max <= 0 then
            self._refresh_max = nil
            self._xp_player_limit = managers.ehi_experience:GetPlayerXPLimit(true)
            self:Refresh()
            self:RemoveFromUpdate()
        end
    end
end

function EHILootMaxSharedMaster:VerifyStatus()
    if self._progress == self._max then
        self:SetCompleted()
    end
end

function EHILootMaxSharedMaster:Refresh()
    if self._refresh_max then
        return
    end
    local xp_per_bags, current_secured_bags = 1, nil
    if self._params.xp_per_loot then
        local xp = 0
        current_secured_bags = 0
        for loot, value in pairs(self._params.xp_per_loot) do
            local amount = managers.loot:GetSecuredBagsTypeAmount(loot)
            xp = xp + (amount * value)
            current_secured_bags = current_secured_bags + amount
        end
        xp_per_bags = managers.ehi_experience:MultiplyXPWithAllBonuses(xp, 1)
    elseif self._params.xp_per_bag_all then
        xp_per_bags = managers.ehi_experience:MultiplyXPWithAllBonuses(self._params.xp_per_bag_all, 1)
    end
    local xp_mission = managers.ehi_experience:MultiplyXPWithAllBonuses(self._params.mission_xp, 0)
    local xp_remaining_to_max = self._xp_player_limit - xp_mission
    local new_max = math.ceil(xp_remaining_to_max / xp_per_bags)
    if new_max ~= self._max then
        current_secured_bags = math.clamp((current_secured_bags or managers.loot:GetSecuredBagsAmount()) - self._offset, 0, math.huge)
        local max_secured_bags = new_max
        if new_max < self._max and self._progress > max_secured_bags then
            current_secured_bags = new_max
        end
        self._progress = math.clamp(self._progress, current_secured_bags, max_secured_bags)
        self:SetProgressMax(new_max)
    end
end

---@param amount number
function EHILootMaxSharedMaster:ObjectiveXPAwarded(amount)
    if amount <= 0 then
        return
    end
    self._params.mission_xp = (self._params.mission_xp or 0) + amount
    self:Refresh()
end