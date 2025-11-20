extends Node

#region ____ Delay Sections ____
## This function creates a timer that will call its callback after the specified time in seconds.
func delay(value: float) -> SceneTreeTimer:
	return get_tree().create_timer(value)

## This function creates a timer that will call its callback after a random time between seconds.
func delay_range(min_value: float, max_value: float) -> SceneTreeTimer:
	return delay(randf_range(min_value, max_value))
#endregion

#region ____ Subscription-Broadcast ____
var _collection_physics: Dictionary
var _collection_idle: Dictionary

# A simple method to craete a default value of the subscribing
func _default(target: Object, prop: String) -> Dictionary:
	return {
		prop: {
			'value': target.get(prop),
			'callback': []
		}
	}

# A method to create the loop back of the transmitter subscribing properties
func _loopback(d: Dictionary) -> Dictionary:
	# iterate the collection physics and the properties, if the value is match with current and previous then callback
	for n in d:
		var _node = d[n]
		
		for p in _node:
			var _current = n.get(p)
			var _prevs   = _node[p].value
			
			# check if current and previous is mis-match then the value is changed and callback is called
			if _current != _prevs:
				if 'callback' in _node[p]:
					for c: Callable in _node[p].callback:
						c.call(_current)
				d[n][p].value = _current
	
	return d

## A method to set the broadcast based on idle process
func set_broadcast_idle(target: Object, prop: String) -> void:
	# set the default data
	if target in _collection_idle and !_collection_idle[target].is_empty():
		_collection_idle[target].merge(_default(target, prop))
		return
	_collection_idle[target] = _default(target, prop)
	
## A method to set the broadcast based on physics process
func set_broadcast_physics(target: Object, prop: String) -> void:
	# set the default data
	if target in _collection_physics and !_collection_physics[target].is_empty():
		_collection_physics[target].merge(_default(target, prop))
		return
	_collection_physics[target] = _default(target, prop)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_d: float) -> void:
	_collection_idle = _loopback(_collection_idle)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_d: float) -> void:
	_collection_physics = _loopback(_collection_physics)

## A callback method to get the subscribing value transmitter based on physics process
func subscribe_physics(target: Object, prop: String, method: Callable) -> void:
	if method not in _collection_physics[target][prop].callback:
		_collection_physics[target][prop].callback.append(method)

## A callback method to get the subscribing value transmitter based on idle process
func subscribe_idle(target: Object, prop: String, method: Callable) -> void:
	if method not in _collection_idle[target][prop].callback:
		_collection_idle[target][prop].callback.append(method)

func clear_broadcast(target: Object) -> void:
	_collection_idle.erase(target)
	_collection_physics.erase(target)
#endregion
