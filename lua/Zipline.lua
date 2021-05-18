if EHI._hooks.ZipLine then
	return
else
	EHI._hooks.ZipLine = true
end

if not EHI:GetOption("show_zipline_timer") then
    return
end

local original =
{
    init = ZipLine.init,
    attach_bag = ZipLine.attach_bag,
    set_user = ZipLine.set_user,
    sync_set_user = ZipLine.sync_set_user
}
local bag_time_correction = 0
local user_time_correction = 0
local level_id = Global.game_settings.level_id
if level_id == "dah" then
    bag_time_correction = 1
end

function ZipLine:init(unit)
    original.init(self, unit)
    local key = tostring(unit:key())
    self._ehi_key_bag_half = key .. "_bag_drop"
    self._ehi_key_bag_full = key .. "_bag_reset"
    self._ehi_key_user_half = key .. "_person_drop"
    self._ehi_key_user_full = key .. "_person_reset"
end

function ZipLine:attach_bag(bag)
    original.attach_bag(self, bag)
    local total_time = self:total_time()
    managers.ehi:AddTracker({
        id = self._ehi_key_bag_half,
        time = total_time - bag_time_correction,
        icons = { "equipment_winch_hook", "wp_bag", "pd2_goto" }
    })
    managers.ehi:AddTracker({
        id = self._ehi_key_bag_full,
        time = (total_time * 2) - bag_time_correction,
        icons = { "equipment_winch_hook", "restarter" }
    })
end

local function AddUserZipline(self, unit)
    if unit then
        local total_time = self:total_time()
        managers.ehi:AddTracker({
            id = self._ehi_key_user_half,
            time = total_time,
            icons = { "equipment_winch_hook", "pd2_escape", "pd2_goto" }
        })
        managers.ehi:AddTracker({
            id = self._ehi_key_user_full,
            time = total_time * 2,
            icons = { "equipment_winch_hook", "restarter" }
        })
    end
end

function ZipLine:set_user(unit)
    original.set_user(self, unit)
    AddUserZipline(self, unit)
end

function ZipLine:sync_set_user(unit)
    original.sync_set_user(self, unit)
    AddUserZipline(self, unit)
end