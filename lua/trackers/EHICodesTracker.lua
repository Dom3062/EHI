---@class EHICodeTracker : EHITracker
EHICodeTracker = class(EHITracker)
EHICodeTracker._update = false
EHICodeTracker._forced_icons = { "code" }
EHICodeTracker._forced_hint_text = "code"
---@param code string?
function EHICodeTracker:Format(code)
    if code then
        return tostring(code)
    end
    return "?"
end

---@param code string
function EHICodeTracker:SetCode(code)
    self._text:set_text(self:Format(code))
    self:FitTheText(self._text)
    self:AnimateBG()
end

---@param pos integer
---@param code string
---@param n_of_code_parts integer
function EHICodeTracker:SetCodePart(pos, code, n_of_code_parts)
    self._code_parts = self._code_parts or {}
    self._code_parts[pos] = code
    if pos == n_of_code_parts then
        local s = ""
        for _, _c in ipairs(self._code_parts) do
            s = s .. _c
        end
        self:SetCode(s)
        self._code_parts = nil
    end
end

---@class EHIColoredCodesTracker : EHICodeTracker
---@field super EHICodeTracker
EHIColoredCodesTracker = class(EHICodeTracker)
EHIColoredCodesTracker._forced_hint_text = "color_codes"
EHIColoredCodesTracker._init_create_text = false
function EHIColoredCodesTracker:OverridePanel()
    local third = self._bg_box:w() / 3
    self._text = self:CreateText({
        name = "red",
        text = "?",
        w = third,
        h = self._icon_size_scaled,
        color = Color.red,
        left = 0
    })
    self._text2 = self:CreateText({
        name = "green",
        text = "?",
        w = third,
        h = self._icon_size_scaled,
        color = Color.green,
        left = self._text:right()
    })
    self._text3 = self:CreateText({
        name = "blue",
        text = "?",
        w = third,
        h = self._icon_size_scaled,
        color = Color(0, 1, 1), -- Aqua
        left = self._text2:right()
    })
end

---@param color string
---@param code string
function EHIColoredCodesTracker:SetCode(color, code)
    local text = self._bg_box:child(color) --[[@as PanelText]]
    text:set_text(self:Format(code))
    self:FitTheText(text)
    self:AnimateBG()
end