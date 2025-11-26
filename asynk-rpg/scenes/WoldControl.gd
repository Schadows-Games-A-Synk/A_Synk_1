extends Node2D

@onready var Charakter := %CharacterBody2D
@onready var Camera := %Camera2D
var StartMousPos: Vector2


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("MOUSE_BUTTON_LEFT") or event is InputEventScreenTouch:
		StartMousPos = event.position
	if Input.is_action_just_released("MOUSE_BUTTON_LEFT") and (StartMousPos.distance_to(event.position)< 10):
		Charakter.get_node("HexAgent").SetInput(event)
	else:
		Camera.moveCamera(event)
