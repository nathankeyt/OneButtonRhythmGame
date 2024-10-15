extends Node

enum BeatType {NONE, STANDARD}
enum TurnType {PLAYER = 0, ENEMY = 1}

var curr_turn: TurnType = TurnType.PLAYER

var played_cards: Array[CardRenderer2D]

var max_resources: int = 5
@onready var curr_resources: int = max_resources

var deck: Deck2D
var hand: Hand2D

var dance_grid: DanceGrid

var player: Player
var enemies: Array[Enemy]

var player_temp_score: int = 0
var player_total_score: int = 0
var enemy_temp_score: int = 0
var enemy_total_score: int = 0

signal player_score_updated(score: int)
signal enemy_score_updated(score: int)
signal player_score_settled(score: int)
signal enemy_score_settled(score: int)

signal card_played(card_renderer: CardRenderer2D)
signal turn_ended(turn_type: TurnType)

signal resource_updated(amount: int)

signal note_played(beat_type: BeatType)
signal track_ended

func add_player_score(score: int):
	player_temp_score += score
	player_score_updated.emit(player_temp_score)

func add_enemy_score(score: int):
	enemy_temp_score += score
	enemy_score_updated.emit(enemy_temp_score)
	
func add_enemy(new_enemy: Enemy):
	enemies.append(new_enemy)

func execute_turn():
	match curr_turn:
		TurnType.PLAYER:
			player.execute_turn()
			
			
			for card_renderer: CardRenderer2D in played_cards:
				var card: Card = card_renderer.card
				
				play_beat_track(card.beat_track)
				card_renderer.hide()
				await track_ended
				
				card.apply_effects()
			
			turn_ended.emit(curr_turn)
			curr_turn = TurnType.ENEMY
		TurnType.ENEMY:
			for enemy: Enemy in enemies:
				enemy.execute_turn()
			turn_ended.emit(curr_turn)
			curr_turn = TurnType.PLAYER
				
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

func play_beat_track(beat_track: BeatTrack):
	if not beat_track:
		return
		
	while(true):
		await GlobalAudioManager.beat_played
		var beat_type: BeatType = beat_track.get_curr_beat()
		match beat_type:
			BeatType.NONE:
				pass
			_:
				note_played.emit(beat_type)
				
		if not beat_track.increment_beat(): break
	
			
