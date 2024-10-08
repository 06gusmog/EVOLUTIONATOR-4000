extends Node
# Lineage tracking
#[parent, children, time of birth, time of death(-1.0 if alive), DNA]
var creature_tree = {"-1": ["-1", [], 0, -1, "", {  }]}

func log_creature_creation(parentID, DNA):
	creature_tree[str(len(creature_tree))] = [parentID, [], Time.get_ticks_msec(), -1.0, DNA]
	if parentID != '-1':
		creature_tree[parentID][1].append(str(len(creature_tree)-1))
	return str(len(creature_tree)-1)

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
