extends Sprite2D
class_name PointAndClick

## Signal event to enable the input [PointAndClick]
signal enable_input
## Signal event to disable the input [PointAndClick]
signal disable_input
## Signal event to toggle the activation the area and collision
signal toggle

const PREFIX := {
	'TRAVERSAL': 'traversal_',
	'INTERACTION': 'interaction_'
}

@export_subgroup('Traversal')
@export var traversal_transit: Sprite2D
@export var skip_transit := false
@export_subgroup('Callback')
@export var interaction_area: Dictionary
@export var interaction_traversal: Dictionary
## Node references to target callback of the methods switch
@export var target_callback: Node2D
@export_group('Environment')
@export var time_override := false
@export_subgroup('Activation')
@export var active_on_morning: Array[Area2D]
@export var active_on_noon: Array[Area2D]
@export var active_on_dusk: Array[Area2D]
@export var active_on_evening: Array[Area2D]
@export_subgroup('Time')
@export_file('*.png', '*.jpg', '*.jpeg', '*.svg') var morning_background: String
@export_file('*.png', '*.jpg', '*.jpeg', '*.svg') var noon_background: String
@export_file('*.png', '*.jpg', '*.jpeg', '*.svg') var dusk_background: String
@export_file('*.png', '*.jpg', '*.jpeg', '*.svg') var evening_background: String

class Processor extends PointAndClickProcessorClass:
	var _tween: Tween
	
	func _init(node: PointAndClick) -> void:
		point_and_click = node
	
	# Method to activate/connect basic signal
	func connect_signals(enable: Callable, disable: Callable) -> void:
		if not point_and_click.enable_input.is_connected(enable): point_and_click.enable_input.connect(enable)
		if not point_and_click.disable_input.is_connected(disable): point_and_click.disable_input.connect(disable)
		if not point_and_click.toggle.is_connected(_on_toggle): point_and_click.toggle.connect(_on_toggle)
	
	# Method to deactivate/disconnect basic signal
	func disconnect_signals(enable: Callable, disable: Callable) -> void:
		if point_and_click.enable_input.is_connected(enable): point_and_click.enable_input.disconnect(enable)
		if point_and_click.disable_input.is_connected(disable): point_and_click.disable_input.disconnect(disable)
		if point_and_click.toggle.is_connected(_on_toggle): point_and_click.toggle.disconnect(_on_toggle)
	
	# Private function to activate all the area interaciton within the point and click node
	func _on_toggle() -> void:
		for i in PREFIX:
			activation_area_by_prefix(input_status, PREFIX.get(i))
		
		if input_status:
			call_deferred('activation_by_time')
	
	func traversal_effects(target: Node2D, fade_in := true, callback = null) -> void:
		if fade_in:
			if _tween: _tween.kill()
			
			await Transmitter.delay(.01).timeout
			_tween = point_and_click.get_tree().create_tween()
			if callback != null and typeof(callback) == TYPE_CALLABLE:
				_tween.finished.connect(callback)
			_tween.tween_property(target, 'modulate', Color.WHITE, .25)
		else:
			target.modulate = Color(1, 1, 1, 0)
			if callback != null and typeof(callback) == TYPE_CALLABLE:
				callback.call()
	
	func traversal_transits(transit: Node2D, is_in := true) -> void:
		if transit != null:
			transit.visible = true
			traversal_effects(
				transit,
				true,
				func():
					await Transmitter.delay(.5).timeout
					traversal_effects(transit, false, func():
						transit.visible = false
						if is_in:
							traversal_in()
							return
						traversal_out()
					)
	)
	
	func traversal_in() -> void:
		traversal_effects(point_and_click, true, func(): point_and_click.toggle.emit())
	
	func traversal_out() -> void:
		traversal_effects(point_and_click, false, func(): point_and_click.toggle.emit())

## Declare the processor here
var processor: Processor
