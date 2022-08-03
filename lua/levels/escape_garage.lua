local EHI = EHI
if not EHI:GetOption("show_achievement") then
    return
end
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local function bilbo_baggin()
    local bags_to_secure = managers.ehi:CountLootbagsOnTheGround()
    if bags_to_secure >= 8 then
        managers.ehi:AddTracker({
            id = "bilbo_baggin",
            icons = EHI:GetAchievementIcon("bilbo_baggin"),
            max = 8,
            remove_after_reaching_target = false,
            class = TT.AchievementProgress
        })
        EHI:AddAchievementToCounter({
            achievement = "bilbo_baggin"
        })
    end
end
local triggers =
{
    [102414] = { special_function = SF.CustomCode, f = function()
        bilbo_baggin()
    end }
}

EHI:ParseTriggers(triggers)
EHI:AddLoadSyncFunction(function(self)
    bilbo_baggin()
    self:SetTrackerProgress("bilbo_baggin", managers.loot:GetSecuredBagsAmount())
end)