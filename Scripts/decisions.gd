extends Control

const DECISION = preload("res://Scenes/decision.tscn")

signal open_decision_editor(screen)

var trying_to_delete = null
var edit_decision = null

var n_search = null
var n_decisions = null


func _ready():
	n_search = $MainContents/DecisionsMargin/Content/SearchContainer
	n_decisions = $MainContents/DecisionsMargin/Content/DecisionsScroller/Decisions


func open():
	visible = true
	edit_decision = null
	show_decisions()


func show_decisions():
	print_debug("Refreshing decisions")
	for child in n_decisions.get_children():
		child.queue_free()
	
	var search_text = n_search.get_search_text()
	
	for decision_name in IO.decisions:
		if not Search.matches_search(decision_name, search_text):
			continue
		
		var new_decision = DECISION.instantiate()
		new_decision.set_decision_name(decision_name)
		new_decision.deleted.connect(show_decisions)
		new_decision.decision_selected.connect(_on_decision_selected)
		n_decisions.add_child(new_decision)


func _on_decision_selected(decision):
	edit_decision = decision
	open_decision_editor.emit(Enums.Screen.DECISION_EDITOR)


func _on_new_decision_button_pressed() -> void:
	open_decision_editor.emit(Enums.Screen.DECISION_EDITOR)


func _on_search_container_search_changed() -> void:
	show_decisions()
