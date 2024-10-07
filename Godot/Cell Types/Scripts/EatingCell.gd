extends Cell

func _interpret_special_sauce(_special_sauce):
	tags.append('Eats')
	tags.append('Inedible')
	energy_consumption = GlobalSettings.cell_type_energy_consumption['eating_cell.tscn']
