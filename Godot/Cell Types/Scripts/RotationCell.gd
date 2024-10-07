extends Cell
var weight: float

func _interpret_special_sauce(special_sauce):
	weight = get_from_sauce(special_sauce, ["weight"])[0] * movement_tweak
	tags.append('Input')
	energy_consumption = GlobalSettings.cell_type_energy_consumption['rotation_cell.tscn']
	
func _act(input, delta):
	get_parent().apply_torque(input * weight * delta)
	energy_consumption = GlobalSettings.cell_type_energy_consumption['rotation_cell.tscn'] + abs(input) * GlobalSettings.action_consumption_factor
