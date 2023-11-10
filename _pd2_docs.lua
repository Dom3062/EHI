---@meta
--[[
    This file is not loaded, it is here to provide code completion in VSCode
]]

_G.Global = {}
---@class World
---@field find_units fun(self: self, ...): Unit[]
---@field find_units_quick fun(self: self, ...): Unit[]
_G.World = {}
---@class tweak_data
---@field chat_colors Color[]
---@field get_value fun(self: self, ...): any
_G.tweak_data = {}
_G.tweak_data.hud = {}
_G.tweak_data.screen_colors = {}
---@class CarryTweakData
---@field small_loot table<string, number>
---@field [string] { name_id: string, is_unique_loot: boolean, skip_exit_secure: boolean }
_G.tweak_data.carry = {}
---@class EHITweakData
_G.tweak_data.ehi = {}
---@class GageAssignmentTweakData
---@field get_num_assignment_units fun(self: self): number
_G.tweak_data.gage_assignment = {}
---@class GuiTweakData
---@field stats_present_multiplier number
_G.tweak_data.gui = {}
---@class GroupAITweakData
---@field difficulty_curve_points number[]
_G.tweak_data.group_ai = {}
---@class HudIconsTweakData
---@field [string] { texture: string, texture_rect: { number: x, number: y, number: w, number: h } }
---@field get_icon_or fun(self: self, icon_id: string, ...): string, { number: x, number: y, number: w, number: h } If the provided icon is not found, `...` is returned
_G.tweak_data.hud_icons = {}
---@class MenuTweakData
---@field medium_font string
---@field pd2_small_font string
---@field pd2_small_font_size number
---@field pd2_medium_font string
---@field pd2_large_font string
---@field pd2_large_font_id userdata
---@field pd2_large_font_size number
_G.tweak_data.menu = {}
---@class PlayerTweakData
---@field SUSPICION_OFFSET_LERP number
---@field alarm_pager PlayerTweakData.alarm_pager
---@field damage PlayerTweakData.damage
---@field omniscience PlayerTweakData.omniscience
_G.tweak_data.player = {}
---@class PlayerTweakData.alarm_pager
---@field bluff_success_chance_w_skill number[]
_G.tweak_data.alarm_pager = {}
---@class PlayerTweakData.damage
---@field automatic_respawn_time number?
_G.tweak_data.player.damage = {
    base_respawn_time_penalty = 5,
    DODGE_INIT = 0,
    respawn_time_penalty = 30
}
---@class PlayerTweakData.omniscience
---@field start_t number
---@field target_resense_t number
_G.tweak_data.player.damage.omniscience = {}
---@class PrePlanningTweakData
---@field get_type_texture_rect fun(self: self, num: number): { number: x, number: y, number: w, number: h }
---@field types table
_G.tweak_data.preplanning = {
    gui = {
        type_icons_path = "guis/dlcs/deep/textures/pd2/pre_planning/preplan_icon_types"
    }
}
---@class UpgradesTweakData
---@field values UpgradesTweakData.values
_G.tweak_data.upgrades = {
    player_damage_health_ratio_threshold = 0.5,
    max_cocaine_stacks_per_tick = 240,
    wild_max_triggers_per_time = 4
}
---@class UpgradesTweakData.values
---@field player UpgradesTweakData.values.player
---@field team UpgradesTweakData.values.team
_G.tweak_data.upgrades.values = {}
---@class UpgradesTweakData.values.player
---@field dodge_shot_gain table
---@field melee_damage_stacking table
_G.tweak_data.upgrades.values.player = {}
---@class UpgradesTweakData.values.team
---@field crew_throwable_regen table
---@field damage UpgradesTweakData.values.team.damage
_G.tweak_data.upgrades.values.team = {}
---@class UpgradesTweakData.values.team.damage
---@field hostage_absorption table
---@field hostage_absorption_limit number
_G.tweak_data.upgrades.values.team.damage = {}
---@class managers
_G.managers = {}
---@type boolean
_G.IS_VR = ...
---@class CoreWorldInstanceManager
_G.CoreWorldInstanceManager = {}
---@class CivilianDamage
_G.CivilianDamage = {}
---@class CopDamage
_G.CopDamage = {}
---@class TimerGui
_G.TimerGui = {}
---@class DigitalGui
_G.DigitalGui = {}
---@class ExperienceManager
_G.ExperienceManager = {}
---@class GamePlayCentralManager
_G.GamePlayCentralManager = {}
---@class LevelsTweakData
---@field get_default_team_ID fun(self: self, type: string): string
_G.LevelsTweakData = {}
---@class LootManager
_G.LootManager = {}
---@class CriminalsManager
_G.CriminalsManager = {}
---@class EnemyManager
_G.EnemyManager = {}
---@class PlayerManager
_G.PlayerManager = {}
---@class PrePlanningManager
_G.PrePlanningManager = {}
---@class HUDManager
_G.HUDManager = {}
---@class HUDMissionBriefing
_G.HUDMissionBriefing = {}
---@class ObjectInteractionManager
---@field _interactive_units Unit[]
_G.ObjectInteractionManager = {}
---@class MissionAssetsManager
_G.MissionAssetsManager = {}
---@class MissionBriefingGui
_G.MissionBriefingGui = {}
---@class MoneyManager
_G.MoneyManager = {}
---@class TradeManager
_G.TradeManager = {}
---@class VehicleDrivingExt
_G.VehicleDrivingExt = {}
---@class ZipLine
_G.ZipLine = {}
---@param o table? Can be used to provide `self` to the callback function
---@param base_callback_class table
---@param base_callback_func_name string
---@param base_callback_param any?
---@return function
_G.callback = function(o, base_callback_class, base_callback_func_name, base_callback_param)
end
---@return Vector3
---@overload fun(x: number, y: number, z: number): Vector3
_G.Vector3 = function()
end
---@return Rotation
---@overload fun(x: number, y: number): Rotation
---@overload fun(x: number, y: number, z: number): Rotation
---@overload fun(x: number, y: number, z: number, w: number): Rotation
_G.Rotation = function()
end
---@class _G.Color
---@field black Color
---@field red Color
---@field white Color
---@field green Color
---@field yellow Color

---@class _G.Color
_G.Color = {}
---@return Color
---@overload fun(r: number, g: number, b: number): Color
---@overload fun(a: number, r: number, g: number, b: number): Color
---@overload fun(hex: string): Color
_G.Color = function()
end
---@generic T
---@param TC T
---@return T
_G.deep_clone = function(TC)
end
CoreTable.deep_clone = _G.deep_clone

---@generic T: table
---@param super T? A base class which `class` will derive from
---@return T
function class(super) end

---@generic T
---@param category string
---@param upgrade string
---@return table|number
---@overload fun(self: self, category: string, upgrade: string, default: `T`): T|table|number
function PlayerManager:upgrade_value(category, upgrade)
end

---@param category string
---@param upgrade string
---@return number
---@overload fun(self: self, category: string, upgrade: string, default: number): number
function PlayerManager:upgrade_level(category, upgrade)
end

---@class TextureRect
---@field [1] number X
---@field [2] number Y
---@field [3] number W
---@field [4] number H

---@class Vector3
---@field x number
---@field y number
---@field z number

---@class Color
---@field r number
---@field red number
---@field g number
---@field green number
---@field b number
---@field blue number
---@field unpack fun(self: self): r: number, g: number, b: number
---@field with_alpha fun(self: self, alpha: number): self

---@class MissionScriptElementValues
---@field amount number `ElementCounter` | `ElementCounterOperator`
---@field chance number `ElementLogicChance` | `ElementLogicChanceOperator`
---@field value number `ElementJobValue`
---@field position Vector3
---@field rotation Rotation

---@class MissionScriptElement
---@field _id number
---@field counter_value fun(self: self): number `ElementCounter`
---@field enabled fun(self: self): boolean
---@field value fun(self: self, value: string): any
---@field id fun(self: self): number
---@field editor_name fun(self: self): string
---@field on_executed function
---@field _is_inside fun(self: self, position: Vector3): boolean `ElementAreaReportTrigger `
---@field _values_ok fun(self: self): boolean `ElementCounterFilter` | `ElementStopwatchFilter`
---@field _values MissionScriptElementValues
---@field _calc_base_delay fun(self: self): number
---@field _calc_element_delay fun(self: self, params: table): number
---@field _timer number `ElementTimer` | `ElementTimerOperator`
---@field _check_difficulty fun(self: self): boolean `ElementDifficulty`
---@field _check_mode fun(self: self): boolean `ElementFilter`

---@class MissionScript
---@field element fun(self: self, id: number): MissionScriptElement?

---@class BlackMarketManager
---@field equipped_grenade fun(self: self): string
---@field equipped_mask fun(self: self): table
---@field equipped_melee_weapon fun(self: self): string
---@field equipped_primary fun(self: self): table
---@field equipped_player_style fun(self: self): string
---@field equipped_secondary fun(self: self): table
---@field equipped_suit_variation fun(self: self): string
---@field get_suspicion_offset_of_local fun(self: self, lerp: number, ignore_armor_kit: boolean?): number
---@field outfit_string fun(self: self): table

---@class ControllerWrapper
---@field add_trigger fun(self: self, connection_name: string, func: function)
---@field enable fun(self: self)
---@field destroy fun(self: self)
---@field get_input_axis fun(self: self, connection_name: string): Vector3
---@field get_input_bool fun(self: self, connection_name: string): boolean
---@field get_input_pressed fun(self: self, connection_name: string): boolean

---@class ControllerManager
---@field create_controller fun(self: self, name: string, index: number?, debug: boolean?, prio: number?): ControllerWrapper
---@field get_settings fun(self: self, wrapper_type: string): unknown

---@class CoroutineManager
---@field _buffer table

---@class GuiDataManager
---@field create_fullscreen_workspace fun(self: self): Workspace
---@field create_fullscreen_16_9_workspace fun(self: self): Workspace 16:9
---@field destroy_workspace fun(self: self, ws: Workspace)
---@field safe_to_full fun(self: self, in_x: number, in_y: number): number, number
---@field safe_to_full_16_9 fun(self: self, in_x: number, in_y: number): number, number
---@field full_to_safe fun(self: self, in_x: number, in_y: number): number, number
---@field full_scaled_size fun(self: self): { x: number, y: number, w: number, h: number }

---@class GroupAIStateBase
---@field _hostage_headcount number
---@field amount_of_winning_ai_criminals fun(self: self): number
---@field get_amount_enemies_converted_to_criminals fun(self: self): number
---@field _get_balancing_multiplier fun(self: self, balance_multipliers: number[]): number
---@field hostage_count fun(self: self): number
---@field whisper_mode fun(self: self): boolean

---@class GroupAIManager
---@field state fun(self: self): GroupAIStateBase

---@class ChatManager
---@field _receive_message fun(self: self, channel_id: number, name: string, message: string, color: Color, icon: string?)

---@class JobManager
---@field current_contact_id fun(self: self): string
---@field current_job_id fun(self: self): string
---@field is_level_christmas fun(self: self, level_id: string): boolean
---@field on_last_stage fun(self: self): boolean

---@class MissionManager
---@field _scripts table<string, MissionScript> All running scripts in a mission
---@field add_global_event_listener fun(self: self, key: string, event_types: string[], clbk: function)
---@field add_runned_unit_sequence_trigger fun(self: self, unit_id: number, sequence: string, callback: function)
---@field check_mission_filter fun(self: self, value: number): boolean
---@field get_element_by_id fun(self: self, id: number): MissionScriptElement?
---@field remove_global_event_listener fun(self: self, key: string)

---@class MenuManager
---@field _input_enabled boolean
---@field _open_menus table
---@field is_pc_controller fun(self: self): boolean Returns `true` if the game was started by mouse or keyboard

---@class MenuComponentManager
---@field _mission_briefing_gui MissionBriefingGui
---@field post_event fun(self: self, event: string, unique: boolean?)

---@class MoneyManager
---@field get_secured_bonus_bag_value fun(self: self, carry_id: string, multiplier: number): number

---@class MousePointerManager
---@field convert_fullscreen_16_9_mouse_pos fun(self: self, in_x: number, in_y: number): number, number
---@field get_id fun(self: self): number Creates and returns a new mouse pointer id to use
---@field modified_fullscreen_16_9_mouse_pos fun(self: self): x: number, y: number
---@field set_pointer_image fun(self: self, type: "arrow"|"link"|"hand"|"grab")
---@field use_mouse fun(self: self, params: table, position: number?)
---@field remove_mouse fun(self: self, id: number)

---@class NetworkAccountBase
---@field get_stat fun(self: self, key: string): number

---@class NetworkPeer
---@field _unit UnitPlayer
---@field id fun(self: self): number
---@field character fun(self: self): string
---@field set_outfit_string fun(self: self, outfit_string: table)

---@class NetworkBaseSession
---@field amount_of_alive_players fun(self: self): number
---@field amount_of_players fun(self: self): number
---@field local_peer fun(self: self): NetworkPeer
---@field peer fun(self: self, peer_id: number): NetworkPeer
---@field peer_by_unit fun(self: self, Unit: UnitPlayer): NetworkPeer
---@field peers fun(self: self): table<number, NetworkPeer>
---@field send_to_peers_synched fun(self: self, ...: any)

---@class NetworkManager
---@field account NetworkAccountBase
---@field add_event_listener fun(self: self, key: string, event_types: string, clbk: function)
---@field session fun(self: self): NetworkBaseSession

---@class PerpetualEventManager
---@field get_holiday_tactics fun(self: self): string

---@class SlotManager
---@field get_mask fun(self: self, ...: string): number

---@class StatisticsManager
---@field is_dropin fun(self: self): boolean
---@field started_session_from_beginning fun(self: self): boolean

---@class WeaponFactoryManager
---@field get_ammo_data_from_weapon fun(self: self, factory_id: string, blueprint: table): table?

---@class managers Global table of all managers in the game
---@field assets MissionAssetsManager
---@field blackmarket BlackMarketManager
---@field controller ControllerManager
---@field criminals CriminalsManager
---@field ehi_manager EHIManager
---@field ehi_tracker EHITrackerManager
---@field ehi_waypoint EHIWaypointManager
---@field ehi_buff EHIBuffManager
---@field ehi_trade EHITradeManager
---@field ehi_escape EHIEscapeChanceManager
---@field ehi_deployable EHIDeployableManager
---@field enemy EnemyManager
---@field experience ExperienceManager
---@field game_play_central GamePlayCentralManager
---@field groupai GroupAIManager
---@field gui_data GuiDataManager
---@field hud HUDManager
---@field chat ChatManager
---@field interaction ObjectInteractionManager
---@field job JobManager
---@field menu MenuManager
---@field menu_component MenuComponentManager
---@field mission MissionManager
---@field money MoneyManager
---@field mouse_pointer MousePointerManager
---@field network NetworkManager
---@field localization LocalizationManager
---@field loot LootManager
---@field perpetual_event PerpetualEventManager
---@field player PlayerManager
---@field preplanning PrePlanningManager
---@field slot SlotManager
---@field statistics StatisticsManager
---@field trade TradeManager
---@field weapon_factory WeaponFactoryManager
---@field worlddefinition WorldDefinition
---@field world_instance CoreWorldInstanceManager

---@class AchievementsTweakData
---@field complete_heist_achievements table
---@field persistent_stat_unlocks table<string, { [1]: { award: string, at: number } }>
---@field visual table<string, { icon_id: string }>

---@class BlackMarketTweakData
---@field melee_weapons { [string]: { type: string } }

---@class tweak_data.projectiles
---@field [string] table?

---@class tweak_data Global table of all configuration data
---@field achievement AchievementsTweakData
---@field blackmarket BlackMarketTweakData
---@field carry CarryTweakData
---@field ehi EHITweakData
---@field experience_manager table
---@field gage_assignment GageAssignmentTweakData
---@field gui GuiTweakData
---@field group_ai GroupAITweakData
---@field hud_icons HudIconsTweakData
---@field levels LevelsTweakData
---@field menu MenuTweakData
---@field mutators table
---@field player PlayerTweakData
---@field preplanning PrePlanningTweakData
---@field projectiles tweak_data.projectiles
---@field upgrades UpgradesTweakData

---@class TimerManager
---@field time fun(self: self): number

---@class Global_game_settings
---@field difficulty string
---@field gamemode string
---@field level_id string
---@field single_player boolean
---@field team_ai boolean

---@class Global
---@field achievment_manager table
---@field block_update_outfit_information boolean
---@field editor_mode boolean Only in `Beardlib Editor`
---@field load_level boolean
---@field hud_disabled boolean
---@field game_settings Global_game_settings
---@field mission_manager table
---@field statistics_manager table
---@field wallet_panel Panel?

---@class Gui
---@field create_world_workspace fun(self: self, w: number, h: number, x: Vector3, y: Vector3, z: Vector3): Workspace
---@field destroy_workspace fun(self: self, ws: Workspace)

---@class World
---@field newgui fun(self: self): Gui

---@class _G Global
---@field Global Global
---@field World World
---@field managers managers Global table of all managers in the game
---@field tweak_data tweak_data Global table of all configuration data
---@field PrintTableDeep fun(tbl: table, maxDepth: integer?, allowLogHeavyTables: boolean?, customNameForInitialLog: string?, tablesToIgnore: table|string?, skipFunctions: boolean?) Recursively prints tables; depends on mod: https://modworkshop.net/mod/34161
---@field PrintTable fun(tbl: table) Prints tables, provided by SuperBLT

---@class mathlib
---@field lerp fun(a: number, b: number, lerp: number): number Linearly interpolates between `a` and `b` by `lerp`
---@field round fun(n: number, precision: number?): number Rounds number with precision
---@field clamp fun(number: number, min: number, max: number): number Returns `number` clamped to the inclusive range of `min` and `max`
---@field rand fun(a: number, b: number?): number If `b` is provided, returns random number between `a` and `b`. Otherwise returns number between `0` and `a`
---@field mod fun(n: number, div: number): number Returns remainder of a division

---@class tablelib
---@field size fun(tbl: table): number Returns size of the table
---@field count fun(v: table, func: fun(item: any, key: any): boolean): number
---@field contains fun(v: table, e: string): boolean Returns `true` or `false` if `e` exists in the table
---@field index_of fun(v: table, e: string): integer Returns `index` of the element when found, otherwise `-1` is returned
---@field get_key fun(map: table, wanted_key_value: any): any? Returns `key name` if value exists
---@field list_to_set fun(list: table): table Maps values as keys

---@class InteractionExt
---@field tweak_data string
---@field interact_position fun(self: self): Vector3

---@class PlayerBase
---@field is_local_player boolean
---@field upgrade_value fun(self: self, category: string, upgrade: string): any|table|number|boolean

---@class HuskPlayerBase : PlayerBase

---@class PlayerInventory
---@field equipped_unit fun(self: self): UnitWeapon

---@class HuskPlayerInventory : PlayerInventory

---@class PlayerMovement
---@field crouching fun(self: self): boolean
---@field running fun(self: self): boolean
---@field zipline_unit fun(self: self): UnitZipline

---@class HuskPlayerMovement

---@class CopBase : UnitBase
---@field _unit UnitEnemy
---@field _tweak_table string
---@field has_tag fun(self: self, tag: string): boolean
---@class HuskCopBase : CopBase

---@class CopDamage
---@field is_civilian fun(type: string): boolean
---@field _ON_STUN_ACCURACY_DECREASE number
---@field _ON_STUN_ACCURACY_DECREASE_TIME number
---@field _unit UnitEnemy
---@field add_listener fun(self: self, key: string, events: string[]?, clbk: function)
---@field dead fun(self: self): boolean
---@field register_listener fun(key: string, event_types: string[], clbk: function)
---@field remove_listener fun(self: self, key: string)
---@field unregister_listener fun(key: string)

---@class HuskCopDamage : CopDamage

---@class CivilianBase : CopBase
---@field _unit UnitCivilian

---@class HuskCivilianBase : HuskCopBase
---@field _unit UnitCivilian

---@class CivilianDamage : CopDamage
---@field _unit UnitCivilian

---@class HuskCivilianDamage : HuskCopDamage
---@field _unit UnitCivilian

---@class C_VehicleVelocity
---@field length fun(self: self): number

---@class C_Vehicle
---@field velocity fun(self: self): C_VehicleVelocity

---@class RaycastWeaponBase
---@field selection_index fun(self: self): number

---@class UnitOOBB
---@field center fun(self: self): number
---@field x fun(self: self): number
---@field y fun(self: self): number
---@field z fun(self: self): number

---@class UnitBase
---@field add_destroy_listener fun(self: self, key: string, clbk: function)
---@field key fun(): string
---@field editor_id fun(): number
---@field position fun(): Vector3
---@field damage fun(): UnitDamage
---@field in_slot fun(self: self, slotmask: number): boolean
---@field oobb fun(self: self): UnitOOBB Object Oriented Bounding Box
---@field remove_destroy_listener fun(self: self, key: string)

---@class UnitTimer : UnitBase
---@field base Drill
---@field timer_gui fun(): TimerGui
---@field interaction fun(): InteractionExt
---@field mission_door_device fun(): MissionDoorDevice?

---@class UnitDigitalTimer : UnitBase
---@field digital_gui fun(): DigitalGui

---@class UnitPlayer : UnitBase
---@field base fun(): PlayerBase|HuskPlayerBase
---@field character_damage fun(): PlayerDamage|HuskPlayerDamage
---@field inventory fun(): PlayerInventory|HuskPlayerInventory
---@field movement fun(): PlayerMovement|HuskPlayerMovement

---@class UnitTeamAI : UnitBase

---@class UnitEnemy : UnitBase
---@field base fun(): CopBase|HuskCopBase
---@field character_damage fun(): CopDamage|HuskCopDamage

---@class UnitCivilian : UnitEnemy
---@field base fun(): CivilianBase|HuskCivilianBase
---@field character_damage fun(): CivilianDamage|HuskCivilianDamage

---@class UnitVehicle : UnitBase
---@field vehicle fun(): C_Vehicle C++ method

---@class UnitWeapon : UnitBase
---@field base fun(): RaycastWeaponBase

---@class UnitZipline : UnitBase
---@field zipline fun(): ZipLine

--- Unit Template; use this if your function expects each time a different unit
---@class Unit
---@field base unknown
---@field timer_gui fun(): TimerGui
---@field digital_gui fun(): DigitalGui
---@field interaction fun(): InteractionExt
---@field in_slot fun(self: self, slotmask: number): boolean
---@field position fun(self: self): Vector3
---@field [unknown] unknown

---@class LocalizationManager
---@field btn_macro fun(self: self, button: string, to_upper: boolean?, nil_if_empty: boolean?): string
---@field get_default_macro fun(self: self, macro: string): string
---@field exists fun(self: self, string_id: string): boolean SuperBLT only
---@field text fun(self: self, string_id: string, macros: table?): string
---@field to_upper_text fun(self: self, string_id: string, macros: table?): string

---@class Workspace
---@field show fun(self: self)
---@field hide fun(self: self)
---@field panel fun(self: self): Panel
---@field connect_keyboard fun(self: self, keyboard: userdata)

---@class PanelBaseObject
---@field x fun(self: self): number
---@field set_x fun(self: self, x: number)
---@field y fun(self: self): number
---@field set_y fun(self: self, y: number)
---@field w fun(self: self): number
---@field set_w fun(self: self, w: number)
---@field h fun(self: self): number
---@field set_h fun(self: self, h: number)
---@field top fun(self: self): number
---@field set_top fun(self: self, top: number)
---@field bottom fun(self: self): number
---@field set_bottom fun(self: self, bottom: number)
---@field left fun(self: self): number
---@field set_left fun(self: self, left: number)
---@field right fun(self: self): number
---@field set_right fun(self: self, right: number)
---@field center fun(self: self): x: number, y: number
---@field set_center fun(self: self, x: number, y: number)
---@field center_x fun(self: self): number
---@field set_center_x fun(self: self, center_x: number)
---@field center_y fun(self: self): number
---@field set_center_y fun(self: self, center_y: number)
---@field set_position fun(self: self, x: number, y: number)
---@field set_leftbottom fun(self: self, left: number, bottom: number)
---@field set_righttop fun(self: self, right: number, top: number)
---@field set_rightbottom fun(self: self, right: number, bottom: number)
---@field alpha fun(self: self) : number
---@field set_alpha fun(self: self, alpha: number)
---@field stop fun(self: self, anim_thread: thread?)
---@field animate fun(self: self, f: function, ...:any?): thread
---@field set_size fun(self: self, w: number, h: number)
---@field visible fun(self: self): boolean
---@field set_visible fun(self: self, visible: boolean)
---@field parent fun(self: self): Panel
---@field color fun(self: self): Color
---@field set_color fun(self: self, color: Color)
---@field inside fun(self: self, x: number, y: number): boolean Returns `true` or `false` if provided `x` and `y` are inside the object
---@field shape fun(self: self): x: number, y: number, w: number, h: number
---@field set_shape fun(self: self, x: number, y: number, w: number, h: number)
---@field set_blend_mode fun(self: self, mode: string)
---@field show fun(self: self)
---@field hide fun(self: self)

---@class Panel : PanelBaseObject
---@field color nil Does not exist in Panel
---@field set_color nil Does not exist in Panel
---@field child fun(self: self, child_name: string): (PanelBaseObject)?
---@field remove fun(self: self, child_name: PanelBaseObject)
---@field text fun(self: self, params: table): PanelText
---@field bitmap fun(self: self, params: table): PanelBitmap
---@field rect fun(self: self, params: table): PanelRectangle
---@field panel fun(self: self, params: table): self
---@field children fun(self: self): PanelBaseObject[] Returns an ipairs table of all items created on the panel
---@field clear fun(self: self) Removes all children in the panel

---@class PanelText : PanelBaseObject
---@field set_text fun(self: self, text: string)
---@field text_rect fun(self: self): x: number, y: number, w: number, h: number Returns rectangle of the text
---@field font_size fun(self: self): number
---@field set_font fun(self: self, font: userdata)
---@field set_font_size fun(self: self, font_size: number)
---@field text fun(self: self): string

---@class PanelBitmap : PanelBaseObject
---@field set_image fun(self: self, texture_path: string, texture_rect_x: number?, texture_rect_y: number?, texture_rect_w: number?, texture_rect_h: number?)
---@field set_texture_rect fun(self: self, x: number, y: number, w: number, h: number)

---@class PanelRectangle : PanelBaseObject