EHIPiggyBankMutatorTracker = class(EHIProgressTracker)
function EHIPiggyBankMutatorTracker:init(panel, params)
    self._current_level = 1
    self._max_levels = 6
    params.flash_times = 1
    params.icons = { "piggy" }
    EHIPiggyBankMutatorTracker.super.init(self, panel, params)
    self:SetNewMax()
end

function EHIPiggyBankMutatorTracker:OverridePanel(params)
    self._panel:set_w(self._panel:w() * 2)
    self._time_bg_box:set_w(self._time_bg_box:w() * 2)
    self._levels_text = self._time_bg_box:text({
        name = "text2",
        text = self:FormatLevels(),
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w() / 2,
        h = self._time_bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = params.text_color or Color.white
    })
    self:FitTheText(self._levels_text)
    self._levels_text:set_left(self._text:right())
    if self._icon1 then
        self._icon1:set_x(self._icon1:x() * 2)
    end
end

function EHIPiggyBankMutatorTracker:FormatLevels()
    return self._current_level .. "/" .. self._max_levels
end

function EHIPiggyBankMutatorTracker:SetNewMax()
    local tweak_data = tweak_data.mutators.piggybank.pig_levels
    local levels = tweak_data[self._current_level]
    local new_max = levels and levels.bag_requirement or 0
    if self._current_level <= 2 then
        new_max = new_max + 1
    end
    self._max = new_max
    self._text:set_text(self:Format())
    self:FitTheText()
end

function EHIPiggyBankMutatorTracker:update(t, dt)
    self._time = self._time - dt
    if self._time <= 0 then
        self:RemoveTrackerFromUpdate()
        self._text:stop()
        self:SetTextColor(Color.white)
        self._levels_text:set_color(Color.white)
    end
end

function EHIPiggyBankMutatorTracker:SetCompleted(force)
    if self._current_level >= self._max_levels then
        self._disable_counting = true
        self._text:set_text("MAX")
        self:FitTheText()
        self:SetTextColor(Color.green)
        self._levels_text:set_color(Color.green)
    else
        self._current_level = self._current_level + 1
        self:SetNewMax()
        self._time = 3
        self:AddTrackerToUpdate()
        self:AnimateNewLevel()
    end
    self._levels_text:set_text(self:FormatLevels())
end

function EHIPiggyBankMutatorTracker:SyncLoad(data)
    self._current_level = data.pig_level
    self._progress = data.pig_fed_count
    self:SetNewMax()
    if self._current_level >= self._max_levels then
        self:SetCompleted()
    end
end

function EHIPiggyBankMutatorTracker:AnimateNewLevel()
    if self._text and alive(self._text) then
        local start_t = check_progress and (min(EHI:RoundNumber(self._time, 0.1) - floor(self._time), 0.99)) or 0
        self._text:animate(function(o)
            while true do
                local t = start_t
                while t < 1 do
                    t = t + coroutine.yield()
                    local n = 1 - sin(t * 180)
                    --local r = lerp(1, 0, n)
                    local g = lerp(1, 0, n)
                    local c = Color(g, 1, g)
                    o:set_color(c)
                    self._levels_text:set_color(c)
                end
                start_t = 0
            end
        end)
    end
end

function EHIPiggyBankMutatorTracker:destroy()
    if self._text and alive(self._text) then
        self._text:stop()
    end
    EHIPiggyBankMutatorTracker.super.destroy(self)
end