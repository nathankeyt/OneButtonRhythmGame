extends Node2D

@export var lead_time: float = 2.0;
@export var note_scene: PackedScene;

@onready var note_spawn_pos: Node2D = $NoteSpawnPos
@onready var note_end_pos: Node2D = $NoteEndPos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start()

func start() -> void:
	await get_tree().create_timer(lead_time).timeout
	$LiveMidiPlayer.play()

func _on_midi_player_midi_event(channel: Variant, event: Variant) -> void:
	match event.type:
		SMF.MIDIEventType.note_on:
			print(event.note, " ", channel.number)
			if channel.number == 4:
				$Visualizer.show()
				await Engine.get_main_loop().process_frame
				$Visualizer.hide()


func _on_foresight_midi_player_midi_event(channel: Variant, event: Variant) -> void:
	match event.type:
		SMF.MIDIEventType.note_on:
			if channel.number == 4:
				var new_note = note_scene.instantiate()
				add_child(new_note)
				new_note.position = note_spawn_pos.position
				
				var tween: Tween = create_tween()
				tween.tween_property(new_note, "position", note_end_pos.position, lead_time)
				tween.tween_callback(new_note.queue_free)
