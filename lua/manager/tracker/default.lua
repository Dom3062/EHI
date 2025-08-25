---@class EHITrackerManager
local EHITrackerManager = ...

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

---@param id string
function EHITrackerManager:_hint_removed(id)
end

---@param id string Tracker ID
---@param hint_w number
function EHITrackerManager:_hint_updated(id, hint_w)
end

if EHI:CheckVRAndNonVROption("vr_tracker_alignment", "tracker_alignment", EHI.Const.Trackers.Alignment.Vertical) then -- Vertical in VR or in non-VR
    ---@param pos number?
    ---@param w number
    function EHITrackerManager:_get_x(pos, w)
        return self._x
    end

    if EHI:CheckVRAndNonVROption("vr_tracker_alignment", "tracker_alignment", EHI.Const.Trackers.Alignment.Vertical_TopToBottom) then -- Top to Bottom
        ---@param pos number?
        function EHITrackerManager:_get_y(pos)
            pos = pos or self._n_of_trackers
            return self._y + (pos * (self._panel_size + self._panel_offset))
        end
    else -- Bottom to Top
        ---@param pos number?
        function EHITrackerManager:_get_y(pos)
            pos = pos or self._n_of_trackers
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
                    tbl.tracker:AnimateTop(self:_get_y(final_pos))
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
        for _, tbl in pairs(self._trackers) do
            if tbl.pos and tbl.pos > pos then
                local final_pos = tbl.pos - 1
                tbl.tracker:AnimateTop(self:_get_y(final_pos))
                tbl.pos = final_pos
            end
        end
    end

    ---Call this function only from trackers themselves
    ---@param id string
    ---@param new_w number
    ---@param move_the_tracker boolean?
    function EHITrackerManager:_change_tracker_width(id, new_w, move_the_tracker)
    end
else -- Horizontal
    ---@param pos number?
    function EHITrackerManager:_get_y(pos)
        return self._y
    end

    if EHI:CheckVRAndNonVROption("vr_tracker_alignment", "tracker_alignment", EHI.Const.Trackers.Alignment.Horizontal_LeftToRight) then -- Left to Right
        ---@param pos number?
        ---@param w number
        function EHITrackerManager:_get_x(pos, w)
            if self._n_of_trackers == 0 or pos and pos <= 0 then
                return self._x
            end
            local x = 0
            local pos_create = pos and (pos - 1) or (self._n_of_trackers - 1)
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
                for _, tbl in pairs(self._trackers) do
                    if tbl.pos and tbl.pos >= pos then
                        local final_x = tbl.x + w + self._panel_offset
                        tbl.tracker:AnimateLeft(final_x)
                        tbl.x = final_x
                        tbl.pos = tbl.pos + 1
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
            panel_offset_move = panel_offset_move or self._panel_offset
            for _, tbl in pairs(self._trackers) do
                if tbl.pos and tbl.pos > pos then
                    local final_x = tbl.x - w - panel_offset_move
                    tbl.tracker:AnimateLeft(final_x)
                    tbl.x = final_x
                    tbl.pos = tbl.pos - pos_move
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
            self:_rearrange_trackers(tracker.pos, w_diff, 0, 0)
        end
    else -- Right to Left
        ---@param pos number?
        ---@param w number
        function EHITrackerManager:_get_x(pos, w)
            if self._n_of_trackers == 0 or pos and pos <= 0 then
                return self._x
            end
            local x = 0
            local pos_create = pos and (pos - 1) or (self._n_of_trackers - 1)
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
                local start_pos = 0
                local previous_x = self._x
                if pos > 0 then
                    local on_pos = list[pos]
                    if on_pos then
                        previous_x = on_pos.x - w - self._panel_offset
                        on_pos.tracker:AnimateLeft(previous_x)
                        on_pos.x = previous_x
                        on_pos.pos = on_pos.pos + 1
                        start_pos = pos + 1
                    else
                        EHI:Log("[EHITrackerManager:MoveTracker()] Something happened during getting the tracker on the position! Nil was returned")
                        EHI:Log("This shouldn't happen, returning nil value to create the tracker on the last available position")
                        return nil
                    end
                end
                for i = start_pos, self._n_of_trackers - 1, 1 do
                    local t_pos = list[i]
                    local final_x = previous_x - t_pos.w - self._panel_offset
                    previous_x = final_x
                    t_pos.tracker:AnimateLeft(final_x)
                    t_pos.x = final_x
                    t_pos.pos = t_pos.pos + 1
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
            panel_offset_move = panel_offset_move or self._panel_offset
            for _, tbl in pairs(self._trackers) do
                if tbl.pos and tbl.pos > pos then
                    local final_x = tbl.x + w + panel_offset_move
                    tbl.tracker:AnimateLeft(final_x)
                    tbl.x = final_x
                    tbl.pos = tbl.pos - pos_move
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
            local pos = tracker.pos
            if move_the_tracker then
                pos = pos - 1
            else
                tracker.x = tracker.x + w_diff
            end
            self:_rearrange_trackers(pos, w_diff, 0, 0)
        end
    end
end