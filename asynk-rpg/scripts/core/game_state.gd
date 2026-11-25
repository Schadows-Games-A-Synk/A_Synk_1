class_name GameState
extends RefCounted
## Der komplette Spielstand als reine Daten. Alles hier laesst sich mit
## to_dict()/from_dict() in JSON umwandeln, damit der Stand spaeter in einer
## (Google-Drive-)Datei zwischen den Spielern hin und her gehen kann.

const FORMAT_VERSION := 1

var map_id: String = ""
## Laufende Runde, beginnt bei 1. Eine Runde ist vorbei, wenn alle einmal dran waren.
var round_number: int = 1
## Index in players, wer gerade am Zug ist.
var current_player: int = 0
## Jeder Spieler: {"id": String, "name": String, "pos": Vector2i, "steps_left": int}
var players: Array[Dictionary] = []
## Alle bisher ausgefuehrten Zuege, in Reihenfolge (siehe GameRules fuer das Format).
var history: Array[Dictionary] = []


static func new_game(names: Array, start_cells: Array, steps_per_turn: int, p_map_id: String = "") -> GameState:
	assert(names.size() == start_cells.size())
	var s := GameState.new()
	s.map_id = p_map_id
	for i in names.size():
		s.players.append({
			"id": "p%d" % (i + 1),
			"name": str(names[i]),
			"pos": start_cells[i],
			"steps_left": steps_per_turn if i == 0 else 0,
		})
	return s


func current() -> Dictionary:
	return players[current_player]


func occupied_cells(except_player: int = -1) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for i in players.size():
		if i != except_player:
			cells.append(players[i]["pos"])
	return cells


func duplicate_state() -> GameState:
	return GameState.from_dict(to_dict())


func to_dict() -> Dictionary:
	var ps := []
	for p in players:
		ps.append({
			"id": p["id"],
			"name": p["name"],
			"pos": [p["pos"].x, p["pos"].y],
			"steps_left": p["steps_left"],
		})
	return {
		"version": FORMAT_VERSION,
		"map_id": map_id,
		"round": round_number,
		"current_player": current_player,
		"players": ps,
		"history": history.duplicate(true),
	}


static func from_dict(d: Dictionary) -> GameState:
	var s := GameState.new()
	s.map_id = str(d.get("map_id", ""))
	s.round_number = int(d.get("round", 1))
	s.current_player = int(d.get("current_player", 0))
	for p in d.get("players", []):
		s.players.append({
			"id": str(p["id"]),
			"name": str(p["name"]),
			"pos": Vector2i(int(p["pos"][0]), int(p["pos"][1])),
			"steps_left": int(p["steps_left"]),
		})
	for m in d.get("history", []):
		s.history.append(GameRules.normalize_move(m))
	return s


func to_json() -> String:
	return JSON.stringify(to_dict(), "\t")


static func from_json(text: String) -> GameState:
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return null
	return from_dict(parsed)
