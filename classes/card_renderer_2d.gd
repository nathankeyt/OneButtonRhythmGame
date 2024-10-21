extends Area2D
class_name CardRenderer2D

@export var card: Card
@export var card_front: SubViewportContainer
@export var card_backing: SubViewportContainer
@export var img_sprite: Sprite2D
@export var title_label: RichTextLabel
@export var text_label: RichTextLabel
@export var cost_label: RichTextLabel

var is_flipped: bool = false

func _ready() -> void:
	render_card()

func set_card(new_card: Card):
	card = new_card
	render_card()

func set_img(img: ImageTexture) -> void:
	if img:
		img_sprite.texture = img
	
func set_title(title: String) -> void:
	title_label.text = "[center]" + title + "[/center]"
	
func set_text(text: String) -> void:
	text_label.text = text + "\n"
	
	if not card.score_effect:
		return
		
	var amount: float = card.score_effect.m_amount
	match card.score_effect.m_operator_type:
		Effect.OperatorType.ADD:
			text_label.text += "Add up to " + str(floor(amount)) + " score."
		Effect.OperatorType.MULTIPLY:
			text_label.text += "Add up to " + str(snapped(amount, 0.01)) + " multiplier."
	
func set_cost(cost: int) -> void:
	cost_label.text = str(cost)

func render_card() -> void:
	if card:
		set_img(card.img)
		set_title(card.title)
		set_text(card.text)
		set_cost(card.cost)
	
func flip_card(should_animate: bool = true, flip_speed: float = 0.25) -> void:
	var speed: float = (flip_speed * int(should_animate)) / 2.0
	var tween: Tween = create_tween()
	if is_flipped:
		tween.tween_property(card_backing, "material:shader_parameter/y_rot", int(is_flipped) * -90, speed)
	tween.tween_property(card_front, "material:shader_parameter/y_rot", int(not is_flipped) * 90, speed)
	if !is_flipped:
		tween.tween_property(card_backing, "material:shader_parameter/y_rot", int(is_flipped) * -90, speed)
	is_flipped = !is_flipped
	
