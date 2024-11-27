extends RigidBody2D
var DNA : Array
var killing_queue : Array
var killing_queue_ID : Array
var cells : Dictionary
var output_cells : Dictionary
var energy : float
var food_object
var bounding_sphere_size : float
var creatureID : String
var cellIDs : Array 
var per_frame_energy_consumption: float

var cell_weight = GlobalSettings.cell_weight

@onready var visual_effects_root_node = $"Visual Effects"
@onready var line_2d = $"Visual Effects/Line2D"

signal mitosis
signal cell_death(cellID:String)
signal death

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("Persist")
	self.add_to_group("Creature")
	#i is because there is no enumerate
	food_object = get_parent().get_node('FoodObject')
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
	
	# Optimizing cell list and connections
	for cellID in cells:
		var cell = cells[cellID]
		if 'Output' in cell.tags:
			output_cells[cell.cellID] = cell
		if 'Input' in cell.tags:
			var optimized_connections = []
			for connection in cell.connections:
				if 'Output' in cells[connection].tags:
					optimized_connections.append(connection)
			cell.connections = optimized_connections
		else:
			cell.connections = []
	
	# Box around the creature
	for cellID in cells:
		var cell = cells[cellID]
		if cell.position.distance_squared_to(center_of_mass) > bounding_sphere_size: #CRITICAL: It crashes on startup here sometimes, error message: Invalid get index 'position' (on base: 'String'). No idea why
			# When saving the cells, references to cell objects are saved as strings instead 
			# of the cells themselves being saved. The cells are saved as children, but the 
			# dictionary is just strings. This works when the creatures are whole because
			# the strings are overwritten with actual references. (lines 35-38). I don't know why 
			# the cells are just completely replaced (lines 28-33) but this solution is fundementally
			# flawed and needs replacing.
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
	for cellID in cells:
		var cell = cells[cellID]
		per_frame_energy_consumption += cell.energy_consumption
	energy = GlobalSettings.starting_energy * per_frame_energy_consumption
	
	get_parent().get_node('FoodSpawnPoints').get_node('FoodSpawnTimer').timeout.connect(reproduce_time)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	clear_killing_queue()
	line_2d.global_rotation = 0.0 # boxD
	for cellID in output_cells:
		var cell = cells[cellID]
		cell.update_output()
	per_frame_energy_consumption = 0
	for cellID in cells:
		var cell = cells[cellID]
		cell.read_and_act(delta)
		per_frame_energy_consumption += cell.energy_consumption
	energy -= per_frame_energy_consumption * delta * GlobalSettings.metabolism_modifier
	if energy <= 0:
		die()
#	if energy >= required_energy:
#		mitosis.emit(self)

func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"DNA": save_DNA(DNA),
		"cellIDs": cells.keys(), 
		"energy": energy, 
		"creatureID": creatureID, 
		"bounding_sphere_size": bounding_sphere_size
	}
	return save_dict

func save2():
	var saved_cells = {}
	for cellID in cells:
		var cell = cells[cellID]
		saved_cells[cellID] = {
			"pos_x": cell.position.x,
			"pos_y": cell.position.y,
			"type": cell.type,
			"connections": cell.connections,
			"special sauce": DNA[int(cellID)]['Special Sauce']
		}
	var saved_DNA = DNA.duplicate(true)
	for RNA in saved_DNA:
		RNA['Position'] = var_to_str(RNA['Position'])
	var save_dict = {
		"pos_x": position.x,
		"pos_y": position.y,
		"rotation": rotation,
		"vel_x": linear_velocity.x,
		"vel_y": linear_velocity.y,
		"vel_rotation": angular_velocity,
		"energy": energy,
		"cells": saved_cells,
		"mass": mass,
		"bounding_sphere_size": bounding_sphere_size,
		"DNA": saved_DNA,
		"creatureID": creatureID
		
	}
	return save_dict

func load2(data):
	# Remove the shit that ready did
	for child in self.get_children():
		if child.name == 'Visual Effects':
			continue
		child.name = 'Unoccupied Name'
		child.queue_free()
	cells = {}
	
	position = Vector2(data['pos_x'], data['pos_y'])
	rotation = data['rotation']
	linear_velocity = Vector2(data['vel_x'], data['vel_y'])
	angular_velocity = data['vel_rotation']
	for cellID in data['cells']:
		var cell_data = data['cells'][cellID]
		var cell_base = load("res://Cell Types/Scenes/" + cell_data['type'])
		var cell_instance = cell_base.instantiate()
		add_child(cell_instance)
		var RNA = {
			"Position": Vector2(cell_data['pos_x'], cell_data['pos_y']), 
			"Type": cell_data['type'], 
			"Connections": cell_data['connections'],
			"Special Sauce": cell_data['special sauce']
		}
		cell_instance.unpack(RNA, cellID)
		cells[cellID] = cell_instance
	bounding_sphere_size = data['bounding_sphere_size']
	var box_side_length = bounding_sphere_size * 2
	line_2d.points = [
		Vector2(1,1) * box_side_length + center_of_mass, 
		Vector2(1,-1) * box_side_length + center_of_mass, 
		Vector2(-1,-1) * box_side_length + center_of_mass, 
		Vector2(-1,1) * box_side_length + center_of_mass, 
		Vector2(1,1) * box_side_length + center_of_mass,
		Vector2(1,-1) * box_side_length + center_of_mass
		]
	energy = data['energy']
	
	var to_remove = []
	for cellID in output_cells:
		print(cellID)
		if not cellID in cells.keys():
			print(cellID, ' Removed')
			to_remove.append(cellID)
	for item in to_remove:
		output_cells.erase(item)

func reproduce_time():
	if not energy >= GlobalSettings.reproduction_energy_requirement * per_frame_energy_consumption:
		return
	var child_position
	if linear_velocity == Vector2(0,0):
		child_position = position + Vector2(0, bounding_sphere_size * 3)
	else:
		child_position = position + -linear_velocity.normalized() * bounding_sphere_size * 3
	var shape_rid = PhysicsServer2D.circle_shape_create()
	var radius = bounding_sphere_size
	PhysicsServer2D.shape_set_data(shape_rid, radius)

	var params = PhysicsShapeQueryParameters2D.new()
	params.shape_rid = shape_rid
	params.transform = Transform2D(0, child_position)

	var space_state = get_world_2d().direct_space_state
	if space_state.collide_shape(params, 1) == []:
		mitosis.emit(self, child_position)

	PhysicsServer2D.free_rid(shape_rid)


func _on_body_shape_entered(_body_rid, body, body_shape_index, local_shape_index):
	#print('---Collision handling start---')
	if not body is RigidBody2D:
		#print('---Not a creature break---')
		return
	
	var local_cell = self.shape_owner_get_owner(self.shape_find_owner(local_shape_index))
	var body_cell = body.shape_owner_get_owner(body.shape_find_owner(body_shape_index))
	if not(is_instance_valid(local_cell) and is_instance_valid(body_cell)):
		#print('Something has gone horribly wrong, and this error handling is keeping the simulation from crashing')
		return 0
	if not (body_cell.cellID in body.killing_queue or local_cell.cellID in killing_queue): # Checks if the cell has already been eaten 
		if 'Eats' in body_cell.tags and not 'Inedible' in local_cell.tags:
			#print('-We have been consumed-')
			kill_cell(local_cell.cellID)
	#print('---Collision handling end---')

func kill_cell(cellID : String):
	if cells[cellID] in killing_queue: #NOTE Killing queue breaks with multiple of the same entry
		return 0
	killing_queue.append(cells[cellID])

func clear_killing_queue():
	if killing_queue != []:
#INFO First group the cells by if they're touching
		var alive_cells = {}
		for cellID in cells:
			if cells[cellID] in killing_queue:
				continue
			alive_cells[cellID] = cells[cellID]
		var groups_of_cells = group_cells(alive_cells) # Moved to its own function, for potential use in SimulationHandler
#INFO Then add potential cut-off parts to killing queue
		if groups_of_cells.size() > 1:
			groups_of_cells.sort_custom(sort_by_length)
			if len(groups_of_cells[0]) <= len(DNA) * 0.5:
				die()
			else:
				groups_of_cells.remove_at(0)
				for group in groups_of_cells:
					for cell in group:
						killing_queue.append(cell)
#INFO Remove all cells that are supposed to be removed
		for cell in killing_queue:
			cells.erase(cell.cellID)
			output_cells.erase(cell.cellID)
#INFO Remove all connections to dead cells
		var killing_queue_cellID = []
		for cell in killing_queue:
			killing_queue_cellID.append(cell.cellID)
		for cellID in cells:
			var cell = cells[cellID]
			cell.remove_connections(killing_queue_cellID)
#INFO Spawn food, remove the cells and send relevant signals
		for cell in killing_queue:
			food_object.add_food((cell.energy_consumption + energy * (cell.energy_consumption/per_frame_energy_consumption)) * GlobalSettings.energy_drop_modifier, cell.global_position)
			mass -= cell_weight
			cell_death.emit(cell.cellID)
			self.remove_child(cell)
			cell.queue_free()
		killing_queue = []
#INFO Check if the creature died
	if len(cells) <= len(DNA) * 0.5:
		die()

func check_connections():
	for cellID in cells:
		var cell = cells[cellID]
		var corrected_connections = []
		for connection in cell.connections:
			if connection in cells.keys():
				corrected_connections.append(connection)
		cell.connections = corrected_connections
		
func die():
	for cellID in cells:
		var cell = cells[cellID]
		food_object.add_food((cell.energy_consumption + energy * (cell.energy_consumption/per_frame_energy_consumption)) * GlobalSettings.energy_drop_modifier, cell.global_position)
	LineageLogger.log_creature_death(creatureID)
	death.emit()
	queue_free()

func sort_by_length(a, b):
	if len(a) > len(b):
		return 1
	return 0

func group_cells(cells:Dictionary):
	var adjacent_offsets = [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]
	var groups_of_cells = []
	for cellID in cells:
		var cell = cells[cellID]
		if cell in killing_queue:
			continue
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
			groups_of_cells.append([cell])
		elif len(groups_it_fit) == 1: # If it only matched one group
			groups_of_cells[groups_it_fit[0]].append(cell)
		else: # If it matched multiple groups
			var new_group = []
			groups_it_fit.reverse()
			for group_index in groups_it_fit:
				new_group.append_array(groups_of_cells.pop_at(group_index))
			groups_of_cells.append(new_group)
	return groups_of_cells
	

func save_DNA(DNA):
	for RNA in DNA:
		if not typeof(RNA['Position']) == TYPE_STRING:
			RNA['Position'] = var_to_str(RNA['Position'])
	return DNA

func load_DNA(DNA):
	if typeof(DNA[0]['Position']) == TYPE_STRING:
		for RNA in DNA:
			RNA['Position'] = str_to_var(RNA['Position'])
	return DNA
