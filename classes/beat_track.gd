extends Resource
class_name BeatTrack

@export var beat_num: int = 16 
@export var beats : Array[Note]
@export var bpm: float = 130.0
@export var repetitions: int = 4

var curr_beat: int = 0

func get_curr_beat() -> Note:
	if curr_beat >= beats.size():
		return null
		
	return beats[curr_beat]

func reset_beat() -> void:
	curr_beat = 0

func increment_beat() -> bool:
	curr_beat += 1
	
	if curr_beat >= beat_num:
		return false
		
	return true
