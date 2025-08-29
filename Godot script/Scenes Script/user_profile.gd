extends Control

@onready var view_plot_button = $Background/ScrollContainer/ScrollMargin/ProfileItemsContainer/MainProfileContainer/ButtonContainer/ButtonMargin/ViewPlotButton
@onready var log_out_button = $Background/ScrollContainer/ScrollMargin/ProfileItemsContainer/MainProfileContainer/ButtonContainer/ButtonMargin/LogOutButton
@onready var edit_profile_button = $Background/ScrollContainer/ScrollMargin/ProfileItemsContainer/MainProfileContainer/ButtonContainer/ButtonMargin2/EditProfileButton
@onready var log_out_pop_up = $Background/LogOutConfirmation
@onready var scrollcontainer = $Background/ScrollContainer

# test case for viewing own profile or not
var own_profile = true

func _ready() -> void:
	log_out_pop_up.visible = false
	
	if own_profile:
		view_plot_button.disabled = true
		view_plot_button.visible = false
	else:
		log_out_button.disabled = true
		log_out_button.visible = false
		edit_profile_button.disabled = true
		edit_profile_button.visible = false
		
func _on_log_out_button_button_down() -> void:
	log_out_pop_up.visible = true
	scrollcontainer.mouse_filter = MOUSE_FILTER_IGNORE
	
func _on_cancel_button_down() -> void:
	log_out_pop_up.visible = false
	scrollcontainer.mouse_filter = MOUSE_FILTER_STOP
