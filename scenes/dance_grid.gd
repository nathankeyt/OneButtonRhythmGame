extends Node3D
class_name DanceGrid

@export var mesh: Mesh
@export var cell_size: int
@export var grid_size: int

var grid: Array[Array]

func _init() -> void:
	BattleManager.dance_grid = self
	
func _ready() -> void:
	generate_grid()

func generate_grid() -> void:
	var center: float = ((grid_size - 1) * cell_size) / 2.0
	for i in grid_size:
		var curr_arr: Array[MeshInstance3D] = []
		grid.append(curr_arr)
		for j in grid_size:
			var new_mesh_instance := MeshInstance3D.new()
			add_child(new_mesh_instance)
			
			new_mesh_instance.mesh = mesh
			new_mesh_instance.position = Vector3((i * cell_size) - center, 0.0, (j * cell_size) - center)
			
			curr_arr.append(new_mesh_instance)
			
