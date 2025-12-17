extends VBoxContainer

signal go_back_after_creating(screen)
signal go_back_after_editing(screen)
signal go_back_after_discarding(screen)
signal go_to_options_selector(screen)
signal go_to_constraints_selector(screen)

const OPTION = preload("res://Scenes/option.tscn")
const CONSTRAINT = preload("res://Scenes/constraint.tscn")

var constraint = null
var current_options = {}
var current_constraints = []
var current_screen = Enums.Screen.PREFERENCE_CONSTRAINT_EDITOR

var n_options = null

func _ready():
	n_options = $ContentMargin/Content/ContentMargin/OptionsPanel/OptionsContent/OptionsScroller/Options


func check_validity():
	if current_screen == Enums.Screen.PREFERENCE_CONSTRAINT_EDITOR:
		if len(current_options) == 0:
			return false
	elif current_screen == Enums.Screen.COMPOSITE_CONSTRAINT_EDITOR:
		if len(current_constraints) == 0:
			return false
	
	var test_name = $ContentMargin/Content/NameEditor.text
	if test_name == "":
		return false
	
	if constraint == null or constraint != test_name:
		return test_name not in IO.constraints
	else:
		return true


func get_editing_name():
	if constraint == null:
		return ""
	else:
		return constraint


func open(edit_constraint, screen, persist=false):
	current_screen = screen
	constraint = edit_constraint
	if screen == Enums.Screen.PREFERENCE_CONSTRAINT_EDITOR:
		$ContentMargin/Content/PrefLabel.text = "Add preferences"
		if constraint != null and not persist:
			add_options(IO.constraints[constraint])
	elif screen == Enums.Screen.COMPOSITE_CONSTRAINT_EDITOR:
		$ContentMargin/Content/PrefLabel.text = "Add sub-constraints"
		if constraint != null and not persist:
			add_sub_constraints(IO.constraints[constraint])
	else:
		printerr("Something bad happened")
	
	if not persist:
		if edit_constraint == null:
			$ContentMargin/Content/NameEditor.text = ""
			$ContentMargin/Content/MessageLabel.text = ""
			$ContentMargin/Content/MessageLabel.visible = false
			$ContentMargin/Content/DoneButton.text = "Tap to create"
			$HeaderPanel/MarginContainer/Header/Header.text = "New Constraint"
		else:
			$ContentMargin/Content/NameEditor.text = constraint
			$ContentMargin/Content/MessageLabel.text = ""
			$ContentMargin/Content/MessageLabel.visible = false
			$ContentMargin/Content/DoneButton.text = "Tap to update"
			$HeaderPanel/MarginContainer/Header/Header.text = "Edit Constraint"
	
	$ContentMargin/Content/DoneButton.disabled = not check_validity()
	refresh_list()
	visible = true


func refresh_list():
	print("Refreshing constraint items")
	for child in n_options.get_children():
		child.queue_free()
	
	if current_screen == Enums.Screen.PREFERENCE_CONSTRAINT_EDITOR:
		for option_name in current_options:
			var option = OPTION.instantiate()
			option.set_option_name(option_name)
			option.set_option_preference(current_options[option_name])
			option.set_editable(true)
			option.set_selection_mode(false)
			option.deleted.connect(_on_option_deleted)
			option.option_preference_changed.connect(_on_option_preference_changed)
			n_options.add_child(option)
	elif current_screen == Enums.Screen.COMPOSITE_CONSTRAINT_EDITOR:
		for constraint_name in current_constraints:
			var new_constraint = CONSTRAINT.instantiate()
			new_constraint.set_constraint_name(constraint_name)
			new_constraint.deleted.connect(_on_constraint_deleted)
			n_options.add_child(new_constraint)


func _on_option_preference_changed(option, new_preference):
	current_options[option.get_option_name()] = new_preference


func _on_constraint_deleted(constraint_node):
	current_constraints.erase(constraint_node.get_constraint_name())
	$ContentMargin/Content/DoneButton.disabled = not check_validity()
	refresh_list()


func _on_option_deleted(option_name):
	current_options.erase(option_name)
	$ContentMargin/Content/DoneButton.disabled = not check_validity()
	refresh_list()


func _on_name_editor_text_changed(new_text: String) -> void:
	if new_text in IO.constraints:
		if constraint == null or constraint != new_text:
			$ContentMargin/Content/MessageLabel.visible = true
			$ContentMargin/Content/MessageLabel.text = "Name alreaady taken!"
			return
	
	$ContentMargin/Content/MessageLabel.text = ""
	$ContentMargin/Content/MessageLabel.visible = false
	$ContentMargin/Content/DoneButton.disabled = not check_validity()


func add_options(from_constraint) -> void:
	for option in from_constraint["options"]:
		current_options[option] = from_constraint["options"][option]


func add_new_options(options) -> void:
	for option in options:
		current_options[option] = 100


func add_sub_constraints(from_constraint) -> void:
	for sub in from_constraint["sub"]:
		current_constraints.append(sub)


func add_new_sub_constraints(constraints) -> void:
	for sub in constraints:
		current_constraints.append(sub)


func _on_back_button_pressed() -> void:
	visible = false
	if constraint == null:
		go_back_after_discarding.emit(Enums.Screen.LAST)
	else:
		go_back_after_editing.emit(Enums.Screen.LAST)
	current_options = {}
	current_constraints = []


func _on_done_button_pressed() -> void:
	var constraint_name = $ContentMargin/Content/NameEditor.text
	
	if constraint == null:
		if current_screen == Enums.Screen.PREFERENCE_CONSTRAINT_EDITOR:
			var options = current_options.keys()
			var current_preferences = []
			for option in options:
				current_preferences.append(current_options[option])
			if IO.create_preference_constraint(constraint_name, options, current_preferences):
				visible = false
				go_back_after_creating.emit(Enums.Screen.LAST)
			else:
				$ContentMargin/Content/MessageLabel.visible = true
				$ContentMargin/Content/MessageLabel.text = "Something bad happened!"
		elif current_screen == Enums.Screen.COMPOSITE_CONSTRAINT_EDITOR:
			if IO.create_composite_constraint(constraint_name, current_constraints):
				visible = false
				go_back_after_creating.emit(Enums.Screen.LAST)
			else:
				$ContentMargin/Content/MessageLabel.visible = true
				$ContentMargin/Content/MessageLabel.text = "Something bad happened!"
		else:
			printerr("You did something stupid")
	else:
		if current_screen == Enums.Screen.PREFERENCE_CONSTRAINT_EDITOR:
			if IO.update_preference_constraint(constraint, constraint_name, current_options):
				visible = false
				go_back_after_editing.emit(Enums.Screen.LAST)
			else:
				$ContentMargin/Content/MessageLabel.visible = true
				$ContentMargin/Content/MessageLabel.text = "Something bad happened!"
		elif current_screen == Enums.Screen.COMPOSITE_CONSTRAINT_EDITOR:
			if IO.update_composite_constraint(constraint, constraint_name, current_constraints):
				visible = false
				go_back_after_editing.emit(Enums.Screen.LAST)
			else:
				$ContentMargin/Content/MessageLabel.visible = true
				$ContentMargin/Content/MessageLabel.text = "Something bad happened!"
		else:
			printerr("you did something stupid")
		
	current_options = {}
	current_constraints = []


func _on_add_options_button_pressed() -> void:
	if current_screen == Enums.Screen.PREFERENCE_CONSTRAINT_EDITOR:
		go_to_options_selector.emit(Enums.Screen.OPTIONS_SELECTOR)
	elif current_screen == Enums.Screen.COMPOSITE_CONSTRAINT_EDITOR:
		go_to_constraints_selector.emit(Enums.Screen.CONSTRAINTS_SELECTOR)
