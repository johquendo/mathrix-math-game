extends Node2D

# Timer that controls the initial "get ready" countdown before the game starts
@onready var start_timer: Timer = $StartTimer

# Reference to the actual gameplay scene (Node2D containing all the logic and game elements)
@onready var game: Node2D = $game

# UI layer that shows the "Get Ready" message and possibly other initial UI elements
@onready var interface: CanvasLayer = $Interface

# Reference to the in-game display layer which includes HP bars, keyboard, etc.
@onready var game_display: CanvasLayer = $game.get_node("Display")


func _ready() -> void:
	interface.visible = true # Show "Get ready…" message
	game_display.visible = false
	game.set_process(false) # Disable processing temporarily
	start_timer.start() # Begin the countdown before gameplay starts

	# Set correct level generator based on global GameState
	match Gamestate.selected_level:
		1:
			game.level_generator = $ProbGenerators/Level_1Generator # Set Level 1 generator
			game.get_node("ProblemTimers/Timer for Solving").wait_time = 15 # Shorter solve time for easier problems
		2:
			game.level_generator = $ProbGenerators/Lvl2Generator # Set Level 2 generator
			game.get_node("ProblemTimers/Timer for Solving").wait_time = 25
		3:
			game.level_generator = $ProbGenerators/Lvl3Generator # Set Level 3 generator
			game.get_node("ProblemTimers/Timer for Solving").wait_time = 40 # Harder problems get more time
	
	# Set fixed position for the problem label so it appears in a consistent screen location
	game.level_generator.position = Vector2(528, 134)


func _on_start_timer_timeout() -> void:
	interface.visible = false # Hide the label
	game_display.visible = true # Show actual game interface
	game.set_process(true) # Resume gameplay processing (start game logic)
