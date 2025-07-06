local EHI = EHI
local SF = EHI.SpecialFunctions

dofile(EHI.LuaPath .. "levels/skm_base.lua")

local other = {}
if EHI:GetOption("show_sniper_tracker") then
    if EHI:GetOption("show_sniper_logic_start_popup") then
        other[300237] = { special_function = SF.CustomCode, f = function()
            managers.hud:ShowSniperLogic(true)
        end }
    end
    if EHI:GetOption("show_sniper_spawned_popup") then
        local function ShowSniperPopup()
            managers.hud:ShowSnipersSpawned(true)
        end
        local Trigger = EHI.Trigger:RegisterCustomSF(function(self, trigger, ...)
            DelayedCalls:Add(trigger.id, trigger.time, ShowSniperPopup)
        end)
        other[302098] = { id = "EHI_302098_20s", time = 20, special_function = Trigger }
        other[302099] = { id = "EHI_302099_50s", time = 50, special_function = Trigger }
        other[302100] = { id = "EHI_302100_60s", time = 60, special_function = Trigger }
        other[302101] = { id = "EHI_302101_10s", time = 10, special_function = Trigger }
        other[302102] = { id = "EHI_302102_30s", time = 30, special_function = Trigger }
        other[302103] = { id = "EHI_302103_60s", time = 60, special_function = Trigger }
        other[302104] = { id = "EHI_302104_15s", time = 15, special_function = Trigger }
        other[302105] = { id = "EHI_302105_40s", time = 40, special_function = Trigger }
    end
end
EHI.Mission:ParseTriggers({
    other = other
})