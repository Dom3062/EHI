local EHI = EHI
if EHI:CheckHook("tweak_data") then
    return
end
if not DOTTweakData and not Global.load_level then -- 1.143.240 version check
    EHI._cache.GameVersionNotCompatible = true
end
dofile(EHI.LuaPath .. "tweak_data/EHITweakData.lua")
tweak_data.ehi = EHITweakData:new(tweak_data)

---@param enemy_id string
---@param weapon_id string
function TweakData:GetHighestDamageFromEnemyAndWeapon(enemy_id, weapon_id)
    if not (enemy_id and weapon_id) then
        EHI:LogWithCurrentLine("Enemy ID or Weapon ID is nil, returning 0")
        return 0
    end
    local enemy_tweak_data = self.character[enemy_id]
    local weapon_tweak_data = self.weapon[weapon_id]
    if not (weapon_tweak_data and enemy_tweak_data) then
        EHI:LogWithCurrentLine("Provided data results in nil, returning 0")
        return 0
    elseif not weapon_tweak_data.usage then
        EHI:LogWithCurrentLine("Usage is missing in provided weapon, will result in a crash later on; returning 0")
        return 0
    end
    local weapon = enemy_tweak_data.weapon or {}
    local weapon_tweak = weapon[weapon_tweak_data.usage] or {}
    local FALLOFF = weapon_tweak.FALLOFF or {}
    local highest_dmg_mul = -math.huge
    if next(FALLOFF) then
        for _, falloff in ipairs(FALLOFF) do
            highest_dmg_mul = math.max(highest_dmg_mul, falloff.dmg_mul or 1)
        end
    else -- In case the falloff is an empty table
        highest_dmg_mul = 1
    end
    return highest_dmg_mul * (weapon_tweak_data.DAMAGE or 0)
end

---@param number number
---@param start number
---@param limit number
function math.increment_with_limit(number, start, limit)
    number = number + 1
    return number > limit and start or number
end

---@param objectives XPBreakdown.objectives
function table.ehi_get_objectives_xp_amount(objectives)
    local xp_amount = 0
    for _, objective in ipairs(objectives) do
        if objective.optional then
        elseif objective.amount then
            xp_amount = xp_amount + objective.amount
        elseif objective.escape and type(objective.escape) == "number" then
            xp_amount = xp_amount + objective.escape
        end
    end
    return xp_amount
end

---@generic K, V
---@param map table<K, V>
---@param key K
---@return V?
function table.remove_key(map, key)
    local value = map[key]
    map[key] = nil
    return value
end

---Works the same as `table.empty` but it returns `true` if a nil table is passed to the function
---@param v table?
function table.ehi_empty(v)
    if v then -- It cannot be on one line because of boolean values
        return table.empty(v)
    end
    return true
end

---Works the same as `table.size` but it returns `0` if a nil table is passed to the function
---@param v table?
function table.ehi_size(v)
    return v and table.size(v) or 0
end

---@generic T
---@param v T[]
---@param func fun(item: T): boolean
function table.list_count(v, func)
    local count = 0
    for _, value in ipairs(v) do
        if func(value) then
            count = count + 1
        end
    end
    return count
end

---@param n number
---@param bracket number? Number formatted as multiples of 10 -> 1, 10, 100, 0.1, 0.01, 0.001...
function math.ehi_round(n, bracket)
    bracket = bracket or 1
    local sign = n >= 0 and 1 or -1
    return math.floor(n / bracket + sign * 0.5) * bracket
end

---@param n number
function math.ehi_round_chance(n)
    return math.ehi_round(n, 0.01) * 100
end

---@param n number
function math.ehi_round_health(n)
    return math.ehi_round(n * 10, 0.1)
end

---Works the same as `next` but it returns `nil, nil` if a nil table is passed to the function
---@generic K, V
---@param v table<K, V>?
---@return K?, V?
function _G.ehi_next(v)
    if v then
        return next(v)
    end
    return nil, nil
end