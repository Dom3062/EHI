function EHI:LordOfWarAchievement()
    local achievement_locked = self:IsAchievementLocked("lord_of_war")
    local tracker_id = achievement_locked and "lord_of_war" or "LootCounter"
    local icon = achievement_locked and "C_Hector_H_Firestarter_Lord" or "pd2_loot"
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
    managers.ehi:AddTracker({
        id = tracker_id,
        max = n_of_weapons + (achievement_locked and 0 or 1),
        icons = { icon },
        class = "EHIProgressTracker"
    })
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