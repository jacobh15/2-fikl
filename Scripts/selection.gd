extends PanelContainer

signal deleted(selection)
signal selection_selected(selection)

var index = null


func set_half_resolution():
	$ContentMargin/Data/ChoiceAndButtons/Delete.set_half_resolution()
	$ContentMargin/Data/ChoiceAndButtons/ChoiceLabel.theme = load("res://main_theme_half.tres")
	$ContentMargin/Data/DecisionAndTime/DecisionLabel.add_theme_font_size_override("font_size", 32)
	$ContentMargin/Data/DecisionAndTime/TimeLabel.add_theme_font_size_override("font_size", 24)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		accept_event()
		selection_selected.emit(self)


func _on_delete_button_pressed() -> void:
	deleted.emit(self)


func set_choice(choice: String):
	$ContentMargin/Data/ChoiceAndButtons/ChoiceLabel.text = choice


func set_decision(decision: String):
	$ContentMargin/Data/DecisionAndTime/DecisionLabel.text = decision


func set_time(timestamp: float):
	var tz = Time.get_time_zone_from_system()
	var time = Time.get_datetime_dict_from_unix_time(int(timestamp) + tz["bias"] * 60)
	var hour = null
	var meridian = null
	if time["hour"] <= 12:
		hour = time["hour"]
		meridian = "AM"
	else:
		hour = time["hour"] - 12
		meridian = "PM"
	var data = [hour, time["minute"], meridian, time["month"], time["day"], time["year"]]
	$ContentMargin/Data/DecisionAndTime/TimeLabel.text = "%d:%02d %s   %d/%d/%d" % data
