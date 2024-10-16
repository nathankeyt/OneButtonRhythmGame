extends Effect
class_name SimpleOperationEffect

@export var m_amount: int = 0.0
@export var m_operator_type: OperatorType

func apply_effect(target: Variant = null) -> void:
	match m_operator_type:
		OperatorType.ADD:
			BattleManager.add_player_score(m_amount)
