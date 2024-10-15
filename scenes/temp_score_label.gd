extends ScoreLabel

func _ready() -> void:
	match turn_type:
		BattleManager.TurnType.PLAYER:
			BattleManager.player_score_updated.connect(update_score)
		BattleManager.TurnType.ENEMY:
			BattleManager.enemy_score_updated.connect(update_score)

func update_score(score: int) -> void:
	text = "[center]+" + str(score) + "[/center]"
