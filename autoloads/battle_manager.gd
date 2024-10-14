extends Node

@export var deck: Deck2D
@export var hand: Hand2D

var temp_score: int = 0
var total_score: int = 0

func add_score(score: int):
	temp_score += score
