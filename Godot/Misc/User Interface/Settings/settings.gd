extends HBoxContainer
# Simulation Speed
@onready var simulation_speed_slider: VSlider = $"simulation_speed/Simulation Speed Slider"
@onready var simulation_speed_value: Label = $simulation_speed/Value

# Saving
var root_dir = DirAccess.open("res://savefiles/")
@onready var reload_button = $"Saving/Reload Button"
@onready var file_menu = $"Saving/File Menu"
@onready var load_simulation = $"Saving/Load Simulation"

func reload_files():
	var list_of_folders = root_dir.get_directories()
	

func _ready() -> void:
	simulation_speed_slider.value = GlobalSettings.simulation_speed



func _on_simulation_speed_slider_drag_ended(value_changed: bool) -> void:
	GlobalSettings.simulation_speed = simulation_speed_slider.value
	GlobalSettings.set_simulation_speed(simulation_speed_slider.value)
	simulation_speed_value.text = str(simulation_speed_slider.value)
