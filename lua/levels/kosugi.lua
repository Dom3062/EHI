local sewer_gate_1 =
{
    class = "ElementUnitSequenceTrigger",
    editor_name = "ehi_sewer_gate_1",
    id = 105500,
    module = "CoreElementUnitSequenceTrigger",
    values = {
        sequence_list = {
            ["1"] = {
                guis_id = 1,
                sequence = "interact",
                unit_id = 100098
            }
        },
        on_executed = {},
        enabled = true,
        trigger_times = -1,
        base_delay = 0,
    }
}

local sewer_gate_2 =
{
    class = "ElementUnitSequenceTrigger",
    editor_name = "ehi_sewer_gate_2",
    id = 105501,
    module = "CoreElementUnitSequenceTrigger",
    values = {
        sequence_list = {
            ["1"] = {
                guis_id = 1,
                sequence = "interact",
                unit_id = 102897
            }
        },
        on_executed = {},
        enabled = true,
        trigger_times = -1,
        base_delay = 0,
    }
}

local sewer_gate_3 =
{
    class = "ElementUnitSequenceTrigger",
    editor_name = "ehi_sewer_gate_3",
    id = 105502,
    module = "CoreElementUnitSequenceTrigger",
    values = {
        sequence_list = {
            ["1"] = {
                guis_id = 1,
                sequence = "interact",
                unit_id = 102899
            }
        },
        on_executed = {},
        enabled = true,
        trigger_times = -1,
        base_delay = 0,
    }
}

local sewer_gate_4 =
{
    class = "ElementUnitSequenceTrigger",
    editor_name = "ehi_sewer_gate_4",
    id = 105503,
    module = "CoreElementUnitSequenceTrigger",
    values = {
        sequence_list = {
            ["1"] = {
                guis_id = 1,
                sequence = "interact",
                unit_id = 102900
            }
        },
        on_executed = {},
        enabled = true,
        trigger_times = -1,
        base_delay = 0,
    }
}

local params = {}
params.name = "ehi_kosugi"
params.activate_on_parsed = true
params.elements = {
    sewer_gate_1,
    sewer_gate_2,
    sewer_gate_3,
    sewer_gate_4
}

managers.mission:_add_script(params)
managers.mission:_activate_mission(params.name)