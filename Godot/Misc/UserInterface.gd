extends Control
var creature_selected
var rendered_creature = Image
var connections = []
@onready var creature_sim = $"Creature View/Creature Sim"

var visual_creature_file = preload("res://Misc/UI assets/visual_creature.tscn")
const CONNECTION2D = preload("res://Misc/UI assets/connection.gd")

func _ready():
	visible = false


func _process(_delta):
	if not creature_selected: # When there is no selected creature: break
		return 0
	var i = 0
	var real_cells = creature_selected.cells
	for sim_cell in creature_sim.get_child(0).get_children():
		if sim_cell is Camera2D:
			continue
		var output = real_cells[i].output
		for connection in sim_cell.get_children():
			if connection is CONNECTION2D:
				connection.update_output(output)
		i += 1


func creature_clicked(creature):
	if creature_selected:
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
	
func _on_cell_death(cellID):
	load_creature(creature_selected)

func _on_exit_button_pressed():
	visible = false
	creature_selected.get_child(0).get_child(0).visible = false
	creature_selected.cell_death.disconnect(_on_cell_death)
