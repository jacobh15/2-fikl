extends HBoxContainer

signal search_changed

func set_half_resolution():
	$SearchIcon.texture = load("res://Textures/Search64.png")
	$LineEdit/ClearButtonMargin.add_theme_constant_override("margin_right", 12)
	$LineEdit/ClearButtonMargin/ClearButton.add_theme_font_size_override("font_size", 48)


func _on_clear_button_pressed() -> void:
	if $LineEdit.text != "":
		$LineEdit.text = ""
		search_changed.emit()


func get_search_text():
	return $LineEdit.text


func _on_line_edit_text_changed(_new_text: String) -> void:
	search_changed.emit()
