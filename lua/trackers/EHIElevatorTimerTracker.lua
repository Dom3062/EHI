EHIElevatorTimerTracker = EHIElevatorTimerTracker or class(EHITracker)
function EHIElevatorTimerTracker:init(panel, params)
    self._floors = params.floors or 26
    params.time = self:GetElevatorTime()
    EHIElevatorTimerTracker.super.init(self, panel, params)
end

function EHIElevatorTimerTracker:GetElevatorTime()
    return self._floors * 8
end

function EHIElevatorTimerTracker:SetFloors(floors)
    self._floors = floors
    local new_time = self:GetElevatorTime()
    if math.abs(self._time - new_time) >= 1 then -- If the difference in the new time is higher than 1s, use the new time to stay accurate
        self._time = new_time
    end
end

function EHIElevatorTimerTracker:LowerFloor()
    self:SetFloors(self._floors - 1)
end

function EHIElevatorTimerTracker:SetPause(pause)
    if pause then
        self:RemoveTrackerFromUpdate()
    else
        self:AddTrackerToUpdate()
    end
    self:SetTextColor(pause and Color.red or Color.white)
end