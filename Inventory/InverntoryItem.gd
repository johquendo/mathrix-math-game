class_name InventoryItem
extends TextureRect

# Only left-click signal
signal left_click_used(item)

@export var data: ItemData
@export var stack_count: int = 1
var description_popup: PopupPanel = null
var hover_timer: Timer = null
var stack_label: Label = null

func init(d: ItemData, count: int = 1) -> void:
	data = d
	stack_count = count

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	if not data:
		push_error("InventoryItem created without data!")
		return
		
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture = data.texture
	
	# Create stack count label
	stack_label = Label.new()
	stack_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	stack_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	stack_label.add_theme_color_override("font_color", Color.WHITE)
	stack_label.add_theme_font_size_override("font_size", 14)
	stack_label.add_theme_constant_override("margin_right", 4)
	stack_label.add_theme_constant_override("margin_bottom", 4)
	add_child(stack_label)
	
	update_stack_display()
	
	# Enable mouse detection
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Create hover timer
	hover_timer = Timer.new()
	hover_timer.one_shot = true
	add_child(hover_timer)
	# Use call_deferred to connect safely
	call_deferred("_connect_timer_signals")

func _connect_timer_signals():
	if is_instance_valid(hover_timer):
		if not hover_timer.timeout.is_connected(_show_popup):
			hover_timer.timeout.connect(_show_popup)

func update_stack_count(count: int) -> void:
	if not is_instance_valid(self):
		return
	stack_count = count
	update_stack_display()

func update_stack_display() -> void:
	if not is_instance_valid(self) or not stack_label:
		return
		
	if stack_count > 1 and data and data.stackable:
		stack_label.text = str(stack_count)
		stack_label.show()
	else:
		stack_label.hide()

func _on_mouse_entered():
	if not is_instance_valid(self) or not hover_timer:
		return
	hover_timer.start(0.5)

func _on_mouse_exited():
	if not is_instance_valid(self) or not hover_timer:
		return
	hover_timer.stop()
	if description_popup and is_instance_valid(description_popup) and description_popup.visible:
		description_popup.hide()

func _show_popup():
	if not is_instance_valid(self) or not data:
		return
	
	if not description_popup or not is_instance_valid(description_popup):
		description_popup = PopupPanel.new()
		description_popup.size = Vector2(300, 150)
		
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_right", 10)
		margin.add_theme_constant_override("margin_top", 10)
		margin.add_theme_constant_override("margin_bottom", 10)
		description_popup.add_child(margin)
		
		var vbox = VBoxContainer.new()
		margin.add_child(vbox)
		
		var title_label = Label.new()
		title_label.text = data.name
		title_label.add_theme_font_size_override("font_size", 16)
		
		match data.type:
			ItemData.Type.COMMON:
				title_label.add_theme_color_override("font_color", Color.WHITE)
			ItemData.Type.UNCOMMON:
				title_label.add_theme_color_override("font_color", Color.GREEN)
			ItemData.Type.RARE:
				title_label.add_theme_color_override("font_color", Color.BLUE)
		
		vbox.add_child(title_label)
		
		var desc_label = Label.new()
		desc_label.text = data.description
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		desc_label.add_theme_font_size_override("font_size", 14)
		vbox.add_child(desc_label)
		
		if data.stackable:
			var stack_info = Label.new()
			stack_info.text = "Stack: " + str(stack_count) + "/" + str(data.max_stack_size)
			stack_info.add_theme_font_size_override("font_size", 12)
			vbox.add_child(stack_info)
		
		add_child(description_popup)
	
	var mouse_pos = get_global_mouse_position()
	if is_instance_valid(description_popup):
		description_popup.position = Vector2(mouse_pos.x + 20, mouse_pos.y + 20)
		description_popup.popup()

# LEFT-CLICK FUNCTIONALITY ONLY
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Left-click detected on InventoryItem!")
			left_click_used.emit(self)
			accept_event()

func _get_drag_data(at_position: Vector2):
	if not is_instance_valid(self):
		return null
	set_drag_preview(make_drag_preview(at_position))
	return self

func make_drag_preview(at_position: Vector2):
	if not is_instance_valid(self):
		return null
		
	var t := TextureRect.new()
	t.texture = texture
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = size/2
	t.modulate.a = 0.5
	t.position = Vector2(-at_position)
	
	if data and data.stackable and stack_count > 1:
		var count_label = Label.new()
		count_label.text = str(stack_count)
		count_label.add_theme_color_override("font_color", Color.WHITE)
		count_label.add_theme_font_size_override("font_size", 12)
		count_label.position = Vector2(t.custom_minimum_size.x - 20, t.custom_minimum_size.y - 20)
		t.add_child(count_label)
	
	return t

func _exit_tree():
	# Disconnect mouse signals
	if mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.disconnect(_on_mouse_entered)
	if mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.disconnect(_on_mouse_exited)
	
	# Disconnect timer signals safely
	if hover_timer and is_instance_valid(hover_timer):
		hover_timer.stop()
		if hover_timer.timeout.is_connected(_show_popup):
			hover_timer.timeout.disconnect(_show_popup)
		
	if description_popup and is_instance_valid(description_popup):
		description_popup.queue_free()
