extends RichTextLabel
class_name ScoreLabel

@export_enum("p_temp_score_updated", "e_temp_score_updated", "p_score_updated", "e_score_updated", "p_score_settled", "e_score_settled") var connected_score_signal: String
@export_enum("p_temp_op_updated", "e_temp_op_updated", "p_op_updated", "e_op_updated", "p_op_settled", "e_op_settled") var connected_operator_signal: String

var operator: String = ""

func _ready() -> void:
	BattleManager.connect(connected_score_signal, update_score)
	BattleManager.connect(connected_operator_signal, update_operator)

func update_score(amount: float):
	text = "[center]" + operator + str(amount) + "[/center]"
	
func update_operator(operator_type: Effect.OperatorType):
	match operator_type:
		Effect.OperatorType.ADD:
			operator = "+"
		Effect.OperatorType.SUBTRACT:
			operator = "-"
		Effect.OperatorType.MULTIPLY:
			operator = "+"
		Effect.OperatorType.DIVIDE:
			operator = "+"
		_:
			operator = ""
