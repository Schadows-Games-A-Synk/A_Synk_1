class_name GameRules
extends RefCounted
## Die Spielregeln. Ein Zug ("move") ist ein einfaches Dictionary, das sich
## direkt als JSON speichern und verschicken laesst:
##
##   {"type": "move",     "player": 0, "round": 1, "path": [[x, y], ...]}
##   {"type": "end_turn", "player": 0, "round": 1}
##
## validate() prueft einen Zug gegen einen Spielstand, apply() fuehrt ihn aus.
## Wer denselben Startstand hat und dieselben Zuege anwendet, landet immer beim
## selben Ergebnis. Darauf baut spaeter der asynchrone Austausch auf.

const STEPS_PER_TURN := 4

const TYPE_MOVE := "move"
const TYPE_END_TURN := "end_turn"


## Baut einen Bewegungszug fuer den aktuellen Spieler zum Zielfeld.
## Liefert {} wenn das Ziel nicht (mit den restlichen Schritten) erreichbar ist.
static func make_move_to(state: GameState, map: HexMap, target: Vector2i) -> Dictionary:
	var me := state.current()
	var path := map.find_path(me["pos"], target, state.occupied_cells(state.current_player), me["steps_left"])
	if path.is_empty() or path.size() > me["steps_left"]:
		return {}
	var p := []
	for c in path:
		p.append([c.x, c.y])
	return {"type": TYPE_MOVE, "player": state.current_player, "round": state.round_number, "path": p}


static func make_end_turn(state: GameState) -> Dictionary:
	return {"type": TYPE_END_TURN, "player": state.current_player, "round": state.round_number}


## Gibt "" zurueck, wenn der Zug erlaubt ist, sonst eine Fehlermeldung.
static func validate(state: GameState, map: HexMap, move: Dictionary) -> String:
	var player := int(move.get("player", -1))
	if player != state.current_player:
		return "Spieler %d ist nicht am Zug" % (player + 1)
	if int(move.get("round", -1)) != state.round_number:
		return "Zug gehoert zu Runde %s, aktuell ist Runde %d" % [move.get("round"), state.round_number]
	match move.get("type"):
		TYPE_END_TURN:
			return ""
		TYPE_MOVE:
			var path: Array = move.get("path", [])
			if path.is_empty():
				return "Leerer Weg"
			var me := state.players[player]
			if path.size() > me["steps_left"]:
				return "Nicht genug Schritte (%d uebrig)" % me["steps_left"]
			var blocked := state.occupied_cells(player)
			var prev: Vector2i = me["pos"]
			for raw in path:
				var c := _cell(raw)
				if not map.are_neighbors(prev, c):
					return "Weg springt von %s nach %s" % [prev, c]
				if not map.is_walkable(c):
					return "Feld %s ist nicht begehbar" % c
				if blocked.has(c):
					return "Feld %s ist besetzt" % c
				prev = c
			return ""
		_:
			return "Unbekannter Zugtyp %s" % move.get("type")


## Fuehrt einen (vorher validierten) Zug auf dem Spielstand aus.
static func apply(state: GameState, move: Dictionary) -> void:
	var m := normalize_move(move)
	match m["type"]:
		TYPE_MOVE:
			var me := state.players[m["player"]]
			me["pos"] = _cell(m["path"][-1])
			me["steps_left"] -= m["path"].size()
		TYPE_END_TURN:
			state.players[state.current_player]["steps_left"] = 0
			state.current_player = (state.current_player + 1) % state.players.size()
			if state.current_player == 0:
				state.round_number += 1
			state.players[state.current_player]["steps_left"] = STEPS_PER_TURN
	state.history.append(m)


## Spielt eine Liste von Zuegen auf einem Startstand nach. Bricht beim ersten
## ungueltigen Zug ab und gibt dann dessen Fehler zurueck.
static func replay(state: GameState, map: HexMap, moves: Array) -> String:
	for m in moves:
		var err := validate(state, map, m)
		if err != "":
			return err
		apply(state, m)
	return ""


## Bringt einen Zug in eine einheitliche Form (JSON liefert Zahlen als float).
static func normalize_move(move: Dictionary) -> Dictionary:
	var m := {
		"type": str(move.get("type", "")),
		"player": int(move.get("player", -1)),
		"round": int(move.get("round", -1)),
	}
	if move.has("path"):
		var p := []
		for raw in move["path"]:
			var c := _cell(raw)
			p.append([c.x, c.y])
		m["path"] = p
	return m


static func path_cells(move: Dictionary) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for raw in move.get("path", []):
		cells.append(_cell(raw))
	return cells


static func _cell(raw) -> Vector2i:
	if raw is Vector2i:
		return raw
	return Vector2i(int(raw[0]), int(raw[1]))
