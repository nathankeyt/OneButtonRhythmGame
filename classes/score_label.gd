extends RichTextLabel
class_name ScoreLabel

@export_enum("p_temp_score_updated", "e_temp_score_updated", "p_score_updated", "e_score_updated", "p_score_settled", "e_score_settled", "combo_updated") var connected_score_signal: String
@export_enum("p_temp_op_updated", "e_temp_op_updated", "p_op_updated", "e_op_updated", "p_op_settled", "e_op_settled", "combo_op_updated") var connected_operator_signal: String

var operator: String = ""
var curr_op: Effect.OperatorType = 0
var prev_score: float = 0

func _ready() -> void:
	BattleManager.connect(connected_score_signal, update_score)
	if connected_operator_signal == "combo_op_updated":
		operator = "x"
		curr_op = Effect.OperatorType.MULTIPLY
	else:
		BattleManager.connect(connected_operator_signal, update_operator)
	

func update_score(amount: float):
	if not amount and connected_score_signal != "p_score_settled":
		var tween: Tween = create_tween()
		tween.tween_method(set_text_val, prev_score, 0.0, GlobalAudioManager.curr_beat_rate * 2.0)
		tween.tween_callback(func(): text = "")
		prev_score = 0.0 
		return
		
	if text == "" and connected_score_signal == "p_temp_score_updated" or connected_score_signal == "combo_updated":
		prev_score = 1.0
	
	var tween: Tween = create_tween()
	tween.tween_method(set_text_val, prev_score, amount, GlobalAudioManager.curr_beat_rate * 2.0)
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
