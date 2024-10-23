extends Node

enum BeatType {NONE, STANDARD, SCORING}
enum TurnType {PLAYER = 0, ENEMY = 1}
enum PhaseType {CARD = 0, DANCE = 1}
enum AccType {PERFECT, EARLY, LATE}

var curr_turn: TurnType = TurnType.PLAYER
var curr_phase: PhaseType = PhaseType.CARD

var played_cards: Array[CardRenderer2D]

var max_resources: int = 3
@onready var curr_resources: int = max_resources

var deck: Deck2D
var hand: Hand2D

var dance_grid: DanceGrid

var player: Player
var enemies: Array[Enemy]

var player_temp_score: float = 0
var player_temp2_score: float = 0.0
var player_total_score: float = 0
var enemy_temp_score: float = 0
var enemy_temp2_score: float = 1.0
var enemy_total_score: float = 0

var combo_score: float = 1.0

var op_queue: Array[Array]

var curr_temp_score_partition: float = 0;

signal p_temp_score_updated(score: float)
signal e_temp_score_updated(score: float)
signal p_score_updated(score: float)
signal e_score_updated(score: float)
signal p_score_settled(score: float)
signal e_score_settled(score: float)

signal p_temp_op_updated(score: Effect.OperatorType)
signal e_temp_op_updated(score: Effect.OperatorType)
signal p_op_updated(score: Effect.OperatorType)
signal e_op_updated(score: Effect.OperatorType)
signal p_op_settled(score: Effect.OperatorType)
signal e_op_settled(score: Effect.OperatorType)

signal card_played(card_renderer: CardRenderer2D)
signal turn_ended(turn_type: TurnType)

signal combo_updated(score: float)

signal resource_updated(amount: int)

signal note_played(beat_type: Note, is_early: bool)
signal display_count(count: int)
signal example_note_played(num: String, is_target: bool)
signal track_ended
signal note_hit(acc: AccType, is_early: bool)

var is_next_note_scoring: bool = false
var was_last_note_scoring: bool = false
var late_flag: bool = false
var nearest_note: Note
var can_hit: bool = false

var curr_op: Effect.OperatorType = 0

func _ready() -> void:
	note_hit.connect(on_note_hit)

func add_player_score(acc: float):
	if not curr_temp_score_partition:
		return
		
	if not is_main_op(curr_op):
		add_temp_player_score(acc)
		return
		
	player_temp_score += curr_temp_score_partition * acc
	p_score_updated.emit(player_temp_score)

func add_enemy_score(score: float):
	enemy_temp_score += score
	e_score_updated.emit(enemy_temp_score)
	
func add_enemy(new_enemy: Enemy):
	enemies.append(new_enemy)
	
func add_temp_player_score(acc: float):
	if not player_temp2_score:
		player_temp2_score += 1.0
	player_temp2_score += curr_temp_score_partition * acc
	p_temp_score_updated.emit(player_temp2_score)

func add_temp_enemy_score():
	if not curr_temp_score_partition:
		return
		
	enemy_temp2_score += curr_temp_score_partition
	e_temp_score_updated.emit(enemy_temp2_score)

func is_main_op(op: Effect.OperatorType):
	return op == Effect.OperatorType.ADD or op == Effect.OperatorType.SUBTRACT or not op

func execute_turn():
	curr_phase = PhaseType.DANCE
	match curr_turn:
		TurnType.PLAYER:
			print(played_cards)
			player.execute_turn()
			hand.lower_hand()
			
			var first_flag: bool = true
			
			for card_renderer: CardRenderer2D in played_cards:
				card_renderer.hide()
			
			for card_renderer: CardRenderer2D in played_cards:
				var card: Card = card_renderer.card		
				
				op_queue.push_front([card.score_effect.m_operator_type, card.get_score_partition()])
				if first_flag:
					pop_op_queue()
					first_flag = false
				
				play_beat_track(card)
				await track_ended
				
				get_tree().create_timer(GlobalAudioManager.curr_beat_rate).timeout.connect(pop_op_queue)
				card.apply_effects()

			
			await get_tree().create_timer(dance_grid.get_note_travel_time() + GlobalAudioManager.curr_beat_rate).timeout 
			played_cards.clear()
			turn_ended.emit(curr_turn)
			player.end_turn()
			
			await get_tree().create_timer(GlobalAudioManager.curr_beat_rate * 2.0).timeout
			player_total_score += player_temp_score * combo_score
			reset_combo()
			p_score_settled.emit(player_total_score)
			player_temp_score = 0.0
			p_score_updated.emit(0.0)
			reset_resources()
			
			curr_turn = TurnType.ENEMY
			
			execute_turn()
		TurnType.ENEMY:
			for enemy: Enemy in enemies:
				enemy.execute_turn()
				
			turn_ended.emit(curr_turn)
			
			for enemy: Enemy in enemies:
				enemy.end_turn()
				
			hand.raise_hand()
			curr_turn = TurnType.PLAYER
			
	curr_phase = PhaseType.CARD
	
func reset_resources():
	curr_resources = max_resources
	resource_updated.emit(curr_resources)
	
func pop_op_queue():
	if player_temp2_score:
		player_temp_score = settle_score(player_temp_score, player_temp2_score, curr_op)
		player_temp2_score = 0.0
		p_score_updated.emit(player_temp_score)
		p_temp_op_updated.emit(0)
		p_temp_score_updated.emit(0.0)
	
	if op_queue.is_empty():
		return
		
	var val: Array = op_queue.pop_back()
	curr_temp_score_partition = val[1]
	curr_op = val[0]
	print("curr op ", curr_op)
	if is_main_op(curr_op):
		p_op_updated.emit(curr_op)
	else:
		p_temp_op_updated.emit(curr_op)	

func settle_score(old_score: float, new_score: float, op: Effect.OperatorType):
	match op:
		Effect.OperatorType.ADD:
			old_score += new_score
		Effect.OperatorType.SUBTRACT:
			old_score -= new_score
		Effect.OperatorType.MULTIPLY:
			old_score *= new_score
		Effect.OperatorType.DIVIDE:
			old_score /= new_score
			
	return old_score
				
func play_card(card_renderer: CardRenderer2D) -> bool:
	if curr_turn != TurnType.PLAYER or card_renderer.card.cost > curr_resources:
		return false
	
	subtract_resources(card_renderer.card.cost)
	played_cards.append(card_renderer)
	card_played.emit(card_renderer)
	
	return true

func subtract_resources(amount: int):
	curr_resources -= amount
	resource_updated.emit(curr_resources)

func add_resources(amount: int):
	curr_resources += amount
	resource_updated.emit(curr_resources)
	
func update_resources(amount: int):
	curr_resources = amount
	resource_updated.emit(curr_resources)

func play_beat_track(card: Card):
	var beat_track: BeatTrack = card.beat_track
	print('playing beat track ', beat_track.beat_num)
	if not beat_track:
		return
		
	GlobalAudioManager.set_bpm(beat_track.bpm)

	await play_example_beats(beat_track)
	can_hit = true
	
	var first: bool = true
	
	for repetitions: int in beat_track.repetitions:
		var count: int = 1
		
		while(true):
			var note: Note = beat_track.get_curr_beat()
			
			if note:
				late_flag = false
				is_next_note_scoring = note.is_scoring
				if is_next_note_scoring:
					nearest_note = note
			else:
				is_next_note_scoring = false
			
			if not first:
				await GlobalAudioManager.quarter_beat_played
			
			first = false
			
			if note:
				
				if not note.is_scoring:
					note_played.emit(note)
					display_count.emit(count)
				count += 1
				note.play()
				
			was_last_note_scoring = is_next_note_scoring
			if was_last_note_scoring:
				nearest_note = note
				late_flag = true
					
			if not beat_track.increment_beat(): 
				print("break")
				beat_track.reset_beat()
				break

	can_hit = false
	track_ended.emit()
	
	
func play_example_beats(beat_track: BeatTrack): 
	await GlobalAudioManager.quarter_beat_played
	
	var target: int = beat_track.example_beat_num / beat_track.example_speed_scale
	for repetition: int in beat_track.example_repetitions:
		for num: int in target:
			var index: int = (num * beat_track.example_speed_scale) % beat_track.beat_num
			var val: String
			
			var comparison_val = (beat_track.example_repetitions - 1) * (target - 1)
			#if num * repetition == comparison_val:
				#val = "GO!"
			#elif num * repetition == comparison_val - 1:
				#val = "SET"
			#elif num * repetition == comparison_val - 2:
				#val = "READY"
			#else:
			val = str(num + 1)
			
			if index < beat_track.set_beats.size() and beat_track.get_beat(index):
				example_note_played.emit(str(val), beat_track.get_beat(index).is_scoring)
			else:
				example_note_played.emit(str(val), false)
				
			for i in beat_track.example_speed_scale:
				await GlobalAudioManager.quarter_beat_played
				#if num + 1 == target and repetition + 1 == beat_track.example_repetitions:
					#num += 1
					#example_note_played.emit("", false)
	
	example_note_played.emit("", false)
	

func _input(event: InputEvent) -> void:
	if can_hit and event.is_action_pressed("select"):
		handle_hit()
	
func handle_hit():
	#if nearest_note:
		#nearest_note.play()
	
	var acc: float;
	if is_next_note_scoring:
		acc = GlobalAudioManager.distance_to_quarter_beat()
	elif was_last_note_scoring:
		acc = -GlobalAudioManager.distance_from_quarter_beat()
	elif late_flag:
		note_hit.emit(AccType.LATE)
		return
	else:
		note_hit.emit(AccType.EARLY)
		return
	
	note_hit.emit(get_acc_type(acc), acc > 0.0)
	
func get_acc_type(time_diff: float) -> AccType:
	if time_diff >= 1.0:
		return AccType.EARLY
	elif time_diff > -1.0:
		add_player_score(1.0)
		return AccType.PERFECT
	
	return AccType.LATE
	
func on_note_hit(acc_type: AccType, ):
	match acc_type:
		AccType.PERFECT:
			add_combo()
		_:
			reset_combo()
	
func add_combo():
	combo_score += 0.5
	combo_updated.emit(combo_score)
	
func reset_combo():
	combo_score = 1.0
	combo_updated.emit(1.0)
			
func is_player_card_phase() -> bool:
	return curr_phase == PhaseType.CARD and curr_turn == TurnType.PLAYER
	
func is_player_dance_phase() -> bool:
	return curr_phase == PhaseType.DANCE and curr_turn == TurnType.PLAYER
