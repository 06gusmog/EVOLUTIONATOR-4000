extends Node2D
const food_bit_scene = preload("res://Food Object/food_bit.tscn")

func _ready():
	self.add_to_group("Persist")

func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y
	}
	return save_dict

func add_food(energy, food_position):
	var food_instance = food_bit_scene.instantiate()
	food_instance.position = food_position
	food_instance.energy = energy
	add_child(food_instance)
	if get_child_count() > GlobalSettings.food_cap:
		remove_food(0)

func remove_food(index):
	var food = get_child(index)
	remove_child(food)
	food.queue_free()
