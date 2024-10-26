extends RichTextLabel

func _ready() -> void:
	BattleManager.target_score_updated.connect(update)

func update(target_score: int):
	text = "[right]Target Score:\n" + str(target_score) + "[/right]"
