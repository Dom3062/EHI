if EHI.TrackerUtils then
    return
end
EHI.TrackerUtils =
{
    super = EHI
}

---@param all_icons table
---@param one_icon table
function EHI.TrackerUtils:GetTrackerIcons(all_icons, one_icon)
    return self.super:GetOption("show_one_icon") and one_icon or all_icons
end

---@param enabled_class string
---@param disabled_class string
function EHI.TrackerUtils:EnableSniperClassTracking(enabled_class, disabled_class)
    if EHISniperBase then
        EHISniperBase._enabled = true
        return enabled_class
    end
    return disabled_class
end

function EHI.TrackerUtils:GetColorCodesMap()
    return {
        red = Color.red,
        green = Color.green,
        blue = Color(0, 1, 1)
    }
end

---@param colored_codes EHI.ColorTable
function EHI.TrackerUtils:CacheColorCodesNumbers(colored_codes)
    local codes = {}
    for color, _ in pairs(colored_codes) do
        local c = {}
        for i = 0, 9, 1 do
            c[i] = Idstring(string.format("g_number_%s_0%d", color, i)):key()
        end
        codes[color] = c
    end
    return codes
end

---@param codes table
---@param bg string
---@param unit UnitBase
---@param color string
---@return number?
function EHI.TrackerUtils:CheckIfCodeIsVisible(codes, bg, unit, color)
    if not unit then
        return nil
    end
    local color_codes = codes[color]
    local damage = unit:damage()
    local object = damage and damage._state and damage._state.object
    if object and object[bg] then
        for i = 0, 9, 1 do
            if object[color_codes[i]] then
                return i
            end
        end
    end
    return nil -- Has not been interacted yet
end