local EHI = EHI
if EHI._hooks.IngameWaitingForPlayersState then
    return
else
    EHI._hooks.IngameWaitingForPlayersState = true
end

local function CheckIfCashBlasterIsEquipped()
    local outfit = managers.blackmarket:unpack_outfit_from_string(managers.blackmarket:outfit_string())
    local secondary = managers.weapon_factory:get_weapon_id_by_factory_id(outfit.secondary.factory_id)
    return secondary == "money"
end

local function AddGageTracker()
    if EHI:GetOption("show_gage_tracker") and managers.ehi:TrackerDoesNotExist("Gage") and EHI._cache.GagePackages and EHI._cache.GagePackages > 0 then
        local max = tweak_data.gage_assignment:get_num_assignment_units() or 1
        managers.ehi:AddTracker({
            id = "Gage",
            icons = { "gage" },
            progress = EHI._cache.GagePackagesProgress or 0,
            max = max,
            class = "EHIProgressTracker"
        })
    end
end

local function f()
    local idstring = Idstring("units/pd2_dlc_nmh/props/nmh_prop_counter/nmh_prop_counter")
    local units = World:find_units_quick("all", 1)
    for _, unit in pairs(units) do
        if unit and unit:name() == idstring and unit:digital_gui() then
            EHI:Log("Found counter; Timer: " .. tostring(unit:digital_gui()._timer) .. "; Timer Count Down: " .. tostring(unit:digital_gui()._timer_count_down) .. "; Paused: " .. tostring(unit:digital_gui()._timer_paused))
        end
    end
end

local original =
{
    at_exit = IngameWaitingForPlayersState.at_exit
}
function IngameWaitingForPlayersState:at_exit(...)
    original.at_exit(self, ...)
    if not Global.hud_disabled then
        managers.ehi:ShowPanel()
    end
    AddGageTracker()
    if CheckIfCashBlasterIsEquipped() then
        managers.ehi:AddTracker({
            id = "Offshore",
            class = "EHIOffshoreSpendTracker"
        })
        local offshore_multiplier = tweak_data:get_value("money_manager", "moneythrower", "kill_to_offshore_multiplier")
        EHI:Hook(StatisticsManager, "killed", function(self, data)
            local by_bullet = data.variant == "bullet"
            local by_melee = data.variant == "melee" or data.weapon_id and tweak_data.blackmarket.melee_weapons[data.weapon_id]
            local by_explosion = data.variant == "explosion"
            local by_other_variant = not by_bullet and not by_melee and not by_explosion
            if by_other_variant then
                local name_id, _ = self:_get_name_id_and_throwable_id(data.weapon_unit)
                if name_id and name_id == "money" then
                    managers.ehi:AddMoneyToTracker("Offshore", offshore_multiplier)
                end
            end
        end)
    end
    if EHI.debug then
        for _, unit in pairs(managers.interaction._interactive_units or {}) do
            EHI:Log("unit:interaction().tweak_data = " .. tostring(unit:interaction().tweak_data))
        end
        EHI:DelayCall("Debug", 5, f)
    end
end