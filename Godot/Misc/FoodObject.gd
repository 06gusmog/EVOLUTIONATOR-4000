extends Area2D

const FOOD_BIT = preload("res://Misc/food_bit.tscn")
var food : Array

func _ready():
	self.add_to_group("Persist")

func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"food": food
	}
	return save_dict

func add_food(energy, food_position):
	food.append([energy, food_position])
	var instantiated_food_bit = FOOD_BIT.instantiate()
	instantiated_food_bit.position = food_position
	instantiated_food_bit.scale = Vector2(1,1) * energy
	add_child(instantiated_food_bit)
	if get_child_count() > GlobalSettings.food_cap:
		eat_food(0)
	
func eat_food(index : int):
	var food_to_eat = get_child(index)
	if food_to_eat.get_meta('eaten') == false: # This fuckery is necessary because the creature overlapps several times before the food is deleted.
		food_to_eat.set_meta('eaten', true)
		food_to_eat.free() # Screw the queue, it only causes problems
		#I think this fixed potential issues with position being added to the food array
		return food.pop_at(index)[0]
	return 0

func _on_body_shape_entered(_body_rid, body, _body_shape_index, local_shape_index):
	if body is RigidBody2D:
		#print('Food has been consumed')
		#print(local_shape_index)
		#print(get_child_count())
		var energy_to_eat = eat_food(local_shape_index)
		#print(energy_to_eat)
		body.energy += energy_to_eat
		if body.energy > body.per_frame_energy_consumption * GlobalSettings.energy_cap:
			body.energy = body.per_frame_energy_consumption * GlobalSettings.energy_cap
	else:
		#print('Food in the wall')
		eat_food(local_shape_index)
