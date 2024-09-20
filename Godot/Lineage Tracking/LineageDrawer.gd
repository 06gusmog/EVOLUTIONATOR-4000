extends Node2D

@export var padding_vertical = 100
@export var padding_horizontal = 100
@export var border_vertical = 0
@export var border_horizontal = 0

@onready var camera_2d = $IGNORE/Camera2D

func add_node(position, creatureID, creature_register):
	var node = load("res://Lineage Tracking/node_start.tscn").instantiate()
	print_rich(creature_register[creatureID]['image'])
	print(node.get_child(0))
	node.position = position
	node.creatureID = creatureID
	add_child(node)
	var img = load(creature_register[creatureID]['image'])
	node.get_child(0).set_texture(img)
	return node

func add_line(node, to, is_mitosis_connection = false):
	var line = Line2D.new()
	line.points = [Vector2(0,0), to]
	if is_mitosis_connection:
		line.name = 'line'
	node.add_child(line)

func draw_specific_lineage(creatureID, event_register, creature_register):
	while true:
		var creature_item = creature_register[creatureID]
		if creature_item['Parent'] == -1:
			break
		creatureID = creature_item['Parent']
	
	var death_events = []
	var event_indices = [creatureID]
	var i = 0
	while i < len(event_indices):
		var creature_item = creature_register[event_indices[i]]
		event_indices.append_array(creature_item['Offspring'])
		if creature_item['Dead'] == false:
			death_events.append(creature_item['Death Event'])
		i += 1
	
	var events = []
	event_indices.append_array(death_events)
	event_indices.sort()
	for event_index in event_indices:
		events.append(event_register[event_index])
	
	draw_lineage(events, creature_register)

func draw_lineage(event_register, creature_register):
	for child in get_children():
		#print('hello')
		if child.name == 'IGNORE':
			continue
		child.queue_free()
	
	#NOTE Always split up
	var node_list = []
	var cursor = [] #NOTE Currently empty is -1, currently line is ID
	var x = 0
	#print(event_register)
	for event in event_register:
		#print(event['Type'])
		match event['Type']:
			'Creation':
				#print('creation')
				for node in node_list:
					node.position.y += padding_vertical
				cursor.insert(0, event['CreatureID'])
				node_list.append(add_node(Vector2(x * padding_horizontal, 0), event['CreatureID'], creature_register))
			'Mitosis':
				#print('mitosis')
				var parent_index = cursor.find(event['Parent CreatureID'])
				if parent_index+1 == len(cursor):
					cursor.append(event['Offspring CreatureID'])
					node_list.append(add_node(Vector2(x * padding_horizontal, (parent_index+1) * padding_vertical), event['Offspring CreatureID'], creature_register))
				elif cursor[parent_index+1] == -1:
					cursor[parent_index+1] = event['Offspring CreatureID']
					node_list.append(add_node(Vector2(x * padding_horizontal, (parent_index+1) * padding_vertical), event['Offspring CreatureID'], creature_register))
				else:
					for node in node_list:
						if node.position.y >= (parent_index+1) * padding_vertical:
							node.position.y += padding_vertical
							for child in node.get_children():
								if child.name == 'line':
									if child.points[1].y + node.position.y <= (parent_index+1) * padding_vertical:
										child.points[1].y -= padding_vertical
					cursor.insert(parent_index+1, event['Offspring CreatureID'])
					node_list.append(add_node(Vector2(x * padding_horizontal, (parent_index+1) * padding_vertical), event['Offspring CreatureID'], creature_register))
				add_line(node_list[-1], Vector2(0, -padding_vertical), true)
			'Death':
				#print('Death')
				var index = cursor.find(event['CreatureID'])
				cursor[index] = -1
				for node in node_list:
					if node.creatureID == event['CreatureID']:
						add_line(node, Vector2((x*padding_horizontal) - node.position.x, 0))
						var ded_sprite = Sprite2D.new()
						ded_sprite.texture = load("res://Lineage Tracking/AUUOOGH_I_am_ded.png")
						ded_sprite.position = Vector2((x*padding_horizontal) - node.position.x, 0)
						node.add_child(ded_sprite)
						break
		x += 1
	x -= 1
	#print('hello3')
	var index = -1
	for row in cursor:
		
		index += 1
		if row == -1:
			continue
		for node in node_list:
			if node.creatureID == row:
				add_line(node, Vector2((x*padding_horizontal) - node.position.x, 0))
				break
	
	#NOTE Ignore the thing under here, it's witchcraft
	camera_2d.position = Vector2(float(len(event_register)) * padding_horizontal/2, float(len(cursor)) * padding_vertical/2)
	camera_2d.zoom = Vector2(1,1) * min(float(camera_2d.get_viewport().size.x) / ((len(event_register)+border_horizontal) * padding_horizontal), float(camera_2d.get_viewport().size.y) / ((len(cursor)+border_vertical) * padding_vertical))
