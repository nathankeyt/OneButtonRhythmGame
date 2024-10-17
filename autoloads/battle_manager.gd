extends Node

enum BeatType {NONE, STANDARD}
enum TurnType {PLAYER = 0, ENEMY = 1}
enum PhaseType {CARD = 0, DANCE = 1}

var curr_turn: TurnType = TurnType.PLAYER
var curr_phase: PhaseType = PhaseType.CARD

var played_cards: Array[CardRenderer2D]

var max_resources: int = 5
@onready var curr_resources: int = max_resources

var deck: Deck2D
var hand: Hand2D

var dance_grid: DanceGrid

var player: Player
var enemies: Array[Enemy]

var player_temp_score: float = 0
var player_temp2_score: float = 0
var player_total_score: float = 0
var enemy_temp_score: float = 0
var enemy_temp2_score: float = 0
var enemy_total_score: float = 0

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

signal resource_updated(amount: int)

signal note_played(beat_type: BeatType, beat_value: int)
signal track_ended

var curr_op: Effect.OperatorType = 0

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
				
				get_tree().create_timer(dance_grid.get_note_travel_time()).timeout.connect(pop_op_queue)
				card.apply_effects()

			played_cards.clear()
			await get_tree().create_timer(dance_grid.get_note_travel_time()).timeout 
			turn_ended.emit(curr_turn)
			player.end_turn()
			
			await get_tree().create_timer(GlobalAudioManager.curr_beat_rate * 2.0).timeout
			player_total_score += player_temp_score
			p_score_settled.emit(player_total_score)
			player_temp_score = 0.0
			p_score_updated.emit(0.0)
			
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
	
func pop_op_queue():
	if player_temp2_score:
		player_temp_score = settle_score(player_temp_score, player_temp2_score, curr_op)
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
		
	while(true):
		await GlobalAudioManager.beat_played
		var beat_type: BeatType = beat_track.get_curr_beat()
		match beat_type:
			BeatType.NONE:
				pass
			_:
				print(beat_type)
				note_played.emit(beat_type)
				
		if not beat_track.increment_beat(): 
			print("break")
			break
	
	track_ended.emit()
			
func is_player_card_phase() -> bool:
	return curr_phase == PhaseType.CARD and curr_turn == TurnType.PLAYER
	
func is_player_dance_phase() -> bool:
	return curr_phase == PhaseType.DANCE and curr_turn == TurnType.PLAYER
