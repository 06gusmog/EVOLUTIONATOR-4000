extends Node2D
var creature_selected


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not creature_selected: # When there is no selected creature: break
		return 0
	


func creature_clicked(creature):
	print(creature)
	if creature_selected:
		creature_selected.get_child(0).get_child(0).visible = false
	creature.get_child(0).get_child(0).visible = true
	creature_selected = creature
