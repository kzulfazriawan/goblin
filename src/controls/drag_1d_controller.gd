extends Area2D
class_name Drag1DController

const CLICK_ACTION := 'clicked'
const ACCELERATION := 10.0

## Sensitivity calculated per pixel
@export var sensitivity := 300.0
@export var max_velocity := 5.0
@export_enum('X', 'Y') var axis := 'X'
@export var inverted := true
@export var capture_cursor := true

var _ready_to_interact := false
var _is_interacting := false
var _drag_force := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _ready_to_interact and Input.is_action_just_pressed(CLICK_ACTION):
		_is_interacting = true
	
	if _is_interacting:
		if Input.is_action_pressed(CLICK_ACTION):
			if capture_cursor: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			#before the signal is send it should be calculated the velocity with max left speed -5 and max right speed 5
			var mouse_velocity := Input.get_last_mouse_velocity()
			var normalized := mouse_velocity / sensitivity
			var axis_normalized := normalized.x if axis.to_lower() == 'x' else normalized.y
			var calculated_vel := clampf(
				axis_normalized if not inverted else -axis_normalized, -max_velocity, max_velocity
			)
			
			_drag_force = lerpf(_drag_force, calculated_vel, delta * ACCELERATION)
			
		elif Input.is_action_just_released(CLICK_ACTION):
			if capture_cursor: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			_is_interacting = false
			_ready_to_interact = false

func _on_mouse_entered() -> void:
	if not _is_interacting: _ready_to_interact = true

func _on_mouse_exited() -> void:
	if not _is_interacting: _ready_to_interact = false

func get_drag_force() -> float:
	return _drag_force

func is_interacting() -> bool:
	return _is_interacting

func is_ready_to_interact() -> bool:
	return _ready_to_interact
