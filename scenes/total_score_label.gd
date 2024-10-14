extends ScoreLabel

func _init() -> void:
	match actor_type:
		BattleManager.ActorType.PLAYER:
			BattleManager.player_total_score_label = self
		BattleManager.ActorType.ENEMY:
			BattleManager.enemy_total_score_label = self

func update_score(score: int) -> void:
	text = "[center]" + str(score) + "[/center]"
