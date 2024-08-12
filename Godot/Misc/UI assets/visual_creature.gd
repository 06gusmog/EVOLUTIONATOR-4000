extends Node2D
var creature
const connection_node = preload("res://Misc/UI assets/connection.tscn")

# TEMPORARY!!!
"""
var rng = RandomNumberGenerator.new()
var cell_types = DirAccess.get_files_at("res://Cell Types/Scenes/")
@export var special_sauce_length: int = 5
var number_string = "0123456789"

func generate_random_DNA(size : int):
	var DNA = []
	var cell_positions = []
	for cell in range(size):
		var random_RNA_return = generate_random_RNA(cell_positions, size)
		var RNA = random_RNA_return[0]
		#This way of updating cell_positions feels a bit goofy, but i think it's fine?
		cell_positions = random_RNA_return[1]
		DNA.append(RNA)
	return DNA
	
func generate_random_RNA(cell_positions: Array, creature_size):
	var RNA = {}
	RNA['Type'] = cell_types[rng.randi() % len(cell_types)] #Would it be slower to use randi_range() instead?
	cell_positions.append(select_cell_position(cell_positions))
	RNA['Position'] = cell_positions[-1]
	RNA['Connections'] = []
	for x in range(int(ceil(7.5/(0.4 * (rng.randi() % 10) + 1.25) - 2))): # Selects a weighted number between 0 and 4  
		var connection = rng.randi() % (creature_size)
		RNA['Connections'].append(str(connection))
	RNA['Special Sauce'] = generate_special_sauce(special_sauce_length)
	return [RNA, cell_positions]
	
func select_cell_position(established_positions : Array):
	var cell_position = Vector2(0,0)
	var x = 1 - ((rng.randi() % 2) * 2)
	var y = 1 - ((rng.randi() % 2) * 2)
	while true:
		if cell_position in established_positions:
			var one_or_zero = rng.randi() % 2
			cell_position.x += x * one_or_zero
			cell_position.y += y * (1-one_or_zero)
		else:
			return cell_position

func generate_special_sauce(length : int):
	var special_sauce = ""
	for i in range(length):
		special_sauce += number_string[rng.randi() % 10]
	return special_sauce
"""
# Called when the node enters the scene tree for the first time.
func _ready(): #NOTE Creates every cell as a sprite2D named after the index, and the cells connections as line2D's as its children, with them being named after their target cell.
	#DNA = generate_random_DNA(3)
	var i = 0
	for cell in creature.cells:
		var cell_instance = cell.duplicate()
		var cell_instance_connections = cell.connections
		add_child(cell_instance)
		for connection in cell_instance_connections:
			print('hello')
			var connection_visual = connection_node.instantiate()
			cell_instance.add_child(connection_visual)
			connection_visual.make_connection(cell_instance.position, creature.cells[int(connection)].position) #NOTE index out of range error
		i += 1
	
func tick_forward(inputs):
	pass
	
