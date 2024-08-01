extends RigidBody2D
var DNA : Array
var killing_queue : Array
var cells : Array

@onready var visual_effects_root_node = $"Visual Effects"


# Called when the node enters the scene tree for the first time.
func _ready():
	#i is because there is no enumerate
	var i = 0
	for RNA in DNA:
		var cell_base = load("res://Cell Types/Scenes/" + RNA['Type'] + ".tscn")
		var cell_instance = cell_base.instantiate()
		add_child(cell_instance)
		cell_instance.unpack(RNA, str(i))
		i += 1
	cells = get_children()
	cells.pop_front()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	clear_killing_queue()
	
	for cell in cells:
		cell.update_output()
	for cell in cells:
		cell.read_and_act()


func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	print('---Collision handling start---')
	if not body is RigidBody2D:
		print('---Not a creature break---')
		return 0
	var local_cell = get_child(local_shape_index)
	var body_cell = get_parent().get_child(body).get_child(body_shape_index)
	if 'Eats' in body_cell.tags and not 'Inedible' in local_cell.tags:
		print('-We have been consumed-')
		kill_cell(local_shape_index)
	print('---Collision handling end---')
	
	
func kill_cell(cellID : String):
	killing_queue.append(cellID)

func clear_killing_queue():
	if killing_queue != []:
		var placeholder_cells = []
		for cell in cells:
			if cell.cellID in killing_queue:
				cell.queue_free()
				continue
			cell.remove_connections(killing_queue)
			placeholder_cells.append(cell)
		cells = placeholder_cells
		killing_queue = []





