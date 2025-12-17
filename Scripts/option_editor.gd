extends Control

signal go_back_after_creating(screen)
signal go_back_after_editing(screen)
signal go_back_after_discarding(screen)

var option = null

func open(edit_option):
	visible = true
	option = edit_option
	if edit_option == null:
		$ContentMargin/Content/NameEditor.text = ""
		$ContentMargin/Content/PreferenceSelection/SliderMargin/PreferenceSlider.value = 100
		$ContentMargin/Content/DoneButton.disabled = true
		$ContentMargin/Content/MessageLabel.text = ""
		$ContentMargin/Content/DoneButton.text = "Tap to create"
		$HeaderPanel/MarginContainer/Header/Header.text = "New Option"
	else:
		$ContentMargin/Content/NameEditor.text = option.get_option_name()
		$ContentMargin/Content/PreferenceSelection/SliderMargin/PreferenceSlider.value = option.get_option_preference()
		$ContentMargin/Content/DoneButton.disabled = false
		$ContentMargin/Content/MessageLabel.text = ""
		$ContentMargin/Content/DoneButton.text = "Tap to update"
		$HeaderPanel/MarginContainer/Header/Header.text = "Edit Option"


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
	elif option_name in IO.options:
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
		if IO.update_option(option.get_option_name(), option_name, option_pref):
			visible = false
			go_back_after_creating.emit(Enums.Screen.LAST)
		else:
			$ContentMargin/Content/MessageLabel.text = "Something bad happened!"
