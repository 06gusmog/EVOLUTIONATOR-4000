extends Node2D
var creature
const connection_node = preload("res://Misc/UI assets/connection.tscn")


# Called when the node enters the scene tree for the first time.
func _ready(): #NOTE Creates every cell as a sprite2D named after the index, and the cells connections as line2D's as its children, with them being named after their target cell.
	#DNA = generate_random_DNA(3)
	var i = 0
	for cell in creature.cells:
		var cell_instance = cell.duplicate()
		var cell_instance_connections = cell.connections
		add_child(cell_instance)
		for connection in cell_instance_connections:
			var connection_visual = connection_node.instantiate()
			cell_instance.add_child(connection_visual)
			connection_visual.make_connection(cell_instance.position, creature.cells[int(connection)].position) #NOTE index out of range error
		i += 1
	
func tick_forward(inputs):
	pass
	
