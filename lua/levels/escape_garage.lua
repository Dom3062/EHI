local EHI = EHI
local SF = EHI.SpecialFunctions
local bilbo_baggin_bags = 8
local function bilbo_baggin()
    bilbo_baggin_bags = bilbo_baggin_bags - 1
    if bilbo_baggin_bags == 0 then
        managers.ehi_tracker:AddAchievementProgressTracker("bilbo_baggin", 8, 0, true)
        EHI:AddAchievementToCounter({
            achievement = "bilbo_baggin"
        })
    end
end
---@type ParseAchievementTable
local achievements =
{
    bilbo_baggin =
    {
        elements =
        {
            [104263] = { special_function = SF.CustomCode, f = bilbo_baggin }
        }
    }
}

local triggers =
{
    [102510] = { time = 10 + 10, id = "EndlessAssault", icons = EHI.Icons.EndlessAssault, class = EHI.Trackers.Warning, hint = EHI.Hints.EndlessAssault }
}

local other = {}
if EHI:IsLootCounterVisible() then
    local CreateCounter = true
    other[104263] = EHI:AddLootCounter3(function(self, ...)
        if CreateCounter then
            EHI:ShowLootCounterNoCheck({})
            CreateCounter = false
        end
        self._trackers:IncreaseLootCounterProgressMax()
    end)
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
--[[EHI:AddLoadSyncFunction(function(self)
    bilbo_baggin()
    self._trackers:SetTrackerProgress("bilbo_baggin", managers.loot:GetSecuredBagsAmount())
end)]]
EHI:AddXPBreakdown({
    objective =
    {
        escape = 4000
    },
    no_total_xp = true
})