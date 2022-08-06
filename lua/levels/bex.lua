local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local element_sync_triggers =
{
    [102290] = { id = "VaultGas", icons = { Icon.Teargas }, hook_element = 102157 }
}
local hack_start = EHI:GetInstanceElementID(100015, 20450)
local bex_10_fail = { id = "bex_10", special_function = SF.SetAchievementFailed }
local triggers = {
    [EHI:GetInstanceElementID(100108, 35450)] = { time = 4.8, id = "SuprisePull", icons = { Icon.Wait } },
    [103919] = { time = 25 + 1 + 13, random_time = 5, id = "Van", icons = Icon.CarEscape },
    [100840] = { time = 1 + 13, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTrackerAccurate },

    [101818] = { time = 50 + 9.3, random_time = 30, id = "HeliDropLance", icons = Icon.HeliDropDrill, class = TT.Inaccurate },
    [hack_start] = { id = "ServerHack", icons = { "wp_hack" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExistsAccurate, element = EHI:GetInstanceElementID(100014, 20450) },
    [EHI:GetInstanceElementID(100016, 20450)] = { id = "ServerHack", special_function = SF.PauseTracker },

    [103701] = { id = "bex_10", status = "ok", special_function = SF.SetAchievementStatus },
    [103702] = bex_10_fail,
    [103704] = bex_10_fail,
    [102602] = { id = "bex_10", special_function = SF.SetAchievementComplete },
    [100107] = { id = "bex_10", status = "loud", class = TT.AchievementStatus, difficulty_pass = ovk_and_up },

    [102302] = { time = 28.05 + 418/30, id = "Suprise", icons = { "pd2_question" } },

    [101820] = { time = 9.3, id = "HeliDropLance", icons = Icon.HeliDropDrill, special_function = SF.SetTrackerAccurate }
}
if Network:is_client() then
    triggers[hack_start].time = 90
    triggers[hack_start].random_time = 10
    triggers[hack_start].special_function = SF.UnpauseTrackerIfExists
    triggers[hack_start].delay_only = true
    triggers[hack_start].class = TT.InaccuratePausable
    triggers[hack_start].synced = { class = TT.Pausable }
    EHI:AddSyncTrigger(hack_start, triggers[hack_start])
    triggers[EHI:GetInstanceElementID(100011, 20450)] = { id = "ServerHack", special_function = SF.RemoveTracker }
    triggers[102157] = { time = 60, random_time = 15, id = "VaultGas", icons = { "teargas" }, class = TT.Inaccurate, special_function = SF.AddTrackerIfDoesNotExist }
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

EHI:ParseTriggers(triggers)