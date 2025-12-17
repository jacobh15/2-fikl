extends Node


func choose(decision: String, constraints: Array) -> String:
	var all_constraints = IO.get_children_recursive(constraints)
	var pref_constraints = []
	for constraint in all_constraints:
		if IO.constraints[constraint]["type"] == Enums.ConstraintType.PREF:
			pref_constraints.append(constraint)
	
	var log_probs = []
	for option in IO.decisions[decision]:
		var log_prob = 0.0
		for constraint in pref_constraints:
			var constraint_prefs = IO.constraints[constraint]["options"]
			if option in constraint_prefs:
				log_prob += log(constraint_prefs[option])
		log_probs.append(log_prob)
	
	var log_scale = 0.0
	for log_prob in log_probs:
		log_scale = min(log_scale, log_prob)
	
	for i in range(len(log_probs)):
		log_probs[i] -= log_scale
	
	var rel_probs = []
	var total = 0.0
	for log_prob in log_probs:
		rel_probs.append(exp(log_prob))
		total += rel_probs[-1]
	
	var cum_probs = []
	var s = 0.0
	for p_rel in rel_probs:
		s += p_rel / total
		cum_probs.append(s)
	
	var u = randf()
	for i in range(len(cum_probs)):
		if u <= cum_probs[i]:
			return IO.decisions[decision][i]
	
	return IO.decisions[decision][-1]  # Just in case we somehow get here
