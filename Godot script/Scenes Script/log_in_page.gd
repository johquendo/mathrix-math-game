extends Control

@onready var email_field: LineEdit = $Background/LogInContainer/FieldContainer/Email
@onready var password_field: LineEdit = $Background/LogInContainer/FieldContainer/Password
@onready var login_button: Button = $Background/LogInContainer/ButtonContainer/LogInButton
@onready var signup_button: Button = $Background/LogInContainer/ButtonContainer/SignInButton
@onready var login_text: Label = $Background/LogInContainer/LogInText

func _ready() -> void:
	password_field.secret = true
	login_button.pressed.connect(_on_LoginButton_pressed)
	signup_button.pressed.connect(_on_SignUpButton_pressed)
	email_field.text_submitted.connect(_on_enter_pressed)
	password_field.text_submitted.connect(_on_enter_pressed)

	# Connect Firebase signals
	Firebase.Auth.login_succeeded.connect(_on_login_success)
	Firebase.Auth.login_failed.connect(_on_login_error)

func _on_enter_pressed(_text=""):
	_on_LoginButton_pressed()

func show_error(message: String):
	login_text.text = message
	login_text.add_theme_color_override("font_color", Color.RED)

func show_success(message: String):
	login_text.text = message
	login_text.add_theme_color_override("font_color", Color.GREEN)

func clear_message():
	login_text.text = ""
	login_text.remove_theme_color_override("font_color")

func _on_LoginButton_pressed() -> void:
	var email = email_field.text.strip_edges()
	var password = password_field.text

	clear_message()

	if email.is_empty() or password.is_empty():
		show_error("Email and password are required.")
		return

	show_success("Logging in...")
	Firebase.Auth.login_with_email_and_password(email, password)

func _on_login_success(auth_info: Dictionary) -> void:
	show_success("Welcome back!")
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://Scenes/home_page_main.tscn")

func _on_login_error(code: int, message: String) -> void:
	show_error("Error: %s" % message)

func _on_SignUpButton_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/sign_up_page.tscn")




	
