extends Control

@onready var start_button: Button = $StartButton
@onready var game_logo: TextureRect = $GameLogo
@onready var game_description: RichTextLabel = $GameDescription


func _ready() -> void:
	
	# Start idle pulse animation
	start_idle_animation()
	
	# Fade in logo
	game_logo.modulate.a = 0  # Start invisible
	var tween = create_tween()
	tween.tween_property(game_logo, "modulate:a", 1.0, 1.0).set_ease(Tween.EASE_IN_OUT)
	
	# Slide in description
	game_description.position.y -= 30  # Start off-screen	
	tween.tween_property(game_description, "position:y", game_description.position.y + 50, 0.8)

func start_idle_animation() -> void:
	var tween = create_tween()
	tween.set_loops()  # Loop forever
	tween.tween_property(start_button, "scale", Vector2(1.05, 1.05), 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(start_button, "scale", Vector2(1.0, 1.0), 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_button_mouse_entered() -> void:
	# Temporarily stop idle and scale up (overrides idle)
	var tween = create_tween()
	tween.tween_property(start_button, "scale", Vector2(1.1, 1.1), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_button_mouse_exited() -> void:
	# Scale back and restart idle
	var tween = create_tween()
	tween.tween_property(start_button, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(start_idle_animation)  # Restart idle after exiting

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/log_in_page.tscn")
