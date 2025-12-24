extends MarginContainer

signal done_clicked


func set_half_resolution():
	add_theme_constant_override("margin_left", 65)
	add_theme_constant_override("margin_right", 65)
	$PanelContainer/ContentMargin.add_theme_constant_override("margin_left", 12)
	$PanelContainer/ContentMargin.add_theme_constant_override("margin_top", 12)
	$PanelContainer/ContentMargin.add_theme_constant_override("margin_right", 12)
	$PanelContainer/ContentMargin/Content/ChoiceLabel.add_theme_font_size_override("font_size", 84)
	$PanelContainer/ContentMargin/Content/DoneButton.add_theme_font_size_override("font_size", 64)
	$ShowChoicePopup.set_half_resolution()


func _on_done_button_pressed() -> void:
	done_clicked.emit()


func set_choice(choice: String) -> void:
	$PanelContainer/ContentMargin/Content/ChoiceLabel.text = choice
