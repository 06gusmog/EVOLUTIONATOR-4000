extends Timer


# Called when the node enters the scene tree for the first time.
func _ready():
	wait_time = 300 * GlobalSettings.simulation_speed
	start()
