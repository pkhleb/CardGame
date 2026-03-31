extends Control

const BATTLE_SCENE := preload("res://battle.tscn")

var player_deck: Array[CardData] = []
var current_battle

func _ready() -> void:
	build_starting_deck()
	start_battle()

func build_starting_deck() -> void:
	player_deck.clear()
	
	var attack_data: CardData = load("res://cards/attack_card.tres")
	var defend_data: CardData = load("res://cards/defend_card.tres")
	var stun_data: CardData = load("res://cards/stun_card.tres")
	
	for i in 4:
		player_deck.append(attack_data)
	for i in 4:
		player_deck.append(defend_data)
	for i in 2:
		player_deck.append(stun_data)

func start_battle() -> void:
	if current_battle != null:
		current_battle.queue_free()
		current_battle = null
	
	current_battle = BATTLE_SCENE.instantiate()
	add_child(current_battle)
	
	current_battle.start_battle_with_deck(player_deck)
