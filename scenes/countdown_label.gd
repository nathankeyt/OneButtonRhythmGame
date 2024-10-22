extends RichTextLabel

@export var normal_color: Color
@export var highlight_color: Color
@export var normal_scale: float = 1.0
@export var highlight_scale: float = 1.0
@export var ready_scale: float = 1.0
@export var go_scale: float = 1.0

@export var normal_sound: AudioStream
@export var highlight_sound: AudioStream

func _ready() -> void:
	text = ""
	modulate = normal_color
	BattleManager.example_note_played.connect(update)


func update(num: String, is_scoring: bool):
	if num == "":
		text = ""
		return

	scale = Vector2.ONE
	#if num == "READY":
		#scale *= ready_scale
	#elif num == "GO!" or num == "SET":
		#scale *= go_scale
	if is_scoring:
		scale *= highlight_scale
	else:
		scale *= normal_scale
	
	if is_scoring:
		GlobalAudioManager.play_SFX(highlight_sound)
		modulate = highlight_color
	else:
		GlobalAudioManager.play_SFX(normal_sound)
		modulate = normal_color
	
	text = "[center]" + num + "[/center]"

	
