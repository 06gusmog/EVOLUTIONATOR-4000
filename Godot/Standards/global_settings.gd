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

#Numbers pulled straight from my butt, feel free to change.
var cell_type_energy_consumption = {
	'eating_cell.tscn':0.3,
	'eye_cell.tscn':0.4,
	'move_cell.tscn':0.3,
	'neuron_cell.tscn':0.5,
	'rotation_cell.tscn':0.2,
	'hearing_cell.tscn':0.2,
	'smelling_cell.tscn':0.2,
	'armor_cell.tscn':0.1
}
var action_consumption_factor = 0.5
#Factor multiplied by per frame energy consumption
#Numbers still out of my butt, feel free to change.
var reproduction_energy_requirement = 150
var starting_energy = 100
var energy_cap = 200
var energy_drop_modifier = 0.5
#Modifier that changes the speed at which energy is consumed
var metabolism_modifier = 0.5

# Energy
var cell_weight = 1.0

var food_spawn_burst_size = 50
var creature_spawn_size = 10

# Mutation
var mutation_chance_multiplier = 1
var mutation_chances = {
	'remove_cell': 15,
	'new_cell': 10, #Likelihood is 1/x
	'new_connection': 5,
	'delete_connection': 5,
	'type_switch': 5,
	'special_sauce_digit_change': 1
	}

# Physics
var simulation_speed = 1
var food_cap = 1000
var ticks_per_second = 30

func set_simulation_speed(speed):
	Engine.time_scale = simulation_speed
	Engine.physics_ticks_per_second = ticks_per_second * simulation_speed

# Visual
var color_sheet = {
	'eating_cell.tscn':Color.RED,
	'eye_cell.tscn':Color.PURPLE,
	'move_cell.tscn':Color.BLUE,
	'neuron_cell.tscn':Color.YELLOW,
	'rotation_cell.tscn':Color.GREEN,
	'hearing_cell.tscn':Color.AQUA,
	'smelling_cell.tscn':Color.ORANGE,
	'armor_cell.tscn':Color.DARK_GRAY
	}


var savefile_selected = "res://savefiles/savegame13-8.txt"
var save_path = "res://savefiles/Placeholder/"

func _ready():
	set_simulation_speed(simulation_speed)
