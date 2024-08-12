extends Node2D

var from: Vector2
var to: Vector2
var sprite

func make_connection(from, to):
	if from == to:
		var self_connection_sprite = load("res://Misc/UI assets/connection_to_self.png")
		sprite = Sprite2D.new()
		sprite.texture = self_connection_sprite
		sprite.position = from
		sprite.scale = Vector2(0.01, 0.01)
		add_child(sprite)
	else:
		sprite = Line2D.new()
		add_child(sprite)
		sprite.points = [from, to]
		sprite.width = 0.2

func update_output(value):
	var hue = (value + 1) / 2
	sprite.modulate = Color(hue,hue,hue)
