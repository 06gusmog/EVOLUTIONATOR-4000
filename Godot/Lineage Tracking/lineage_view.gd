extends HBoxContainer

@onready var creature_lineage_view: TextureRect = $"Creature Lineage View"
@onready var file_name: LineEdit = $"Button Panel/Name"

const SAVE_PATH = "res://Lineage Tracking/Saved Lineages/"

func _on_load_and_save_all_lineages_button_down() -> void:
	if file_name.text != '':
		DirAccess.make_dir_absolute(SAVE_PATH + file_name.text + '/')
		var i = 0
		for creatureID in LineageLogger.get_creature('-1')[1]:
			var relative_lineage = LineageLogger.get_relative_lineage(creatureID)
			var image = LineageLogger.get_image(relative_lineage.keys()[1])
		
			image.save_png(SAVE_PATH + file_name.text + '/' + str(i) + '.png')
			i += 1
