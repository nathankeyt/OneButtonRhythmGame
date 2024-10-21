@tool
extends Node3D
class_name SpotLightContainer

@export var color: Color = Color("#ffc9f9") 
@export var energy: float = 1.0
@export var indirect_energy: float = 1.0
@export var fog_energy: float = 1.0

var spotlights : Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spotlights = Array(get_children())
	
	for spotlight: SpotLight3D in spotlights:
		spotlight.light_energy = energy
		spotlight.light_color = color
		spotlight.light_volumetric_fog_energy = fog_energy
		spotlight.light_indirect_energy = indirect_energy
		

func update_light_colors(color: Color):
	for spotlight: SpotLight3D in spotlights:
		spotlight.light_color = color

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
