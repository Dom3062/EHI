if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

local EHI = EHI
if EHI._hooks.ElementAwardAchievment then
    return
else
    EHI._hooks.ElementAwardAchievment = true
end
local level_id = Global.game_settings.level_id
local triggers = nil
if level_id == "red2" then -- First World Bank
    triggers = {
        [107072] = { id = "cac_10" }
    }
elseif level_id == "dinner" then -- Slaughterhouse
    triggers = {
        [102841] = { id = "farm_4" }
    }
elseif level_id == "flat" then -- Panic Room
    triggers = {
        [104859] = { id = "flat_2" },
        [100805] = { id = "cac_9" }
    }
elseif level_id == "mia_2" then -- Hotline Miami Day 2
    triggers = {
        [EHI:GetInstanceElementID(100027, 3500)] = { id = "HostageBomb" },
        [EHI:GetInstanceElementID(100027, 3750)] = { id = "HostageBomb" },
        [EHI:GetInstanceElementID(100027, 3900)] = { id = "HostageBomb" },
        [EHI:GetInstanceElementID(100027, 4450)] = { id = "HostageBomb" },
        [EHI:GetInstanceElementID(100027, 4900)] = { id = "HostageBomb" },
        [EHI:GetInstanceElementID(100027, 6100)] = { id = "HostageBomb" },
        [EHI:GetInstanceElementID(100027, 17600)] = { id = "HostageBomb" },
        [EHI:GetInstanceElementID(100027, 17650)] = { id = "HostageBomb" }
    }
elseif level_id == "crojob2" then -- The Bomb: Dockyard
    triggers = {
        [102479] = { id = "cow_11" }
    }
elseif level_id == "firestarter_3" then -- Firestarter Day 3
    triggers = {
        [105237] = { id = "slakt_5" }
    }
elseif level_id == "peta_1" then -- Goat Simulator Heist Day 1
    triggers = {
        [EHI:GetInstanceElementID(100080, 2900)] = { id = "peta_2" }
    }
elseif level_id == "rvd1" then -- Reservoir Dogs Heist Day 2
    triggers = {
        [100247] = { id = "rvd_10" }
    }
elseif level_id == "dah" then -- Diamond Heist
    triggers = {
        [102259] = { id = "dah_8" } -- Achievement is a bit buggy with high ping clients
    }
else
    return
end

local function Trigger(id)
    if triggers[id] then
        managers.ehi:CallFunction(triggers[id].id, "SetCompleted", true)
    end
end

local _f_on_executed = ElementAwardAchievment.on_executed
function ElementAwardAchievment:on_executed(instigator)
    _f_on_executed(self, instigator)
    Trigger(self._id)
end