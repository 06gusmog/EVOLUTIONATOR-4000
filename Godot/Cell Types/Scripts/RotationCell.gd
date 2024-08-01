extends Cell
var weight: float

func _interpret_special_sauce(special_sauce):
	weight = get_from_sauce(special_sauce, ["weight"])

func _update_output(input): 
	output = 0
	
func _act(input):
	get_parent().apply_torque(input * weight)	
