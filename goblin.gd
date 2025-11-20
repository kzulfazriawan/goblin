@tool
extends EditorPlugin

#region ____Constants____
## Constant variable of dictionary collections of the autoloads
const AUTOLOADS := {
	'Transmitter': 'res://addons/goblin/src/autoloads/transmitter.gd',
	'Logging'    : 'res://addons/goblin/src/autoloads/logging.gd',
	'Statement'  : 'res://addons/goblin/src/autoloads/statement.gd'
}

## Constant variable of dictionary projecct settings for framework
const PROJECT_SETTINGS := {
	'framework/configurations/dialogue/text_speed': .75,
	'framework/configurations/dialogue/box_opacity': 1.0,
	'framework/configurations/dialogue/auto_speed': 5,
	'framework/configurations/display/window': Vector2i(1280, 720),
	'framework/configurations/audio/master': 1.0,
	'framework/configurations/audio/bgm': 1.0,
	'framework/configurations/audio/sfx': 1.0,
	'framework/configurations/audio/voices': 1.0,
}
#endregion

#region ____Utilities____
## Set/update configurations
func set_configs() -> void:
	for config: String in PROJECT_SETTINGS.keys():
		if not ProjectSettings.has_setting(config):
			print_rich('Project settings with key: {key} not found. Attempt to set with value {value}'.format({
				'key': config, 'value': PROJECT_SETTINGS.get(config, null)
			}))
			ProjectSettings.set_setting(config, PROJECT_SETTINGS.get(config, null))
			#ProjectSettings.set_initial_value(config, PROJECT_SETTINGS.get(config, null))

## Unset/delete configurations
func unset_configs() -> void:
	for config: String in PROJECT_SETTINGS.keys():
		if ProjectSettings.has_setting(config):
			print_rich('Project settings with key: {key} is found. Attempt to unset'.format({'key': config}))
			ProjectSettings.set_setting(config, null)
#endregion


#region ____Engine Lifecycles____
# Called when the node enters the SceneTree
func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	set_configs()
	ProjectSettings.save()
	
	for i in AUTOLOADS.keys():
		add_autoload_singleton(i, AUTOLOADS[i])

# Called when the node about to leave the SceneTree
func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	unset_configs()
	
	for i in AUTOLOADS.keys():
		remove_autoload_singleton(i)
#endregion
