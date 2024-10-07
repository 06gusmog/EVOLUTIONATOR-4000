extends Cell
var distance: int
var distance_factor = 10
@onready var area_2d = $Area2D

func _interpret_special_sauce(special_sauce):
	var sauce_values = get_from_sauce(special_sauce, ['weight'])
	distance = (sauce_values[0] + 1) * distance_factor
	area_2d.scale = Vector2(0.1 * distance, 0.1 * distance)
	tags.append('Output')

func _update_output(_input):
	var bodies_in_range = area_2d.get_overlapping_bodies()
	if len(bodies_in_range) == 0:
		output = -1
	else:
		var dist2 = []
		for body in bodies_in_range:
			if body == self.get_parent():
				continue
			dist2.append(to_local(body.position).distance_squared_to(self.position))
		if len(dist2) == 0:
			output = -1
			return
		var min_dist2 = dist2.min()
		var collision_distance = sqrt(min_dist2)
		if collision_distance > distance:
			collision_distance = distance
		output = (distance - collision_distance) /distance
