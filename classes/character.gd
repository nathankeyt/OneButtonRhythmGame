extends PathFollow3D
class_name Character

@export var sprite: Sprite3D

func execute_turn() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "progress_ratio", 1.0, 1.0).set_ease(Tween.EASE_IN_OUT)

func end_turn() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "progress_ratio", 0.0, 1.0).set_ease(Tween.EASE_IN_OUT)
