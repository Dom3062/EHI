function EHI:LordOfWarAchievement()
    local weapons = managers.ehi:GetUnits("units/payday2/equipment/gen_interactable_weapon_case_2x1/gen_interactable_weapon_case_2x1", 1)
    local n_of_weapons = 0
    for _, weapon in pairs(weapons) do
        if weapon:damage()._state and weapon:damage()._state.graphic_group and weapon:damage()._state.graphic_group.grp_wpn then
            local state = weapon:damage()._state.graphic_group.grp_wpn
            if state[1] == "set_visibility" and state[2] then
                n_of_weapons = n_of_weapons + 1
            end
        end
    end
    self:ShowAchievementLootCounter({
        achievement = "lord_of_war",
        max = n_of_weapons,
        additional_loot = 1,
        show_loot_counter = true,
        exclude_from_sync = true
    })
    if managers.ehi:TrackerDoesNotExist("LootCounter") then
        self:ShowLootCounter(1, 0, self.LootCounter.CheckType.OneTypeOfLoot, "money")
    end
end

local triggers = {
    [103240] = { special_function = EHI.SpecialFunctions.CustomCode, f = function()
        -- This needs to be delayed because the number of required weapons are decided upon spawn
        EHI:DelayCall("LordOfWarAchievement", 5, function()
            EHI:LordOfWarAchievement()
        end)
    end}
}

EHI:ParseTriggers(triggers)
EHI:AddLoadSyncFunction(function(self)
    EHI:LordOfWarAchievement()
    if self:TrackerExists("lord_of_war") then
        self:SetTrackerProgress("lord_of_war", managers.loot:GetSecuredBagsAmount())
        if self:TrackerExists("LootCounter") then
            self:SetTrackerProgress("LootCounter", managers.loot:GetSecuredBagsTypeAmount("money"))
        end
    else
        self:SetTrackerProgress("LootCounter", managers.loot:GetSecuredBagsAmount())
    end
end)