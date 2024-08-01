extends Area2D

const FOOD_BIT = preload("res://Misc/food_bit.tscn")
var food : Array

func add_food(energy, food_position):
	food.append(energy)
	var instantiated_food_bit = FOOD_BIT.instantiate()
	instantiated_food_bit.position = food_position
	add_child(instantiated_food_bit)
	
func eat_food(index : int):
	var food_to_eat = get_child(index)
	if food_to_eat.get_meta('eaten') == false: # This fuckery is necessary because the creature overlapps several times before the food is deleted.
		food_to_eat.set_meta('eaten', true)
		food_to_eat.queue_free()
		return food.pop_at(index)
	return 0


func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body is RigidBody2D:
		var energy_to_eat = eat_food(local_shape_index)
		body.energy += energy_to_eat
	else:
		print('Food in the wall')
		eat_food(local_shape_index)
