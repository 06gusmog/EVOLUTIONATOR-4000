extends HBoxContainer

# 1 thing left: Saving timer. Make it check the string so it updates.
# And adjust timer to simulation speed when it changes.

@onready var world: Node2D = $"../../../../.."

# Simulation Speed
@onready var simulation_speed_slider: VSlider = $"simulation_speed/Simulation Speed Slider"
@onready var simulation_speed_value: Label = $simulation_speed/Value

var root_dir = DirAccess.open("res://savefiles/")

# Loading
@onready var reload_button: Button = $"Loading/Reload Button"
@onready var loading_folder_menu: MenuButton = $"Loading/HBoxContainer/Folder Menu"
@onready var file_menu: MenuButton = $"Loading/HBoxContainer/File Menu"
@onready var folder: Label = $"Loading/selected File/Folder"
@onready var file: Label = $"Loading/selected File/File"
@onready var load_simulation: Button = $"Loading/Load Simulation"

# Saving
@onready var saving_folder_menu: MenuButton = $"Saving/Folder Menu"
@onready var selected_folder: Label = $"Saving/Selected Folder"
@onready var new_folder: Button = $"Saving/New Folder"
@onready var folder_name: LineEdit = $"Saving/Folder Name"
@onready var save: Button = $Saving/Save
@onready var check_button: CheckButton = $Saving/CheckButton
@onready var autosave_time: LineEdit = $"Saving/Autosave Time"
@onready var autosave_timer: Timer = $"../../../../../Autosave Timer"
@onready var time_until_autosave: Label = $"Saving/Autosave Time/Time Until Autosave"

func _ready() -> void:
	simulation_speed_slider.value = GlobalSettings.simulation_speed
	var popup_menu = saving_folder_menu.get_popup()
	popup_menu.index_pressed.connect(_on_saving_folder_menu_button_popup_select)
	popup_menu = loading_folder_menu.get_popup()
	popup_menu.index_pressed.connect(_on_folder_menu_button_popup_select)
	popup_menu = file_menu.get_popup()
	popup_menu.index_pressed.connect(_on_file_menu_button_popup_select)

func _process(delta: float) -> void:
	time_until_autosave.text = 'Time Left: ' + str(int(autosave_timer.time_left / GlobalSettings.simulation_speed))

func _on_simulation_speed_slider_drag_ended(value_changed: bool) -> void:
	GlobalSettings.simulation_speed = simulation_speed_slider.value
	GlobalSettings.set_simulation_speed(simulation_speed_slider.value)
	simulation_speed_value.text = str(simulation_speed_slider.value)

func set_popup(menu_button, options):
	var popup = menu_button.get_popup()
	popup.clear()
	for item in options:
		popup.add_item(item)

func _on_reload_button_button_down() -> void:
	var directories = root_dir.get_directories()
	set_popup(loading_folder_menu, directories)
	set_popup(saving_folder_menu, directories)
	folder.text = ''
	file.text = ''
	selected_folder.text = ''

func _on_folder_menu_button_popup_select(index):
	var files = root_dir.get_directories_at('res://savefiles/' + loading_folder_menu.get_popup().get_item_text(index))
	print(files)
	set_popup(file_menu, files)
	folder.text = loading_folder_menu.get_popup().get_item_text(index)
	file.text = ''

func _on_file_menu_button_popup_select(index):
	file.text = file_menu.get_popup().get_item_text(index)

func _on_load_simulation_button_down() -> void:
	if folder.text != '' and file.text != '':
		world.load_game_2("res://savefiles/" + folder.text + '/' + file.text)

func _on_new_folder_button_down() -> void:
	if folder_name.text != '':
		if folder_name.text in root_dir.get_directories():
			print('Folder already exists')
			return
		root_dir.make_dir(folder_name.text)

func _on_saving_folder_menu_button_popup_select(index):
	GlobalSettings.save_path = 'res://savefiles/' + saving_folder_menu.get_popup().get_item_text(index) + '/'
	selected_folder.text = saving_folder_menu.get_popup().get_item_text(index)

func _on_save_button_down() -> void:
	if selected_folder.text != '':
		world.save_game_2()

func _on_autosave_time_text_changed(new_text: String) -> void:
	if new_text.is_valid_int():
		if int(new_text) > 0:
			GlobalSettings.time_between_saves = int(new_text) * 60
			autosave_timer.wait_time = GlobalSettings.time_between_saves * GlobalSettings.simulation_speed

func _on_check_button_button_down() -> void:
	if check_button.button_pressed:
		autosave_timer.stop()
		print('stop')
	else:
		autosave_timer.start()
		print('start')


func _on_autosave_timer_timeout() -> void:
	world.save_game_2()
