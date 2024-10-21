extends Effect
class_name ScoreEffect

@export var m_amount: float
@export var m_operator_type: OperatorType

func partition_amount(partitions: float) -> float:
	if m_operator_type == OperatorType.MULTIPLY:
		print((m_amount - 1) / partitions)
		return (m_amount - 1) / partitions
		
	return m_amount / partitions
	

	
