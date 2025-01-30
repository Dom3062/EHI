local EHI = EHI
if EHI:CheckHook("tweak_data") then
    return
end
dofile(EHI.LuaPath .. "EHITweakData.lua")
tweak_data.ehi = EHITweakData:new(tweak_data)

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

---Works the same as `table.size` but it returns 0 if nil table is passed to the function
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