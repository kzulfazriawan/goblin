extends Control
class_name Dialogue

## Constant setting name of the text speed cofiguration
const TEXT_SPEED_CONFIG  := 'framework/configurations/dialogue/text_speed'
const BOX_OPACITY_CONFIG := 'framework/configurations/dialogue/box_opacity'

## Signal event to starting the [Dialogue] and start to reading line from the logs
signal start(on_line: int, data_logs: Array)
## Signal event when dialogue is finished (Connect it from the node that trigger the start)
signal finish
## Signal event to enable the input [Dialogue]
signal enable_input
## Signal event to disable the input [Dialogue]
signal disable_input

## Variable group name for the node [Actor3D]
@export var groupname: String = 'dialogue'
## Define the dialogue will hide along with it's parent
@export var with_parent := false
@export_subgroup('Nodes')
@export var overlay: Panel
## Node location of the  main panel [Dialogue]
@export var panel: Panel
## Node location path of the active [Label]
@export var active: Label
## Node location path of the primary [Label]
@export var primary: Label
## Node location path of the logs [RichTextLabel]
@export var logs: RichTextLabel
## Node location path of the history logs [RichTextLabel]
@export var log_histories: RichTextLabel
## Node location of the sprite rect [TextureRect]
@export var sprite_rect: TextureRect

## Processor class of the [Dialogues]
class Processor extends DialogueProcessorClass:
	func _init(node: Dialogue) -> void:
		dialogue = node
		time = ProjectSettings.get_setting(TEXT_SPEED_CONFIG) if ProjectSettings.has_setting(TEXT_SPEED_CONFIG) else 1
	
	# Method to activate/connect basic signal
	func connect_signals(enable: Callable, disable: Callable) -> void:
		if not dialogue.enable_input.is_connected(enable): dialogue.enable_input.connect(enable)
		if not dialogue.disable_input.is_connected(disable): dialogue.disable_input.connect(disable)
		if not dialogue.start.is_connected(_on_start): dialogue.start.connect(_on_start)
		if not dialogue.finish.is_connected(_on_finish): dialogue.finish.connect(_on_finish)
	
	# Method to deactivate/disconnect basic signal
	func disconnect_signals(enable: Callable, disable: Callable) -> void:
		if dialogue.enable_input.is_connected(enable): dialogue.enable_input.disconnect(enable)
		if dialogue.disable_input.is_connected(disable): dialogue.disable_input.disconnect(disable)
		if dialogue.start.is_connected(_on_start): dialogue.start.disconnect(_on_start)
		if dialogue.finish.is_connected(_on_finish): dialogue.finish.disconnect(_on_finish)
	
	## Method to hide all the labels in the dialogues such as active and primary [Label]
	func hide_labels() -> void:
		active_label.visible  = false
		primary_label.visible = false
	
	## Method to show and set the text of the active [Label]
	func set_active(v: String) -> void:
		active_label.text = v
		active_label.visible = true
		
	## Method to show and set the text of the primary [Label]
	func set_primary(v: String) -> void:
		primary_label.text = v
		primary_label.visible = true
	
	func set_sprite(v: Variant) -> void:
		if dialogue.sprite_rect != null:
			dialogue.sprite_rect.visible = bool(v != null)
			if v == null: return
			dialogue.sprite_rect.texture = v
	
	# A private method to connecting with signal emit with `start` signal
	func _on_start(on_line: int, data_logs: Array) -> void:
		if dialogue.with_parent and dialogue.get_parent() != null:
			dialogue.get_parent().visible = dialogue.visible
		
		if not data_logs.is_empty():
			logs = data_logs
		
		dialogue.visible = true
		# Set a line and next
		line = on_line
		next()
		# After all set, then enable the input
		dialogue.enable_input.emit()
	
	# A private method to connecting with signal emit with `finish` signal
	func _on_finish() -> void:
		# Reset the line and the nodes
		log_textarea.text  = ''
		active_label.text  = ''
		primary_label.text = ''
		
		line = -1
		
		# Disabled all input before anything.
		dialogue.disable_input.emit()
		dialogue.visible = false
		
		set_sprite(null)
		
		# Set the sprite as null to remove.		
		if dialogue.with_parent and dialogue.get_parent() != null:
			dialogue.get_parent().visible = dialogue.visible
		
		clear_histories_and_logs()

	## A method to read the next line of the logs data in set it into the textarea [RichTextLabel]
	func next() -> void:
		# check if tween exists and is running then force it to finishing the time
		if get_tween() != null and get_tween().is_running():
			get_tween().custom_step(time)
		
		else:
			if line is Array:
				parse_callables(line)
			
			else:
				# this will be processing the parsing log string, hide labels, and reset visible_ratio of the textarea
				var parse = parse_log_string(line)
				
				hide_labels()
				
				log_textarea.visible_ratio = 0
				log_textarea.text = parse.log
				
				if 'name' in parse:
					if parse.active:
						set_active(parse.name)
					else:
						set_primary(parse.name)
				
				set_sprite(active_sprite)
				
				get_tween_text_running()
			skip(1)
	
	func history(shown := false, transition_time := .5) -> void:
		if shown:
			dialogue.disable_input.emit()
		else:
			dialogue.enable_input.emit()
		
		var tween      = get_tween()
		var modulation = Color.WHITE if shown else Color(0, 0, 0, 0) 
		dialogue.overlay.visible = shown
		
		tween_animation(dialogue.overlay, 'modulate', modulation, transition_time, Callable(
			self, '_shown_history' if shown else '_close_history'
		))
	
	func _shown_history() -> void:
		dialogue.log_histories.visible = true
		dialogue.log_histories.text    = get_histories(true)
	
	func _close_history() -> void:
		dialogue.log_histories.text    = ''
		dialogue.log_histories.visible = false

## Declare the processor here
var processor: Processor
