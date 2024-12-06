local wezterm = require 'wezterm';

wezterm.on("bell", function(window, pane)
	wezterm.log_info("the bell was rung in pane " .. pane:pane_id() .. "!");
end)

wezterm.on('augment-command-palette', function(window, pane)
  return {
    {
      brief = 'Rename tab',
      icon = 'md_rename_box',

      action = wezterm.action.PromptInputLine {
        description = 'Enter new name for tab',
        -- initial_value = 'My Tab Name',
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            window:active_tab():set_title(line)
          end
        end),
      },
    },
    {
	    brief = 'SSH',
	    action = wezterm.action_callback(function(window, pane)
		    local success, stdout, stderr = wezterm.run_child_process { 'jq', '-r', '.[].ENV_ID', '/home/michael/.cache/dwdevtool/shared-environments.json' };
		    local ssh_hosts = {};
		    for _, line in ipairs(wezterm.split_by_newlines(stdout)) do
			    table.insert(ssh_hosts, {label=line, id=line .. ".demo-datawalk.com"});
		    end
		    window:perform_action(wezterm.action.InputSelector {
			    title = 'Host',
			    choices = ssh_hosts,
			    action = wezterm.action_callback(function(window, pane, id, label)
				    window:set_right_status(label);
			    end),
			    fuzzy = true,
		    }, pane);
	    end),
    },
  }
end)

-- wezterm.on('update-status', function(window, pane)
	--   window:set_left_status('hello world');
	--   window:set_right_status('testing');
	-- end)

local config = wezterm.config_builder();
config:set_strict_mode(true);
config.font = wezterm.font_with_fallback {
	'Liga Roboto Mono',
	'icons-in-terminal',
	'Noto Sans Symbols',
	'Noto Sans Symbols 2',
	'Droid Sans Fallback',
	'Noto Color Emoji',
}
config.font_size = 12.0
config.color_scheme_dirs = { "~/.config/wezterm/colors" }
-- config.color_scheme = 'Molokai'
-- config.color_scheme = 'nord'
config.color_scheme = 'Catppuccin Macchiato'
-- config.color_scheme = "Everforest Dark (Medium)"
config.enable_wayland = true
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.9
config.check_for_updates = false
config.check_for_updates_interval_seconds = 86400
config.show_update_window = false
config.keys = {
	{key="Tab", mods="CTRL", action=wezterm.action{ActivateTabRelative=1}},
	{key="PageUp", mods="CTRL", action=wezterm.action{ActivateTabRelative=1}},
	{key="PageDown", mods="CTRL", action=wezterm.action{ActivateTabRelative=-1}},
	{key="UpArrow", mods="CTRL", action=wezterm.action{ScrollToPrompt=-1}},
	{key="DownArrow", mods="CTRL", action=wezterm.action{ScrollToPrompt=1}},
}
config.mouse_bindings = {
	{
		event={Down={streak=4, button="Left"}},
		action={SelectTextAtMouseCursor="SemanticZone"},
		mods="NONE"
	},
}
config.visual_bell = {
	fade_in_duration_ms = 100,
	fade_out_duration_ms = 100,
	fade_in_function = 'Linear',
	fade_out_function = 'Linear',
	target = 'BackgroundColor'
}
config.hyperlink_rules = {
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
}
config.quick_select_patterns = {
	-- JIRA ref
	"\\b(?:CTO|SOS|US|DW|MLAR)-\\d+\\b",
	-- s3 URL
	"(?:s3://)\\S+",
	-- s3 folder in `aws s3 ls` output
	"(?<=PRE )(?:[.\\w\\-@]+/)+",
}
config.inactive_pane_hsb = {
	saturation = 0.9,
	brightness = 0.25,
}
-- config.ssh_domains = {
-- 	{
-- 		name = "tight-terrier-5eeb",
-- 		remote_address = "tight-terrier-5eeb.demo-datawalk.com",
-- 	},
-- }

config.ssh_domains = wezterm.default_ssh_domains()
for _, dom in ipairs(config.ssh_domains) do
  dom.assume_shell = 'Posix'
end

return config
