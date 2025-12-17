extends HBoxContainer

signal search_changed

func _on_clear_button_pressed() -> void:
	if $LineEdit.text != "":
		$LineEdit.text = ""
		search_changed.emit()


func get_search_text():
	return $LineEdit.text


func _on_line_edit_text_changed(_new_text: String) -> void:
	search_changed.emit()
