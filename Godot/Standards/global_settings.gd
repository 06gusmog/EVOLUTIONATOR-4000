extends Node

signal event

# Visual
var color_sheet = {
	'eating_cell.tscn':Color.RED,
	'eye_cell.tscn':Color.PURPLE,
	'move_cell.tscn':Color.BLUE,
	'neuron_cell.tscn':Color.YELLOW,
	'rotation_cell.tscn':Color.GREEN
	}

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
var cell_weight = 1.0
var simulation_speed = 10
var food_cap = 1000
var ticks_per_second = 30

# Lineage Tracking
var event_register = []
var creature_register = []

var photo_booth

func add_event(type:String, creatureID:int, other_tags:Array = []):
	match type:
		'Creation':
			event_register.append({'Type':'Creation', 'CreatureID': creatureID})
			creature_register.append({'Creation Event':len(event_register)-1, 'DNA':other_tags[0], 'Parent':-1, 'Offspring':[], 'image':photo_booth.generate_icon(other_tags[0], color_sheet), 'Dead':false, 'Death Event':0})
		'Mitosis':
			event_register.append({'Type':'Mitosis', 'Offspring CreatureID': creatureID, 'Parent CreatureID': other_tags[0]})
			creature_register.append({'Creation Event':len(event_register)-1, 'DNA':other_tags[1], 'Parent':other_tags[0], 'Offspring':[], 'image':photo_booth.generate_icon(other_tags[1], color_sheet), 'Dead':false, 'Death Event':0})
			creature_register[other_tags[0]]['Offspring'].append(creatureID)
		'Death':
			event_register.append({'Type':'Death', 'CreatureID':creatureID})
			creature_register[creatureID]['Dead'] = true
			creature_register[creatureID]['Death Event'] = len(event_register)-1
	event.emit()
		


func _ready():
	Engine.time_scale = simulation_speed
	Engine.physics_ticks_per_second = ticks_per_second * simulation_speed
