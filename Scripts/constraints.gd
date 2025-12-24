extends Control

const CONSTRAINT = preload("res://Scenes/constraint.tscn")

signal open_constraint_editor(screen)
signal go_back(screen)

var trying_to_delete = null
var edit_constraint = null
var selection_mode = false
var can_edit_composite = true
var selected_constraints = {}
var exclude_constraints = {}

var n_constraints = null
var n_search = null
var is_half_resolution = false

func _ready():
	n_constraints = $MainContents/ConstraintsMargin/ConstraintsContent/ConstraintsScroller/Constraints
	n_search = $MainContents/ConstraintsMargin/ConstraintsContent/SearchContainer
	$ConfirmDeletePopup.set_message_text("Constraint is being used as a sub-constraint--delete anyway?")


func set_half_resolution():
	is_half_resolution = true
	$MainContents.add_theme_constant_override("separation", 16)
	$MainContents/HeaderPanel/MarginContainer.add_theme_constant_override("margin_left", 15)
	$MainContents/HeaderPanel/MarginContainer.add_theme_constant_override("margin_top", 10)
	$MainContents/HeaderPanel/MarginContainer.add_theme_constant_override("margin_right", 15)
	$MainContents/HeaderPanel/MarginContainer/Header.add_theme_constant_override("separation", 10)
	$MainContents/HeaderPanel/MarginContainer/Header/BackButton.add_theme_font_size_override("font_size", 112)
	$MainContents/HeaderPanel/MarginContainer/Header/Header.label_settings = load("res://header_half.tres")
	$MainContents/HeaderPanel/MarginContainer/Header/NewConstraintMargin.add_theme_constant_override("margin_right", 12)
	$MainContents/HeaderPanel/MarginContainer/Header/NewConstraintMargin/NewConstraintButton.add_theme_font_size_override("font_size", 112)
	$MainContents/ConstraintsMargin.add_theme_constant_override("margin_left", 15)
	$MainContents/ConstraintsMargin.add_theme_constant_override("margin_right", 15)
	$MainContents/ConstraintsMargin/ConstraintsContent.add_theme_constant_override("separation", 8)
	$MainContents/ConstraintsMargin/ConstraintsContent/ConstraintsScroller/Constraints.add_theme_constant_override("separation", 8)
	$ConstraintTypePopup.set_half_resolution()
	$ConfirmDeletePopup.set_half_resolution()
	$MainContents/ConstraintsMargin/ConstraintsContent/SearchContainer.set_half_resolution()


func open(in_selection_mode=false, edit_composite=true):
	if not in_selection_mode:
		edit_constraint = null
	selection_mode = in_selection_mode
	can_edit_composite = edit_composite
	$MainContents/HeaderPanel/MarginContainer/Header/BackButton.visible = in_selection_mode
	$MainContents/ConstraintsMargin/ConstraintsContent/UseSelectedButton.visible = in_selection_mode
	show_constraints()
	visible = true


func show_constraints():
	print_debug("Refreshing constraints")
	for child in n_constraints.get_children():
		if child.name != "SearchContainer":
			child.queue_free()
	
	var search_text = n_search.get_search_text()
	
	for constraint_name in IO.constraints:
		if not Search.matches_search(constraint_name, search_text):
			continue
		
		if constraint_name in exclude_constraints:
			continue
		
		var new_constraint = CONSTRAINT.instantiate()
		new_constraint.set_constraint_name(constraint_name)
		new_constraint.set_constraint_type(IO.constraints[constraint_name]["type"])
		new_constraint.set_selection_mode(selection_mode)
		if constraint_name in selected_constraints:
			new_constraint.set_selected(true)
		new_constraint.constraint_checked.connect(_on_constraint_checked)
		new_constraint.deleted.connect(_on_constraint_deleted)
		new_constraint.constraint_selected.connect(_on_constraint_selected)
		if is_half_resolution:
			new_constraint.set_half_resolution()
		n_constraints.add_child(new_constraint)


func _on_constraint_checked(constraint, is_checked):
	if is_checked:
		selected_constraints[constraint.get_constraint_name()] = true
	else:
		selected_constraints.erase(constraint.get_constraint_name())


func _on_constraint_deleted(constraint):
	if IO.delete_constraint(constraint.get_constraint_name(), false):
		show_constraints()
	else:
		trying_to_delete = constraint
		get_tree().paused = true
		$ConfirmDeletePopup.visible = true


func _on_constraint_selected(constraint):
	edit_constraint = constraint.get_constraint_name()
	if constraint.get_constraint_type() == Enums.ConstraintType.PREF:
		open_constraint_editor.emit(Enums.Screen.PREFERENCE_CONSTRAINT_EDITOR)
	elif constraint.get_constraint_type() == Enums.ConstraintType.COMP:
		if can_edit_composite:
			open_constraint_editor.emit(Enums.Screen.COMPOSITE_CONSTRAINT_EDITOR)


func _on_new_constraint_button_pressed() -> void:
	get_tree().paused = true
	$ConstraintTypePopup.visible = true


func _on_search_container_search_changed() -> void:
	show_constraints()


func _on_constraint_type_popup_button_pressed(choice: Variant) -> void:
	get_tree().paused = false
	$ConstraintTypePopup.visible = false
	if choice == Enums.ConstraintType.PREF:
		open_constraint_editor.emit(Enums.Screen.PREFERENCE_CONSTRAINT_EDITOR)
	elif choice == Enums.ConstraintType.COMP:
		open_constraint_editor.emit(Enums.Screen.COMPOSITE_CONSTRAINT_EDITOR)


func _on_back_button_pressed() -> void:
	selected_constraints = {}
	exclude_constraints = {}
	go_back.emit(Enums.Screen.LAST)


func _on_use_selected_button_pressed() -> void:
	exclude_constraints = {}
	go_back.emit(Enums.Screen.LAST)


func _on_confirm_delete_popup_no_pressed() -> void:
	$ConfirmDeletePopup.visible = false
	get_tree().paused = false


func _on_confirm_delete_popup_yes_pressed() -> void:
	$ConfirmDeletePopup.visible = false
	get_tree().paused = false
	if IO.delete_constraint(trying_to_delete.get_constraint_name()):
		show_constraints()
	else:
		printerr("Something very bad happened")


func _on_constraints_scroller_scroll_started() -> void:
	for child in n_constraints.get_children():
		child.pressed = false
