---@class EHIDeployableManager
local EHIDeployableManager = {}
EHIDeployableManager._all_deployables_tracker = EHI:GetOption("show_equipment_aggregate_all") and "Deployables"
EHIDeployableManager._equipment_map =
{
    doctor = "doctor_bag",
    ammo = "ammo_bag",
    fak = "first_aid_kit",
    grenade = "grenade_crate",
    bodybag = "bodybags_bag"
}
EHIDeployableManager._deployables = {} ---@type table<string, { unit: UnitDeployable, tracker_type: string? }>
function EHIDeployableManager:post_init()
    EHI:AddOnAlarmCallback(function(dropin)
        self:AddEquipmentToIgnore(self._equipment_map.bodybag)
    end)
    if EHI:GetOption("grenadecases_block_on_abilities_or_no_throwable") then
        EHI.PlayerUtils:AddGrenadeDoesNotAllowPickupsCallback(function()
            self:AddEquipmentToIgnore(self._equipment_map.grenade)
            managers.ehi_tracker:ForceRemoveTracker("GrenadeCases")
        end)
    end
    if self._all_deployables_tracker then
        EHI:LoadTracker("EHIAggregatedEquipmentTracker")
    else
        if EHI:GetOption("show_equipment_aggregate_health") then
            EHI:LoadTracker("EHIAggregatedEquipmentTracker") -- EHIAggregatedHealthEquipmentTracker depends on EHIAggregatedEquipmentTracker
            EHI:LoadTracker("EHIAggregatedHealthEquipmentTracker")
        end
        if not EHIEquipmentTracker then -- Don't load it twice
            EHI:LoadTracker("EHIEquipmentTracker")
        end
    end
end

---@param type string
function EHIDeployableManager:AddEquipmentToIgnore(type)
    managers.ehi_tracker:CallFunction("Deployables", "AddToIgnore", type)
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
    managers.ehi_tracker:CallFunction(ehi_tracker, "UpdateAmount", key, 0, tracker_type)
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
        managers.ehi_tracker:AddTracker({
            id = "Deployables",
            icons = { "deployables" },
            ignore = self._deployables_ignore,
            format = { ammo_bag = "percent" },
            hint = "deployables",
            class = "EHIAggregatedEquipmentTracker"
        })
    elseif type == "Health" then
        managers.ehi_tracker:AddTracker({
            id = "Health",
            hint = "doctor_fak",
            class = "EHIAggregatedHealthEquipmentTracker"
        })
    elseif type == "DoctorBags" then
        managers.ehi_tracker:AddTracker({
            id = "DoctorBags",
            icons = { "doctor_bag" },
            hint = "doctor_bag",
            class = "EHIEquipmentTracker"
        })
    elseif type == "AmmoBags" then
        managers.ehi_tracker:AddTracker({
            id = "AmmoBags",
            format = "percent",
            icons = { "ammo_bag" },
            hint = "ammo_bag",
            class = "EHIEquipmentTracker"
        })
    elseif type == "BodyBags" and self:IsDeployableAllowed(self._equipment_map.bodybag) then
        managers.ehi_tracker:AddTracker({
            id = "BodyBags",
            icons = { "bodybags_bag" },
            hint = "bodybags_bag",
            remove_on_alarm = true,
            class = "EHIEquipmentTracker"
        })
    elseif type == "FirstAidKits" then
        managers.ehi_tracker:AddTracker({
            id = "FirstAidKits",
            icons = { "first_aid_kit" },
            dont_show_placed = true,
            hint = "fak",
            class = "EHIEquipmentTracker"
        })
    elseif type == "GrenadeCases" and self:IsDeployableAllowed(self._equipment_map.grenade) then
        managers.ehi_tracker:AddTracker({
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
---@param t_id string Tracker ID
function EHIDeployableManager:UpdateAmount(key, amount, id, t_id)
    local tracker = self._all_deployables_tracker or t_id
    if managers.ehi_tracker:DoesNotExist(tracker) and amount > 0 then
        self:CreateDeployableTracker(tracker, id)
    end
    managers.ehi_tracker:CallFunction(tracker, "UpdateAmount", key, amount, id)
end

---@param pos Vector3
---@param rot Rotation
---@param width number
---@param depth number
---@param height number
function EHIDeployableManager:AddPositionShapeCheck(pos, rot, width, depth, height)
    self._shapes = self._shapes or {} ---@type CoreShapeManager.ShapeBoxMiddle[]
    table.insert(self._shapes, CoreShapeManager.ShapeBoxMiddle:new({
        position = pos,
        rotation = rot,
        width = width,
        depth = depth,
        height = height
    }))
end

function EHIDeployableManager:RunPositionShapeChecks()
    if self._ignore_shape_check_run then
        return
    end
    self._ignore_shape_check_run = true
    if self._shape_check_callback then
        self._shape_check_callback:call()
        self._shape_check_callback = nil
    end
end

---@param unit UnitDeployable
function EHIDeployableManager:OnDeployablePlaced(unit)
    if not self._shapes then
        return
    end
    local pos = unit:position()
    local base = unit:base() --[[@as AmmoBagBase|GrenadeCrateBase]]
    for _, shape in ipairs(self._shapes) do
        if shape:is_inside(pos) then
            if self._ignore_shape_check_run then
                base:SetIgnore()
            else
                self._shape_check_callback = self._shape_check_callback or ListenerHolder:new()
                self._shape_check_callback:add(base._ehi_key, callback(base, base, "SetIgnore"))
            end
            break
        end
    end
end

---@param key string
function EHIDeployableManager:OnDeployableConsumed(key)
    if self._shape_check_callback then
        self._shape_check_callback:remove(key)
    end
end

EHI:AddCallback(EHI.CallbackMessage.InitManagers, function(managers) ---@param managers managers
    EHIDeployableManager:post_init()
end)

if _G.IS_VR then
    return blt.vm.loadfile(EHI.LuaPath .. "vr/EHIDeployableManagerVR.lua")(EHIDeployableManager)
end
return EHIDeployableManager