extends Node

## Logging utility for categorized console outputs.
## Provides formatted logging with levels: INFO, WARNING, and ERROR.
## Outputs are printed with color-coded BBCode for UI display and recorded for history access.

## Enumeration of log severity levels.
enum LEVEL {
	INFO,    ## General information logs
	ERROR,   ## Critical errors that disrupt flow
	WARNING  ## Non-critical issues that should be noted
}

## Template format for each log entry.
const FORMAT := '[{time}]{level} - {message}'

## Color codes for each log level in BBCode.
const COLORS := {
	LEVEL.INFO   : '#ffffff',
	LEVEL.ERROR  : '#f21b3f',
	LEVEL.WARNING: '#fcf300'
}

## Stores plain log history as strings.
var logs := []

## Stores formatted BBCode log entries (e.g., for RichTextLabel display).
var log_rich := []

## Temporary container for the current message being logged.
var _message := ''


## Internal method to construct and format log entries based on level.
##
## @param level: The log level (INFO, WARNING, ERROR)
## @return Dictionary with raw message and BBCode-formatted output.
func _get_log_message(level: LEVEL) -> Dictionary:
	var result := FORMAT.format({
		'time'   : Utils.timestamp(),
		'level'  : LEVEL.keys()[level],
		'message': _message.strip_edges()
	})

	var bbcode := '[color=%s]%s[/color]' % [COLORS[level], result]

	match level:
		LEVEL.INFO:
			print_rich(bbcode)

		LEVEL.WARNING:
			print_rich(bbcode)
			push_warning(_message)
			print_stack()

		LEVEL.ERROR:
			print_rich(bbcode)
			push_error(_message)
			print_stack()

	return {
		'msg': result,
		'bbcode': bbcode
	}


## Logs an informational message (white color).
##
## @param message: Text content to log.
func info(message: String) -> void:
	_message = message
	var response = _get_log_message(LEVEL.INFO)
	logs.append(response.msg)
	log_rich.append(response.bbcode)


## Logs a warning message (yellow color) and outputs a warning with stack trace.
##
## @param message: Text content to log.
func warning(message: String) -> void:
	_message = message
	var response = _get_log_message(LEVEL.WARNING)
	logs.append(response.msg)
	log_rich.append(response.bbcode)


## Logs an error message (red color) and outputs an error with stack trace.
##
## @param message: Text content to log.
func error(message: String) -> void:
	_message = message
	var response = _get_log_message(LEVEL.ERROR)
	logs.append(response.msg)
	log_rich.append(response.bbcode)


## Retrieves the BBCode-formatted log history.
##
## @return Array of BBCode log strings.
func get_log_rich() -> Array:
	return log_rich
