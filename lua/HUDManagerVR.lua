if true then
	return
end

local _f_init_tablet_gui = HUDManagerVR._init_tablet_gui
function HUDManagerVR:_init_tablet_gui(...)
    _f_init_tablet_gui(self, ...)
    local tablet_panel = self._tablet_ws:panel()
    local ehi = tablet_panel:panel({
        name = "ehi_page",
        x = tablet_panel:child("right_page"):w()
    })
    self._page_panels[4] = ehi
    self._pages.right.right = "ehi"
    self._pages.ehi.left = "right"
    local right = tablet_panel:child("right")
    if right:child("bg") then
        right:remove(right:child("bg"))
        right:bitmap({
            name = "bg",
            layer = -2,
            texture = "guis/dlcs/vr/textures/pd2/pad_bg_r",
            w = tablet_panel:w(),
            h = tablet_panel:h()
        })
    end
    ehi:bitmap({
        name = "bg",
        layer = -2,
        texture = "guis/dlcs/vr/textures/pd2/pad_bg_l",
        w = tablet_panel:w(),
        h = tablet_panel:h()
    })
    managers.ehi:GetTabletPanel(ehi)
	--[[self._tablet_ws = self._gui:create_world_workspace(402, 226, Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0))
	local tablet_panel = self._tablet_ws:panel()
	local main = tablet_panel:panel({
		name = "main_page"
	})
	local right = tablet_panel:panel({
		name = "right_page",
		x = tablet_panel:w()
	})
	local left = tablet_panel:panel({
		name = "left_page",
		x = -tablet_panel:w()
	})
	self._tablet_highlight = tablet_panel:panel({
		layer = 10,
		name = "highlight"
	})

	self._tablet_highlight:bitmap({
		texture = "guis/dlcs/vr/textures/pd2/pad_state_rollover",
		name = "highlight",
		w = tablet_panel:w(),
		h = tablet_panel:h()
	})

	self._tablet_touch = self._tablet_highlight:bitmap({
		texture = "guis/dlcs/vr/textures/pd2/pad_state_touch",
		name = "highlight",
		h = 100,
		w = 100
	})

	self._tablet_highlight:hide()

	for texture_name, page in pairs({
		pad_bg = main,
		pad_bg_l = right,
		pad_bg_r = left
	}) do
		page:bitmap({
			name = "bg",
			layer = -2,
			texture = "guis/dlcs/vr/textures/pd2/" .. texture_name,
			w = tablet_panel:w(),
			h = tablet_panel:h()
		})
	end

	self._page_panels = {
		main,
		right,
		left
	}
	self._pages = {
		main = {
			left = "left",
			right = "right"
		},
		right = {
			left = "main"
		},
		left = {
			right = "main"
		}
	}
	self._current_page = "main"
	self._page_callbacks = {
		on_interact = {},
		on_focus = {}
	}

	self._tablet_ws:hide()]]
end