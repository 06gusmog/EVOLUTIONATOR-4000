extends Node

#Map
var map_size = Vector2(640, 384)

# Energy
var energy_required_to_reproduce = 1100.0
var energy_lost_on_reproduction = 400.0
var energy_dropped_on_cell_death = 100.0 #This should probably be a percentage of the stored energy
var cell_weight = 1.0
var spawn_energy_multiplier = 0.5

var food_spawn_burst_size = 50
var creature_spawn_size = 10

# Mutation
var mutation_chance_multiplier = 1
var mutation_chances = {
	'remove_cell': 20,
	'new_cell': 10, #Likelihood is 1/x
	'new_connection': 5,
	'type_switch': 5,
	'special_sauce_digit_change': 1
	}

# Physics
var simulation_speed = 5
var food_cap = 1000

func _ready():
	Engine.time_scale = simulation_speed
	Engine.physics_ticks_per_second = Engine.physics_ticks_per_second * simulation_speed
