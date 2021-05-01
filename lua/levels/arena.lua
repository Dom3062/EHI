local EHI = EHI

local cutter_1 =
{
    class = "ElementUnitSequenceTrigger",
    editor_name = "ehi_cutter",
    id = 100160,
    module = "CoreElementUnitSequenceTrigger",
    values = {
        sequence_list = {
            ["1"] = {
                guis_id = 1,
                sequence = "interact",
                unit_id = 100067
            }
        },
        on_executed = {},
        enabled = true,
        trigger_times = -1,
        base_delay = 0,
    }
}

local cutter_2 =
{
    class = "ElementUnitSequenceTrigger",
    editor_name = "ehi_cutter2",
    id = 100161,
    module = "CoreElementUnitSequenceTrigger",
    values = {
        sequence_list = {
            ["1"] = {
                guis_id = 1,
                sequence = "interact",
                unit_id = 100093
            }
        },
        on_executed = {},
        enabled = true,
        trigger_times = -1,
        base_delay = 0,
    }
}

local cutter_3 =
{
    class = "ElementUnitSequenceTrigger",
    editor_name = "ehi_cutter3",
    id = 100162,
    module = "CoreElementUnitSequenceTrigger",
    values = {
        sequence_list = {
            ["1"] = {
                guis_id = 1,
                sequence = "interact",
                unit_id = 100094
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
    4500, 5400, 5800, 6000, 6200, 6600
}

local params = {}
params.name = "ehi_arena"
params.activate_on_parsed = true
params.elements = {}

for _, index in ipairs(start_index) do
    local c1 = deep_clone(cutter_1)
    c1.id = EHI:GetInstanceElementID(c1.id, index)
    c1.editor_name = c1.editor_name .. tostring(index)
    c1.values.sequence_list["1"].unit_id = EHI:GetInstanceUnitID(c1.values.sequence_list["1"].unit_id, index)
    params.elements[#params.elements + 1] = c1
    local c2 = deep_clone(cutter_2)
    c2.id = EHI:GetInstanceElementID(c2.id, index)
    c2.editor_name = c2.editor_name .. tostring(index)
    c2.values.sequence_list["1"].unit_id = EHI:GetInstanceUnitID(c2.values.sequence_list["1"].unit_id, index)
    params.elements[#params.elements + 1] = c2
    local c3 = deep_clone(cutter_3)
    c3.id = EHI:GetInstanceElementID(c3.id, index)
    c3.editor_name = c3.editor_name .. tostring(index)
    c3.values.sequence_list["1"].unit_id = EHI:GetInstanceUnitID(c3.values.sequence_list["1"].unit_id, index)
    params.elements[#params.elements + 1] = c3
end

managers.mission:_add_script(params)
managers.mission:_activate_mission(params.name)