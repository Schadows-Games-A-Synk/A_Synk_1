class_name GameSession
extends Node
## Verbindet Spiellogik und Szene. Haelt den aktuellen GameState, nimmt Zuege
## entgegen, prueft sie mit GameRules und meldet Aenderungen per Signal.
## Die Anzeige (Figuren, HUD) hoert nur auf diese Signale und veraendert den
## Spielstand nie selbst.
##
## Spaeter kommt hier der Austausch ueber Google Drive dazu: statt nur lokal
## werden Zuege dann auch aus der geteilten Datei gelesen bzw. hineingeschrieben.

signal game_started(state: GameState)
signal move_applied(move: Dictionary, state: GameState)
signal turn_started(player_index: int, state: GameState)
signal move_rejected(reason: String)

const GROUP := "game_session"

## Die Bodenebene, aus der die begehbaren Felder gelesen werden.
@export var terrain: TileMapLayer
@export var player_names: PackedStringArray = ["Spieler 1", "Spieler 2"]
@export var start_cells: Array[Vector2i] = [Vector2i(0, 1), Vector2i(2, 2)]
## Spielstand nach jedem Zug in user://savegame.json sichern und beim Start laden.
@export var autosave := true

const SAVE_PATH := "user://savegame.json"

var state: GameState
var map: HexMap


func _enter_tree() -> void:
	add_to_group(GROUP)


func _ready() -> void:
	map = HexMap.from_cells(terrain.get_used_cells() if terrain else [])
	# Erst starten, wenn alle Figuren/HUDs ihr _ready hinter sich haben.
	_start.call_deferred()


func _start() -> void:
	var loaded := load_game() if autosave else null
	if loaded:
		state = loaded
	else:
		new_game()
		return
	game_started.emit(state)
	turn_started.emit(state.current_player, state)


func new_game() -> void:
	state = GameState.new_game(player_names, start_cells, GameRules.STEPS_PER_TURN, scene_file_path_or_name())
	_save()
	game_started.emit(state)
	turn_started.emit(state.current_player, state)


## Versucht, den aktuellen Spieler auf das Feld zu bewegen.
func request_move_to(cell: Vector2i) -> bool:
	var move := GameRules.make_move_to(state, map, cell)
	if move.is_empty():
		move_rejected.emit("Feld nicht erreichbar")
		return false
	return submit(move)


func request_end_turn() -> bool:
	return submit(GameRules.make_end_turn(state))


## Einziger Weg, den Spielstand zu aendern.
func submit(move: Dictionary) -> bool:
	var err := GameRules.validate(state, map, move)
	if err != "":
		move_rejected.emit(err)
		return false
	var before_player := state.current_player
	GameRules.apply(state, move)
	_save()
	move_applied.emit(state.history[-1], state)
	if state.current_player != before_player:
		turn_started.emit(state.current_player, state)
	return true


func load_game() -> GameState:
	if not FileAccess.file_exists(SAVE_PATH):
		return null
	var s := GameState.from_json(FileAccess.get_file_as_string(SAVE_PATH))
	if s == null or s.players.size() != player_names.size():
		return null
	for p in s.players:
		if not map.is_walkable(p["pos"]):
			return null
	return s


func _save() -> void:
	if not autosave:
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(state.to_json())


func scene_file_path_or_name() -> String:
	var owner_scene := owner if owner else get_tree().current_scene
	return owner_scene.scene_file_path if owner_scene else ""
