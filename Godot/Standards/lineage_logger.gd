extends Node
# Lineage tracking

const REGISTRY_FOLDER_PATH = "res://Lineage Tracking/Registry/"
#[parent, children, time of birth, time of death(-1.0 if alive), DNA]

var creature_count = 0
func _ready():
	for file in DirAccess.get_files_at(REGISTRY_FOLDER_PATH):
		DirAccess.remove_absolute(REGISTRY_FOLDER_PATH + file)
	
	var file = ConfigFile.new()
	var err = file.load(REGISTRY_FOLDER_PATH + "0.cfg")
	if err != OK:
		if err == ERR_FILE_NOT_FOUND:
			pass
	file.set_value("-1", "parent", "-1")
	file.set_value("-1", "children", [])
	file.set_value("-1", "time of birth", 0)
	file.set_value("-1", "time of death", -1)
	file.set_value("-1", "DNA", {})
	file.save(REGISTRY_FOLDER_PATH + "0.cfg")

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

func log_creature_creation(parentID, DNA):
	var target_file_index = str(int(creature_count)/50)
	var file = ConfigFile.new()
	var err = file.load(REGISTRY_FOLDER_PATH + target_file_index + ".cfg")
	if err != OK:
		if err == ERR_FILE_NOT_FOUND:
			pass
		else:
			print(err)
			return
	file.set_value(str(creature_count), "parent", parentID)
	file.set_value(str(creature_count), "children", [])
	file.set_value(str(creature_count), "time of birth", GlobalSettings.global_time)
	file.set_value(str(creature_count), "time of death", -1)
	file.set_value(str(creature_count), "DNA", DNA)
	file.save(REGISTRY_FOLDER_PATH + target_file_index + ".cfg")
	if parentID != "-1":
		var parent = get_creature(parentID)
		var parent_file = ConfigFile.new()
		parent_file.load(REGISTRY_FOLDER_PATH + str(int(parentID)/50) + ".cfg")
		parent_file.set_value(parentID, "children", parent[1] + [creature_count])
		parent_file.save(REGISTRY_FOLDER_PATH + str(int(parentID)/50) + ".cfg")
	creature_count += 1
	return str(creature_count - 1)

func log_creature_death(ID):
	var creature = get_creature(ID)
	creature[3] = GlobalSettings.global_time
	var file = ConfigFile.new()
	file.load(REGISTRY_FOLDER_PATH + str(int(ID)/50) + ".cfg")
	file.set_value(ID, "time of death", creature[3])

func get_image(creatureID: String):
	var paddingx = 1
	var paddingy = 1
	var edge_thickness = 1
	var edge_color = Color.WHITE
	var childrenIDs = get_creature(creatureID)[1]
	if len(childrenIDs) > 0:
		# Get all child icons recursively
		var images = []
		var sizex = 0
		var sizey = 0
		for childID in childrenIDs:
			images.append(get_image(str(childID)))
			if images[-1].get_height() > sizey:
				sizey = images[-1].get_height()
			sizex += images[-1].get_width()
		
		# Create image and selfie
		var selfie = generate_icon(get_creature(creatureID)[4], GlobalSettings.color_sheet)
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
	
	return generate_icon(get_creature(creatureID)[4], GlobalSettings.color_sheet)

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
	var parentID = get_creature(creatureID)[0]
	while parentID != '-1':
		creatureID = parentID
		parentID = get_creature(creatureID)[0]
	
	# Get all the creatureIDs and put them into a list
	var i = 0
	var list_of_creatureIDs = [creatureID]
	while i < len(list_of_creatureIDs):
		list_of_creatureIDs.append_array(get_creature(str(list_of_creatureIDs[i]))[1])
		i += 1
	
	# Convert that list into the dictionary we want
	var relative_lineage = {'-1':['-1', [], 0.0, -1.0, '', {}]}
	for ID in list_of_creatureIDs:
		relative_lineage[ID] = get_creature(str(ID))
	
	return relative_lineage
