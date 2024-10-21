extends Node3D
class_name DanceGrid

@export var mesh: Mesh
@export var cell_size: int = 1
@export var grid_size: int = 12
@export var start_radius: int = 9
@export var end_radius: int = 0
@export var hit_mesh: MeshInstance3D

@onready var total_radius: int = start_radius - end_radius
@onready var center: float = ((grid_size - 1) * cell_size) / 2.0
@onready var press_flag: FlagRef = FlagRef.new()

var grid: Array[Array]
var color_flag: bool = true
var note_queue: Array[Array]
var hit_mesh_material: StandardMaterial3D


func _init() -> void:
	BattleManager.dance_grid = self
	
func _ready() -> void:
	generate_grid()
	BattleManager.note_played.connect(animate_circle)
	BattleManager.note_hit.connect(animate_hit)

func generate_grid() -> void:
	hit_mesh_material = StandardMaterial3D.new()
	hit_mesh_material.emission_energy_multiplier = 1.0
	hit_mesh_material.albedo_color = Color.GRAY
	hit_mesh.set_surface_override_material(0, hit_mesh_material)
	
	for x in grid_size:
		var curr_arr: Array[MeshInstance3D] = []
		grid.append(curr_arr)
		for y in grid_size:
			var new_mesh_instance := MeshInstance3D.new()
			add_child(new_mesh_instance)
			
			new_mesh_instance.mesh = mesh
			new_mesh_instance.position = Vector3((x * cell_size) - center, 0.0, (y * cell_size) - center)
			
			var new_material := StandardMaterial3D.new()
			new_material.emission_energy_multiplier = 1.0
			new_mesh_instance.set_surface_override_material(0, new_material)
			
			curr_arr.append(new_mesh_instance)

func activate_circle(stop_flag: FlagRef, radius: int, color: Color = Color.RED, duration: float = 0.0, is_user_activated: bool = false):
	if radius == 1 and not is_user_activated:
		press_flag.flag = true
		
	var materials: Array[StandardMaterial3D] = get_materials_at_radius(radius)
	
	if is_user_activated:
		hit_mesh_material.emission = color
		hit_mesh_material.emission_enabled = true
	else:
		for material: StandardMaterial3D in materials:
			material.emission = color
			material.emission_enabled = true
	
	if duration:
		await get_tree().create_timer(duration).timeout
	else:
		await GlobalAudioManager.quarter_beat_played
	
	if is_user_activated:
		hit_mesh_material.emission_enabled = false
	else:
		deactive_materials(materials)
		
	#if not stop_flag.flag:
		#deactive_materials(materials)
	#elif color == Color.BLUE:
		#print(color)
	
		
func deactivate_circle(radius: int):
	var materials: Array[StandardMaterial3D] = get_materials_at_radius(radius)
	deactive_materials(materials)
		
func deactive_materials(materials: Array[StandardMaterial3D]):
	for material: StandardMaterial3D in materials:
		material.emission_enabled = false
	
func get_materials_at_radius(radius: int):
	var materials: Array[StandardMaterial3D]
	for x in grid_size:
		for y in grid_size:
			var circle_bounds = pow(x - center, 2) + pow(y - center, 2)
			if circle_bounds <= pow(radius, 2) && circle_bounds > pow(radius - 1, 2):
				materials.append(grid[x][y].get_surface_override_material(0))

	return materials
			
func get_time_sec():
	return Time.get_ticks_msec() * 0.001

func animate_hit(acc: BattleManager.AccType, is_early: bool = false):
	var stop_flag = FlagRef.new()
	match acc:
		BattleManager.AccType.PERFECT:
			if is_early:
				await GlobalAudioManager.quarter_beat_played
			animate_standard(stop_flag, Color.BLUE)
		_:
			animate_standard(stop_flag, Color.RED)

func animate_circle(beat_type: Note):
	var stop_flag = FlagRef.new()
	note_queue.push_front([beat_type, get_time_sec() + get_note_travel_time(), stop_flag])
	
	animate_standard(stop_flag, Color.DEEP_PINK if color_flag else Color.PURPLE)
	color_flag = !color_flag

func get_note_travel_time() -> float:
	return GlobalAudioManager.curr_beat_rate * (start_radius - 1)

func animate_standard(stop_flag: FlagRef, color: Color = Color.RED):
	for radius in total_radius - 1:
		var curr_radius: int = radius + 1
		activate_circle(stop_flag, curr_radius, color)
		
		var deactivate_function := func(): deactivate_circle(curr_radius)
		stop_flag.flag_change.connect(deactivate_function)
		
		await GlobalAudioManager.quarter_beat_played
		
		stop_flag.flag_change.disconnect(deactivate_function)
		if stop_flag.flag:
			return
			
	note_queue.pop_back()
			


#func _input(event: InputEvent) -> void:
	#if BattleManager.is_player_dance_phase() and event.is_action_pressed("select"):
		#press_flag.flag = true
		#
		#if not note_queue.is_empty():
			#var beat_info: Array = note_queue.back()
			#var time_diff: float = beat_info[1] - get_time_sec()
			#
			#if time_diff <= 0.0:
				#note_queue.pop_back()
				#BattleManager.add_player_score(1.0 + (time_diff / GlobalAudioManager.curr_beat_rate))
				#(beat_info[2] as FlagRef).flip()
			#
		#press_flag = FlagRef.new()
		#activate_circle(press_flag, 1, Color.BLUE, 0.05, true)
