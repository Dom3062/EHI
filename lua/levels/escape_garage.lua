local EHI = EHI
local SF = EHI.SpecialFunctions
EHI.Manager._cache.bilbo_baggin_bags = 8
---@type ParseAchievementTable
local achievements =
{
    bilbo_baggin =
    {
        elements =
        {
            [104263] = { special_function = SF.CustomCode2, f = function(self)
                self._cache.bilbo_baggin_bags = self._cache.bilbo_baggin_bags - 1
                if self._cache.bilbo_baggin_bags == 0 then
                    self._unlockable:AddAchievementProgressTracker("bilbo_baggin", 8, 0, true)
                    self._loot:AddAchievementListener({
                        achievement = "bilbo_baggin",
                        max = 8
                    })
                end
            end }
        }
    }
}

local other = {}
if EHI:IsLootCounterVisible() then
    other[104263] = EHI:AddLootCounter4(function(self, ...)
        if not self._cache.CreateCounter then
            EHI:ShowLootCounterNoChecks({ skip_offset = true })
            self._cache.CreateCounter = true
        end
        self._loot:IncreaseLootCounterProgressMax()
    end, { element = { 101999, 102000, 101442 } })
end

EHI.Manager:ParseTriggers({
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objective =
    {
        escape = 4000
    },
    no_total_xp = true
})