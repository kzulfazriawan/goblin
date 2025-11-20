extends Panel
class_name SaveOrLoad

const SLOT_FILES := [
	'user://autosave.sav',
	'user://save1.sav',
	'user://save2.sav',
	'user://save3.sav'
]

const SAVE_CONTENT_FORMAT := '''
	Day : {day}
	Time : {time}
	
	${currency}


[center]
Location
{place}
[/center]
'''

@export var main_app: Node
@export var signal_name := 'load_game'

var _is_load := false
var _time_translate := ['Morning', 'Noon', 'Dusk', 'Evening']

func _init() -> void:
	# Ensure this panel is registered under 'configuration' group
	if not is_in_group('save_or_load'):
		add_to_group('save_or_load')

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_visibility_changed() -> void:
	if visible:
		for i in range($Layout/SaveSlots.get_child_count()):
			var panel := $Layout/SaveSlots.get_child(i)
			var load_button: Button = panel.get_node('Wrapper/Load')
			var save_button: Button = panel.get_node('Wrapper/Save')
			var contents: RichTextLabel = panel.get_node('Wrapper/Contents')
			var parse := Utils.json_parse(SLOT_FILES[i])
			if not parse.is_empty():
				var currency = Marshalls.base64_to_utf8(parse.get('currency'))
				contents.text = SAVE_CONTENT_FORMAT.format({
					'day': int(parse.get('day', 0)),
					'time': int(parse.get('time', 0)),
					'currency': currency if currency else '0',
					'place': parse.get('place', 'Room').capitalize(),
				})
			save_button.visible = !_is_load
			load_button.visible = false
		
			if _is_load:
				load_button.visible = !parse.is_empty()

# An utilities method to toggle the configuration based on the parameter to shown.
func _toggle_save_or_load(state: bool, callback = null) -> void:
	var tween = create_tween()
	var target_color = Color.WHITE if state else Color(1, 1, 1, 0)
	if callback != null and typeof(callback) == TYPE_CALLABLE:
		tween.finished.connect(callback)
	tween.tween_property($'.', 'modulate', target_color, 0.25)

	if not state: await tween.finished
	visible = state

	if get_parent() != null:
		get_parent().visible = state

func open_load_state() -> void:
	_is_load = true
	_toggle_save_or_load(true)

func open_save_state() -> void:
	_is_load = false
	_toggle_save_or_load(true)

func _loading_game() -> void:
	if main_app.has_signal(signal_name):
		_toggle_save_or_load(false, func(): main_app.emit_signal(signal_name))

func _on_close_pressed() -> void:
	_toggle_save_or_load(false)

func _on_autosave_load_click() -> void:
	Statement.set_state_from_file(SLOT_FILES[0])
	call_deferred('_loading_game')

func _on_slot1_load_pressed() -> void:
	Statement.set_state_from_file(SLOT_FILES[1])
	call_deferred('_loading_game')

func _on_slot2_load_pressed() -> void:
	Statement.set_state_from_file(SLOT_FILES[2])
	call_deferred('_loading_game')
	
func _on_slot3_load_pressed() -> void:
	Statement.set_state_from_file(SLOT_FILES[3])
	call_deferred('_loading_game')

func _on_autosave_save_pressed() -> void:
	Statement.save_state_to_file(SLOT_FILES[0])
	call_deferred('_toggle_save_or_load', false)

func _on_slot1_save_pressed() -> void:
	Statement.save_state_to_file(SLOT_FILES[1])
	call_deferred('_toggle_save_or_load', false)

func _on_slot2_save_pressed() -> void:
	Statement.save_state_to_file(SLOT_FILES[2])
	call_deferred('_toggle_save_or_load', false)

func _on_slot3_save_pressed() -> void:
	Statement.save_state_to_file(SLOT_FILES[3])
	call_deferred('_toggle_save_or_load', false)
