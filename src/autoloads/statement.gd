extends Node

## Enumerate time phases information
enum TIME { MORNING, NOON, DUSK, EVENING }

const AUTOSAVE_FILE := 'user://autosave.sav'

#region ____Game Statement____
# Amount of the currency in the game
var _currency: String

# Current in-game day counter
var _day: int = 0

# Current time-of-day phase
var _time: TIME = TIME.NOON

# A wildcard state for the story-progression or any utilities required
var _wildcards := -1

# Remaining action points in the current time phase
var _action_point: int = 3

# Maximum action points in the game
var _max_action_points := 3

var _custom_data := {}
#endregion

#region ---- CURRENCY, TIME & ACTIONS ----
func set_currency_amount(value: int) -> void:
	_currency = Marshalls.utf8_to_base64(str(value))

func get_currency_amount() -> int:
	return int(Marshalls.base64_to_utf8(_currency))

func add_currency_amount(value: int) -> void:
	var original_currency = int(Marshalls.base64_to_utf8(_currency)) if _currency != null else 0
	set_currency_amount(original_currency + value)

## Spend one action point. When points hit 0, advance to the next time phase.
func spend_action(is_force := false) -> void:
	_action_point -= 1 if not is_force else _max_action_points
	
	if _action_point < 1:
		advance_time()

## Advance to the next time phase, reset action points. When wrapping to MORNING, increment day.
func advance_time() -> void:
	_time         = (_time + 1) % TIME.size()
	_action_point = _max_action_points
	_wildcards    = -1
	
	if _time == TIME.MORNING:
		_day += 1

## Return the time and translate as a string
func get_time_str() -> String:
	match get_time():
		TIME.MORNING: return 'morning'
		TIME.NOON: return 'noon'
		TIME.DUSK: return 'dusk'
		TIME.EVENING: return 'evening'
	return ''

func get_time() -> TIME:
	return _time

func get_day() -> int:
	return _day
#endregion

func set_wildcards(value: int) -> void:
	_wildcards = value

func get_wildcards() -> int:
	return _wildcards

func set_custom_data(index: String, value: Variant) -> void:
	_custom_data.set(index, value)

func get_custom_data() -> Dictionary:
	return _custom_data

func save_state_to_file(file: String, additional := {}) -> void:
	var collections = {
		'currency'         : _currency,
		'day'              : _day,
		'time'             : _time,
		'max_action_points': _max_action_points,
	}
	var json = JSON.stringify(collections)
	Utils.write_file(file, json)

func autosave() -> void:
	save_state_to_file('user://autosave.sav')

func set_state_from_file(file: String) -> void:
	var json = Utils.json_parse(file)
	
	if not json.is_empty():
		_currency          = json.get('currency', _currency)
		_day               = json.get('day', _day)
		_time              = json.get('time', _time)
		_max_action_points = json.get('max_action_points', _max_action_points)
		_wildcards         = 999
