extends MarginContainer

var current_screen = Enums.Screen.SELECTIONS
var last_screens = []


func _ready() -> void:
	var safe_area: Rect2i = DisplayServer.get_display_safe_area()
	var window_size: Vector2i = DisplayServer.window_get_size()

	# BASE MARGINS
	var top: int = 0
	var left: int = 0
	var bottom: int = 0
	var right: int = 0

	if window_size.x >= safe_area.size.x and window_size.y >= safe_area.size.y:
		var x_factor: float = size.x / window_size.x
		var y_factor: float = size.y / window_size.y
	
		top = max(top, safe_area.position.y * y_factor)
		left = max(left, safe_area.position.x * x_factor)
		bottom = max(bottom, abs(safe_area.end.y - window_size.y) * y_factor)
		right = max(right, abs(safe_area.end.x - window_size.x) * x_factor)

	add_theme_constant_override("margin_top", top)
	add_theme_constant_override("margin_left", left)
	add_theme_constant_override("margin_bottom", bottom)
	add_theme_constant_override("margin_right", right)


func _on_change_screen(screen: Enums.Screen) -> void:
	if screen == Enums.Screen.LAST:
		if len(last_screens) > 0:
			_on_change_screen(last_screens.pop_back())
			return
		else:
			print_debug("Attempting to go to last screen when stack is empty")
	elif screen == Enums.Screen.SELECTIONS:
		$TabContainer/Tabs.visible = true
		$TabContainer/TabBar.visible = true
		$TabContainer/TabBar/Selections.button_pressed = true
		$TabContainer/Tabs/Selections.open()
	elif screen == Enums.Screen.SELECTION_EDITOR:
		if current_screen != Enums.Screen.CONSTRAINTS_SELECTOR:
			last_screens.append(current_screen)
		
		var persist = false
		if current_screen == Enums.Screen.CONSTRAINTS_SELECTOR:
			persist = true
			$TabContainer/SelectionEditor.add_constraints($TabContainer/Tabs/Constraints.selected_constraints)
		
		$TabContainer/Tabs.visible = false
		$TabContainer/TabBar.visible = false
		$TabContainer/SelectionEditor.open(persist, $TabContainer/Tabs/Selections.copy_selection)
	elif screen == Enums.Screen.OPTION_EDITOR:
		last_screens.append(current_screen)
		$TabContainer/Tabs.visible = false
		$TabContainer/TabBar.visible = false
		$TabContainer/OptionEditor.open($TabContainer/Tabs/Options.edit_option)
	elif screen == Enums.Screen.OPTIONS:
		$TabContainer/Tabs.visible = true
		$TabContainer/TabBar.visible = true
		$TabContainer/TabBar/Options.button_pressed = true
		$TabContainer/Tabs/Options.open()
	elif screen == Enums.Screen.OPTIONS_SELECTOR:
		if current_screen != Enums.Screen.OPTION_EDITOR:
			last_screens.append(current_screen)
		
		if current_screen == Enums.Screen.DECISION_EDITOR:
			$TabContainer/Tabs/Options.selected_options = {}
			for option_name in $TabContainer/DecisionEditor.current_options:
				$TabContainer/Tabs/Options.exclude_options[option_name] = true
		
		if current_screen == Enums.Screen.PREFERENCE_CONSTRAINT_EDITOR:
			$TabContainer/Tabs/Options.selected_options = {}
			for option_name in $TabContainer/ConstraintEditor.current_options:
				$TabContainer/Tabs/Options.exclude_options[option_name] = true
		
		$TabContainer/Tabs.visible = true
		for child in $TabContainer/Tabs.get_children():
			if child.name == "Options":
				child.visible = true
			else:
				child.visible = false
		
		$TabContainer/TabBar.visible = false
		$TabContainer/DecisionEditor.visible = false
		$TabContainer/ConstraintEditor.visible = false
		$TabContainer/OptionEditor.visible = false
		$TabContainer/TabBar/Options.button_pressed = true
		$TabContainer/Tabs/Options.open(true)
	elif screen == Enums.Screen.DECISIONS:
		$TabContainer/Tabs.visible = true
		$TabContainer/TabBar.visible = true
		$TabContainer/TabBar/Decisions.button_pressed = true
		$TabContainer/Tabs/Decisions.open()
	elif screen == Enums.Screen.DECISION_EDITOR:
		if current_screen == Enums.Screen.DECISIONS:
			last_screens.append(current_screen)
		
		var persist = false
		if current_screen == Enums.Screen.OPTIONS_SELECTOR:
			persist = true
			$TabContainer/DecisionEditor.add_options($TabContainer/Tabs/Options.selected_options)
			$TabContainer/Tabs/Options.selected_options = {}
		
		$TabContainer/Tabs.visible = false
		$TabContainer/TabBar.visible = false
		$TabContainer/DecisionEditor.open($TabContainer/Tabs/Decisions.edit_decision, persist)
	elif screen == Enums.Screen.CONSTRAINTS:
		$TabContainer/Tabs.visible = true
		$TabContainer/TabBar.visible = true
		$TabContainer/TabBar/Constraints.button_pressed = true
		$TabContainer/Tabs/Constraints.open()
	elif screen == Enums.Screen.CONSTRAINTS_SELECTOR:
		if current_screen != Enums.Screen.PREFERENCE_CONSTRAINT_EDITOR:
			last_screens.append(current_screen)
		
		if current_screen == Enums.Screen.COMPOSITE_CONSTRAINT_EDITOR:
			$TabContainer/Tabs/Constraints.selected_constraints = {}
			var all_children = IO.get_children_recursive($TabContainer/ConstraintEditor.current_constraints)
			for constraint_name in all_children:
				$TabContainer/Tabs/Constraints.exclude_constraints[constraint_name] = true
			
			var c = $TabContainer/ConstraintEditor.get_editing_name()
			for constraint_name in IO.get_circular_sub_constraints(c):
				$TabContainer/Tabs/Constraints.exclude_constraints[constraint_name] = true
		
		$TabContainer/Tabs.visible = true
		for child in $TabContainer/Tabs.get_children():
			if child.name == "Constraints":
				child.visible = true
			else:
				child.visible = false
		
		$TabContainer/TabBar.visible = false
		$TabContainer/DecisionEditor.visible = false
		$TabContainer/ConstraintEditor.visible = false
		$TabContainer/OptionEditor.visible = false
		$TabContainer/TabBar/Constraints.button_pressed = true
		$TabContainer/Tabs/Constraints.open(true)
	elif screen == Enums.Screen.PREFERENCE_CONSTRAINT_EDITOR:
		if current_screen == Enums.Screen.CONSTRAINTS:
			last_screens.append(current_screen)
		
		var persist = false
		if current_screen == Enums.Screen.OPTIONS_SELECTOR:
			persist = true
			$TabContainer/ConstraintEditor.add_new_options($TabContainer/Tabs/Options.selected_options)
			$TabContainer/Tabs/Options.selected_options = {}
			
		$TabContainer/Tabs.visible = false
		$TabContainer/TabBar.visible = false
		$TabContainer/ConstraintEditor.open($TabContainer/Tabs/Constraints.edit_constraint, screen, persist)
	elif screen == Enums.Screen.COMPOSITE_CONSTRAINT_EDITOR:
		if current_screen == Enums.Screen.CONSTRAINTS:
			last_screens.append(current_screen)
		
		var persist = false
		if current_screen == Enums.Screen.CONSTRAINTS_SELECTOR:
			persist = true
			$TabContainer/ConstraintEditor.add_new_sub_constraints($TabContainer/Tabs/Constraints.selected_constraints)
			$TabContainer/Tabs/Constraints.selected_constraints = {}
			
		$TabContainer/Tabs.visible = false
		$TabContainer/TabBar.visible = false
		$TabContainer/ConstraintEditor.open($TabContainer/Tabs/Constraints.edit_constraint, screen, persist)
	
	current_screen = screen
	print_debug("Updated current screen: ", Enums.Screen.find_key(current_screen))
	print_debug(last_screens)
