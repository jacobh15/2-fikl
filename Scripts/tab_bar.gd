extends Node

signal change_tab(new_tab)

func _ready() -> void:
	$Selections.button_group.pressed.connect(button_pressed)


func button_pressed(button):
	emit_signal("change_tab", button.name)


func set_half_resolution():
	self.theme = load("res://TabBar/theme_half.tres")
	$Selections.icon = load("res://Textures/Die96.png")
	$Decisions.icon = load("res://Textures/Fork96.png")
	$Options.icon = load("res://Textures/List96.png")
	$Constraints.icon = load("res://Textures/Lock96.png")
