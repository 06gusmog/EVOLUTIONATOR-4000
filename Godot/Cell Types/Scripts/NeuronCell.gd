extends Cell
var sign: int
var weight: float
var constant: float

func _interpret_special_sauce(special_sauce):
	var acquired_sauce = get_from_sauce(special_sauce, ["bool", "weight", "bool", "weight"])
	sign = int(acquired_sauce[0]) * 2 - 1
	weight = acquired_sauce[1] * sign
	sign = int(acquired_sauce[2]) * 2 - 1
	constant = acquired_sauce[3] * sign

func _update_output(input):
	output = input * weight + constant
