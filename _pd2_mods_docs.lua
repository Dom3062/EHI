---@meta

----------------
--- SuperBLT ---
----------------

---@class Hooks
---@field Add fun(self: self, key: string, id: string, func: function)
---@field PostHook fun(self: self, object: table, func: string, id: string, post_call: function)
---@field PreHook fun(self: self, object: table, func: string, id: string, pre_call: function)
---@field RemovePostHook fun(self: self, id: string)
_G.Hooks = {}

-----------------------
--- End of SuperBLT ---
-----------------------

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

----------------------------
--- Why Are You Running? ---
----------------------------

---@class SWAYRMod
---@field included fun(level_id: string): boolean
_G.SWAYRMod = {}

-----------------------------------
--- End of Why Are You Running? ---
-----------------------------------