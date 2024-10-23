extends RichTextLabel

func _ready() -> void:
	text = ""
	BattleManager.display_count.connect(update)

func update(num: int) -> void:
	if num == 0.0:
		text = ""
		
	var val: String = "[center]" + str(num) + "[/center]"
	text = val
	
	await GlobalAudioManager.half_beat_played
	
	if text == val:
		text = ""
	
