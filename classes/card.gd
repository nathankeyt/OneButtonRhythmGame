extends Resource
class_name Card

@export var title: String
@export var text: String
@export var cost: int
@export var img: ImageTexture
@export var score_effect: ScoreEffect
@export var modifiable_effects: Array[Effect]
@export var unmodifiable_effects: Array[Effect]
@export var beat_track: BeatTrack

var num_beats: int = 0

func apply_effects() -> void:
	for effect: Effect in modifiable_effects:
		effect.apply_effect()

	for effect: Effect in unmodifiable_effects:
		effect.apply_effect()

func get_score_partition() -> float:
	if not num_beats:
		get_num_beats()
	
	if not score_effect or not num_beats:
		return 0.0
		
	return score_effect.partition_amount(num_beats)

func get_num_beats():
	if not beat_track:
		return
		
	for beat: Note in beat_track.beats:
		if beat:
			num_beats += 1
