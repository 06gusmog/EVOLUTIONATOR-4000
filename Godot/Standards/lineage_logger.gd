extends Node
# Lineage tracking
#[parent, children, time of birth, time of death(-1.0 if alive), ICON, DNA]
var creature_tree = {'-1':['-1', [], 0.0, -1.0, '', {}]} # Starting with the root creature

func log_creature_creation(parentID, DNA):
	var icon_location = generate_icon(DNA, GlobalSettings.color_sheet)
	creature_tree[str(len(creature_tree))] = [parentID, [], Time.get_ticks_msec(), -1.0, icon_location, DNA]
	if parentID != '-1':
		creature_tree[parentID][1].append(str(len(creature_tree)-1))
	return str(len(creature_tree)-1)

func log_creature_death(creatureID):
	creature_tree[creatureID][3] = Time.get_ticks_msec()

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
	for RNA in DNA:
		icon.set_pixel(RNA['Position'].x - lowest_positions.x, RNA['Position'].y - lowest_positions.y, color_sheet[RNA['Type']])
	
	icon.save_png('res://Lineage Tracking/Icons/' + str(len(creature_tree)) + '.png')
	return 'res://Lineage Tracking/Icons/' + str(len(creature_tree)) + '.png'

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
	
	# Convert that list into the dictionary we want
	var relative_lineage = {'-1':['-1', [], 0.0, -1.0, '', {}]}
	for ID in list_of_creatureIDs:
		relative_lineage[ID] = creature_tree[ID]
	
	return relative_lineage
