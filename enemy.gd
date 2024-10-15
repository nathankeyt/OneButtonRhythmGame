extends Character
class_name Enemy

func _init() -> void:
	BattleManager.add_enemy(self)
