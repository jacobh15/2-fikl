extends Node

signal change_tab(new_tab)

func _ready() -> void:
	$Selections.button_group.pressed.connect(button_pressed)

func button_pressed(button):
	emit_signal("change_tab", button.name)
