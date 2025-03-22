local EHI = EHI

---@class EHIExperienceManager
EHIExperienceManager = {}
EHIExperienceManager._XPElementLevel =
{
    jewelry_store = true,
    ukrainian_job = true,
    election_day_1 = true,
    alex_1 = true,
    firestarter_1 = true,
    safehouse = true
}
EHIExperienceManager._XPElementLevelNoCheck =
{
    mallcrasher = true, -- Mallcrasher
    rat = true, -- Cook Off

    -- Custom Missions
    ratdaylight = true,
    lid_cookoff_methslaves = true
}
EHIExperienceManager._XPElement = 0
---@param level_id string
function EHIExperienceManager:IsOneXPElementHeist(level_id)
    if self._XPElementLevelNoCheck[level_id] then
        return false
    end
    return self._XPElement <= 1 or self._XPElementLevel[level_id]
end

---@param element ElementExperience
function EHIExperienceManager:AddXPElement(element)
    if element._values.amount and element._values.amount > 0 then
        self._XPElement = self._XPElement + 1
    end
end

---@param trackers EHITrackerManager
function EHIExperienceManager:TrackersInit(trackers)
    self._trackers = trackers
end

---@param xp ExperienceManager
function EHIExperienceManager:ExperienceInit(xp)
    if self._config then
        return
    end
    self:ExperienceReload(xp)
    if EHI:CheckNotLoad() or EHI:IsXPTrackerDisabled() then
        self._xp_disabled = true
        self._config =
        {
            xp_format = EHI:GetOption("xp_format") --[[@as 1|2|3]]
        }
        if Global.load_level and not Global.editor_mode and EHI:GetOption("show_mission_xp_overview") then
            EHI:AddCallback(EHI.CallbackMessage.InitManagers, callback(self, self, "LoadData"))
        end
        return
    end
    self._config =
    {
        xp_format = EHI:GetOption("xp_format") --[[@as 1|2|3]],
        xp_panel = EHI:GetOption("xp_panel") --[[@as 1|2|3|4]],
        show_total_xp_diff = EHI:GetOption("total_xp_difference") --[[@as 1|2|3|4]]
    }
    self._config.show_xp_diff = self._config.show_total_xp_diff ~= 1
    self._base_xp = 0
    self._total_xp = 0
    self._ehi_xp = self:CreateXPTable()
    EHI:AddOnSpawnedCallback(callback(self, self, "UpdateSkillXPMultiplier"))
    Hooks:PostHook(HUDManager, "mark_cheater", "EHI_ExperienceManager_mark_cheater", function()
        self:UpdateSkillXPMultiplier()
    end)
    EHI:AddCallback(EHI.CallbackMessage.SyncGagePackagesCount, function(picked_up, max_units, client_sync_load)
        local multiplier = 1
        if picked_up > 0 then -- Don't use the in-game function because it is inaccurate by one package
            local ratio = 1 - (max_units - picked_up) / max_units
            multiplier = managers.gage_assignment._tweak_data:get_experience_multiplier(ratio)
        end
        self:SetGagePackageBonus(multiplier)
    end)
    local function Block()
        self._xp_disabled = true -- Block any XP updates if the mission ended or player quitted to menu
    end
    EHI:AddCallback(EHI.CallbackMessage.MissionEnd, Block)
    EHI:AddCallback(EHI.CallbackMessage.GameEnd, Block)
    EHI:AddCallback(EHI.CallbackMessage.GameRestart, Block)
    EHI:AddCallback(EHI.CallbackMessage.InitManagers, callback(self, self, "LoadData"))
    if _G.ch_settings then
        EHI:AddOnSpawnedCallback(Block)
    else
        EHI:AddCallback(EHI.CallbackMessage.InitFinalize, callback(self, self, "HookAwardXP"))
    end
end

function EHIExperienceManager:CreateXPTable()
    return
    {
        mutator_xp_reduction = 0,
        level_to_stars = math.clamp(math.ceil((self._xp.level + 1) / 10), 1, 10),
        in_custody = false,
        alive_players = Global.game_settings.single_player and 1 or 0,
        gage_bonus = 1,
        stealth = true,
        bonus_xp = 0,
        skill_xp_multiplier = 1, -- Recalculated in `EHIExperienceManager:UpdateSkillXPMultiplier()`
        difficulty_multiplier = 1,
        projob_multiplier = 1 -- Unavailable since `Update 109`, however mods can still enable Pro Job modifier in heists
    }
end

---@param xp ExperienceManager
function EHIExperienceManager:ExperienceReload(xp)
    self._xp = self._xp or {}
    self._xp.level = xp:current_level()
    local max_level = xp:reached_level_cap()
    self._xp.level_xp_to_100 = max_level and 0 or self:GetRemainingXPToMaxLevel(xp:total())
    self._xp.level_xp_to_next_level = max_level and 0 or math.max(xp:next_level_data_points() - xp:next_level_data_current_points(), 0)
    self._xp.prestige_xp = xp:get_current_prestige_xp()
    self._xp.prestige_xp_remaining = xp:get_max_prestige_xp() - self._xp.prestige_xp
    self._xp.prestige_enabled = max_level and xp:current_rank() > 0
end

---@param managers managers
function EHIExperienceManager:LoadData(managers)
    self._ehi_xp = self._ehi_xp or self:CreateXPTable()
    -- Job
    local job = managers.job
    local is_current_job_professional = job:is_current_job_professional()
    local difficulty_stars = job:current_difficulty_stars()
    self._ehi_xp.job_stars = job:current_job_stars()
    self._ehi_xp.stealth_bonus = job:get_ghost_bonus()
    if is_current_job_professional then
        self._ehi_xp.projob_multiplier = tweak_data:get_value("experience_manager", "pro_job_multiplier") or 1
    end
    local heat = job:get_job_heat_multipliers(job:current_job_id())
    self._ehi_xp.heat = heat and heat ~= 0 and heat or 1
    self._ehi_xp.is_level_limited = self._ehi_xp.level_to_stars < self._ehi_xp.job_stars
    if self._config.xp_format ~= 1 then
        self._ehi_xp.difficulty_multiplier = tweak_data:get_value("experience_manager", "difficulty_multiplier", difficulty_stars) or 1
    end
    -- Player
    local player = managers.player
    self._ehi_xp.infamy_bonus = player:get_infamy_exp_multiplier()
    local multiplier = tweak_data:get_value("experience_manager", "limited_bonus_multiplier") or 1
    if tweak_data.levels:IsLevelChristmas() then
        multiplier = multiplier + (tweak_data:get_value("experience_manager", "limited_xmas_bonus_multiplier") or 1) - 1
    end
    self._ehi_xp.limited_xp_bonus = multiplier
    -- Mutators
    local mutator = managers.mutators
    if mutator:can_mutators_be_active() then
        self._ehi_xp.mutator_xp_reduction = mutator:get_experience_reduction() * -1
    end
    if _G.ch_settings then
        self._ehi_xp.level_id = Global.game_settings.level_id
        self._ehi_xp.current_difficulty_stars = difficulty_stars
        local current_job_stage = job:current_stage() or 1
        self._ehi_xp.current_job_stage = current_job_stage
        self._ehi_xp.on_last_stage = job:on_last_stage()
        self._ehi_xp.xp_multiplier = managers.experience:get_contract_difficulty_multiplier(difficulty_stars or 0)
        self._ehi_xp.difficulty_multiplier = self._ehi_xp.xp_multiplier
        if is_current_job_professional then
            self._ehi_xp.prof = true
            if _G.ch_settings.settings.u24_progress then
                self._ehi_xp.projob_multiplier = tweak_data:get_value("experience_manager", "pro_day_multiplier", current_job_stage) or 1
            else
                self._ehi_xp.projob_multiplier = self._pro_day_multiplier[current_job_stage] or 1
            end
        end
    end
end

function EHIExperienceManager:HookAwardXP()
    local level_id = Global.game_settings.level_id
    if tweak_data.levels:IsLevelSafehouse(level_id) then
        return
    elseif self:IsOneXPElementHeist(level_id) and self._config.xp_panel == 2 then
        self._config.xp_panel = 1 -- Force one XP panel when the heist gives you the XP at the escape zone -> less screen clutter
        if self._config.show_xp_diff and self._config.show_total_xp_diff > 1 then
            self._config.xp_panel = self._config.show_total_xp_diff
        end
    end
    if self._config.xp_panel <= 2 then
        if self._config.xp_panel == 1 or self._config.show_total_xp_diff == 2 then
            ---@param id number
            ---@param amount number
            self._show = function(id, amount)
                local _id = string.format("XP%d", id)
                if self._trackers:CallFunction2(_id, "AddXP", amount) then
                    self._trackers:AddTracker({
                        id = _id,
                        amount = amount,
                        class = "EHIXPTracker"
                    })
                end
            end
        elseif self._config.show_total_xp_diff >= 3 then
            ---@param id number
            ---@param amount number
            self._show = function(id, amount)
                if self._trackers:TrackerExists("XPHidden") then
                    self._trackers:AddXPToTracker("XPHidden", amount)
                end
            end
        end
        if self._config.xp_panel == 2 then
            if self._config.xp_format == 1 then
                ---@param id number
                ---@param amount number
                self._xp_awarded = function(id, amount)
                    self._trackers:AddXPToTracker("XPTotal", amount)
                    if self._config.show_xp_diff then
                        self:ShowGainedXP(id, amount, amount)
                    end
                end
            elseif self._config.xp_format == 2 then
                ---@param id number
                ---@param amount number
                self._xp_awarded = function(id, amount)
                    local multiplied = amount * self._ehi_xp.difficulty_multiplier
                    self._trackers:AddXPToTracker("XPTotal", multiplied)
                    if self._config.show_xp_diff then
                        self:ShowGainedXP(id, amount, multiplied)
                    end
                end
            else
                ---@param id number
                ---@param amount number
                self._xp_awarded = function(id, amount)
                    self._base_xp = self._base_xp + amount
                    local new_total = self:MultiplyXPWithAllBonuses(self._base_xp)
                    self._trackers:SetXPInTracker("XPTotal", new_total)
                    if self._config.show_xp_diff then
                        self:ShowGainedXP(id, 0, new_total, true)
                    end
                end
            end
        end
    else
        ---@param id number
        ---@param amount number
        self._show = function(id, amount)
            if self._trackers:TrackerExists("XPHidden") then
                self._trackers:AddXPToTracker("XPHidden", amount)
            else
                self._xp_to_award = (self._xp_to_award or 0) + amount
            end
        end
    end
    if self._config.xp_panel ~= 2 then
        if self._config.xp_format == 1 then
            ---@param id number
            ---@param amount number
            self._xp_awarded = function(id, amount)
                self:ShowGainedXP(id, amount, amount)
            end
        elseif self._config.xp_format == 2 then
            ---@param id number
            ---@param amount number
            self._xp_awarded = function(id, amount)
                self:ShowGainedXP(id, amount, amount * self._ehi_xp.difficulty_multiplier)
            end
        else
            ---@param id number
            ---@param amount number
            self._xp_awarded = function(id, amount)
                self:ShowGainedXP(id, amount)
            end
        end
    end
    EHI:Hook(ExperienceManager, "on_loot_drop_xp", function(xp, value_id)
        local amount = tweak_data:get_value("experience_manager", "loot_drop_value", value_id) or 0
        if amount <= 0 then
            return
        end
        self._ehi_xp.bonus_xp = self._ehi_xp.bonus_xp + amount
        self:RecalculateXP(1)
        EHI:CallCallback("ExperienceManager_RefreshPlayerCount")
    end)
    if self._config.xp_panel ~= 1 then
        local one_element = self:IsOneXPElementHeist(level_id)
        if self._config.xp_panel == 2 then
            local xp_limit = self:GetPlayerXPLimit()
            if xp_limit > 0 and not one_element then
                self._trackers:AddTracker({
                    id = "XPTotal",
                    xp_limit = xp_limit,
                    xp_overflow_enabled = self._xp.prestige_enabled and EHI:IsModInstalled("Infamy Pool Overflow", "Dr_Newbie"),
                    class = "EHITotalXPTracker"
                })
            end
        end
        if self._config.xp_panel >= 3 or (self._config.xp_panel == 2 and self._config.show_total_xp_diff >= 3) then
            self._trackers:AddHiddenTracker({
                id = "XPHidden",
                amount = self._xp_to_award,
                panel = self._config.xp_panel == 2 and self._config.show_total_xp_diff or self._config.xp_panel,
                format = self._config.xp_format,
                refresh_t = one_element and 0,
                class = "EHIHiddenXPTracker"
            })
            self._xp_to_award = nil
        end
    end
end

function EHIExperienceManager:SwitchToLoudMode()
    if self._xp_disabled then
        return
    end
    self._ehi_xp.stealth = false
    self:UpdateSkillXPMultiplier()
end

---@param amount number
function EHIExperienceManager:MissionXPAwarded(amount)
    if amount <= 0 or self._xp_disabled then
        return
    elseif self._xp_awarded then
        self._xp_awarded(0, amount)
    end
end

function EHIExperienceManager:UpdateSkillXPMultiplier()
    self._ehi_xp.skill_xp_multiplier = managers.player:get_skill_exp_multiplier(self._ehi_xp.stealth)
    self:RecalculateXP(2)
end

---@param bonus number
function EHIExperienceManager:SetGagePackageBonus(bonus)
    self._ehi_xp.gage_bonus = bonus
    self:RecalculateXP(3)
end

---@param in_custody boolean
function EHIExperienceManager:SetInCustody(in_custody)
    if self._xp_disabled then
        return
    end
    self._ehi_xp.in_custody = in_custody
    if in_custody then
        self._ehi_xp.alive_players = math.max(self._ehi_xp.alive_players - 1, 0)
    else
        self._ehi_xp.alive_players = self._ehi_xp.alive_players + 1
    end
    self:RecalculateXP(4)
end

function EHIExperienceManager:IncreaseAlivePlayers()
    if self._xp_disabled then
        return
    end
    self._ehi_xp.alive_players = self._ehi_xp.alive_players + 1
    self:RecalculateXP(5)
end

function EHIExperienceManager:QueryAmountOfAllPlayers()
    local previous_value = self._ehi_xp.alive_players
    local human_players = managers.network:session() and managers.network:session():amount_of_alive_players()
    local bots = managers.groupai:state() and managers.groupai:state():amount_of_winning_ai_criminals()
    self._ehi_xp.alive_players = math.clamp(human_players + bots, 0, 4)
    if previous_value ~= self._ehi_xp.alive_players then
        self:UpdateSkillXPMultiplier()
    end
end

function EHIExperienceManager:QueryAmountOfAlivePlayers()
    self._ehi_xp.alive_players = managers.network:session() and managers.network:session():amount_of_alive_players()
    self:UpdateSkillXPMultiplier()
end

---@param human_player boolean?
function EHIExperienceManager:DecreaseAlivePlayers(human_player)
    if self._xp_disabled then
        return
    end
    self._ehi_xp.alive_players = math.max(self._ehi_xp.alive_players - 1, 0)
    if human_player then
        self:UpdateSkillXPMultiplier()
    else
        self:RecalculateXP(6)
    end
end

---@param id number
---@param base_xp number
---@param xp_gained number?
---@param xp_set boolean?
function EHIExperienceManager:ShowGainedXP(id, base_xp, xp_gained, xp_set)
    self._base_xp = self._base_xp + base_xp
    local new_total = xp_gained and (xp_set and xp_gained or (self._total_xp + xp_gained)) or self:MultiplyXPWithAllBonuses(self._base_xp)
    if self._total_xp ~= new_total then
        local diff = new_total - self._total_xp
        self._total_xp = new_total
        if self._show then
            self._show(id, diff)
        end
    end
end

if _G.ch_settings then
    EHIExperienceManager._pro_day_multiplier =
    {
        1.10,
        1.15,
        1.35,
        5.5,
        7,
        8.5,
        10
    }
    EHIExperienceManager._days_multiplier =
    {
        1,
        Global.game_settings and Global.game_settings.level_id == "peta2" and 2.35 or 1.3,
        1.75,
        4,
        5,
        6,
        7
    }
    ---@param xp number?
    ---@param default_xp_if_zero number?
    function EHIExperienceManager:MultiplyXPWithAllBonuses(xp, default_xp_if_zero)
        if not xp or xp <= 0 then
            return default_xp_if_zero or 0
        end
        local job_stars = self._ehi_xp.job_stars
        local num_winners = self._ehi_xp.alive_players
        local player_stars = self._ehi_xp.level_to_stars
        local level_id = self._ehi_xp.level_id
        local current_job_stage = self._ehi_xp.current_job_stage or 1
        local days_multiplier = 1 --params.professional and tweak_data:get_value("experience_manager", "pro_day_multiplier", current_job_stage) or tweak_data:get_value("experience_manager", "day_multiplier", current_job_stage)
        local ghost_multiplier = 1 + (self._ehi_xp.stealth_bonus or 0)
        local total_stars = math.min(job_stars, player_stars)
        local contract_xp = 0
        local total_xp = 0
        local stage_xp_dissect = 0
        local job_xp_dissect = 0
        local level_limit_dissect = 0
        local risk_dissect = 0
        local personal_win_dissect = 0
        local alive_crew_dissect = 0
        local skill_dissect = 0
        local base_xp = 0
        local days_dissect = 0
        local job_heat_dissect = 0
        local ghost_dissect = 0
        local infamy_dissect = 0
        local extra_bonus_dissect = 0
        if _G.ch_settings.settings.u24_progress then
            days_multiplier = self._ehi_xp.prof and tweak_data:get_value("experience_manager", "pro_day_multiplier", current_job_stage) or tweak_data:get_value("experience_manager", "day_multiplier", current_job_stage)
        else
            days_multiplier = self._ehi_xp.prof and self._pro_day_multiplier[current_job_stage] or self._days_multiplier[current_job_stage]
        end

        if self._ehi_xp.on_last_stage then
            job_xp_dissect = managers.experience:get_job_xp_by_stars(total_stars)
            level_limit_dissect = level_limit_dissect + managers.experience:get_job_xp_by_stars(job_stars)
        end

        local static_stage_experience = level_id and tweak_data.levels[level_id].static_experience
        static_stage_experience = static_stage_experience and static_stage_experience[(self._ehi_xp.current_difficulty_stars or 0) + 1]
        stage_xp_dissect = static_stage_experience or managers.experience:get_stage_xp_by_stars(total_stars)
        level_limit_dissect = level_limit_dissect + (static_stage_experience or managers.experience:get_stage_xp_by_stars(job_stars))
        base_xp = job_xp_dissect + stage_xp_dissect

        days_dissect = math.round(base_xp * days_multiplier - base_xp)
        if self._ehi_xp.is_level_limited then
            local diff_in_stars = job_stars - player_stars
            local days_tweak_multiplier = tweak_data:get_value("experience_manager", "day_multiplier", current_job_stage)
            local tweak_multiplier = tweak_data:get_value("experience_manager", "level_limit", "pc_difference_multipliers", diff_in_stars) or 0
            days_multiplier = (days_multiplier - days_tweak_multiplier) * tweak_multiplier + days_tweak_multiplier
        end

        level_limit_dissect = math.round(base_xp * days_multiplier - base_xp)
        level_limit_dissect = math.round(level_limit_dissect - days_dissect)
        base_xp = base_xp + days_dissect + level_limit_dissect
        risk_dissect = math.round(base_xp * self._ehi_xp.xp_multiplier)
        contract_xp = base_xp + risk_dissect
        if self._ehi_xp.in_custody then
            local multiplier = tweak_data:get_value("experience_manager", "in_custody_multiplier") or 1
            personal_win_dissect = math.round(contract_xp * multiplier - contract_xp)
            contract_xp = contract_xp + personal_win_dissect
        end

        total_xp = contract_xp
        local total_contract_xp = total_xp
        local multiplier = self._ehi_xp.skill_xp_multiplier or 1
        skill_dissect = math.round(total_contract_xp * multiplier - total_contract_xp)
        total_xp = total_xp + skill_dissect
        local bonus_xp = self._ehi_xp.infamy_bonus
        infamy_dissect = math.round(total_contract_xp * bonus_xp - total_contract_xp)
        total_xp = total_xp + infamy_dissect
        bonus_xp = tweak_data:get_value("experience_manager", "limited_bonus_multiplier") or 1
        extra_bonus_dissect = math.round(total_contract_xp * bonus_xp - total_contract_xp)
        total_xp = total_xp + extra_bonus_dissect
        local num_players_bonus = num_winners and tweak_data:get_value("experience_manager", "alive_humans_multiplier", num_winners) or 1
        alive_crew_dissect = math.round(total_contract_xp * num_players_bonus - total_contract_xp)
        total_xp = total_xp + alive_crew_dissect

        ghost_dissect = math.round(total_xp * ghost_multiplier - total_xp)
        total_xp = total_xp + ghost_dissect
        job_heat_dissect = math.round(total_xp * self._ehi_xp.heat - total_xp)
        total_xp = total_xp + job_heat_dissect

        return math.round(total_xp)
    end
else
    ---@param xp number?
    ---@param default_xp_if_zero number?
    function EHIExperienceManager:MultiplyXPWithAllBonuses(xp, default_xp_if_zero)
        if not xp or xp <= 0 then
            return default_xp_if_zero or 0
        end
        local job_stars = self._ehi_xp.job_stars
        local num_winners = self._ehi_xp.alive_players
        local player_stars = self._ehi_xp.level_to_stars
        local pro_job_multiplier = self._ehi_xp.projob_multiplier or 1
        local ghost_multiplier = 1 + (self._ehi_xp.stealth_bonus or 0)
        local xp_multiplier = self._ehi_xp.difficulty_multiplier or 1
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
        pro_job_xp_dissect = math.round(base_xp * pro_job_multiplier - base_xp)
        base_xp = base_xp + pro_job_xp_dissect

        if self._ehi_xp.is_level_limited then
            local diff_in_stars = job_stars - player_stars
            local tweak_multiplier = tweak_data:get_value("experience_manager", "level_limit", "pc_difference_multipliers", diff_in_stars) or 0
            base_xp = math.round(base_xp * tweak_multiplier)
        end

        contract_xp = base_xp
        risk_dissect = math.round(contract_xp * xp_multiplier)
        contract_xp = contract_xp + risk_dissect

        if self._ehi_xp.in_custody then
            local multiplier = tweak_data:get_value("experience_manager", "in_custody_multiplier") or 1
            personal_win_dissect = math.round(contract_xp * multiplier - contract_xp)
            contract_xp = contract_xp + personal_win_dissect
        end

        total_xp = contract_xp
        local total_contract_xp = total_xp
        bonus_xp = self._ehi_xp.skill_xp_multiplier or 1
        skill_dissect = math.round(total_contract_xp * bonus_xp - total_contract_xp)
        total_xp = total_xp + skill_dissect
        bonus_xp = self._ehi_xp.infamy_bonus
        infamy_dissect = math.round(total_contract_xp * bonus_xp - total_contract_xp)
        total_xp = total_xp + infamy_dissect

        local num_players_bonus = num_winners and tweak_data:get_value("experience_manager", "alive_humans_multiplier", num_winners) or 1
        alive_crew_dissect = math.round(total_contract_xp * num_players_bonus - total_contract_xp)
        total_xp = total_xp + alive_crew_dissect

        bonus_xp = self._ehi_xp.gage_bonus
        gage_assignment_dissect = math.round(total_contract_xp * bonus_xp - total_contract_xp)
        total_xp = total_xp + gage_assignment_dissect
        ghost_dissect = math.round(total_xp * ghost_multiplier - total_xp)
        total_xp = total_xp + ghost_dissect
        local heat_xp_mul = self._ehi_xp.heat
        job_heat_dissect = math.round(total_xp * heat_xp_mul - total_xp)
        total_xp = total_xp + job_heat_dissect
        bonus_xp = self._ehi_xp.limited_xp_bonus
        extra_bonus_dissect = math.round(total_xp * bonus_xp - total_xp)
        total_xp = total_xp + extra_bonus_dissect
        local bonus_mutators_dissect = total_xp * self._ehi_xp.mutator_xp_reduction
        total_xp = total_xp + bonus_mutators_dissect
        total_xp = total_xp + self._ehi_xp.bonus_xp
        return total_xp
    end
end

---@param id number
function EHIExperienceManager:RecalculateXP(id)
    if self._base_xp == 0 or self._xp_disabled then
        return
    elseif self._config.xp_format == 3 then
        if self._config.xp_panel == 2 then
            if self._xp_awarded then
                self._xp_awarded(id, 0)
            end
        else
            self:ShowGainedXP(id, 0)
        end
    end
end

---@param xp_total number
function EHIExperienceManager:GetRemainingXPToMaxLevel(xp_total)
    local totalXpTo100 = 0
    for _, level in ipairs(tweak_data.experience_manager.levels) do
        totalXpTo100 = totalXpTo100 + Application:digest_value(level.points, false)
    end
    return math.max(totalXpTo100 - xp_total, 0)
end

---@param return_number boolean?
function EHIExperienceManager:GetPlayerXPLimit(return_number)
    if self._xp.prestige_enabled then
        return self:IsInfamyPoolOverflowed() and (return_number and self._xp.prestige_xp or math.huge) or self._xp.prestige_xp_remaining
    end
    return self._xp.level_xp_to_100
end

function EHIExperienceManager:IsInfamyPoolEnabled()
    return self._xp.prestige_enabled
end

---Not possible in Vanilla, mod check
function EHIExperienceManager:IsInfamyPoolOverflowed()
    return self._xp.prestige_xp_remaining < 0 --- Not possible in Vanilla, mod check
end

function EHIExperienceManager:CurrentAlivePlayers()
    return self._ehi_xp and self._ehi_xp.alive_players or 0
end

function EHIExperienceManager:SetAIOnDeathListener()
    EHI:UpdateExistingHookIfExistsOrHook(TradeManager, "on_AI_criminal_death", "EHI_ExperienceManager_AICriminalDeath", function(...)
        self:DecreaseAlivePlayers()
        EHI:CallCallback("ExperienceManager_RefreshPlayerCount", self:CurrentAlivePlayers())
    end)
end

---@param ub boolean?
function EHIExperienceManager:SetCriminalsListener(ub)
    if ub then
        local function Query(...)
            if not self._xp_disabled then
                DelayedCalls:Add("EHIExperienceManager_SetCriminalsListener", 1, function()
                    self:QueryAmountOfAllPlayers()
                    EHI:CallCallback("ExperienceManager_RefreshPlayerCount", self:CurrentAlivePlayers())
                end)
            else
                DelayedCalls:Add("EHIExperienceManager_SetCriminalsListener", 1, function()
                    EHI:CallCallback("ExperienceManager_RefreshPlayerCount", self:CurrentAlivePlayers())
                end)
            end
        end
        if EHI:HookExists(CriminalsManager, "add_character", "EHI_CriminalsManager_add_character") then
            EHI:UpdateExistingHook(CriminalsManager, "add_character", "EHI_CriminalsManager_add_character", Query)
            EHI:UpdateExistingHook(CriminalsManager, "set_unit", "EHI_CriminalsManager_set_unit", Query)
            EHI:UpdateExistingHook(CriminalsManager, "on_peer_left", "EHI_CriminalsManager_on_peer_left", Query)
        else
            Hooks:PostHook(CriminalsManager, "add_character", "EHI_CriminalsManager_add_character", Query)
            Hooks:PostHook(CriminalsManager, "set_unit", "EHI_CriminalsManager_set_unit", Query)
            Hooks:PostHook(CriminalsManager, "on_peer_left", "EHI_CriminalsManager_on_peer_left", Query)
        end
        EHI:UpdateExistingHookIfExistsOrHook(CriminalsManager, "_remove", "EHI_CriminalsManager_remove", Query)
    else
        local function Query(...)
            if not self._xp_disabled then
                DelayedCalls:Add("EHIExperienceManager_SetCriminalsListener", 1, function()
                    self:QueryAmountOfAlivePlayers()
                    EHI:CallCallback("ExperienceManager_RefreshPlayerCount", self:CurrentAlivePlayers())
                end)
            else
                DelayedCalls:Add("EHIExperienceManager_SetCriminalsListener", 1, function()
                    EHI:CallCallback("ExperienceManager_RefreshPlayerCount", self:CurrentAlivePlayers())
                end)
            end
        end
        Hooks:PostHook(CriminalsManager, "add_character", "EHI_CriminalsManager_add_character", Query)
        Hooks:PostHook(CriminalsManager, "set_unit", "EHI_CriminalsManager_set_unit", Query)
        Hooks:PostHook(CriminalsManager, "on_peer_left", "EHI_CriminalsManager_on_peer_left", Query)
    end
end