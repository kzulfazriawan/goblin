extends DialoguePersistenceClass
class_name DialogueProcessorClass

## Reference variale of the current sprite/node in the dialogue
var active_sprite: Resource

## Variable reference to filter the name as active character in the current dialogue
var name_as_active_character: String

## Variable reference to get the current active name
var active_name: String

## Variable reference to get the current active log
var active_log: String

## Method to parse the log string in the dialogue
func parse_log_string(v: String) -> Dictionary:
	var result = {'log': v}
	
	if v.contains(':'):
		var split: Array[String] = []
		split.assign(v.split(':'))
		active_name   = split[0].strip_edges()
		active_log    = split[1].strip_edges()
		active_sprite = load(sprites[active_name]) if active_name in sprites else null
		
		result = {
			'log'   : active_log,
			'name'  : names[active_name],
			'active': bool(active_name == name_as_active_character)
		}
	
	add_history_line(v)
	return result

## Method to running the callables in the dialogue
func parse_callables(v: Array) -> void:
	for i in v:
		i.call()  
