extends RigidBody2D
var DNA : Array
var killing_queue : Array
var cells : Dictionary
var energy = GlobalSettings.energy_required_to_reproduce * GlobalSettings.spawn_energy_multiplier
var food_object
var user_interface
var bounding_sphere_size : float

var cell_weight = GlobalSettings.cell_weight
var cell_energy = GlobalSettings.energy_dropped_on_cell_death
var required_energy = GlobalSettings.energy_required_to_reproduce

@onready var visual_effects_root_node = $"Visual Effects"
@onready var line_2d = $"Visual Effects/Line2D"

signal mitosis
signal cell_death(cellID:String)

# Called when the node enters the scene tree for the first time.
func _ready():
	#i is because there is no enumerate
	food_object = get_parent().get_node('FoodObject')
	user_interface = get_parent().get_node('CanvasLayer').get_node('UserInterface')
	var i = 0
	for RNA in DNA:
		var cell_base = load("res://Cell Types/Scenes/" + RNA['Type'])
		var cell_instance = cell_base.instantiate()
		add_child(cell_instance)
		cell_instance.unpack(RNA, str(i))
		i += 1
	
	mass = i * cell_weight
	for cell in get_children():
		cells[cell.name] = cell
	cells.erase('Visual Effects')
	
	# Box around the creature
	for cellID in cells:
		var cell = cells[cellID]
		if cell.position.distance_squared_to(center_of_mass) > bounding_sphere_size:
			bounding_sphere_size = cell.position.distance_squared_to(center_of_mass)
	bounding_sphere_size = sqrt(bounding_sphere_size)
	var box_side_length = bounding_sphere_size * 2
	line_2d.points = [
		Vector2(1,1) * box_side_length + center_of_mass, 
		Vector2(1,-1) * box_side_length + center_of_mass, 
		Vector2(-1,-1) * box_side_length + center_of_mass, 
		Vector2(-1,1) * box_side_length + center_of_mass, 
		Vector2(1,1) * box_side_length + center_of_mass,
		Vector2(1,-1) * box_side_length + center_of_mass
		]
	line_2d.visible = false
	
	get_parent().get_node('FoodSpawnPoints').get_node('FoodSpawnTimer').timeout.connect(reproduce_time)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	clear_killing_queue()
	line_2d.global_rotation = 0.0 # boxD
	
	var frame_energy_consumption = 0.0
	for cellID in cells:
		var cell = cells[cellID]
		cell.update_output()
	for cellID in cells:
		var cell = cells[cellID]
		cell.read_and_act(delta)
		frame_energy_consumption += cell.energy_consumption
	energy -= frame_energy_consumption * delta
	if energy <= 0:
		die()
#	if energy >= required_energy:
#		mitosis.emit(self)
	
func reproduce_time():
	if energy >= GlobalSettings.energy_required_to_reproduce:
		mitosis.emit(self)

func _on_body_shape_entered(_body_rid, body, body_shape_index, local_shape_index):
	#print('---Collision handling start---')
	if not body is RigidBody2D:
		#print('---Not a creature break---')
		return
	#print(body)
	#if body.get_child_count() < body_shape_index+2:
	#	print('Ahh fuck')
	#	body.die()
	var local_cell = get_child(local_shape_index+1)
	var body_cell = body.get_child(body_shape_index+1)
	#print(body_cell)
	#print(local_cell)
	if is_instance_valid(body_cell) and is_instance_valid(local_cell): # Checks if the cell has already been eaten
		if 'Eats' in body_cell.tags and not 'Inedible' in local_cell.tags:
			#print('-We have been consumed-')
			kill_cell(get_child(local_shape_index+1).cellID)
	#print('---Collision handling end---')
	
	
func kill_cell(cellID : String):
	var cell = get_node(cellID)
	var cell_copy = cell.duplicate() 
	# NOTE I am very mad. This took a while to find
	# This is an issue with godot, here's the git report I found: https://github.com/godotengine/godot/issues/3393#issuecomment-1218262767
	# Confirmed bug from 2016
	# Fuck me I guess
	cell_copy.cellID = cell.cellID
	killing_queue.append(cell_copy)
	cell.queue_free()

func clear_killing_queue():
	if killing_queue != []:
#INFO First remove the invalid (free'd) cells from cells
		var placeholder_cells = {} 
		for cellID in cells:
			var cell = cells[cellID]
			if is_instance_valid(cell): # Checks if the cell has been removed in kill_cell
				placeholder_cells[cellID] = cell
		cells = placeholder_cells
#INFO Then group the cells by if they're touching
		var adjacent_offsets = [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]
		var groups_of_cells = []
		for cellID in cells:
			var cell = cells[cellID]
			#print(cell.position)
			var groups_it_fit = []
			var i = 0
			for group in groups_of_cells:
				var group_positions = []
				for item in group:
					group_positions.append(item.position)
				for offset in adjacent_offsets:
					if (cell.position + offset) in group_positions:
						groups_it_fit.append(i)
						break
				i += 1
			if len(groups_it_fit) == 0: # If it didnt match any group
				#print('First')
				groups_of_cells.append([cell])
			elif len(groups_it_fit) == 1: # If it only matched one group
				#print('Second')
				groups_of_cells[groups_it_fit[0]].append(cell)
			else: # If it matched multiple groups
				#print('Third')
				var new_group = []
				groups_it_fit.reverse()
				for group_index in groups_it_fit:
					new_group.append_array(groups_of_cells.pop_at(group_index))
				groups_of_cells.append(new_group)
#INFO Then add potential cut-off parts to killing queue
		if groups_of_cells.size() > 1:
			print('several_groups')
			print(groups_of_cells.size())
			print(groups_of_cells)
			groups_of_cells.sort_custom(sort_by_length)
			if len(groups_of_cells[0]) <= len(DNA) * 0.5:
				die()
			else:
				groups_of_cells.remove_at(0)
				for group in groups_of_cells:
					for cell in group:
						var cell_copy = cell.duplicate() 
						cell_copy.cellID = cell.cellID
						killing_queue.append(cell_copy)
						cell.free() # Might be risky
#INFO Remove invalid cells again
		placeholder_cells = {} 
		for cellID in cells:
			var cell = cells[cellID]
			if is_instance_valid(cell): # Checks if the cell has been removed in kill_cell
				placeholder_cells[cellID] = cell
		cells = placeholder_cells
#INFO Remove all connections to dead cells
		var killing_queue_cellID = []
		for cell in killing_queue:
			killing_queue_cellID.append(cell.cellID)
		for cellID in cells:
			var cell = cells[cellID]
			cell.remove_connections(killing_queue_cellID)
#INFO Spawn food and send relevant signals
		for cell in killing_queue:
			food_object.add_food(cell_energy, cell.global_position)
			mass -= cell_weight
			cell_death.emit(cell.cellID)
		killing_queue = []
#INFO Check if the creature died
	if len(cells) <= len(DNA) * 0.5:
		print('Not enough mass')
		die()

func die():
	print('Aaauuugh my leg!')
	for cellID in cells:
		var cell = cells[cellID]
		food_object.add_food(cell_energy, cell.global_position)
	queue_free()

func _on_input_event(_viewport, event, _shape_idx): # Box
	if event.is_action_pressed('click'):
		user_interface.creature_clicked(self)


func sort_by_length(a, b):
	if len(a) > len(b):
		return 1
	return 0
