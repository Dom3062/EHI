Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_EHI", function(loc)
	--[[for _, filename in pairs(file.GetFiles(BB._path .. "loc/")) do
		local str = filename:match('^(.*).txt$')
		if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
			loc:load_localization_file(BB._path .. "loc/" .. filename)
			break
		end
	end]]
	loc:load_localization_file(EHI.ModPath .. "loc/english.json", false)
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