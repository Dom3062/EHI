local EHI = EHI
if EHI._hooks.MenuManager then
	return
else
	EHI._hooks.MenuManager = true
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_EHI", function(loc)
	local language_filename = nil
	local LanguageKey =
	{
		["PAYDAY 2 THAI LANGUAGE Mod"] = "thai",
		--["Ultimate Localization Manager & 正體中文化"] = "tchinese",
		["PAYDAY 2 BRAZILIAN PORTUGUESE"] = "portuguese-br",
		--["Payday 2 Korean patch"] = "korean"
	}
	for _, mod in pairs(BLT and BLT.Mods and BLT.Mods:Mods() or {}) do
		language_filename = mod:IsEnabled() and LanguageKey[mod:GetName()]
		if language_filename then
			break
		end
	end
	if not language_filename then
		for _, filename in pairs(file.GetFiles(EHI.LocPath)) do
			local str = filename:match('^(.*).json$')
			if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
				language_filename = str
				break
			end
		end
	end
	if language_filename and language_filename ~= "english" then
		loc:load_localization_file(EHI.ModPath .. "loc/" .. language_filename .. ".json")
	end
	loc:load_localization_file(EHI.ModPath .. "loc/english.json", false)
	--[[for _, filename in pairs(file.GetFiles(BB._path .. "loc/")) do
		local str = filename:match('^(.*).txt$')
		if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
			loc:load_localization_file(BB._path .. "loc/" .. filename)
			break
		end
	end]]
end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_EHI", function(menu_manager, nodes)
    MenuCallbackHandler.OpenEHIModOptions = function(self, item)
        EHI.Menu = EHI.Menu or EHIMenu:new()
		EHI.Menu:Open()

		-- Add Hook when menu is created
		Hooks:PostHook(MenuManager, "update", "update_menu_EHI", function(self, t, dt)
			if EHI.Menu and EHI.Menu.update and EHI.Menu._enabled then
				EHI.Menu:update(t, dt)
			end
		end)
	end

	local node = nodes["blt_options"]

	local item_params = {
		name = "EHI_OpenMenu",
		text_id = "ehi_mod_title",
		help_id = "ehi_mod_desc",
		callback = "OpenEHIModOptions",
		localize = true,
	}
	local item = node:create_item({type = "CoreMenuItem.Item"}, item_params)
    node:add_item(item)
end)