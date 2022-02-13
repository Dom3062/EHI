EHInmhElevatorTimerTracker = EHInmhElevatorTimerTracker or class(EHITracker)
function EHInmhElevatorTimerTracker:init(panel, params)
    self._floors = params.floors or 26
    params.time = self:GetElevatorTime()
    EHInmhElevatorTimerTracker.super.init(self, panel, params)
end

function EHInmhElevatorTimerTracker:GetElevatorTime()
    return self._floors * 8
end

function EHInmhElevatorTimerTracker:SetFloors(floors)
    self._floors = floors
    local new_time = self:GetElevatorTime()
    if math.abs(self._time - new_time) >= 1 then -- If the difference in the new time is higher than 1s, use the new time to stay accurate
        self._time = new_time
    end
end

function EHInmhElevatorTimerTracker:LowerFloor()
    self:SetFloors(self._floors - 1)
end

function EHInmhElevatorTimerTracker:SetPause(pause)
    if pause then
        self:RemoveTrackerFromUpdate()
    else
        self:AddTrackerToUpdate()
    end
    self:SetTextColor(pause and Color.red or Color.white)
end