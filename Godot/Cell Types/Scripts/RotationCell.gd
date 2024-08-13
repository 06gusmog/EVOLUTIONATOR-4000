extends Cell
var weight: float

func _interpret_special_sauce(special_sauce):
	weight = get_from_sauce(special_sauce, ["weight"])[0] * movement_tweak
	tags.append('Input')

func _update_output(input): 
	output = 0
	
func _act(input, delta):
	get_parent().apply_torque_impulse(input * weight * delta)
