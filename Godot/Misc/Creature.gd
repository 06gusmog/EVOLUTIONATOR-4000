extends RigidBody2D
var DNA : Array
var killing_queue : Array
var cells : Array
var energy = 1000.0
var food_object

@export var cell_weight : float
@export var cell_energy : float

@onready var visual_effects_root_node = $"Visual Effects"

# Called when the node enters the scene tree for the first time.
func _ready():
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
	cells = get_children()
	cells.pop_front()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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


func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	#print('---Collision handling start---')
	if not body is RigidBody2D:
		#print('---Not a creature break---')
		return 0
	var local_cell = cells[local_shape_index]
	var body_cell = body.cells[body_shape_index]
	print(body_cell)
	print(local_cell)
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
		cells = placeholder_cells
		killing_queue = []
	if cells == []:
		die()

func die():
	for cell in cells:
		food_object.add_food(cell_energy, cell.global_position)
		mass -= cell_weight
	queue_free()







