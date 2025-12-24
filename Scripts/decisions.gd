extends Control

const DECISION = preload("res://Scenes/decision.tscn")

signal open_decision_editor(screen)

var trying_to_delete = null
var edit_decision = null

var n_search = null
var n_decisions = null
var is_half_resolution = false


func _ready():
	n_search = $MainContents/DecisionsMargin/Content/SearchContainer
	n_decisions = $MainContents/DecisionsMargin/Content/DecisionsScroller/Decisions


func set_half_resolution():
	is_half_resolution = true
	$MainContents.add_theme_constant_override("separation", 16)
	$MainContents/HeaderPanel/MarginContainer.add_theme_constant_override("margin_left", 15)
	$MainContents/HeaderPanel/MarginContainer.add_theme_constant_override("margin_top", 10)
	$MainContents/HeaderPanel/MarginContainer.add_theme_constant_override("margin_right", 15)
	$MainContents/HeaderPanel/MarginContainer/Header/Header.label_settings = load("res://header_half.tres")
	$MainContents/HeaderPanel/MarginContainer/Header/NewDecisionMargin.add_theme_constant_override("margin_right", 12)
	$MainContents/HeaderPanel/MarginContainer/Header/NewDecisionMargin/NewDecisionButton.add_theme_font_size_override("font_size", 112)
	$MainContents/DecisionsMargin.add_theme_constant_override("margin_left", 15)
	$MainContents/DecisionsMargin.add_theme_constant_override("margin_right", 15)
	$MainContents/DecisionsMargin/Content.add_theme_constant_override("separation", 8)
	$MainContents/DecisionsMargin/Content/DecisionsScroller/Decisions.add_theme_constant_override("separation", 8)
	$MainContents/DecisionsMargin/Content/SearchContainer.set_half_resolution()


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
		if is_half_resolution:
			new_decision.set_half_resolution()
		n_decisions.add_child(new_decision)


func _on_decision_selected(decision):
	edit_decision = decision
	open_decision_editor.emit(Enums.Screen.DECISION_EDITOR)


func _on_new_decision_button_pressed() -> void:
	open_decision_editor.emit(Enums.Screen.DECISION_EDITOR)


func _on_search_container_search_changed() -> void:
	show_decisions()


func _on_decisions_scroller_scroll_started() -> void:
	for child in n_decisions.get_children():
		child.pressed = false
