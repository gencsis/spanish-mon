class_name HUD
extends CanvasLayer



@onready var slot_bg: Array[TextureRect] = [
	$Root/InventoryGrid/Slot1/Inventory1,
	$Root/InventoryGrid/Slot2/Inventory2,
	$Root/InventoryGrid/Slot3/Inventory3,
]

@onready var slot_icons: Array[TextureRect] = [
	$Root/InventoryGrid/Slot1/Item1,
	$Root/InventoryGrid/Slot2/Item2,
	$Root/InventoryGrid/Slot3/Item3,
]

@onready var heart_icons: Array[TextureRect] = [
	$Root/InventoryGrid/Slot1/Heart1,
	$Root/InventoryGrid/Slot2/Heart2,
	$Root/InventoryGrid/Slot3/Heart3,
]

@onready var slot_highlights: Array[TextureRect] = [
	$Root/InventoryGrid/Slot1/H_Inventory1,
	$Root/InventoryGrid/Slot2/H_Inventory2,
	$Root/InventoryGrid/Slot3/H_Inventory3,
]


@onready var sfx_gainHeart = $sfx_gainHeart
@onready var eat_word: TypingChoice2D = $Root/EatWord

const WORM_ICON = preload("res://Assets/UI/worm-inventory.png")
const EMPTY_SLOT = preload("res://Assets/UI/single_inventory.png") 

const FULL_HEART  = preload("res://Assets/UI/hearts_one1.png")
const EMPTY_HEART = preload("res://Assets/UI/hearts_one2.png")  

var bag_open: bool = false
var selected_slot: int = 0

var max_hearts: int = 3
var current_hearts: int = 2

var slot_items: Array[String] = ["", "", ""]

func add_item_to_inventory(item_id: String) -> bool:
	for i in range(slot_items.size()):
		if slot_items[i] == "":
			slot_items[i] = item_id
			match item_id:
				"worm":
					slot_icons[i].texture = WORM_ICON
				_:
					print("Unknown item id:", item_id)
					slot_icons[i].texture = null
			return true
	print("Inventory full, could not add:", item_id)
	return false

func _ready() -> void:
	set_hearts(current_hearts)
	
	for i in range(slot_bg.size()):
		slot_bg[i].texture = EMPTY_SLOT
		
	for i in range(slot_icons.size()):
		slot_icons[i].texture = null
		
	for h in slot_highlights:
		h.visible = false

	eat_word.visible = false
	eat_word.choice_completed.connect(_on_eat_word_completed)
	
func set_hearts(count: int) -> void:
	current_hearts = clamp(count, 0, max_hearts)
	for i in range(heart_icons.size()):
		if i < current_hearts:
			heart_icons[i].texture = FULL_HEART
		else:
			heart_icons[i].texture = EMPTY_HEART
			
func increase_hearts(amount: int) -> void:
	set_hearts(current_hearts + amount)
	sfx_gainHeart.play()

func _unhandled_input(event: InputEvent) -> void:
	# Open/use bag with Z
	if event.is_action_pressed("bag"):
		if bag_open:
			_close_bag()
		else:
			_open_bag()
		get_viewport().set_input_as_handled()
		return

	if not bag_open:
		return

	# when bag is open
	if event.is_action_pressed("ui_left"):
		_move_selection(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
		_move_selection(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		_close_bag()
		get_viewport().set_input_as_handled()

func _open_bag() -> void:
	bag_open = true
	selected_slot = 0
	for i in range(slot_items.size()):
		if slot_items[i] != "":
			selected_slot = i
			break

	_update_slot_highlight()
	_update_eat_prompt()
	print("Bag opened")


func _close_bag() -> void:
	bag_open = false
	_clear_slot_highlight()
	eat_word.visible = false
	eat_word.stop_choices()
	print("Bag closed")


func _move_selection(direction: int) -> void:
	var count := slot_items.size()
	selected_slot = (selected_slot + direction + count) % count
	_update_slot_highlight()
	_update_eat_prompt()


func _update_slot_highlight() -> void:
	for i in range(slot_highlights.size()):
		slot_highlights[i].visible = bag_open and i == selected_slot

func _clear_slot_highlight() -> void:
	for h in slot_highlights:
		h.visible = false

func _activate_selected_slot() -> void:
	var item_id := slot_items[selected_slot]
	if item_id == "":
		print("No item in selected slot")
		_close_bag()
		return
		
	match item_id:
		"worm":
			_eat_worm_at_slot(selected_slot)
		_:
			print("Unknown item:", item_id)
	_close_bag()


func _eat_worm_at_slot(slot: int) -> void:
	slot_items[slot] = ""
	slot_icons[slot].texture = null
	increase_hearts(1)
	print("Ate worm from slot", slot)

func _update_eat_prompt() -> void:
	if not bag_open:
		eat_word.visible = false
		eat_word.stop_choices()
		return
		
	if selected_slot >= 0 and selected_slot < slot_items.size():
		if slot_items[selected_slot] == "worm":
			eat_word.set_word("eat")
			eat_word.visible = true
			eat_word.start_choices()
		else:
			eat_word.visible = false
			eat_word.stop_choices()

func _on_eat_word_completed(index: int, word: String) -> void:
	if not bag_open:
		return
	if word.to_lower() != "eat":
		return

	if selected_slot >= 0 and selected_slot < slot_items.size():
		if slot_items[selected_slot] == "worm":
			_eat_worm_at_slot(selected_slot)
	_close_bag()
