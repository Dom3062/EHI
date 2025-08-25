---@class EHITrackerManager
local EHITrackerManager = ...
EHITrackerManager._n_of_rc_last = EHITrackerManager._n_of_rc - 1

---@param pos number
---@param new_pos number
function EHITrackerManager:_are_both_pos_on_the_same_rc_index(pos, new_pos)
    return self:_get_rc_line_index(pos) == self:_get_rc_line_index(new_pos)
end

---@param pos number
function EHITrackerManager:_get_start_end_pos_from_pos(pos)
    return self:_get_start_end_pos_from_pos_line(self:_get_rc_line_index(pos) + 1)
end

---@param tracker EHITracker Tracker itself
---@param pos number Tracker pos
---@param w number Tracker width
function EHITrackerManager:_tracker_created(tracker, pos, w)
    self._n_of_trackers = self._n_of_trackers + 1
end

---@param id string
---@param pos number
---@param w number Tracker width
function EHITrackerManager:_tracker_destroyed(id, pos, w)
end

if EHI:CheckVRAndNonVROption("vr_tracker_alignment", "tracker_alignment", EHI.Const.Trackers.Alignment.Horizontal_LeftToRight) then -- Left to Right
    ---@param pos number?
    ---@param w number
    function EHITrackerManager:_get_x(pos, w)
        if self._n_of_trackers == 0 or pos and pos <= 0 then
            return self._x
        end
        local pos_create = pos and (pos - 1) or (self._n_of_trackers - 1)
        if pos_create % self._n_of_rc == self._n_of_rc_last then
            return self._x
        end
        local x = self._x -- In case we do not find our tracker on that pos, that is bad
        for _, tbl in pairs(self._trackers) do
            if tbl.pos and tbl.pos == pos_create then
                x = tbl.x + tbl.w + self._panel_offset
                break
            end
        end
        return x
    end

    ---@param pos number?
    ---@param w number
    function EHITrackerManager:_move_trackers(pos, w)
        if pos and pos >= 0 and self._n_of_trackers > 0 and pos <= self._n_of_trackers then
            local list = self:_itemize_list_of_trackers()
            for i = pos, self._n_of_trackers - 1, 1 do
                local tbl = list[i]
                local final_pos = tbl.pos + 1
                local final_x
                if final_pos % self._n_of_rc == 0 then
                    final_x = self._x
                elseif self:_are_both_pos_on_the_same_rc_index(pos, final_pos) then
                    final_x = tbl.x + w + self._panel_offset
                else
                    local previous_pos = tbl.pos - 1
                    local previous_tracker = list[previous_pos] or {}
                    final_x = (previous_tracker.x or self._x) + (previous_tracker.w or 0) + (previous_pos == 0 and 0 or self._panel_offset)
                end
                tbl.tracker:AnimateTopLeft(final_x, self:_get_y(final_pos), 0)
                tbl.x = final_x
                tbl.pos = final_pos
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
        local list = self:_itemize_list_of_trackers()
        local w_offset
        local start_pos = pos + 1
        for i = start_pos, self._n_of_trackers, 1 do
            local tbl = list[i]
            local final_pos = tbl.pos - 1
            local final_x
            if final_pos % self._n_of_rc == 0 then
                final_x = self._x
            elseif self:_are_both_pos_on_the_same_rc_index(start_pos, tbl.pos) and final_pos ~= pos then
                final_x = tbl.x - (w_offset or w) - self._panel_offset
            else
                local same_pos = final_pos == pos
                local previous_tracker = same_pos and list[final_pos - 1] or list[final_pos] or {}
                final_x = (previous_tracker.x or self._x) + (previous_tracker.w or 0) + self._panel_offset
                if same_pos then
                    w_offset = tbl.w
                end
            end
            tbl.tracker:AnimateTopLeft(final_x, self:_get_y(final_pos), 0)
            tbl.x = final_x
            tbl.pos = final_pos
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
        local w_diff = new_w - tracker.w
        if w_diff == 0 then
            return
        end
        tracker.w = new_w
        local start_pos = tracker.pos + 1
        local _, end_pos = self:_get_start_end_pos_from_pos(tracker.pos)
        for _, tbl in pairs(self._trackers) do
            if tbl.pos and math.within(tbl.pos, start_pos, end_pos) then
                local final_x = tbl.x + w_diff
                tbl.tracker:AnimateTopLeft(final_x, self:_get_y(tbl.pos), 0)
                tbl.x = final_x
            end
        end
    end
else -- Right to Left
    ---@param pos number?
    ---@param w number
    function EHITrackerManager:_get_x(pos, w)
        if self._n_of_trackers == 0 or pos and pos <= 0 then
            return self._x
        end
        local pos_create = pos and (pos - 1) or (self._n_of_trackers - 1)
        if pos_create % self._n_of_rc == self._n_of_rc_last then
            return self._x
        end
        local x = self._x -- In case we do not find our tracker on that pos, that is bad
        for _, tbl in pairs(self._trackers) do
            if tbl.pos and tbl.pos == pos_create then
                x = tbl.x - w - self._panel_offset
                break
            end
        end
        return x
    end

    ---@param pos number?
    ---@param w number
    function EHITrackerManager:_move_trackers(pos, w)
        if pos and pos >= 0 and self._n_of_trackers > 0 and pos <= self._n_of_trackers then
            local list = self:_itemize_list_of_trackers()
            --[[
                The moving logic here needs to be separated in order to work correctly
                First check, if the provided position is pointing to the start of a row
                In the first loop, move trackers by provided width (w); same row
                In the second loop, move trackers by their width; other rows
            ]]
            local _, end_pos = self:_get_start_end_pos_from_pos(pos)
            if pos % self._n_of_rc == 0 then -- Special case; provided position is the first position in a row
                local first_w = list[pos].w
                for i = pos, end_pos, 1 do
                    local tbl = list[i]
                    if not tbl then
                        break
                    end
                    local final_pos = tbl.pos + 1
                    local final_x
                    if i == end_pos then
                        final_x = self._x
                    else
                        final_x = tbl.x - first_w - self._panel_offset
                    end
                    tbl.tracker:AnimateTopLeft(final_x, self:_get_y(final_pos), 0)
                    tbl.x = final_x
                    tbl.pos = final_pos
                end
            else
                for i = pos, end_pos, 1 do
                    local tbl = list[i]
                    if not tbl then
                        break
                    end
                    local final_pos = tbl.pos + 1
                    local final_x
                    if i == end_pos then
                        final_x = self._x
                    else
                        final_x = tbl.x - w - self._panel_offset
                    end
                    tbl.tracker:AnimateTopLeft(final_x, self:_get_y(final_pos), 0)
                    tbl.x = final_x
                    tbl.pos = final_pos
                end
            end
            for i = end_pos + 1, self._n_of_trackers - 1, 1 do
                local tbl = list[i]
                local final_pos = tbl.pos + 1
                local final_x
                if final_pos % self._n_of_rc == 0 then
                    final_x = self._x
                else
                    local previous_pos = tbl.pos - 1
                    local previous_tracker = list[previous_pos] or {}
                    final_x = (previous_tracker.x or self._x) - tbl.w - self._panel_offset
                end
                tbl.tracker:AnimateTopLeft(final_x, self:_get_y(final_pos), 0)
                tbl.x = final_x
                tbl.pos = final_pos
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
        local list = self:_itemize_list_of_trackers()
        local w_offset
        local start_pos = pos + 1
        for i = start_pos, self._n_of_trackers, 1 do
            local tbl = list[i]
            local final_pos = tbl.pos - 1
            local final_x
            if final_pos % self._n_of_rc == 0 then
                final_x = self._x
            elseif self:_are_both_pos_on_the_same_rc_index(start_pos, tbl.pos) and final_pos ~= pos then
                final_x = tbl.x + (w_offset or w) + self._panel_offset
            else
                local same_pos = final_pos == pos
                local previous_tracker = same_pos and list[final_pos - 1] or list[final_pos] or {}
                final_x = (previous_tracker.x or self._x) - tbl.w - self._panel_offset
                if same_pos then
                    w_offset = tbl.w
                end
            end
            tbl.tracker:AnimateTopLeft(final_x, self:_get_y(final_pos), 0)
            tbl.x = final_x
            tbl.pos = final_pos
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
        local w_diff = new_w - tracker.w
        if w_diff == 0 then
            return
        end
        tracker.w = new_w
        local pos = tracker.pos
        if move_the_tracker then
            pos = pos - 1
        else
            pos = pos + 1
            tracker.x = tracker.x - w_diff
        end
        local _, end_pos = self:_get_start_end_pos_from_pos(tracker.pos)
        for _, tbl in pairs(self._trackers) do
            if tbl.pos and math.within(tbl.pos, pos, end_pos) then
                local final_x = tbl.x - w_diff
                tbl.tracker:AnimateTopLeft(final_x, self:_get_y(tbl.pos), 0)
                tbl.x = final_x
            end
        end
    end
end

if EHI:GetOption("trackers_rc_horizontal_new_column_position") == EHI.Const.Trackers.Horizontal.NewRCAnim.Top then
    ---@param pos number?
    function EHITrackerManager:_get_y(pos)
        return self._y - (self:_get_rc_line_index(pos) * self._rc_params.horizontal_offset)
    end
else
    ---@param pos number?
    function EHITrackerManager:_get_y(pos)
        return self._y + (self:_get_rc_line_index(pos) * self._rc_params.horizontal_offset)
    end
end

---@param id string Tracker ID
---@param hint_w number
function EHITrackerManager:_hint_updated(id, hint_w)
end

---@param id string Tracker ID
function EHITrackerManager:_hint_removed(id)
end