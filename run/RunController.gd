extends Control

const BATTLE_SCENE := preload("res://battle.tscn")
const CARD_REWARD_SCENE := preload("res://CardReward.tscn")

var player_deck: Array[CardData] = []
var current_battle
var current_reward

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
	clear_current_scene()
	
	current_battle = BATTLE_SCENE.instantiate()
	add_child(current_battle)
	
	current_battle.start_battle_with_deck(player_deck)
	
	current_battle.battle_won.connect(_on_battle_won)
	current_battle.battle_lost.connect(_on_battle_lost)
	
	
func _on_battle_won() -> void:
	show_reward_scene()
	
func _on_battle_lost() -> void:
	print("Game Over")

func show_reward_scene() -> void:
	clear_current_scene()
	
	current_reward = CARD_REWARD_SCENE.instantiate()
	add_child(current_reward)
	
	var rewards = generate_reward_cards()
	current_reward.setup_rewards(rewards)
	
	current_reward.reward_selected.connect(_on_reward_selected)
	current_reward.reward_skipped.connect(_on_reward_skipped)
	
func generate_reward_cards() -> Array[CardData]:
	var attack_data: CardData = load("res://cards/attack_card.tres")
	var defend_data: CardData = load("res://cards/defend_card.tres")
	var stun_data: CardData = load("res://cards/stun_card.tres")
	
	return [attack_data, defend_data, stun_data]
	
func _on_reward_selected(card_data: CardData) -> void:
	player_deck.append(card_data)
	start_battle()
	
func _on_reward_skipped() -> void:
	start_battle()

func clear_current_scene() -> void:
	if current_battle != null:
		current_battle.queue_free()
		current_battle = null
	
	if current_reward != null:
		current_reward.queue_free()
		current_reward = null
