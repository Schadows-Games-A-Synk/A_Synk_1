extends Node
## Integrationstest: laedt die echte Spielszene und spielt ein paar Zuege im
## Hotseat-Modus durch (ohne Maus, direkt ueber die GameSession). Ausfuehren mit:
##   godot --headless --path asynk-rpg res://tests/test_hotseat.tscn

var _failures := 0


func check(cond: bool, what: String) -> void:
	if not cond:
		_failures += 1
		printerr("FEHLER: ", what)


func _ready() -> void:
	var world: Node = load("res://scenes/node_2d.tscn").instantiate()
	var session: GameSession = world.get_node("GameSession")
	session.autosave = false
	add_child(world)
	await get_tree().process_frame
	await get_tree().process_frame

	var s := session.state
	check(s != null and s.players.size() == 2, "Spiel mit 2 Spielern gestartet")
	check(session.map.cell_count() > 1000, "Karte aus der TileMap gelesen (%d Felder)" % session.map.cell_count())
	for p in s.players:
		check(session.map.is_walkable(p["pos"]), "Startfeld %s ist begehbar" % p["pos"])

	var hud = world.get_node("CanvasLayer/TurnHud")
	check(hud.is_blocking(), "Uebergabe-Bildschirm zeigt sich zu Beginn")

	var a1: Node2D = world.get_node("CharacterBody2D")
	var a2: Node2D = world.get_node("CharacterBody2D2")
	var agent1 = a1.get_node("HexAgent")
	check(a1.global_position.distance_to(agent1.cell_to_position(s.players[0]["pos"])) < 0.5, "Figur 1 steht auf ihrem Feld")

	# Spieler 1 zieht 2 Felder, Spieler 2 darf in der Zeit nichts.
	var target: Vector2i = s.players[0]["pos"] + Vector2i(2, 0)
	if not session.map.is_walkable(target):
		target = s.players[0]["pos"] + Vector2i(0, 2)
	check(session.request_move_to(target), "Spieler 1 bewegt sich nach %s" % target)
	check(s.players[0]["steps_left"] == 2, "Spieler 1 hat noch 2 Schritte")
	check(not session.submit({"type": "end_turn", "player": 1, "round": 1}), "Spieler 2 darf nicht beenden")

	await get_tree().create_timer(1.0).timeout
	check(a1.global_position.distance_to(agent1.cell_to_position(target)) < 0.5, "Figur 1 ist sichtbar angekommen")

	var p2_before := a2.global_position
	check(session.request_end_turn(), "Spieler 1 beendet den Zug")
	check(s.current_player == 1, "Spieler 2 ist dran")
	check(a2.global_position == p2_before, "Figur 2 hat sich nicht bewegt")
	check(session.request_end_turn(), "Spieler 2 beendet den Zug")
	check(s.current_player == 0 and s.round_number == 2, "Runde 2, Spieler 1")

	print("Hotseat-Test: %s" % ("OK" if _failures == 0 else "%d Fehler" % _failures))
	print(s.to_json())
	get_tree().quit(1 if _failures > 0 else 0)
