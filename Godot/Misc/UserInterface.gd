extends Control
var creature_selected
var is_a_creature_selected = false
var rendered_creature = Image
var connections = []

@onready var camera_2d = $"../../Camera2D"
@export var camera_move_speed = 5.0

@onready var creature_sim = $"Creature View/Creature Sim"
@onready var progress_bar = $"TabContainer/HBoxContainer/Creature View/ProgressBar"
@onready var world = $"../.."
@onready var texture_rect = $TabContainer/HBoxContainer2/AspectRatioContainer/TextureRect

var visual_creature_file = preload("res://Misc/UI assets/visual_creature.tscn")
const CONNECTION2D = preload("res://Misc/UI assets/connection.gd")

func _ready():
	var blank_image = Image.create(10,10, false, Image.FORMAT_RGBA8)
	blank_image.save_png('res://Lineage Tracking/Icons/test.png')

func _process(_delta):
	camera_2d.position += Input.get_vector( 'left', 'right', 'up', 'down') * camera_move_speed * 1/camera_2d.zoom
	camera_2d.zoom -= Vector2(0.01, 0.01) * Input.get_axis("zoom_in", "zoom_out") * camera_2d.zoom
	
	if Input.is_action_just_pressed('Pause'):
		if get_tree().paused:
			print('Unpause')
			get_tree().paused = false
		else:
			print('Pause')
			get_tree().paused = true
	
	if Input.is_action_just_pressed('click'):
		var mouse_pos = world.get_local_mouse_position()
		print(mouse_pos)
		is_a_creature_selected = false
		creature_sim.get_child(0).visible = false
		progress_bar.value = 0
		if is_instance_valid(creature_selected):
			creature_selected.get_child(0).get_child(0).visible = false
		for creature in world.get_children():
			if not creature is RigidBody2D:
				continue
			#print(mouse_pos.distance_squared_to(creature.global_position))
			if mouse_pos.distance_squared_to(creature.global_position) <= creature.bounding_sphere_size*creature.bounding_sphere_size:
				creature_clicked(creature)
				is_a_creature_selected = true
				creature_sim.get_child(0).visible = true
				break
			
		
	if not is_a_creature_selected: # When there is no selected creature: break
		return 0
	if not is_instance_valid(creature_selected):
		return 0
	var real_cells = creature_selected.cells # Signal when creature dies
	for sim_cell in creature_sim.get_child(0).get_children():
		if sim_cell is Camera2D:
			continue
		#print(sim_cell.tags)
		if is_instance_valid(real_cells[sim_cell.cellID]):
			if 'Output' in sim_cell.tags:
				var output = real_cells[sim_cell.cellID].output
				var dot_sprite = sim_cell.get_node('Dot')
				var hue = (output + 1) / 2
				dot_sprite.modulate = Color(hue,hue,hue)
			if 'Input' in sim_cell.tags:
				#print(sim_cell.tags)
				for connection in sim_cell.get_children():
					#print(connection)
					if connection is CONNECTION2D: # theres some other sprites and stuff in there that I have to filther out.
						#print('hello')
						connection.update_output(real_cells[connection.origin_cellID].output)
		
	progress_bar.value = creature_selected.energy
	
	
		


func creature_clicked(creature):
	var relative_lineage = LineageLogger.get_relative_lineage(creature.creatureID)
	var image = LineageLogger.get_image(relative_lineage.keys()[1])
	texture_rect.texture = ImageTexture.create_from_image(image)
	image.save_png('res://Lineage Tracking/Icons/test.png')
	print_rich('[img]res://Lineage Tracking/Icons/test.png[/img]')
	if is_instance_valid(creature_selected):
		if creature_selected.get_child(0).get_child(0).visible:
			creature_selected.get_child(0).get_child(0).visible = false
			creature_selected.cell_death.disconnect(_on_cell_death)
	visible = true
	creature.get_child(0).get_child(0).visible = true
	creature_selected = creature
	load_creature(creature_selected)
	creature.cell_death.connect(_on_cell_death)
	creature.death.connect(_on_creature_death)

func load_creature(creature):
	var visual_creature_instance = visual_creature_file.instantiate()
	visual_creature_instance.creature = creature
	if creature_sim.get_child_count() > 0:
		creature_sim.remove_child(creature_sim.get_child(0))
	creature_sim.add_child(visual_creature_instance)
	progress_bar.max_value = len(creature.cells) * GlobalSettings.energy_cap_PC
	
func _on_cell_death(_cellID):
	self.call_deferred("load_creature", creature_selected)

func _on_creature_death():
	is_a_creature_selected = false
	creature_sim.get_child(0).visible = false
	progress_bar.value = 0
