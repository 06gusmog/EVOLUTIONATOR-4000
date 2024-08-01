extends Cell

var oogboog : bool
var sminglesmorg : float

func _interpret_special_sauce(special_sauce):
	var sauce_values = get_from_sauce(special_sauce, ['bool', 'angle'])
	oogboog = sauce_values[0]
	sminglesmorg = sauce_values[1]

func _act(input):
	pass

func _update_output(input):
	pass
