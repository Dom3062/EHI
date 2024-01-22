local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local Hints = EHI.Hints
local triggers =
{
    [100391] = { id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF.SetTimeByPreplanning, data = { id = 100486, yes = 60 + 25, no = 120 + 25 }, waypoint = { icon = Icon.Escape, position_by_element = 100420 }, hint = Hints.Escape }
}
if EHI:IsClient() then
    triggers[100414] = EHI:ClientCopyTrigger(triggers[100391], { time = 25 }, true)
end

local other =
{
    [100032] = EHI:AddAssaultDelay({ time = 60 })
}

EHI:ParseTriggers({
    mission = triggers,
    other = other
})

EHI:ShowLootCounter({
    max = 8,
    offset = managers.job:current_job_id() ~= "constantine_butcher_nar"
})

local tbl =
{
    [EHI:GetInstanceUnitID(100037, 3750)] = { f = function(unit_id, unit_data, unit)
        EHI:HookWithID(unit:timer_gui(), "set_jammed", "EHI_100037_3750_unjammed", function(self, jammed, ...)
            if jammed == false then
                self:_HideWaypoint(EHI:GetInstanceElementID(100017, 3750)) -- Interact (Computer Icon)
            end
        end)
    end}
}
EHI:UpdateUnits(tbl)

local DisableWaypoints =
{
    --levels/instances/unique/sand/sand_server_hack
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b
    [EHI:GetInstanceElementID(100018, 3750)] = true -- Defend
}
-- levels/instances/unique/rvd/rvd_hackbox
-- Handled in CoreWorldInstanceManager.lua
EHI:DisableWaypoints(DisableWaypoints)