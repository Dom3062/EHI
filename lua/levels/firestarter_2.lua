local EHI = EHI
local Icon = EHI.Icons
if EHI:GetOption("show_mission_trackers") then
    for _, pc_id in ipairs({ 104170, 104175, 104349, 104350, 104351, 104352, 104354, 101455 }) do
        managers.mission:add_runned_unit_sequence_trigger(pc_id, "interact", function(unit)
            managers.ehi_tracker:AddTracker({
                id = tostring(pc_id),
                time = 13,
                icons = { Icon.PCHack }
            })
        end)
    end
end

---@type MissionDoorTable
local MissionDoor =
{
    -- Security doors
    [Vector3(-2357.87, -3621.42, 489.107)] = 101899,
    [Vector3(1221.42, -2957.87, 489.107)] = 101834,
    [Vector3(1342.13, -2621.42, 89.1069)] = 101782, --101867
    [Vector3(-2830.08, 341.886, 492.443)] = 101783 --102199
}
EHI:SetMissionDoorPosAndIndex(MissionDoor)

local other =
{
    [104618] = EHI:AddAssaultDelay({ time = 30 + 1 + 5 + 30 + 30 })
}
if EHI:IsLootCounterVisible() then
    local Weapons = { 101473, 102717, 102718, 102720 }
    local OtherLoot = { 100739, 101779, 101804, 102711, 102712, 102713, 102714, 102715, 102716, 102721, 102723, 102725 }
    local FilterIsOk = EHI:RegisterCustomSpecialFunction(function(self, trigger, element, ...)
        if element:_check_difficulty() then
            self._trackers:SecuredMissionLoot() -- Server secured
        end
    end)
    other[107121] = EHI:AddLootCounter2(function()
        local ef = tweak_data.ehi.functions
        local max = EHI:IsMayhemOrAbove() and 2 or 1
        local goat = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) and 1 or 0
        local random_loot = ef.GetNumberOfVisibleWeapons(Weapons) + ef.GetNumberOfVisibleOtherLoot(OtherLoot)
        EHI:ShowLootCounterNoChecks({
            max = max + random_loot + goat,
            triggers =
            {
                [100249] = { special_function = FilterIsOk }, -- N-OVK
                [100251] = { special_function = FilterIsOk } -- MH+
            },
            hook_triggers = true,
            offset = true,
            client_from_start = true
        })
    end)
end

EHI:ParseTriggers({
    other = other
})
EHI:AddXPBreakdown({
    objective =
    {
        escape =
        {
            { amount = 6000, stealth = true, timer = 180 },
            { amount = 12000, stealth = true },
            { amount = 10000, loud = true }
        }
    },
    loot_all = 1000
})