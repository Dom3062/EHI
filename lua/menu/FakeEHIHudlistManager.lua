if Global.editor_mode then -- Please, do not spam log in editor mode
    return
end

local EHI = EHI

---@class FakeEHIList
---@field SetItemsPos fun(self: self, x: number, y: number)
local FakeEHIList = class()
---@param x number
---@param y number
---@param aspect_ratio integer
function FakeEHIList:init(x, y, aspect_ratio)
    self._items = {} ---@type table<string, FakeEHILeftItemBase|FakeEHIRightItemBase>
    self._itemized_list = {} ---@type FakeEHILeftItemBase[]|FakeEHIRightItemBase[]
    self._x = x
    self._y = y
    self._aspect_ratio = aspect_ratio
end

---@param visibility boolean
function FakeEHIList:UpdateListEnabled(visibility)
    self:RunOnAllItems("SetListEnabled", visibility)
end

---@param visibility boolean
function FakeEHIList:UpdateVisibility(visibility)
    self:RunOnAllItems("SetVisibility", visibility)
end

---@param x number
function FakeEHIList:UpdateX(x)
    local x_full, _ = tweak_data.ehi.shared.ConvertSafeRectToFull(x, 0, self._aspect_ratio)
    if self._x == x_full then
        return
    end
    self._x = x_full
    self:SetItemsPos(x_full, self._y)
end

---@param y number
function FakeEHIList:UpdateY(y)
    local _, y_full = tweak_data.ehi.shared.ConvertSafeRectToFull(0, y, self._aspect_ratio)
    if self._y == y_full then
        return
    end
    self._y = y_full
    self:SetItemsPos(self._x, y_full)
end

---@param scale number
function FakeEHIList:UpdateScale(scale)
    if self._scale == scale then -- To stop flickering because menu is firing this up every frame even if the value match
        return
    end
    self._scale = scale
    self._y_offset = 2 * scale
    self:RunOnAllItems("Rescale", scale)
    self:SetItemsPos(self._x, self._y)
end

---@param enabled boolean
---@param id string
function FakeEHIList:UpdateItemEnabled(enabled, id)
    self:CallItemFunction(id, "SetEnabled", enabled)
    self:SetItemsPos(self._x, self._y)
end

---@param a number
function FakeEHIList:UpdateBGAlpha(a)
    if self._bg_alpha == a then
        return
    end
    self._bg_alpha = a
    self:RunOnAllItems("UpdateBGAlpha", a)
end

---@param color { r: number, g: number, b: number }
function FakeEHIList:UpdateBGColor(color)
    self:RunOnAllItems("UpdateBGColor", color)
end

---@param progress integer
function FakeEHIList:UpdateProgress(progress)
    if self._progress == progress then
        return
    end
    self._progress = progress
    self:RunOnAllItems("SetProgress", progress)
end

---@param a number
function FakeEHIList:UpdateProgressAlpha(a)
    if self._progress_alpha == a then
        return
    end
    self._progress_alpha = a
    self:RunOnAllItems("UpdateProgressAlpha", a)
end

---@param visibility boolean
function FakeEHIList:UpdateProgressVisibility(visibility)
    self:RunOnAllItems("SetProgressVisibility", visibility)
end

---@param color_index integer
function FakeEHIList:UpdateItemsColor(color_index)
    self:RunOnAllItems("UpdateItemsColor", color_index)
end

---@param f string
function FakeEHIList:RunOnAllItems(f, ...)
    for _, item in ipairs(self._itemized_list) do
        if item[f] then
            item[f](item, ...)
        end
    end
end

---@param id string
---@param f string
function FakeEHIList:CallItemFunction(id, f, ...)
    local item = self._items[id]
    if item and item[f] then
        item[f](item, ...)
    end
end

---@class FakeEHILeftList : FakeEHIList
---@field new fun(self: self, x: number, y: number, aspect_ratio: integer, color_index: integer, progress: integer): self
---@field super FakeEHIList
local FakeEHILeftList = class(FakeEHIList)
---@param x number
---@param y number
---@param aspect_ratio integer
---@param color_index integer
---@param progress integer
function FakeEHILeftList:init(x, y, aspect_ratio, color_index, progress)
    FakeEHILeftList.super.init(self, x, y, aspect_ratio)
    self._color_index = color_index
    self._progress = progress
    self._bg_alpha = EHI:GetHudlistOption("left_list_bg_alpha")
    self._bg_color = EHI:GetColor(EHI:GetHudlistOption("left_list_bg_color"))
    self._progress_alpha = EHI:GetHudlistOption("left_list_progress_alpha")
    self._progress_visibility = EHI:GetHudlistOption("left_list_progress_visibility")
    self._scale = EHI:GetHudlistOption("left_list_scale") --[[@as number]]
    self._preview_enabled = EHI:GetOption("show_preview_hudlist_left_list")
    self._list_enabled = EHI:GetHudlistOption("show_left_list")
    self._y_offset = 2 * self._scale
end

---@param class FakeEHILeftItemBase
---@param panel Panel
---@param params table
function FakeEHILeftList:AddItem(class, panel, params)
    local texture, texture_rect = tweak_data.ehi.default.hudlist.get_icon(params.icon)
    params.bg_alpha = self._bg_alpha
    params.bg_color = self._bg_color
    params.progress_alpha = self._progress_alpha
    params.progress_visibility = self._progress_visibility
    params.scale = self._scale
    params.visible = self._preview_enabled
    params.list_enabled = self._list_enabled
    params.color_index = self._color_index
    params.progress = self._progress
    local item = class:new(panel, params, texture, texture_rect)
    self._items[params.id] = item
    table.insert(self._itemized_list, item)
end

---@param x number
---@param y number
function FakeEHILeftList:SetItemsPos(x, y)
    local next_y = y
    for _, item in ipairs(self._itemized_list) do ---@cast item -FakeEHIRightItemBase
        if item:ItemIsVisible() then
            item:SetPosition(x, next_y)
            next_y = next_y + item:GetRealHeight() + self._y_offset
        end
    end
end

---@param static boolean
function FakeEHILeftList:UpdateProgressStatic(static)
    self:RunOnAllItems("SetProgressStatic", static)
end

---@param visible boolean
---@param id string
function FakeEHILeftList:UpdateItemTopText(visible, id)
    self:CallItemFunction(id, "UpdateTopText", visible)
    self:SetItemsPos(self._x, self._y)
end

---@class FakeEHIRightList : FakeEHIList
---@field new fun(self: self, x: number, y: number, aspect_ratio: integer, color_index: integer, progress: integer, panel_w: number): self
---@field super FakeEHIList
local FakeEHIRightList = class(FakeEHIList)
---@param x number
---@param y number
---@param aspect_ratio integer
---@param color_index integer
---@param progress integer
---@param panel_w number
function FakeEHIRightList:init(x, y, aspect_ratio, color_index, progress, panel_w)
    FakeEHIRightList.super.init(self, x, y, aspect_ratio)
    self._color, self._color_string = tweak_data.ehi:GetBuffColorFromIndex(color_index)
    self._progress = progress
    self._panel_w = panel_w
    self._bg_alpha = EHI:GetHudlistOption("right_list_bg_alpha")
    self._bg_color = EHI:GetColor(EHI:GetHudlistOption("right_list_bg_color"))
    self._progress_alpha = EHI:GetHudlistOption("right_list_progress_alpha")
    self._progress_visibility = EHI:GetHudlistOption("right_list_progress_visibility")
    self._scale = EHI:GetHudlistOption("right_list_scale") --[[@as number]]
    self._preview_enabled = EHI:GetOption("show_preview_hudlist_right_list")
    self._list_enabled = EHI:GetHudlistOption("show_right_list")
    self._y_offset = 2 * self._scale
end

---@param class FakeEHIRightItemBase
---@param panel Panel
---@param params table
function FakeEHIRightList:AddItem(class, panel, params)
    params.bg_alpha = self._bg_alpha
    params.bg_color = self._bg_color
    params.progress = self._progress
    params.progress_alpha = self._progress_alpha
    params.progress_visibility = self._progress_visibility
    params.scale = self._scale
    params.visible = self._preview_enabled
    params.list_enabled = self._list_enabled
    params.right_offset = self._panel_w - self._x
    params.color = self._color
    params.color_string = self._color_string
    local item = class:new(panel, params)
    self._items[params.id] = item
    table.insert(self._itemized_list, item)
end

---@param x number
---@param y number
function FakeEHIRightList:SetItemsPos(x, y)
    local right_offset = self._panel_w - x
    local next_y = y
    for _, item in ipairs(self._itemized_list) do ---@cast item -FakeEHILeftItemBase
        if item:ItemIsVisible() then
            item:SetRightOffset(right_offset, self._scale)
            item._panel:set_y(next_y)
            next_y = next_y + item._panel:h() + self._y_offset
        end
    end
end

---@class FakeEHIHudlistManager
FakeEHIHudlistManager = {}
FakeEHIHudlistManager.AspectRatio =
{
    _16_10 = 1,
    _4_3 = 2,
    Other = 3
}
FakeEHIHudlistManager._convert_safe_rect_to_full = tweak_data.ehi.shared.ConvertSafeRectToFull
FakeEHIHudlistManager._get_local_peer_color = tweak_data.ehi.functions.GetLocalPeerColor
FakeEHIHudlistManager._get_other_peer_color = tweak_data.ehi.functions.GetOtherPeerColor
---@param panel Panel
---@param aspect_ratio integer
function FakeEHIHudlistManager:new(panel, aspect_ratio)
    self._panel = panel:panel({
        visible = EHI:GetOption("show_hudlist")
    })
    self._format =
    {
        time = EHI:GetOption("time_format")
    }
    self._aspect_ratio = aspect_ratio
    local left_x_offset, left_y_offset = tweak_data.ehi.shared.ConvertSafeRectToFull(EHI:GetHudlistOption("left_list_x"), EHI:GetHudlistOption("left_list_y"), aspect_ratio)
    local right_x_offset, right_y_offset = tweak_data.ehi.shared.ConvertSafeRectToFull(EHI:GetHudlistOption("right_list_x"), EHI:GetHudlistOption("right_list_y"), aspect_ratio)
    dofile(EHI.LuaPath .. "menu/FakeEHIHudlistLeftItems.lua")
    FakeEHILeftItemBase._parent = self
    self._left_list = FakeEHILeftList:new(left_x_offset, left_y_offset, aspect_ratio, EHI:GetHudlistOption("left_list_item_color"), EHI:GetHudlistOption("left_list_progress"))
    self:_init_left_list_items()
    dofile(EHI.LuaPath .. "menu/FakeEHIHudlistRightItems.lua")
    self._right_list = FakeEHIRightList:new(right_x_offset, right_y_offset, aspect_ratio, EHI:GetHudlistOption("right_list_item_color"), EHI:GetHudlistOption("right_list_progress"), self._panel:w())
    self:_init_right_list_items()
    return self
end

function FakeEHIHudlistManager:_init_left_list_items()
    local options = EHI:GetHudlistOption("left_list")
    self._left_list:AddItem(FakeEHILeftItemBase, self._panel, {
        id = "Timer",
        icon = {
            skills = { 3, 6 }
        },
        items =
        {
            {
                icon = {
                    ehi = "wp_hack"
                },
                progress = 120,
                top_text =
                {
                    localize = true,
                    text = "ehi_hint_hack"
                },
                bottom_text = true
            },
            {
                icon = {
                    ehi = "tablet"
                },
                progress = 240,
                color = options.timer_jammed,
                top_text =
                {
                    localize = true,
                    text = "ehi_hint_hack"
                },
                bottom_text = true
            },
            {
                icon = {
                    ehi = "pd2_drill"
                },
                progress = 240,
                color = options.timer_not_powered,
                top_text =
                {
                    localize = true,
                    text = "ehi_hint_drill"
                },
                bottom_text = true
            },
            {
                icon = {
                    ehi = "pd2_generic_saw"
                },
                progress = 240,
                color = options.timer_autorepair,
                top_text =
                {
                    localize = true,
                    text = "ehi_hint_saw"
                },
                bottom_text = true
            }
        },
        enabled = options.show_timers,
        top_text = options.timer_top_text,
        bottom_text = true
    })
    do
        local icon = {
            skills = { 6, 8 }
        }
        local names = { "Security", "GenSec", "Cop", "FBI", "SWAT", "Heavy", "FBI Heavy", "ZEAL Sniper", "Heavy ZEAL", "ZEAL" }
        self._left_list:AddItem(FakeEHILeftMinionItem, self._panel, {
            id = "Minion",
            icon = icon,
            items =
            {
                {
                    icon = icon,
                    progress = 100,
                    icon_color = self._get_local_peer_color(),
                    top_text =
                    {
                        text = table.random(names)
                    }
                },
                {
                    icon = icon,
                    progress = 100,
                    icon_color = self._get_other_peer_color(),
                    top_text =
                    {
                        text = table.random(names)
                    }
                }
            },
            minion_option = options.minions_option,
            health_circle = options.minions_health_circle,
            enabled = options.show_minions,
            top_text = options.minions_top_text -- Bottom text is not used in real Minions
        })
    end
    self._left_list:AddItem(FakeEHILeftDeployableItem, self._panel, {
        id = "Deployable",
        icon = {
            ehi = "deployables"
        },
        items =
        {
            {
                icon = {
                    texture = "guis/textures/pd2/skilltree/icons_atlas",
                    texture_rect = { 128, 448, 64, 64 }
                },
                progress = 4,
                icon_color = self._get_local_peer_color(),
                top_text =
                {
                    text = "Doctor Bag"
                },
                bottom_text = true
            },
            {
                icon = {
                    texture = "guis/textures/pd2/skilltree/icons_atlas",
                    texture_rect = { 128, 448, 64, 64 }
                },
                progress_between = { 4, 16 },
                top_text =
                {
                    text = "Doctor Bag"
                },
                bottom_text = true,
                fake_pos = 1
            },
            {
                icon = {
                    texture = "guis/textures/pd2/skilltree/icons_atlas",
                    texture_rect = { 64, 0, 64, 64 }
                },
                progress = 4,
                icon_color = self._get_other_peer_color(),
                top_text =
                {
                    text = "Ammo Bag"
                },
                bottom_text = true,
                fake_pos = 2
            }
        },
        format = options.deployable_format,
        aggregate = options.deployable_aggregate,
        enabled = options.show_deployables,
        top_text = options.deployable_top_text,
        bottom_text = true
    })
    do
        local icon = {
            skills = { 6, 2 }
        }
        self._left_list:AddItem(FakeEHILeftItemBase, self._panel, {
            id = "JammerRetrigger",
            icon = icon,
            items =
            {
                {
                    icon = icon,
                    progress = 240,
                    icon_color = self._get_local_peer_color(),
                    bottom_text = true
                },
                {
                    icon = icon,
                    progress = 240,
                    icon_color = self._get_other_peer_color(),
                    bottom_text = true
                }
            },
            enabled = options.show_ecm_retrigger,
            bottom_text = true
        })
    end
    self._left_list:AddItem(FakeEHILeftItemBase, self._panel, {
        id = "Pager",
        icon = {
            ehi = "pager_icon"
        },
        items =
        {
            {
                icon = {
                    ehi = "pagers_used"
                },
                progress = 12,
                bottom_text = true
            }
        },
        enabled = options.show_enemy_pagers,
        bottom_text = true
    })
    do
        local icon = {
            skills = { 1, 4 }
        }
        self._left_list:AddItem(FakeEHILeftJammerItem, self._panel, {
            id = "Jammer",
            icon = icon,
            items =
            {
                {
                    icon = icon,
                    progress = math.rand(25, 30),
                    icon_color = self._get_local_peer_color(),
                    bottom_text = true
                },
                {
                    icon = icon,
                    progress = math.rand(25, 30),
                    icon_color = self._get_other_peer_color(),
                    bottom_text = true
                }
            },
            enabled = options.show_jammers,
            affects_pager_color_index = options.jammer_affects_pager,
            bottom_text = true
        })
    end
    if not _G.ch_settings then
        local icon = {
            ehi = "camera_loop"
        }
        self._left_list:AddItem(FakeEHILeftItemBase, self._panel, {
            id = "Camera",
            icon = icon,
            items =
            {
                {
                    icon = icon,
                    progress = 25,
                    bottom_text = true
                }
            },
            enabled = options.show_camera_loop,
            bottom_text = true
        })
    end
    self._left_list:SetItemsPos(self._left_list._x, self._left_list._y)
    if EHI:GetHudlistOption("left_list_progress_static") then
        self._left_list:UpdateProgressStatic(true)
    end
end

function FakeEHIHudlistManager:_init_right_list_items()
    local options = EHI:GetHudlistOption("right_list")
    local preplanning = tweak_data.preplanning
    do
        local u_options = options.unit_types
        local separate_enabled = u_options.dozer_count and u_options.dozer_count_separate
        self._right_list:AddItem(FakeEHIRightUnitItem, self._panel, {
            id = "Unit",
            items =
            {
                {
                    id = "regular",
                    icon = {
                        skills = { 6, 1 },
                        color = EHI:GetColor(u_options.regular_color)
                    },
                    value = 80
                },
                {
                    id = "converts",
                    icon = {
                        skills = { 6, 8 },
                        color = EHI:GetColor(u_options.converts_count_color)
                    },
                    value = 4
                },
                {
                    id = "enemy_tied",
                    icon = {
                        skills = { 2, 8 },
                        color = EHI:GetColor(u_options.enemy_tied_count_color)
                    },
                    value = 4
                },
                {
                    id = "dozer_hw",
                    icon = {
                        ehi = "heavy",
                        color = EHI:GetColor(u_options.dozer_count_hw_color)
                    },
                    enabled = separate_enabled and u_options.dozer_count_hw
                },
                {
                    id = "dozer_medic",
                    icon = {
                        ehi = "crime_spree_dozer_medic",
                        color = EHI:GetColor(u_options.dozer_count_medic_color)
                    },
                    enabled = separate_enabled and u_options.dozer_count_medic
                },
                {
                    id = "dozer_mini",
                    icon = {
                        ehi = "crime_spree_dozer_minigun",
                        color = EHI:GetColor(u_options.dozer_count_mini_color)
                    },
                    enabled = separate_enabled and u_options.dozer_count_mini
                },
                {
                    id = "dozer_skull",
                    icon = {
                        ehi = "crime_spree_dozer_lmg",
                        color = EHI:GetColor(u_options.dozer_count_skull_color)
                    },
                    enabled = separate_enabled and u_options.dozer_count_skull
                },
                {
                    id = "dozer_black",
                    icon = {
                        ehi = "heavy",
                        color = EHI:GetColor(u_options.dozer_count_black_color)
                    },
                    enabled = separate_enabled and u_options.dozer_count_black
                },
                {
                    id = "dozer_green",
                    icon = {
                        ehi = "heavy",
                        color = EHI:GetColor(u_options.dozer_count_green_color)
                    },
                    enabled = separate_enabled and u_options.dozer_count_green
                },
                {
                    id = "dozer",
                    icon = {
                        ehi = "heavy",
                        color = EHI:GetColor(u_options.dozer_count_color)
                    },
                    enabled = u_options.dozer_count and not u_options.dozer_count_separate,
                    value = 4
                },
                {
                    id = "sniper",
                    icon = {
                        ehi = "sniper",
                        color = EHI:GetColor(u_options.sniper_count_color)
                    },
                    value = 3,
                    enabled = u_options.sniper_count
                },
                {
                    id = "marshal_sniper",
                    icon = {
                        ehi = EHI:GetAchievementIconString("cac_4"),
                        color = EHI:GetColor(u_options.marshal_sniper_count_color)
                    },
                    value = 2,
                    enabled = u_options.marshal_sniper_count
                },
                {
                    id = "taser",
                    icon = {
                        ehi = EHI:GetAchievementIconString("halloween_5"),
                        color = EHI:GetColor(u_options.taser_count_color)
                    },
                    value = 2,
                    enabled = u_options.taser_count
                },
                {
                    id = "medic",
                    icon = {
                        texture = "guis/textures/pd2_mod_ehi/medic_icon",
                        color = EHI:GetColor(u_options.medic_count_color)
                    },
                    value = 2,
                    enabled = u_options.medic_count
                },
                {
                    id = "cloaker",
                    icon = {
                        ehi = EHI:GetAchievementIconString("gage2_8"),
                        scale = 0.9,
                        color = EHI:GetColor(u_options.cloaker_count_color)
                    },
                    value = 2,
                    enabled = u_options.cloaker_count
                },
                {
                    id = "shield",
                    icon = {
                        ehi = EHI:GetAchievementIconString("gage4_6"),
                        color = EHI:GetColor(u_options.shield_count_color)
                    },
                    value = 2,
                    enabled = u_options.shield_count
                },
                {
                    id = "marshal_shield",
                    icon = {
                        ehi = "equipment_sheriff_star",
                        color = EHI:GetColor(u_options.marshal_shield_count_color)
                    },
                    value = 2,
                    enabled = u_options.marshal_shield_count
                },
                {
                    id = "captain",
                    icon = {
                        ehi = EHI:GetAchievementIconString("farm_1"),
                        color = EHI:GetColor(u_options.captain_count_color)
                    },
                    enabled = u_options.captain_count
                },
                {
                    id = "phalanx",
                    icon = {
                        ehi = "crime_spree_shield_phalanx",
                        color = EHI:GetColor(u_options.phalanx_count_color)
                    },
                    value = 10,
                    enabled = u_options.phalanx_count
                },
                {
                    id = "turret",
                    icon = {
                        skills = { 7, 5 },
                        color = EHI:GetColor(u_options.turret_count_color)
                    },
                    value = 4,
                    enabled = u_options.turret_count
                },
                {
                    id = "civilians",
                    icon = {
                        skills = { 6, 7 },
                        color = EHI:GetColor(u_options.civilian_count_color)
                    },
                    value = 16,
                    enabled = u_options.civilian_count
                },
                {
                    id = "civilians_tied",
                    icon = {
                        skills = { 4, 7 },
                        color = EHI:GetColor(u_options.civilian_tied_count_color)
                    },
                    value = 10,
                    enabled = u_options.civilian_tied_count
                }
            },
            enabled = options.show_units,
            dozer_count_separate = u_options.dozer_count_separate
        })
    end
    self._right_list:AddItem(FakeEHIRightLootItem, self._panel, {
        id = "Loot",
        items =
        {
            {
                icon = {
                    ehi = "equipment_plates"
                },
                text = {
                    name = "Money",
                },
                value = 4
            },
            {
                icon = {
                    texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
                    texture_rect = { 348, 0, 85, 60 }
                },
                text = {
                    name = "Gold",
                },
                value = 8
            },
            {
                icon = {
                    texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
                    texture_rect = { 87, 0, 71, 61 }
                },
                text = {
                    name = "Diamonds",
                },
                value = 16
            },
            {
                icon = {
                    ehi = EHI:GetAchievementIconString("peta_3")
                },
                text = {
                    name = "Goat",
                },
                value = 15
            },
            {
                id = "crate",
                icon = {
                    texture = preplanning.gui.type_icons_path,
                    texture_rect = preplanning:get_type_texture_rect(preplanning.types.ranc_marked_crate.icon)
                },
                text = {
                    name = "Crate"
                },
                value = 10
            }
        },
        enabled = options.show_loot,
        potentional_loot = options.potentional_loot,
        top_type = options.loot_top_type
    })
    self._right_list:AddItem(FakeEHIRightItemBase, self._panel, {
        id = "Special",
        items =
        {
            {
                icon = {
                    ehi = "equipment_crowbar"
                },
                value = 4
            },
            {
                icon = {
                    ehi = "equipment_planks"
                },
                value = 4
            },
            {
                icon = {
                    ehi = "equipment_plates"
                },
                value = 20
            },
            {
                icon = {
                    ehi = EHI:GetAchievementIconString(string.format("eng_%d", math.random(1, 4)))
                },
                value = 1
            }
        },
        enabled = options.show_special_items
    })
    self._right_list:AddItem(FakeEHIRightStealthItem, self._panel, {
        id = "Stealth",
        items =
        {
            {
                icon = {
                    ehi = "pager_icon"
                },
                value = 20
            },
            {
                icon = {
                    ehi = "pagers_used",
                    scale = 0.9
                },
                value = 4
            },
            {
                icon = {
                    ehi = "camera_loop"
                },
                value = 20
            },
            {
                icon = {
                    texture = "guis/textures/pd2/skilltree/icons_atlas",
                    texture_rect = { 320, 704, 64, 64 }
                },
                value = 3
            }
        },
        enabled = options.show_stealth_info,
        bodybags_format = options.stealth_info_bodybags_format
    })
    self._right_list:SetItemsPos(self._right_list._x, self._right_list._y)
end

---@param enabled boolean
function FakeEHIHudlistManager:SetHudlistEnabled(enabled)
    self._panel:set_visible(enabled)
end

---@param value AnyExceptNil
---@param s_list string
---@param f string
function FakeEHIHudlistManager:CallListFunction(value, s_list, f, ...)
    local list = s_list == "left" and self._left_list or self._right_list
    if f and list[f] then
        list[f](list, value, ...)
    else
        EHI:Log(string.format("[FakeEHIHudlistManager] List '%s' is missing function or it is nil -> %s", s_list, tostring(f)))
    end
end

---@param option integer
function FakeEHIHudlistManager:UpdateTimeFormat(option)
    self._format.time = option
    self._left_list:RunOnAllItems("SetTimeFormat")
end

---@param color integer Gets converted to color and string
---@param id string
---@param pos integer
function FakeEHIHudlistManager:SetItemProgressColor(color, id, pos)
    self._left_list:CallItemFunction(id, "SetItemProgressColor", pos, color)
end

---@param progress integer
---@param id string
---@param s_list string
function FakeEHIHudlistManager:SetItemProgressBitmap(progress, id, s_list)
    local list = s_list == "left" and self._left_list or self._right_list
    list:CallItemFunction(id, "SetProgress", progress)
end