local EHI = EHI
local SF = EHI.SpecialFunctions
local function LordOfWarAchievement()
    local weapons = managers.ehi:GetUnits("units/payday2/equipment/gen_interactable_weapon_case_2x1/gen_interactable_weapon_case_2x1", 1)
    local n_of_weapons = 0
    if type(weapons) ~= "table" then
        EHI:Log("[firestarter_1.lua] Engine provided invalid data; aborted to avoid crash")
        return
    end
    for _, weapon in pairs(weapons) do
        if weapon:damage()._state and weapon:damage()._state.graphic_group and weapon:damage()._state.graphic_group.grp_wpn then
            local state = weapon:damage()._state.graphic_group.grp_wpn
            if state[1] == "set_visibility" and state[2] then
                n_of_weapons = n_of_weapons + 1
            end
        end
    end
    EHI:ShowAchievementLootCounter({
        achievement = "lord_of_war",
        max = n_of_weapons,
        triggers =
        {
            [103427] = { special_function = SF.SetAchievementFailed, trigger_times = 1 } -- Weapons destroyed
        },
        hook_triggers = true
    })
    if EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish) then
        EHI:ShowAchievementLootCounter({
            achievement = "ovk_10",
            max = n_of_weapons,
            triggers =
            {
                [103427] = { special_function = SF.IncreaseProgress } -- Weapons destroyed
            },
            hook_triggers = true
        })
    end
    EHI:ShowLootCounter({
        max = n_of_weapons,
        additional_loot = 1, -- 1 bag of money
        triggers =
        {
            [103427] = { special_function = SF.DecreaseProgressMax }, -- Weapons destroyed
            [104470] = { special_function = SF.DecreaseProgressMax }, -- Money destroyed
            [104471] = { special_function = SF.DecreaseProgressMax }, -- Money destroyed
            [104472] = { special_function = SF.DecreaseProgressMax }, -- Money destroyed
            [104473] = { special_function = SF.DecreaseProgressMax } -- Money destroyed
        },
        hook_triggers = true
    })
end

local other =
{
    -- This needs to be delayed because the number of required weapons are decided upon spawn
    [103240] = { special_function = SF.CustomCodeDelayed, t = 5, f = LordOfWarAchievement }
}

EHI:ParseTriggers({
    mission = {},
    other = other
})
--[[EHI:AddLoadSyncFunction(function(self)
    LordOfWarAchievement()
    if self:TrackerExists("lord_of_war") then
        self:SetTrackerProgress("lord_of_war", managers.loot:GetSecuredBagsTypeAmount("weapon"))
        if self:TrackerExists("LootCounter") then
            self:SetTrackerProgress("LootCounter", managers.loot:GetSecuredBagsAmount())
        end
    else
        self:SetTrackerProgress("LootCounter", managers.loot:GetSecuredBagsAmount())
    end
end)]]