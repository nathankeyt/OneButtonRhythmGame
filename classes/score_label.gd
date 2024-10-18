extends RichTextLabel
class_name ScoreLabel

@export_enum("p_temp_score_updated", "e_temp_score_updated", "p_score_updated", "e_score_updated", "p_score_settled", "e_score_settled") var connected_score_signal: String
@export_enum("p_temp_op_updated", "e_temp_op_updated", "p_op_updated", "e_op_updated", "p_op_settled", "e_op_settled") var connected_operator_signal: String

var operator: String = ""
var curr_op: Effect.OperatorType = 0
var prev_score: float = 0

func _ready() -> void:
	BattleManager.connect(connected_score_signal, update_score)
	BattleManager.connect(connected_operator_signal, update_operator)
	

func update_score(amount: float):
	if not amount:
		text = ""
		return
	
	var tween: Tween = create_tween()
	tween.tween_method(set_text_val, prev_score, amount, GlobalAudioManager.curr_beat_rate)
	prev_score = amount
	
func set_text_val(amount: float):
	text = "[center]" + operator + str(floor(amount) if BattleManager.is_main_op(curr_op) else snappedf(amount, 0.01)) + "[/center]"
	
func update_operator(operator_type: Effect.OperatorType):
	curr_op = operator_type
	match operator_type:
		Effect.OperatorType.ADD:
			operator = "+"
		Effect.OperatorType.SUBTRACT:
			operator = "-"
		Effect.OperatorType.MULTIPLY:
			operator = "x"
		Effect.OperatorType.DIVIDE:
			operator = "/"
		_:
			operator = ""
