extends Control

# Use the recursive search function to find GameManager
@onready var game_manager = _find_node_recursive("GameManager")

# Helper function to find nodes by name recursively
func _find_node_recursive(node_name: String) -> Node:
	return _find_node_recursive_helper(get_tree().root, node_name)

func _find_node_recursive_helper(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	
	for child in node.get_children():
		var result = _find_node_recursive_helper(child, node_name)
		if result:
			return result
	
	return null

func _ready():
	if game_manager:
		print("GameManager connected in SimpleUI!")
	else:
		print("Warning: GameManager not found in SimpleUI!")

func _on_BuyCommon_pressed():
	if game_manager and game_manager.has_method("test_buy_basic_math"):
		game_manager.test_buy_basic_math()

func _on_TestRestockButton_pressed():
	if game_manager and game_manager.has_method("test_manual_restock"):
		game_manager.test_manual_restock()
		
# Add these functions to SimpleUI.gd
func _on_BuyCalculator_pressed():
	if game_manager and game_manager.has_method("test_buy_calculator"):
		game_manager.test_buy_calculator()

func _on_BuyDisplayCase_pressed():
	if game_manager and game_manager.has_method("test_buy_display_case"):
		game_manager.test_buy_display_case()

func _on_BuyUpgradeMedal_pressed():
	if game_manager and game_manager.has_method("test_buy_upgrade_medal"):
		game_manager.test_buy_upgrade_medal()
