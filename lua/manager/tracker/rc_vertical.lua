---@class EHITrackerManager
local EHITrackerManager = ...

---@param tracker EHITracker
function EHITrackerManager:_get_hint_w(tracker)
    return tracker._hint and tracker._hint:w() + 3 or 0
end

---@param tracker EHITracker Tracker itself
---@param pos number Tracker pos
---@param w number Tracker width
function EHITrackerManager:_tracker_created(tracker, pos, w)
    local full_w = w + self:_get_hint_w(tracker)
    self._n_of_trackers = self._n_of_trackers + 1
    if self._n_of_trackers % self._n_of_rc == 0 then -- Create in advance another RC to hold our internal data
        self._rc_params.last_line = self._rc_params.last_line + 1
        self._rc_line[self._rc_params.last_line] = { max_size = 0 }
    end
    local pos_line = self:_get_rc_line_index(pos) + 1
    local line = self._rc_line[pos_line]
    if full_w > line.max_size then
        if pos_line == self._rc_params.last_line then -- Our bigger tracker has been created on the last line, no need to move other trackers; just update our internal data
            line.max_size = full_w
            line.id = tracker._id
        else
            self:_rearrange_rc_data(pos_line) -- It will also update ID and Max Size
            self:_rearrange_trackers(pos, 0, 0)
        end
    elseif pos_line ~= self._rc_params.last_line then -- Our new (smaller) tracker has not been created on the last line, update every RC Line internal data to stay accurate (because some bigger trackers could have moved to other lines)
        self:_rearrange_rc_data(pos_line)
        self:_rearrange_trackers(pos, 0, 0)
    end
end

---@param id string
---@param pos number
---@param w number Tracker width
function EHITrackerManager:_tracker_destroyed(id, pos, w)
    local line, pos_line = self:_get_rc_line_and_pos_line_from_pos(pos)
    if self._n_of_trackers % self._n_of_rc == self._n_of_rc - 1 then
        local last_line = self._rc_params.last_line
        self._rc_line[last_line] = nil
        local new_last_line = last_line - 1
        if pos_line ~= last_line then -- Destroyed tracker is not from the last row/column; refresh our internal data
            self:_rearrange_rc_data(pos_line, new_last_line)
        end
        self._rc_params.last_line = new_last_line
    elseif line.id == id then -- Tracker with the highest width has been deleted, recheck all other RCs to get the second highest
        self:_rearrange_rc_data(pos_line)
    end
end

---@param pos_line number
---@param last_line number?
function EHITrackerManager:_rearrange_rc_data(pos_line, last_line)
    for i = pos_line, last_line or self._rc_params.last_line, 1 do
        local line = self._rc_line[i]
        local start_pos, end_pos = self:_get_start_end_pos_from_pos_line(i)
        line.max_size = 0
        for id, tbl in pairs(self._trackers) do
            if tbl.pos and math.within(tbl.pos, start_pos, end_pos) then
                local new_w = tbl.w + self:_get_hint_w(tbl.tracker)
                if new_w > line.max_size then
                    line.max_size = new_w
                    line.id = id
                end
            end
        end
    end
end

if EHI:GetOption("tracker_vertical_w_anim") == EHI.Const.Trackers.Vertical.WidthAnim.RightToLeft then
    ---@param pos number?
    ---@param w number
    function EHITrackerManager:_get_x(pos, w)
        pos = pos and self:_get_rc_line_index(pos) or (self._rc_params.last_line - 1)
        local size = 0
        for i = pos, 1, -1 do
            size = size + self._rc_line[i].max_size + self._rc_params.next_panel_offset
        end
        return self._x - size --[[@as number]]
    end
else
    ---@param pos number?
    ---@param w number
    function EHITrackerManager:_get_x(pos, w)
        pos = pos and self:_get_rc_line_index(pos) or (self._rc_params.last_line - 1)
        local size = 0
        for i = pos, 1, -1 do
            size = size + self._rc_line[i].max_size + self._rc_params.next_panel_offset
        end
        return self._x + size --[[@as number]]
    end
end

if EHI:CheckVRAndNonVROption("vr_tracker_alignment", "tracker_alignment", EHI.Const.Trackers.Alignment.Vertical_TopToBottom) then -- Top to Bottom
    ---@param pos number?
    function EHITrackerManager:_get_y(pos)
        pos = (pos or self._n_of_trackers) % self._n_of_rc
        return self._y + (pos * (self._panel_size + self._panel_offset))
    end
else -- Bottom to Top
    ---@param pos number?
    function EHITrackerManager:_get_y(pos)
        pos = (pos or self._n_of_trackers) % self._n_of_rc
        return self._y - (pos * (self._panel_size + self._panel_offset))
    end
end

---@param pos number?
---@param w number
function EHITrackerManager:_move_trackers(pos, w)
    if pos and pos >= 0 and self._n_of_trackers > 0 and pos <= self._n_of_trackers then
        for _, tbl in pairs(self._trackers) do
            if tbl.pos and tbl.pos >= pos then
                local final_pos = tbl.pos + 1
                tbl.tracker:AnimateTopLeft(self:_get_x(final_pos, 0), self:_get_y(final_pos), tbl.w + self._rc_params.gap_scaled)
                tbl.pos = final_pos
            end
        end
        return pos
    end
    return nil -- Received crap or no tracker exists; create tracker on the first available position
end

---@param pos number
---@param w number
---@param pos_move number?
---@param panel_offset_move number?
function EHITrackerManager:_rearrange_trackers(pos, w, pos_move, panel_offset_move)
    if not pos then
        return
    end
    pos_move = pos_move or 1
    for _, tbl in pairs(self._trackers) do
        if tbl.pos and tbl.pos > pos then
            local final_pos = tbl.pos - pos_move
            tbl.tracker:AnimateTopLeft(self:_get_x(final_pos, 0), self:_get_y(final_pos), tbl.w + self._rc_params.gap_scaled)
            tbl.pos = final_pos
        end
    end
end

---Call this function only from trackers themselves
---@param id string
---@param new_w number
---@param move_the_tracker boolean?
function EHITrackerManager:_change_tracker_width(id, new_w, move_the_tracker)
    local tracker = self._trackers[id]
    if not tracker then
        return
    end
    local w = tracker.w
    local w_diff = -(new_w - w)
    if w_diff == 0 then
        return
    end
    tracker.w = new_w
    local new_w_hint = new_w + self:_get_hint_w(tracker.tracker)
    local pos = tracker.pos
    local line, pos_line = self:_get_rc_line_and_pos_line_from_pos(pos)
    if new_w_hint > line.max_size then -- Our tracker or another is wider than our maximum, update
        line.max_size = new_w_hint
        line.id = id
        if pos_line ~= self._rc_params.last_line then
            self:_rearrange_trackers(pos, 0, 0)
        end
    elseif line.id == id then -- Our logged tracker is smaller than it was, we need to check if there is a tracker that is bigger than this tracker
        local previous_w = line.max_size
        local start_pos, end_pos = self:_get_start_end_pos_from_pos_line(pos_line)
        line.max_size = 0
        for t_id, tbl in pairs(self._trackers) do
            if tbl.pos and math.within(tbl.pos, start_pos, end_pos) then
                local w_with_hint = tbl.w + self:_get_hint_w(tbl.tracker)
                if w_with_hint > line.max_size then
                    line.max_size = w_with_hint
                    line.id = t_id
                end
            end
        end
        if previous_w > line.max_size then -- Our new second biggest tracker is smaller than previous, reposition trackers
            self:_rearrange_trackers(pos, 0, 0)
        end
    end
end

---@param id string Tracker ID
---@param hint_w number
function EHITrackerManager:_hint_updated(id, hint_w)
    local tracker = self._trackers[id]
    if not tracker then
        return
    end
    local w = tracker.w + hint_w
    local pos = tracker.pos
    local line, pos_line = self:_get_rc_line_and_pos_line_from_pos(pos)
    if w > line.max_size then -- Our tracker or another is wider than our maximum, update
        line.max_size = w
        line.id = id
        if pos_line ~= self._rc_params.last_line then
            self:_rearrange_trackers(pos, 0, 0)
        end
    elseif line.id == id then -- Our logged tracker is smaller than it was, we need to check if there is a tracker that is bigger than this tracker
        local previous_w = line.max_size
        local start_pos, end_pos = self:_get_start_end_pos_from_pos_line(pos_line)
        line.max_size = 0
        for t_id, tbl in pairs(self._trackers) do
            if tbl.pos and math.within(tbl.pos, start_pos, end_pos) then
                local w_with_hint = tbl.w + self:_get_hint_w(tbl.tracker)
                if w_with_hint > line.max_size then
                    line.max_size = w_with_hint
                    line.id = t_id
                end
            end
        end
        if previous_w > line.max_size then -- Our new second biggest tracker is smaller than previous, reposition trackers
            self:_rearrange_trackers(pos, 0, 0)
        end
    end
end

---@param id string Tracker ID
function EHITrackerManager:_hint_removed(id)
    local tracker = self._trackers[id]
    if not tracker then
        return
    end
    local pos = tracker.pos
    local line, pos_line = self:_get_rc_line_and_pos_line_from_pos(pos)
    if line.id == id then -- Our logged tracker is smaller than it was, we need to check if there is a tracker that is bigger than this tracker
        local previous_w = line.max_size
        local start_pos, end_pos = self:_get_start_end_pos_from_pos_line(pos_line)
        line.max_size = 0
        for t_id, tbl in pairs(self._trackers) do
            if tbl.pos and math.within(tbl.pos, start_pos, end_pos) then
                local new_w = tbl.w + self:_get_hint_w(tbl.tracker)
                if new_w > line.max_size then
                    line.max_size = new_w
                    line.id = t_id
                end
            end
        end
        if previous_w > line.max_size then -- Our new second biggest tracker is smaller than previous, reposition trackers
            self:_rearrange_trackers(pos, 0, 0)
        end
    end
end