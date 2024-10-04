extends Node

#Map
var map_size = Vector2(640, 384)

# Energy
# PC stands for Per Cell
var energy_required_to_reproduce_PC = 100.0
var energy_cap_PC = 200.0
var energy_starting_PC = 50.0
var energy_dropped_min = 25.0
var energy_dropped_max = 75.0
var energy_consumption_PC = 0.2

# Energy
var cell_weight = 1.0

var food_spawn_burst_size = 50
var creature_spawn_size = 10

# Mutation
var mutation_chance_multiplier = 1
var mutation_chances = {
	'remove_cell': 20,
	'new_cell': 10, #Likelihood is 1/x
	'new_connection': 5,
	'delete_connection': 5,
	'type_switch': 5,
	'special_sauce_digit_change': 1
	}

# Physics
var simulation_speed = 10
var food_cap = 1000
var ticks_per_second = 30

# Visual
var color_sheet = {
	'eating_cell.tscn':Color.RED,
	'eye_cell.tscn':Color.PURPLE,
	'move_cell.tscn':Color.BLUE,
	'neuron_cell.tscn':Color.YELLOW,
	'rotation_cell.tscn':Color.GREEN
	}

#To create a new game, create a folder in %appdata%/Godot/app_userdata/[name of the project]/
#and write the name of the new folder between :// and savegame.save
var save_path = "user://Game1/"
var save_name = "user://Game1/savegame.save"
var create_new_game = true

func _ready():
	if not create_new_game:
		load_game()
	Engine.time_scale = simulation_speed
	Engine.physics_ticks_per_second = ticks_per_second * simulation_speed

#This code is stolen from https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html, 
#if any problems occur please consult the source
func load_game():
	if not FileAccess.file_exists(save_name):
		return # Error! We don't have a save to load.

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open(save_name, FileAccess.READ)
	print(save_file.get_length())
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(node_data["filename"]).instantiate()
		
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])
		
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
	print("Game Loaded")


