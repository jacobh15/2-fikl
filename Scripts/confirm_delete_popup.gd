extends MarginContainer

signal no_pressed
signal yes_pressed


func set_message_text(message: String) -> void:
	$PanelContainer/ContentMargin/Content/Label.text = message


func set_half_resolution():
	$PanelContainer/ContentMargin.add_theme_constant_override("margin_left", 12)
	$PanelContainer/ContentMargin.add_theme_constant_override("margin_top", 12)
	$PanelContainer/ContentMargin.add_theme_constant_override("margin_right", 12)
	$PanelContainer/ContentMargin/Content/Buttons/NoButton.add_theme_font_size_override("font_size", 112)
	$PanelContainer/ContentMargin/Content/Buttons/YesButton.add_theme_font_size_override("font_size", 112)
	add_theme_constant_override("margin_left", 65)
	add_theme_constant_override("margin_right", 65)


func _on_no_button_pressed() -> void:
	no_pressed.emit()


func _on_yes_button_pressed() -> void:
	yes_pressed.emit()
