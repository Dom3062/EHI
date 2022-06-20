local math_min = math.min
local math_lerp = math.lerp
local Color = Color
function EHI:CopyClass(parent, stop_text_anim)
    local c = class(parent)
    c.delete = EHIStaticTracker.delete
    if stop_text_anim then
        c.destroy = function(self, skip, anim_destroy)
            if self._text and alive(self._text) then
                self._text:stop()
            end
            EHIStaticTracker.destroy(self, skip, anim_destroy)
        end
    else
        c.destroy = EHIStaticTracker.destroy
    end
    return c
end

EHIStaticTracker = class(EHITracker)
function EHIStaticTracker:delete()
    self:destroy()
    self._parent_class:RemoveStaticTracker(self._id)
end

function EHIStaticTracker:destroy(destroy, anim_destroy)
    if alive(self._panel) and alive(self._parent_panel) then
        if self._icon1 then
            self._icon1:stop()
        end
        self._panel:stop()
        if destroy then
            self._parent_panel:remove(self._panel)
        else
            self._visible = false
            self._panel:animate(function(o)
                local TOTAL_T = 0.18
                local t = 0
                while TOTAL_T > t do
                    local dt = coroutine.yield()
                    t = math_min(t + dt, TOTAL_T)
                    local lerp = t / TOTAL_T
                    o:set_alpha(math_lerp(1, 0, lerp))
                end
                self._time_bg_box:child("bg"):stop()
                if anim_destroy then
                    self._parent_panel:remove(self._panel)
                else
                    self._time_bg_box:set_color(Color(1, 0, 0, 0))
                    self._text:set_color(Color.white)
                end
            end)
        end
    end
end

EHIStaticWarningTracker = EHI:CopyClass(EHIWarningTracker, true)