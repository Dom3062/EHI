local EHI = EHI
if EHI:CheckLoadHook("LevelsTweakData") then
	return
end

function LevelsTweakData:GetGroupAIState()
	local level_data = self[Global.game_settings.level_id] or {}
    return level_data.group_ai_state or "besiege"
end

function LevelsTweakData:IsLevelSkirmish()
	return self:GetGroupAIState() == "skirmish"
end

function LevelsTweakData:IsLevelSafehouse()
	local level_id = Global.game_settings.level_id
	local level_data = self[level_id] or {}
	return level_data.is_safehouse or level_id == "safehouse"
end

function LevelsTweakData:IsStealthAvailable()
	local level_id = Global.game_settings.level_id
	local level_data = self[level_id] or {}
	-- In case the heist will require stealth completion but does not have XP bonus
    -- Big Oil Day 2 is exception to this rule because guards have pagers
	return level_data.ghost_bonus or level_data.ghost_required or level_data.ghost_required_visual or level_id == "welcome_to_the_jungle_2"
end

function LevelsTweakData:IsStealthRequired()
	local level_data = self[Global.game_settings.level_id] or {}
	return level_data.ghost_required or level_data.ghost_required_visual
end

function LevelsTweakData:IsLevelChristmas()
	local level_data = tweak_data.levels[Global.game_settings.level_id] or {}
	return level_data.is_christmas_heist
end