local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
---@type ParseTriggerTable
local triggers = {
    [100643] = { time = 30, id = "CrowdAlert", icons = { Icon.Alarm }, class = TT.Warning, hint = Hints.Alarm },
    [100645] = { id = "CrowdAlert", special_function = SF.RemoveTracker }

    -- Heli Escape is in CoreWorldInstanceManager
}
if EHI.Manager._SHOW_MISSION_TRIGGERS then
    triggers[EHI:GetInstanceElementID(100088, 18200)] = { id = "VaultCode", class = TT.Code }
    ---@param self EHIManager
    local function ShowCodePart(self, arg)
        self._trackers:CallFunction("VaultCode", "SetCodePart", arg[1] + 1, arg[2], 4)
    end
    local num, pos = 0, 0
    for i = 100169, 100208, 1 do
        num = num + 1
        if num == 10 then
            num = 0
        end
        triggers[EHI:GetInstanceElementID(i, 18200)] = { special_function = SF.CustomCode2, f = ShowCodePart, arg = { pos, num } }
        if num == 0 then
            pos = pos + 1
        end
    end
    triggers[EHI:GetInstanceElementID(100281, 20000)] = { id = "VaultCode", special_function = SF.RemoveTracker }
end

---@type ParseAchievementTable
local achievements =
{
    sah_9 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [100107] = { time = 300, class = TT.Achievement.Base },
            [101878] = { special_function = SF.SetAchievementComplete },
            [101400] = { special_function = SF.SetAchievementFailed, trigger_once = true }
        },
        sync_params = { from_start = true }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 1 }) -- Diff 0.5 is applied at start -> ´delay´ MissionScriptElement 100018
}

EHI.Manager:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

EHI:UpdateUnits({
    -- Unused Grenade case
    [400178] = { f = "IgnoreDeployable" }
})
local xp_override =
{
    params =
    {
        min =
        {
            objectives = true,
            loot =
            {
                black_tablet = { times = 1 }
            }
        },
        no_max = true
    }
}
EHI:AddXPBreakdown({
    plan =
    {
        stealth =
        {
            objectives =
            {
                { amount = 4000, name = "vault_found" },
                { amount = 6000, name = "sah_entered_vault_code" },
                { amount = 4000, name = "sah_retrieved_tablet" },
                { escape = 1000 }
            },
            loot_all = 1000,
            total_xp_override = xp_override
        },
        loud =
        {
            objectives =
            {
                { amount = 6000, name = "vault_found" },
                { amount = 10000, name = "sah_entered_vault_code" },
                { amount = 6000, name = "sah_retrieved_tablet" },
                { escape = 4000 }
            },
            loot_all = 1000,
            total_xp_override = xp_override
        }
    }
})