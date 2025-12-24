extends MarginContainer

signal button_pressed(choice)

func set_half_resolution():
	$PanelContainer/ContentMargin.add_theme_constant_override("margin_left", 12)
	$PanelContainer/ContentMargin.add_theme_constant_override("margin_top", 12)
	$PanelContainer/ContentMargin.add_theme_constant_override("margin_right", 12)
	$PanelContainer/ContentMargin/Content/Buttons/PreferenceButton.add_theme_font_size_override("font_size",  112)
	$PanelContainer/ContentMargin/Content/Buttons/CompositeButton.add_theme_font_size_override("font_size",  112)
	$PanelContainer/ContentMargin/Content/Buttons/CancelButton.add_theme_font_size_override("font_size",  112)
	add_theme_constant_override("margin_left", 65)
	add_theme_constant_override("margin_right", 65)


func _on_preference_button_pressed() -> void:
	button_pressed.emit(Enums.ConstraintType.PREF)


func _on_composite_button_pressed() -> void:
	button_pressed.emit(Enums.ConstraintType.COMP)


func _on_cancel_button_pressed() -> void:
	button_pressed.emit(null)
