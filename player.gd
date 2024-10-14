extends Character
class_name Player

func _ready() -> void:
	BattleManager.player = self
