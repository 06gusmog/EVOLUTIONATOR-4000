extends Node2D

var lineage_log: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("Persist")

	if not lineage_log == {}:
		LineageLogger.creature_tree = lineage_log
	else:
		LineageLogger.creature_tree = {"-1": ["-1", [], 0, -1, "", {  }]}

func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"lineage_log": LineageLogger.creature_tree
	}
	return save_dict
