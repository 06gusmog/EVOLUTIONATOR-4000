extends Node2D

var lineage_log: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("Persist")

	if not lineage_log == {}:
		LineageLogger.creature_tree = load_registry()
	else:
		LineageLogger.creature_tree = {"-1": ["-1", [], 0, -1, "", {  }]}

func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"lineage_log": save_registry()
	}
	return save_dict

func save_registry():
	var registry = LineageLogger.creature_tree.duplicate()
	for creatureID in registry:
		var creature = registry[creatureID][4]
		for cell in creature:
			cell["Position"] = var_to_str(cell["Position"])
	return registry

func load_registry():
	var registry = lineage_log.duplicate()
	for creatureID in registry:
		var creature = registry[creatureID][4]
		for cell in creature:
			cell["Position"] = str_to_var(cell["Position"])
	return registry
