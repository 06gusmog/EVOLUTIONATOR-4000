extends TextureRect

#var white_png = ImageTexture.create_from_image(load("res://Misc/visuals/1_white_pixel.png"))
var white_png = load("res://Misc/visuals/1_white_pixel.png")

func _ready():
	
	print(load("res://Misc/visuals/1_white_pixel.png"))

func load_lineage(creature):
	var relative_lineage = LineageLogger.get_relative_lineage(creature.creatureID)
	var image = LineageLogger.get_image(relative_lineage.keys()[1])
	texture = ImageTexture.create_from_image(image)
	
	#image.save_png('res://Misc/User Interface/Schematic View/Current Lineage.png')
	#print_rich('[img]res://Misc/User Interface/Schematic View/Current Lineage.png[/img]')

func unload_lineage():
	texture = white_png
