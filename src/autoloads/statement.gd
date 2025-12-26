extends Node

## Enumerate time phases information
enum TIME { MORNING, NOON, DUSK, EVENING }

const AUTOSAVE_FILE := 'user://autosave.sav'

#region ____Game Statement____
# Currency format in the game
var currency_format := '$'
# Amount of the currency in the game
var currency:
	set(amount):
		if typeof(amount) != TYPE_INT:
			push_error(amount + ' Currency amount must be int')
			return
		
		currency = Marshalls.utf8_to_base64(str(amount))
	get:
		return currency_format + Marshalls.base64_to_utf8(currency) if currency != null else '0'

# Current in-game day counter
var day := 1
# Current time-of-day phase
var time := TIME.MORNING
# A wildcard state for the story-progression or any utilities required
var wildcards := -1
# Remaining action points in the current time phase
var action_point: int = 3
# Maximum action points in the game
var max_action_points := 3
# Inventories collections
var inventories := {}
# Custom data statment game
var custom_data := {}
#endregion

#region ____Utilities methods____
## Adding the amount number of the currency
##
## @param value: Number of the amount value of the currency that will be add
func add_currency_amount(value: int) -> void:
	currency = int(currency.replace(currency_format, '')) + value

## Spend the amount number of the currency
##
## @param value: Number of the amount value of the currency that will be spent
func spend_currency_amount(value: int) -> void:
	currency = int(currency.replace(currency_format, '')) - value

func get_raw_currency() -> int:
	return int(currency.replace(currency_format, ''))

## Spend one action point. When points hit 0, advance to the next time phase.
##
## @param is_force: Optional value that will force to spent all the action points
func spend_action(is_force := false) -> void:
	action_point -= 1 if not is_force else max_action_points
	if action_point < 1: advance_time()

## Advance to the next time phase, reset action points. When wrapping to MORNING, increment day.
func advance_time() -> void:
	time         = (time + 1) % TIME.size()
	action_point = max_action_points
	wildcards    = -1
	
	if time == TIME.MORNING: day += 1

## Return the time and translate as a string
##
## @return: Variant value either string or null
func get_time_str() -> Variant:
	match time:
		TIME.MORNING: return 'morning'
		TIME.NOON   : return 'noon'
		TIME.DUSK   : return 'dusk'
		TIME.EVENING: return 'evening'
	return null

func save_state_to_file(file: String, additional := {}) -> void:
	var collections = {
		'currency'         : currency,
		'day'              : day,
		'time'             : time,
		'max_action_points': max_action_points,
		'custom_data'      : custom_data
	}
	var json = JSON.stringify(collections)
	Utils.write_file(file, json)

func autosave() -> void:
	save_state_to_file('user://autosave.sav')

func set_state_from_file(file: String) -> void:
	var json = Utils.json_parse(file)
	
	if not json.is_empty():
		currency          = json.get('currency', currency)
		day               = json.get('day', day)
		time              = json.get('time', time)
		max_action_points = json.get('max_action_points', max_action_points)
		custom_data       = json.get('custom_data', custom_data)
		wildcards         = 999
#endregion
