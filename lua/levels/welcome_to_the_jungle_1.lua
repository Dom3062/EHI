local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local other = {
    [102064] = EHI:AddAssaultDelay({ control = 60 + 1, trigger_once = true })
}

---@type ParseAchievementTable
local achievements =
{
    cac_24 =
    {
        elements =
        {
            [101282] = { time = 60, class = TT.Achievement.Base },
            [101285] = { special_function = SF.SetAchievementComplete }
        }
    }
}
managers.ehi_hudlist:CallRightListItemFunction("Unit", "EnablePersistentSniperItem")
EHI.Unit:IgnoreCarryInHudlist(100886, 100872) -- Money and gold behind abandoned factory (blocked entrance)
EHI.Unit:IgnoreInteractInHudlist(100866, 100867, 100868) -- Gold bar, gold coins and jewelry (same place as above)

EHI.Mission:ParseTriggers({
    achievement = achievements,
    other = other,
    assault =
    {
        diff_load_sync = function(self, assault_number, in_assault)
            if self.ConditionFunctions.IsStealth() then
                return
            elseif assault_number <= 0 or (assault_number == 1 and in_assault) then
                self._assault:SetDiff(0.5)
            elseif (assault_number == 1 and not in_assault) or (assault_number == 2 and in_assault) then
                self._assault:SetDiff(0.75)
            else
                self._assault:SetDiff(1)
            end
        end
    }
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 1500, name = "big_oil_intel_pickup", times = 3, optional = true },
        { amount = 6000, name = "twh_safe_open", times = 1 },
        { escape = {
            { amount = 6000, stealth = true, ghost_bonus = tweak_data.levels:GetLevelStealthBonus() },
            { amount = 6000, loud = true }
        } }
    },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                objectives =
                {
                    big_oil_intel_pickup = { min = 0, max = 3 },
                    twh_safe_open = { min_max = 1 }
                },
                escape = 6000
            }
        }
    }
})