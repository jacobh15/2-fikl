extends PanelContainer

signal deleted(constraint)
signal constraint_selected(constraint)
signal constraint_checked(constraint: Node, is_checked: bool)


var type = null


func _on_delete_pressed() -> void:
	deleted.emit(self)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		accept_event()
		constraint_selected.emit(self)


func set_constraint_name(constraint_name: String) -> void:
	$Margin/Content/NameLabel.text = constraint_name


func get_constraint_name() -> String:
	return $Margin/Content/NameLabel.text


func set_constraint_type(constraint_type: Enums.ConstraintType):
	type = constraint_type
	if constraint_type == Enums.ConstraintType.PREF:
		$Margin/Content/TypeTexture.visible = false
	elif constraint_type == Enums.ConstraintType.COMP:
		$Margin/Content/TypeTexture.visible = true
	else:
		printerr("Somehow passed an invalid constraint type")


func get_constraint_type() -> Enums.ConstraintType:
	return type


func set_selection_mode(mode: bool) -> void:
	$Margin/Content/SelectedCheck.visible = mode


func set_selected(selected: bool) -> void:
	$Margin/Content/SelectedCheck.button_pressed = selected


func _on_selected_check_toggled(toggled_on: bool) -> void:
	constraint_checked.emit(self, toggled_on)
