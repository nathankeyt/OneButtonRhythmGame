extends Resource
class_name Card

@export var title: String
@export var text: String
@export var cost: int
@export var img: ImageTexture
@export var modifiable_effects: Array[Effect]
@export var unmodifiable_effects: Array[Effect]
@export_file var midi_track: String

func apply_effects() -> void:
	for effect: Effect in modifiable_effects:
		effect.apply_effect()

	for effect: Effect in unmodifiable_effects:
		effect.apply_effect()
