extends Node3D

@export var bounce_amount: float = 1.0

var flip: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("bounce")
	GlobalAudioManager.half_beat_played.connect(bounce)


func bounce():
	if flip:
		global_position.y += bounce_amount
		#tween.tween_property(self, "global_position:y", global_position.y + bounce_amount, GlobalAudioManager.curr_beat_rate)
	else:
		global_position.y -= bounce_amount
		#tween.tween_property(self, "global_position:y", global_position.y - bounce_amount, GlobalAudioManager.curr_beat_rate)
	flip = !flip

func _physics_process(delta: float) -> void:
	#if flip:
		#global_position.y += bounce_amount * delta
	#else:
		#global_position.y -= bounce_amount * delta
	pass
