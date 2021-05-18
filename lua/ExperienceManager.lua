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
local difficulty_multiplier = 1
local limited_bonus_multiplier = (tweak_data:get_value("experience_manager", "limited_bonus_multiplier") or 1) - 1
if xp_format ~= 1 then
    local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty) - 2
    difficulty_multiplier = tweak_data:get_value("experience_manager", "difficulty_multiplier", difficulty_index) or 1
end

local function MultiplyXPWillAllBonuses(base_amount)
    local stealth_bonus = 1 + (managers.job:get_ghost_bonus() or 0)
    local player_bonus = math.max(0, (managers.player:get_skill_exp_multiplier(managers.groupai and managers.groupai:state():whisper_mode())) - 1)
    local infamy_bonus = math.max(0, managers.player:get_infamy_exp_multiplier() - 1)
    return base_amount * difficulty_multiplier * (1 + player_bonus + infamy_bonus + limited_bonus_multiplier) * stealth_bonus
end

local f
if EHI:GetOption("xp_panel") == 1 then
    if xp_format == 1 then
        f = function(self, amount)
            if amount > 0 and managers.ehi then
                local id = "XP"
                if managers.ehi:TrackerExists(id) then
                    managers.hud:AddXP(id, amount)
                else
                    managers.ehi:AddTracker({
                        id = id,
                        amount = amount,
                        class = "EHIXPTracker"
                    })
                end
            end
        end
    elseif xp_format == 2 then
        f = function(self, amount)
            if amount > 0 and managers.hud.ehi then
                local id = "XP"
                if managers.ehi:TrackerExists(id) then
                    managers.hud:AddXP(id, amount * difficulty_multiplier)
                else
                    managers.ehi:AddTracker({
                        id = id,
                        amount = amount * difficulty_multiplier,
                        class = "EHIXPTracker"
                    })
                end
            end
        end
    else
        f = function(self, amount)
            if amount > 0 and managers.hud.ehi then
                local id = "XP"
                local xp_gained = MultiplyXPWillAllBonuses(amount)
                if managers.ehi:TrackerExists(id) then
                    managers.hud:AddXP(id, xp_gained)
                else
                    managers.ehi:AddTracker({
                        id = id,
                        amount = xp_gained,
                        class = "EHIXPTracker"
                    })
                end
            end
        end
    end
else
    if xp_format == 1 then
        f = function(self, amount)
            if amount > 0 and managers.hud.ehi then
                managers.hud:AddXP("XPTotal", amount)
            end
        end
    elseif xp_format == 2 then
        f = function(self, amount)
            if amount > 0 and managers.hud.ehi then
                managers.hud:AddXP("XPTotal", amount * difficulty_multiplier)
            end
        end
    else
        f = function(self, amount)
            if amount > 0 and managers.hud.ehi then
                local xp_gained = MultiplyXPWillAllBonuses(amount)
                managers.hud:AddXP("XPTotal", xp_gained)
            end
        end
    end
end

EHI:Hook(ExperienceManager, "mission_xp_award", f)