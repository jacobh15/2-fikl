extends Control

signal open_option_editor(screen)
signal go_back(screen)

const OPTION = preload("res://Scenes/option.tscn")
var trying_to_delete = null
var selection_mode = false
var edit_option = null
var selected_options = {}
var exclude_options = {}

var n_options = null
var n_search = null
var is_half_resolution = false

func _ready():
	n_options = $MainContents/OptionsMargin/OptionsContent/OptionsScroller/Options
	n_search = $MainContents/OptionsMargin/OptionsContent/SearchContainer


func set_half_resolution():
	is_half_resolution = true
	$MainContents.add_theme_constant_override("separation", 16)
	$MainContents/HeaderPanel/MarginContainer.add_theme_constant_override("margin_left", 15)
	$MainContents/HeaderPanel/MarginContainer.add_theme_constant_override("margin_top", 10)
	$MainContents/HeaderPanel/MarginContainer.add_theme_constant_override("margin_right", 15)
	$MainContents/HeaderPanel/MarginContainer/Header.add_theme_constant_override("separation", 10)
	$MainContents/HeaderPanel/MarginContainer/Header/BackButton.add_theme_font_size_override("font_size", 112)
	$MainContents/HeaderPanel/MarginContainer/Header/Header.label_settings = load("res://header_half.tres")
	$MainContents/HeaderPanel/MarginContainer/Header/NewOptionMargin.add_theme_constant_override("margin_right", 12)
	$MainContents/HeaderPanel/MarginContainer/Header/NewOptionMargin/NewOptionButton.add_theme_font_size_override("font_size", 112)
	$MainContents/OptionsMargin.add_theme_constant_override("margin_left", 15)
	$MainContents/OptionsMargin.add_theme_constant_override("margin_right", 15)
	$MainContents/OptionsMargin/OptionsContent.add_theme_constant_override("separation", 8)
	$MainContents/OptionsMargin/OptionsContent/OptionsScroller/Options.add_theme_constant_override("separation", 8)
	$ConfirmDeletePopup.set_half_resolution()
	$MainContents/OptionsMargin/OptionsContent/SearchContainer.set_half_resolution()


func open(in_selection_mode=false):
	selection_mode = in_selection_mode
	$MainContents/HeaderPanel/MarginContainer/Header/BackButton.visible = in_selection_mode
	$MainContents/OptionsMargin/OptionsContent/UseSelectedButton.visible = in_selection_mode
	edit_option = null
	show_options()


func show_options():
	print_debug("Refreshing options")
	for child in n_options.get_children():
		if child.name != "SearchContainer" and child.name != "UseSelectedButton":
			child.queue_free()
	
	var search_text = n_search.get_search_text()
	
	for option_name in IO.options:
		if not Search.matches_search(option_name, search_text):
			continue
		
		if option_name in exclude_options:
			continue
		
		var pref = IO.options[option_name]
		var new_option = OPTION.instantiate()
		new_option.set_selection_mode(selection_mode)
		new_option.set_option_name(option_name)
		new_option.set_option_preference(pref)
		new_option.set_editable(false)
		new_option.deleted.connect(show_options)
		new_option.deleted.connect(_on_option_deleted)
		new_option.option_selected.connect(_on_option_selected)
		new_option.option_checked.connect(_on_option_checked)
		
		if is_half_resolution:
			new_option.set_half_resolution()
		
		if selection_mode:
			if option_name in selected_options:
				new_option.set_selected(true)
		
		n_options.add_child(new_option)


func _on_option_checked(option, checked):
	if checked:
		selected_options[option.get_option_name()] = true
	else:
		selected_options.erase(option.get_option_name())


func _on_option_selected(option):
	edit_option = option
	open_option_editor.emit(Enums.Screen.OPTION_EDITOR)


func _on_new_option_button_pressed() -> void:
	open_option_editor.emit(Enums.Screen.OPTION_EDITOR)


func _on_no_button_pressed() -> void:
	trying_to_delete = null
	$ConfirmDeletePopup.visible = false
	get_tree().paused = false


func _on_option_deleted(option):
	if IO.delete_option(option, false):
		selected_options.erase(option)
		show_options()
	else:
		get_tree().paused = true
		$ConfirmDeletePopup.visible = true
		trying_to_delete = option
	

func _on_yes_button_pressed() -> void:
	if IO.delete_option(trying_to_delete):
		selected_options.erase(trying_to_delete)
		trying_to_delete = null
		$ConfirmDeletePopup.visible = false
		get_tree().paused = false
		show_options()
	else:
		printerr("Something bad happened")


func _on_search_container_search_changed() -> void:
	if visible:
		show_options()


func _on_back_button_pressed() -> void:
	selected_options = {}
	exclude_options = {}
	go_back.emit(Enums.Screen.LAST)


func _on_use_selected_button_pressed() -> void:
	exclude_options = {}
	go_back.emit(Enums.Screen.LAST)
