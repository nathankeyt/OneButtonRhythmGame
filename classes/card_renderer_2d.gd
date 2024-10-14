extends Area2D
class_name CardRenderer2D

@export var card: Card

@onready var img_sprite: Sprite2D = $ImgSprite
@onready var title_label: RichTextLabel = $TitleLabel
@onready var text_label: RichTextLabel = $TextLabel
@onready var cost_label: RichTextLabel = $CostLabel

func _ready() -> void:
	render_card()

func set_card(new_card: Card):
	card = new_card
	render_card()

func set_img(img: ImageTexture) -> void:
	if img:
		img_sprite.texture = img
	
func set_title(title: String) -> void:
	title_label.text = title
	
func set_text(text: String) -> void:
	text_label.text = text
	
func set_cost(cost: int) -> void:
	cost_label.text = str(cost)

func render_card() -> void:
	if card:
		set_img(card.img)
		set_title(card.title)
		set_text(card.text)
		set_cost(card.cost)
	
