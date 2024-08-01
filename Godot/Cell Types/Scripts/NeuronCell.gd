extends Cell
var weight: float
var sign: bool

func _interpret_special_sauce(special_sauce):
	var acquired_sauce = get_from_sauce(special_sauce, ["bool", "weight"])
	sign = acquired_sauce[0] * 2  - 1
	weight = acquired_sauce[1] * sign

func _update_output(input):
	output = input * weight
