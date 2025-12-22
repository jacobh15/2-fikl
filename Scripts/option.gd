extends PanelContainer

signal deleted(option_name)
signal option_selected(option)
signal option_checked(option, toggled)
signal option_preference_changed(option: Node, new_preference: float)

var pressed = true


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			pressed = true
		elif pressed:
			var test_rect = Rect2(Vector2.ZERO, get_rect().size);
			if test_rect.has_point(event.position):
				pressed = false
				accept_event()
				option_selected.emit(self)


func set_option_name(option_name: String) -> void:
	$Margin/Elements/Data/Content/NameLabel.text = option_name


func get_option_name() -> String:
	return $Margin/Elements/Data/Content/NameLabel.text


func set_option_preference(level: float) -> void:
	$Margin/Elements/Data/PreferenceSelection/SliderMargin/PreferenceSlider.value = level


func get_option_preference() -> float:
	return $Margin/Elements/Data/PreferenceSelection/SliderMargin/PreferenceSlider.value


func set_editable(editable: bool) -> void:
	$Margin/Elements/Data/PreferenceSelection.set_editable(editable)


func set_selection_mode(mode: bool) -> void:
	$Margin/Elements/SelectedCheck.visible = mode


func set_selected(selected: bool) -> void:
	$Margin/Elements/SelectedCheck.button_pressed = selected
	

func is_selected() -> bool:
	return $Margin/Elements/SelectedCheck.button_pressed


func _on_delete_pressed() -> void:
	deleted.emit(get_option_name())


func _on_selected_check_toggled(toggled_on: bool) -> void:
	option_checked.emit(self, toggled_on)


func _on_preference_selection_preference_changed(new_preference: float) -> void:
	option_preference_changed.emit(self, new_preference)
