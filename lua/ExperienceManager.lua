if not Global.load_level then
    return
end

if EHI._hooks.ExperienceManager then
    return
else
    EHI._hooks.ExperienceManager = true
end

if not EHI:GetOption("show_gained_xp") then
    return
end

if Global.game_settings and Global.game_settings.gamemode and Global.game_settings.gamemode == "crime_spree" then
    return
end

local xp_format = EHI:GetOption("xp_format")
local xp_panel = EHI:GetOption("xp_panel")
local heat = 1
local difficulty_multiplier = 1
local projob_multiplier = 1  -- Not used in Vanilla, but other mods can create Pro Job missions
local limited_bonus_multiplier = (tweak_data:get_value("experience_manager", "limited_bonus_multiplier") or 1) - 1
local stealth_bonus = 1
local infamy_bonus = 0
local stealth_mode = true
if xp_format ~= 1 then
    local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty) - 2
    difficulty_multiplier = tweak_data:get_value("experience_manager", "difficulty_multiplier", difficulty_index) or 1
end

if xp_format == 3 then -- Multiply
    EHI:AddOnAlarmCallback(function()
        stealth_mode = false
    end)
end

local function MultiplyXPWillAllBonuses(base_amount)
    local player_bonus = math.max(0, (managers.player:get_skill_exp_multiplier(stealth_mode)) - 1) * heat
    return (base_amount * heat) * difficulty_multiplier * (1 + player_bonus + infamy_bonus + limited_bonus_multiplier) * stealth_bonus * projob_multiplier
end

local TrackerID = xp_panel == 1 and "XP" or "XPTotal"

function ExperienceManager:SetJobHeat(job_heat)
    if xp_format == 3 then
        heat = job_heat
        difficulty_multiplier = difficulty_multiplier * job_heat
        limited_bonus_multiplier = limited_bonus_multiplier * job_heat
        projob_multiplier = projob_multiplier * job_heat
        stealth_bonus = stealth_bonus * job_heat
        infamy_bonus = infamy_bonus * job_heat
    end
end

function ExperienceManager:SetProJobMultiplier(multiplier)
    projob_multiplier = multiplier
end

function ExperienceManager:SetStealthBonus(bonus)
    stealth_bonus = 1 + bonus
end

function ExperienceManager:SetInfamyBonus(bonus)
    infamy_bonus = bonus
end

local f
if xp_panel == 1 then
    if xp_format == 1 then
        f = function(self, amount)
            if amount > 0 then
                if managers.ehi:TrackerExists(TrackerID) then
                    managers.ehi:AddXPToTracker(TrackerID, amount)
                else
                    managers.ehi:AddTracker({
                        id = TrackerID,
                        amount = amount,
                        exclude_from_sync = true,
                        class = "EHIXPTracker"
                    })
                end
            end
        end
    elseif xp_format == 2 then
        f = function(self, amount)
            if amount > 0 then
                if managers.ehi:TrackerExists(TrackerID) then
                    managers.ehi:AddXPToTracker(TrackerID, amount * difficulty_multiplier)
                else
                    managers.ehi:AddTracker({
                        id = TrackerID,
                        amount = amount * difficulty_multiplier,
                        exclude_from_sync = true,
                        class = "EHIXPTracker"
                    })
                end
            end
        end
    else
        f = function(self, amount)
            if amount > 0 then
                local xp_gained = MultiplyXPWillAllBonuses(amount)
                if managers.ehi:TrackerExists(TrackerID) then
                    managers.ehi:AddXPToTracker(TrackerID, xp_gained)
                else
                    managers.ehi:AddTracker({
                        id = TrackerID,
                        amount = xp_gained,
                        exclude_from_sync = true,
                        class = "EHIXPTracker"
                    })
                end
            end
        end
    end
else
    if xp_format == 1 then
        f = function(self, amount)
            if amount > 0 then
                managers.ehi:AddXPToTracker(TrackerID, amount)
            end
        end
    elseif xp_format == 2 then
        f = function(self, amount)
            if amount > 0 then
                managers.ehi:AddXPToTracker(TrackerID, amount * difficulty_multiplier)
            end
        end
    else
        f = function(self, amount)
            if amount > 0 then
                managers.ehi:AddXPToTracker(TrackerID, MultiplyXPWillAllBonuses(amount))
            end
        end
    end
end

EHI:Hook(ExperienceManager, "mission_xp_award", f)