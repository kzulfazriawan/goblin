extends Dialogue

# Import Json file to the stories in the dialogue 
@export_file("*.json") var file_stories

var _sections := {}

#region ____Engine Lifecycles____
# Called when the node is constructed for the first time.
func _init() -> void:
	processor = Processor.new($'.')

# Called when the node enters node tree.
func _enter_tree() -> void:
	processor.connect_signals(input_active, input_deactive)
	Transmitter.set_broadcast_idle(processor, 'active_name')
	
	# Fail-safe of the overlay
	overlay.visible  = false
	overlay.modulate = Color(0, 0, 0, 0)

# Called when the node leaving the node tree.
func _exit_tree() -> void:
	Transmitter.clear_broadcast(processor)
	processor.disconnect_signals(input_active, input_deactive)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	processor.active_label  = active
	processor.primary_label = primary
	processor.log_textarea  = logs
	
	call_deferred('_attach_story')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if ProjectSettings.has_setting(TEXT_SPEED_CONFIG):
		processor.time = ProjectSettings.get_setting(TEXT_SPEED_CONFIG)
	
	if ProjectSettings.has_setting(BOX_OPACITY_CONFIG):
		panel.self_modulate = Color(1, 1, 1, ProjectSettings.get_setting(BOX_OPACITY_CONFIG))

# Called when any unahndled input from the key is triggered
func _input(event: InputEvent) -> void:
	var event_clicked = bool(event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
	var input_pressed = Input.is_action_just_pressed('ui_accept')
	
	if input_pressed or event_clicked:
		processor.next()
#endregion

#region ____Helper Utilities____
## A function when input is enabled
func input_active() -> void:
	processor.input_status = true

## A function when input is disabled
func input_deactive() -> void:
	processor.input_status = false

## Utilities method to start testing the dialogue module
func _attach_story() -> void:
	if file_stories != null:
		var parse = Utils.json_parse(file_stories)
		processor.names   = parse.get('names', {})
		processor.sprites = parse.get('sprites', {})
		
		for i in parse:
			if i not in['names', 'sprites']:
				_sections[i] = parse[i]
		
		if 'test' in parse:
			start.emit(0, get_sections('test'))

func get_sections(key: String) -> Array:
	return _sections[key]
#endregion

func _on_history_pressed() -> void:
	processor.history(!log_histories.visible)
