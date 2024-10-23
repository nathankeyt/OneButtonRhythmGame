extends Character
class_name Player

@onready var animation_player: AnimationPlayer = $main_character_dance/AnimationPlayer

var flip: bool = true

func _init() -> void:
	BattleManager.player = self

func _ready() -> void:
	GlobalAudioManager.half_beat_played.connect(bounce)


func bounce():
	if flip:
		animation_player.play("rigAction")
	else:
		animation_player.play_backwards("rigAction")
	flip = !flip
		
