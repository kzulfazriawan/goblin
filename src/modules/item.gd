extends Control
class_name Item

@export var uid: String
@export var item_name: String
@export_multiline var description: String
@export var price: int
@export var quantity: int
@export_file('*.png', '*.svg', '*.jpg', '*.jpeg') var icon: String

class Processor extends ItemProcessorClass:
	var _icon: TextureRect
	var _name: Label
	var _quantity: Label
	
	func _init(node: Item) -> void:
		persist = node
	
	func consume() -> void:
		spend(1)
		Statement.inventories[uid] = quantity
	
	func equip() -> void:
		spend(1)
	
	func view() -> void:
		var container := VBoxContainer.new()
		
		_name         = Label.new()
		_quantity     = Label.new()
		_icon         = TextureRect.new()
		_name.text    = name
		_icon.texture = icon
		
		container.add_child(_icon)
		container.add_child(_name)
		persist.add_child(_quantity)
		persist.add_child(container)
	
var processor: Processor

func get_classname() -> String:
	return 'Item'
