extends Node2D
## Eingabe fuer die Spielwelt: Ziehen/Zoomen bewegt die Kamera, ein kurzer
## Klick/Tipp auf ein Feld wird als Zug-Wunsch an die GameSession geschickt.

@onready var Camera := %Camera2D
@onready var Session: GameSession = %GameSession
@onready var Hud := %TurnHud
var StartMousPos: Vector2


func _ready() -> void:
	Session.turn_started.connect(_on_turn_started)


func _input(event: InputEvent) -> void:
	if Hud.is_blocking():
		return
	if Input.is_action_just_pressed("MOUSE_BUTTON_LEFT") or event is InputEventScreenTouch:
		StartMousPos = event.position
	if Input.is_action_just_released("MOUSE_BUTTON_LEFT") and StartMousPos.distance_to(event.position) < 10:
		_on_tap(event.position)
	else:
		Camera.moveCamera(event)


func _on_tap(screen_pos: Vector2) -> void:
	if Glob.MouseOnUI or Hud.covers(screen_pos) or Glob.CurStatus == Glob.Status.Nothing or _any_unit_moving():
		return
	var world_pos := get_canvas_transform().affine_inverse() * screen_pos
	var cell: Vector2i = Session.terrain.local_to_map(Session.terrain.to_local(world_pos))
	Session.request_move_to(cell)


func _any_unit_moving() -> bool:
	for agent in get_tree().get_nodes_in_group("hex_agents"):
		if agent.isMoving:
			return true
	return false


func _on_turn_started(player_index: int, state: GameState) -> void:
	# Kamera auf die Figur des Spielers setzen, der jetzt dran ist.
	var cell: Vector2i = state.players[player_index]["pos"]
	Camera.position = Session.terrain.to_global(Session.terrain.map_to_local(cell))
