extends Node

@export_enum("win", "lose") var signal_enum: String
@export var scene_path: String

func _ready() -> void:
	BattleManager.connect(signal_enum, load_scene)

func load_scene() -> void:
	get_tree().change_scene_to_file(scene_path)
