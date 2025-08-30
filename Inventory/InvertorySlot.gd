extends PanelContainer
class_name InventorySlot

@export var type: ItemData.Type
var current_item: InventoryItem = null
var stack_count: int = 0
var max_stack_size: int = 64

func init(t: ItemData.Type, cms: Vector2) -> void:
	type = t
	custom_minimum_size = cms
	mouse_filter = Control.MOUSE_FILTER_PASS

# ADD FUNCTION FOR LEFT-CLICK USAGE
func use_one_item():
	if stack_count <= 0 or current_item == null:
		return false
	
	print("Using one ", current_item.data.name)
	stack_count -= 1
	
	# If stack is empty, remove the item
	if stack_count <= 0:
		remove_item(1)
	else:
		update_stack_display()
	
	return true

func _can_drop_data(_at_position: Vector2, data) -> bool:
	if data is InventoryItem:
		var item_data = data.data
		# Prevent dropping on self
		if data == current_item:
			return false
			
		if type == ItemData.Type.COMMON or item_data.type == type:
			if current_item == null:
				return true
			elif can_stack_with(data):
				return stack_count + data.stack_count <= max_stack_size
	return false

func _drop_data(_at_position: Vector2, data) -> void:
	if not (data is InventoryItem):
		return
		
	# Prevent dropping on self
	if data == current_item:
		return
		
	var previous_parent = data.get_parent()
	var previous_slot = null
	
	# Safely get previous slot
	if previous_parent and previous_parent is InventorySlot and previous_parent != self:
		previous_slot = previous_parent
	
	# If slot is empty, add the item
	if current_item == null:
		# Remove from previous parent safely
		if is_instance_valid(data) and data.get_parent():
			data.get_parent().remove_child(data)
		
		add_child(data)
		current_item = data
		stack_count = data.stack_count
		data.position = Vector2.ZERO
		
		# Clear previous slot if it was different
		if previous_slot and is_instance_valid(previous_slot):
			previous_slot.current_item = null
			previous_slot.stack_count = 0
			
	# If slot has the same item, stack them
	elif can_stack_with(data):
		stack_count += data.stack_count
		update_stack_display()
		
		# Remove the dragged item safely
		if is_instance_valid(data):
			data.queue_free()
		
		# Clear previous slot if it was different
		if previous_slot and is_instance_valid(previous_slot):
			previous_slot.current_item = null
			previous_slot.stack_count = 0

func can_stack_with(item: InventoryItem) -> bool:
	return (current_item != null and 
			is_instance_valid(current_item) and
			current_item.data.id == item.data.id and 
			current_item.data.stackable)

func update_stack_display() -> void:
	if current_item and is_instance_valid(current_item):
		current_item.update_stack_count(stack_count)

func add_item(item: InventoryItem) -> bool:
	if not is_instance_valid(item):
		return false
		
	if current_item == null:
		add_child(item)
		current_item = item
		stack_count = item.stack_count
		item.position = Vector2.ZERO
		return true
	elif can_stack_with(item):
		stack_count += item.stack_count
		update_stack_display()
		if is_instance_valid(item):
			item.queue_free()
		return true
	return false

func remove_item(count: int = 1) -> void:
	if stack_count > count:
		stack_count -= count
		update_stack_display()
	else:
		stack_count = 0
		if current_item and is_instance_valid(current_item):
			current_item.queue_free()
		current_item = null

func _exit_tree():
	if current_item and is_instance_valid(current_item):
		current_item.queue_free()
	current_item = null
	stack_count = 0
