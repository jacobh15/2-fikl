extends Control

signal go_back_after_creating(screen)
signal go_back_after_editing(screen)
signal go_back_after_discarding(screen)

var option = null
var constraint = null

func set_half_resolution():
	theme = load("res://main_theme_half.tres")
	$HeaderPanel/MarginContainer.add_theme_constant_override("margin_left", 8)
	$HeaderPanel/MarginContainer.add_theme_constant_override("margin_top", 5)
	$HeaderPanel/MarginContainer.add_theme_constant_override("margin_right", 15)
	$HeaderPanel/MarginContainer/Header.add_theme_constant_override("separation", 10)
	$HeaderPanel/MarginContainer/Header/BackButton.add_theme_font_size_override("font_size", 112)
	$HeaderPanel/MarginContainer/Header/Header.label_settings = load("res://header_half.tres")
	$ContentMargin.add_theme_constant_override("margin_left", 8)
	$ContentMargin.add_theme_constant_override("margin_top", 8)
	$ContentMargin.add_theme_constant_override("margin_right", 8)
	$ContentMargin/Content.add_theme_constant_override("separation", 15)
	$ContentMargin/Content/PreferenceSelection.set_half_resolution()


func open(edit_option, edit_constraint=null):
	visible = true
	constraint = edit_constraint
	option = edit_option
	if edit_option == null:
		$ContentMargin/Content/NameEditor.text = ""
		$ContentMargin/Content/NameEditor.editable = true
		$ContentMargin/Content/NameEditor.focus_mode = FocusMode.FOCUS_ALL
		$ContentMargin/Content/PreferenceSelection/SliderMargin/PreferenceSlider.value = 100
		$ContentMargin/Content/DoneButton.disabled = true
		$ContentMargin/Content/MessageLabel.text = ""
		$ContentMargin/Content/DoneButton.text = "Tap to create"
		$HeaderPanel/MarginContainer/Header/Header.text = "New Option"
	elif edit_constraint == null:
		$ContentMargin/Content/NameEditor.text = option.get_option_name()
		$ContentMargin/Content/NameEditor.editable = true
		$ContentMargin/Content/NameEditor.focus_mode = FocusMode.FOCUS_ALL
		$ContentMargin/Content/PreferenceSelection/SliderMargin/PreferenceSlider.value = option.get_option_preference()
		$ContentMargin/Content/DoneButton.disabled = false
		$ContentMargin/Content/MessageLabel.text = ""
		$ContentMargin/Content/DoneButton.text = "Tap to update"
		$HeaderPanel/MarginContainer/Header/Header.text = "Edit Option"
	else:
		$ContentMargin/Content/NameEditor.text = option.get_option_name()
		$ContentMargin/Content/NameEditor.editable = false
		$ContentMargin/Content/NameEditor.focus_mode = FocusMode.FOCUS_NONE
		$ContentMargin/Content/PreferenceSelection/SliderMargin/PreferenceSlider.value = option.get_option_preference()
		$ContentMargin/Content/DoneButton.disabled = false
		$ContentMargin/Content/MessageLabel.text = ""
		$ContentMargin/Content/DoneButton.text = "Tap to update"
		$HeaderPanel/MarginContainer/Header/Header.text = "Edit Preference"


func _on_name_editor_text_changed(new_text: String) -> void:
	if new_text in IO.options:
		if option == null or option.get_option_name() != new_text:
			$ContentMargin/Content/MessageLabel.text = "Name alreaady taken!"
			$ContentMargin/Content/DoneButton.disabled = true
			return
	
	$ContentMargin/Content/MessageLabel.text = ""
	$ContentMargin/Content/DoneButton.disabled = (len(new_text) == 0)


func _on_back_button_pressed() -> void:
	visible = false
	if option == null:
		go_back_after_discarding.emit(Enums.Screen.LAST)
	else:
		go_back_after_editing.emit(Enums.Screen.LAST)


func _on_done_button_pressed() -> void:
	var option_name = $ContentMargin/Content/NameEditor.text
	if option_name == "":
		$ContentMargin/Content/MessageLabel.text = "Please enter a name"
	elif constraint == null and option_name in IO.options:
		$ContentMargin/Content/MessageLabel.text = "Must use a unique name"
	
	var option_pref = $ContentMargin/Content/PreferenceSelection/SliderMargin/PreferenceSlider.value
	$ContentMargin/Content/MessageLabel.text = "Creating..."
	
	if option == null:
		if IO.create_option(option_name, option_pref):
			visible = false
			go_back_after_creating.emit(Enums.Screen.LAST)
		else:
			$ContentMargin/Content/MessageLabel.text = "Something bad happened!"
	else:
		if constraint == null:
			if IO.update_option(option.get_option_name(), option_name, option_pref):
				visible = false
				go_back_after_editing.emit(Enums.Screen.LAST)
			else:
				$ContentMargin/Content/MessageLabel.text = "Something bad happened!"
		else:
			var old_options = IO.constraints[constraint]["options"]
			old_options[option.get_option_name()] = option_pref
			if IO.update_preference_constraint(constraint, constraint, old_options):
				visible = false
				go_back_after_editing.emit(Enums.Screen.LAST)
			else:
				$ContentMargin/Content/MessageLabel.text = "Something bad happened!"
