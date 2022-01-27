local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local c4_drop = { time = 120 + 25 + 0.25 + 2, id = "C4Drop", icons = Icon.HeliDropC4 }
local c4_wp = Vector3(0, 0, 50)
local vectors =
{ -- The rotation is taken directly from the game by Lua (it is not the same as in the decompiled mission script)
    [26550] = EHI:GetInstanceElementPosition(Vector3(1175.0, -1375.0, -12.6262), c4_wp, Rotation(-44.9999, 0, 0)),
    [26650] = EHI:GetInstanceElementPosition(Vector3(6325.0, 2325.0, 0.0), c4_wp, Rotation(0, 0, -0)),
    [26750] = EHI:GetInstanceElementPosition(Vector3(2425.0, 4325.0, 1201.0), c4_wp, Rotation(44.9999, 0, -0)),
    [26850] = EHI:GetInstanceElementPosition(Vector3(925.0, 10575.0, -12.6262), c4_wp, Rotation(-135, 0, -0)),
    [26950] = EHI:GetInstanceElementPosition(Vector3(1550.0, 925.0, 1200.0), c4_wp, Rotation(135, 0, -0))
}
local triggers = {
    [101644] = { time = 60, id = "BainWait", icons = { Icon.Wait } },
    [EHI:GetInstanceElementID(100047, 21250)] = { time = 1 + 60 + 60 + 60 + 20, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot },
    [100795] = { time = 5, id = "C4", icons = { "pd2_c4" } },

    [101240] = c4_drop,
    [101241] = c4_drop,
    [101242] = c4_drop,
    [101243] = c4_drop,
    [101249] = c4_drop,
}
for i = 26550, 26950, 100 do
    triggers[EHI:GetInstanceElementID(100003, i)] = { id = EHI:GetInstanceElementID(100021, i), special_function = SF.ShowWaypoint, data = { icon = "pd2_c4", position = vectors[i] }}
end

EHI:ParseTriggers(triggers)