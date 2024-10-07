extends Cell

func _interpret_special_sauce(_special_sauce):
	tags.append('Inedible')
	energy_consumption = GlobalSettings.cell_type_energy_consumption['armor_cell.tscn']
