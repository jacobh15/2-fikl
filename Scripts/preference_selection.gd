extends HBoxContainer

signal preference_changed(new_preference: float)

func set_editable(editable: bool) -> void:
	$SliderMargin/PreferenceSlider.editable = editable


func _on_preference_slider_value_changed(new_value):
	preference_changed.emit(new_value)
