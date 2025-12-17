extends Control

signal go_to_selection_editor(screen)

const SELECTION = preload("res://Scenes/selection.tscn")

var n_selections = null
var copy_selection = null

func _ready():
	n_selections = $MainContents/SelectionsMargin/SelectionsScroller/SelectionHistory
	show_selections()


func open():
	copy_selection = null
	visible = true
	show_selections()


func show_selections():
	for child in n_selections.get_children():
		child.queue_free()
	
	for i in range(len(IO.selections) - 1, -1, -1):
		var new_selection = SELECTION.instantiate()
		new_selection.index = i
		var selection = IO.selections[i]
		new_selection.set_choice(selection["choice"])
		new_selection.set_decision(selection["decision"])
		new_selection.set_time(selection["time"])
		new_selection.selection_selected.connect(_on_selection_selected)
		new_selection.deleted.connect(_on_selection_deleted)
		n_selections.add_child(new_selection)


func _on_selection_deleted(selection):
	IO.delete_selection(selection.index)
	show_selections()


func _on_selection_selected(selection):
	copy_selection = selection.index
	go_to_selection_editor.emit(Enums.Screen.SELECTION_EDITOR)


func _on_new_selection_button_pressed() -> void:
	go_to_selection_editor.emit(Enums.Screen.SELECTION_EDITOR)
