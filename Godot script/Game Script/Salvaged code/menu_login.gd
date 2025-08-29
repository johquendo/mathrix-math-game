extends Control

@onready var username_field: LineEdit = $LogInContainer/InputContainer/Username
@onready var password_field: LineEdit = $LogInContainer/InputContainer/Password
@onready var login_button: Button = $LogInContainer/InputContainer/LogInButton
@onready var login_text: Label = $LogInContainer/InputContainer/LogInText

var config := ConfigFile.new()
const FILE_PATH := "user://players.cfg"

func _ready():
	password_field.secret_mode_enabled = true

	var err = config.load(FILE_PATH)
	if err != OK:
		print("No config file found, creating new one.")
		config.save(FILE_PATH)

func _on_LogInButton_pressed():
	var username = username_field.text.strip_edges().to_upper()
	var password = password_field.text

	if username.is_empty() or password.is_empty():
		login_text.text = "Fields cannot be empty."
		return

	if not config.has_section_key("users", username):
		login_text.text = "No account found."
		return

	var saved_hash = config.get_value("users", username)
	if saved_hash == password.sha256_text():
		login_text.text = "Login successful!"
	else:
		login_text.text = "Incorrect password."
		
	







		
