extends Node 
#Resource
#class_name Globals

enum Status {Nothing,Lumber,Mine,Fish}
var CurStatus := Status.Nothing
var MouseOnUI : bool

func _init() -> void:
	CurStatus = Status.Nothing
