extends Node2D
class_name Hand2D

@export var cards: Array[CardRenderer2D]
@export var highlight_scale: float = 1.25
@export var highlight_shift: float = 100.0
@export var highlight_speed: float = 0.1
@export var max_hand_size: int = 5
@export var starter_draw_size: int = 5
@export var select_threshold: float = 0.15

@export var draw_length: float = 0.25
@export var draw_delay: float = 0.1

@export var battle_song: BattleSong

@export var hand_lower_distance: float = 300.0
@export var hand_lower_time: float = 0.5

@onready var display_path: Path2D = $DisplayPath
@onready var select_timer: Timer = $SelectTimer
@onready var select_bar: ProgressBar = $SelectBar
@onready var execute_turn_button: Button = $ExecuteTurnButton

var selected_card: CardRenderer2D
var hover_index: int = -1

func _init() -> void:
	BattleManager.hand = self

func _ready() -> void:
	render_cards()
	draw_cards(starter_draw_size)
	GlobalAudioManager.play_battle_song(battle_song, 2.0)

func add_card(card: CardRenderer2D) -> void:
	if card:
		if hover_index == cards.size():
			hover_index += 1
		cards.push_back(card)
		render_cards()

func render_cards() -> void:
	var hand_size: int = cards.size()
	var last_index: int = hand_size - 1
	var increment: float = 1.0 / max_hand_size
	var card_pos_arr: Array[Node] = display_path.get_children()
	var card_pos_arr_size: int = card_pos_arr.size()
	
	for i in hand_size:
		var card_pos: PathFollow2D
		var reverse_index: int = last_index - i
		var curr_card: CardRenderer2D = cards[reverse_index]
		
		if reverse_index >= card_pos_arr_size:
			card_pos = PathFollow2D.new()
		else:
			card_pos = card_pos_arr[reverse_index]
			
		var new_progress_ratio =  0.5 + (((last_index / 2.0) - i) * increment)
		
		if reverse_index >= card_pos_arr_size:
			display_path.add_child(card_pos)
			card_pos.progress_ratio = new_progress_ratio
			curr_card.show()
			var tween: Tween = create_tween()
			tween.tween_property(curr_card, "global_position", card_pos.global_position, draw_length)
			
			tween.tween_callback(curr_card.reparent.bind(card_pos, false))
			tween.tween_callback(func(): curr_card.position = Vector2.ZERO)
			curr_card.flip_card(true, draw_length)
		else:
			var tween: Tween = create_tween()
			tween.tween_property(card_pos, "progress_ratio", new_progress_ratio, draw_length)
			tween.tween_callback(curr_card.reparent.bind(card_pos, false))
			#card_pos.progress_ratio = 0.5 + (((last_index / 2.0) - i) * increment)
			#curr_card.reparent(card_pos, false)
			
		display_path.move_child(card_pos, 0)

func lower_hand() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(display_path, "position:y", display_path.position.y + hand_lower_distance, hand_lower_time).set_ease(Tween.EASE_IN_OUT)

func raise_hand() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(display_path, "position:y", display_path.position.y - hand_lower_distance, hand_lower_time).set_ease(Tween.EASE_IN_OUT)

func _input(event: InputEvent) -> void:
	if BattleManager.is_player_card_phase():
		if event.is_action_pressed("select"):
			select_timer.start()
			
		if event.is_action_released("select"):
			if not select_timer.is_stopped():
				if get_time_in(select_timer) < select_threshold:
					increment_hover()
					
				select_timer.stop()
				select_bar.ratio = 0.0

func increment_hover() -> void:
	if cards.size() <= 0:
		return
	
	if hover_index != -1:
		toggle_highlight_card(hover_index)
	hover_index = (hover_index + 1) % (cards.size() + 1)
	toggle_highlight_card(hover_index)

func toggle_highlight_card(index: int) -> void:
	if cards.size() < index:
		return
		
	if cards.size() == index:
		if execute_turn_button.has_focus():
			execute_turn_button.release_focus()
		else:
			execute_turn_button.grab_focus()
		return 
		
	var card: CardRenderer2D = cards[index]
	var tween: Tween = create_tween()
	
	if card.z_index:
		tween.parallel().tween_property(card, "scale", Vector2.ONE, highlight_speed)
		tween.parallel().tween_property(card, "position:y", card.position.y + highlight_shift, highlight_speed)
		card.z_index = 0
	else:
		tween.parallel().tween_property(card, "scale", Vector2.ONE * highlight_scale, highlight_speed)
		tween.parallel().tween_property(card, "position:y", card.position.y - highlight_shift, highlight_speed)
		card.z_index = 1

func play_card(index: int) -> void:
	if index < 0 or cards.size() <= index:
		return
		
	var card_renderer: CardRenderer2D = cards[index]
		
	if not BattleManager.play_card(card_renderer):
		return
		
	remove_card(index)

func remove_card(index: int) -> void:
	var card_pos_arr: Array[Node] = display_path.get_children()
	var card_pos: Node = card_pos_arr[index]
	
	display_path.remove_child(card_pos)
	card_pos.queue_free()
	cards.remove_at(index)
	
	print(cards)
	print(display_path.get_children())
	render_cards()
	
	toggle_highlight_card(index)

func _process(delta: float) -> void:
	var curr_time: float = get_time_in(select_timer)
	if not select_timer.is_stopped() and curr_time > select_threshold and hover_index != -1:
		select_bar.ratio = (curr_time - select_threshold) / (select_timer.wait_time - select_threshold)

func _on_select_timer_timeout() -> void:
	if hover_index == cards.size():
		BattleManager.execute_turn()
	else:
		play_card(hover_index)
	
	select_bar.ratio = 0.0

func get_time_in(timer: Timer):
	return timer.wait_time - timer.time_left

func draw_cards(num: int) -> void:
	for i in num:
		draw_card()
		await get_tree().create_timer(draw_delay).timeout

func draw_card() -> void:
	add_card(BattleManager.deck.pop_rendered())
