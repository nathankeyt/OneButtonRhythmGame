extends Node2D

@export var label_scene: PackedScene
@export var travel_distance: Vector2
@export var length: int = 1
@export var perfect_color: Color
@export var miss_sound: AudioStream

func _ready() -> void:
	BattleManager.note_hit.connect(generate_label)

func generate_label(acc_type: BattleManager.AccType, is_early: bool = false):
	var new_label: RichTextLabel = label_scene.instantiate()
	add_child(new_label)

	new_label.text = " " + BattleManager.AccType.keys()[acc_type] + "!"
	
	var color: Color
	match acc_type:
		BattleManager.AccType.PERFECT:
			color = perfect_color
		_:
			color = Color.WHITE

	new_label.modulate = color
	
	var tween: Tween = create_tween()
	tween.parallel().tween_property(new_label, "position", travel_distance, GlobalAudioManager.curr_beat_rate * 2.0 * length)
	tween.parallel().tween_property(new_label, "modulate:a", 0.0, GlobalAudioManager.curr_beat_rate * 2.0 * length).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(func(): new_label.queue_free())
