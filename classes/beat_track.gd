extends Resource
class_name BeatTrack

@export var beat_num: int = 16 
@export var set_beats : Array[BattleManager.BeatType]
@export var note_mapping: NoteMapping
@export var bpm: float = 130.0
@export var repetitions: int = 4
@export var example_speed_scale: int = 1
@export var example_repetitions: int = 1
@export var example_beat_num: int = 16

var curr_beat: int = 0


func get_curr_beat() -> Note:	
	if curr_beat >= set_beats.size():
		return null
		
	return get_beat(curr_beat)

func get_beat(index: int) -> Note:
	if index >= set_beats.size():
		return
		
	return note_mapping.get_note(set_beats[index])

func reset_beat() -> void:
	curr_beat = 0

func increment_beat() -> bool:
	curr_beat += 1
	
	if curr_beat >= beat_num:
		return false
		
	return true
