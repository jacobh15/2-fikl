extends MarginContainer

signal no_pressed
signal yes_pressed


func set_message_text(message: String) -> void:
	$PanelContainer/ContentMargin/Content/Label.text = message


func _on_no_button_pressed() -> void:
	no_pressed.emit()


func _on_yes_button_pressed() -> void:
	yes_pressed.emit()
