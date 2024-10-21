extends Node3D

@export var light_gradient: Gradient
@export var color_change_rate: float = 1.0
@export var spotlight_container: SpotLightContainer
@export var main_spotlight: SpotLight3D

var change_rate: float = 0.0
var curr_color: Color
var curr_pos: float = 0.0

func _ready() -> void:
	change_rate = GlobalAudioManager.curr_beat_rate * color_change_rate

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	curr_color = light_gradient.sample(curr_pos)
	update_connected_nodes()
	
	curr_pos += change_rate * delta
	
	if curr_pos > 1.0:
		curr_pos = 0.0
		
	
		
func update_connected_nodes():
	if main_spotlight:
		main_spotlight.light_color = curr_color
		
	if spotlight_container:
		spotlight_container.update_light_colors(curr_color)
