extends Node

const OPTIONS_PATH = "user://options.json"
var options = {}

const DECISIONS_PATH = "user://decisions.json"
var decisions = {}
var decisions_index = {}

const CONSTRAINTS_PATH = "user://constraints.json"
var constraints = {}
var constraints_index = {}
var sub_constraints_index = {}

const SELECTIONS_PATH = "user://selections.json"
const SELECTION_HISTORY_SIZE = 200
var selections = []


func _ready() -> void:
	if not FileAccess.file_exists(OPTIONS_PATH):
		save_options()
	else:
		load_options()
	
	if not FileAccess.file_exists(DECISIONS_PATH):
		save_decisions()
	else:
		load_decisions()
		
	if not FileAccess.file_exists(CONSTRAINTS_PATH):
		save_constraints()
	else:
		load_constraints()
		
	if not FileAccess.file_exists(SELECTIONS_PATH):
		save_selections()
	else:
		load_selections()


func save_options():
	var f = FileAccess.open(OPTIONS_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(options))
	f.close()


func load_options():
	var f = FileAccess.open(OPTIONS_PATH, FileAccess.READ)
	var j = JSON.new()
	j.parse(f.get_as_text())
	options = j.data
	f.close()
	
	decisions_index = {}
	for option in options:
		decisions_index[option] = []
		
	constraints_index = {}
	for option in options:
		constraints_index[option] = []


func save_decisions():
	var f = FileAccess.open(DECISIONS_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(decisions))
	f.close()


func load_decisions():
	var f = FileAccess.open(DECISIONS_PATH, FileAccess.READ)
	var j = JSON.new()
	j.parse(f.get_as_text())
	decisions = j.data
	f.close()
	
	for decision in decisions:
		for option in decisions[decision]:
			decisions_index[option].append(decision)


func save_selections():
	var f = FileAccess.open(SELECTIONS_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(selections))
	f.close()


func load_selections():
	var f = FileAccess.open(SELECTIONS_PATH, FileAccess.READ)
	var j = JSON.new()
	j.parse(f.get_as_text())
	selections = j.data
	f.close()


func save_constraints():
	var f = FileAccess.open(CONSTRAINTS_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(constraints))
	f.close()


func load_constraints():
	var f = FileAccess.open(CONSTRAINTS_PATH, FileAccess.READ)
	var j = JSON.new()
	j.parse(f.get_as_text())
	constraints = j.data
	f.close()
	
	sub_constraints_index = {}
	for constraint in constraints:
		var data = constraints[constraint]
		if data["type"] == Enums.ConstraintType.PREF:
			for option in data["options"]:
				constraints_index[option].append(constraint)
		sub_constraints_index[constraint] = []
	
	for constraint in constraints:
		var data = constraints[constraint]
		if data["type"] == Enums.ConstraintType.COMP:
			for sub_constraint in data["sub"]:
				sub_constraints_index[sub_constraint].append(constraint)


func create_option(option_name: String, option_pref: float) -> bool:
	if option_name in options:
		return false
	
	options[option_name] = option_pref
	decisions_index[option_name] = []
	constraints_index[option_name] = []
	
	save_options()
	return true


func delete_option(option_name: String, cascade: bool = true) -> bool:
	if option_name in options:
		var old_decisions = decisions_index[option_name]
		var old_constraints = constraints_index[option_name]
		if not cascade and (len(old_decisions) > 0 or len(old_constraints) > 0):
			return false
		
		for decision in old_decisions:
			decisions[decision].erase(option_name)
		
		for constraint in old_constraints:
			var data = constraints[constraint]
			data["options"].erase(option_name)
		
		options.erase(option_name)
		decisions_index.erase(option_name)
		constraints_index.erase(option_name)
		save_options()
		
		if cascade:
			save_decisions()
			save_constraints()
		
		return true
	
	return false


func update_option(old_option_name: String, new_option_name: String, new_option_pref: float) -> bool:
	if new_option_name == old_option_name:
		if new_option_name not in options:
			return false
		
		options[new_option_name] = new_option_pref
	else:
		if new_option_name in options:
			return false
		
		if old_option_name in options:
			options.erase(old_option_name)
			
			var old_decisions = decisions_index[old_option_name]
			decisions_index.erase(old_option_name)
			decisions_index[new_option_name] = old_decisions
			for decision in old_decisions:
				decisions[decision].erase(old_option_name)
				decisions[decision].append(new_option_name)
			
			save_decisions()
			
			var old_constraints = constraints_index[old_option_name]
			constraints_index.erase(old_option_name)
			constraints_index[new_option_name] = old_constraints
			for constraint in old_constraints:
				var data = constraints[constraint]
				data["options"][new_option_name] = data["options"][old_option_name]
				data["options"].erase(old_option_name)
			
			save_constraints()
		
		options[new_option_name] = new_option_pref
	
	save_options()
	return true


func create_decision(decision_name: String, initial_options: Array) -> bool:
	if decision_name in decisions:
		return false
	
	decisions[decision_name] = initial_options
	
	for option in initial_options:
		decisions_index[option].append(decision_name)
	
	save_decisions()
	return true


func delete_decision(decision_name: String) -> bool:
	if decision_name not in decisions:
		return false
	
	var affected_options = decisions[decision_name]
	decisions.erase(decision_name)
	for option in affected_options:
		decisions_index[option].erase(decision_name)
	
	save_decisions()
	return true


func update_decision(old_decision_name: String, new_decision_name: String, new_options: Array) -> bool:
	if old_decision_name == new_decision_name:
		if old_decision_name not in decisions:
			return false
		
		for old_option in decisions[old_decision_name]:
			decisions_index[old_option].erase(old_decision_name)
		
		decisions[new_decision_name] = new_options
		
		for option in new_options:
			decisions_index[option].append(new_decision_name)
	else:
		if new_decision_name in decisions:
			return false
		
		var old_options = decisions[old_decision_name]
		decisions.erase(old_decision_name)
		for old_option in old_options:
			decisions_index[old_option].erase(old_decision_name)
		
		decisions[new_decision_name] = new_options
		for option in new_options:
			decisions_index[option].append(new_decision_name)
	
	save_decisions()
	return true


func create_preference_constraint(constraint_name: String, option_names: Array, prefs: Array) -> bool:
	if constraint_name in constraints:
		return false
	
	var option_dict = {}
	for i in range(len(option_names)):
		option_dict[option_names[i]] = prefs[i]
		
	constraints[constraint_name] = {
		"type": Enums.ConstraintType.PREF,
		"options": option_dict
	}
	
	sub_constraints_index[constraint_name] = []
	for option in option_names:
		constraints_index[option].append(constraint_name)
	
	save_constraints()
	return true


func get_circular_sub_constraints(constraint_name: String) -> Dictionary:
	var circular = {constraint_name: true}
	if constraint_name not in constraints:
		return circular
	
	if constraints[constraint_name]["type"] != Enums.ConstraintType.COMP:
		return circular
	
	var remaining_constraints = {}
	for c in sub_constraints_index[constraint_name]:
		remaining_constraints[c] = true
	
	while len(remaining_constraints) > 0:
		var add = []
		var sub = []
		for c in remaining_constraints:
			circular[c] = true
			for o in sub_constraints_index[c]:
				add.append(o)
			sub.append(c)
		
		for a in add:
			remaining_constraints[a] = true
		
		for s in sub:
			remaining_constraints.erase(s)
	
	return circular


func get_children_recursive(constraint_names: Array) -> Dictionary:
	var remaining_constraints = {}
	for constraint in constraint_names:
		remaining_constraints[constraint] = true
	
	var all_children = {}
	while len(remaining_constraints) > 0:
		var add = []
		var sub = []
		for c in remaining_constraints:
			if c not in all_children:
				all_children[c] = true
				if constraints[c]["type"] == Enums.ConstraintType.COMP:
					for child in constraints[c]["sub"]:
						add.append(child)
			sub.append(c)
		
		for c in add:
			remaining_constraints[c] = true
		
		for c in sub:
			remaining_constraints.erase(c)
	
	return all_children


func create_composite_constraint(constraint_name: String, sub_constraints: Array) -> bool:
	if constraint_name in constraints:
		return false
	
	constraints[constraint_name] = {
		"type": Enums.ConstraintType.COMP,
		"sub": sub_constraints
	}
	
	sub_constraints_index[constraint_name] = []
	for sub_constraint in sub_constraints:
		sub_constraints_index[sub_constraint].append(constraint_name)
	
	save_constraints()
	return true


func delete_constraint(constraint_name: String, cascade: bool = true) -> bool:
	if constraint_name not in constraints:
		return false
	
	if not cascade and len(sub_constraints_index[constraint_name]) > 0:
		return false
		
	var data = constraints[constraint_name]
	if data["type"] == Enums.ConstraintType.PREF:
		for option in data["options"]:
			constraints_index[option].erase(constraint_name)
	
	var owners = sub_constraints_index[constraint_name]
	for constraint in owners:
		constraints[constraint]["sub"].erase(constraint_name)
	
	sub_constraints_index.erase(constraint_name)
	constraints.erase(constraint_name)
	
	save_constraints()
	return true


func update_preference_constraint(old_constraint_name: String, new_constraint_name: String, new_options: Dictionary) -> bool:
	if old_constraint_name == new_constraint_name:
		if old_constraint_name not in constraints:
			return false
		
		var data = constraints[old_constraint_name]
		if data["type"] != Enums.ConstraintType.PREF:
			return false
		
		for option in data["options"]:
			constraints_index[option].erase(old_constraint_name)
		
		data["options"] = new_options
		
		for option in new_options:
			constraints_index[option].append(new_constraint_name)
	else:
		if new_constraint_name in constraints:
			return false
		
		var data = constraints[old_constraint_name]
		if data["type"] != Enums.ConstraintType.PREF:
			return false
		
		constraints.erase(old_constraint_name)
		for option in data["options"]:
			constraints_index[option].erase(old_constraint_name)
		
		constraints[new_constraint_name] = {
			"type": Enums.ConstraintType.PREF,
			"options": new_options
		}
		
		for option in new_options:
			constraints_index[option].append(new_constraint_name)
	
		for constraint in sub_constraints_index[old_constraint_name]:
			constraints[constraint]["sub"].erase(old_constraint_name)
			constraints[constraint]["sub"].append(new_constraint_name)
		sub_constraints_index[new_constraint_name] = sub_constraints_index[old_constraint_name]
		sub_constraints_index.erase(old_constraint_name)
	
	save_constraints()
	return true


func update_composite_constraint(old_constraint_name: String, new_constraint_name: String, new_sub_constraints: Array) -> bool:
	if old_constraint_name == new_constraint_name:
		if old_constraint_name not in constraints:
			return false
		
		var data = constraints[old_constraint_name]
		if data["type"] != Enums.ConstraintType.COMP:
			return false
		
		for constraint in data["sub"]:
			sub_constraints_index[constraint].erase(old_constraint_name)
		
		data["sub"] = new_sub_constraints
		
		for constraint in new_sub_constraints:
			sub_constraints_index[constraint].append(new_constraint_name)
	else:
		if new_constraint_name in constraints:
			return false
		
		var data = constraints[old_constraint_name]
		if data["type"] != Enums.ConstraintType.COMP:
			return false
		
		constraints.erase(old_constraint_name)
		for constraint in data["sub"]:
			sub_constraints_index[constraint].erase(old_constraint_name)
		
		constraints[new_constraint_name] = {
			"type": Enums.ConstraintType.PREF,
			"sub": new_sub_constraints
		}
		
		for constraint in new_sub_constraints:
			sub_constraints_index[constraint].erase(old_constraint_name)
			
		for constraint in sub_constraints_index[old_constraint_name]:
			constraints[constraint]["sub"].erase(old_constraint_name)
			constraints[constraint]["sub"].append(new_constraint_name)
		sub_constraints_index[new_constraint_name] = sub_constraints_index[old_constraint_name]
		sub_constraints_index.erase(old_constraint_name)
	
	save_constraints()
	return true


func create_selection(choice: String, decision: String, selection_constraints: Array) -> float:
	if len(selections) == SELECTION_HISTORY_SIZE:
		selections.pop_front()
	
	selections.append({
		"time": Time.get_unix_time_from_system(),
		"choice": choice,
		"decision": decision,
		"constraints": selection_constraints
	})
	
	save_selections()
	
	return selections[-1]["time"]


func delete_selection(selection_index: int):
	selections.pop_at(selection_index)
	save_selections()
