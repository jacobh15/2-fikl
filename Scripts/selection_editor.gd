extends Control

const CONSTRAINT = preload("res://Scenes/constraint.tscn")

signal open_constraint_editor(screen)
signal open_constraints(screen)
signal go_back(screen)

var current_constraints = []
var decision_index = {}

var n_constraints = null
var n_decision = null
var n_done = null
var is_half_resolution = false


func _ready():
	n_constraints = $SelectionHistory/ContentMargin/Content/ContentMargin/ConstraintsPanel/ConstraintsContent/ConstraintsScroller/Constraints
	n_decision = $SelectionHistory/ContentMargin/Content/DecisionButton
	n_done = $SelectionHistory/ContentMargin/Content/DoneButton


func set_half_resolution():
	is_half_resolution = true
	theme = load("res://main_theme_half.tres")
	$SelectionHistory/HeaderPanel/MarginContainer.add_theme_constant_override("margin_left", 8)
	$SelectionHistory/HeaderPanel/MarginContainer.add_theme_constant_override("margin_top", 5)
	$SelectionHistory/HeaderPanel/MarginContainer.add_theme_constant_override("margin_right", 15)
	$SelectionHistory/HeaderPanel/MarginContainer/Header.add_theme_constant_override("separation", 10)
	$SelectionHistory/HeaderPanel/MarginContainer/Header/BackButton.add_theme_font_size_override("font_size", 112)
	$SelectionHistory/HeaderPanel/MarginContainer/Header/Header.label_settings = load("res://header_half.tres")
	$SelectionHistory/ContentMargin.add_theme_constant_override("margin_left", 8)
	$SelectionHistory/ContentMargin.add_theme_constant_override("margin_top", 8)
	$SelectionHistory/ContentMargin.add_theme_constant_override("margin_right", 8)
	$SelectionHistory/ContentMargin/Content.add_theme_constant_override("separation", 15)
	$SelectionHistory/ContentMargin/Content/ContentMargin.add_theme_constant_override("margin_left", 8)
	$SelectionHistory/ContentMargin/Content/ContentMargin.add_theme_constant_override("margin_top", 3)
	$SelectionHistory/ContentMargin/Content/ContentMargin.add_theme_constant_override("margin_right", 8)
	$SelectionHistory/ContentMargin/Content/ContentMargin.add_theme_constant_override("margin_bottom", 3)
	$SelectionHistory/ContentMargin/Content/ContentMargin/ConstraintsPanel/ConstraintsContent/AddConstrarintsButton.add_theme_font_size_override("font_size", 72)
	$SelectionHistory/ContentMargin/Content/ContentMargin/ConstraintsPanel/ConstraintsContent/ConstraintsScroller/Constraints.add_theme_constant_override("separation", 8)


func check_validity():
	return (n_decision.selected != 0)


func open(persist=false, initial=null):
	visible = true
	
	if not persist:
		decision_index = {}
		var i = 2
		n_decision.clear()
		n_decision.add_item("Set Decision")
		n_decision.add_separator()
		n_decision.selected = 0
		for decision in IO.decisions:
			decision_index[decision] = i
			i += 1
			n_decision.add_item(decision)
		
		current_constraints = []
		if initial != null:
			print_debug(initial)
			var decision = IO.selections[initial]["decision"]
			if decision in decision_index:
				n_decision.selected = decision_index[IO.selections[initial]["decision"]]
			for constraint in IO.selections[initial]["constraints"]:
				if constraint in IO.constraints:
					current_constraints.append(constraint)
	
	show_constraints()
	n_done.disabled = not check_validity()


func show_constraints():
	print_debug("Refreshing selection constraints")
	for child in n_constraints.get_children():
		child.queue_free()
	
	for constraint_name in current_constraints:
		var new_constraint = CONSTRAINT.instantiate()
		new_constraint.set_constraint_name(constraint_name)
		new_constraint.set_constraint_type(IO.constraints[constraint_name]["type"])
		new_constraint.set_selection_mode(false)
		new_constraint.deleted.connect(_on_constraint_deleted)
		new_constraint.constraint_selected.connect(_on_constraint_selected)
		if is_half_resolution:
			new_constraint.set_half_resolution()
		n_constraints.add_child(new_constraint)


func add_constraints(new_constraints):
	for constraint in new_constraints:
		current_constraints.append(constraint)


func _on_constraint_deleted(constraint):
	current_constraints.erase(constraint.get_constraint_name())


func _on_constraint_selected(constraint):
	if constraint.get_constraint_type() == Enums.ConstraintType.PREF:
		open_constraint_editor.emit(Enums.Screen.PREFERENCE_CONSTRAINT_EDITOR)
	elif constraint.get_constraint_type() == Enums.ConstraintType.COMP:
		open_constraint_editor.emit(Enums.Screen.COMPOSITE_CONSTRAINT_EDITOR)


func _on_back_button_pressed() -> void:
	visible = false
	go_back.emit(Enums.Screen.LAST)


func _on_add_constrarints_button_pressed() -> void:
	visible = false
	open_constraints.emit(Enums.Screen.CONSTRAINTS_SELECTOR)


func _on_decision_button_item_selected(_index: int) -> void:
	n_done.disabled = not check_validity()


func _on_done_button_pressed() -> void:
	get_tree().paused = true
	var decision = n_decision.get_item_text(n_decision.selected)
	var choice = Chooser.choose(decision, current_constraints)
	$ShowChoicePopup.set_choice(choice)
	IO.create_selection(choice, decision, current_constraints)
	$ShowChoicePopup.visible = true


func _on_show_choice_popup_done_clicked() -> void:
	$ShowChoicePopup.visible = false
	get_tree().paused = false
	visible = false
	go_back.emit(Enums.Screen.SELECTIONS)


func _on_constraints_scroller_scroll_started() -> void:
	for child in n_constraints.get_children():
		child.pressed = false
