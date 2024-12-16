---@class EHIDeployableManager
EHIDeployableManager = {}
EHIDeployableManager._all_deployables_tracker = EHI:GetOption("show_equipment_aggregate_all") and "Deployables"
EHIDeployableManager._block_abilities_or_no_throwable = EHI:GetOption("grenadecases_block_on_abilities_or_no_throwable") --[[@as boolean]]
EHIDeployableManager._equipment_map =
{
    doctor = "doctor_bag",
    ammo = "ammo_bag",
    fak = "first_aid_kit",
    grenade = "grenade_crate",
    bodybag = "bodybags_bag"
}
---@param ehi_tracker EHITrackerManager
function EHIDeployableManager:new(ehi_tracker)
    self._trackers = ehi_tracker
    self._deployables = {} ---@type table<string, { unit: UnitDeployable, tracker_type: string? }>
    return self
end

function EHIDeployableManager:SwitchToLoudMode()
    self:AddEquipmentToIgnore(self._equipment_map.bodybag)
end

function EHIDeployableManager:Spawned()
    if self._block_abilities_or_no_throwable and not managers.blackmarket:equipped_grenade_allows_pickups() then
        self:AddEquipmentToIgnore(self._equipment_map.grenade)
        self._trackers:RemoveTracker("GrenadeCases")
    end
end

---@param type string
function EHIDeployableManager:AddEquipmentToIgnore(type)
    self._trackers:CallFunction("Deployables", "AddToIgnore", type)
    self._deployables_ignore = self._deployables_ignore or {}
    self._deployables_ignore[type] = true
end

---@param tracker_type string?
---@return boolean
function EHIDeployableManager:IsDeployableAllowed(tracker_type)
    if not (tracker_type and self._deployables_ignore) then
        return true
    end
    return not self._deployables_ignore[tracker_type]
end

---@param ehi_tracker string
---@param key string
---@param unit UnitDeployable
---@param tracker_type string?
function EHIDeployableManager:AddToCache(ehi_tracker, key, unit, tracker_type)
    if not key then
        return
    end
    self._deployables[key] = { unit = unit, tracker_type = tracker_type }
    self._trackers:CallFunction(ehi_tracker, "UpdateAmount", key, 0, tracker_type)
end

---@param ehi_tracker string
---@param key string
function EHIDeployableManager:LoadFromCache(ehi_tracker, key)
    if not key then
        return
    end
    local deployable = table.remove_key(self._deployables, key)
    if deployable and self:IsDeployableAllowed(deployable.tracker_type) then
        self:UpdateAmount(key, deployable.unit:base():GetRealAmount(), deployable.tracker_type, ehi_tracker)
    end
end

---@param key string
function EHIDeployableManager:RemoveFromCache(key)
    if not key then
        return
    end
    self._deployables[key] = nil
end

---@param type string
---@param tracker_type string?
function EHIDeployableManager:CreateDeployableTracker(type, tracker_type)
    if type == "Deployables" and self:IsDeployableAllowed(tracker_type) then
        self._trackers:AddTracker({
            id = "Deployables",
            icons = { "deployables" },
            ignore = self._deployables_ignore,
            format = { ammo_bag = "percent" },
            hint = "deployables",
            class = "EHIAggregatedEquipmentTracker"
        })
    elseif type == "Health" then
        self._trackers:AddTracker({
            id = "Health",
            format = {},
            hint = "doctor_fak",
            class = "EHIAggregatedHealthEquipmentTracker"
        })
    elseif type == "DoctorBags" then
        self._trackers:AddTracker({
            id = "DoctorBags",
            icons = { "doctor_bag" },
            hint = "doctor_bag",
            class = "EHIEquipmentTracker"
        })
    elseif type == "AmmoBags" then
        self._trackers:AddTracker({
            id = "AmmoBags",
            format = "percent",
            icons = { "ammo_bag" },
            hint = "ammo_bag",
            class = "EHIEquipmentTracker"
        })
    elseif type == "BodyBags" and self:IsDeployableAllowed(self._equipment_map.bodybag) then
        self._trackers:AddTracker({
            id = "BodyBags",
            icons = { "bodybags_bag" },
            hint = "bodybags_bag",
            remove_on_alarm = true,
            class = "EHIEquipmentTracker"
        })
    elseif type == "FirstAidKits" then
        self._trackers:AddTracker({
            id = "FirstAidKits",
            icons = { "first_aid_kit" },
            dont_show_placed = true,
            hint = "fak",
            class = "EHIEquipmentTracker"
        })
    elseif type == "GrenadeCases" and self:IsDeployableAllowed(self._equipment_map.grenade) then
        self._trackers:AddTracker({
            id = "GrenadeCases",
            icons = { "frag_grenade" },
            hint = "throwables",
            class = "EHIEquipmentTracker"
        })
    end
end

---@param key string
---@param amount number
---@param id string
---@param t_id string
function EHIDeployableManager:UpdateAmount(key, amount, id, t_id)
    local tracker = self._all_deployables_tracker or t_id
    if self._trackers:TrackerDoesNotExist(tracker) and amount > 0 then
        self:CreateDeployableTracker(tracker, id)
    end
    self._trackers:CallFunction(tracker, "UpdateAmount", key, amount, id)
end

if _G.IS_VR then
    dofile(EHI.LuaPath .. "EHIDeployableManagerVR.lua")
end