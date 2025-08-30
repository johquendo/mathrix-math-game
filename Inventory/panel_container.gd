extends Node
class_name InventoryPanel

var InvSize = 16
var itemLoad = [
	"res://Inventory/itemsRes/rare.tres",
	"res://Inventory/itemsRes/uncommon.tres", 
	"res://Inventory/itemsRes/common.tres"
]

func _ready():
	# Create slots
	for i in InvSize:
		var slot := InventorySlot.new()
		slot.init(ItemData.Type.COMMON, Vector2(64, 64))
		%GridContainerINV.add_child(slot)
	
	# Add initial items
	for j in itemLoad.size():
		var item_data = load(itemLoad[j]) as ItemData
		if item_data:
			var item := InventoryItem.new()
			item.init(item_data)
			%GridContainerINV.get_child(j).add_child(item)
			%GridContainerINV.get_child(j).current_item = item
			%GridContainerINV.get_child(j).stack_count = item.stack_count
			# Connect left-click signal
			item.left_click_used.connect(_on_item_left_click_used)

func _process(_delta):
	# Toggle inventory visibility
	if Input.is_action_just_pressed("ui_accept"):
		self.visible = !self.visible

func _input(event):
	# Handle test item hotkeys
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			add_test_item("res://Inventory/itemsRes/common.tres")
		elif event.keycode == KEY_2:
			add_test_item("res://Inventory/itemsRes/uncommon.tres")
		elif event.keycode == KEY_3:
			add_test_item("res://Inventory/itemsRes/rare.tres")
		elif event.keycode == KEY_R:
			remove_test_item(0)

# Handle left-click usage
func _on_item_left_click_used(item: InventoryItem):
	var slot = item.get_parent()
	if slot is InventorySlot:
		slot.use_one_item()
		print("Used one item from stack")

func add_test_item(item_path: String):
	var item_data = load(item_path) as ItemData
	if not item_data:
		push_error("Failed to load item: " + item_path)
		return
	
	var item := InventoryItem.new()
	item.init(item_data)
	
	# Find available slot
	for i in range(%GridContainerINV.get_child_count()):
		var slot = %GridContainerINV.get_child(i)
		if slot is InventorySlot:
			if slot.current_item == null:
				if slot.add_item(item):
					# Connect the signal for new items
					item.left_click_used.connect(_on_item_left_click_used)
					print("Added ", item_data.name, " to slot ", i)
					return
			elif slot.can_stack_with(item):
				if slot.add_item(item):
					print("Stacked ", item_data.name, " in slot ", i)
					return
	
	print("No space for ", item_data.name)

func remove_test_item(slot_index: int):
	if slot_index >= %GridContainerINV.get_child_count():
		print("Slot index out of range")
		return
	
	var slot = %GridContainerINV.get_child(slot_index)
	if slot is InventorySlot:
		if slot.current_item:
			slot.remove_item(1)
			print("Removed item from slot ", slot_index)
		else:
			print("Slot ", slot_index, " is already empty")
	else:
		print("Not a valid slot at index ", slot_index)
