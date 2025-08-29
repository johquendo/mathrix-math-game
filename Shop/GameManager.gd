extends Node

# Use relative paths or search for nodes
@onready var currency_manager = get_node("/root/GlobalCurrency")
@onready var shop_system = get_node_or_null("../ShopRestockSystem")
@onready var problem_generator = get_node_or_null("../ProblemGenerator")
@onready var currency_label = _find_node_recursive("CurrencyLabel")
@onready var uncommon_math_button = _find_node_recursive("BuyUncommon")
@onready var rare_math_button = _find_node_recursive("BuyRare")
@onready var calculator_button = _find_node_recursive("BuyCalculator")
@onready var display_case_button = _find_node_recursive("BuyDisplayCase")
@onready var upgrade_medal_button = _find_node_recursive("BuyUpgradeMedal")

# UI elements - search recursively if needed
@onready var timer_label = _find_node_recursive("TimerLabel")
@onready var status_label = _find_node_recursive("StatusLabel")
@onready var stock_label = _find_node_recursive("StockLabel")
@onready var basic_math_button = _find_node_recursive("BuyCommon")

var timer_update_interval = 1.0
var timer_update_counter = 0.0

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
	print("GameManager starting...")
	print("Current scene: ", get_tree().current_scene.name)
	
	if currency_manager:
		print("Currency manager connected!")
		# Connect to currency changed signal
		if currency_manager.has_signal("currency_changed"):
			currency_manager.currency_changed.connect(_on_currency_changed)
		
		# Set initial currency display
		_on_currency_changed(currency_manager.get_currency())
	
	# Debug: Print all nodes to find what's available
	_print_node_tree(get_tree().root, 0)
	
	# Check if nodes were found
	if shop_system:
		if shop_system.has_signal("restocked"):
			shop_system.restocked.connect(_on_shop_restocked)
			print("Shop system connected!")
		else:
			print("Warning: ShopRestockSystem doesn't have restocked signal!")
	else:
		print("Warning: ShopRestockSystem not found!")
	
	if problem_generator:
		print("Problem generator connected!")
	else:
		print("Warning: ProblemGenerator not found!")
	
	# Check UI elements
	if timer_label:
		print("TimerLabel found: ", timer_label.get_path())
	else:
		print("Warning: TimerLabel not found!")
	
	if status_label:
		print("StatusLabel found: ", status_label.get_path())
	else:
		print("Warning: StatusLabel not found!")
	
	if stock_label:
		print("StockLabel found: ", stock_label.get_path())
	else:
		print("Warning: StockLabel not found!")
	
	if basic_math_button:
		print("BuyCommon button found: ", basic_math_button.get_path())
	else:
		print("Warning: BuyCommon button not found!")
		
	if uncommon_math_button:
		print("BuyUncommon button found: ", uncommon_math_button.get_path())
	else:
		print("Warning: BuyUncommon button not found!")

	if rare_math_button:
		print("BuyRare button found: ", rare_math_button.get_path())
	else:
		print("Warning: BuyRare button not found!")
		
	if calculator_button:
		print("BuyCalculator button found: ", calculator_button.get_path())
	else:
		print("Warning: BuyCalculator button not found!")

	if display_case_button:
		print("BuyDisplayCase button found: ", display_case_button.get_path())
	else:
		print("Warning: BuyDisplayCase button not found!")

	if upgrade_medal_button:
		print("BuyUpgradeMedal button found: ", upgrade_medal_button.get_path())
	else:
		print("Warning: BuyUpgradeMedal button not found!")

	# Connect buttons
	_setup_button_connections()
	
	# Initial UI update
	update_inventory_display()
	update_timer_display()
	
	print("Game Manager ready!")

# Debug function to print node tree
func _print_node_tree(node: Node, depth: int):
	var indent = "  ".repeat(depth)
	print(indent + "├─ " + node.name + " (" + node.get_class() + ")")
	
	for child in node.get_children():
		_print_node_tree(child, depth + 1)

func _setup_button_connections():
	# Disconnect first to avoid multiple connections
	if basic_math_button and basic_math_button.has_signal("pressed"):
		if basic_math_button.pressed.is_connected(test_buy_basic_math):
			basic_math_button.pressed.disconnect(test_buy_basic_math)
		basic_math_button.pressed.connect(test_buy_basic_math)
		print("BuyCommon button connected!")
	else:
		print("Warning: BuyCommon button not available for connection!")
	
	if uncommon_math_button and uncommon_math_button.has_signal("pressed"):
		if uncommon_math_button.pressed.is_connected(test_buy_uncommon_math):
			uncommon_math_button.pressed.disconnect(test_buy_uncommon_math)
		uncommon_math_button.pressed.connect(test_buy_uncommon_math)
		print("BuyUncommon button connected!")
	else:
		print("Warning: BuyUncommon button not available for connection!")
	
	if rare_math_button and rare_math_button.has_signal("pressed"):
		if rare_math_button.pressed.is_connected(test_buy_rare_math):
			rare_math_button.pressed.disconnect(test_buy_rare_math)
		rare_math_button.pressed.connect(test_buy_rare_math)
		print("BuyRare button connected!")
	else:
		print("Warning: BuyRare button not available for connection!")
	
	if calculator_button and calculator_button.has_signal("pressed"):
		if calculator_button.pressed.is_connected(test_buy_calculator):
			calculator_button.pressed.disconnect(test_buy_calculator)
		calculator_button.pressed.connect(test_buy_calculator)
		print("BuyCalculator button connected!")
	else:
		print("Warning: BuyCalculator button not available for connection!")
	
	if display_case_button and display_case_button.has_signal("pressed"):
		if display_case_button.pressed.is_connected(test_buy_display_case):
			display_case_button.pressed.disconnect(test_buy_display_case)
		display_case_button.pressed.connect(test_buy_display_case)
		print("BuyDisplayCase button connected!")
	else:
		print("Warning: BuyDisplayCase button not available for connection!")
	
	if upgrade_medal_button and upgrade_medal_button.has_signal("pressed"):
		if upgrade_medal_button.pressed.is_connected(test_buy_upgrade_medal):
			upgrade_medal_button.pressed.disconnect(test_buy_upgrade_medal)
		upgrade_medal_button.pressed.connect(test_buy_upgrade_medal)
		print("BuyUpgradeMedal button connected!")
	else:
		print("Warning: BuyUpgradeMedal button not available for connection!")

func _process(delta):
	# Update timer display every second
	timer_update_counter += delta
	if timer_update_counter >= timer_update_interval:
		timer_update_counter = 0.0
		update_timer_display()

func _on_shop_restocked(_items: Array):
	print("Shop restocked signal received!")
	update_inventory_display()
	update_timer_display()
	
	if status_label:
		status_label.text = "Shop restocked!"

func update_inventory_display():
	# Update all item displays
	_update_basic_math_display()
	_update_uncommon_math_display()
	_update_rare_math_display()
	_update_calculator_display()
	_update_display_case_display()
	_update_upgrade_medal_display()

func _update_basic_math_display():
	if not shop_system:
		return
	
	# Update Basic Math stock display
	var basic_math_count = shop_system.get_item_count("Basic Math")
	
	if stock_label:
		stock_label.text = "Stock: %d" % basic_math_count
	else:
		print("StockLabel not available for update!")
	
	# Update button state
	if basic_math_button:
		basic_math_button.disabled = (basic_math_count <= 0)
		if basic_math_count <= 0:
			basic_math_button.modulate = Color.GRAY
		else:
			basic_math_button.modulate = Color.WHITE

func _update_uncommon_math_display():
	if not shop_system:
		return
	
	# Update Uncommon Math stock display
	var uncommon_math_count = shop_system.get_item_count("Uncommon Math")
	
	# You'll need to find or create stock labels for uncommon/rare items
	var uncommon_stock_label = _find_node_recursive("UncommonStockLabel")
	if uncommon_stock_label:
		uncommon_stock_label.text = "Stock: %d" % uncommon_math_count
	
	# Update button state
	if uncommon_math_button:
		uncommon_math_button.disabled = (uncommon_math_count <= 0)
		if uncommon_math_count <= 0:
			uncommon_math_button.modulate = Color.GRAY
		else:
			uncommon_math_button.modulate = Color.WHITE
			
func _update_rare_math_display():
	if not shop_system:
		return
	
	# Update Rare Math stock display
	var rare_math_count = shop_system.get_item_count("Rare Math")
	
	# You'll need to find or create stock labels for uncommon/rare items
	var rare_stock_label = _find_node_recursive("RareStockLabel")
	if rare_stock_label:
		rare_stock_label.text = "Stock: %d" % rare_math_count
	
	# Update button state
	if rare_math_button:
		rare_math_button.disabled = (rare_math_count <= 0)
		if rare_math_count <= 0:
			rare_math_button.modulate = Color.GRAY
		else:
			rare_math_button.modulate = Color.WHITE

func _update_calculator_display():
	if not shop_system:
		return
	
	var calculator_count = shop_system.get_item_count("Calculator")
	var calculator_stock_label = _find_node_recursive("CalculatorStockLabel")
	
	if calculator_stock_label:
		calculator_stock_label.text = "Stock: %d" % calculator_count
	
	if calculator_button:
		calculator_button.disabled = (calculator_count <= 0)
		if calculator_count <= 0:
			calculator_button.modulate = Color.GRAY
		else:
			calculator_button.modulate = Color.WHITE

func _update_display_case_display():
	if not shop_system:
		return
	
	var display_case_count = shop_system.get_item_count("Display Case")
	var display_case_stock_label = _find_node_recursive("DisplayCaseStockLabel")
	
	if display_case_stock_label:
		display_case_stock_label.text = "Stock: %d" % display_case_count
	
	if display_case_button:
		display_case_button.disabled = (display_case_count <= 0)
		if display_case_count <= 0:
			display_case_button.modulate = Color.GRAY
		else:
			display_case_button.modulate = Color.WHITE

func _update_upgrade_medal_display():
	if not shop_system:
		return
	
	var upgrade_medal_count = shop_system.get_item_count("Upgrade Medal")
	var upgrade_medal_stock_label = _find_node_recursive("UpgradeMedalStockLabel")
	
	if upgrade_medal_stock_label:
		upgrade_medal_stock_label.text = "Stock: %d" % upgrade_medal_count
	
	if upgrade_medal_button:
		upgrade_medal_button.disabled = (upgrade_medal_count <= 0)
		if upgrade_medal_count <= 0:
			upgrade_medal_button.modulate = Color.GRAY
		else:
			upgrade_medal_button.modulate = Color.WHITE

func update_timer_display():
	if shop_system and timer_label:
		var time_left = shop_system.get_time_until_next_restock()
		var minutes = floor(time_left / 60)
		var seconds = int(time_left) % 60
		timer_label.text = "%d:%02d" % [minutes, seconds]
	elif not shop_system:
		print("Shop system not available for timer update!")
	elif not timer_label:
		print("TimerLabel not available for update!")
		
# Function called when player buys a problem from shop
func on_buy_problem(problem_type: String):
	if not shop_system:
		return {"success": false, "error": "Shop system not available"}
	
	# Use the shop system to get prices
	var cost = shop_system.get_item_price(problem_type) if shop_system.has_method("get_item_price") else 0
	
	# Check if player can afford it
	if currency_manager and not currency_manager.can_afford(cost):
		if status_label:
			status_label.text = "Not enough coins! Need %d" % cost
		
		# Show visual feedback on the button itself
		_show_not_enough_money_feedback(problem_type)
		return {"success": false, "error": "Not enough currency"}
	
	var purchase_result = shop_system.buy_item(problem_type)
	
	if purchase_result.success:
		# Deduct currency
		if currency_manager:
			currency_manager.spend_currency(cost, "Bought " + problem_type)
		
		# For tools, we don't need to generate problems
		if problem_type in ["Calculator", "Display Case", "Upgrade Medal"]:
			# Update UI immediately
			update_inventory_display()
			
			if status_label:
				status_label.text = "Purchased: %s" % problem_type
			
			# Return success for tools
			return {
				"success": true,
				"item": problem_type,
				"remaining": shop_system.get_item_count(problem_type),
				"is_tool": true
			}
		
		# For math problems, generate the actual problem
		var difficulty = shop_system.get_difficulty_for_problem(problem_type) if shop_system.has_method("get_difficulty_for_problem") else 0
		
		# Set the problem generator to this difficulty and generate
		if problem_generator:
			if problem_generator.has_method("set_difficulty"):
				problem_generator.set_difficulty(difficulty)
			
			var problem_data = problem_generator.generate_item()
			
			# Get remaining count for display
			var remaining_count = shop_system.get_item_count(problem_type)
			
			# Update UI immediately
			update_inventory_display()
			
			if status_label:
				status_label.text = "Purchased: %s (%d left)" % [problem_type, remaining_count]
			
			# Return the purchase data including the answer
			var result = {
				"success": true,
				"item": problem_type,
				"remaining": remaining_count,
				"problem": problem_data["problem"],
				"answer": problem_data["answer"],
				"difficulty": difficulty,
				"cost": cost,
				"is_tool": false
			}
			
			return result
		else:
			print("Problem generator not available")
			return {"success": false, "error": "Problem generator not available"}
	else:
		if status_label:
			status_label.text = "Cannot purchase: %s (out of stock)" % problem_type
		return {"success": false, "error": "Item not available"}

# Manual test functions
func test_buy_basic_math():
	return on_buy_problem("Basic Math")

func test_buy_uncommon_math():
	return on_buy_problem("Uncommon Math")

func test_buy_rare_math():
	return on_buy_problem("Rare Math")

func test_buy_calculator():
	return on_buy_problem("Calculator")

func test_buy_display_case():
	return on_buy_problem("Display Case")

func test_buy_upgrade_medal():
	return on_buy_problem("Upgrade Medal")

# Manual restock for testing
func test_manual_restock():
	if shop_system:
		shop_system.manual_restock()
		if status_label:
			status_label.text = "Manual restock triggered!"
		print("Manual restock triggered!")
		
func _on_currency_changed(new_amount: int):
	# Update currency display if you have one
	if currency_label:
		currency_label.text = "Coins: %d" % new_amount
	else:
		# Try to find it if it wasn't found initially
		currency_label = _find_node_recursive("CurrencyLabel")
		if currency_label:
			currency_label.text = "Coins: %d" % new_amount

# First, define the reset function
func _reset_button_appearance(button: Button):
	if button and button.has_meta("original_text"):
		button.text = button.get_meta("original_text")
		button.modulate = Color.WHITE

# Then define the feedback function that uses it
func _show_not_enough_money_feedback(problem_type: String):
	# Find the button for this problem type
	var button = null
	var cost = 0
	
	if shop_system and shop_system.has_method("get_item_price"):
		cost = shop_system.get_item_price(problem_type)
	
	match problem_type:
		"Basic Math":
			button = basic_math_button
		"Uncommon Math":
			button = uncommon_math_button
		"Rare Math":
			button = rare_math_button
		"Calculator":
			button = calculator_button
		"Display Case":
			button = display_case_button
		"Upgrade Medal":
			button = upgrade_medal_button
	
	if button:
		# Store original values
		if not button.has_meta("original_modulate"):
			button.set_meta("original_modulate", button.modulate)
		if not button.has_meta("original_text"):
			button.set_meta("original_text", button.text)
		
		# Change appearance with cost information
		button.text = "NEED %d COINS!" % cost
		button.modulate = Color.RED
		
		# Simple one-time reset after delay (no flashing)
		var timer = get_tree().create_timer(2.0)
		timer.timeout.connect(_reset_button_appearance.bind(button))
