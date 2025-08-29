---@class EHICorrectCablesTracker : EHITracker
---@field super EHITracker
EHICorrectCablesTracker = class(EHITracker)
EHICorrectCablesTracker._forced_icons = EHI:GetAchievementIcon("nmh_9") -- Cutting cables icon
EHICorrectCablesTracker._forced_hint_text = "vit_color_cables"
EHICorrectCablesTracker._needs_update = false
EHICorrectCablesTracker._color_map =
{
    r = Color.red,
    b = tweak_data.ehi:ColorRedirect(Color.blue),
    g = Color.green,
    y = Color.yellow
}

function EHICorrectCablesTracker:post_init(params)
    self._text:set_w(self._bg_box:w() / 2)
    self._text2 = self:CreateText({
        w = self._text:w(),
        text = "0.00",
        left = self._text:right(),
        FitTheText = true
    })
end

---@param color_text "r"|"g"|"b"|"y"
function EHICorrectCablesTracker:SetCode(color_text)
    local text = self._code_index == nil and self._text or self._text2
    text:set_text(managers.localization:text(string.format("ehi_color_%s", color_text)))
    text:set_color(self._color_map[color_text])
    self:FitTheText(text)
    self._code_index = self._code_index or {} ---@type table<string, Text>
    self._code_index[color_text] = text
end

---@param color_text "r"|"g"|"b"|"y"
function EHICorrectCablesTracker:RemoveCode(color_text)
    local text = self._code_index and self._code_index[color_text]
    if text then
        text:parent():remove(text)
        self._code_index[color_text] = nil
        local _, other_text = next(self._code_index)
        if other_text then
            self:AnimateTextPosition(0, self._bg_box:w(), other_text, true)
            self:AnimateBG()
        else
            self:delete()
        end
    end
end