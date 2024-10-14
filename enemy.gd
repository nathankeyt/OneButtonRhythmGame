extends Character
class_name Enemy

func _ready() -> void:
	BattleManager.add_enemy(self)
