extends Node

var current_tab = null

signal change_screen(screen)

func _ready():
	current_tab = $Selections


func set_current_tab(tab_node):
	current_tab.visible = false
	current_tab = tab_node
	current_tab.visible = true


func _on_tab_bar_change_tab(tab_name) -> void:
	if tab_name == "Selections":
		print_debug("Switching to \"Selections\"")
		set_current_tab($Selections)
		change_screen.emit(Enums.Screen.SELECTIONS)
	elif tab_name == "Decisions":
		print_debug("Switching to \"Decisions\"")
		set_current_tab($Decisions)
		change_screen.emit(Enums.Screen.DECISIONS)
	elif tab_name == "Options":
		print_debug("Switching to \"Options\"")
		set_current_tab($Options)
		change_screen.emit(Enums.Screen.OPTIONS)
	elif tab_name == "Constraints":
		print_debug("Switching to \"Constraints\"")
		set_current_tab($Constraints)
		change_screen.emit(Enums.Screen.CONSTRAINTS)
	elif tab_name == "Settings":
		print_debug("Switching to \"Settings\"")
		set_current_tab($Settings)
		change_screen.emit(Enums.Screen.SETTINGS)
	else:
		printerr("Attempt to switch to invalid tab")
