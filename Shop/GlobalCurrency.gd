# GlobalCurrency.gd
extends Node

# Signals
signal currency_changed(new_amount: int)
signal currency_earned(amount: int, reason: String)
signal currency_spent(amount: int, reason: String)

# Static reference to the singleton
static var instance: GlobalCurrency

# Currency amount - use a private backing field
var _current_currency: int = 999
var current_currency: int:
	get:
		return _current_currency
	set(value):
		_set_current_currency(value)

# Save file path
const SAVE_PATH = "user://currency_save.cfg"

func _init():
	# Make this a singleton/autoload
	if instance == null:
		instance = self
	else:
		queue_free()
		return

func _ready():
	# Load saved currency
	load_currency()
	
	# Connect to problem solving events if available
	_connect_to_problem_events()

func _connect_to_problem_events():
	# Try to find problem solver and connect to it
	call_deferred("_deferred_connect_to_problem_events")

func _deferred_connect_to_problem_events():
	var problem_solver = get_tree().get_first_node_in_group("problem_solver")
	if problem_solver and problem_solver.has_signal("problem_solved"):
		problem_solver.problem_solved.connect(_on_problem_solved)
		print("Connected to problem solver")
	else:
		# Try again after a short delay
		get_tree().create_timer(1.0).timeout.connect(_connect_to_problem_events)

func _set_current_currency(value: int):
	var old_value = _current_currency
	_current_currency = max(0, value)  # Ensure currency doesn't go negative
	
	if _current_currency != old_value:
		currency_changed.emit(_current_currency)
		save_currency()

# Add currency
func add_currency(amount: int, reason: String = "") -> void:
	if amount > 0:
		# Use the backing field directly to avoid infinite recursion
		_current_currency += amount
		currency_earned.emit(amount, reason)
		currency_changed.emit(_current_currency)
		save_currency()
		print("Earned %d coins%s. Total: %d" % [amount, " (" + reason + ")" if reason != "" else "", _current_currency])

# Spend currency
func spend_currency(amount: int, reason: String = "") -> bool:
	if amount <= 0:
		return false
	
	if _current_currency >= amount:
		# Use the backing field directly to avoid infinite recursion
		_current_currency -= amount
		currency_spent.emit(amount, reason)
		currency_changed.emit(_current_currency)
		save_currency()
		print("Spent %d coins%s. Remaining: %d" % [amount, " (" + reason + ")" if reason != "" else "", _current_currency])
		return true
	else:
		print("Not enough coins! Need %d, have %d" % [amount, _current_currency])
		return false

# Check if player can afford something
func can_afford(amount: int) -> bool:
	return _current_currency >= amount

# Get current currency
func get_currency() -> int:
	return _current_currency

# Save currency to file
func save_currency():
	var config = ConfigFile.new()
	config.set_value("currency", "amount", _current_currency)
	var error = config.save(SAVE_PATH)
	if error == OK:
		print("Currency saved: ", _current_currency)
	else:
		print("Error saving currency: ", error)

# Load currency from file
func load_currency():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	
	if err == OK:
		var saved_currency = config.get_value("currency", "amount", 999)
		# Only load if the saved value is reasonable
		if saved_currency >= 0:
			_current_currency = saved_currency
			print("Currency loaded: ", _current_currency)
		else:
			_current_currency = 999
			print("Invalid currency value in save file, using default: ", _current_currency)
	else:
		# Default starting currency
		_current_currency = 999
		print("No save file found, using default currency: ", _current_currency)
	
	currency_changed.emit(_current_currency)

# Reset currency (for testing/debugging)
func reset_currency(amount: int = 999):
	_current_currency += 10000
	currency_changed.emit(_current_currency)
	save_currency()
	print("Currency reset to: ", _current_currency)

# Event handler for problem solving
func _on_problem_solved(correct: bool, difficulty: int = 0):
	if correct:
		var reward = _calculate_reward(difficulty)
		add_currency(reward, "Solved problem")
	else:
		# Optional: deduct currency for wrong answers
		# var penalty = 5
		# spend_currency(penalty, "Wrong answer")
		pass

func _calculate_reward(difficulty: int) -> int:
	match difficulty:
		1:  # Uncommon
			return 15
		2:  # Rare
			return 25
		_:  # Common/default
			return 10

# DEBUG: Add this function to fix stuck currency
func _input(event):
	# Press R to reset currency for debugging
	if event.is_action_pressed("ui_accept"):  # Enter key
		reset_currency(1000)
		print("DEBUG: Added 100 Coins to your Bank Account (Not)")
