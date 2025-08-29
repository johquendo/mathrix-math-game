extends Node
class_name RestockSystem

signal restocked(items_available: Array)

@export var restock_interval_minutes: float = 0.1

@export_category("Item Definitions")
@export var basic_math_items: Array[String] = ["Addition", "Subtraction"]
@export var uncommon_math_items: Array[String] = ["Multiplication", "Division"]
@export var rare_math_items: Array[String] = ["Algebra", "Geometry"]

@export_category("Tool Definitions")
@export var calculator_tool: Array[String] = ["Calculator"]
@export var display_case_tool: Array[String] = ["Display Case"]
@export var upgrade_medal_tool: Array[String] = ["Upgrade Medal"]

@export var basic_stock_min: int = 3
@export var basic_stock_max: int = 6
@export var uncommon_stock_min: int = 2
@export var uncommon_stock_max: int = 4
@export var rare_stock_min: int = 1
@export var rare_stock_max: int = 2

# Tools are unique - only 0 or 1 in stock
@export var calculator_stock: int = 1
@export var display_case_stock: int = 1
@export var upgrade_medal_stock: int = 1

var item_counts: Dictionary = {
	"Basic Math": 0,      # Common items
	"Uncommon Math": 0,   # Uncommon items
	"Rare Math": 0,       # Rare items
	"Calculator": 0,      # Premium tool
	"Display Case": 0,    # Premium tool
	"Upgrade Medal": 0    # Premium tool
}

var restock_timer: Timer

func _ready():
	restock_shop()
	
	restock_timer = Timer.new()
	add_child(restock_timer)
	
	restock_timer.wait_time = restock_interval_minutes * 60
	restock_timer.one_shot = false
	restock_timer.timeout.connect(_on_restock_timer_timeout)
	
	restock_timer.start()
	
	print("Shop restock system started. First restock in ", restock_interval_minutes, " minutes")

func _on_restock_timer_timeout():
	restock_shop()

func restock_shop():
	# RESET ALL STOCK TO ZERO FIRST
	for item in item_counts:
		item_counts[item] = 0
	
	print("=== RESTOCKING SHOP ===")
	
	# Basic Math items (Common)
	var basic_stock_amount = randi_range(basic_stock_min, basic_stock_max)
	item_counts["Basic Math"] = basic_stock_amount
	print("Restocked: Basic Math (x", basic_stock_amount, ")")
	
	# Uncommon Math items
	var uncommon_stock_amount = randi_range(uncommon_stock_min, uncommon_stock_max)
	item_counts["Uncommon Math"] = uncommon_stock_amount
	print("Restocked: Uncommon Math (x", uncommon_stock_amount, ")")
	
	# Rare Math items
	var rare_stock_amount = randi_range(rare_stock_min, rare_stock_max)
	item_counts["Rare Math"] = rare_stock_amount
	print("Restocked: Rare Math (x", rare_stock_amount, ")")
	
	# Premium Tools (unique items)
	item_counts["Calculator"] = calculator_stock
	item_counts["Display Case"] = display_case_stock
	item_counts["Upgrade Medal"] = upgrade_medal_stock
	print("Restocked: Calculator (x", calculator_stock, ")")
	print("Restocked: Display Case (x", display_case_stock, ")")
	print("Restocked: Upgrade Medal (x", upgrade_medal_stock, ")")
	
	var available_items = get_current_items()
	print("Shop restocked! Inventory: ", get_inventory_string())
	print("======================")
	
	# EMIT SIGNAL AFTER EVERYTHING IS DONE
	restocked.emit(available_items)

func get_current_items():
	var items = []
	for item in item_counts:
		if item_counts[item] > 0:
			for i in range(item_counts[item]):
				items.append(item)
	return items

func get_item_count(item_name: String) -> int:
	return item_counts.get(item_name, 0)

func get_all_item_counts() -> Dictionary:
	return item_counts.duplicate()

func buy_item(item_name: String) -> Dictionary:
	if item_counts.get(item_name, 0) > 0:
		item_counts[item_name] -= 1
		print("Purchased: ", item_name)
		print("Remaining: ", item_name, " (x", item_counts[item_name], ")")
		
		# Randomly select the actual problem type based on item category
		var actual_item_type = ""
		match item_name:
			"Basic Math":
				actual_item_type = basic_math_items[randi() % basic_math_items.size()]
			"Uncommon Math":
				actual_item_type = uncommon_math_items[randi() % uncommon_math_items.size()]
			"Rare Math":
				actual_item_type = rare_math_items[randi() % rare_math_items.size()]
			"Calculator":
				actual_item_type = calculator_tool[0]  # Only one type
			"Display Case":
				actual_item_type = display_case_tool[0]  # Only one type
			"Upgrade Medal":
				actual_item_type = upgrade_medal_tool[0]  # Only one type
			_:
				actual_item_type = item_name
		
		print("Purchased: ", actual_item_type)
		
		return {
			"success": true,
			"display_name": item_name,
			"actual_type": actual_item_type,
			"remaining": item_counts[item_name]
		}
	
	return {"success": false}

func get_time_until_next_restock() -> float:
	if restock_timer:
		return restock_timer.time_left
	return 0.0

func get_item_rarity(item_name: String) -> String:
	match item_name:
		"Basic Math":
			return "common"
		"Uncommon Math":
			return "uncommon"
		"Rare Math":
			return "rare"
		"Calculator", "Display Case", "Upgrade Medal":
			return "premium"
		_:
			return "common"

func get_difficulty_for_problem(problem_type: String) -> int:
	match problem_type:
		"Basic Math":
			return 0  # Common
		"Uncommon Math":
			return 1  # Uncommon
		"Rare Math":
			return 2  # Rare
		_:
			return 0  # Default to common

func get_item_price(item_name: String) -> int:
	match item_name:
		"Basic Math":
			return 10
		"Uncommon Math":
			return 50
		"Rare Math":
			return 100
		"Calculator":
			return 50000
		"Display Case":
			return 9000
		"Upgrade Medal":
			return 100000
		_:
			return 0

func get_inventory_string() -> String:
	var result = []
	for item in item_counts:
		if item_counts[item] > 0:
			var rarity = get_item_rarity(item)
			result.append("%s: %d (%s)" % [item, item_counts[item], rarity])
	
	if result.is_empty():
		return "Empty"
	return ", ".join(result)

# Manual restock function for testing
func manual_restock():
	print("=== MANUAL RESTOCK TRIGGERED ===")
	restock_shop()

# Change restock interval dynamically
func set_restock_interval(minutes: float):
	restock_interval_minutes = minutes
	if restock_timer:
		restock_timer.wait_time = minutes * 60
		restock_timer.start()
