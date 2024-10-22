extends RichTextLabel

@export var normal_color: Color
@export var highlight_color: Color
@export var normal_scale: float = 1.0
@export var highlight_scale: float = 1.0

@export var normal_sound: AudioStream
@export var highlight_sound: AudioStream

func _ready() -> void:
	text = ""
	modulate = normal_color
	BattleManager.example_note_played.connect(update)


func update(num: int, is_scoring: bool):
	if num <= 0:
		text = ""
		return

	if is_scoring:
		scale = Vector2.ONE * highlight_scale
		GlobalAudioManager.play_SFX(highlight_sound)
		modulate = highlight_color
	else:
		scale = Vector2.ONE * normal_scale
		GlobalAudioManager.play_SFX(normal_sound)
		modulate = normal_color
	
	text = "[center]" + str(num) + "[/center]"

	
