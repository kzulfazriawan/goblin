class_name PersistenceClass

## A simple constant to define the string of the persist groupname
const PERSIST = 'persist'

## Variable to define the node as persistence type to be read/save in state
var persist: Node:
	# Set the node as persistence type to be load/save in state 
	set(node):
		persist = node
		if not persist.is_in_group(PERSIST): persist.add_to_group(PERSIST)

## An abbreviation of Unique Identifier Node an custom unique name of the node
var uid: String:
	# Set the Unique Identifier to the variable
	set(value):
		uid = Marshalls.utf8_to_base64(value)
	# Return the Unique Identifier from the variable
	get:
		return Marshalls.base64_to_utf8(uid)

## Variable reference to identify the input status is disabled/enabled
var input_status: bool:
	# Set the input and unhandled input
	set(value):
		persist.set_process_input(value)
		persist.set_process_unhandled_input(value)
		input_status = value

## Variable reference to identify the physics_process status is disabled/enabled
var physics_status: bool:
	# Set the physics_process
	set(value):
		persist.set_physics_process(value)
		physics_status = value

# Variable reference to identify the process status is disabled/enabled
var idle_status: bool:
# Set the process
	set(value):
		persist.set_process(value)
		idle_status = value

## An accessor method to read the instance of the class
func is_instanceof(cls_name: String) -> bool:
	return cls_name == 'Persistence'
