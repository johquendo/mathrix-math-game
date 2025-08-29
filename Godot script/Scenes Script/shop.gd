extends Control

@onready var shop: Control = $"."
@onready var shop_panel: Panel = $SimpleUI/ShopPanel
@onready var tool_shop_panel: Panel = $SimpleUI/ToolShopPanel

func _ready() -> void:
		pass
		
		
func _on_back_button_down() -> void:
	shop.visible = false

func _on_tools_button_button_down() -> void:
	shop_panel.visible = false
	tool_shop_panel.visible = true

func _on_equations_button_button_down() -> void:
	shop_panel.visible = true
	tool_shop_panel.visible = false
