extends HBoxContainer

func _ready() -> void:
	BattleManager.card_played.connect(add_card)
	BattleManager.turn_ended.connect(empty)

func add_card(card_renderer: CardRenderer2D) -> void:
	var new_center_container = CenterContainer.new()
	add_child(new_center_container)
	
	card_renderer.reparent(new_center_container, false)
	print("added")

func empty(turn_type: BattleManager.TurnType):
	print("empty")
	for card: Node in get_children():
		card.queue_free()
