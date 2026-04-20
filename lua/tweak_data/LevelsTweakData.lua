if EHI:CheckLoadHook("LevelsTweakData") then
    return
end
local cache = {}

---@return string
function LevelsTweakData:GetGroupAIState()
    if cache.ai_state then
        return cache.ai_state
    end
    local level_data = self[Global.game_settings.level_id] or {}
    local state = level_data.group_ai_state or "besiege"
    cache.ai_state = state
    return state
end

function LevelsTweakData:IsLevelSkirmish()
    return self:GetGroupAIState() == "skirmish"
end

function LevelsTweakData:IsLevelSafehouse()
    if cache.is_safehouse ~= nil then
        return cache.is_safehouse
    end
    local level_id =  Global.game_settings.level_id
    local level_data = self[level_id] or {}
    local safehouse = level_data.is_safehouse or level_id == "safehouse"
    cache.is_safehouse = safehouse
    return safehouse
end

function LevelsTweakData:IsStealthAvailable()
    if cache.steath_available ~= nil then
        return cache.steath_available
    end
    local level_data = self[Global.game_settings.level_id] or {}
    -- In case the heist will require stealth completion but does not have XP bonus  
    -- Big Oil Day 2 is exception to this rule because guards have pagers
    local ghost = level_data.ghost_bonus or level_data.ghost_required or level_data.ghost_required_visual or level_id == "welcome_to_the_jungle_2"
    cache.steath_available = ghost
    return ghost
end

---@return boolean
function LevelsTweakData:IsStealthRequired()
    if cache.stealth_required ~= nil then
        return cache.stealth_required
    end
    local level_data = self[level_id or Global.game_settings.level_id] or {}
    local required = level_data.ghost_required or level_data.ghost_required_visual
    cache.stealth_required = required
    return required
end

function LevelsTweakData:IsLevelChristmas()
    if cache.level_christmas ~= nil then
        return cache.level_christmas
    end
    local level_data = self[Global.game_settings.level_id] or {}
    local is_xmas = level_data.is_christmas_heist and managers.perpetual_event:get_holiday_tactics() == "BTN_XMAS"
    cache.level_christmas = is_xmas
    return is_xmas
end

function LevelsTweakData:GetLevelStealthBonus()
    if cache.stealth_bonus then
        return cache.stealth_bonus
    end
    local level_data = self[level_id or Global.game_settings.level_id] or {}
    local bonus = level_data.ghost_bonus or 0
    cache.stealth_bonus = bonus
    return bonus
end