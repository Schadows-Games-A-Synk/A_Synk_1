extends Node2D


@export var tileMap: TileMapLayer 
@export var offSet := Vector2(0,-6)
var StartMousPos: Vector2

var isMoving = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("MOUSE_BUTTON_LEFT"):
		StartMousPos = event.position
	if Input.is_action_just_released("MOUSE_BUTTON_LEFT") and (StartMousPos.distance_to(event.position)< 10):
			_move()


func _move():
	if isMoving: return
	
	var mousePosition = get_global_mouse_position()
	var isTargetPositionValid = get_tile_global_pos(mousePosition)
	
	if not isTargetPositionValid: return
	isMoving = true
	
	var movmentArray = _get_route(mousePosition)
	
	for movment in movmentArray:
		var playerTilePos = tileMap.local_to_map(global_position)
		var targetTilePos = playerTilePos + movment
		var targetPos = tileMap.map_to_local(targetTilePos) + offSet
		var tween := create_tween()
		tween.tween_property(get_parent(), "global_position",targetPos, 0.3)
		await tween.finished
	isMoving = false


func _get_route(targetPosition):
	var routeArray = []
	var direction = tileMap.local_to_map(targetPosition) - tileMap.local_to_map(global_position)
	var currTilePos = tileMap.local_to_map(global_position)
	
	while direction:
		var newPoint = snap(direction, 1)
		
		if newPoint.x and newPoint.y and newPoint.x == newPoint.y:
			var checkPoint = Vector2i(0, newPoint.y)
			
		if not _has_tile(currTilePos + newPoint):
			var points = [Vector2i(0,newPoint.y), Vector2i(newPoint.x, 0)]
			
			for point in points:
				if point == Vector2i.ZERO: continue
				_has_tile
				if _has_tile(currTilePos+point):
					newPoint=point 
		routeArray.append(newPoint)
		direction -= newPoint
		currTilePos += newPoint
	return routeArray

func snap(vec, step:int):
	if vec.x > 0: vec.x = 1
	elif vec.x < 0: vec.x = -1
	if vec.y > 0: vec.y = 1
	elif vec.y < 0: vec.y = -1
	
	return vec


func _has_tile(tilePos):
	var tileData = tileMap.get_cell_atlas_coords(tilePos)
	return tileData != Vector2i(-1,-1)


func get_tile_global_pos(mousePosition):
	var mouseTilePos := tileMap.local_to_map(mousePosition)
	var mouseTileDelta = tileMap.get_cell_atlas_coords(mouseTilePos)
	if mouseTileDelta == Vector2i(0,1):
		mouseTileDelta = Vector2i(-1,-1)
	#print(mouseTileDelta)
	if mouseTileDelta == Vector2i(-1,-1): return
	var tileGlobalPos = tileMap.map_to_local(mouseTilePos)
	return Vector2i(tileGlobalPos)
