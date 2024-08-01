extends Node2D
@onready var camera_2d = $Camera2D
@export var camera_move_speed = 5.0

var template = load("res://Misc/creature.tscn")

var creatures = [
	[
		{'Type':'test_cell', 'Position':Vector2(1,0), 'Connections':[], 'Special Sauce':'1234'},
		{'Type':'test_cell', 'Position':Vector2(1,1), 'Connections':[], 'Special Sauce':'1234'},
		{'Type':'test_cell', 'Position':Vector2(1,2), 'Connections':[], 'Special Sauce':'1234'},
		{'Type':'test_cell', 'Position':Vector2(1,3), 'Connections':[], 'Special Sauce':'1234'},
		{'Type':'test_cell', 'Position':Vector2(1,4), 'Connections':[], 'Special Sauce':'1234'}
	],
	[
		{'Type':'eye_cell', 'Position':Vector2(1,0), 'Connections':[], 'Special Sauce':'009'},
		{'Type':'move_cell', 'Position':Vector2(1,1), 'Connections':['0'], 'Special Sauce':'1234'},
		{'Type':'move_cell', 'Position':Vector2(1,1), 'Connections':['3'], 'Special Sauce':'005'},
		{'Type':'neuron_cell', 'Position':Vector2(1,1), 'Connections':[], 'Special Sauce':'0051'}
	]
]

# Called when the node enters the scene tree for the first time.
func _ready():
	var i = 0
	for creature in creatures:
		var dudebro = template.instantiate()
		dudebro.DNA = creature
		dudebro.position += Vector2(i*20, 0)
		add_child(dudebro)
		i += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	camera_2d.position += Input.get_vector( 'left', 'right', 'up', 'down') * camera_move_speed * 1/camera_2d.zoom
	camera_2d.zoom -= Vector2(0.01, 0.01) * Input.get_axis("zoom_in", "zoom_out") * camera_2d.zoom
