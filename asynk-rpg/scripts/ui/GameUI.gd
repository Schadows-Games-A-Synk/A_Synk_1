extends Control

@onready var Nothing_Button := %Nothing_Button
@onready var Lumber_Button := %Lumber_Button
@onready var Mine_Button := %Mine_Button
@onready var Fish_Button := %Fish_Button

enum Status {Nothing,Lumber,Mine,Fish}
var CurStatus : Status

func SwitshTexture(ButtonIn: Button):
	var StyleBox_Normal : StyleBoxTexture
	var StyleBox_Hoverd : StyleBoxTexture
	StyleBox_Normal = ButtonIn.get_theme_stylebox("normal")
	var NormalV2 := StyleBox_Normal.region_rect
	StyleBox_Hoverd = ButtonIn.get_theme_stylebox("hover")
	var HoverV2 := StyleBox_Hoverd.region_rect
	StyleBox_Normal.region_rect = HoverV2
	StyleBox_Hoverd.region_rect = NormalV2

func _ready() -> void:
	CurStatus = Status.Nothing

func _on_nothing_button_pressed() -> void:
	if  CurStatus != Status.Nothing:
		ResetButonStatus()
		HandleButonStade(Status.Nothing)
	pass # Replace with function body.

func _on_lumber_button_pressed() -> void:
	if  CurStatus != Status.Lumber:
		ResetButonStatus()
		HandleButonStade(Status.Lumber)
	elif CurStatus == Status.Lumber:
		ResetButonStatus()
		HandleButonStade(Status.Nothing)
	pass # Replace with function body.

func _on_mine_button_pressed() -> void:
	if  CurStatus != Status.Mine:
		ResetButonStatus()
		HandleButonStade(Status.Mine)
	elif CurStatus == Status.Mine:
		ResetButonStatus()
		HandleButonStade(Status.Nothing)
		ResetButonStatus()
		HandleButonStade(Status.Nothing)
	pass # Replace with function body.

func _on_fish_button_pressed() -> void:
	if  CurStatus != Status.Fish:
		ResetButonStatus()
		HandleButonStade(Status.Fish)
	elif CurStatus == Status.Fish:
		ResetButonStatus()
		HandleButonStade(Status.Nothing)
	pass # Replace with function body.

func HandleButonStade(NewStatus: Status):
	match NewStatus:
		Status.Nothing:
			SwitshTexture(Nothing_Button)
			CurStatus = NewStatus
		Status.Lumber:
			SwitshTexture(Lumber_Button)
			CurStatus = NewStatus
		Status.Mine:
			SwitshTexture(Mine_Button)
			CurStatus = NewStatus
		Status.Fish:
			SwitshTexture(Fish_Button)
			CurStatus = NewStatus

func ResetButonStatus():
	match CurStatus:
		Status.Nothing:
			SwitshTexture(Nothing_Button)
			CurStatus = CurStatus
		Status.Lumber:
			SwitshTexture(Lumber_Button)
			CurStatus = CurStatus
		Status.Mine:
			SwitshTexture(Mine_Button)
			CurStatus = CurStatus
		Status.Fish:
			SwitshTexture(Fish_Button)
			CurStatus = CurStatus
