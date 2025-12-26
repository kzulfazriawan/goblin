extends Control
class_name Inventory

signal select(node: Item)

@export_dir var items_path: String
@export var player_inventory := false
@export var wrapper_lists: Container
@export var icon_detail: TextureRect
@export var name_detail: Label
@export var price_detail: Label
@export var description_detail: Label
@export var panel_detail: Panel
@export var button_action: Button

var _selected: Item

func _ready() -> void:
	Statement.add_currency_amount(100)

func uid_filter(uid: String, n: int, price: int) -> bool:
	if n < 0:
		var found := false
		
		for i in Statement.inventories:
			if i == uid:
				found = true
				var qty = Statement.inventories.get(i, 0)
				
				if qty < abs(n):
					return false
			
		if not found:
			return false
	
	if n > 0:
		return Statement.get_raw_currency() >= price * abs(n)
		
	return n != 0

func trade(uid: String, n: int, price: int) -> void:
	var items := Statement.inventories
	
	if uid_filter(uid, n, price):
		var found := false
		
		for i in items:
			if uid == i:
				var qty = Statement.inventories.get(i, 0)
				Statement.inventories.set(i, qty + n)
				found = true
				
				if Statement.inventories[i] <= 0:
					Statement.inventories.erase(i)
				break
		
		if not found:
			Statement.inventories.set(uid, n)
			
		Statement.call(
			'add_currency_amount' if n < 0 else 'spend_currency_amount', price * abs(n)
		)

func buy(item: Item, n: int) -> void:
	trade(item.processor.uid, n, item.processor.price)

func sell(item: Item, n: int) -> void:
	trade(item.processor.uid, -n, item.processor.price)

func _items_filter(instance: Item, all := false) -> Variant:
	if not all:
		for i in Statement.inventories:
			if i == instance.processor.uid: return instance
		return null
	else:
		instance.processor.add(99)
		return instance

func _on_visibility_changed() -> void:
	# everytime visibility change reset
	for child in wrapper_lists.get_children():
		child.queue_free()
	
	if visible:
		for i in DirAccess.get_files_at(items_path):
			var file := '/'.join([items_path, i])
			var load := load(file)
			var instance = _items_filter(load.instantiate(), !player_inventory)
			
			if instance != null:
				instance.inventory = $'.'
				wrapper_lists.add_child(instance)
				
				if 'processor' in instance:
					instance.processor.view()

func _on_select(node: Item) -> void:
	_selected = node
	name_detail.text        = node.processor.name
	price_detail.text       = '%s %d' % [Statement.currency_format, node.processor.price]
	icon_detail.texture     = node.processor.icon
	description_detail.text = node.processor.description
	panel_detail.visible    = true
	button_action.text      = 'Buy' if not player_inventory else 'Use'

func _on_action_pressed() -> void:
	if not player_inventory:
		buy(_selected, 1)
