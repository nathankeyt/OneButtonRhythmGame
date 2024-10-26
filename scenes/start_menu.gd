extends Node

@export var select_threshold: float = 0.1
@export var select_timer: Timer
@export var selection_color: Color
@export var play_label: RichTextLabel
@export var quit_label: RichTextLabel
@export var select_bar: ProgressBar
@export var main_level_path: String

var is_play_selected: bool = true

func _ready() -> void: 
	play_label.modulate = selection_color

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		select_timer.start()
			
	if event.is_action_released("select"):
		if not select_timer.is_stopped():
			if get_time_in(select_timer) < select_threshold:
				if is_play_selected:
					play_label.modulate = Color.WHITE
					quit_label.modulate = selection_color
				else:
					play_label.modulate = selection_color
					quit_label.modulate = Color.WHITE
					
				is_play_selected = !is_play_selected
					
			select_timer.stop()
			select_bar.ratio = 0.0
		
func get_time_in(timer: Timer):
	return timer.wait_time - timer.time_left
	
func _process(delta: float) -> void:
	var curr_time: float = get_time_in(select_timer)
	if not select_timer.is_stopped() and curr_time > select_threshold:
		select_bar.ratio = (curr_time - select_threshold) / (select_timer.wait_time - select_threshold)

func _on_hold_timer_timeout() -> void:
	if is_play_selected:
		get_tree().change_scene_to_file(main_level_path)
	else:
		print('what')
		get_tree().quit()
	
