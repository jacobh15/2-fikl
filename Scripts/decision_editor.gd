extends Control

signal go_back_after_creating(screen)
signal go_back_after_editing(screen)
signal go_back_after_discarding(screen)
signal go_to_options_selector(screen)

const OPTION = preload("res://Scenes/option.tscn")

var decision = null
var current_options = []

var n_options = null

func _ready():
	n_options = $ContentMargin/Content/ContentMargin/OptionsPanel/OptionsContent/OptionsScroller/Options


func check_validity():
	if len(current_options) == 0:
		return false
	
	var test_name = $ContentMargin/Content/NameEditor.text
	if test_name == "":
		return false
	
	if decision == null or decision.get_decision_name() != test_name:
		return test_name not in IO.decisions
	else:
		return true


func open(edit_decision, persist=false):
	visible = true
	decision = edit_decision
	if not persist:
		if edit_decision == null:
			$ContentMargin/Content/NameEditor.text = ""
			$ContentMargin/Content/MessageLabel.text = ""
			$ContentMargin/Content/MessageLabel.visible = false
			$ContentMargin/Content/DoneButton.text = "Tap to create"
			$HeaderPanel/MarginContainer/Header/Header.text = "New Decision"
		else:
			$ContentMargin/Content/NameEditor.text = decision.get_decision_name()
			$ContentMargin/Content/MessageLabel.text = ""
			$ContentMargin/Content/MessageLabel.visible = false
			$ContentMargin/Content/DoneButton.text = "Tap to update"
			$HeaderPanel/MarginContainer/Header/Header.text = "Edit Decision"
			add_options(IO.decisions[edit_decision.get_decision_name()])
	
	$ContentMargin/Content/DoneButton.disabled = not check_validity()
	show_options()


func show_options():
	for child in n_options.get_children():
		child.queue_free()
	
	for option_name in current_options:
		var option = OPTION.instantiate()
		option.set_option_name(option_name)
		option.set_option_preference(IO.options[option_name])
		option.set_editable(false)
		option.set_selection_mode(false)
		option.deleted.connect(_on_option_deleted)
		n_options.add_child(option)


func _on_option_deleted(option_name):
	current_options.erase(option_name)
	$ContentMargin/Content/DoneButton.disabled = not check_validity()
	show_options()


func _on_name_editor_text_changed(new_text: String) -> void:
	if new_text in IO.decisions:
		if decision == null or decision.get_decision_name() != new_text:
			$ContentMargin/Content/MessageLabel.visible = true
			$ContentMargin/Content/MessageLabel.text = "Name alreaady taken!"
			return
	
	$ContentMargin/Content/MessageLabel.text = ""
	$ContentMargin/Content/MessageLabel.visible = false
	$ContentMargin/Content/DoneButton.disabled = not check_validity()


func add_options(new_options) -> void:
	for option in new_options:
		current_options.append(option)


func _on_back_button_pressed() -> void:
	visible = false
	if decision == null:
		go_back_after_discarding.emit(Enums.Screen.LAST)
	else:
		go_back_after_editing.emit(Enums.Screen.LAST)
	current_options = []


func _on_done_button_pressed() -> void:
	var decision_name = $ContentMargin/Content/NameEditor.text
	
	if decision == null:
		if IO.create_decision(decision_name, current_options):
			visible = false
			go_back_after_creating.emit(Enums.Screen.LAST)
		else:
			$ContentMargin/Content/MessageLabel.visible = true
			$ContentMargin/Content/MessageLabel.text = "Something bad happened!"
	else:
		if IO.update_decision(decision.get_decision_name(), decision_name, current_options):
			visible = false
			go_back_after_creating.emit(Enums.Screen.LAST)
		else:
			$ContentMargin/Content/MessageLabel.visible = true
			$ContentMargin/Content/MessageLabel.text = "Something bad happened!"
	
	current_options = []


func _on_add_options_button_pressed() -> void:
	go_to_options_selector.emit(Enums.Screen.OPTIONS_SELECTOR)


func _on_options_scroller_scroll_started() -> void:
	for child in n_options.get_children():
		child.pressed = false
