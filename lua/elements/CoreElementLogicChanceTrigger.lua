if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

local EHI = rawget(_G, "EHI")
if EHI._hooks.ElementLogicChanceTrigger then
    return
else
    EHI._hooks.ElementLogicChanceTrigger = true
end

-- Big Oil Day 2
-- 103129

core:module("CoreElementLogicChance")

local function deep_clone(o)
	if type(o) == "userdata" then
		return o
	end

	local res = {}

	setmetatable(res, getmetatable(o))

	for k, v in pairs(o) do
		if type(v) == "table" then
			res[k] = deep_clone(v)
		else
			res[k] = v
		end
	end

	return res
end

local function GetInstanceElementID(id, start_index)
    return 100000 + math.mod(id, 100000) + 30000 + start_index
end

local level_id = Global.game_settings.level_id
local triggers = {}

if level_id == "nmh" then -- No Mercy
    local outcome =
    {
        [100013] = { time = 25 + 40/30, random_time = { low = 15, high = 20 }, id = "Fail", icons = { "equipment_bloodvial", "restarter" }, class = "EHIInaccurateTracker" },
        [100017] = { time = 30, id = "Success", icons = { "equipment_bloodvialok" } }
    }

    local start_index_table =
    {
        2100, 2200, 2300, 2400, 2500, 2600, 2700
    }

    for id, value in pairs(outcome) do
        for _, index in ipairs(start_index_table) do
            local element = GetInstanceElementID(id, index)
            triggers[element] = deep_clone(value)
            triggers[element].id = triggers[element].id .. tostring(element)
        end
    end
elseif level_id == "man" then -- Undercover
    triggers = {
        [102866] = { time = 5, id = "GotCode", icons = { "faster" } }
    }
else
    return
end

local function GetTime(id)
    local full_time = triggers[id].time or 0
    full_time = full_time + (triggers[id].random_time and math.random(triggers[id].random_time.low, triggers[id].random_time.high) or 0)
    return full_time
end

local function CreateTrackerForReal(id, icon2)
    if icon2 then
        triggers[id].icons[2] = icon2
    end
    managers.ehi:AddTracker({
        id = triggers[id].id or trigger_id_all,
        time = GetTime(id),
        chance = triggers[id].chance,
        max = triggers[id].max,
        icons = triggers[id].icons or trigger_icon_all,
        class = triggers[id].class
    })
end

local function CreateTracker(id)
    if triggers[id].condition ~= nil then
        if triggers[id].condition == true then
            CreateTrackerForReal(id)
        end
    else
        CreateTrackerForReal(id)
    end
end

local function Trigger(id)
    if triggers[id] then
        if triggers[id].special_function then
            local f = triggers[id].special_function
            if f == SF.AddMoney then
                managers.hud:AddMoney(triggers[id].id, triggers[id].amount)
            elseif f == SF.RemoveTracker then
                managers.hud:RemoveTracker(triggers[id].id)
            elseif f == SF.PauseTracker then
                managers.ehi:PauseTracker(triggers[id].id)
            elseif f == SF.UnpauseTracker then
                managers.ehi:UnpauseTracker(triggers[id].id)
            elseif f == SF.UnpauseTrackerIfExists then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    managers.ehi:UnpauseTracker(triggers[id].id)
                else
                    CreateTracker(id)
                end
            elseif f == SF.ResetTrackerTimeWhenUnpaused then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    managers.hud:ResetTrackerTimeAndUnpause(triggers[id].id)
                else
                    CreateTracker(id)
                end
            elseif f == SF.AddTrackerIfDoesNotExist then
                if managers.ehi:TrackerDoesNotExist(triggers[id].id) then
                    CreateTracker(id)
                end
            elseif f == SF.CreateTrackerIfDoesNotExistOrAddDelayWhenUnpaused then
                local trigger = triggers[id]
                if managers.ehi:TrackerExists(trigger.id) then
                    managers.hud:AddDelayToTrackerAndUnpause(trigger.id, trigger.delay_time)
                else
                    CreateTracker(id)
                end
            elseif f == SF.AddToCache then
                _cache[triggers[id].id or trigger_id_all] = triggers[id].data
            elseif f == SF.GetFromCache then
                local data = _cache[triggers[id].id or trigger_id_all]
                _cache[triggers[id].id or trigger_id_all] = nil
                CreateTrackerForReal(triggers[id].id or trigger_id_all, data.icon)
            elseif f == SF.ReplaceTrackerWithTracker then
                managers.hud:RemoveTracker(triggers[id].data.id)
                triggers[triggers[id].data.trigger] = nil -- Removes trigger from the list, used in The White House
                CreateTracker(id)
            elseif f == SF.IncreaseChance then
                local trigger = triggers[id]
                managers.hud.ehi:IncreaseChance(trigger.id, trigger.amount)
            elseif f == SF.CreateAnotherTrackerWithTracker then
                CreateTracker(id)
                CreateTracker(triggers[id].data.fake_id)
            elseif f == SF.ExecuteIfTrackerExists then
                local data = triggers[id].data
                if managers.ehi:TrackerExists(data.id) then
                    managers.hud:SetTime(triggers[id].id, triggers[id].time)
                    managers.hud:RemoveTracker(data.id)
                end
            elseif f == SF.SetChanceWhenTrackerExists then
                local trigger = triggers[id]
                if managers.ehi:TrackerExists(trigger.id) then
                    managers.hud.ehi:SetChance(trigger.id, trigger.chance)
                else
                    CreateTracker(id)
                end
            end
        else
            CreateTracker(id)
        end
    end
end

local _f_client_on_executed = ElementLogicChanceTrigger.client_on_executed
function ElementLogicChanceTrigger:client_on_executed()
    _f_client_on_executed(self)
    Trigger(self._id)
end

local _f_on_executed = ElementLogicChanceTrigger.on_executed
function ElementLogicChanceTrigger:on_executed(...)
    _f_on_executed(self, ...)
    Trigger(self._id)
end