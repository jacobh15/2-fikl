extends Node


func matches_search(option_name: String, search_text):
	if len(search_text) == 0:
		return true
	else:
		return search_text.to_lower() in option_name.to_lower()
