extends RigidBody2D
var DNA : Array
var killing_queue : Array
var cells : Array
var energy = 1000.0
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
	cells = get_children()
	cells.pop_front()
	
	# Box around the creature
	for cell in cells:
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	line_2d.global_rotation = 0.0 # box
	
	clear_killing_queue()
	var frame_energy_consumption = 0.0
	for cell in cells:
		cell.update_output()
	for cell in cells:
		cell.read_and_act(delta)
		frame_energy_consumption += cell.energy_consumption
	energy -= frame_energy_consumption * delta
	if energy <= 0:
		die()
	if energy >= required_energy:
		mitosis.emit(self)


func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	#print('---Collision handling start---')
	if not body is RigidBody2D:
		#print('---Not a creature break---')
		return 0
	var local_cell = cells[local_shape_index]
	var body_cell = body.cells[body_shape_index]
	#print(body_cell)
	#print(local_cell)
	if 'Eats' in body_cell.tags and not 'Inedible' in local_cell.tags:
		#print('-We have been consumed-')
		kill_cell(str(local_shape_index))
	#print('---Collision handling end---')
	
	
func kill_cell(cellID : String):
	killing_queue.append(cellID)

func clear_killing_queue():
	if killing_queue != []:
		var placeholder_cells = []
		for cell in cells:
			if cell.cellID in killing_queue:
				food_object.add_food(cell_energy, cell.global_position)
				cell.queue_free()
				mass -= cell_weight
				continue
			cell.remove_connections(killing_queue)
			placeholder_cells.append(cell)
		for item in killing_queue:
			cell_death.emit(item)
		cells = placeholder_cells
		killing_queue = []
	if cells == []:
		die()

func die():
	for cell in cells:
		food_object.add_food(cell_energy, cell.global_position)
		mass -= cell_weight
	queue_free()

func _on_input_event(_viewport, event, _shape_idx): # Box
	if event.is_action_pressed('click'):
		user_interface.creature_clicked(self)
