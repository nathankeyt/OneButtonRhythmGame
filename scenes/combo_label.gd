extends RichTextLabel

func _ready() -> void:
	BattleManager.combo_updated(update)


func update(score: float) -> void:
	pass
