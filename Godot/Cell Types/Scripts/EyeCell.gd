extends Cell
var angle : float
var distance : int
var distance_factor = 10
@onready var ray_cast_2d = $RayCast2D
@onready var line_2d = $Line2D

func _interpret_special_sauce(special_sauce):
	var sauce_values = get_from_sauce(special_sauce, ['angle', 'weight'])
	angle = sauce_values[0]
	distance = (sauce_values[1] + 1) * distance_factor
	ray_cast_2d.target_position = Vector2(cos(angle), sin(angle)) * distance
	line_2d.points = [Vector2(0,0), ray_cast_2d.target_position]
	tags.append('Output')
	energy_consumption = GlobalSettings.cell_type_energy_consumption['eye_cell.tscn']
	
func _update_output(_input):
	if ray_cast_2d.is_colliding():
		var collision_point = ray_cast_2d.get_collision_point()
		var collision_distance = to_local(collision_point).distance_to(Vector2(0,0))
		output = (distance - collision_distance) / distance
	else:
		output = 0
