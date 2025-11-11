extends Camera2D

var OldMousePosition: Vector2
var OldMousePositionZoom: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if delta > 0.0:
		pass 

func _input(event):
	if event is InputEventScreenDrag:
		var i = event.index
		var summePos = 0
		if i > 1 :
			for Pos in i:
				summePos += i
				print(summePos / i.size())
	if event is InputEventMouseButton:
		OldMousePositionZoom =get_global_mouse_position()
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed and (zoom.x < 2.0 and zoom.y < 2.0):
			zoom *= 1.1
			position += OldMousePositionZoom - get_global_mouse_position()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed and (zoom.x > 0.05 and zoom.y > 0.05):
			zoom *= 0.9
			position += OldMousePositionZoom - get_global_mouse_position()
	if Input.is_action_just_pressed("MOUSE_BUTTON_LEFT"):
		OldMousePosition = get_global_mouse_position()
	if Input.is_action_pressed("MOUSE_BUTTON_LEFT"):
		if event is InputEventMouseMotion:
			position += OldMousePosition - get_global_mouse_position()



#Camera2D:
#extends Camera2D
#
#var prev_d: float = 0.0
#var zoom_level: float = 1.0
#var touches: Dictionary = {}
#const SPEED: float = 0.005
#
#func _input(event):
	#if event is InputEventScreenTouch:
		#if event.pressed:
			#touches[event.index] = event.position
		#else:
			#touches.erase(event.index)
			#prev_d = 0.0
			#
	#elif event is InputEventScreenDrag:
		#touches[event.index] = event.position
		#
	#if touches.size() == 2:
		#var keys = touches.keys()
		#var d: float = touches[keys[0]].distance_to(touches[keys[1]])
		#
		#if prev_d > 0:
			#zoom_level += (d - prev_d) * SPEED
			#zoom_level = clamp(zoom_level, 0.5, 2.0)
			#self.zoom = Vector2(zoom_level, zoom_level)
			#
		#prev_d = d
