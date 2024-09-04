extends Node2D
const CREATURE = preload("res://Misc/creature.tscn")
const connection_node = preload("res://Misc/UI assets/connection.tscn")
const white_dot = preload("res://Misc/UI assets/white_dot.png")
@onready var camera_2d = $"Camera Room/Camera2D"
@onready var camera_room = $"Camera Room"

@export var edge_padding = 0.01

func generate_icon(DNA):
	var cells = {}
	var radius_squared = 0
	for child in $"Camera Room".get_children():
		if child is Camera2D:
			continue
		child.queue_free()
	
	var i = 0
	for RNA in DNA:
		var cell_base = load("res://Cell Types/Scenes/" + RNA['Type'])
		var cell_instance = cell_base.instantiate()
		add_child(cell_instance)
		cell_instance.unpack(RNA, str(i))
		i += 1 
	
	for cell in get_children():
		cells[cell.name] = cell
	cells.erase('Camera Room')
	
	for cellID in cells:
		var cell_instance = cells[cellID]
		if cell_instance.position.distance_squared_to(Vector2(0,0)) > radius_squared:
			radius_squared = cell_instance.position.distance_squared_to(Vector2(0,0))
		if 'Input' in cell_instance.tags:
			for connection in cell_instance.connections:
				if 'Output' in cells[connection].tags:
					var connection_visual = connection_node.instantiate()
					cell_instance.add_child(connection_visual)
					connection_visual.make_connection(cell_instance.position, cells[connection].position, connection) #NOTE index out of range error
		
		if 'Output' in cell_instance.tags:
			var dot_sprite = Sprite2D.new()
			dot_sprite.texture = white_dot
			dot_sprite.scale = Vector2(0.01,0.01)
			dot_sprite.name = 'Dot'
			cell_instance.add_child(dot_sprite)
	
	camera_2d.zoom = Vector2(1,1) * float(camera_2d.get_viewport().size.x) / (sqrt(radius_squared) + edge_padding)
	var img = camera_room.get_texture().get_image()
	return ImageTexture.create_from_image(img)
