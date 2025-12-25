extends Control

@onready var Nothing_Button := %Nothing_Button
@onready var Lumber_Button := %Lumber_Button
@onready var Mine_Button := %Mine_Button
@onready var Fish_Button := %Fish_Button

func _ready() -> void:
	Nothing_Button.grab_focus()

func SwitshTexture(ButtonIn: Button):
	var StyleBox_Normal : StyleBoxTexture
	var StyleBox_Hoverd : StyleBoxTexture
	StyleBox_Normal = ButtonIn.get_theme_stylebox("normal")
	var NormalV2 := StyleBox_Normal.region_rect
	StyleBox_Hoverd = ButtonIn.get_theme_stylebox("hover")
	var HoverV2 := StyleBox_Hoverd.region_rect
	StyleBox_Normal.region_rect = HoverV2
	StyleBox_Hoverd.region_rect = NormalV2

func ButonHandling(NewStatus: Glob.Status):
	if  Glob.CurStatus != NewStatus:
		HandleButonStade(Glob.CurStatus)
		HandleButonStade(NewStatus)
	elif Glob.CurStatus == NewStatus:
		HandleButonStade(Glob.CurStatus)
		HandleButonStade(Glob.Status.Nothing)

func _on_nothing_button_pressed() -> void:
	if  Glob.CurStatus != Glob.Status.Nothing:
		HandleButonStade(Glob.CurStatus)
		HandleButonStade(Glob.Status.Nothing)
	pass # Replace with function body.

func _on_lumber_button_pressed() -> void:
	ButonHandling(Glob.Status.Lumber)
	pass # Replace with function body.

func _on_mine_button_pressed() -> void:
	ButonHandling(Glob.Status.Mine)
	pass # Replace with function body.

func _on_fish_button_pressed() -> void:
	ButonHandling(Glob.Status.Fish)
	pass # Replace with function body.

func HandleButonStade(NewStatus: Glob.Status):
	match NewStatus:
		Glob.Status.Nothing:
			SwitshTexture(Nothing_Button)
			Glob.CurStatus = NewStatus
		Glob.Status.Lumber:
			SwitshTexture(Lumber_Button)
			Glob.CurStatus = NewStatus
		Glob.Status.Mine:
			SwitshTexture(Mine_Button)
			Glob.CurStatus = NewStatus
		Glob.Status.Fish:
			SwitshTexture(Fish_Button)
			Glob.CurStatus = NewStatus

func _on_margin_container_mouse_entered() -> void:
	Glob.MouseOnUI = true

func _on_margin_container_mouse_exited() -> void:
	Glob.MouseOnUI = false

func _on_nothing_button_mouse_entered() -> void:
	Glob.MouseOnUI = true

func _on_lumber_button_mouse_entered() -> void:
	Glob.MouseOnUI = true

func _on_mine_button_mouse_entered() -> void:
	Glob.MouseOnUI = true

func _on_fish_button_mouse_entered() -> void:
	Glob.MouseOnUI = true


func _on_fish_button_mouse_exited() -> void:
	Glob.MouseOnUI = false
	pass # Replace with function body.


func _on_mine_button_mouse_exited() -> void:
	Glob.MouseOnUI = false
	pass # Replace with function body.


func _on_lumber_button_mouse_exited() -> void:
	Glob.MouseOnUI = false
	pass # Replace with function body.


func _on_nothing_button_mouse_exited() -> void:
	Glob.MouseOnUI = false
	pass # Replace with function body.
