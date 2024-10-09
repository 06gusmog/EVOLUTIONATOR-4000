extends HBoxContainer
@onready var simulation_speed_slider: VSlider = $"simulation_speed/Simulation Speed Slider"
@onready var simulation_speed_value: Label = $simulation_speed/Value


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	simulation_speed_slider.value = GlobalSettings.simulation_speed



func _on_simulation_speed_slider_drag_ended(value_changed: bool) -> void:
	GlobalSettings.simulation_speed = simulation_speed_slider.value
	GlobalSettings.set_simulation_speed(simulation_speed_slider.value)
	simulation_speed_value.text = str(simulation_speed_slider.value)
