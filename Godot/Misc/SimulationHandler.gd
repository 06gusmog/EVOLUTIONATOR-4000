extends Node2D

var rng = RandomNumberGenerator.new()
var number_string = "0123456789"
var mutation_chances = GlobalSettings.mutation_chances
var mutation_chance_multiplier = GlobalSettings.mutation_chance_multiplier
var cell_types = DirAccess.get_files_at("res://Cell Types/Scenes/")
const CREATURE = preload("res://Misc/creature.tscn")
@export var creature_amount: int
@export var special_sauce_length: int = 5
@onready var camera_2d = $Camera2D
@export var camera_move_speed = 5.0
@onready var food_object = $FoodObject
@onready var spawnpoints = $Spawnpoints

var noise = FastNoiseLite.new()

# Math functions

func _ready():
	noise.seed = randi()
	noise.fractal_octaves = 1
	noise.fractal_gain = 0.5
	noise.fractal_lacunarity = 2

func _process(_delta):
	camera_2d.position += Input.get_vector( 'left', 'right', 'up', 'down') * camera_move_speed * 1/camera_2d.zoom
	camera_2d.zoom -= Vector2(0.01, 0.01) * Input.get_axis("zoom_in", "zoom_out") * camera_2d.zoom
	#if Input.is_action_just_pressed("click"):
	#	food_object.add_food(20, get_global_mouse_position())
	if Input.is_action_just_pressed("test input"):
		spawn_food()

func get_random_position():
	var width = int(GlobalSettings.map_size[0])
	var height = int(GlobalSettings.map_size[1])
	return [rng.randi() % width - width/2, rng.randi() % height - height/2]

func spawn_food():
	var energy = rng.randi() % 50 + 100
	#This is the method used: https://stackoverflow.com/questions/71551080/random-distribution-of-points-based-on-perlin-noise
	var proposed_position = [0,0]
	for x in range(15):
		proposed_position = get_random_position()
		var reference_position = get_random_position()
		if noise.get_noise_2d(proposed_position[0], proposed_position[1]) >= noise.get_noise_2d(reference_position[0], reference_position[1]):
			break
	food_object.add_food(energy, Vector2(proposed_position[0], proposed_position[1]))

func create_creature(DNA, creature_position): 
	var dudebro = CREATURE.instantiate()
	dudebro.DNA = DNA
	dudebro.position = creature_position 
	dudebro.mitosis.connect(_on_mitosis) # This connects the signal
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
	creature.energy = creature.energy / 2
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
	
	#Chance to change one cell type
	if not rng.randi() % (mutation_chances['type_switch'] * mutation_chance_multiplier):
		print('Cell Mutation: Type Change')
		new_DNA[rng.randi() % len(new_DNA)]['Type'] = cell_types[rng.randi() % len(cell_types)]
	
	#Chance to change one digit in the special sauce
	if not rng.randi() % (mutation_chances['special_sauce_digit_change'] * mutation_chance_multiplier):
		print('Cell Mutation: Special Sauce')
		var special_sauce = new_DNA[rng.randi() % len(new_DNA)]['Special Sauce']
		special_sauce[rng.randi() % len(special_sauce)] = str(rng.randi() % 10)
	
	create_creature(new_DNA, creature.position + Vector2(0, creature.bounding_sphere_size * 2))
	creature.energy -= 500
	
func _on_food_spawn_timer_timeout():
	for x in range(GlobalSettings.food_spawn_burst_size):
		spawn_food()


func _on_spawn_timer_timeout():
	for spawn in spawnpoints.get_children():
		if spawn is Timer:
			continue
		var overlapping_bodies = spawn.get_child(0).get_overlapping_bodies()
		if overlapping_bodies == []:
			create_creature(generate_random_DNA(GlobalSettings.creature_spawn_size), spawn.position)
		elif len(overlapping_bodies) == 1 and food_object in overlapping_bodies:
			create_creature(generate_random_DNA(GlobalSettings.creature_spawn_size), spawn.position)
