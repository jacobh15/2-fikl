extends Label

func _ready() -> void:
	var slider = get_parent().get_node("SliderMargin/PreferenceSlider")
	text = str(int(slider.value)) + "%"


func _on_preference_slider_value_changed(value: float) -> void:
	text = str(int(value)) + "%"
