if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

local EHI = EHI
if EHI._hooks.LootManager then
	return
else
	EHI._hooks.LootManager = true
end
local check_types = {
    AllLoot = 1, -- Currently unused
    BagsOnly = 2,
    ValueOfBags = 3,
    SmallLootOnly = 4, -- Currently unused
    ValueOfSmallLoot = 5,
    OneTypeOfLoot = 6,
    MultipleTriggers = 7
}
local LootCounter =
{
    spa = true, -- Brooklyn 10-10
    friend = true, -- Scarface Mansion
    dark = true, -- Murky Station
    wwh = true, -- Alaskan Deal
    --alex_3 = true, -- Rats Day 3
    --rvd1 = true -- Reservoir Dogs Heist Day 2
    -- Custom Heist
    rusdl = true,
    hunter_departure = true
}
local level_id = Global.game_settings.level_id
local tracker_id = nil
local check_type = nil
local multiple_check_type = {}
local loot_type = nil
local sync_only = false
if level_id == "mex_cooking" then -- Border Crystals
    check_type = check_types.BagsOnly
    tracker_id = "mex2_9"
elseif level_id == "cane" then -- Santa's Workshop
    check_type = check_types.BagsOnly
    tracker_id = "cane_3"
elseif level_id == "crojob2" then -- The Bomb: Dockyard
    check_type = check_types.OneTypeOfLoot
    loot_type = "meth"
    tracker_id = "voff_2"
elseif level_id == "pal" then -- Counterfeit
    check_type = check_types.BagsOnly
    tracker_id = "pal_2"
elseif level_id == "pex" then -- Breakfast in Tijuana
    check_type = check_types.BagsOnly
    tracker_id = "pex_10"
elseif level_id == "dah" then -- Diamond Heist
    check_type = check_types.OneTypeOfLoot
    loot_type = "diamondheist_big_diamond"
    tracker_id = "dah_8"
    sync_only = true
elseif level_id == "alex_1" or level_id == "rat" then -- Rats Day 1 / Cook Off
    check_type = check_types.BagsOnly
    tracker_id = "halloween_2"
elseif level_id == "chas" then -- Dragon Heist
    check_type = check_types.BagsOnly
    tracker_id = "chas_10"
elseif level_id == "brb" then -- Brooklyn Bank
    check_type = check_types.OneTypeOfLoot
    loot_type = "gold"
    tracker_id = "brb_8"
elseif level_id == "rvd2" then -- Reservoir Dogs Heist Day 1
    check_type = check_types.OneTypeOfLoot
    loot_type = { "diamonds_dah", "diamonds" }
    tracker_id = "rvd_11"
elseif level_id == "pbr" then -- Beneath the Mountain
    check_type = check_types.BagsOnly
    tracker_id = EHI:IsAchievementLocked("berry_2") and "berry_2" or "LootCounter"
elseif level_id == "mus" then -- The Diamond
    check_type = check_types.OneTypeOfLoot
    loot_type = { "mus_artifact_paint", "mus_artifact" }
    tracker_id = "bat_3"
elseif level_id == "shoutout_raid" then -- Meltdown
    if EHI:IsAchievementLocked("melt_3") then
        check_type = check_types.MultipleTriggers
        multiple_check_type = { check_types.OneTypeOfLoot, check_types.OneTypeOfLoot }
        loot_type = { "warhead", { "coke", "gold", "money", "weapon", "weapons" } }
        tracker_id = { "LootCounter", "melt_3" }
    else
        check_type = check_types.BagsOnly
        tracker_id = "LootCounter"
    end
elseif level_id == "arm_for" then -- Transport: Train Heist
    if EHI:IsAchievementLocked("armored_1") then
        check_type = check_types.MultipleTriggers
        multiple_check_type = { check_types.OneTypeOfLoot, check_types.OneTypeOfLoot }
        loot_type = { "turret", "ammo" }
        tracker_id = { "LootCounter", "armored_1" }
    else
        check_type = check_types.BagsOnly
        tracker_id = "LootCounter"
    end
elseif level_id == "sand" then -- Ukrainian Prisoner Heist
    check_type = check_types.BagsOnly
    tracker_id = "sand_9"
elseif level_id == "dinner" then -- Slaughterhouse
    if EHI:IsDifficultyOrAbove("overkill") and EHI:IsAchievementLocked("farm_6") then
        check_type = check_types.MultipleTriggers
        multiple_check_type = { check_types.OneTypeOfLoot, check_types.OneTypeOfLoot }
        loot_type = { "gold", "din_pig" }
        tracker_id = { "LootCounter", "farm_6" }
    else
        check_type = check_types.BagsOnly
        tracker_id = "LootCounter"
    end
elseif level_id == "firestarter_1" then -- Firestarter Day 1
    check_type = check_types.BagsOnly
    if EHI:IsAchievementLocked("lord_of_war") then
        tracker_id = "lord_of_war"
    else
        tracker_id = "LootCounter"
    end
elseif level_id == "big" then -- The Big Bank
    check_type = check_types.BagsOnly
    tracker_id = "bigbank_3"
elseif level_id == "mallcrasher" and EHI:IsDifficulty("overkill") and EHI:IsAchievementLocked("ameno_3") then -- Mallcrasher
    check_type = check_types.ValueOfSmallLoot
    tracker_id = "ameno_3"
elseif level_id == "branchbank" or level_id == "branchbank_gold" or level_id == "branchbank_cash" or level_id == "branchbank_deposit" then
    check_type = check_types.ValueOfBags
    tracker_id = "uno_1"
elseif LootCounter[level_id] then
    check_type = check_types.BagsOnly
    tracker_id = "LootCounter"
else
    return
end

local original =
{
    sync_secure_loot = LootManager.sync_secure_loot,
    sync_load = LootManager.sync_load
}

function LootManager:sync_secure_loot(...)
    original.sync_secure_loot(self, ...)
    if not sync_only then
        self:EHIReportProgress()
    end
end

function LootManager:GetSecuredBagsAmount()
    local mandatory = self:get_secured_mandatory_bags_amount()
    local bonus = self:get_secured_bonus_bags_amount()
    local total = (mandatory or 0) + (bonus or 0)
    return total
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
    tid = tid or tracker_id
    ct = ct or check_type
    lt = lt or loot_type
    if ct == check_types.AllLoot then
    elseif ct == check_types.BagsOnly then
        managers.ehi:SetTrackerProgress(tid, self:GetSecuredBagsAmount())
    elseif ct == check_types.ValueOfBags then
        managers.ehi:SetTrackerProgress(tid, self:GetSecuredBagsValueAmount())
    elseif ct == check_types.SmallLootOnly then
    elseif ct == check_types.ValueOfSmallLoot then
        managers.ehi:SetTrackerProgress(tid, self:get_real_total_small_loot_value())
    elseif ct == check_types.OneTypeOfLoot then
        if lt then
            local secured = 0
            if type(lt) == "string" then
                for _, data in ipairs(self._global.secured) do
                    if data.carry_id == lt then
                        secured = secured + 1
                    end
                end
            elseif type(lt) == "table" then
                for _, carry_id in pairs(lt) do
                    for _, data in ipairs(self._global.secured) do
                        if data.carry_id == carry_id then
                            secured = secured + 1
                        end
                    end
                end
            end
            managers.ehi:SetTrackerProgress(tid, secured)
        end
    elseif ct == check_types.MultipleTriggers then
        for i, value in ipairs(multiple_check_type) do
            self:EHIReportProgress(tracker_id[i], value, loot_type[i])
        end
    end
end

function LootManager:sync_load(...)
    original.sync_load(self, ...)
    self:EHIReportProgress()
end