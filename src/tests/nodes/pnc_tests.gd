extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred('_switch_background', 'outside')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _switch_background(value: String) -> void:
	var activation := {
		'longue' : false,
		'outside': false
	}
	
	activation.set(value, true)
	
	$Camera2D/Longue.visible  = activation.longue
	$Camera2D/Outside.visible = activation.outside

func enter() -> void:
	_switch_background('longue')

func outside() -> void:
	_switch_background('outside')
