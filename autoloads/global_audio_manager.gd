extends AudioStreamPlayer2D

signal sfx_finished
signal beat_played

var curr_beat_rate: float = 1.0
var last_beat_time: float

func play_track(new_stream: AudioStream, volume = 1.0):
	if (stream == new_stream):
		return
		
	stream = new_stream
	volume_db = volume
	play()
	
func play_battle_song(battle_song: BattleSong, volume = 1.0):
	play_track(battle_song.audio_stream, volume)
	print(battle_song.bpm)
	curr_beat_rate = 60.0 / battle_song.bpm
	
	while(true):
		await get_tree().create_timer(curr_beat_rate).timeout
		beat_played.emit()
		last_beat_time = Time.get_ticks_msec()
		
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
