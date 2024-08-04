extends Node2D

var rng = RandomNumberGenerator.new()
var number_string = "0123456789"
var cell_types = DirAccess.get_files_at("res://Cell Types/Scenes/")
const CREATURE = preload("res://Misc/creature.tscn")
@export var creature_amount: int
@export var creature_size: int
@export var special_sauce_length: int = 5
@onready var camera_2d = $Camera2D
@export var camera_move_speed = 5.0
@onready var food_object = $FoodObject

# Math functions

func _ready():
	for i in range(creature_amount):
		create_creature(generate_random_DNA(creature_size), Vector2((i % 10)*20, int(i / 10) * -20))

func _process(delta):
	camera_2d.position += Input.get_vector( 'left', 'right', 'up', 'down') * camera_move_speed * 1/camera_2d.zoom
	camera_2d.zoom -= Vector2(0.01, 0.01) * Input.get_axis("zoom_in", "zoom_out") * camera_2d.zoom
	if Input.is_action_just_pressed("click"):
		food_object.add_food(20, get_global_mouse_position())

func create_creature(DNA, creature_position): 
	var dudebro = CREATURE.instantiate()
	dudebro.DNA = DNA
	dudebro.position = creature_position #Does this still work if we spawn more later? [Why would we do it like this???]
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
	RNA['Type'] = cell_types[rng.randi() % len(cell_types)] #Would it be slower to use randi_range() instead?
	cell_positions.append(select_cell_position(cell_positions))
	RNA['Position'] = cell_positions[-1]
	RNA['Connections'] = []
	for x in range(int(ceil(7.5/(0.4 * (rng.randi() % 10) + 1.25) - 2))): # Selects a weighted number between 0 and 4  
		var connection = rng.randi() % (creature_size-1)
		if connection >= len(cell_positions):
			connection += 1
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

func _on_mitosis(creature): #NOTE: Does not yet connect to the mitosis signal [It now connects to the mitosis signal]
	var new_DNA = [creature.DNA, creature.DNA]
	print('MITOSIS')
	create_creature(creature.DNA, creature.position + Vector2(0, creature.bounding_sphere_size * 2))
	creature.energy -= 500
	# NOTE: I have No idea what you were planning to do with this list, but here's my suggestion for how we do the position -Gus
	#for DNA in new_DNA:
	"""---Insert the code for mutation here---"""
		
		#var creature_index = null #CRITICAL: This does not work and is just to prevent error in the editor, either we have to keep track of the creature index, or we fix the position some other way (probably the latter) 
		
		#creature.energy -= 100
