extends PersistenceClass
class_name DialoguePersistenceClass

## Variable reference of the main node dialogue as Dialogue
var dialogue: Dialogue:
	set(node):
		dialogue = node
		persist  = dialogue

## Variable reference of the main node of the logs textarea as RichTextLabel
var log_textarea: RichTextLabel

## Variable reference of the main node of the active label name as Label
var active_label: Label

## Variable reference of the main node of the primary label name as Label
var primary_label: Label

var texture_sprites: TextureRect

## Variable reference animation time interval in seconds float
var time: float

## Variable logs data of the dialogue such as text strings or callable
var logs: Array[Variant]

## Variable names data of the dialogue that will be appear in the dialogue
var names: Dictionary

## Variable sprite data of the dialogue that will be appear in the dialogue
var sprites := {}

# Private variable to store cache of line value                                     
var _line := 0

## Variable line logs from the current dialogue
var line:
	# Set the variable row of the line in dialogue
	set(value):
		if typeof(value) != TYPE_INT:
			push_error('Variable line is only accepting integer as `set` value')
			return
			
		if value < 0:
			return
		
		_line = value
	# Return the variable of the line in dialogue
	get:
		var result = logs[_line] if _line < logs.size() else ''
		return result

## Method to skip the row line into position
func skip(value: int) -> void:
	line = _line + value

# Tween variable that will utilities for the animation the logs textarea
var _tween: Tween

## Animate the property tween
func tween_animation(node: Control, properties: String, value: Variant, timing: float, callback = null) -> void:
	_tween = dialogue.get_tree().create_tween()
	_tween.set_parallel(true)
	
	if (callback != null and typeof(callback) == TYPE_CALLABLE) and not _tween.finished.is_connected(callback):
		_tween.finished.connect(callback)
	
	_tween.tween_property(node, properties, value, timing)

## Return the tween variable
func get_tween_text_running() -> Tween:
	tween_animation(log_textarea, 'visible_ratio', 1, time)
	return get_tween()

func get_tween() -> Tween:
	return _tween

# A cached histories of the dialogue in current scenes
var _histories := []

func clear_histories_and_logs() -> void:
	_histories = []
	logs       = []

func add_history_line(value: String) -> void:
	if value == '': return
	
	if not value.contains(':'):
		_histories.append(value)
	else:
		var parse = value.split(':')
		_histories.append('[b]{name}[/b]: {dialogue}'.format({
			'name': '[color=#505050]' + names[parse[0]] + '[/color]',
			'dialogue': parse[1]
		}))

## Get the lists of histories in the dialogue
func get_histories(as_rich_text := false):
	if _histories != null and typeof(_histories) == TYPE_ARRAY:
		if not as_rich_text: return _histories
		
		var result := ''
		for text in _histories:
			result += text + '\n'
		return result

## An accessor method to read the instance of the class
func is_instanceof(cls_name: String) -> bool:
	return cls_name == 'Dialogue'

func get_pos() -> int:
	return _line
