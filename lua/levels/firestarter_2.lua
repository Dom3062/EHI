local EHI = EHI
local Icon = EHI.Icons
local pc_ids = { 104170, 104175, 104349, 104350, 104351, 104352, 104354, 101455 }
for _, pc_id in pairs(pc_ids) do
    managers.mission:add_runned_unit_sequence_trigger(pc_id, "interact", function(unit)
        managers.ehi:AddTracker({
            id = tostring(pc_id),
            time = 13,
            icons = { Icon.Wait }
        })
    end)
end

local MissionDoorPositions =
{
    -- Security doors
    [1] = Vector3(-2357.87, -3621.42, 489.107),
    [2] = Vector3(1221.42, -2957.87, 489.107),
    [3] = Vector3(1342.13, -2621.42, 89.1069), --101867
    [4] = Vector3(-2830.08, 341.886, 492.443) --102199
}
local MissionDoorIndex =
{
    [1] = { w_id = 101899 },
    [2] = { w_id = 101834 },
    [3] = { w_id = 101782 },
    [4] = { w_id = 101783 }
}
EHI:SetMissionDoorPosAndIndex(MissionDoorPositions, MissionDoorIndex)
local function GetNumberOfVisibleWeapons()
    local world = managers.worlddefinition
    local n = 0
    for _, index in ipairs({ 101473, 102717, 102718, 102720 }) do
        local weapon = world:get_unit(index)
        if weapon and weapon:damage() and weapon:damage()._state and weapon:damage()._state.graphic_group and weapon:damage()._state.graphic_group.grp_wpn then
            local state = weapon:damage()._state.graphic_group.grp_wpn
            if state[1] == "set_visibility" and state[2] then
                n = n + 1
            end
        end
    end
    return n
end
local function GetNumberOfVisibleOtherLoot()
    local world = managers.worlddefinition
    local n = 0
    for _, index in ipairs({ 100739, 101779, 101804, 102711, 102712, 102713, 102714, 102715, 102716, 102721, 102723, 102725 }) do
        local unit = world:get_unit(index)
        if unit and unit:damage() and unit:damage()._variables and unit:damage()._variables.var_hidden == 0 then
            n = n + 1
        end
    end
    return n
end

local LootCounter = EHI:GetOption("show_loot_counter")
local other =
{
    [107124] = { special_function = EHI.SpecialFunctions.CustomCode, f = function()
        if not LootCounter then
            return
        end
        local max = EHI:IsDifficultyOrAbove(EHI.Difficulties.Mayhem) and 2 or 1
        local goat = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) and 1 or 0
        local random_loot = GetNumberOfVisibleWeapons() + GetNumberOfVisibleOtherLoot()
        EHI:ShowLootCounterNoCheck({
            max = max,
            -- Random Loot + Goat
            additional_loot = random_loot + goat,
            offset = true
        })
    end}
}
EHI:ParseTriggers({
    mission = {},
    other = other
})