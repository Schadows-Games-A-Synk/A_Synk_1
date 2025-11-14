extends TileMapLayer

@onready var tmOverworld = %TileMapLayer

func _input(event: InputEvent) -> void:
	var pos = event.position
	
	var tile_pos: Vector2i = tmOverworld.local_to_map(get_global_mouse_position())
	
	var atlas_pos: Vector2i = tmOverworld.get_cell_atlas_coords(tile_pos)
	if event.is_pressed():
		print("*******")
		print( tile_pos)
		print(atlas_pos)
		print(tmOverworld.get_surrounding_cells(tile_pos) )
		#print(tmOverworld.get_cell_tile_data(tile_pos)ss)
		print("*******")
