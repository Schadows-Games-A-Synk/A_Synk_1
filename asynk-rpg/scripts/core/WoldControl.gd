extends Node2D

@export var ScrollRange: int = 10
@onready var Charakter := %CharacterBody2D
@onready var Camera := %Camera2D
var StartMousPos: Vector2


func _input(event: InputEvent) -> void:
	if not Glob.MouseOnUI:
		if Input.is_action_just_pressed("MOUSE_BUTTON_LEFT") or (event is InputEventScreenTouch) and (not event.is_released()):
			StartMousPos = event.position
			Camera.moveCamera(event)
		if Input.is_action_just_pressed("BUTTON_WHEEL_DOWN") or Input.is_action_just_pressed("BUTTON_WHEEL_UP") or (Input.is_action_pressed("MOUSE_BUTTON_LEFT") and (StartMousPos.distance_to(event.position)> ScrollRange)):
			Camera.moveCamera(event)
		if (Input.is_action_just_released("MOUSE_BUTTON_LEFT") and (StartMousPos.distance_to(event.position)<= ScrollRange)) :
			Charakter.get_node("HexAgent").SetInput(event)
