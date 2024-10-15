extends Effect
class_name SimpleOperationEffect

enum OperatorType {Add, Subtract, Multiply, Divide}

@export var m_amount: int = 0.0
@export var m_operator_type: OperatorType

func apply_effect(target: Variant = null) -> void:
	match m_operator_type:
		OperatorType.Add:
			BattleManager.add_player_score(m_amount)
