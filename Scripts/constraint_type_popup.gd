extends MarginContainer

signal button_pressed(choice)


func _on_preference_button_pressed() -> void:
	button_pressed.emit(Enums.ConstraintType.PREF)


func _on_composite_button_pressed() -> void:
	button_pressed.emit(Enums.ConstraintType.COMP)


func _on_cancel_button_pressed() -> void:
	button_pressed.emit(null)
