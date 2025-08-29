extends Node

class_name ShopRestockSystem

signal restocked(items_available)  # Signal emitted when shop restocks

@export var restock_interval_minutes: float = 10.0

# Define your items with their rarities
@export_category("Item Definitions")
@export var common_items: Array[String] = ["Addition", "Subtraction"]
@export var uncommon_items: Array[String] = ["Mutliplication", "Division"]

var current_items: Array[String] = []
var restock_timer: Timer

func _ready():
	# Initial restock
	restock_shop()
	
	# Create and setup timer
	restock_timer = Timer.new()
	add_child(restock_timer)
	
	restock_timer.wait_time = restock_interval_minutes * 60  # Convert minutes to seconds
	restock_timer.one_shot = false  # Make it repeat
	restock_timer.timeout.connect(_on_restock_timer_timeout)
	
	# Start the timer
	restock_timer.start()
	
	print("Shop restock system started. First restock in ", restock_interval_minutes, " minutes")

func _on_restock_timer_timeout():
	restock_shop()
	print("Shop restocked! Available items: ", current_items)

func restock_shop():
	# Clear current items
	current_items.clear()
	
	# Common item selection (30% chance, only one appears)
	var common_chance = randf()
	if common_chance <= 0.3:
		var random_common = common_items[randi() % common_items.size()]
		current_items.append(random_common)
		print("Common item selected: ", random_common)
	
	# Uncommon item selection (20% chance, only one appears)
	var uncommon_chance = randf()
	if uncommon_chance <= 0.2:
		var random_uncommon = uncommon_items[randi() % uncommon_items.size()]
		current_items.append(random_uncommon)
		print("Uncommon item selected: ", random_uncommon)
	
	# Emit signal that shop has been restocked
	restocked.emit(current_items)

func get_current_items() -> Array[String]:
	return current_items.duplicate()  # Return copy to prevent external modification

func buy_item(item_name: String) -> bool:
	if current_items.has(item_name):
		current_items.erase(item_name)
		print("Purchased: ", item_name)
		return true
	return false

func get_time_until_next_restock() -> float:
	return restock_timer.time_left

# Function to get the rarity of an item (useful for UI)
func get_item_rarity(item_name: String) -> String:
	if common_items.has(item_name):
		return "common"
	elif uncommon_items.has(item_name):
		return "uncommon"
	return "unknown"

# Function to simulate the restock chances (for testing)
func simulate_restock_chances(runs: int = 1000):
	var common_count = 0
	var uncommon_count = 0
	var both_count = 0
	var none_count = 0
	
	for i in range(runs):
		var temp_items = []
		
		# Common item selection
		var common_chance = randf()
		if common_chance <= 0.3:
			temp_items.append("Common")
		
		# Uncommon item selection
		var uncommon_chance = randf()
		if uncommon_chance <= 0.2:
			temp_items.append("Uncommon")
		
		if temp_items.size() == 2:
			both_count += 1
		elif temp_items.size() == 1:
			if temp_items[0] == "Common":
				common_count += 1
			else:
				uncommon_count += 1
		else:
			none_count += 1
	
	print("=== Restock Chance Simulation (", runs, " runs) ===")
	print("Only Common: ", common_count, " (", (common_count/float(runs))*100, "%)")
	print("Only Uncommon: ", uncommon_count, " (", (uncommon_count/float(runs))*100, "%)")
	print("Both Items: ", both_count, " (", (both_count/float(runs))*100, "%)")
	print("No Items: ", none_count, " (", (none_count/float(runs))*100, "%)")

# Optional: Manual restock function for testing
func manual_restock():
	restock_shop()

# Optional: Change restock interval dynamically
func set_restock_interval(minutes: float):
	restock_interval_minutes = minutes
	restock_timer.wait_time = minutes * 60
	restock_timer.start()  # Restart timer with new interval
