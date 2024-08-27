extends Control
var creature_selected
var rendered_creature = Image
var connections = []
@onready var creature_sim = $"Creature View/Creature Sim"
@onready var progress_bar = $"TabContainer/HBoxContainer/Creature View/ProgressBar"

var visual_creature_file = preload("res://Misc/UI assets/visual_creature.tscn")
const CONNECTION2D = preload("res://Misc/UI assets/connection.gd")

func _ready():
	visible = false


func _process(_delta):
	if not creature_selected: # When there is no selected creature: break
		return 0
	var real_cells = creature_selected.cells
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
	if is_instance_valid(creature_selected):
		if creature_selected.get_child(0).get_child(0).visible:
			creature_selected.get_child(0).get_child(0).visible = false
			creature_selected.cell_death.disconnect(_on_cell_death)
	visible = true
	creature.get_child(0).get_child(0).visible = true
	creature_selected = creature
	load_creature(creature_selected)
	creature.cell_death.connect(_on_cell_death)

func load_creature(creature):
	var visual_creature_instance = visual_creature_file.instantiate()
	visual_creature_instance.creature = creature
	if creature_sim.get_child_count() > 0:
		creature_sim.remove_child(creature_sim.get_child(0))
	creature_sim.add_child(visual_creature_instance)
	progress_bar.max_value = len(creature.cells) * GlobalSettings.energy_cap_PC
	
func _on_cell_death(_cellID):
	load_creature(creature_selected)
