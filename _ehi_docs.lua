---@meta
--[[
    This file is not loaded, it is here to provide code completion in VSCode
]]

_G.EHI._cache.LocalPeerID = math.random()
_G.EHI._cache.Beardlib = {} ---@type table<string, { name: string, objective: string }>
_G.EHI.HeistTimerIsInverted = math.random() == math.random()
_G.EHI.GagePackagesSpawned = math.random() == math.random()
_G.EHI.Sync = managers.ehi_sync
_G.EHI.Trigger = EHIMissionElementTrigger
---@type EHIMissionElementOverride
_G.EHI.Element = EHIMissionElementOverride
---@type EHIMissionHolder
_G.EHI.Mission = EHIMissionHolder
---@type EHIMissionElementWaypoint
_G.EHI.Waypoint = EHIMissionElementWaypoint
---@type EHIMissionUnit
_G.EHI.Unit = EHIMissionUnit

---@alias AnyExceptNil table|string|boolean|number|userdata

---@class ElementWaypointTrigger : WaypointInitData
---@field waypointless boolean Creates Waypoint class without any waypoint in the game world
---@field id string? ID of the waypoint, if not provided, `id` is then copied from the trigger
---@field icon string? 
---@field time number? Time to run down. If not provided, `time` is then copied from the trigger
---@field class string? Class of the waypoint. If not provided, `class` is then copied from the trigger and converted to Waypoint class
---@field class_table EHIWaypoint?
---@field position Vector3
---@field position_from_element number?
---@field position_from_unit number?
---@field remove_vanilla_waypoint number? Removes waypoint in the game
---@field remove_vanilla_waypoint_overriden number? Removes already overriden waypoint in the game
---@field position_from_element_and_remove_vanilla_waypoint number?
---@field data_from_element number?
---@field data_from_element_and_remove_vanilla_waypoint number?
---@field restore_on_done boolean? Depends on `remove_vanilla_waypoint`
---@field present_timer number?
---@field remove_on_alarm boolean Removes the waypoint on alarm
---@field skip_if_not_found boolean Skips error message if the instance is not placed on the map
---@field unit Unit
---@field class_convert string?

---@class ElementClientTriggerData
---@field time number Maps to `additional_time`. If the field already exists, it is added to the field (+)
---@field random_time number,
---@field special_function number?

---@class ParseInstanceTable
---@field [string] table<number, ElementTrigger>

---@class EHIRandomTime
---@field [1] number Left time operand in BASE DELAY or delay (start time); mapped to ˙additional_time˙
---@field [2] number Right time operand in BASE DELAY or delay (end time); mapped to `random_time`

---@class ElementTrigger
---@field id string Tracker ID
---@field time number? Time to run down. Not required when tracker class is not using it. Defaults to `0` if not provided
---@field additional_time number? Time to add when the time is randomized. Used with conjuction with `random_time`
---@field random_time number? Auto converts tracker class to inaccurate tracker
---@field condition boolean?
---@field condition_function fun(): boolean
---@field icons table? Icons to show in the tracker
---@field class string? Class of tracker. If not provided it defaults to `EHITracker` in `EHITrackerManager`
---@field class_table EHITracker? Direct reference of tracker the class that should create and hold a tracker
---@field special_function number? Special function the trigger should do
---@field waypoint ElementWaypointTrigger? Waypoint definition
---@field waypoint_f fun(self: EHIMissionElementTrigger, trigger: self)? In case waypoint needs to be dynamic (different position each call or it depends on a trigger itself)
---@field trigger_once boolean? If the trigger should run once. After execution it is unhooked from the Element and removed from memory
---@field client ElementClientTriggerData? Table for clients only to prepopulate fields for tracker syncing. Only applicable to `SF.GetElementTimerAccurate` and `SF.UnpauseTrackerIfExistsAccurate`
---@field pos number? Tracker position
---@field f string|fun(arg: any?)|fun(self: EHIMissionElementTrigger, arg: any?)? Arguments are unsupported in `SF.CustomCodeDelayed`; `EHIMissionElementTrigger` is for `SF.CustomCode2`
---@field flash_times number?
---@field flash_bg boolean?
---@field hint string?
---@field tracker_merge boolean|{ id: string, start_timer: boolean }
---@field tracker_group boolean
---@field remove_on_alarm boolean? Removes the tracker on alarm; calls `EHITracker:ForceDelete()`
---@field update_on_alarm boolean? Updates the tracker on alarm; calls `EHITracker:OnAlarm()`
---@field first_icon_pos number? Forces specific icon from provided list of icons to be visible if `show_one_icon` option is enabled; Has no effect if all icons are visible
---@field load_sync fun(self: EHIMissionElementTrigger)|false|nil
---@field [any] any

---@class AssaultElementTrigger : ElementTrigger
---@field control_additional_time number? Time in the `Control` stage before the first assault, `30s` from the `Anticipation` stage is added too; used with conjuction with `random_time`
---@field control number? Time in the `Control` stage before the first assault, `30s` from the `Anticipation` stage is added too

---@class ParseTriggerTable
---@field [number] ElementTrigger

---@class ParseAchievementDefinitionTable
---@field beardlib boolean If the achievement is from Beardlib
---@field difficulty_pass boolean Difficulty check, setting this to `false` will disable the achievement to show on the screen
---@field elements table<number, ElementTrigger> Elements to hook
---@field failed_on_alarm boolean Fails the achievement on alarm
---@field load_sync fun(self: EHIMissionElementTrigger) Function to run if client drops-in to the game
---@field alarm_callback fun(dropin: boolean) Function to run after alarm has sounded
---@field parsed_callback fun() Function runs after the achievement is parsed
---@field preparse_callback fun(data: self) Function runs before the achievement is parsed and achievement is enabled
---@field cleanup_callback fun() Function runs during achievement traversal when difficulty check or unlock check is false; intended to delete remnants so they don't occupy memory
---@field cleanup_class string EHI class name to delete when difficulty check or unlock check is false; intended to delete remnants so they don't occupy memory
---@field mission_end_callback boolean Achieves or fails achievement on mission end
---@field data_sync table<string, any> Params to sync to other players

---@class ParseAchievementTable
---@field [string] ParseAchievementDefinitionTable Achievement Definition

---@class ParseTriggersTable
---@field mission { [number]: ElementTrigger } Triggers related to mission
---@field achievement { [string]: ParseAchievementDefinitionTable } Triggers related to achievements in the mission
---@field other table Triggers not related to mission or achievements
---@field trophy table Triggers related to Safehouse trophies
---@field sidejob table Triggers related to Safehouse Side Job missions
---@field preload table Trackers to preload during game load, achievements not recommended
---@field assault ParseTriggersTable.assault? Assault params to be loaded during game load
---@field pre_parse ParseTriggersTable.pre_parse?
---@field sync_triggers ParseTriggersTable.sync_triggers?
---@field tracker_merge table<string, { start_timer: boolean, elements: { [number]: ElementTrigger } }>?
---@field loot_removal_triggers number[] Loot removal triggers

---@class ParseTriggersTable.assault
---@field diff number?
---@field fake_assault_block boolean
---@field force_assault_start boolean
---@field wave_mode_elements_block number[]
---@field ignore_assault_start_count number?

---@class ParseTriggersTable.pre_parse
---@field filter_out_not_loaded_trackers "show_timers"|string[] Only in mission triggers

---@class ParseTriggersTable.sync_triggers
---@field base { [number]: ElementTrigger } Random delay is defined in the BASE DELAY
---@field element { [number]: ElementTrigger } Random delay is defined when calling the elements

---@class ParseTriggersTable.tracker_merge
---@field [string] { start_timer: boolean, elements: { [number]: ElementTrigger } }

---@class ParseUnitsTable
---@field [number] UnitUpdateDefinition

---@class LootCounterTable.SequenceTriggersTable
---@field loot string[] Sequences where loot spawns (ipairs); triggers `LootCounter:RandomLootSpawned()`
---@field no_loot string[] Sequences where no loot or garbage spawns (ipairs); triggers `LootCounter:RandomLootDeclined()`

---@class LootCounterTable.MaxBagsForMaxLevel
---@field mission_xp number Should include objectives that Host and Client will trigger all the time; e.g: `Escape XP`
---@field xp_per_loot { [string]: number }
---@field xp_per_bag_all number
---@field objective_triggers number[]
---@field custom_counter AchievementLootCounterTable|AchievementBagValueCounterTable

---@class LootCounterTable
---@field max integer Maximum number of loot
---@field max_random integer Defines a variable number of loot
---@field unknown_random boolean Defines if heist will spawn additional random loot during gameplay
---@field load_sync fun(self: EHIMissionElementTrigger)|nil|false Synchronizes secured bags in Loot Counter, automatically sets `no_sync_load` to true and you have to sync the progress manually via `self._loot:SyncSecuredLoot()`
---@field no_sync_load boolean Prevents Loot Counter from sync after joining
---@field skip_offset boolean Skip offset calculation if mission resets all secured bags
---@field client_from_start boolean If client is playing from mission briefing; does not do anything on host
---@field offset integer Used in multi-day heists if loot is brought to next days; Provided via `EHI:ShowLootCounterOffset()`; DO NOT PROVIDE IT
---@field triggers table If loot is manipulated via Mission Script, also see field `hook_triggers`
---@field hook_triggers boolean If Loot Counter is created during spawn or gameplay, triggers must be hooked in order to work
---@field sequence_triggers table<number, LootCounterTable.SequenceTriggersTable> Used for random loot spawning via sequences (forces syncing via BLT and GameSetup)
---@field is_synced boolean If the Loot Counter is synced from host (forces syncing via BLT and GameSetup)
---@field no_max boolean
---@field max_bags_for_level LootCounterTable.MaxBagsForMaxLevel
---@field max_xp_bags number Force maximum count if the heist limits maximum experience from loot bags
---@field no_triggers_if_max_xp_bags_gt_max boolean Disables triggers if provided `max_xp_bags` is greater than max
---@field carry_data { loot: boolean, no_loot: boolean, at_loot: boolean, no_at_loot: boolean } Enables tracking via `EHICarryData`, `EHINoCarryData`, `EHIATCarryData` and `EHIATNoCarryData` classes

---@class WaypointLootCounterTable
---@field element number|number[]
---@field present_timer number|table<number, number> If number is provided, the present timer is applied to elements, if table is provided in this format `{ [element_id]: time }`, then the present timer will get applied only to the element. Not provided elements will get assigned a default value in `EHIWaypointManager`
---@field check_function fun(progress: number, max: number): boolean
---@field remove_check fun(progress: number, max: number): boolean
---@field disable_waypoint_removal boolean Disables waypoint removal, useful if the mission script is killing the waypoint in the middle of securing loot. This will also remove vanilla waypoint from syncing (as per mission script design)
---@field class string

---@class AchievementCounterTable
---@field check_type integer See `EHI.Const.LootCounter.CheckType`, defaults to `EHI.Const.LootCounter.CheckType.BagsOnly` if not provided
---@field loot_type string|string[] What loot should be counted; Autosets `check_type` to `EHI.Const.LootCounter.CheckType.CheckTypeOfLoot`
---@field f fun(loot: LootManager) Function for custom calculation; Autosets `check_type` to `EHI.Const.LootCounter.CheckType.CustomCheck`

---@class AchievementLootCounterTable
---@field achievement string Achievement ID
---@field show_loot_counter boolean If achievement is already earned, show Loot Counter instead
---@field waypoint_loot_counter WaypointLootCounterTable
---@field max integer Maximum number of loot
---@field silent_max integer Maximum number of loot if the achievement counter start with lower max amount
---@field progress integer Start with progress if provided, otherwise 0
---@field show_finish_after_reaching_target boolean Setting this to `true` will show `FINISH` in the tracker
---@field class string Achievement tracker class
---@field load_sync fun(self: EHIMissionElementTrigger) Synchronizes secured bags in the achievement
---@field loot_counter_load_sync fun(self: EHIMissionElementTrigger) Synchronizes secured bags in the loot counter if achievement is not visible
---@field alarm_callback fun(dropin: boolean) Do some action when alarm is sounded
---@field failed_on_alarm boolean Fails achievement in tracker on alarm
---@field triggers table<number, ElementTrigger> Adds triggers when counter is manipulated via Mission Script, prevents counting
---@field loot_counter_triggers table<number, ElementTrigger> Adds triggers when counter is manipulated via Mission Script to the `Loot Counter` when achievement failed initial check
---@field hook_triggers boolean If tracker is created during spawn or gameplay, triggers must be hooked in order to work
---@field add_to_counter boolean Adds achievement to update loop when a loot is secured; applicable only to `triggers`, useful when standard loot counting is required with triggers
---@field no_counting boolean Prevents standard counting
---@field counter AchievementCounterTable Modifies counter checks
---@field difficulty_pass boolean?
---@field loot_counter_on_fail boolean? If the achievement loot counter should switch to `EHILootCounter` class when failed
---@field silent_failed_on_alarm boolean Fails achievement silently and switches to Loot Counter (only for dropins that are currently syncing and after the achievement has failed); Depends on Loot Counter to be visible in order to work
---@field start_silent boolean? If the achievement loot counter should start as `EHILootCounter` first; When achievement really starts, call `EHIAchievementLootCounterTracker:SetStarted()`
---@field no_sync boolean Disables loot sync

---@class AchievementBagValueCounterTable
---@field achievement string Achievement ID
---@field value number Value of loot needed to secure
---@field show_finish_after_reaching_target boolean Setting this to `true` will show `FINISH` in the tracker
---@field counter AchievementCounterTable Modifies counter checks

---@class AchievementKillCounterTable
---@field achievement string Achievement ID
---@field achievement_stat string Achievement Counter
---@field achievement_option string? If achievement belongs to some EHI setting
---@field difficulty_pass boolean?

---@class AddWaypointTable : WaypointInitData
---@field id string Waypoint ID
---@field time number
---@field class string? Waypoint class, defaults to `EHIWaypoint` if not provided
---@field remove_vanilla_waypoint number?
---@field restore_on_done boolean? Depends on `remove_vanilla_waypoint`
---@field icon string|table
---@field texture string
---@field texture_rect TextureRect
---@field timer 0
---@field pause_timer 1
---@field no_sync true

---@class MissionDoorTable
---@field w_id number Waypoint ID
---@field restore boolean? If the waypoint should be restored when the drill finishes
---@field unit_id number? ID of the MissionDoor device (safe, door, vault, ...)

---@class ValueBasedOnDifficultyTable
---@field normal_or_above any Normal or above
---@field normal any Normal
---@field hard_or_below any Hard or below
---@field hard_or_above any Hard or above
---@field hard any Hard
---@field veryhard_or_below any Very Hard or below
---@field veryhard_or_above any Very Hard or above
---@field veryhard any Very Hard
---@field overkill_or_below any OVERKILL or below
---@field overkill_or_above any OVERKILL or above
---@field overkill any OVERKILL
---@field mayhem_or_below any Mayhem or below
---@field mayhem_or_above any Mayhem or above
---@field mayhem any Mayhem
---@field deathwish_or_below any Death Wish or below
---@field deathwish_or_above any Death Wish or above
---@field deathwish any Death Wish
---@field deathsentence_or_below any Death Sentence or below
---@field deathsentence any Death Sentence

---@class KeypadResetTimerTable
---@field normal number Normal `5s`
---@field hard number Hard `15s`
---@field veryhard number Very Hard `15s`
---@field overkill number OVERKILL `20s`
---@field mayhem number Mayhem `30s`
---@field deathwish number Death Wish `30s`
---@field deathsentence number Death Sentence `40s`

---@class UnitUpdateDefinition
---@field ignore boolean
---@field child_units table
---@field icons table
---@field remove_on_power_off boolean
---@field power_off_override boolean
---@field disable_set_visible boolean
---@field remove_on_alarm boolean
---@field remove_vanilla_waypoint number
---@field remove_vanilla_waypoint_overriden { id: number, waypoint: string } Removes already overriden waypoint in the game
---@field restore_waypoint_on_done boolean Depends on `remove_vanilla_waypoint`
---@field ignore_visibility boolean
---@field set_custom_id string
---@field tracker_merge_id string
---@field destroy_tracker_merge_on_done boolean? Depends on `tracker_merge_id`
---@field custom_callback { id: string, f: string }
---@field position Vector3
---@field remove_on_pause boolean
---@field warning boolean
---@field completion boolean
---@field icon_on_pause string
---@field f string|fun(id: number, unit_data: self, unit: UnitTimer|UnitDigitalTimer)
---@field hint string
---@field instance CoreWorldInstanceManager.Instance?
---@field ignore_waypoint boolean
---@field [any] any

---@class EHI.ColorTable.Color
---@field unit_id number Unit ID (100000)
---@field unit_ids number[] Unit ID (100000); higher priority than `unit_id`
---@field index number Instance start index
---@field indexes number[] Instance start index; higher priority than `index`

---@class EHI.ColorTable.params
---@field no_mission_check boolean
---@field tracker_name string Defaults to `ColorCodes` if not provided
---@field unit_id_all number Overrides `unit_id` and `unit_ids`

---@class EHI.ColorTable
---@field red number|boolean|EHI.ColorTable.Color
---@field green number|boolean|EHI.ColorTable.Color
---@field blue number|boolean|EHI.ColorTable.Color

---@class EHITracker.params
---@field id string
---@field icons table?
---@field time number?
---@field x number Provided by `EHITrackerManager`
---@field y number Provided by `EHITrackerManager`
---@field hide_on_delete boolean?
---@field flash_times number?
---@field flash_bg boolean?
---@field hint string?
---@field remove_on_alarm boolean?
---@field update_on_alarm boolean?
---@field delay_popup boolean Provided by `EHITrackerManager`
---@field first_icon_pos number?
---@field [any] any

---@class EHITracker.CreateText
---@field status_text string? Sets status text, like in achievements
---@field text string? Text to display
---@field x number?
---@field left number? Identical to `x`
---@field w number?
---@field h number?
---@field color Color?
---@field visible boolean?
---@field FitTheText boolean? Fits the text in the text panel
---@field FitTheText_FontSize number? Fits the text in the text panel with given font size, depends on `FitTheText`

---@class XPBreakdown.plan.i_custom.objectives_override.stop_at_inclusive_and_add_objectives
---@field stop_at string
---@field add_objectives XPBreakdown.objectives Has higher priority than `add_objectives_with_pos`
---@field add_objectives_with_pos XPBreakdown.plan.i_custom.objectives_override.add_objectives_with_pos
---@field mark_optional table Depends on `stop_at`

---@class XPBreakdown.plan.i_custom.objectives_override.add_objectives_with_pos
---@field [number] { objective: XPBreakdown.objectives, pos: number }

---@class XPBreakdown.plan.i_custom.objectives_override
---@field stop_at string
---@field stop_at_inclusive string
---@field add_objectives XPBreakdown.objectives
---@field add_objectives_with_pos XPBreakdown.plan.i_custom.objectives_override.add_objectives_with_pos
---@field mark_optional table Depends on `stop_at` or `stop_at_inclusive`
---@field stop_at_inclusive_and_add_objectives XPBreakdown.plan.i_custom.objectives_override.stop_at_inclusive_and_add_objectives

---@class XPBreakdown.plan.i_custom
---@field name "stealth"|"loud"
---@field additional_name string? Places another string in brackets; `ehi_experience_<name>`
---@field plan _XPBreakdown
---@field objectives_override XPBreakdown.plan.i_custom.objectives_override

---@class XPBreakdown.plan.custom
---@field [number] XPBreakdown.plan.i_custom

---@class XPBreakdown.plan
---@field custom XPBreakdown.plan.custom
---@field stealth _XPBreakdown
---@field loud _XPBreakdown

---@class XPBreakdown.random
---@field max number?
---@field [string] XPBreakdown.objectives

---@class _XPBreakdown.escape
---@field amount number
---@field stealth boolean
---@field loud boolean
---@field timer number
---@field ghost_bonus number `stealth` only
---@field c4_used boolean `loud` only
---@field escape_chance { start_chance: number, kill_add_chance: number?, no_expert_driver_asset: boolean } `loud` only
---@field escape_after_alarm_in number for `stealth` only missions

---@class XPBreakdown.escape
---@field [number] _XPBreakdown.escape

---@class XPBreakdown.objective
---@field [string] number|table
---@field escape number|XPBreakdown.escape

---@class _XPBreakdown.objectives.name_format
---@field id string `ehi_experience_<name>`
---@field macros table<string, string>

---@class _XPBreakdown.objectives
---@field amount number XP Base
---@field name string `ehi_experience_<name>`
---@field name_format _XPBreakdown.objectives.name_format
---@field additional_name string? `ehi_experience_<name>`
---@field optional boolean?
---@field times number?
---@field escape number|XPBreakdown.escape|true
---@field escape_ghost_bonus_only number
---@field loud_escape true
---@field police_escape true
---@field random XPBreakdown.random
---@field stealth number
---@field loud number
---@field _or boolean
---@field ghost_bonus number
---@field escape_chance { start_chance: number, kill_add_chance: number?, no_expert_driver_asset: boolean }
---@field increase_escape_chance number?

---@class XPBreakdown.objectives
---@field [number] _XPBreakdown.objectives

---@class XPBreakdown.loot
---@field [string] number|{amount: number, times: number}

---@class _XPBreakdown
---@field u24_mod boolean
---@field objective XPBreakdown.objective
---@field objectives XPBreakdown.objectives
---@field loot XPBreakdown.loot
---@field loot_all number|{amount: number, times: number, text: string}
---@field wave number[]
---@field wave_all number|{amount: number, times: number}

---@class XPBreakdown
---@field u24_mod boolean
---@field objective XPBreakdown.objective
---@field objectives XPBreakdown.objectives
---@field loot XPBreakdown.loot
---@field loot_all number|{amount: number, times: number}
---@field wave number[]
---@field wave_all number|{amount: number, times: number}
---@field no_total_xp boolean
---@field plan XPBreakdown.plan
---@field total_xp_override table