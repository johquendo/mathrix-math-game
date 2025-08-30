extends Control

var is_dragging = false
var drag_offset = Vector2()
var is_resizing = false
var resize_start = Vector2()
var original_size = Vector2()
var original_position = Vector2()
var is_editing = false
var context_menu = null
var context_menu_visible = false
var resize_handle_size = 12

signal text_size_changed(text_instance)
signal edit_requested(text_instance)
signal edit_finished(text_instance)
signal delete_requested(text_instance)  # Add this signal

@onready var text_edit = $TextEdit
@onready var resize_handle = $ResizeHandle

func _ready():
	# Initial setup
	custom_minimum_size = Vector2(150, 30)
	size = Vector2(150, 30)

	# Setup TextEdit
	text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	text_edit.size = size

	# Set text color to black
	text_edit.add_theme_color_override("font_color", Color.BLACK)
	text_edit.add_theme_color_override("font_readonly_color", Color.DIM_GRAY)

	# Create a transparent background
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color.TRANSPARENT
	text_edit.add_theme_stylebox_override("normal", style_box)
	text_edit.add_theme_stylebox_override("focus", style_box)
	text_edit.add_theme_stylebox_override("read_only", style_box)

	# Setup resize handle
	resize_handle.size = Vector2(resize_handle_size, resize_handle_size)
	resize_handle.position = Vector2(size.x - resize_handle_size, size.y - resize_handle_size)
	resize_handle.color = Color.BLUE
	resize_handle.visible = false

	# Connect signals
	text_edit.text_changed.connect(_on_self_text_changed)
	text_edit.focus_exited.connect(_on_text_edit_focus_exited)
	resize_handle.gui_input.connect(_on_resize_handle_gui_input)
	text_edit.gui_input.connect(_on_text_edit_gui_input)

	# Make sure we can receive input but allow parent to control filtering
	mouse_filter = MOUSE_FILTER_PASS
	text_edit.mouse_filter = MOUSE_FILTER_PASS

	# Create context menu
	create_context_menu()

	# Initially not editable
	finish_editing()

func _on_self_text_changed():
	# Auto-resize height based on content
	emit_signal("text_size_changed", self)

func _on_text_edit_focus_exited():
	# When text edit loses focus, finish editing
	if is_editing:
		finish_editing()

func _gui_input(event):
	# Handle right-click for context menu
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if not is_editing:
				show_context_menu()
				get_viewport().set_input_as_handled()

func _on_text_edit_gui_input(event):
	if not is_editing:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Start dragging when clicking on text edit (but not on resize handle)
			var local_pos = event.position
			var resize_handle_rect = Rect2(resize_handle.position, resize_handle.size)

			if not resize_handle_rect.has_point(local_pos):
				is_dragging = true
				drag_offset = event.global_position - global_position
				get_viewport().set_input_as_handled()

		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			is_dragging = false

	if event is InputEventMouseMotion and is_dragging:
		var new_global_position = event.global_position - drag_offset

		# Constrain movement to canvas boundaries
		var constrained_position = _constrain_to_canvas_bounds(new_global_position)
		global_position = constrained_position

		get_viewport().set_input_as_handled()

func _constrain_to_canvas_bounds(proposed_global_position):
	# Get the canvas boundaries from the parent whiteboard
	var canvas_bounds = Rect2(Vector2.ZERO, Vector2(706, 608))  # Match your whiteboard size
	var whiteboard_global_position = Vector2(221, 16)  # Match your whiteboard position

	# Convert to local canvas coordinates
	var local_bounds = Rect2(whiteboard_global_position, canvas_bounds.size)

	# Constrain the text box position to stay within canvas bounds
	var constrained_x = clamp(proposed_global_position.x, local_bounds.position.x, local_bounds.end.x - size.x)
	var constrained_y = clamp(proposed_global_position.y, local_bounds.position.y, local_bounds.end.y - size.y)

	return Vector2(constrained_x, constrained_y)

func _get_max_size():
	# Calculate maximum size based on current position and canvas bounds
	var canvas_bounds = Rect2(Vector2.ZERO, Vector2(706, 608))
	var whiteboard_global_position = Vector2(221, 16)
	var local_bounds = Rect2(whiteboard_global_position, canvas_bounds.size)

	# Calculate available space in each direction
	var max_width = local_bounds.end.x - global_position.x
	var max_height = local_bounds.end.y - global_position.y

	return Vector2(max_width, max_height)

func _on_resize_handle_gui_input(event):
	if not is_editing:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			is_resizing = true
			resize_start = event.global_position
			original_size = size
			original_position = global_position
			get_viewport().set_input_as_handled()

		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			is_resizing = false

	if event is InputEventMouseMotion and is_resizing:
		var delta = event.global_position - resize_start

		# Calculate new size based on resize direction
		var new_size = Vector2(
			max(original_size.x + delta.x, custom_minimum_size.x),
			max(original_size.y + delta.y, custom_minimum_size.y)
		)

		# Constrain size to canvas boundaries
		var max_size = _get_max_size()
		new_size.x = min(new_size.x, max_size.x)
		new_size.y = min(new_size.y, max_size.y)

		# Apply new size
		size = new_size
		text_edit.size = new_size
		resize_handle.position = Vector2(size.x - resize_handle_size, size.y - resize_handle_size)
		resize_start = event.global_position
		original_size = size
		queue_redraw()
		get_viewport().set_input_as_handled()

func create_context_menu():
	context_menu = PopupMenu.new()
	context_menu.add_item("Edit", 0)
	context_menu.add_item("Delete", 1)  # Add Delete option
	context_menu.set_size(Vector2(100, 60))  # Make it taller to fit both options
	context_menu.id_pressed.connect(_on_context_menu_id_pressed)
	context_menu.popup_hide.connect(_on_context_menu_hidden)
	add_child(context_menu)

func _on_context_menu_id_pressed(id):
	if id == 0:  # Edit
		request_edit()
	elif id == 1:  # Delete
		# Emit signal to request deletion
		emit_signal("delete_requested", self)

func _on_context_menu_hidden():
	context_menu_visible = false

func show_context_menu():
	# Only show context menu if no text box is currently active
	# Use a safe approach to check if parent scene has active text
	var has_active_text = false
	var parent = get_parent()

	# Safely check if parent has active text instance
	if parent and parent.has_method("has_active_text_instance"):
		has_active_text = parent.has_active_text_instance()

	if not has_active_text:
		context_menu.position = get_global_mouse_position()
		context_menu.popup()
		context_menu_visible = true

func hide_context_menu():
	context_menu.hide()
	context_menu_visible = false

func start_editing():
	is_editing = true
	# Enable editing
	text_edit.focus_mode = FOCUS_ALL
	text_edit.caret_blink = true
	text_edit.editable = true
	text_edit.grab_focus()
	resize_handle.visible = true
	mouse_default_cursor_shape = Control.CURSOR_IBEAM

	# Notify parent about edit request safely
	var parent = get_parent()
	if parent and parent.has_method("_on_text_edit_requested"):
		parent._on_text_edit_requested(self)

	queue_redraw()

func finish_editing():
	is_editing = false
	is_dragging = false
	is_resizing = false
	text_edit.focus_mode = FOCUS_NONE
	text_edit.caret_blink = false
	text_edit.editable = false
	
	text_edit.add_theme_color_override("font_readonly_color", Color.BLACK)
	
	resize_handle.visible = false
	mouse_default_cursor_shape = Control.CURSOR_ARROW

	# Notify parent about edit finished safely
	var parent = get_parent()
	if parent and parent.has_method("_on_text_edit_finished"):
		parent._on_text_edit_finished(self)

	emit_signal("edit_finished", self)
	queue_redraw()

func request_edit():
	if not is_editing:
		start_editing()
		emit_signal("edit_requested", self)

func _draw():
	if is_editing:
		# Draw a border around the text box when editing
		draw_rect(Rect2(Vector2.ZERO, size), Color.BLUE, false, 2.0)
	else:
		# Check if we should draw gray border (text mode)
		var should_draw_gray = false
		var parent = get_parent()

		# Safely check if parent is in text mode
		if parent and parent.has_method("get_current_tool"):
			var current_tool = parent.get_current_tool()
			# Assuming 1 is TEXT mode (you may need to adjust this)
			should_draw_gray = current_tool == 1

		if should_draw_gray:
			# Draw a subtle border when not editing but in text mode
			draw_rect(Rect2(Vector2.ZERO, size), Color.GRAY, false, 1.0)
