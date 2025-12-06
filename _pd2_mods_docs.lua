---@meta

--------------------
--- SuperBLT DLL ---
--------------------
---@class blt
_G.blt = {}
_G.blt.vm = {}
_G.blt.vm.dofile = dofile
_G.blt.vm.loadfile = loadfile

----------------
--- SuperBLT ---
----------------

---@class json
_G.json = {}
---Converts a Lua table to a JSON string
---@param data table @Data to encode
---@return string @Encoded data
function json.encode(data)
end

---Converts a JSON string to a Lua table
---@param data string @String to decode
---@return table @Decoded data
function json.decode(data)
end

---@class BLTMod
_G.ModInstance = {}

---@class BLT
---@field Mods BLTModManager
_G.BLT = {}

---@class BLTModManager
---@field Mods fun(self: self): BLTMod[]

---@class BLTMod
---@field GetAuthor fun(self: self): string
---@field GetName fun(self: self): string
---@field GetVersion fun(self: self): string
---@field IsEnabled fun(self: self): boolean
---@field SetEnabled fun(self: self, enable: boolean, force: boolean?)

---@class DelayedCalls
---@field Add fun(self: self, id: string, time: number, func: function)
_G.DelayedCalls = {}

---@class Hooks
---@field _function_hooks table
---@field Add fun(self: self, key: string, id: string, func: function)
---@field RemovePreHook fun(self: self, id: string)
---@field RemovePostHook fun(self: self, id: string)
_G.Hooks = {}

---@generic T
---@param object T
---@param func string
---@param id string
---@param post_call fun(self: T, ...)
function Hooks:PostHook(object, func, id, post_call)
end

---@generic T
---@param object T
---@param func string
---@param id string
---@param pre_call fun(self: T, ...)
function Hooks:PreHook(object, func, id, pre_call)
end

---Removes a hooked function call with the specified id to prevent it from being called
---@param id string @Name of the function call to remove
function Hooks:Remove(id)
end

---@class NetworkHelper
_G.NetworkHelper = {}

---`Function in SuperBLT`  
---Sends networked data with a message id to all connected players except specific ones
---@param peer_id integer|integer[] @Peer ID or table of peer IDs of the player(s) to exclude
---@param id string @Unique name of the data to send
---@param data string @Data to send
function NetworkHelper:SendToPeersExcept(peer_id, id, data)
end

---`Function in SuperBLT`  
---Registers a function to be called when network data with a specific message id is received
---@param message_id string @The message id to hook to
---@param hook_id string @A unique name for this hook
---@param func fun(data: string, sender: integer) @Function to be called when network data for that specific message id is received
function NetworkHelper:AddReceiveHook(message_id, hook_id, func)
end

---`Function in SuperBLT`  
---Removes a receive hook
---@param hook_id string @The unique name of the hook to remove
---@param message_id? string @The message id to remove the hook from, if not specified removes all matching hooks
function NetworkHelper:RemoveReceiveHook(hook_id, message_id)
end

---`Function in SuperBLT`  
---Converts a string representation of a color to a color
---@param str string
---@return Color?
function NetworkHelper:StringToColour(str)
end

---`Function in SuperBLT`  
---Rounds a number to the specified precision (decimal places)
---@param num number @The number to round
---@param idp integer? @The number of decimal places to round to (defaults to `0`)
---@return number @The input number rounded to the input precision
function math.round_with_precision(num, idp)
end

---`Function in SuperBLT`  
---Loads a file containing JSON data and converts it into a Lua table
---@param path string @The path (relative to payday2_win32_release.exe) and file name to load the data from
---@return table? @The table containing the data, or `nil` if loading wasn't successful
function io.load_as_json(path)
end

---@class MenuHelper
MenuHelper = {}
---Returns a registered menu
---@param menu_id string @ID of the menu to get
---@return table @Menu with `menu_id`
function MenuHelper:GetMenu(menu_id)
end

---Registers a new menu that can have items added to it
---@param menu_id string @Unique ID to use for this menu
---@return table @The newly created menu
function MenuHelper:NewMenu(menu_id)
end

---Loads a json-formatted text file and automatically parses and converts into a usable menu
---@param file_path string @Path of the file to load and convert into a menu
---@param parent_class any @Unused
---@param data_table table @Table containing the data keys which various menu items can load their value from
function MenuHelper:LoadFromJsonFile(file_path, parent_class, data_table)
end

---@class menu_item_data
---@field menu_id string @Menu identifier of the menu to create this item on
---@field id string? @Unique identifier for this item
---@field title string @Title of the item, treated as localization key unless `localized` is set to `false`
---@field desc string? @Description of the item, treated as localization key unless `localized` is set to `false`
---@field disabled boolean? @Wether this item should be disabled, defaults to `false`
---@field disabled_color Color? @Color of the item when disabled, defaults to `Color(0.25, 1, 1, 1)`
---@field localized boolean? @Wether `title` and `desc` are treated as localization keys, defaults to `true`
---@field priority number? @Sorting order of the item in the menu
---@field callback string? @Function on `MenuCallbackHandler` to call when the item is changed

---@class button_data: menu_item_data
---@field next_node string? @Menu identifier of the menu to switch to when the item is clicked
---@field back_callback string? @Function on `MenuCallbackHandler` to call when the menu of the item is left

---Adds a button to the menu specified in `button_data`
---@param button_data button_data @Settings for the button to be added
---@return CoreMenuItem.Item @The created menu item
function MenuHelper:AddButton(button_data)
end

---@class divider_data: menu_item_data
---@field title string? @Title of the item, treated as localization key unless `localized` is set to `false`
---@field size number? @The size of the item, defaults to `8`
---@field no_text boolean? @Wether to display the divider as empty space, defaults to `true`

---Adds a divider to the menu specified in `divider_data`
---@param divider_data divider_data @Settings for the divider to be added
---@return MenuItemDivider @The created menu item
function MenuHelper:AddDivider(divider_data)
end

---@class toggle_data: menu_item_data
---@field value boolean? @The initial value of the item, defaults to `false`
---@field icon_by_text boolean? @Wether to place the checkbox to the right of its name, defaults to `false`

---Adds a toggle button to the menu specified in `toggle_data`
---@param toggle_data toggle_data @Settings for the toggle to be added
---@return CoreMenuItemToggle.ItemToggle @The created menu item
function MenuHelper:AddToggle(toggle_data)
end

---@class slider_data: menu_item_data
---@field value number @The initial value of the item
---@field min number? @Minimum allowed value of the item, defaults to `0`
---@field max number? @Maximum allowed value of the item, defaults to `10`
---@field step number? @Step size when the item is changed via arrow keys, defaults to `1`
---@field show_value boolean? @Wether to show the item value on the slider, defaults to `false`
---@field display_precision integer? @How many numbers to show after the decimal point, defaults to `2`
---@field display_scale number? @Value to multiply the item value with for displaying it, defaults to `1`
---@field is_percentage boolean? @Wether to show a percentage sign next to the item value, defaults to `false`

---Adds a slider to the menu specified in `slider_data`
---@param slider_data slider_data @Settings for the slider to be added
---@return CoreMenuItemSlider.ItemSlider @The created menu item
function MenuHelper:AddSlider(slider_data)
end

---@class multi_data: menu_item_data
---@field value any? @The initial value of the item
---@field items string[] @List of choices to display for the item
---@field item_values any[]? @List of values for the options in `items`, defaults to the index of the choice
---@field localized_items boolean? @Wether to treat the choices in `items` as localization keys, defaults to `true`

---Adds a multiple choice item to the menu specified in `multi_data`
---@param multi_data multi_data @Settings for the multiple choice item to be added
---@return MenuItemMultiChoice @The created menu item
function MenuHelper:AddMultipleChoice(multi_data)
end

---@class bind_data: menu_item_data
---@field connection_name string @Unique identifier for the keybind
---@field binding string? @Keyboard key that triggers this keybind
---@field button string? @Mouse button that triggers this keybind

---Adds a customizable keybinding to the menu specified in `bind_data`
---@param bind_data bind_data @Settings for the keybinding to be added
---@return MenuItemCustomizeController @The created menu item
function MenuHelper:AddKeybinding(bind_data)
end

---@class inputdata: menu_item_data
---@field value string? The initial value of the item

---Adds an input box to the menu specified in `input_data`
---@param input_data inputdata @Settings for the input box to be added
---@return MenuItemInput @The created menu item
function MenuHelper:AddInput(input_data)
end

---@class BLTNotificationsGui
---@field _panel Panel
---@field _beardlib_panel Panel? Panel from BeardLib
BLTNotificationsGui = {}
-----------------------
--- End of SuperBLT ---
-----------------------

----------------
--- Beardlib ---
----------------

---@class Global
---@field fm table A table of loaded files in Beardlib `Beardlib specific only`

---@class CustomAchievementPackage
---@field new fun(self: self, package_id: string): self
---@field Achievement fun(self: self, achievement_id: string): CustomAchievement?
_G.CustomAchievementPackage = {}

---@class CustomAchievement
---@field GetIcon fun(self: self): string Returns icon path
---@field GetName fun(self: self): string Returns localizated name of the achievement
---@field GetObjective fun(self: self): string Returns localizated achievement objective
---@field IsUnlocked fun(self: self): boolean
_G.CustomAchievement = {}

-----------------------
--- End of Beardlib ---
-----------------------

------------------------
--- Classic Heisting ---
------------------------
_G.ch_settings = {}

-------------------------
--- Custom Name Color ---
-------------------------
---@class CustomNameColor
---@field GetOwnColor fun(self: self): Color
---@field ModID string
_G.CustomNameColor = {}

--------------------------------
--- End of Custom Name Color ---
--------------------------------

----------------------------
--- Why Are You Running? ---
----------------------------

---@class SWAYRMod
---@field included fun(level_id: string): boolean
_G.SWAYRMod = {}

-----------------------------------
--- End of Why Are You Running? ---
-----------------------------------