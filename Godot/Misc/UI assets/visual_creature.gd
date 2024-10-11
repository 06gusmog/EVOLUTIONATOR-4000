extends Node2D
var creature
const connection_node = preload("res://Misc/UI assets/connection.tscn")
const white_dot = preload("res://Misc/UI assets/white_dot.png")

# Called when the node enters the scene tree for the first time.
func _ready(): #NOTE Creates every cell as a sprite2D named after the index, and the cells connections as line2D's as its children, with them being named after their target cell.
	#DNA = generate_random_DNA(3)
	for cellID in creature.cells:
		var cell = creature.cells[cellID]
		var cell_instance = cell.duplicate() # Dot on output, connections on input
		var cell_instance_connections = cell.connections
		cell_instance.cellID = cellID
		cell_instance.tags = cell.tags
		add_child(cell_instance)
		if 'Input' in cell.tags:
			for connection in cell_instance_connections:
				if 'Output' in creature.cells[connection].tags:
					var connection_visual = connection_node.instantiate()
					cell_instance.add_child(connection_visual)
					connection_visual.make_connection(cell_instance.position, creature.cells[connection].position, connection) #NOTE index out of range error
		
		if 'Output' in cell.tags:
			var dot_sprite = Sprite2D.new()
			dot_sprite.texture = white_dot
			dot_sprite.scale = Vector2(0.01,0.01)
			dot_sprite.name = 'Dot'
			cell_instance.add_child(dot_sprite)
