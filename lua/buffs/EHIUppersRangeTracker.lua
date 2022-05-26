local pm
local mvector3_distance = mvector3.distance
local math_floor = math.floor
local string_format = string.format
local function show(o)
    local t = 0
    local total = 0.15
    while t < total do
        t = t + coroutine.yield()
        o:set_alpha(t / total)
    end
    o:set_alpha(1)
end
local function hide(o)
    local t = 0
    local total = 0.15
    while t < total do
        t = t + coroutine.yield()
        o:set_alpha(1 - (t / total))
    end
    o:set_alpha(0)
end
EHIUppersRangeTracker = class(EHIGaugeBuffTracker)
function EHIUppersRangeTracker:PreUpdate()
    pm = managers.player
    local function Check(...)
        if self._in_custody then
            return
        end
        local list = FirstAidKitBase.List
        if table.size(list) == 0 then
            self:Deactivate()
        else
            self:Activate()
        end
    end
    EHI:HookWithID(FirstAidKitBase, "Add", "UppersRangeBuff_Add", Check)
    EHI:HookWithID(FirstAidKitBase, "Remove", "UppersRangeBuff_Remove", Check)
    local function f(state)
        self:CustodyState(state)
    end
    EHI:AddOnCustodyCallback(f)
end

function EHIUppersRangeTracker:Activate()
    if self._active then
        return
    end
    self._active = true
    self._parent_class:AddBuffToUpdate(self._id, self)
end

function EHIUppersRangeTracker:CustodyState(state)
    if state then
        self:Deactivate()
    else
        local list = FirstAidKitBase.List
        if table.size(list) > 0 then
            self:Activate()
        end
    end
    self._in_custody = state
end

function EHIUppersRangeTracker:Deactivate()
    if not self._active then
        return
    end
    self:DeactivateSoft()
    self._parent_class:RemoveBuffFromUpdate(self._id)
    self._active = false
end

function EHIUppersRangeTracker:ActivateSoft()
    if self._visible then
        return
    end
    self._panel:stop()
    self._panel:animate(show)
    self._parent_class:AddVisibleBuff(self._id)
    self._visible = true
end

function EHIUppersRangeTracker:DeactivateSoft()
    if not self._visible then
        return
    end
    self._parent_class:RemoveVisibleBuff(self._id, self._pos)
    self._panel:stop()
    self._panel:animate(hide)
    self._visible = false
end

function EHIUppersRangeTracker:update(t, dt)
    self._time = self._time - dt
    if self._time <= 0 then
        self._time = 0.5
        local player_unit = pm:player_unit()
        if alive(player_unit) then
            local found, distance, min_distance = self:GetFirstAidKit(player_unit:position())
            if found then
                local ratio = 1 - (distance / min_distance)
                self._distance = distance / 100
                self:ActivateSoft()
                self:SetRatio(ratio)
            else
                self:DeactivateSoft()
            end
        end
    end
end

function EHIUppersRangeTracker:GetFirstAidKit(pos)
	for _, o in pairs(FirstAidKitBase.List) do
		local dst = mvector3_distance(pos, o.pos)
		if dst <= o.min_distance then
			return true, dst, o.min_distance
		end
	end
	return false
end

function EHIUppersRangeTracker:Format()
    return string_format("%dm", math_floor(self._distance))
end

function EHIUppersRangeTracker:SetRatio(ratio)
    if self._ratio == ratio then
        return
    end
    EHIUppersRangeTracker.super.SetRatio(self, ratio)
end