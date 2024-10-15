extends Resource
class_name BeatTrack

@export var beat_num: int = 16
@export var beats : Array[BattleManager.BeatType]

var curr_beat: int = 0

func get_curr_beat() -> BattleManager.BeatType:
	if curr_beat >= beats.size():
		return BattleManager.BeatType.NONE
		
	return beats[curr_beat]

func increment_beat() -> bool:
	curr_beat += 1
	
	if curr_beat >= beat_num:
		return false
		
	return true
