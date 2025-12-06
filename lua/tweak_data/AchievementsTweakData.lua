if EHI:CheckMenuHook("AchievementsTweakData") then
    return
end

local achievements = {
    -- In individual mission files
    "halloween_1", "halloween_2",
    "live_2", "live_3", "live_4", "live_5",
    "armored_1", "armored_6",
    "bex_10", "bex_11",
    "bigbank_3", "bigbank_4", "cac_22",
    "born_3",
    "bph_10",
    "brb_8",
    "fort_4",
    "cane_2", "cane_3", "cane_5",
    "corp_9", "corp_10", "corp_11", "corp_12",
    "cow_10", "cow_11",
    "cow_3", "cow_4", "cow_5",
    "dah_8",
    "dark_2", "dark_3", "dark_5", "voff_3",
    "deep_9", "deep_11", "deep_12",
    "des_9", "des_11", "uno_5",
    "farm_1", "farm_2", "farm_3", "farm_4", "farm_6",
    "bob_8", "slakt_1",
    "bob_4",
    "frappucino_to_go_please",
    "bilbo_baggin",
    "you_shall_not_pass",
    "king_of_the_hill",
    "bullet_dodger",
    "uno_2",
    "fex_10",
    "lord_of_war", "ovk_10",
    "the_wire",
    "slakt_5", "voff_1", "uno_1",
    "fish_4", "fish_5", "fish_6",
    "flat_2", "flat_5", "cac_9",
    "pink_panther", "cac_19",
    "friend_5", "friend_6", "uno_7",
    "glace_9", "glace_10", "uno_4",
    "orange_4", "orange_5",
    "slakt_3", "cac_26",
    "cac_21",
    "chas_9", "chas_10", "chas_11",
    "chca_9", "chca_10", "chca_12",
    "born_5",
    "cac_30",
    "ameno_7",
    "kenaz_3", "kenaz_4", "kenaz_5",
    "kosugi_1", "kosugi_2", "kosugi_3", "kosugi_4", "kosugi_5",
    "mad_2", "cac_13",
    "window_cleaner", "ameno_3", "uno_3",
    "man_2", "man_3", "man_4", "man_5",
    "mex_9",
    "mex2_9",
    "pig_2", "pig_7",
    "moon_4",
    "bat_3", "bat_4",
    "nmh_11",
    "pal_2", "pal_3",
    "berry_3", "berry_4",
    "jerry_3", "jerry_4", "cac_33",
    "pent_10", "pent_12",
    "peta_2",
    "peta_3", "peta_5",
    "pex_10", "pex_11",
    "uno_9",
    "ranc_9", "ranc_10", "ranc_11",
    "voff_5",
    "green_3", "cac_10",
    "run_8", "run_9", "run_10",
    "rvd_8", "rvd_9", "rvd_10", "rvd_12",
    "rvd_11",
    "sah_9",
    "sand_9", "sand_10", "sand_11",
    "melt_3",
    "spa_4", "spa_5", "spa_6",
    "tag_9", "tag_10",
    "lets_do_this", "cac_12",
    "hot_wheels",
    "uno_8",
    "cac_24",
    "wwh_9", "wwh_10", "cac_27",

    -- In IngameWaitingForPlayers
    -- Weapons
    "halloween_6", "halloween_8",
    "armored_5", "armored_7", "armored_9",
    "gage_1", "gage_2", "gage_3", "gage_4", "gage_5", "gage_6", "gage_7",
    "gage2_5",
    "gage3_2", "gage3_3", "gage3_4", "gage3_5", "gage3_6", "gage3_7", "gage3_10", "gage3_11", "gage3_12", "gage3_13", "gage3_14", "gage3_15", "gage3_16", "gage3_17",
    "gage4_6", "gage4_8", "gage4_10",
    "gage5_1", "gage5_5", "gage5_9", "gage5_10",
    "eagle_1",
    "ameno_8",
    "turtles_1", "turtles_2",
    "tango_achieve_2", "tango_achieve_3",
    "grv_2", "grv_3",
    "cac_2",
    "pxp2_1", "pxp2_2",
    "pim_1", "pim_3",
    -- Melee
    "halloween_7",
    "gage5_8",
    "eagle_2",
    "steel_2",
    "gsu_01",
    "gage2_3", "gage2_9",
    "gage4_7",
    "pig_3",
    "sawp_1",
    "bph_9",
    -- Grenades
    "gage_9",
    "dec21_02",
    "pim_2",
    "pxp2_3",
    -- Other
    "halloween_4", "halloween_5", "halloween_10",
    "armored_4", "armored_8", "armored_10",
    "gmod_1", "gmod_2", "gmod_3", "gmod_4", "gmod_5", "gmod_6",
    "ovk_3",
    "cac_3",
    "cac_34",
    "eng_1", "eng_2", "eng_3", "eng_4",
    "xm20_1",
    "pent_11",
    "tawp_1",
    -- Shared
    "pxp1_1"
}

---@class AchievementsTweakData
---@field tags { progress: string[] }
---@field persistent_stat_unlocks table<string, { [1]: { award: string, at: number } }>
---@field visual table<string, { icon_id: string, tags: string[], unlock_icons: { texture: string }[] }>

local original = AchievementsTweakData._init_visual
function AchievementsTweakData:_init_visual(...)
    original(self, ...)
    table.insert(self.tags.progress, "progress_ehi_tracked")
    table.insert(self.tags.progress, "progress_ehi_secret")
    for _, id in ipairs(achievements) do
        local achievement_data = self.visual[id]
        if achievement_data and achievement_data.tags then
            table.insert(achievement_data.tags, "progress_ehi_tracked")
        end
    end
end

function AchievementsTweakData:_check_uno()
    if self.__uno_checked then
        return
    end
    local uno_challenge = managers.custom_safehouse:uno_achievement_challenge():challenge()
    for _, achievement_id in ipairs(uno_challenge or {}) do
        local achievement_data = self.visual[achievement_id]
        if achievement_data and achievement_data.tags then
            table.insert(achievement_data.tags, "progress_ehi_secret")
        end
    end
    self.__uno_checked = true
end