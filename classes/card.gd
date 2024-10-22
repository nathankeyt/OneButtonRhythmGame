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

var num_scoring_beats: int = 0

func apply_effects() -> void:
	for effect: Effect in modifiable_effects:
		effect.apply_effect()

	for effect: Effect in unmodifiable_effects:
		effect.apply_effect()

func get_score_partition() -> float:
	if not num_scoring_beats:
		get_num_scoring_beats()
	
	if not score_effect or not num_scoring_beats:
		return 0.0
		
	return score_effect.partition_amount(num_scoring_beats * beat_track.repetitions)

func get_num_scoring_beats():
	if not beat_track:
		return
		
	for i: int in beat_track.beat_num:
		var beat: Note = beat_track.get_beat(i)
		if beat and beat.is_scoring:
			num_scoring_beats += 1
			
			
