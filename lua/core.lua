if _G.EHI then
    _G.EHI = _G.EHI or {}
    return
end

_G.EHI =
{
    debug = false,
    settings = {},

    _hooks = {},

    _sync_triggers = {},

    _cache =
    {
    },

    SyncMessages =
    {
        EHISyncAddTracker = "EHISyncAddTracker"
    },

    SpecialFunctions =
    {
        AddMoney = 1,
        RemoveTracker = 2,
        PauseTracker = 3,
        UnpauseTracker = 4,
        UnpauseTrackerIfExists = 5,
        ResetTrackerTimeWhenUnpaused = 6,
        AddTrackerIfDoesNotExist = 7,
        SetAchievementComplete = 8,
        AddToCache = 9,
        GetFromCache = 10,
        ReplaceTrackerWithTracker = 11,
        IncreaseChance = 12,
        ExecuteIfTrackerExists = 13,
        CreateAnotherTrackerWithTracker = 14,
        SetChanceWhenTrackerExists = 15,
        RemoveTriggerWhenExecuted = 16,
        Trigger = 17,
        RemoveTrigger = 18,
        SetTimeOrCreateTracker = 19,
        ExecuteIfElementIsEnabled = 20,
        RemoveTrackers = 21,
        CreateTrackers = 22,
        UnpauseTrackersOrCreateThem = 23,
        AddTime = 24,
        IncreaseProgress = 25,
        SetTimeNoAnimOrCreateTracker = 26,
        SetTrackerAccurate = 27,
        RemoveTriggers = 28,
        AddToGlobalCache = 29,
        GetFromGlobalCache = 30,
        SetAchievementFailed = 31,
        SetRandomTime = 32
    },

    ConditionFunctions =
    {
        IsLoud = function()
            if managers.groupai and not managers.groupai:state():whisper_mode() then
                return true
            end
            return false
        end,
        IsStealth = function()
            if managers.groupai and managers.groupai:state():whisper_mode() then
                return true
            end
            return false
        end
    },

    Icons =
    {
        Trophy = "trophy",
        Fire = "pd2_fire",
        Escape = "pd2_escape",
        LootDrop = "pd2_lootdrop",
        Fix = "pd2_fix",
        Bag = "wp_bag",
        Defend = "pd2_defend",
        C4 = "pd2_c4",
        Interact = "pd2_generic_interact",
        Winch = "equipment_winch_hook",
        Teargas = "teargas",
        Hostage = "hostage",
        Methlab = "pd2_methlab",
        Loop = "restarter",
        Wait = "faster",
        Vault = "C_Elephant_H_ElectionDay_Murphy",
        Car = "pd2_car",
        Heli = "heli",
        Boat = "boat",
        Lasers = "C_Dentist_H_BigBank_Entrapment"
    },

    difficulties = {
		"easy", -- Leftover from PD:TH
		"normal",
		"hard",
		"overkill",
		"overkill_145",
		"easy_wish",
		"overkill_290",
		"sm_wish"
	},

    ModVersion = tonumber(ModInstance:GetVersion()),
    ModPath = ModPath,
    LocPath = ModPath .. "loc/",
    LuaPath = ModPath .. "lua/",
    MenuPath = ModPath .. "menu/",
    SettingsSaveFilePath = BLTModManager.Constants:SavesDirectory() .. "ehi.json",
    SaveDataVer = 1
}

function EHI:DifficultyToIndex(difficulty)
    return table.index_of(self.difficulties, difficulty) - 2
end

function EHI:IsOVKOrAbove(difficulty)
    return self:DifficultyToIndex(difficulty) >= 3
end

function EHI:GetSpecialFunctions()
    return self.SpecialFunctions
end

function EHI:GetIcons()
    return self.Icons
end

function EHI:GetConditionFunctions()
    return self.ConditionFunctions
end

function EHI:Log(s)
    log("[EHI] " .. s)
end

function EHI:Load()
    self:LoadDefaultValues()
    local file = io.open(self.SettingsSaveFilePath, "r")
    if file then
        local table = json.decode(file:read('*all')) or {}
        file:close()
        if table.SaveDataVer and table.SaveDataVer == self.SaveDataVer then
            self:LoadValues(self.settings, table)
            self:Log("Loaded user settings")
        else
            self.SaveDataNotCompatible = true
            self:Save()
        end
    end
    self.ModVersion = tonumber(self.ModInstance:GetVersion())
end

function EHI:Save()
    self.settings.SaveDataVer = self.SaveDataVer
    self.settings.ModVersion = self.ModVersion
    local file = io.open(self.SettingsSaveFilePath, "w+")
    if file then
        file:write(json.encode(self.settings) or {})
        file:close()
    end
end

function EHI:LoadValues(bai_table, file_table)
    for k, v in pairs(file_table) do -- Load subtables in table and calls the same method to load subtables or values in that subtable
        if type(file_table[k]) == "table" and bai_table[k] then
            self:LoadValues(bai_table[k], v)
        end
    end
    for k, v in pairs(file_table) do
        if type(file_table[k]) ~= "table" then
            if bai_table and bai_table[k] ~= nil then -- Load values to the table
                bai_table[k] = v
            end
        end
    end
end

function EHI:DelayCall(name, t, func)
    DelayedCalls:Add(name, t, func)
end

function EHI:LoadDefaultValues()
    self.settings =
    {
        -- Common
        x_offset = 0,
        y_offset = 150,
        scale = 1,
        vr_scale = 2.5,
        time_format = 2,

        -- Visuals
        show_tracker_bg = true,
        show_one_icon = false,

        -- Trackers
        show_achievement = true,
        show_gained_xp = true,
        xp_format = 3,
        xp_panel = 1,
        show_trade_delay = true,
        show_trade_delay_option = 1,
        show_trade_delay_other_players_only = true,
        show_timers = true,
        show_zipline_timer = true,
        show_gage_tracker = true,
        show_captain_damage_reduction = true,
        show_equipment_tracker = true,
        equipment_format = 1,
        show_equipment_doctorbag = true,
        show_equipment_ammobag = true,
        show_equipment_grenadecases = true,
        show_equipment_bodybags = true,
        show_equipment_firstaidkit = true,
        show_equipment_aggregate_health = true,
        show_minion_tracker = true,
        show_difficulty_tracker = true,
        show_pager_tracker = true,
        show_enemy_count_tracker = true
    }
    self:Log("Default values loaded")
end

function EHI:GetOption(option)
    if option then
        return self.settings[option]
    end
end

function EHI:Hook(object, func, post_call)
    Hooks:PostHook(object, func, "EHI_" .. func, post_call)
end

function EHI:Unhook(id)
    Hooks:RemovePostHook("EHI_" .. id)
end

function EHI:GetPeerColor(unit)
    local color = Color.white
    if unit then
        color = managers.criminals:character_color_id_by_unit(unit)
        color = tweak_data.chat_colors[color] or Color.white
    else
        self:Log("unit is nil, returned color set to white")
    end
    return color
end

function EHI:GetPeerColorByPeerID(peer_id)
    local color = Color.white
    if peer_id then
        color = tweak_data.chat_colors[peer_id] or Color.white
    else
        self:Log("peer_id is nil, returned color set to white")
    end
    return color
end

function EHI:GetInstanceElementID(id, start_index)
    return 100000 + math.mod(id, 100000) + 30000 + start_index
end

function EHI:GetInstanceUnitID(id, start_index)
    return self:GetInstanceElementID(id, start_index)
end

function EHI:RoundNumber(n, bracket)
    bracket = bracket or 1
    local sign = n >= 0 and 1 or -1
    return math.floor(n / bracket + sign * 0.5) * bracket
end

function EHI:Sync(message, data)
    LuaNetworking:SendToPeersExcept(LuaNetworking:LocalPeerID(), message, data or "")
end

function EHI:SetSyncTriggers(triggers)
    if self._sync_triggers then
        for key, value in pairs(triggers) do
            if self._sync_triggers[key] then
                self:Log("key: " .. tostring(key) .. " already exists in sync!")
            else
                self._sync_triggers[key] = value
            end
        end
    else
        self._sync_triggers = triggers
    end
end

function EHI:AddSyncTrigger(id, trigger)
    local table = {}
    table[id] = trigger
    self:SetSyncTriggers(table)
end

function EHI:AddTrackerSynced(id, delay)
    if self._sync_triggers[id] and managers.ehi then
        local trigger_id = self._sync_triggers[id].id
        if managers.ehi:TrackerExists(trigger_id) then
            managers.ehi:SetTrackerAccurate(trigger_id, (self._sync_triggers[id].time or 0) + delay)
        else
            managers.ehi:AddTracker({
                id = trigger_id,
                time = (self._sync_triggers[id].time or 0) + delay,
                icons = self._sync_triggers[id].icons,
                class = self._sync_triggers[id].class
            })
        end
        if self._sync_triggers[id].client_on_executed then
            -- Right now there is only SF.RemoveTriggerWhenExecuted
            self._sync_triggers[id] = nil
        end
    end
end

function EHI:DebugEquipment(tracker_id, unit, key, amount)
    self:Log("Received garbage. Key is nil. Tracker ID: " .. tostring(tracker_id))
    self:Log("unit: " .. tostring(unit))
    if unit and alive(unit) then
        self:Log("unit:name(): " .. tostring(unit:name()))
        self:Log("unit:key(): " .. tostring(unit:key()))
    end
    self:Log("key: " .. tostring(key))
    self:Log("amount: " .. tostring(amount))
    self:Log("traceback: " .. debug.traceback())
end

Hooks:Add("BaseNetworkSessionOnPeerRemoved", "BaseNetworkSessionOnPeerRemoved_EHI", function(peer, peer_id, reason)
    if managers.ehi then
        local tracker = managers.ehi:GetTracker("CustodyTime")
        if tracker then
            tracker:RemovePeerFromCustody(peer_id)
        end
    end
end)

EHI:Load()