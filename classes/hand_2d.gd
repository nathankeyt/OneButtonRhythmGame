extends Node2D
class_name Hand2D

@export var cards: Array[CardRenderer2D]
@export var highlight_scale: float = 1.25
@export var max_hand_size: int = 5
@export var select_threshold: float = 0.15

@onready var display_path: Path2D = $DisplayPath
@onready var select_timer: Timer = $SelectTimer
@onready var select_bar: ProgressBar = $SelectBar
@onready var execute_turn_button: Button = $ExecuteTurnButton

var selected_card: CardRenderer2D
var hover_index: int = -1

func _ready() -> void:
	BattleManager.hand = self
	render_cards()

func add_card(card: CardRenderer2D) -> void:
	if card:
		if hover_index == cards.size():
			hover_index += 1
		cards.push_back(card)
		render_cards()
	
func render_cards() -> void:
	var hand_size: int = cards.size()
	var last_index: int = hand_size - 1
	var card_pos_arr: Array[Node] = display_path.get_children()
	var card_pos_arr_size: int = card_pos_arr.size()
	
	for i in hand_size:
		var card_pos: PathFollow2D
		if i >= card_pos_arr_size:
			card_pos = PathFollow2D.new()
		else:
			card_pos = card_pos_arr[i]
			
		display_path.add_child(card_pos)
		display_path.move_child(card_pos, 0)
			
		var curr_card: CardRenderer2D = cards[last_index - i]
		var increment: float = 1.0 / max_hand_size
		
		card_pos.progress_ratio = 0.5 + (((last_index / 2.0) - i) * increment)
		print(curr_card.card.title, " ", card_pos.progress_ratio)
		curr_card.show()
		curr_card.reparent(card_pos, false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		print('test')
		draw_card()
			  
	if not cards.is_empty():
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
		hover_index = -1
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
	if card.z_index:
		card.scale = Vector2.ONE * 1.0
		card.z_index = 0
	else:
		card.scale = Vector2.ONE * highlight_scale
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

func draw_cards(num: int):
	for i in num:
		draw_card()

func draw_card():
	add_card(BattleManager.deck.pop_rendered())
