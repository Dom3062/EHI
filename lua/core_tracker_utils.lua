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
        blue = tweak_data.ehi:ColorRedirect(Color.blue)
    }
end

---@param colored_codes EHI.ColorTable
---@return { string: Idstring[] }
function EHI.TrackerUtils:CacheColorCodesNumbers(colored_codes)
    local codes = {}
    for color, _ in pairs(colored_codes) do
        local c = {}
        for i = 0, 9, 1 do
            c[i] = Idstring(string.format("g_number_%s_0%d", color, i))
        end
        codes[color] = c
    end
    return codes
end

---@param codes { string: Idstring[] }
---@param bg Idstring
---@param unit Unit?
---@param color string
---@return number?
function EHI.TrackerUtils:CheckIfCodeIsVisible(codes, bg, unit, color)
    if not unit then
        return nil
    end
    local color_codes = codes[color]
    if unit:get_object(bg):visibility() then
        for i = 0, 9, 1 do
            if unit:get_object(color_codes[i]):visibility() then
                return i
            end
        end
    end
    return nil -- Has not been interacted yet
end