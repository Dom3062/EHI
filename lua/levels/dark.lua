local EHI = EHI

local sewer_grate_1 =
{
    class = "ElementUnitSequenceTrigger",
    editor_name = "ehi_sewer_grate_1",
    id = 100160,
    module = "CoreElementUnitSequenceTrigger",
    values = {
        sequence_list = {
            ["1"] = {
                guis_id = 1,
                sequence = "interact",
                unit_id = 100334
            }
        },
        on_executed = {},
        enabled = true,
        trigger_times = -1,
        base_delay = 0,
    }
}

local start_index =
{
    8750, 17750, 33525, 36525
}

local params = {}
params.name = "ehi_dark"
params.activate_on_parsed = true
params.elements = {}

for _, index in ipairs(start_index) do
    local c1 = deep_clone(sewer_grate_1)
    c1.id = EHI:GetInstanceElementID(c1.id, index)
    c1.editor_name = c1.editor_name .. tostring(index)
    c1.values.sequence_list["1"].unit_id = EHI:GetInstanceUnitID(c1.values.sequence_list["1"].unit_id, index)
    params.elements[#params.elements + 1] = c1
end

managers.mission:_add_script(params)
managers.mission:_activate_mission(params.name)