local EHI = EHI
if EHI:CheckLoadHook("WorldDefinition") then
    return
end

---@class WorldDefinition
---@field _continents table
---@field get_unit fun(self: self, id: number): Unit?

local units = {}
EHI:HookWithID(WorldDefinition, "init", "EHI_WorldDefinition_init", function(...)
    units = tweak_data.ehi.units
end)

EHI:HookWithID(WorldDefinition, "create", "EHI_WorldDefinition_create", function(self, ...)
    if self._definition.statics then
        for _, values in ipairs(self._definition.statics) do
            if units[values.unit_data.name] and not values.unit_data.instance then
                EHI._cache.MissionUnits[values.unit_data.unit_id] = units[values.unit_data.name]
            end
        end
    end
    for _, continent in pairs(self._continent_definitions) do
        if continent.statics then
            for _, values in ipairs(continent.statics) do
                if units[values.unit_data.name] and not values.unit_data.instance then
                    EHI._cache.MissionUnits[values.unit_data.unit_id] = units[values.unit_data.name]
                end
            end
        end
    end
end)

EHI:PreHookWithID(WorldDefinition, "init_done", "EHI_WorldDefinition_init_done", function(...)
    EHI:FinalizeUnits(EHI._cache.MissionUnits)
    EHI:FinalizeUnits(EHI._cache.InstanceUnits)
end)

function WorldDefinition:IgnoreDeployable(unit_id, unit_data, unit)
    if unit:base() and unit:base().SetIgnore then
        unit:base():SetIgnore()
    end
end

function WorldDefinition:IgnoreChildDeployable(unit_id, unit_data, unit)
    if unit:base() and unit:base().SetIgnoreChild then
        unit:base():SetIgnoreChild()
    end
end

function WorldDefinition:SetDeployableOffset(unit_id, unit_data, unit)
    if unit:base() and unit:base().SetOffset then
        unit:base():SetOffset(unit_data.offset or 1)
    end
end

function WorldDefinition:chasC4(unit_id, unit_data, unit)
    if not unit:digital_gui()._ehi_key then
        return
    end
    if not unit_data.instance then
        unit:digital_gui():SetIcons(unit_data.icons)
        return
    end
    if EHI:GetBaseUnitID(unit_id, unit_data.instance.start_index, unit_data.continent_index) == 100054 then
        unit:digital_gui():SetIcons(unit_data.icons)
    else
        unit:digital_gui():SetIgnore(true)
    end
end