extends PanelContainer

signal deleted
signal decision_selected(decision)

var pressed = true


func set_half_resolution():
	$Margin/Content/Delete.set_half_resolution()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			pressed = true
		elif pressed:
			var test_rect = Rect2(Vector2.ZERO, get_rect().size);
			if test_rect.has_point(event.position):
				pressed = false
				accept_event()
				decision_selected.emit(self)


func set_decision_name(decision_name: String) -> void:
	$Margin/Content/NameLabel.text = decision_name


func get_decision_name() -> String:
	return $Margin/Content/NameLabel.text


func _on_delete_pressed() -> void:
	if IO.delete_decision(get_decision_name()):
		deleted.emit()
		queue_free()
	else:
		printerr("Something very bad happened: could not delete decision")
