extends Control

@onready var Nothing_Button := %Nothing_Button
@onready var Lumber_Button := %Lumber_Button
@onready var Mine_Button := %Mine_Button
@onready var Fish_Button := %Fish_Button

enum Status {Nothing,Lumber,Mine,Fish }
var CurStatus : Status

func _ready() -> void:
	CurStatus = Status.Nothing

func _on_nothing_button_pressed() -> void:
	if  CurStatus != Status.Nothing:
		CurStatus = Status.Nothing
	pass # Replace with function body.


func _on_lumber_button_pressed() -> void:
	pass # Replace with function body.


func _on_mine_button_pressed() -> void:
	pass # Replace with function body.


func _on_fish_button_pressed() -> void:
	pass # Replace with function body.
