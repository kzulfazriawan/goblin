extends PointAndClick

var _time_activation: Statement.TIME

#region ____Engine Lifecycles____
# Called when the node is constructed for the first time.
func _init() -> void:
	processor = Processor.new($'.')

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	processor.connect_signals(input_active, input_deactive)
	processor.eval_traversal_area(interaction_traversal, target_callback)
	processor.eval_interaction_area(interaction_area, target_callback)
	
	if not visibility_changed.is_connected(_on_visibility_changed):
		visibility_changed.connect(_on_visibility_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if time_override:
		processor.textured_by_time()
		
		if _time_activation != Statement.time:
			processor.set_activation_occupied(false)
			_time_activation = Statement.time
			return
		
		if not processor.get_activation_occupied():
			processor.activation_by_time()
			processor.set_activation_occupied(true)
			return
#endregion

#region ____Helper Utilities____
## A function when input is enabled
func input_active() -> void:
	processor.input_status = true
	toggle.emit()

## A function when input is disabled
func input_deactive() -> void:
	processor.input_status = false
	toggle.emit()
#endregion

func _on_visibility_changed() -> void:
	if visible:
		enable_input.emit()
		if traversal_transit != null and not skip_transit:
			processor.traversal_transits(traversal_transit, true)
			return
		processor.traversal_in()
		return
	
	disable_input.emit()
	processor.traversal_out()
