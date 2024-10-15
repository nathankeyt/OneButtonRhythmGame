extends Node2D
class_name Deck2D

@export var cards: Array[Card]
@export var card_renderer_scene: PackedScene

@onready var sprite: Sprite2D = $CardBacking

func _init() -> void:
	BattleManager.deck = self

func pop() -> Card:
	return cards.pop_front()
	
func pop_rendered() -> CardRenderer2D:
	if cards.is_empty():
		return null
		
	var card_renderer: CardRenderer2D = card_renderer_scene.instantiate()
	add_child(card_renderer)
	card_renderer.hide()
	card_renderer.set_card(pop())
	card_renderer.flip_card(false)
	return card_renderer
	
func push(card: Card) -> void:
	cards.push_back(card)

func shuffle() -> void:
	cards.shuffle()
