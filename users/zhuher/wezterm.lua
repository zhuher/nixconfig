local wezterm = require 'wezterm'
local act = wezterm.action

function scheme_for_appearance()
  if wezterm.gui.get_appearance():find 'Dark' then
    return 'Dracula+'
  else
    return 'rose-pine-dawn'
  end
end

return {
  font = wezterm.font 'MonaspiceXe Nerd Font Propo',
  color_scheme = scheme_for_appearance(),
  use_fancy_tab_bar = true,
  hide_tab_bar_if_only_one_tab = true,
  window_padding = {
    left = "1pt",
    right = "1pt",
    top = "1pt",
    bottom = "1pt",
  },
  front_end = "WebGpu",
  window_background_opacity = 0.8,
  macos_window_background_blur = 20,
  disable_default_key_bindings = true,
  disable_default_mouse_bindings = true,
  scrollback_lines = 69420,
  mouse_bindings = {
    { event = { Up = { streak = 2, button = 'Left' } }, action = act.OpenLinkAtMouseCursor },
    { event = { Drag = { streak = 1, button = 'Left' } }, mods = 'SUPER', action = act.StartWindowDrag },
    { event = { Drag = { streak = 1, button = 'Left' } }, mods = 'NONE', action = act.ExtendSelectionToMouseCursor("Cell") },
    { event = { Down = { streak = 1, button = 'Left' } }, mods = 'NONE', action = act.SelectTextAtMouseCursor("Cell") },
    { event = { Down = { streak = 1, button = { WheelUp = 1 } } }, mods = 'SUPER', action = act.IncreaseFontSize },
    { event = { Down = { streak = 1, button = { WheelDown = 1 } } }, mods = 'SUPER', action = act.DecreaseFontSize },
    { event = { Down = { streak = 1, button = { WheelUp = 1 } } }, mods = 'NONE', action = act.ScrollByLine(-1) },
    { event = { Down = { streak = 1, button = { WheelDown = 1 } } }, mods = 'NONE', action = act.ScrollByLine(1) },
  };
  keys = {
    { key = 'd', mods = 'SUPER', action = act.SplitHorizontal{ domain = 'CurrentPaneDomain' } },
    { key = 'd', mods = 'SHIFT|SUPER', action = act.SplitVertical{ domain = 'CurrentPaneDomain' } },
    { key = 'c', mods = 'SUPER', action = act.CopyTo 'Clipboard' },
    { key = 'v', mods = 'SUPER', action = act.PasteFrom 'Clipboard' },
    { key = 'h', mods = 'SUPER', action = act.ActivatePaneDirection 'Left' },
    { key = 'l', mods = 'SUPER', action = act.ActivatePaneDirection 'Right' },
    { key = 'k', mods = 'SUPER', action = act.ActivatePaneDirection 'Up' },
    { key = 'j', mods = 'SUPER', action = act.ActivatePaneDirection 'Down' },
    { key = 't', mods = 'SUPER', action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 'w', mods = 'SUPER', action = act.CloseCurrentPane{ confirm = true } },
    { key = 'w', mods = 'SHIFT|SUPER', action = act.CloseCurrentTab{ confirm = true } },
    { key = '\\', mods = 'SUPER', action = act.ShowDebugOverlay },
    { key = '\'', mods = 'SUPER', action = act.ActivateCommandPalette },
    { key = '[', mods = 'SUPER', action = act.ActivateTabRelative(-1) },
    { key = ']', mods = 'SUPER', action = act.ActivateTabRelative(1) },
    { key = 'LeftArrow', mods = 'SHIFT|SUPER', action = act.AdjustPaneSize{ 'Left', 1 } },
    { key = 'RightArrow', mods = 'SHIFT|SUPER', action = act.AdjustPaneSize{ 'Right', 1 } },
    { key = 'UpArrow', mods = 'SHIFT|SUPER', action = act.AdjustPaneSize{ 'Up', 1 } },
    { key = 'DownArrow', mods = 'SHIFT|SUPER', action = act.AdjustPaneSize{ 'Down', 1 } },
    { key = ';', mods = 'SUPER', action = act.CharSelect{ copy_on_select = true, copy_to =  'ClipboardAndPrimarySelection' } },
    { key = '=', mods = 'SUPER', action = act.IncreaseFontSize },
    { key = '-', mods = 'SUPER', action = act.DecreaseFontSize },
    { key = '0', mods = 'SUPER', action = act.ResetFontSize },
    { key = 'r', mods = 'SHIFT|SUPER|CTRL', action = act.ReloadConfiguration },
    { key = "PageUp", mods = "SUPER", action = act.ScrollByPage(-0.5) },
    { key = "PageDown", mods = "SUPER", action = act.ScrollByPage(0.5) },
    { key = "UpArrow", mods = "SHIFT|SUPER", action = act.ScrollByPage(-0.5) },
    { key = "DownArrow", mods = "SHIFT|SUPER", action = act.ScrollByPage(0.5) },
    { key = "UpArrow", mods = "SHIFT", action = act.ScrollByLine(-1) },
    { key = "DownArrow", mods = "SHIFT", action = act.ScrollByLine(1) },
  },
}
