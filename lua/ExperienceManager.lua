if not Global.load_level then
    return
end

if EHI._hooks.ExperienceManager then
    return
else
    EHI._hooks.ExperienceManager = true
end

if EHI:IsXPTrackerDisabled() then
    return
end

local BaseXP = 0
local TotalXP = 0
local OldTotalXP = 0
local xp_format = EHI:GetOption("xp_format")
local xp_panel = EHI:GetOption("xp_panel")
local EXPERIENCE = ""
local EXPERIENCE_GAINED = ""
local EXPERIENCE_TOTAL = ""
if EHI:IsOneXPElementHeist(Global.game_settings.level_id) and xp_panel == 2 then
    xp_panel = 1 -- Force one XP panel when the heist gives you the XP at the escape zone -> less screen clutter
end

local _f_init = ExperienceManager.init
function ExperienceManager:init(...)
    _f_init(self, ...)
    self:EHIInitFinalize()
end

function ExperienceManager:EHIInitFinalize()
    self._xp =
    {
        mutator_xp_reduction = 0,
        level_to_stars = math.clamp(math.ceil((self:current_level() + 1) / 10), 1, 10), -- Can't call the function directly because they didn't use "self"
        in_custody = false,
        alive_players = Global.game_settings.single_player and 1 or 0,
        gage_bonus = 1,
        stealth = true,
        pda9_rewards = tweak_data.mutators.piggybank.rewards,
        current_difficulty = Global.game_settings.difficulty
    }
    if xp_format == 3 then -- Multiply
        local function f()
            self._xp.stealth = false
            self:RecalculateSkillXPMultiplier()
        end
        EHI:AddOnAlarmCallback(f)
        local function f2(state)
            self:SetInCustody(state)
        end
        EHI:AddOnCustodyCallback(f2)
    end
    EXPERIENCE = managers.localization:text("ehi_popup_experience")
    local gained = xp_format == 1 and "ehi_popup_experience_base_gained" or "ehi_popup_experience_gained"
    if xp_panel == 4 then
        gained = "ehi_popup_experience_gained"
    end
    EXPERIENCE_GAINED = managers.localization:text(gained)
    EXPERIENCE_TOTAL = managers.localization:text("ehi_popup_experience_total")
end

function ExperienceManager:SetJobData(data)
    self._xp.job_stars = data.job_stars
    self._xp.difficulty_stars = data.difficulty_stars
    self._xp.stealth_bonus = data.stealth_bonus
    self._xp.level_id = data.level_id
    self._xp.projob_multiplier = data.projob_multiplier
    self._xp.heat = data.heat
    self._xp.contract_difficulty_multiplier = self:get_contract_difficulty_multiplier(data.difficulty_stars)
    self._xp.is_level_limited = self._xp.level_to_stars < data.job_stars
    if xp_format ~= 1 then
        self._xp.difficulty_multiplier = tweak_data:get_value("experience_manager", "difficulty_multiplier", data.difficulty_stars) or 1
    end
end

function ExperienceManager:SetPlayerData(data)
    self._xp.infamy_bonus = data.infamy_bonus
    self._xp.skill_xp_multiplier = data.skill_xp_multiplier
	local multiplier = tweak_data:get_value("experience_manager", "limited_bonus_multiplier") or 1
    local level_data = self._xp.level_id and tweak_data.levels[self._xp.level_id] or {}
	if level_data.is_christmas_heist then
		multiplier = multiplier + (tweak_data:get_value("experience_manager", "limited_xmas_bonus_multiplier") or 1) - 1
	end
	self._xp.limited_xp_bonus = multiplier
end

function ExperienceManager:UpdateSkillXPMultiplier(multiplier)
    self._xp.skill_xp_multiplier = multiplier
    self:RecalculateXP()
end

function ExperienceManager:RecalculateSkillXPMultiplier()
    self:UpdateSkillXPMultiplier(managers.player:get_skill_exp_multiplier(self._xp.stealth))
end

function ExperienceManager:SetMutatorData(data)
    self._xp.mutator_xp_reduction = data.xp_reduction * -1
    self._xp.pda9_event_active = data.pda9_event_active
end

function ExperienceManager:SetGagePackageBonus(bonus)
    self._xp.gage_bonus = bonus
    self:RecalculateXP()
end

function ExperienceManager:SetInCustody(in_custody)
    self._xp.in_custody = in_custody
    if in_custody then
        self._xp.alive_players = math.max(self._xp.alive_players - 1, 0)
    else
        self._xp.alive_players = self._xp.alive_players + 1
    end
    self:RecalculateXP()
end

function ExperienceManager:IncreaseAlivePlayers()
    self._xp.alive_players = self._xp.alive_players + 1
    self:RecalculateXP()
end

function ExperienceManager:QueryAmountOfAlivePlayers()
    self._xp.alive_players = managers.network:session() and managers.network:session():amount_of_alive_players() or 0
    self:RecalculateSkillXPMultiplier()
end

function ExperienceManager:DecreaseAlivePlayers(human_player)
    self._xp.alive_players = math.max(self._xp.alive_players - 1, 0)
    if human_player then
        self:RecalculateSkillXPMultiplier()
    else
        self:RecalculateXP()
    end
end

local Show = function() end
if xp_panel == 1 then
    Show = function(self, diff)
        if managers.ehi:TrackerExists("XP") then
            managers.ehi:AddXPToTracker("XP", diff)
        else
            managers.ehi:AddTracker({
                id = "XP",
                amount = diff,
                exclude_from_sync = true,
                class = "EHIXPTracker"
            })
        end
    end
elseif xp_panel == 3 then
    Show = function(self, diff)
        if managers.hud then
            managers.hud:custom_ingame_popup_text(EXPERIENCE, EXPERIENCE_GAINED .. self:cash_string(diff, diff >= 0 and "+" or "") .. "\n" .. EXPERIENCE_TOTAL .. self:cash_string(TotalXP, "+"), "EHI_XP")
        end
    end
elseif xp_panel == 4 then
    Show = function(self, diff)
        if managers.hud and managers.hud._hud_hint then
            managers.hud:show_hint({ text = EXPERIENCE_GAINED .. self:cash_string(diff, diff >= 0 and "+" or "") .. " XP; ".. EXPERIENCE_TOTAL .. self:cash_string(TotalXP, "+") .. " XP" })
        end
    end
end

function ExperienceManager:ShowGainedXP(base_xp, xp_gained, xp_force)
    BaseXP = BaseXP + base_xp
    TotalXP = xp_force or (TotalXP + (xp_gained or base_xp))
    if OldTotalXP ~= TotalXP then
        local diff = TotalXP - OldTotalXP
        OldTotalXP = TotalXP
        Show(self, diff)
    end
end

local f
if xp_panel == 2 then
    if xp_format == 1 then
        f = function(self, amount)
            if amount > 0 then
                managers.ehi:AddXPToTracker("XPTotal", amount)
            end
        end
    elseif xp_format == 2 then
        f = function(self, amount)
            if amount > 0 then
                managers.ehi:AddXPToTracker("XPTotal", amount * self._xp.difficulty_multiplier)
            end
        end
    else
        f = function(self, amount)
            if amount > 0 then
                BaseXP = BaseXP + amount
                managers.ehi:SetXPInTracker("XPTotal", self:MultiplyXPWithAllBonuses(BaseXP))
            end
        end
    end
else
    if xp_format == 1 then
        f = function(self, amount)
            if amount > 0 then
                self:ShowGainedXP(amount)
            end
        end
    elseif xp_format == 2 then
        f = function(self, amount)
            if amount > 0 then
                self:ShowGainedXP(amount, amount * self._xp.difficulty_multiplier)
            end
        end
    else
        f = function(self, amount)
            if amount > 0 then
                self:ShowGainedXP(amount, self:MultiplyXPWithAllBonuses(amount))
            end
        end
    end
end

EHI:Hook(ExperienceManager, "mission_xp_award", f)

local math_round = math.round
function ExperienceManager:MultiplyXPWithAllBonuses(xp)
	local job_stars = self._xp.job_stars
	local num_winners = self._xp.alive_players
	local player_stars = self._xp.level_to_stars
	local pro_job_multiplier = self._xp.projob_multiplier
	local ghost_multiplier = 1 + self._xp.stealth_bonus
	local xp_multiplier = self._xp.contract_difficulty_multiplier
	local contract_xp = 0
	local total_xp = 0
	local stage_xp_dissect = 0
	local job_xp_dissect = 0
	local risk_dissect = 0
	local personal_win_dissect = 0
	local alive_crew_dissect = 0
	local skill_dissect = 0
	local base_xp = 0
	local job_heat_dissect = 0
	local ghost_dissect = 0
	local infamy_dissect = 0
	local extra_bonus_dissect = 0
	local gage_assignment_dissect = 0
	local mission_xp_dissect = xp
	local pro_job_xp_dissect = 0
	local bonus_xp = 0

	base_xp = job_xp_dissect + stage_xp_dissect + mission_xp_dissect
	pro_job_xp_dissect = math_round(base_xp * pro_job_multiplier - base_xp)
	base_xp = base_xp + pro_job_xp_dissect

	if self._xp.is_level_limited then
		local diff_in_stars = job_stars - player_stars
		local tweak_multiplier = tweak_data:get_value("experience_manager", "level_limit", "pc_difference_multipliers", diff_in_stars) or 0
		base_xp = math_round(base_xp * tweak_multiplier)
	end

	contract_xp = base_xp
	risk_dissect = math_round(contract_xp * xp_multiplier)
	contract_xp = contract_xp + risk_dissect

	if self._xp.in_custody then
		local multiplier = tweak_data:get_value("experience_manager", "in_custody_multiplier") or 1
		personal_win_dissect = math_round(contract_xp * multiplier - contract_xp)
		contract_xp = contract_xp + personal_win_dissect
	end

	total_xp = contract_xp
	local total_contract_xp = total_xp
	bonus_xp = self._xp.skill_xp_multiplier
	skill_dissect = math_round(total_contract_xp * bonus_xp - total_contract_xp)
	total_xp = total_xp + skill_dissect
	bonus_xp = self._xp.infamy_bonus
	infamy_dissect = math_round(total_contract_xp * bonus_xp - total_contract_xp)
	total_xp = total_xp + infamy_dissect

    local num_players_bonus = num_winners and tweak_data:get_value("experience_manager", "alive_humans_multiplier", num_winners) or 1
    alive_crew_dissect = math_round(total_contract_xp * num_players_bonus - total_contract_xp)
    total_xp = total_xp + alive_crew_dissect

	bonus_xp = self._xp.gage_bonus
	gage_assignment_dissect = math_round(total_contract_xp * bonus_xp - total_contract_xp)
	total_xp = total_xp + gage_assignment_dissect
	ghost_dissect = math_round(total_xp * ghost_multiplier - total_xp)
	total_xp = total_xp + ghost_dissect
	local heat_xp_mul = self._xp.heat
	job_heat_dissect = math_round(total_xp * heat_xp_mul - total_xp)
	total_xp = total_xp + job_heat_dissect
	bonus_xp = self._xp.limited_xp_bonus
	extra_bonus_dissect = math_round(total_xp * bonus_xp - total_xp)
    if self._xp.pda9_event_active then
        local pig_level = self._xp.pda9_event_exploded_level or false
        local bonus_piggybank_dissect = math_round(pig_level and (self._xp.pda9_rewards[self._xp.current_difficulty] or self._xp.pda9_rewards.default) * tweak_data.mutators.piggybank.pig_levels[pig_level].bag_requirement or 0)
	    total_xp = total_xp + bonus_piggybank_dissect
    end
	total_xp = total_xp + extra_bonus_dissect
	local bonus_mutators_dissect = total_xp * self._xp.mutator_xp_reduction
	total_xp = total_xp + bonus_mutators_dissect
    if self._xp.pda9_event_active then
	    total_xp = total_xp * 2
    end
	return total_xp
end

function ExperienceManager:RecalculateXP()
    if BaseXP == 0 or self._xp_update_blocked then
        return
    end
    if xp_format == 3 then
        if xp_panel == 2 then
            managers.ehi:SetXPInTracker("XPTotal", self:MultiplyXPWithAllBonuses(BaseXP))
        else
            self:ShowGainedXP(0, 0, self:MultiplyXPWithAllBonuses(BaseXP))
        end
    end
end

function ExperienceManager:BlockXPUpdate()
    self._xp_update_blocked = true
end

function ExperienceManager:SetPiggyBankExplodedLevel(level)
    self._xp.pda9_event_exploded_level = level
    self:RecalculateXP()
end