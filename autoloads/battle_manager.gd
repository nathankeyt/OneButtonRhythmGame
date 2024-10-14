extends Node

enum TurnType {PLAYER, ENEMY}

var deck: Deck2D
var hand: Hand2D

var player_temp_score: int = 0
var player_total_score: int = 0
var enemy_temp_score: int = 0
var enemy_total_score: int = 0

signal player_score_updated(score: int)
signal enemy_score_updated(score: int)
signal player_score_settled(score: int)
signal enemy_score_settled(score: int)

func add_player_score(score: int):
	player_temp_score += score
	player_score_updated.emit(player_temp_score)

func add_enemy_score(score: int):
	enemy_temp_score += score
	enemy_score_updated.emit(enemy_temp_score)
	
