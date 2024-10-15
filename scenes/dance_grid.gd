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
	BattleManager.beat_played.connect(animate_circle)
	generate_grid()
	await get_tree().create_timer(1.0).timeout
	animate_circle(BattleManager.BeatType.STANDARD, 2.0)

func generate_grid() -> void:
	for x in grid_size:
		var curr_arr: Array[MeshInstance3D] = []
		grid.append(curr_arr)
		for y in grid_size:
			var new_mesh_instance := MeshInstance3D.new()
			add_child(new_mesh_instance)
			
			new_mesh_instance.mesh = mesh
			new_mesh_instance.position = Vector3((x * cell_size) - center, 0.0, (y * cell_size) - center)
			new_mesh_instance.set_surface_override_material(0, StandardMaterial3D.new())
			
			curr_arr.append(new_mesh_instance)

func activate_circle(radius: int, duration: float = 1.0):
	var activated_materials: Array[StandardMaterial3D]
	for x in grid_size:
		for y in grid_size:
			var circle_bounds = pow(x - center, 2) + pow(y - center, 2)
			if circle_bounds <= pow(radius, 2) && circle_bounds > pow(radius - 1, 2):
				var material: StandardMaterial3D = grid[x][y].get_surface_override_material(0)
				material.albedo_color = Color.RED
				activated_materials.append(material)
	
	await get_tree().create_timer(duration).timeout
	
	for material: StandardMaterial3D in activated_materials:
		material.albedo_color = Color.WHITE
				

func animate_circle(beat_type: BattleManager.BeatType, duration: float = 1.0):
	match beat_type:
		BattleManager.BeatType.STANDARD:
			animate_standard(duration)

func animate_standard(duration: float):
	var beat_duration: float = duration / total_radius
	for radius in total_radius:
		await activate_circle(total_radius - radius, beat_duration)
		
	
