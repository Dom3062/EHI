---@param achievements ParseAchievementTable Table with achievements
---@param package string Beardlib package where achievements are stored
---@param exclude table? If the achievement table contains vanilla achievements, provide their ID so they don't get marked as from Beardlib
function EHI:PreparseBeardlibAchievements(achievements, package, exclude)
    exclude = exclude or {}
    for id, data in pairs(achievements or {}) do
        if not exclude[id] then
            data.beardlib = true
            data.package = package
        end
    end
end

---Currently one custom mission is using this, if any other custom will be using this, the function should be rewritten
---@param achievement string
---@param max number
---@param difficulty_check number Difficulty or above
function EHI:ShowBeardLibAchievementLootCounter_Mallbank(achievement, max, difficulty_check)
    if self:IsBeardLibAchievementUnlocked("Mallbank", achievement) or not self:IsDifficultyOrAbove(difficulty_check) then
        return
    end
    managers.ehi_tracker:AddTracker({
        beardlib = true,
        id = achievement,
        max = max,
        icons = { "ehi_" .. achievement },
        show_finish_after_reaching_target = true,
        class = self.Trackers.Achievement.Progress
    })
    managers.ehi_loot:AddAchievementListener({
        achievement = achievement,
        max = max
    })
end

if EHI:GetUnlockableOption("hide_unlocked_achievements") then
    ---@param package_id string
    ---@param achievement_id string
    function EHI:IsBeardLibAchievementUnlocked(package_id, achievement_id)
        return not self:IsBeardLibAchievementLocked(package_id, achievement_id)
    end
else -- Always show trackers for achievements
    ---@param package_id string
    ---@param achievement_id string
    function EHI:IsBeardLibAchievementUnlocked(package_id, achievement_id)
        self:IsBeardLibAchievementLocked(package_id, achievement_id, true)
        return false
    end
end

---@param package_id string Package ID in Beardlib
---@param achievement_id string
---@param skip_check boolean?
function EHI:IsBeardLibAchievementLocked(package_id, achievement_id, skip_check)
    local Achievement = CustomAchievementPackage:new(package_id):Achievement(achievement_id)
    if not Achievement or (Achievement:IsUnlocked() and not skip_check) then
        return false
    end
    self._cache.Beardlib = self._cache.Beardlib or {}
    self._cache.Beardlib[achievement_id] = { name = Achievement:GetName(), objective = Achievement:GetObjective() }
    tweak_data.hud_icons["ehi_" .. achievement_id] = { texture = Achievement:GetIcon() }
    return true
end