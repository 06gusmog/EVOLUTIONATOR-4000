extends Control

@onready var connection_monitor = $"VBoxContainer/TabContainer/Schematic View/Connection Monitor"
@onready var tab_container: TabContainer = $VBoxContainer/TabContainer
@onready var down: Button = $VBoxContainer/DOWN
@onready var creature_lineage_view: TextureRect = $"VBoxContainer/TabContainer/Lineage View/Creature Lineage View"


@onready var camera_2d = $"../../Camera2D"
@export var camera_move_speed = 5.0

@onready var world = $"../.."

func _ready():
	var blank_image = Image.create(10,10, false, Image.FORMAT_RGBA8)
	blank_image.save_png('res://Lineage Tracking/Icons/test.png')

func _process(_delta):
	camera_2d.position += Input.get_vector( 'left', 'right', 'up', 'down') * camera_move_speed * 1/camera_2d.zoom
	camera_2d.zoom -= Vector2(0.01, 0.01) * Input.get_axis("zoom_in", "zoom_out") * camera_2d.zoom
	
	if Input.is_action_just_pressed('Pause'):
		if get_tree().paused:
			print('Unpause')
			get_tree().paused = false
		else:
			print('Pause')
			get_tree().paused = true
	
	if Input.is_action_just_pressed('click'):
		var global_mouse_pos = get_global_mouse_position()
		#print(global_mouse_pos)
		#print(get_viewport_rect().size.y/2)
		if global_mouse_pos.y < get_viewport_rect().size.y/2:
			var local_mouse_pos = world.get_local_mouse_position()
			var clicked = false
			for creature in world.get_children():
				if not creature is RigidBody2D:
					continue
				#print(mouse_pos.distance_squared_to(creature.global_position))
				if local_mouse_pos.distance_squared_to(creature.global_position) <= creature.bounding_sphere_size*creature.bounding_sphere_size:
					creature_clicked(creature)
					clicked = true
					break
			if not clicked:
				background_clicked()
	
	if Input.is_action_just_pressed('test input'):
		#world.save_game_2()
		world.load_game_2("res://savefiles/savegame15-52.txt")
		#print('Saved!!')
	#progress_bar.value = creature_selected.energy



func background_clicked():
	creature_lineage_view.unload_lineage()
	
	connection_monitor.unload_creature()

func creature_clicked(creature):
	# Show the UI
	tab_container.visible = true
	down.text = "HIDE UI"
	
	# Set lineage view
	creature_lineage_view.load_lineage(creature)
	
	# Set schematic view
	connection_monitor.unload_creature()
	connection_monitor.load_creature(creature)

func load_creature(creature):
	pass
	#progress_bar.max_value = len(creature.cells) * GlobalSettings.energy_cap_PC


func _on_hide_ui_button_pressed() -> void:
	if tab_container.visible:
		tab_container.visible = false
		down.text = "SHOW UI"
	else:
		tab_container.visible = true
		down.text = "HIDE UI"
