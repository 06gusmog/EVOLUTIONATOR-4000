extends SubViewport

@onready var monitor_root = $"Monitor Root"
@onready var cells_root = $"Monitor Root/Cells"
@onready var connections_root = $"Monitor Root/Connections"
@onready var camera = $"Monitor Root/Camera"
@onready var energy: ProgressBar = $"../Energy"
@onready var energy_consumption: Label = $"../Energy Consumption"

const WHITE_PIXEL = preload("res://Misc/visuals/1_white_pixel.png")

@export var resolution = 500

var active = false
var loaded_creature: Node

func _ready():
	camera.zoom = Vector2(resolution, resolution)

func load_creature(creature: Node):
	# Error handling, because why not
	if not is_instance_valid(creature):
		print('The creature is not loadable')
		return 0
	if active:
		print('Previous Creature Inproperly Unloaded! Please make sure Connection Monitor is properly cleared before loading new creatures.')
		return 0
	if cells_root.get_child_count() > 0 or connections_root.get_child_count() > 0:
		print('Previous Creature Inproperly Unloaded! Please make sure Connection Monitor is properly cleared before loading new creatures.')
		return 0
	
	active = true
	loaded_creature = creature
	
	energy.max_value = loaded_creature.per_frame_energy_consumption * GlobalSettings.energy_cap
	
	creature.cell_death.connect(self._on_creature_cell_death)
	creature.death.connect(self._on_creature_death)
	
	creature.get_child(0).get_child(0).visible = true
	
	for cellID in loaded_creature.cells:
		
		var cell = loaded_creature.cells[cellID]
		# Adding all the cells
		var sprite = Sprite2D.new()
		sprite.texture = WHITE_PIXEL
		sprite.modulate = GlobalSettings.color_sheet[cell.type]
		sprite.position = cell.position
		sprite.name = cellID
		cells_root.add_child(sprite)
		
		# Creating roots for connections (Needs to be done before adding any connections)
		if 'Output' in cell.tags:
			var connection_root = Node2D.new()
			connection_root.name = cell.cellID
			connections_root.add_child(connection_root)
			
			sprite = Sprite2D.new()
			sprite.name = 'Output Indicator'
			sprite.texture = WHITE_PIXEL
			sprite.modulate = GlobalSettings.color_sheet[cell.type]
			sprite.modulate.a = 1
			sprite.position = cell.position
			sprite.scale = Vector2(0.5,0.5)
			connection_root.add_child(sprite)
			
	# Adding all the connections
	for cellID in loaded_creature.cells:
		
		var cell = loaded_creature.cells[cellID]
		if 'Input' in cell.tags:
			for connection in cell.connections:
				if connection in loaded_creature.killing_queue_ID:
					continue
				var connecting_cell = loaded_creature.get_node(connection)
				if 'Output' in connecting_cell.tags:
					# Use polygon 2d with 2 points per border, then thin them when distinction is necessary. (future project)
					var line = Line2D.new()
					line.name = cell.cellID
					line.points = [cell.position, connecting_cell.position]
					line.width = 0.2
					var output_connection = connections_root.get_node(connecting_cell.cellID)
					output_connection.add_child(line)
	size = Vector2i(1,1) * creature.bounding_sphere_size * 3 * resolution

func unload_creature():
	if active:
		loaded_creature.get_child(0).get_child(0).visible = false
		loaded_creature.cell_death.disconnect(_on_creature_cell_death)
		loaded_creature.death.disconnect(_on_creature_death)
		energy.value = 0
		energy_consumption.text = "Consumption: 0"
	for child in cells_root.get_children():
		child.free()
	for child in connections_root.get_children():
		child.free()
	active = false

func _on_creature_cell_death(cellID:String):
	for output_cell in connections_root.get_children():
		for connection in output_cell.get_children():
			if connection.name == cellID:
				connection.free()
		if output_cell.name == cellID:
			output_cell.free()
	for output_cell in cells_root.get_children():
		if output_cell.name == cellID:
			output_cell.free()
			break

func _on_creature_death():
	unload_creature()

func _process(delta):
	if active == false:
		return 0
	
	energy.value = loaded_creature.energy
	energy_consumption.text = "Consumption:" + str(round(loaded_creature.per_frame_energy_consumption * 100) / 100)
	
	for output_node in connections_root.get_children():
		var do_I_skip_this_cell = false
		for cell_to_be_killed in loaded_creature.killing_queue:
			if cell_to_be_killed.cellID == output_node.name:
				do_I_skip_this_cell = true
		if do_I_skip_this_cell:
			continue
		
		var value = loaded_creature.cells[output_node.name].output
		var value_color = Color.WHITE * ((value+1)/2)
		value_color.a = abs(value)
		for connection in output_node.get_children():
			connection.modulate = value_color
