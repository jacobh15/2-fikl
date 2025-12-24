extends HBoxContainer

signal preference_changed(new_preference: float)

func set_half_resolution():
	theme = load("res://main_option_editing_theme_half.tres")
	$SliderMargin.add_theme_constant_override("margin_left", 8)
	$SliderMargin.add_theme_constant_override("margin_right", 4)


func set_editable(editable: bool) -> void:
	$SliderMargin/PreferenceSlider.editable = editable


func _on_preference_slider_value_changed(new_value):
	preference_changed.emit(new_value)
