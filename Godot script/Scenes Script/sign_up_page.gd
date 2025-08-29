extends Control

@onready var username_field: LineEdit = $Background/LogInContainer/InputContainer/Username
@onready var email_field: LineEdit = $Background/LogInContainer/InputContainer/Email
@onready var password_field: LineEdit = $Background/LogInContainer/InputContainer/Password
@onready var confirm_field: LineEdit = $Background/LogInContainer/InputContainer/ConfirmPassword
@onready var create_button: Button = $Background/LogInContainer/InputContainer/CreateAccountButton
@onready var back_button: Button = $Background/LogInContainer/InputContainer/BackButton
@onready var signup_text: Label = $Background/LogInContainer/SignUpText

var signup_username: String = ""  # store username temporarily

func _ready() -> void:
	create_button.pressed.connect(_on_CreateButton_pressed)
	back_button.pressed.connect(_on_BackButton_pressed)
	email_field.text_submitted.connect(_on_enter_pressed)
	password_field.text_submitted.connect(_on_enter_pressed)
	confirm_field.text_submitted.connect(_on_enter_pressed)
	username_field.text_submitted.connect(_on_enter_pressed)

	# Firebase Auth signals
	Firebase.Auth.signup_succeeded.connect(_on_signup_success)
	Firebase.Auth.signup_failed.connect(_on_signup_error)

func _on_enter_pressed(_text=""):
	_on_CreateButton_pressed()

func show_error(message: String):
	signup_text.text = message
	signup_text.add_theme_color_override("font_color", Color.RED)

func show_success(message: String):
	signup_text.text = message
	signup_text.add_theme_color_override("font_color", Color.GREEN)

func clear_message():
	signup_text.text = ""
	signup_text.remove_theme_color_override("font_color")

func _on_CreateButton_pressed() -> void:
	signup_username = username_field.text.strip_edges()
	var email = email_field.text.strip_edges()
	var password = password_field.text
	var confirm = confirm_field.text

	clear_message()

	if signup_username.is_empty() or email.is_empty() or password.is_empty() or confirm.is_empty():
		show_error("All fields are required.")
		return

	if password != confirm:
		show_error("Passwords do not match.")
		return

	show_success("Creating account...")
	Firebase.Auth.signup_with_email_and_password(email, password)

func _on_signup_success(auth_info: Dictionary) -> void:
	show_success("Account created!")

	# Save username, items, and coins to Firestore collection "user_data"
	var user_data = {
		"username": signup_username,
		"items": [],
		"coins": 1000
	}

	# Add document to "user_data" collection (auto-generated ID)
	var collection = Firebase.Firestore.collection("user_data")
	var document = await collection.add("", user_data)
	if document:
		print("User data saved successfully!")
	else:
		print("Failed to save user data.")

	await get_tree().create_timer(1.0).timeout
	# Auto-login after signup
	Firebase.Auth.login_with_email_and_password(email_field.text.strip_edges(), password_field.text)
	get_tree().change_scene_to_file("res://Scenes/home_page_main.tscn")

func _on_signup_error(code: int, message: String) -> void:
	show_error("Error: %s" % message)

func _on_BackButton_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/log_in_page.tscn")
