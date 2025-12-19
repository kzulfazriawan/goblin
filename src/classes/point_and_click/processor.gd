extends PointAndClickPersistenceClass
class_name PointAndClickProcessorClass

var _load_occupied := false
var _load_image2D: Resource
var _textured := false
var _activation_occupied := false

func _eval_register_area(collections: Dictionary, target: Node2D, prefix: String) -> void:
	for i in collections:
		var area: Area2D = point_and_click.get_node(collections.get(i))
		var name: String = i.to_lower()
		
		if area.get_class() != 'Area2D': continue
		
		set_area_clicked(prefix + name, area, [Callable(target, name)])

func eval_traversal_area(collections: Dictionary, target: Node2D) -> void:
	_eval_register_area(collections, target, PointAndClick.PREFIX.TRAVERSAL)

func eval_interaction_area(collections: Dictionary, target: Node2D) -> void:
	_eval_register_area(collections, target, PointAndClick.PREFIX.INTERACTION)

func activation_area_by_prefix(activate: bool, prefix: String) -> void:
	var lists := []
	
	for i:String in _areas_clicked:
		if not i.contains(prefix): continue
		lists.append(_areas_clicked.get(i))
	
	for i: Area2D in lists:
		i.set_meta('pnc_active', activate)
		call_deferred('_activation_area', i)

func _resource_compare_or_load(comparer: Resource) -> bool:
	if not _load_occupied:
		_load_image2D = comparer
		
	if _load_image2D != comparer:
		return false
	return true

func textured_by_time() -> void:
	var resource_comparer: bool
	
	match Statement.time:
		Statement.TIME.MORNING:
			resource_comparer = _resource_compare_or_load(load(point_and_click.morning_background))
		Statement.TIME.NOON:
			resource_comparer = _resource_compare_or_load(load(point_and_click.noon_background))
		Statement.TIME.DUSK:
			resource_comparer = _resource_compare_or_load(load(point_and_click.dusk_background))
		Statement.TIME.EVENING:
			resource_comparer = _resource_compare_or_load(load(point_and_click.evening_background))
		
	if not resource_comparer:
		_load_occupied = false
		return
	
	if not _load_occupied:
		point_and_click.texture = _load_image2D
		_load_occupied = true

func _eval_activation_area(lists: Array) -> void:
	activation_area_by_prefix(false, PointAndClick.PREFIX.INTERACTION)
	
	for i in lists:
		i.set_meta('pnc_active', true)
		call_deferred('_activation_area', i)

func set_activation_occupied(value: bool):
	_activation_occupied = value

func get_activation_occupied() -> bool:
	return _activation_occupied

func activation_by_time() -> void:
	match Statement.time:
		Statement.TIME.MORNING: _eval_activation_area(point_and_click.active_on_morning)
		Statement.TIME.NOON   : _eval_activation_area(point_and_click.active_on_noon)
		Statement.TIME.DUSK   : _eval_activation_area(point_and_click.active_on_dusk)
		Statement.TIME.EVENING: _eval_activation_area(point_and_click.active_on_evening)
