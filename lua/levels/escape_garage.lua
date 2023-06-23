local EHI = EHI
local SF = EHI.SpecialFunctions
local bilbo_baggin_bags = 0
local function bilbo_baggin()
    bilbo_baggin_bags = bilbo_baggin_bags + 1
    if bilbo_baggin_bags == 8 then
        managers.ehi_tracker:AddAchievementProgressTracker("bilbo_baggin", 8, 0, false)
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
            [102414] = { special_function = SF.CustomCode, f = bilbo_baggin }
        }
    }
}

local other =
{
    [102414] = EHI:AddLootCounter(tweak_data.ehi.functions.ShowNumberOfLootbagsOnTheGround)
}
--[[if EHI:IsLootCounterVisible() then
    local CreateCounter = true
    other[104263] = EHI:AddLootCounter3(function(self, ...)
        if CreateCounter then
            EHI:ShowLootCounterNoCheck({})
            CreateCounter = false
        end
        self._trackers:IncreaseLootCounterProgressMax()
    end)
end]]

--[[if EHI:IsClient() then
    achievements.bilbo_baggin.elements[102414].special_function = SF.CustomCodeDelayed
    achievements.bilbo_baggin.elements[102414].t = 1
    if other[102414] then
        other[102414].special_function = SF.CustomCodeDelayed
        other[102414].t = 1
    end
end]]

EHI:ParseTriggers({
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