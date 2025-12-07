extends Panel
class_name Configuration

'''
Configuration panel script.
Loads stored ProjectSettings into the corresponding UI controls.
Optimized for readability, scalability, and maintainability.
'''

# -------------------------------------------------------------------
# ENUMS
# -------------------------------------------------------------------
enum WINDOW_SIZE { HD, WXGA, HDP, FHD }

#region ____ Constants ____
const GROUPNAME := 'configuration'

# Maps friendly keys to their actual ProjectSettings paths
const CONFIGURATIONS := {
	'dialogue_text_speed' : 'framework/configurations/dialogue/text_speed',
	'dialogue_box_opacity': 'framework/configurations/dialogue/box_opacity',
	'dialogue_auto_speed' : 'framework/configurations/dialogue/auto_speed',
	'display_window_size' : 'framework/configurations/display/window',
	'display_window_mode' : 'display/window/size/mode',
	'audio_master'        : 'framework/configurations/audio/master',
	'audio_bgm'           : 'framework/configurations/audio/bgm',
	'audio_sfx'           : 'framework/configurations/audio/sfx',
	'audio_voices'        : 'framework/configurations/audio/voices'
}

# Defines which UI control corresponds to each configuration key. This avoids repeating node path
# lookups everywhere.
const UI_PATHS := {
	'dialogue_text_speed' : 'Layout/Tab/General/Wrapper/Text/Speed',
	'dialogue_box_opacity': 'Layout/Tab/General/Wrapper/Text/Opacity',
	'audio_master'        : 'Layout/Tab/General/Wrapper/Audio/Master',
	'audio_bgm'           : 'Layout/Tab/General/Wrapper/Audio/Music',
	'audio_sfx'           : 'Layout/Tab/General/Wrapper/Audio/Effects',
	'display_window_mode' : 'Layout/Tab/Graphics/Wrapper/Window/Fullscreen',
	'display_window_size' : 'Layout/Tab/Graphics/Wrapper/Size/Resolutions'
}

# Converts resolution Vector2i → enum (for dropdown UI)
const RESOLUTIONS := {
	Vector2i(1280, 720) : WINDOW_SIZE.HD,
	Vector2i(1366, 768) : WINDOW_SIZE.WXGA,
	Vector2i(1600, 900) : WINDOW_SIZE.HDP,
	Vector2i(1920, 1080): WINDOW_SIZE.FHD
}
#endregion

@export var master_bus_name := 'Master'
@export var bgm_bus_name := 'BGM'
@export var sfx_bus_name := 'SFX'

# -------------------------------------------------------------------
# VARIABLES
# -------------------------------------------------------------------
var _window_sizes: WINDOW_SIZE
var _master_bus_index: int
var _bgm_bus_index: int
var _sfx_bus_index:int

#region ____ Engine Lifecycles ____
func _init() -> void:
	# Ensure this panel is registered under 'configuration' group
	if not is_in_group(GROUPNAME):
		add_to_group(GROUPNAME)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Apply all settings when panel becomes ready
	for key in CONFIGURATIONS.keys():
		_apply_setting(key)
	
	_master_bus_index = AudioServer.get_bus_index(master_bus_name)
	_bgm_bus_index = AudioServer.get_bus_index(bgm_bus_name)
	_sfx_bus_index = AudioServer.get_bus_index(sfx_bus_name)
#endregion

#region ____ Helper methods ____
# Reads ProjectSettings for the given key and applies the value to the corresponding UI node.
# Each key may have special handling depending on its type (slider, checkbox, option button).
func _apply_setting(key: String) -> void:
	var setting_path: String = CONFIGURATIONS[key]
	
	if not ProjectSettings.has_setting(setting_path): return
	
	var value = ProjectSettings.get_setting(setting_path)
	match key:
		'display_window_mode':
			# Special handling: toggle fullscreen checkbox
			_get_node(UI_PATHS[key]).button_pressed = (value == DisplayServer.WINDOW_MODE_FULLSCREEN)
		
		'display_window_size':
			# Special handling: resolution dropdown
			if value in RESOLUTIONS:
				_window_sizes = RESOLUTIONS[value]
				_get_node(UI_PATHS[key]).selected = int(_window_sizes)
		
		_:
			# General handling: apply numeric values (sliders, spinboxes)
			var node = _get_node(UI_PATHS.get(key, ''))
			if node and node.has_method('set_value'):
				node.value = value

# Safely fetches a node by relative path from this Panel, and eturns `null` if the path is empty/invalid.
func _get_node(path: String) -> Node:
	if path.is_empty(): return null
	return get_node_or_null(path)
#endregion

#region ____ Event Methods ____
## Public method for all to open configuration overlay in the game.
func open_configuration() -> void:
	_toggle_config(true)

# Called when button `close_config` is pressed
func _on_close_pressed() -> void:
	_toggle_config(false)

# An utilities method to toggle the configuration based on the parameter to shown.
func _toggle_config(state: bool) -> void:
	var tween = create_tween()
	var target_color = Color.WHITE if state else Color(1, 1, 1, 0)
	tween.tween_property($'.', 'modulate', target_color, 0.25)

	if not state: await tween.finished
	visible = state

	if get_parent() != null:
		get_parent().visible = state
#endregion

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED)
	ProjectSettings.set_setting(
		CONFIGURATIONS.display_window_mode,
		DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED
	)
	ProjectSettings.save()
	
	if not toggled_on:
		# Update the resolutions with the size on the configuration or default viewport
		DisplayServer.window_set_size(
			ProjectSettings.get_setting(CONFIGURATIONS.display_window_size, Vector2i(1600, 900))
		)
	
	Logging.info(
		'Set configuration %s with value %s' % [
			CONFIGURATIONS.display_window_mode, 'FULLSCREEN' if toggled_on else 'WINDOWED'
		]
	)

func _on_resolutions_item_selected(index: int) -> void:
	var resolution_lists := [
		Vector2i(1280, 720),
		Vector2i(1366, 768),
		Vector2i(1600, 900),
		Vector2i(1920, 1080)
	]
	DisplayServer.window_set_size(resolution_lists.get(index))
	ProjectSettings.set_setting(CONFIGURATIONS.display_window_size, resolution_lists.get(index))
	ProjectSettings.save()
	
	Logging.info(
		'Set configuration %s with value %s x %s' % [
			CONFIGURATIONS.display_window_size,
			str(resolution_lists.get(index).x),
			str(resolution_lists.get(index).y)
		]
	)

func _on_speed_value_changed(value: float) -> void:
	ProjectSettings.set_setting(CONFIGURATIONS.dialogue_text_speed, value)
	ProjectSettings.save()
	Logging.info('Set configuration %s into %.1f' % [CONFIGURATIONS.dialogue_text_speed, value])

func _on_opacity_value_changed(value: float) -> void:
	ProjectSettings.set_setting(CONFIGURATIONS.dialogue_box_opacity, value)
	ProjectSettings.save()
	Logging.info('Set configuration %s into %.1f' % [CONFIGURATIONS.dialogue_box_opacity, value])

func _on_master_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(_master_bus_index, linear_to_db(value))
	ProjectSettings.set_setting(CONFIGURATIONS.audio_master, value)
	ProjectSettings.save()
	Logging.info('Set configuration %s into %.1f' % [CONFIGURATIONS.audio_master, value])

func _on_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(_bgm_bus_index, linear_to_db(value))
	ProjectSettings.set_setting(CONFIGURATIONS.audio_bgm, value)
	ProjectSettings.save()
	Logging.info('Set configuration %s into %.1f' % [CONFIGURATIONS.audio_bgm, value])

func _on_effects_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(_sfx_bus_index, linear_to_db(value))
	ProjectSettings.set_setting(CONFIGURATIONS.audio_sfx, value)
	ProjectSettings.save()
	Logging.info('Set configuration %s into %.1f' % [CONFIGURATIONS.audio_sfx, value])

func _tween_fade(modulate_color: Color, callback: Callable) -> void:
	var tween = get_tree().create_tween()
	if tween.finished.is_connected(callback): tween.finished.disconnect(callback)
	tween.tween_property($'.', 'modulate', modulate_color, .25)
	tween.finished.connect(callback)
