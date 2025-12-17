extends MarginContainer

signal done_clicked


func _on_done_button_pressed() -> void:
	done_clicked.emit()


func set_choice(choice: String) -> void:
	$PanelContainer/ContentMargin/Content/ChoiceLabel.text = choice
