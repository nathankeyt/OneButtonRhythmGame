extends Effect
class_name AddScoreEffect

@export var m_add_score: int = 0.0

func apply_effect(target: Variant = null) -> void:
	BattleManager.add_score(m_add_score)
