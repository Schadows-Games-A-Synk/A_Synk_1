extends Camera2D

var OldMousePosition: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass 

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed and (zoom.x < 2.0 and zoom.y < 2.0):
			zoom *= 1.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed and (zoom.x > 0.05 and zoom.y > 0.05):
			zoom *= 0.9
	if Input.is_action_just_pressed("MOUSE_BUTTON_LEFT"):
		OldMousePosition = (get_viewport().get_mouse_position() + offset)
	if Input.is_action_pressed("MOUSE_BUTTON_LEFT"):
		if event is InputEventMouseMotion:
			offset = (OldMousePosition- get_viewport().get_mouse_position())
			print(OldMousePosition -get_viewport().get_mouse_position())
			print(zoom)
