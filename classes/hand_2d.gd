extends Node2D
class_name Hand2D

@export var cards: Array[CardRenderer2D]
@export var highlight_scale: float = 1.25
@export var max_hand_size: int = 5

@onready var display_path: Path2D = $DisplayPath
@onready var select_timer: Timer = $SelectTimer
@onready var select_bar: ProgressBar = $SelectBar

var selected_card: CardRenderer2D
var hover_index: int = -1

func _ready() -> void:
	BattleManager.hand = self
	render_cards()

func add_card(card: CardRenderer2D) -> void:
	if card:
		cards.push_back(card)
		render_cards()
	
func render_cards() -> void:
	var hand_size: int = cards.size()
	print(hand_size)
	var card_pos_arr: Array[Node] = display_path.get_children()
	var card_pos_arr_size: int = card_pos_arr.size()
	
	for i in hand_size:
		var card_pos: PathFollow2D
		if i >= card_pos_arr_size:
			card_pos = PathFollow2D.new()
		else:
			card_pos = card_pos_arr[i]
			
		var reverse_index: int = hand_size - 1 - i
		var curr_card: CardRenderer2D = cards[reverse_index]
		
		card_pos.progress_ratio = reverse_index * (1.0 / max_hand_size)
		print(curr_card.card.title, " ", i)
		display_path.add_child(card_pos)
		display_path.move_child(card_pos, 0)
		
		curr_card.show()
		curr_card.reparent(card_pos, false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		print('test')
		add_card(BattleManager.deck.pop_rendered())
			  
	if not cards.is_empty():
		if event.is_action_pressed("select"):
			select_timer.start()
			
		if event.is_action_released("select"):
			if not select_timer.is_stopped():
				select_timer.stop()
				select_bar.ratio = 0.0
				increment_hover()
			
func increment_hover() -> void:
	if cards.size() <= 0:
		hover_index = -1
		return
	
	if hover_index != -1:
		toggle_highlight_card(hover_index)
	hover_index = (hover_index + 1) % cards.size()
	toggle_highlight_card(hover_index)
		
func toggle_highlight_card(index: int) -> void:
	if cards.size() <= index:
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
	print("played " + card_renderer.card.title)
	card_renderer.card.apply_effects()
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
	if index == hover_index:
		increment_hover()
	
func _process(delta: float) -> void:
	var curr_time: float = select_timer.wait_time - select_timer.time_left
	if not select_timer.is_stopped() and curr_time > 0.1:
		select_bar.ratio = curr_time / select_timer.wait_time

func _on_select_timer_timeout() -> void:
	play_card(hover_index)
	select_bar.ratio = 0.0
