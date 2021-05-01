EHIPALTracker = EHIPALTracker or class(EHITracker)
function EHIPALTracker:init(panel, params)
    params.icons = { "money", "paper", "ink" }
    params.time = 60 -- money time
    self._money_not_paused = true
    self._paper_not_paused = true
    self._ink_not_paused = true
    self._paper_time = 80
    self._ink_time = 121
    EHIPALTracker.super.init(self, panel, params)
    local move = 49
    self._orange = tweak_data.ehi.color.InaccurateColor
    self._panel:set_w(self._panel:w() + move)
    for i = 1, 3, 1 do
        local icon = self["_icon" .. tostring(i)]
        icon:set_x(icon:x() + move)
    end
    self._time_bg_box:set_w(self._time_bg_box:w() + move)
    self._text:set_w(33)
    self:FitTheText()
    self._separator1 = self._time_bg_box:rect({
        name = "separator1",
        x = 35,
        w = 2,
        h = self._time_bg_box:h(),
        color = Color.white
    })
    self._text2 = self._time_bg_box:text({
        name = "text2",
        text = self:Format2(),
        align = "center",
        vertical = "center",
        x = 39,
        w = 33,
        h = self._time_bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h(),
        color = self._orange
    })
    self:FitTheText2()
    self._separator2 = self._time_bg_box:rect({
        name = "separator2",
        x = 74,
        w = 2,
        h = self._time_bg_box:h(),
        color = Color.white
    })
    self._text3 = self._time_bg_box:text({
        name = "text3",
        text = self:Format3(),
        align = "center",
        vertical = "center",
        x = 78,
        w = 33,
        h = self._time_bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h(),
        color = self._orange
    })
    self:FitTheText3()
end

local function SecondsOnly2(self)
    local t = math.floor(self._paper_time * 10) / 10

	if t < 0 then
		return string.format("%d", 0)
    elseif t < 1 then
        return string.format("%.2f", self._paper_time)
	elseif t < 10 then
		return string.format("%.1f", t)
	else
		return string.format("%d", t)
	end
end

local function MinutesAndSeconds2(self)
    local t = math.floor(self._paper_time * 10) / 10

	if t < 0 then
		return string.format("%d", 0)
    elseif t < 1 then
        return string.format("%.2f", self._paper_time)
	elseif t < 10 then
		return string.format("%.1f", t)
	elseif t < 60 then
		return string.format("%d", t)
	else
		return string.format("%d:%02d", t / 60, t % 60)
	end
end

local function SecondsOnly3(self)
    local t = math.floor(self._ink_time * 10) / 10

	if t < 0 then
		return string.format("%d", 0)
    elseif t < 1 then
        return string.format("%.2f", self._ink_time)
	elseif t < 10 then
		return string.format("%.1f", t)
	else
		return string.format("%d", t)
	end
end

local function MinutesAndSeconds3(self)
    local t = math.floor(self._ink_time * 10) / 10

	if t < 0 then
		return string.format("%d", 0)
    elseif t < 1 then
        return string.format("%.2f", self._ink_time)
	elseif t < 10 then
		return string.format("%.1f", t)
	elseif t < 60 then
		return string.format("%d", t)
	else
		return string.format("%d:%02d", t / 60, t % 60)
	end
end

if EHI:GetOption("time_format") == 1 then
    EHIPALTracker.Format2 = SecondsOnly2
    EHIPALTracker.Format3 = SecondsOnly3
else
    EHIPALTracker.Format2 = MinutesAndSeconds2
    EHIPALTracker.Format3 = MinutesAndSeconds3
end

function EHIPALTracker:update(t, dt)
    if self._money_not_paused then
        self._time = self._time - dt
        self._text:set_text(self:Format())
    end
    if self._paper_not_paused then
        self._paper_time = self._paper_time - dt
        self._text2:set_text(self:Format2())
    end
    if self._ink_not_paused then
        self._ink_time = self._ink_time - dt
        self._text3:set_text(self:Format3())
    end
end

function EHIPALTracker:ResetMoneyTime()
    self._time = 60
    self:FitTheText()
    self:SetMoneyPaused(true)
end

function EHIPALTracker:ResetPaperTime()
    self._paper_time = 80
    self:FitTheText2()
    self:SetPaperPaused(true)
end

function EHIPALTracker:ResetInkTime()
    self._ink_time = 121
    self:FitTheText3()
    self:SetInkPaused(true)
end

function EHIPALTracker:SetMoneyPaused(pause)
    self._money_not_paused = not pause
    self._text:set_color(self._money_not_paused and Color.white or Color.red)
end

function EHIPALTracker:SetPaperPaused(pause)
    self._paper_not_paused = not pause
    self._text2:set_color(self._paper_not_paused and self._orange or Color.red)
end

function EHIPALTracker:SetInkPaused(pause)
    self._ink_not_paused = not pause
    self._text3:set_color(self._ink_not_paused and self._orange or Color.red)
end

function EHITracker:FitTheText2()
    local w = select(3, self._text2:text_rect())
    if w > self._text2:w() then
        self._text2:set_font_size(self._text2:font_size() * (self._text2:w() / w))
    end
end

function EHITracker:FitTheText3()
    local w = select(3, self._text3:text_rect())
    if w > self._text3:w() then
        self._text3:set_font_size(self._text3:font_size() * (self._text3:w() / w))
    end
end

function EHIPALTracker:StopAll()
    self:SetMoneyPaused(true)
    self:SetPaperPaused(true)
    self:SetInkPaused(true)
end

function EHIPALTracker:ResumeAll()
    self:SetMoneyPaused(false)
    self:SetPaperPaused(false)
    self:SetInkPaused(false)
end