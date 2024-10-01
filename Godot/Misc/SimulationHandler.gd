extends Node2D

var rng = RandomNumberGenerator.new()
var number_string = "0123456789"
var mutation_chances = GlobalSettings.mutation_chances
var mutation_chance_multiplier = GlobalSettings.mutation_chance_multiplier
var cell_types = DirAccess.get_files_at("res://Cell Types/Scenes/")
const CREATURE = preload("res://Misc/creature.tscn")
@export var creature_amount: int
@export var special_sauce_length: int = 5
@onready var food_object = $FoodObject
@onready var spawnpoints = $Spawnpoints
@onready var food_spawn_nodes = get_node("FoodSpawnPoints").get_children()

# Math functions

func _ready():
	food_spawn_nodes.pop_at(-1)

func _process(_delta):
	#if Input.is_action_just_pressed("click"):
	#	food_object.add_food(20, get_global_mouse_position())
	if Input.is_action_just_pressed("test input"):
		print("Saving Game")
		save_game()

func get_random_position(food_spawn_node):
	var diameter = 150
	var offset = food_spawn_node.position 
	return Vector2(rng.randi() % diameter - diameter/2 + offset[0], rng.randi() % diameter - diameter/2 + offset[1])

func spawn_food(food_spawn_node):
	var energy = rng.randi() % 50 + 100
	var proposed_position = [0,0]
	for x in range(15):
		proposed_position = get_random_position(food_spawn_node)
		var reference_position = get_random_position(food_spawn_node)
		if food_spawn_node.position.distance_to(proposed_position)*2 <= food_spawn_node.position.distance_to(reference_position):
			break
	food_object.add_food(energy, Vector2(proposed_position[0], proposed_position[1]))

func create_creature(DNA, creature_position, parentID = '-1'): 
	var creatureID = LineageLogger.log_creature_creation(parentID, DNA)
	var dudebro = CREATURE.instantiate()
	dudebro.DNA = DNA
	dudebro.position = creature_position 
	dudebro.mitosis.connect(_on_mitosis) # This connects the signal
	dudebro.creatureID = creatureID
	add_child(dudebro)

func generate_special_sauce(length : int):
	var special_sauce = ""
	for i in range(length):
		special_sauce += number_string[rng.randi() % 10]
	return special_sauce
	
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
	RNA['Type'] = cell_types[rng.randi() % len(cell_types)]
	cell_positions.append(select_cell_position(cell_positions))
	RNA['Position'] = cell_positions[-1] #Uhhhhh, I don't know how to mutate this?????
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

func _on_mitosis(creature:): 
	var new_DNA = creature.DNA
	print('MITOSIS')
	
	#Chance to remove a cell
	if not rng.randi() % (mutation_chances['remove_cell'] * mutation_chance_multiplier):
		print('Cell Mutation: Removal')
		var pop_index = rng.randi() % len(new_DNA)
		new_DNA.pop_at(pop_index)
		for RNA in new_DNA:
			var new_connections = []
			for connection in RNA['Connections']:
				if int(connection) < len(new_DNA):
					new_connections.append(connection)
			RNA['Connections'] = new_connections
		
	
	#Chance to spawn a new cell
	if not rng.randi() % (mutation_chances['new_cell'] * mutation_chance_multiplier):
		print('Cell Mutation: Addition')
		var cell_positions = [] #NOTE: I think it would be better to store cell_positions for every creature, instead of calculating it every time
		for RNA in new_DNA:
			cell_positions.append(RNA['Position'])
		new_DNA.append(generate_random_RNA(cell_positions, len(new_DNA) + 1)[0])
	
	#Chance to gain a new connection on a random cell
	if not rng.randi() % (mutation_chances['new_connection'] * mutation_chance_multiplier):
		print('Cell Mutation: Connection')
		new_DNA[rng.randi() % len(new_DNA)]['Connections'].append(str(rng.randi() % len(new_DNA)))
	
	if not rng.randi() % (mutation_chances['delete_connection'] * mutation_chance_multiplier):
		var connections = new_DNA[rng.randi() % len(new_DNA)]['Connections']
		if not len(connections) == 0:
			connections.pop_at(rng.randi() % len(connections))
	
	#Chance to change one cell type
	if not rng.randi() % (mutation_chances['type_switch'] * mutation_chance_multiplier):
		print('Cell Mutation: Type Change')
		new_DNA[rng.randi() % len(new_DNA)]['Type'] = cell_types[rng.randi() % len(cell_types)]
	
	#Chance to change one digit in the special sauce
	if not rng.randi() % (mutation_chances['special_sauce_digit_change'] * mutation_chance_multiplier):
		print('Cell Mutation: Special Sauce')
		var special_sauce = new_DNA[rng.randi() % len(new_DNA)]['Special Sauce']
		special_sauce[rng.randi() % len(special_sauce)] = str(rng.randi() % 10)
	
	if creature.linear_velocity == Vector2(0,0):
		create_creature(new_DNA, creature.position + Vector2(0, creature.bounding_sphere_size * 3), creature.creatureID)
	else:
		create_creature(new_DNA, creature.position + -creature.linear_velocity.normalized() * creature.bounding_sphere_size * 3, creature.creatureID)
	creature.energy -= GlobalSettings.energy_required_to_reproduce_PC * len(creature.cells)
	
#This code is stolen from https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html, 
#if any problems occur please consult the source
func save_game():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)

func _on_food_spawn_timer_timeout():
	for x in range(GlobalSettings.food_spawn_burst_size):
		spawn_food(food_spawn_nodes[rng.randi() % len(food_spawn_nodes)])

func _on_spawn_timer_timeout():
	for spawn in spawnpoints.get_children():
		if spawn is Timer:
			continue
		var overlapping_bodies = spawn.get_child(0).get_overlapping_bodies()
		if overlapping_bodies == []:
			create_creature(generate_random_DNA(GlobalSettings.creature_spawn_size), spawn.position)
		elif len(overlapping_bodies) == 1 and food_object in overlapping_bodies:
			create_creature(generate_random_DNA(GlobalSettings.creature_spawn_size), spawn.position)
