extends Control
class_name ScrollAndClickToggleController

@export var max_accumulation := 4.5
@export var label: Label
@export var inactive_text_label := 'Auto Off'
@export var active_text_label := 'Auto On\n Scroll Up/Down'

var _is_mouse_inside := false
var _is_active := false
var _accumulation := 1.0
var _amplitude := 1.25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	label.text = active_text_label if _is_active else inactive_text_label

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and _is_mouse_inside:
		_amplitude = 1.25 * _accumulation
		
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_is_active = !_is_active
		
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and _is_active:
			if _accumulation < max_accumulation: _accumulation += .01
		
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and _is_active:
			if _accumulation > 1.0: _accumulation -= .01

func _on_mouse_entered() -> void:
	_is_mouse_inside = true

func _on_mouse_exited() -> void:
	_is_mouse_inside = false

func is_active() -> bool:
	return _is_active

func is_mouse_inside() -> bool:
	return _is_mouse_inside

func get_accumulation() -> float:
	return _accumulation

func get_amplitude() -> float:
	return _amplitude
