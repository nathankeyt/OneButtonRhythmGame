extends RichTextLabel

func _ready() -> void:
	BattleManager.turn_updated.connect(update)

func update(turns_left: int):
	text = "[right]Turns Left:\n" + str(turns_left) + "[/right]"
