extends PersistenceClass
class_name ItemProcessorClass

enum CATEGORY{CONSUMABLE, EQUIPMENT, KEY_ITEM, OTHER}

var name: String

var quantity: int

var icon: Texture2D

var price: int

var category: CATEGORY

var callback: Callable

var description: String

func add(n: int) -> void:
	quantity += n

func spend(n: int) -> void:
	quantity -= n
