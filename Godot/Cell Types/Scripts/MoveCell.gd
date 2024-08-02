extends Cell
var angle : float
var strength : int
var force : Vector2

@onready var sprite_2d_2 = $Sprite2D2

func _interpret_special_sauce(special_sauce):
	var sauce_values = get_from_sauce(special_sauce, ["angle", "weight"])
	angle = sauce_values[0]
	strength = sauce_values[1] * movement_tweak
	force = Vector2(cos(angle), sin(angle)) * strength
	sprite_2d_2.rotation = angle - PI/2

func _act(input, delta):
	get_parent().apply_impulse(input * force * delta, position)
	sprite_2d_2.scale.y = strength * input / (movement_tweak * 9)
