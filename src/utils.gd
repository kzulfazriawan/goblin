extends Object
class_name Utils

## Utility class providing common static methods for file handling,
## string formatting, random generation, time retrieval, and environment detection.
#
## These functions are designed to support internal systems like
## console output formatting, file reading, and identifier generation.

const WINDOWS_ENV_HOSTNAME    := 'COMPUTERNAME'
const NONWINDOWS_ENV_HOSTNAME := 'HOSTNAME'

## Parses a JSON file and returns its contents as a Dictionary.
##
## @param file: The path to the JSON file.
## @return Dictionary if parsed successfully, otherwise null.
static func json_parse(file: String) -> Dictionary:
	Logging.info('[Utils.json_parse] Attempting to parse JSON from: ' + file)
	var load_file = Utils.load_file(file)
	var result = JSON.parse_string(load_file) if load_file != null else {}
	Logging.info('[Utils.json_parse] Parsing complete')
	return result

## Loads and returns the contents of a file as a UTF-8 string.
##
## @param filepath: Path to the file.
## @return File contents as String if found, otherwise null.
static func load_file(filepath: String) -> Variant:
	Logging.info('[Utils.load_file] Attempting to load file: ' + filepath)

	if FileAccess.file_exists(filepath):
		var file = FileAccess.open(filepath, FileAccess.READ)
		return file.get_as_text()

	Logging.error('[Utils.load_file] File not found: ' + filepath)
	return null

## Write the contents of a file and save it into the directory
##
## @param filepath: Path to the file.
## @param content: Content of the file.
## @return File contents as String if found, otherwise null.
static func write_file(filepath: String, content: String) -> Variant:
	Logging.info('[Utils.load_file] Attempting to write file: ' + filepath)
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	file.store_string(content)
	return load_file(filepath)

## Generates a random alphanumeric string of a given length.
##
## @param length: Length of the string to generate (default is 16).
## @return Randomly generated string.
static func generate_random_string(length: int = 16) -> String:
	var chars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var result := ""
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	for i in length:
		var index := rng.randi_range(0, chars.length() - 1)
		result += chars[index]

	return result


## Prepends a newline character to a string.
##
## @param data: The original string.
## @return Newline-prefixed string.
static func newline(data: String) -> String:
	return '\n' + data


## Retrieves the system hostname.
## - Uses 'COMPUTERNAME' on Windows.
## - Uses 'HOSTNAME' on non-Windows OS.
##
## @return Hostname string.
static func hostname() -> String:
	var env_key := WINDOWS_ENV_HOSTNAME if OS.has_feature("windows") else NONWINDOWS_ENV_HOSTNAME
	return OS.get_environment(env_key)


## Returns the current or overridden system time in 'YYYY/MM/DD HH:MM' format.
##
## @param y: Optional override for year.
## @param m: Optional override for month.
## @param d: Optional override for day.
## @param h: Optional override for hour.
## @param mi: Optional override for minute.
## @return Formatted timestamp as string.
static func timestamp(y: int = 0, m: int = 0, d: int = 0, h: int = 0, mi: int = 0) -> String:
	var time = Time.get_datetime_dict_from_system()
	return '%04d/%02d/%02d %02d:%02d' % [
		time.year if y < 1 else y,
		time.month if m < 1 else m,
		time.day if d < 1 else d,
		time.hour if h < 1 else h,
		time.minute if mi < 1 else mi
	]

func _blend_toward(delta: float, animation_node: AnimationTree, parameter: String, toward: float, speed: float) -> float:
	var blend_pos = animation_node[parameter]
	return move_toward(blend_pos, toward, speed * delta)

static func animation_tree_blend_toward_center(delta: float, animation_node: AnimationTree, parameter, speed: float) -> void:
	var utils = Utils.new()
	animation_node[parameter] = utils._blend_toward(delta, animation_node, parameter, 0.0, speed)

static func animation_tree_blend_toward_left(delta: float, animation_node: AnimationTree, parameter, speed: float) -> void:
	var utils = Utils.new()
	animation_node[parameter] = utils._blend_toward(delta, animation_node, parameter, -1.0, speed)

static func animation_tree_blend_toward_right(delta: float, animation_node: AnimationTree, parameter, speed: float) -> void:
	var utils = Utils.new()
	animation_node[parameter] = utils._blend_toward(delta, animation_node, parameter, 1.0, speed)


## Returns the number of spaces needed to pad a string to a given length.
##
## @param data: Original string.
## @param length: Desired total length.
## @return A string of spaces to make up the padding.
static func space_length(data: String, length: int) -> String:
	var space := ''
	for i in range(length - data.length()):
		space += ' '
	return space

static func clear_visibility_children(node: Node, unless: Variant) -> void:
	for item in node.get_children():
		item.visible = false if item != unless else true
