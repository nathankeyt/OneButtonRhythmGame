extends Node3D

@onready var animation_player: AnimationPlayer = $main_character_dance/AnimationPlayer

var flip: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("rigAction")
	animation_player.animation_finished.connect(ping_pong)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func ping_pong():
	if flip:
		animation_player.play("rigAction")
	else:
		animation_player.play_backwards("rigAction")
	flip = !flip
