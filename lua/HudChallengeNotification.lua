local EHI = EHI
local titles = {}
local to_localize = {}
local hooked = false
function EHI:SetNotificationAlert(ehi_title, localization, c)
    if localization then
        if managers.localization then
            localization = managers.localization:text(localization)
        else
            to_localize[ehi_title] = { localization = localization, color = c or Color.red }
        end
    end
    titles[ehi_title] = { localization = localization or ehi_title, color = c or Color.red }
    if not hooked then
        local _f_init = HudChallengeNotification.init
        if VoidUI and VoidUI.options.enable_challanges then
            function HudChallengeNotification:init(title, ...)
                local valid = false
                local color = nil
                if title and titles[title] then
                    valid = true
                    local _t = titles[title]
                    title = _t.localization
                    color = _t.color
                end
                _f_init(self, title, ...)
                if valid then
                    for i, d in ipairs(self._hud:children()) do
                        if d.panel then
                            for ii, dd in ipairs(d:children()) do
                                if dd.set_image then
                                    dd:set_color(color)
                                end
                            end
                        end
                    end
                end
            end
        else
            function HudChallengeNotification:init(title, ...)
                local valid = false
                local color = nil
                if title and titles[title] then
                    valid = true
                    local _t = titles[title]
                    title = _t.localization
                    color = _t.color
                end
                _f_init(self, title, ...)
                if valid and self._box then
                    for i, d in ipairs(self._box:children()) do
                        if d.set_image then
                            d:set_color(color)
                        end
                    end
                end
            end
        end
        hooked = true
    end
end

EHI:AddCallback("LocalizationLoaded", function(l)
    for title, loc in pairs(to_localize) do
        titles[title] = { localization = l:text(loc.localization), color = loc.color }
    end
    to_localize = nil
end)