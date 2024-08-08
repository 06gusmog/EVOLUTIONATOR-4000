extends Control
var creature_selected
var rendered_creature = Image
var connections = []

func _ready():
	visible = false


func _process(_delta):
	if not creature_selected: # When there is no selected creature: break
		return 0
	for connection in connections:
		var strength = creature_selected.get_child(connection['From'])
		


func creature_clicked(creature):
	if creature_selected:
		creature_selected.get_child(0).get_child(0).visible = false
	visible = true
	creature.get_child(0).get_child(0).visible = true
	creature_selected = creature


func _on_exit_button_pressed():
	visible = false
	creature_selected.get_child(0).get_child(0).visible = false
