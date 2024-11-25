extends Node
# Lineage tracking

const REGISTRY_FOLDER_PATH = "res://Lineage Tracking/Registry/"
#[parent, children, time of birth, time of death(-1.0 if alive), DNA]
var creature_tree = {"-1": ["-1", [], 0, -1, "", {  }]}

var creature_count = len(creature_tree)
func _ready():
	for x in range(creature_count/50):
		var file = ConfigFile.new()
		for y in range(min(50, creature_count - x*50)): # NOTE: Condition not functional, revisit. 
			var current_creature = creature_tree[str(x*50 + y)]
			file.set_value(str(y), "parent", current_creature[0])
			file.set_value(str(y), "children", current_creature[1])
			file.set_value(str(y), "time of birth", current_creature[2])
			file.set_value(str(y), "time of death", current_creature[3])
			file.set_value(str(y), "DNA", current_creature[4])
			file.save(REGISTRY_FOLDER_PATH + str(x) + ".cfg")
	pass

func log_creature_creation(parentID, DNA):
	creature_tree[str(len(creature_tree))] = [parentID, [], Time.get_ticks_msec(), -1.0, DNA]
	if parentID != '-1':
		creature_tree[parentID][1].append(str(len(creature_tree)-1))
	return str(len(creature_tree)-1)

func get_creature(ID):
	var file = ConfigFile.new()
	file.load(REGISTRY_FOLDER_PATH + str(int(ID)/50) + ".cfg")
	var creature = []
	creature.append(file.get_value(ID, "parent"))
	creature.append(file.get_value(ID, "children"))
	creature.append(file.get_value(ID, "time of birth"))
	creature.append(file.get_value(ID, "time of death"))
	creature.append(file.get_value(ID, "DNA"))
	return creature

func log_creature_creation_2(parentID, DNA):
	"""I think this works now, still untested though. Not sure if it just keeps going on an 
	empty file if it failed to load. That part should probably be improved regardless. """
	var target_file_index = str(int(creature_count + 1)/50)
	var file = ConfigFile.new()
	var err = file.load(REGISTRY_FOLDER_PATH + target_file_index + ".cfg")
	if err != OK:
		if err == ERR_UNAVAILABLE:
			pass
		else:
			return
	file.set_value(str(creature_count + 1), "parent", parentID)
	file.set_value(str(creature_count + 1), "children", [])
	file.set_value(str(creature_count + 1), "time of birth", Time.get_ticks_msec())
	file.set_value(str(creature_count + 1), "time of death", -1)
	file.set_value(str(creature_count + 1), "DNA", DNA)
	file.save(REGISTRY_FOLDER_PATH + target_file_index + ".cfg")
	file.close
	if parentID != "-1":
		var parent_file = ConfigFile.new()
		var parent_err = file.load(REGISTRY_FOLDER_PATH + str(int(parentID)/50) + ".cfg")
		if parent_err != OK:
			return
		var old_value = parent_file.get_value(parentID, "children")
		parent_file.set_value(parentID, "children", Array(old_value) + creature_count)
		parent_file.save(REGISTRY_FOLDER_PATH + str(int(parentID)/50) + ".cfg")
	creature_count += 1
	return str(creature_count - 1)

func log_creature_death(creatureID):
	creature_tree[creatureID][3] = Time.get_ticks_msec()

func get_image(creatureID: String):
	var paddingx = 1
	var paddingy = 1
	var edge_thickness = 1
	var edge_color = Color.WHITE
	var childrenIDs = creature_tree[creatureID][1]
	if len(childrenIDs) > 0:
		# Get all child icons recursively
		var images = []
		var sizex = 0
		var sizey = 0
		for childID in childrenIDs:
			images.append(get_image(childID))
			if images[-1].get_height() > sizey:
				sizey = images[-1].get_height()
			sizex += images[-1].get_width()
		
		# Create image and selfie
		var selfie = generate_icon(creature_tree[creatureID][4], GlobalSettings.color_sheet)
		var groupie = Image.create(sizex + (len(images) + 1) * paddingx + edge_thickness * 2, sizey + paddingy + selfie.get_height(), false, Image.FORMAT_RGBA8)
		groupie.fill(Color.BLACK)
		
		# Set edge pixels white
		var groupie_width = groupie.get_width()
		for x in range(edge_thickness):
			for y in range(groupie.get_height()):
				groupie.set_pixel(x, y, edge_color)
				groupie.set_pixel(groupie_width - x - 1, y, edge_color)
		
		# Add everything together
		var selfie_rect = Rect2(Vector2(0,0), Vector2(selfie.get_width(), selfie.get_height()))
		groupie.blit_rect(selfie, selfie_rect, Vector2(int((groupie.get_width()-selfie.get_width() + 1)/2), 0))
		var y_pos = selfie.get_height() + paddingy
		var width_sum = edge_thickness + paddingx
		for image in images:
			var image_rect = Rect2(Vector2(0,0), Vector2(image.get_width(), image.get_height()))
			groupie.blit_rect(image, image_rect, Vector2(width_sum, y_pos))
			width_sum += image.get_width() + paddingx
		return groupie
	
	return generate_icon(creature_tree[creatureID][4], GlobalSettings.color_sheet)

func generate_icon(DNA, color_sheet):
	var lowest_positions = Vector2(0,0)
	var icon_size = Vector2(0,0)
	for RNA in DNA:
		var pos = RNA['Position']
		if pos.x < lowest_positions.x:
			lowest_positions.x = pos.x
		if pos.y < lowest_positions.y:
			lowest_positions.y = pos.y
		if pos.x > icon_size.x:
			icon_size.x = pos.x
		if pos.y > icon_size.y:
			icon_size.y = pos.y
	icon_size -= lowest_positions # Because lowest_positions is negative
	var icon = Image.create(icon_size.x+1, icon_size.y+1, false, Image.FORMAT_RGBA8)
	icon.fill(Color.BLACK)
	for RNA in DNA:
		icon.set_pixel(RNA['Position'].x - lowest_positions.x, RNA['Position'].y - lowest_positions.y, color_sheet[RNA['Type']])
	
	return icon

func get_relative_lineage(creatureID):
	# Get first creature in the chain
	var parentID = creature_tree[creatureID][0]
	while parentID != '-1':
		creatureID = parentID
		parentID = creature_tree[parentID][0]
	
	# Get all the creatureIDs and put them into a list
	var i = 0
	var list_of_creatureIDs = [creatureID]
	while i < len(list_of_creatureIDs):
		list_of_creatureIDs.append_array(creature_tree[list_of_creatureIDs[i]][1])
		i += 1
	
	# Convert that list into the dictionary we want
	var relative_lineage = {'-1':['-1', [], 0.0, -1.0, '', {}]}
	for ID in list_of_creatureIDs:
		relative_lineage[ID] = creature_tree[ID]
	
	return relative_lineage
