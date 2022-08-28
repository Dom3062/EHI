EHIHostageTakerMuscleRegenBuffTracker = class(EHIBuffTracker)
function EHIHostageTakerMuscleRegenBuffTracker:init(panel, params)
    EHIHostageTakerMuscleRegenBuffTracker.super.init(self, panel, params)
    local icon = self._panel:child("icon") -- Hostage Taker regen
    self._panel:bitmap({ -- Muscle regen
        name = "icon2",
        texture = "guis/textures/pd2/specialization/icons_atlas",
        texture_rect = {4 * 64, 64, 64, 64},
        color = Color.white,
        x = icon:x(),
        y = icon:y(),
        w = icon:w(),
        h = icon:h()
    })
    self:SetIcon("hostage_taker")
end

function EHIHostageTakerMuscleRegenBuffTracker:SetIcon(buff)
    if self._buff == buff then
        return
    end
    if buff == "hostage_taker" then
        self._panel:child("icon"):set_visible(true)
        self._panel:child("icon2"):set_visible(false)
    else
        self._panel:child("icon2"):set_visible(true)
        self._panel:child("icon"):set_visible(false)
    end
    self._buff = buff
end