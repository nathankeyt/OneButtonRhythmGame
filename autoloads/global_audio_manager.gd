extends AudioStreamPlayer

signal sfx_finished
signal beat_played
signal half_beat_played

var beat_manager: RhythmNotifier

var curr_beat_rate: float = 1.0
var last_beat_time: float

var time_begin: float = 0.0
var time_delay: float = 0.0

func play_track(new_stream: AudioStream, volume = 1.0):
	if (stream == new_stream):
		return
		
	stream = new_stream
	volume_db = volume
	
	play()
	
func play_battle_song(battle_song: BattleSong, volume = 1.0):
	beat_manager.bpm = battle_song.bpm
	curr_beat_rate = 60.0 / battle_song.bpm
	beat_manager.beats(1).connect(func(count): beat_played.emit())
	beat_manager.beats(0.5).connect(func(count): half_beat_played.emit())
	play_track(battle_song.audio_stream, volume)
	seek(16)
	
		
func time_since_last_beat():
	return (Time.get_ticks_msec() - last_beat_time) * 0.001
	
func time_to_next_beat():
	return curr_beat_rate - time_since_last_beat()
	
func play_SFX(new_stream: AudioStream, volume = 1.0, length = 0.0):
	var sfx_player = AudioStreamPlayer2D.new()
	sfx_player.stream = new_stream
	sfx_player.volume_db = volume
	sfx_player.name = "SFX_Instance"
	add_child(sfx_player)
	sfx_player.play()
	
	if length:
		await get_tree().create_timer(length).timeout
	else:
		await sfx_player.finished
	
	sfx_finished.emit()
	sfx_player.queue_free()
