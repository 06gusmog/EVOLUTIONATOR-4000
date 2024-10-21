extends Area2D
var energy: float
@onready var shape: CollisionShape2D = $shape
@onready var white_square: Sprite2D = $white_square

func _ready():
	self.add_to_group("Persist")

func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		'energy' : energy
	}
	return save_dict

func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		#print('Food has been consumed')
		body.energy += energy
		if body.energy > body.per_frame_energy_consumption * GlobalSettings.energy_cap:
			body.energy = body.per_frame_energy_consumption * GlobalSettings.energy_cap
		queue_free()
	else:
		#print('Food in the wall')
		queue_free()
