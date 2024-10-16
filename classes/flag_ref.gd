extends RefCounted
class_name FlagRef

var flag: bool

signal flag_change

func _init(flag_value: bool = false) -> void:
	flag = flag_value
	
func flip():
	flag = !flag
	flag_change.emit()
