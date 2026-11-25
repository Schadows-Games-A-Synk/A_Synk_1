extends SceneTree
## Tests fuer die reine Spiellogik (ohne Grafik). Ausfuehren mit:
##   godot --headless --path asynk-rpg -s res://tests/test_rules.gd
## Beendet sich mit Code 0, wenn alles passt, sonst 1.

var _failures := 0
var _checks := 0


func _init() -> void:
	test_pathfinding()
	test_move_and_turn_order()
	test_invalid_moves()
	test_serialization_and_replay()
	print("%d Checks, %d Fehler" % [_checks, _failures])
	quit(1 if _failures > 0 else 0)


func check(cond: bool, what: String) -> void:
	_checks += 1
	if not cond:
		_failures += 1
		printerr("FEHLER: ", what)


## Kleine Karte: Rechteck 0..5 x 0..5 ohne das Feld (2,2).
func small_map() -> HexMap:
	var cells := []
	for x in 6:
		for y in 6:
			if Vector2i(x, y) != Vector2i(2, 2):
				cells.append(Vector2i(x, y))
	return HexMap.from_cells(cells)


func new_state() -> GameState:
	return GameState.new_game(["A", "B"], [Vector2i(0, 0), Vector2i(5, 5)], GameRules.STEPS_PER_TURN, "test")


func test_pathfinding() -> void:
	var m := small_map()
	var p := m.find_path(Vector2i(0, 0), Vector2i(3, 3))
	check(p.size() == 3 or p.size() == 4, "Weg (0,0)->(3,3) hat sinnvolle Laenge: %s" % [p])
	check(not p.has(Vector2i(2, 2)), "Weg meidet Loch (2,2)")
	check(p[-1] == Vector2i(3, 3), "Weg endet am Ziel")
	var prev := Vector2i(0, 0)
	for c in p:
		check(m.are_neighbors(prev, c), "Schritte sind Nachbarn")
		prev = c
	check(m.find_path(Vector2i(0, 0), Vector2i(9, 9)).is_empty(), "Kein Weg ausserhalb der Karte")
	check(m.find_path(Vector2i(0, 0), Vector2i(1, 0), [Vector2i(1, 0)]).is_empty(), "Besetztes Ziel nicht erreichbar")
	check(m.find_path(Vector2i(0, 0), Vector2i(5, 5), [], 2).is_empty(), "max_steps begrenzt die Suche")


func test_move_and_turn_order() -> void:
	var m := small_map()
	var s := new_state()
	check(s.current_player == 0 and s.current()["steps_left"] == 4, "A beginnt mit 4 Schritten")
	var mv := GameRules.make_move_to(s, m, Vector2i(2, 0))
	check(not mv.is_empty(), "A kann 2 Felder weit gehen")
	check(GameRules.validate(s, m, mv) == "", "Zug ist gueltig")
	GameRules.apply(s, mv)
	check(s.players[0]["pos"] == Vector2i(2, 0), "A steht auf (2,0)")
	check(s.players[0]["steps_left"] == 2, "A hat noch 2 Schritte")
	check(GameRules.make_move_to(s, m, Vector2i(5, 0)).is_empty(), "3 Felder geht nicht mehr")
	GameRules.apply(s, GameRules.make_end_turn(s))
	check(s.current_player == 1 and s.round_number == 1, "B ist dran, noch Runde 1")
	check(s.players[1]["steps_left"] == 4 and s.players[0]["steps_left"] == 0, "Schritte wurden weitergegeben")
	GameRules.apply(s, GameRules.make_end_turn(s))
	check(s.current_player == 0 and s.round_number == 2, "Wieder A, Runde 2")
	check(s.history.size() == 3, "3 Zuege im Verlauf")


func test_invalid_moves() -> void:
	var m := small_map()
	var s := new_state()
	var wrong_player := {"type": "end_turn", "player": 1, "round": 1}
	check(GameRules.validate(s, m, wrong_player) != "", "B darf nicht ziehen, wenn A dran ist")
	var jump := {"type": "move", "player": 0, "round": 1, "path": [[3, 0]]}
	check(GameRules.validate(s, m, jump) != "", "Springen ist verboten")
	var hole := {"type": "move", "player": 0, "round": 1, "path": [[1, 1], [2, 2]]}
	check(GameRules.validate(s, m, hole) != "", "Loch ist nicht begehbar")
	var too_far := {"type": "move", "player": 0, "round": 1, "path": [[1, 0], [2, 0], [3, 0], [4, 0], [5, 0]]}
	check(GameRules.validate(s, m, too_far) != "", "Mehr als 4 Schritte verboten")
	var old_round := {"type": "end_turn", "player": 0, "round": 7}
	check(GameRules.validate(s, m, old_round) != "", "Zug aus falscher Runde verboten")
	s.players[1]["pos"] = Vector2i(1, 0)
	var onto := {"type": "move", "player": 0, "round": 1, "path": [[1, 0]]}
	check(GameRules.validate(s, m, onto) != "", "Feld mit Figur ist besetzt")


func test_serialization_and_replay() -> void:
	var m := small_map()
	var s := new_state()
	var start_json := s.to_json()
	GameRules.apply(s, GameRules.make_move_to(s, m, Vector2i(1, 1)))
	GameRules.apply(s, GameRules.make_end_turn(s))
	GameRules.apply(s, GameRules.make_move_to(s, m, Vector2i(4, 4)))

	# Rundreise durch JSON-Text, wie spaeter ueber eine Drive-Datei.
	var text := s.to_json()
	var back := GameState.from_json(text)
	check(back != null, "JSON laesst sich wieder einlesen")
	check(back.to_dict() == s.to_dict(), "Spielstand ueberlebt JSON unveraendert")
	check(back.players[1]["pos"] == Vector2i(4, 4), "Position korrekt gelesen")

	# Nur die Zugliste verschicken und auf dem Startstand nachspielen.
	var moves = JSON.parse_string(JSON.stringify(s.history))
	var replayed := GameState.from_json(start_json)
	check(GameRules.replay(replayed, m, moves) == "", "Zuege lassen sich nachspielen")
	check(replayed.to_dict() == s.to_dict(), "Nachgespielter Stand ist identisch")
	check(GameRules.replay(GameState.from_json(start_json), m, [moves[2]]) != "", "Zug in falscher Reihenfolge wird abgelehnt")
