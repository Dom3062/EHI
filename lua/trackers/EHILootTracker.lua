---@class EHILootTracker : EHITracker
---@field super EHITracker
EHILootTracker = class(EHITracker)
EHILootTracker.update = EHILootTracker.update_fade
EHILootTracker._forced_hint_text = "loot_counter"
EHILootTracker._forced_icons = { EHI.Icons.Loot }
EHILootTracker._needs_update = false
function EHILootTracker:post_init(params)
    if params.max_random > 0 and params.unknown_random then
        self:IncreaseTrackerSize()
    end
    if params.max_xp_bags > 0 then
        self:SetTextColor(Color.yellow)
    elseif params.max == 0 and params.max_random > 0 then
        self:SetTextColor(Color.green)
    end
end

---@param animate boolean?
function EHILootTracker:IncreaseTrackerSize(animate)
    if self.__tracker_size_increased then
        return
    end
    self.__tracker_size_increased = true
    if animate then
        self:AnimateMovement(self._anim_params.PanelSizeIncreaseHalf)
    else
        self:SetMovement(self._anim_params.PanelSizeIncreaseHalf)
    end
    self._text:set_w(self._bg_box:w())
    self:SetAndFitTheText()
end

---@param animate boolean?
function EHILootTracker:DecreaseTrackerSize(animate)
    if not self.__tracker_size_increased then
        return
    end
    self.__tracker_size_increased = nil
    if animate then
        self:AnimateMovement(self._anim_params.PanelSizeDecreaseHalf)
    else
        self:SetMovement(self._anim_params.PanelSizeDecreaseHalf)
    end
    self._text:set_w(self._bg_box:w())
    self:SetAndFitTheText()
end

---@param text string
---@param silent_update boolean?
function EHILootTracker:SetText(text, silent_update)
    self:SetAndFitTheText(text)
    if not silent_update then
        self:AnimateBG()
    end
end

---@param state boolean
function EHILootTracker:UpdateUnknownLoot(state)
    if state then
        self:IncreaseTrackerSize(true)
    else
        self:DecreaseTrackerSize(true)
    end
end

---@param random_loot_present boolean
function EHILootTracker:SetCompleted(random_loot_present)
    self:SetTextColor(Color.green)
    if not random_loot_present then
        self:AddTrackerToUpdate()
    end
end

function EHILootTracker:MaxNoLongerLimited()
    self:SetTextColor(Color.white)
end