extends Control
## Zeigt an, wer am Zug ist, wie viele Schritte noch uebrig sind, und hat den
## "Zug beenden"-Knopf. Beim Spielerwechsel auf demselben Geraet (Hotseat)
## erscheint ein Uebergabe-Bildschirm, damit der naechste Spieler bewusst
## uebernimmt. Veraendert den Spielstand nur ueber die GameSession.

var _session: GameSession
var _info: Label
var _hint: Label
var _end_button: Button
var _panel: PanelContainer
var _overlay: ColorRect
var _overlay_label: Label
var _hint_timer: SceneTreeTimer


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()
	_session = get_tree().get_first_node_in_group(GameSession.GROUP) as GameSession
	if _session:
		_session.game_started.connect(_refresh)
		_session.move_applied.connect(func(_m, s): _refresh(s))
		_session.turn_started.connect(_on_turn_started)
		_session.move_rejected.connect(_show_hint)


## true, solange der Uebergabe-Bildschirm offen ist: dann keine Eingabe in die Welt.
func is_blocking() -> bool:
	return _overlay.visible


## true, wenn der Bildschirmpunkt auf diesem HUD liegt (wichtig fuer Touch,
## wo es kein "Maus ist ueber dem Knopf" gibt).
func covers(screen_pos: Vector2) -> bool:
	return _overlay.visible or _panel.get_global_rect().has_point(screen_pos)


func _build() -> void:
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_panel.position = Vector2(-16, 16)
	add_child(_panel)
	var box := VBoxContainer.new()
	_panel.add_child(box)
	_info = Label.new()
	box.add_child(_info)
	_end_button = Button.new()
	_end_button.text = "Zug beenden"
	_end_button.pressed.connect(func(): _session.request_end_turn())
	box.add_child(_end_button)
	var restart := Button.new()
	restart.text = "Neues Spiel"
	restart.flat = true
	restart.pressed.connect(func(): _session.new_game())
	restart.mouse_entered.connect(func(): Glob.MouseOnUI = true)
	box.add_child(restart)
	_hint = Label.new()
	_hint.modulate = Color(1, 0.75, 0.4)
	box.add_child(_hint)
	_panel.mouse_entered.connect(func(): Glob.MouseOnUI = true)
	_panel.mouse_exited.connect(func(): Glob.MouseOnUI = false)
	_end_button.mouse_entered.connect(func(): Glob.MouseOnUI = true)

	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0.8)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay.visible = false
	add_child(_overlay)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(center)
	var obox := VBoxContainer.new()
	obox.add_theme_constant_override("separation", 24)
	center.add_child(obox)
	_overlay_label = Label.new()
	_overlay_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_overlay_label.add_theme_font_size_override("font_size", 32)
	obox.add_child(_overlay_label)
	var go := Button.new()
	go.text = "Los geht's"
	go.add_theme_font_size_override("font_size", 28)
	go.pressed.connect(func(): _overlay.visible = false)
	obox.add_child(go)


func _refresh(state: GameState) -> void:
	var me := state.current()
	_info.text = "Runde %d · %s ist dran\nNoch %d Schritte" % [state.round_number, me["name"], me["steps_left"]]


func _on_turn_started(_player_index: int, state: GameState) -> void:
	_refresh(state)
	_hint.text = ""
	if state.players.size() > 1:
		_overlay_label.text = "%s ist dran\nGib das Gerät weiter." % state.current()["name"]
		_overlay.visible = true


func _show_hint(reason: String) -> void:
	_hint.text = reason
	_hint_timer = get_tree().create_timer(2.5)
	var t := _hint_timer
	t.timeout.connect(func(): if _hint_timer == t: _hint.text = "")
