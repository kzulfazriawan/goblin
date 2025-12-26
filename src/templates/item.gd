extends Item

@export var name_label: Label
@export var icon_rect: TextureRect
@export var price_label: Label
@export var quantity_label: Label
@export var inventory: Inventory

var _icon: TextureRect
var _name: Label
var _quantity: Label

#region ____Engine Lifecycles____
func _init() -> void:
	processor = Processor.new(self)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	processor.uid         = uid
	processor.name        = item_name
	processor.price       = price
	processor.quantity    = quantity
	processor.description = description
	processor.icon        = load(icon)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if processor != null:
		icon_rect.texture   = processor.icon
		name_label.text     = processor.name
		price_label.text    = '$ %d' % processor.price
		quantity_label.text = str(processor.quantity)
#endregion

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		inventory.select.emit($'.')
