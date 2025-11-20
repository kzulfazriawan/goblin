extends PersistenceClass
class_name PointAndClickPersistenceClass

var point_and_click: PointAndClick:
	set(node):
		point_and_click = node
		persist         = point_and_click

# Cached collection of the area that can be clicked
var _areas_clicked := {}

func _activation_area(area: Area2D):
	if not area.has_meta('pnc_active'): return
	
	# Set the collision based on the meta
	for collision:CollisionShape2D in area.get_children():
		collision.disabled = !area.get_meta('pnc_active')
		
	area.visible = area.get_meta('pnc_active')
	return area

func set_area_clicked(name: String, area: Area2D, callables: Array[Callable] = []) -> void:
	# Click event
	if not callables.is_empty():
		area.input_event.connect(
			func (viewport: Node, event: InputEvent, shape_idx: int):
				if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
					for callable in callables: callable.call_deferred()
		)
	
	# By default all the collision will be disabled and visibility will be hidden
	area.set_meta('pnc_active', false)
	
	# Register into cache
	_areas_clicked[name] = _activation_area(area)

func get_area_clicked(name: String) -> Area2D:
	return _areas_clicked[name]
