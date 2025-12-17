extends LineEdit

var suggestions = ["abc", "def", "hello"]

func _on_text_changed(new_text: String) -> void:
	if new_text != "":
		for suggestion in suggestions:
			if suggestion.begins_with(new_text):
				get_node("../Suggestion").text = suggestion
				return
	
	get_node("../Suggestion").text = ""


func _on_text_submitted(new_text: String) -> void:
	if new_text != "":
		for suggestion in suggestions:
			if suggestion.begins_with(new_text):
				text = suggestion
				return
