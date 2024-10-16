extends Effect
class_name ScoreEffect

@export var m_amount: float
@export var m_operator_type: OperatorType

func partition_amount(partitions: float) -> float:
	return m_amount / partitions
	

	
