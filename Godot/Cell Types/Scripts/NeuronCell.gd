extends Cell
var weight: float
var constant: float

func _interpret_special_sauce(special_sauce):
	var acquired_sauce = get_from_sauce(special_sauce, ["bool", "weight", "bool", "weight"])
	var weight_sign = int(acquired_sauce[0]) * 2 - 1
	weight = acquired_sauce[1] * weight_sign
	var const_sign = int(acquired_sauce[2]) * 2 - 1
	constant = acquired_sauce[3] * const_sign
	tags.append('Output')
	tags.append('Input')
	energy_consumption = GlobalSettings.cell_type_energy_consumption['neuron_cell.tscn']

func _update_output(input):
	output = input * weight + constant
