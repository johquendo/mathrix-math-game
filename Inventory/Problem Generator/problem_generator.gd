extends Control

# UI elements
@onready var item_display = $ItemDisplay
@onready var difficulty_label = $DifficultyLabel
@onready var generate_button = $GenerateButton
@onready var change_difficulty_button = $ChangeDifficultyButton

# Shape nodes - you'll need to create these as Sprite2D nodes
@onready var square_shape = $SquareShape
@onready var circle_shape = $CircleShape
@onready var triangle_shape = $TriangleShape

# Difficulty levels
enum DIFFICULTY {COMMON, UNCOMMON, RARE}
var current_difficulty: DIFFICULTY = DIFFICULTY.COMMON

# Current item data
var current_item = {
	"type": "square",  # Visual representation
	"difficulty": DIFFICULTY.COMMON,
	"problem": "",     # Hidden problem text
	"answer": 0        # Hidden answer value
}

func _ready():
	change_difficulty_button.pressed.connect(_on_difficulty_button_pressed)
	
	# Hide all shapes initially
	hide_all_shapes()
	
	# Print welcome message to output
	print("=== Math Problem Generator ===")
	print("Press 'Generate Item' to create math problems!")
	print("Problems will appear here in the output console.")
	print("=====================================")
	
	# Generate first item
	generate_item()

func _on_generate_button_pressed():
	generate_item()

func _on_difficulty_button_pressed():
	# Cycle to next difficulty
	current_difficulty = wrapi(current_difficulty + 1, 0, 3)
	generate_item()

func generate_item():
	var problem_data = {}
	
	match current_difficulty:
		DIFFICULTY.COMMON:
			problem_data = generate_common_problem()
			difficulty_label.text = "Difficulty: Common"
			current_item.type = "square"
		DIFFICULTY.UNCOMMON:
			problem_data = generate_uncommon_problem()
			difficulty_label.text = "Difficulty: Uncommon"
			current_item.type = "circle"
		DIFFICULTY.RARE:
			problem_data = generate_rare_problem()
			difficulty_label.text = "Difficulty: Rare"
			current_item.type = "triangle"
	
	# Update current item with hidden problem data
	current_item.difficulty = current_difficulty
	current_item.problem = problem_data["problem"]
	current_item.answer = problem_data["answer"]
	
	# Update visual display (show shape instead of problem)
	update_item_display()
	
	# PRINT PROBLEM TO OUTPUT CONSOLE
	print_problem_to_console(problem_data["problem"], problem_data["answer"])

func print_problem_to_console(problem, answer):
	# Get difficulty name for output
	var diff_name = ""
	match current_difficulty:
		DIFFICULTY.COMMON: diff_name = "COMMON"
		DIFFICULTY.UNCOMMON: diff_name = "UNCOMMON"
		DIFFICULTY.RARE: diff_name = "RARE"
	
	# Print to Godot's output console
	print("---")
	print("Generated %s Problem:" % diff_name)
	print("Problem: %s" % problem)
	print("Answer: %d" % answer)
	print("Visual Item: %s" % current_item.type)
	print("---")

func hide_all_shapes():
	# Hide all shape nodes
	if square_shape:
		square_shape.visible = false
	if circle_shape:
		circle_shape.visible = false
	if triangle_shape:
		triangle_shape.visible = false

func update_item_display():
	# Hide all shapes first
	hide_all_shapes()
	
	# Show and position the appropriate shape
	match current_item.type:
		"square":
			if square_shape:
				square_shape.visible = true
				# Center the square in the item display area
				square_shape.position = Vector2(100, 100)  # Adjust as needed
		"circle":
			if circle_shape:
				circle_shape.visible = true
				circle_shape.position = Vector2(100, 100)  # Adjust as needed
		"triangle":
			if triangle_shape:
				triangle_shape.visible = true
				triangle_shape.position = Vector2(100, 100)  # Adjust as needed
	
	# Optional: Add tooltip with the actual problem
	if item_display:
		item_display.tooltip_text = current_item.problem

# Function to get the current problem (for answering)
func get_current_problem():
	return current_item.problem

# Function to check answer against current item
func check_answer(user_answer):
	return user_answer == current_item.answer

# Problem generation functions
func generate_common_problem():
	var rng = RandomNumberGenerator.new()
	
	var num1 = rng.randi_range(1, 100)
	var num2 = rng.randi_range(1, 100)
	var operation = rng.randi_range(0, 1)
	
	var problem = ""
	var answer = 0
	
	if operation == 0:  # Addition
		problem = "%d + %d" % [num1, num2]
		answer = num1 + num2
	else:  # Subtraction
		if num1 < num2:
			var temp = num1
			num1 = num2
			num2 = temp
		problem = "%d - %d" % [num1, num2]
		answer = num1 - num2
	
	return {"problem": problem, "answer": answer}

func generate_uncommon_problem():
	var rng = RandomNumberGenerator.new()
	
	var num1 = rng.randi_range(1, 12)
	var num2 = rng.randi_range(1, 12)
	var operation = rng.randi_range(0, 1)
	
	var problem = ""
	var answer = 0
	
	if operation == 0:  # Multiplication
		problem = "%d × %d" % [num1, num2]
		answer = num1 * num2
	else:  # Division
		var product = num1 * num2
		problem = "%d ÷ %d" % [product, num1]
		answer = num2
	
	return {"problem": problem, "answer": answer}

func generate_rare_problem():
	var rng = RandomNumberGenerator.new()
	
	var problem_type = rng.randi_range(0, 2)
	var problem = ""
	var answer = 0
	
	match problem_type:
		0:  # Simple quadratic
			var a = rng.randi_range(1, 5)
			var b = rng.randi_range(1, 10)
			problem = "x² + %dx + %d = 0" % [b, a*b]
			answer = -a
		1:  # Factoring problem
			var factor1 = rng.randi_range(1, 5)
			var factor2 = rng.randi_range(1, 5)
			problem = "Factor: x² + %dx + %d" % [factor1 + factor2, factor1 * factor2]
			answer = factor1
		2:  # Simple polynomial evaluation
			var x = rng.randi_range(1, 5)
			var a = rng.randi_range(1, 5)
			var b = rng.randi_range(1, 10)
			var c = rng.randi_range(1, 20)
			problem = "Evaluate: %dx² + %dx + %d when x = %d" % [a, b, c, x]
			answer = a*x*x + b*x + c
	
	return {"problem": problem, "answer": answer}
