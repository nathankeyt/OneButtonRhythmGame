extends Resource
class_name Note

@export var sound: AudioStream
@export var is_scoring: bool = false

func play():
	GlobalAudioManager.play_SFX(sound)
