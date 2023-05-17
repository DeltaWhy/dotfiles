local wezterm = require 'wezterm';

wezterm.on("bell", function(window, pane)
	wezterm.log_info("the bell was rung in pane " .. pane:pane_id() .. "!");
end)

return {
	font = wezterm.font_with_fallback {
		'Liga Roboto Mono',
		'icons-in-terminal',
		'Noto Sans Symbols',
		'Noto Sans Symbols 2',
		'Droid Sans Fallback',
		'Noto Color Emoji',
	},
	font_size = 12.0,
	-- color_scheme = 'Molokai',
	color_scheme = 'nord',
	-- color_scheme = 'Catppuccin Mocha',
	enable_wayland = true,
	hide_tab_bar_if_only_one_tab = true,
	window_background_opacity = 0.9,
	check_for_updates = true,
	check_for_updates_interval_seconds = 86400,
	show_update_window = true,
	keys = {
		{key="Tab", mods="CTRL", action=wezterm.action{ActivateTabRelative=1}},
		{key="PageUp", mods="CTRL", action=wezterm.action{ActivateTabRelative=1}},
		{key="PageDown", mods="CTRL", action=wezterm.action{ActivateTabRelative=-1}},
		{key="UpArrow", mods="CTRL", action=wezterm.action{ScrollToPrompt=-1}},
		{key="DownArrow", mods="CTRL", action=wezterm.action{ScrollToPrompt=1}},
	},
	mouse_bindings = {
		{ event={Down={streak=4, button="Left"}},
		  action={SelectTextAtMouseCursor="SemanticZone"},
		  mods="NONE"
		},
	},
	visual_bell = {
		fade_in_duration_ms = 100,
		fade_out_duration_ms = 100,
		fade_in_function = 'Linear',
		fade_out_function = 'Linear',
		target = 'BackgroundColor'
	},
	hyperlink_rules = {
		-- Linkify things that look like URLs
		-- This is actually the default if you don't specify any hyperlink_rules
		{
			regex = "\\b\\w+://(?:[\\w.-]+)\\.[a-z]{2,15}\\S*\\b",
			format = "$0",
		},

		-- linkify email addresses
		{
			regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
			format = "mailto:$0",
		},

		-- file:// URI
		{
			regex = "\\bfile://\\S*\\b",
			format = "$0",
		},

		-- Make task numbers clickable
		{
		regex = "\\b((CTO|SOS|US|DW|MLAR)-(\\d+))\\b",
		format = "https://datawalk.atlassian.net/browse/$1",
		},
	},
}
