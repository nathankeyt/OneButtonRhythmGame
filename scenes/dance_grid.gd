extends Node3D
class_name DanceGrid

@export var mesh: Mesh
@export var cell_size: int = 1
@export var grid_size: int = 12
@export var start_radius: int = 9
@export var end_radius: int = 0

@onready var total_radius: int = start_radius - end_radius
@onready var center: float = ((grid_size - 1) * cell_size) / 2.0

var grid: Array[Array]

func _init() -> void:
	BattleManager.dance_grid = self
	
func _ready() -> void:
	generate_grid()
	BattleManager.note_played.connect(animate_circle)
	animate_circle(BattleManager.BeatType.STANDARD)

func generate_grid() -> void:
	for x in grid_size:
		var curr_arr: Array[MeshInstance3D] = []
		grid.append(curr_arr)
		for y in grid_size:
			var new_mesh_instance := MeshInstance3D.new()
			add_child(new_mesh_instance)
			
			new_mesh_instance.mesh = mesh
			new_mesh_instance.position = Vector3((x * cell_size) - center, 0.0, (y * cell_size) - center)
			
			var new_material := StandardMaterial3D.new()
			new_material.emission = Color.RED
			new_material.emission_energy_multiplier = 1.0
			new_mesh_instance.set_surface_override_material(0, new_material)
			
			curr_arr.append(new_mesh_instance)

func activate_circle(radius: int, duration: float = 1.0):
	var activated_materials: Array[StandardMaterial3D]
	for x in grid_size:
		for y in grid_size:
			var circle_bounds = pow(x - center, 2) + pow(y - center, 2)
			if circle_bounds <= pow(radius, 2) && circle_bounds > pow(radius - 1, 2):
				var material: StandardMaterial3D = grid[x][y].get_surface_override_material(0)
				material.emission_enabled = true
				activated_materials.append(material)
	
	await get_tree().create_timer(duration).timeout
	
	for material: StandardMaterial3D in activated_materials:
		material.emission_enabled = false
				

func animate_circle(beat_type: BattleManager.BeatType):
	match beat_type:
		BattleManager.BeatType.STANDARD:
			animate_standard()

func animate_standard():
	for radius in total_radius:
		activate_circle(total_radius - radius, 0.25)
		await GlobalAudioManager.beat_played
		
