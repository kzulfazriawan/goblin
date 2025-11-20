extends Panel
class_name Loading

## Signal to start the loading
signal start(scene: PackedScene)

## Target of the loading scenes
@export var target: Node

# Private variable of the tween animation of the scenes
var _tween: Tween

var _instance: Node

func _ready() -> void:
	if not start.is_connected(_on_start):
		start.connect(_on_start)

# Method to start tween animation on starting the tween
func _start_tween(target_color: Color, duration: float, callback: Callable) -> void:
	# fail-safe tween animation to kill previous one before starting new one
	if _tween: _tween.kill()
	
	_tween = get_tree().create_tween()
	# fail-safe tween callback when finished by signal
	if callback and not _tween.finished.is_connected(callback): _tween.finished.connect(callback)
	_tween.tween_property($'.', 'modulate', target_color, duration)

# Method to show loading interface when transition scenes is on load progress
func _shown(state: bool) -> void:
	$'.'.visible = state
	
	if get_parent() != null: get_parent().visible = state

## Method to transitions start for faded in on loading
func fade_in(callback: Callable) -> void:
	_shown(true)
	_start_tween(Color.WHITE, 0.75, callback)

## Method to transitions start for faded out on loading
func fade_out(callback: Callable) -> void:
	_start_tween(Color(1, 1, 1, 0), 0.75, func():
		_shown(false)
		callback.call()
	)

# Utilities method to set the scenes based on the lists of the available scenes
func _set_scenes() -> void:
	if _instance is Control:
		_instance.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	if _instance:
		target.add_child(_instance)
	
	call_deferred('fade_out', func(): pass)

# Called when `start` signal is emitted
func _on_start(scene: PackedScene) -> void:
	_instance = scene.instantiate()
	
	for item: Node in target.get_children():
		item.call_deferred('queue_free')
		target.remove_child(item)
	
	fade_in(_set_scenes)

func get_instance() -> Node:
	return _instance
