extends Node

# Energy
var energy_required_to_reproduce = 1100.0
var energy_dropped_on_cell_death = 100.0 #This should probably be a percentage of the stored energy
var cell_weight = 1.0

# Mutation
var mutation_chance_multiplier = 1.0
var mutation_chances = {
	'new_cell': 100, #Likelihood is 1/x
	'new_connection': 50,
	'type_switch': 50,
	'special_sauce_digit_change': 10
	}
