local lerp = math.lerp
local sin = math.sin
local Color = Color
EHIPiggyBankMutatorTracker = class(EHIProgressTracker)
EHIPiggyBankMutatorTracker._forced_icons = { "piggy" }
function EHIPiggyBankMutatorTracker:init(panel, params)
    self._current_level = 1
    self._max_levels = 7
    params.flash_times = 1
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
        h = self._icon_size_scaled,
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

function EHIPiggyBankMutatorTracker:CheckLevelFromKills()
    if self._progress == 0 then -- The game has not started yet or players haven't secured bags yet
        return
    end
    local tweak_data = tweak_data.mutators.piggybank.pig_levels
    local n = table.size(tweak_data)
    local offset =
    {
        [1] = 1,
        [2] = 1
    }
    local done = false
    for i = 1, n, 1 do
        local max = (tweak_data[i].bag_requirement or 0) + (offset[i] or 0)
        if max > self._progress then
            self._current_level = i
            self._max = max
            self._text:set_text(self:Format())
            self:FitTheText()
            done = true
            break
        end
    end
    if not done and self._progress >= (tweak_data[n].bag_requirement or 0) then
        self._current_level = 6
        self:SetCompleted()
    end
end

function EHIPiggyBankMutatorTracker:SetCompleted(force)
    self._current_level = self._current_level + 1
    if self._current_level == self._max_levels then
        self._disable_counting = true
        self._text:set_text("MAX")
        self:FitTheText()
        self:SetTextColor(Color.green)
    else
        self:SetNewMax()
        self._time = 3
        self:AnimateNewLevel()
    end
    self._levels_text:set_text(self:FormatLevels())
end

function EHIPiggyBankMutatorTracker:SyncLoad(data)
    if data.exploded_pig_level then
        self:delete()
        return
    end
    self._progress = data.pig_fed_count
    self:CheckLevelFromKills()
end

function EHIPiggyBankMutatorTracker:AnimateNewLevel()
    if self._text and alive(self._text) then
        self._text:animate(function(o)
            local spins = 1
            while spins <= 3 do
                local t = 0
                while t < 1 do
                    t = t + coroutine.yield()
                    local n = 1 - sin(t * 180)
                    --local r = lerp(1, 0, n)
                    local g = lerp(1, 0, n)
                    local c = Color(g, 1, g)
                    self:SetTextColor(c)
                end
                spins = spins + 1
            end
            self:SetTextColor(Color.white)
        end)
    end
end

function EHIPiggyBankMutatorTracker:SetTextColor(color)
    self._levels_text:set_color(color)
    EHIPiggyBankMutatorTracker.super.SetTextColor(self, color)
end

function EHIPiggyBankMutatorTracker:delete()
    if self._text and alive(self._text) then
        self._text:stop()
    end
    EHIPiggyBankMutatorTracker.super.delete(self)
end