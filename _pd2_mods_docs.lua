---@meta

----------------
--- Beardlib ---
----------------

---@class CustomAchievementPackage
---@field new fun(self: self, package_id: string): self
---@field Achievement fun(self: self, achievement_id: string): CustomAchievement?
_G.CustomAchievementPackage = {}

---@class CustomAchievement
---@field GetIcon fun(self: self): string Returns icon path
---@field GetName fun(self: self): string Returns localizated name of the achievement
---@field GetObjective fun(self: self): string Returns localizated achievement objective
---@field IsUnlocked fun(self: self): boolean
_G.CustomAchievement = {}

-----------------------
--- End of Beardlib ---
-----------------------