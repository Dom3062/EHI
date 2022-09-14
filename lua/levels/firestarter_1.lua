local EHI = EHI
function EHI:LordOfWarAchievement()
    local weapons = managers.ehi:GetUnits("units/payday2/equipment/gen_interactable_weapon_case_2x1/gen_interactable_weapon_case_2x1", 1)
    local n_of_weapons = 0
    if type(weapons) ~= "table" then
        EHI:Log("Engine provided invalid data; aborted to avoid crash")
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
    self:ShowAchievementLootCounter({
        achievement = "lord_of_war",
        max = n_of_weapons,
        exclude_from_sync = true
    })
    self:ShowLootCounter({
        max = n_of_weapons,
        additional_loot = 1 -- 1 bag of money
    })
end

local achievements = {
    [103240] = { special_function = EHI.SpecialFunctions.CustomCodeDelayed, t = 5, f = function()
        -- This needs to be delayed because the number of required weapons are decided upon spawn
        EHI:LordOfWarAchievement()
    end}
}

EHI:ParseTriggers({}, achievements)
EHI:AddLoadSyncFunction(function(self)
    EHI:LordOfWarAchievement()
    if self:TrackerExists("lord_of_war") then
        self:SetTrackerProgress("lord_of_war", managers.loot:GetSecuredBagsTypeAmount("weapon"))
        if self:TrackerExists("LootCounter") then
            self:SetTrackerProgress("LootCounter", managers.loot:GetSecuredBagsAmount())
        end
    else
        self:SetTrackerProgress("LootCounter", managers.loot:GetSecuredBagsAmount())
    end
end)