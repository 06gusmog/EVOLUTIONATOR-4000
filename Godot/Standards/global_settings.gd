extends Node

#Map
var map_size = Vector2(640, 384)

# Energy
var energy_required_to_reproduce = 1100.0
var energy_dropped_on_cell_death = 100.0 #This should probably be a percentage of the stored energy
var cell_weight = 1.0

var food_spawn_burst_size = 50

# Mutation
var mutation_chance_multiplier = 10
var mutation_chances = {
	'remove_cell': 10,
	'new_cell': 10, #Likelihood is 1/x
	'new_connection': 5,
	'type_switch': 5,
	'special_sauce_digit_change': 1
	}
