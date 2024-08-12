extends Node2D

var from: Vector2
var to: Vector2
var sprite

func make_connection(from, to):
	if from == to:
		print('hello')
		var self_connection_sprite = load("res://Misc/UI assets/connection_to_self.png")
		print(self_connection_sprite)
		sprite = Sprite2D.new()
		print(sprite.texture)
		sprite.texture = self_connection_sprite
		print(sprite.texture)
		sprite.position = from
		sprite.scale = Vector2(0.01, 0.01)
		add_child(sprite)
	else:
		sprite = Line2D.new()
		add_child(sprite)
		sprite.points = [from, to]
		sprite.width = 0.5

func update_output(value):
	var hue = (value + 1) / 2
	sprite.modulate = Vector3(1,1,1) * hue
