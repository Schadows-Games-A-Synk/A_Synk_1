extends Node2D
## Anzeige einer Spielfigur. Bewegt sich nur, wenn die GameSession einen Zug
## dieses Spielers meldet, und entscheidet selbst nichts.

@export var tileMap: TileMapLayer
@export var offSet := Vector2(0, -6)
## Welcher Spieler (Index im GameState) diese Figur ist.
@export var player_index := 0
@export var step_time := 0.3
## Farbe des Rings unter der Figur, damit man die Spieler unterscheiden kann.
@export var marker_color := Color(0.25, 0.55, 1.0, 0.85)
@export var marker_offset := Vector2(6, 16)

var isMoving := false
var _queue: Array = []


func _ready() -> void:
	add_to_group("hex_agents")
	var session := get_tree().get_first_node_in_group(GameSession.GROUP) as GameSession
	if session == null:
		push_warning("HexAgent: keine GameSession in der Szene")
		return
	session.game_started.connect(_on_game_started)
	session.move_applied.connect(_on_move_applied)


func _draw() -> void:
	draw_set_transform(marker_offset, 0, Vector2(1, 0.45))
	draw_circle(Vector2.ZERO, 28, marker_color)
	draw_arc(Vector2.ZERO, 28, 0, TAU, 32, marker_color.darkened(0.4), 4)
	draw_set_transform(Vector2.ZERO)


func cell_to_position(cell: Vector2i) -> Vector2:
	return tileMap.to_global(tileMap.map_to_local(cell)) + offSet


func _on_game_started(state: GameState) -> void:
	if player_index >= state.players.size():
		get_parent().visible = false
		return
	_queue.clear()
	get_parent().global_position = cell_to_position(state.players[player_index]["pos"])


func _on_move_applied(move: Dictionary, _state: GameState) -> void:
	if move["type"] != GameRules.TYPE_MOVE or move["player"] != player_index:
		return
	_queue.append(GameRules.path_cells(move))
	if not isMoving:
		_animate()


func _animate() -> void:
	isMoving = true
	while not _queue.is_empty():
		for cell in _queue.pop_front():
			var tween := create_tween()
			tween.tween_property(get_parent(), "global_position", cell_to_position(cell), step_time)
			await tween.finished
	isMoving = false
