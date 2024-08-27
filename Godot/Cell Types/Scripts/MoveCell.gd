extends Cell
var angle : float
var strength : int
var force : Vector2

@onready var sprite_2d_2 = $Sprite2D2

func _interpret_special_sauce(special_sauce):
	var sauce_values = get_from_sauce(special_sauce, ["angle", "weight"])
	angle = sauce_values[0]
	strength = sauce_values[1] * movement_tweak
	sprite_2d_2.rotation = angle - PI/2
	tags.append('Input')

func _act(input, delta):
	var direction = Vector2(cos(angle + get_parent().rotation), sin(angle + get_parent().rotation))
	get_parent().apply_impulse(direction * strength * input * delta, position.rotated(get_parent().rotation))
	sprite_2d_2.scale.y = strength * input / (movement_tweak * 9)
