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
		var dudebro = CREATURE.instantiate()
		dudebro.DNA = generate_random_DNA(creature_size)
		dudebro.position += Vector2((i % 10)*20, int(i / 10) * -20)
		add_child(dudebro)

func _process(delta):
	camera_2d.position += Input.get_vector( 'left', 'right', 'up', 'down') * camera_move_speed * 1/camera_2d.zoom
	camera_2d.zoom -= Vector2(0.01, 0.01) * Input.get_axis("zoom_in", "zoom_out") * camera_2d.zoom
	if Input.is_action_just_pressed("click"):
		food_object.add_food(20, get_global_mouse_position())

func generate_special_sauce(length : int):
	var special_sauce = ""
	for i in range(length):
		special_sauce += number_string[rng.randi() % 10]
	return special_sauce
	
func generate_random_DNA(size : int):
	"""No chance to have 0 connections. That math function could use a revision"""
	var DNA = []
	var cell_positions = []
	for cell in range(size):
		var RNA = {}
		RNA['Type'] = cell_types[rng.randi() % len(cell_types)]
		cell_positions.append(select_cell_position(cell_positions))
		RNA['Position'] = cell_positions[-1]
		RNA['Connections'] = []
		for x in range(int(ceil(8.8/((rng.randi() % 10) + 2.2)))): # Selects a weighted number between 1 and 4
			var connection = rng.randi() % (size-1)
			if connection >= len(cell_positions):
				connection += 1
			RNA['Connections'].append(str(connection))
		RNA['Special Sauce'] = generate_special_sauce(special_sauce_length)
		DNA.append(RNA)
	return DNA

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

