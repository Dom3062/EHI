local EHI = EHI
if EHI._hooks.LootManager then
	return
else
	EHI._hooks.LootManager = true
end
local check_types = EHI.LootCounter.CheckType
local LootCounter =
{
    --alex_3 = true, -- Rats Day 3
    --rvd1 = true -- Reservoir Dogs Heist Day 2
}

function LootManager:GetSecuredBagsAmount()
    local mandatory = self:get_secured_mandatory_bags_amount()
    local bonus = self:get_secured_bonus_bags_amount()
    local total = (mandatory or 0) + (bonus or 0)
    return total
end

function LootManager:GetSecuredBagsTypeAmount(t)
    local secured = 0
    if type(t) == "string" then
        for _, data in ipairs(self._global.secured) do
            if data.carry_id == t then
                secured = secured + 1
            end
        end
    elseif type(t) == "table" then
        for _, carry_id in pairs(t) do
            for _, data in ipairs(self._global.secured) do
                if data.carry_id == carry_id then
                    secured = secured + 1
                end
            end
        end
    end
    return secured
end

function LootManager:GetSecuredBagsValueAmount()
    local value = 0
    for _, data in pairs(self._global.secured) do
        if not tweak_data.carry.small_loot[data.carry_id] then
            value = value + managers.money:get_secured_bonus_bag_value(data.carry_id, data.multiplier)
        end
    end
    return value
end

function LootManager:EHIReportProgress(tid, ct, lt)
    if ct == check_types.AllLoot then
    elseif ct == check_types.BagsOnly then
        managers.ehi:SetTrackerProgress(tid, self:GetSecuredBagsAmount())
    elseif ct == check_types.ValueOfBags then
        managers.ehi:SetTrackerProgress(tid, self:GetSecuredBagsValueAmount())
    elseif ct == check_types.SmallLootOnly then
    elseif ct == check_types.ValueOfSmallLoot then
        managers.ehi:SetTrackerProgress(tid, self:get_real_total_small_loot_value())
    elseif ct == check_types.OneTypeOfLoot then
        managers.ehi:SetTrackerProgress(tid, self:GetSecuredBagsTypeAmount(lt))
    end
end