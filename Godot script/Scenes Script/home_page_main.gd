extends Control

# UI references
@onready var timer: Label = $Shop/SimpleUI/TimerLabel
@onready var control: Control = $"."  
@onready var main: VBoxContainer = $main
@onready var shop: Control = $Shop
@onready var settings: Panel = $settings
@onready var inventory: Panel = $inventory
@onready var leaderboards: Panel = $leaderboards
@onready var profile: Panel = $profile
@onready var player_1: Panel = $"player 1"
@onready var player_2: Panel = $"player 2"
@onready var player_3: Panel = $"player 3"
@onready var player_4: Panel = $"player 4"
@onready var player_5: Panel = $"player 5"

# Tool button references
@onready var pen_tool_button: Button = $BoardTools/PenToolButton
@onready var text_tool_button: Button = $BoardTools/TextToolButton

var whiteboard_scene = preload("res://Scenes/WhiteboardApp.tscn")
var whiteboard_instance: Control = null
var whiteboard_layer: CanvasLayer = null

# --- Setup ---
func _ready() -> void:
	main.visible = true
	_hide_all_panels()

	# Connect tool buttons
	if pen_tool_button:
		pen_tool_button.pressed.connect(_on_pen_tool_selected)
	if text_tool_button:
		text_tool_button.pressed.connect(_on_text_tool_selected)

	# setup whiteboard ONCE
	call_deferred("_setup_whiteboard")

# --- Hide all panels helper ---
func _hide_all_panels() -> void:
	shop.visible = false
	settings.visible = false
	inventory.visible = false
	leaderboards.visible = false
	profile.visible = false
	timer.visible = false

# --- White Board Stuff ---
func _setup_whiteboard() -> void:
	whiteboard_layer = CanvasLayer.new()
	whiteboard_layer.layer = 10  # High layer number to be on top
	add_child(whiteboard_layer)

	whiteboard_instance = whiteboard_scene.instantiate()
	whiteboard_layer.add_child(whiteboard_instance)

	whiteboard_instance.position = Vector2(221, 16)
	whiteboard_instance.size = Vector2(706, 608)
	whiteboard_instance.mouse_filter = Control.MOUSE_FILTER_STOP
	
	if whiteboard_instance:
		if whiteboard_instance.has_signal("pen_tool_selected"):
			whiteboard_instance.pen_tool_selected.connect(_on_whiteboard_pen_tool_selected)
		if whiteboard_instance.has_signal("text_tool_selected"):
			whiteboard_instance.text_tool_selected.connect(_on_whiteboard_text_tool_selected)

# Tool selection functions that call whiteboard methods
func _on_pen_tool_selected():
	if whiteboard_instance:
		whiteboard_instance.call_deferred("_on_pen_tool_selected")

func _on_text_tool_selected():
	if whiteboard_instance:
		whiteboard_instance.call_deferred("_on_text_tool_selected")

# Signal handlers for whiteboard tool changes
func _on_whiteboard_pen_tool_selected():
	if pen_tool_button:
		pen_tool_button.button_pressed = true
	if text_tool_button:
		text_tool_button.button_pressed = false

func _on_whiteboard_text_tool_selected():
	if pen_tool_button:
		pen_tool_button.button_pressed = false
	if text_tool_button:
		text_tool_button.button_pressed = true

# --- Button Handlers with panel + whiteboard toggle ---
func _on_shop_button_down() -> void:
	_hide_all_panels()
	shop.visible = true
	timer.visible = true
	if whiteboard_layer: whiteboard_layer.visible = false

func _on_back_button_down() -> void:
	shop.visible = false
	if whiteboard_layer: whiteboard_layer.visible = true

func _on_settings_button_down() -> void:
	_hide_all_panels()
	settings.visible = true
	if whiteboard_layer: whiteboard_layer.visible = false

func _on_backk_button_down() -> void:
	settings.visible = false
	if whiteboard_layer: whiteboard_layer.visible = true

func _on_profile_button_down() -> void:
	_hide_all_panels()
	profile.visible = true
	if whiteboard_layer: whiteboard_layer.visible = false

func _on_back_profile_button_down() -> void:
	profile.visible = false
	if whiteboard_layer: whiteboard_layer.visible = true

func _on_inventory_button_down() -> void:
	_hide_all_panels()
	inventory.visible = true
	if whiteboard_layer: whiteboard_layer.visible = false

func _on_back_inventory_button_down() -> void:
	inventory.visible = false
	if whiteboard_layer: whiteboard_layer.visible = true

func _on_leaderboards_button_down() -> void:
	_hide_all_panels()
	leaderboards.visible = true
	if whiteboard_layer: whiteboard_layer.visible = false

func _on_back_leaderboards_button_down() -> void:
	leaderboards.visible = false
	if whiteboard_layer: whiteboard_layer.visible = true

# Player Boards
func _on_p_1_button_down(): player_1.visible = true
func _on_back_p_1_button_down(): player_1.visible = false
func _on_p_2_button_down(): player_2.visible = true
func _on_back_p_2_button_down(): player_2.visible = false
func _on_p_3_button_down(): player_3.visible = true
func _on_back_p_3_button_down(): player_3.visible = false
func _on_p_4_button_down(): player_4.visible = true
func _on_back_p_4_button_down(): player_4.visible = false
func _on_p_5_button_down(): player_5.visible = true
func _on_back_p_5_button_down(): player_5.visible = false
