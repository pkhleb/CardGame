extends Control

const CARD_UI_SCENE := preload("res://ui/CardUI.tscn")

@onready var player_hp_label: Label = $MarginContainer/VBoxContainer/PlayerPanel/VBoxContainer/PlayerHPLabel
@onready var player_block_label: Label = $MarginContainer/VBoxContainer/PlayerPanel/VBoxContainer/PlayerBlockLabel
@onready var enemy_hp_label: Label = $MarginContainer/VBoxContainer/EnemyPanel/VBoxContainer/EnemyHPLabel
@onready var enemy_intent_label: Label = $MarginContainer/VBoxContainer/EnemyPanel/VBoxContainer/EnemyIntentLabel
@onready var enemy_block_label: Label = $MarginContainer/VBoxContainer/EnemyPanel/VBoxContainer/EnemyBlockLabel
@onready var energy_label: Label = $MarginContainer/VBoxContainer/EnergyLabel
@onready var message_label: Label = $MarginContainer/VBoxContainer/MessageLabel
@onready var restart_button: Button = $MarginContainer/VBoxContainer/RestartButton
@onready var end_turn_button: Button = $MarginContainer/VBoxContainer/EndTurnButton
@onready var hand_container: HBoxContainer = $MarginContainer/VBoxContainer/HandPanel/ScrollContainer/HandContainer
@onready var draw_pile_label: Label = $MarginContainer/VBoxContainer/DrawPileLabel
@onready var discard_pile_label: Label = $MarginContainer/VBoxContainer/DiscardPileLabel

var battle_over: bool

const PLAYER_MAX_HP := 40
const PLAYER_MAX_ENERGY := 3
const ENEMY_MAX_HP := 30
const ENEMY_ATTACK_DAMAGE := 6
const HAND_SIZE := 5

var player_hp: int
var player_block: int
var player_energy: int

var enemy_hp: int
var enemy_block: int
var enemy_intent: String
var enemy_stunned: bool

var draw_pile: Array[CardInstance] = []
var discard_pile: Array[CardInstance] = []
var hand: Array[CardInstance] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	restart_button.pressed.connect(_on_restart_button_pressed)
	end_turn_button.pressed.connect(_on_end_turn_pressed)

	setup_battle()
	start_player_turn()
	set_message("Player turn")
	refresh_hand_ui()
	
func _on_card_selected(card: CardInstance) -> void:
	play_card(card)

func setup_battle() -> void:
	battle_over = false
	end_turn_button.disabled = false
	
	player_hp = PLAYER_MAX_HP
	player_block = 0
	player_energy = 0

	enemy_hp = ENEMY_MAX_HP
	enemy_block = 0
	enemy_stunned = false
	update_enemy_intent()
	enemy_intent = "Attack %d" % ENEMY_ATTACK_DAMAGE

	draw_pile.clear()
	discard_pile.clear()
	hand.clear()

	var attack_data: CardData = load("res://cards/attack_card.tres")
	var defend_data: CardData = load("res://cards/defend_card.tres")
	var stun_data: CardData = load("res://cards/stun_card.tres")

	for i in 4:
		draw_pile.append(make_card(attack_data))
	for i in 4:
		draw_pile.append(make_card(defend_data))
	for i in 2:
		draw_pile.append(make_card(stun_data))

	draw_pile.shuffle()

	set_message("Battle started")
	
func is_battle_over() -> bool:
	return battle_over
	
func check_battle_end() -> bool:
	if enemy_hp <= 0:
		battle_over = true
		hand.clear()
		end_turn_button.disabled = true
		refresh_hand_ui()
		refresh_ui()
		set_message("You win!")
		return true

	if player_hp <= 0:
		battle_over = true
		hand.clear()
		end_turn_button.disabled = true
		refresh_hand_ui()
		refresh_ui()
		set_message("You lose!")
		return true

	return false

func reshuffle_discard_into_draw() -> void:
	if discard_pile.is_empty():
		return

	draw_pile = discard_pile.duplicate()
	discard_pile.clear()
	draw_pile.shuffle()

func make_card(card_data: CardData) -> CardInstance:
	return CardInstance.new(card_data)

func draw_one_card() -> void:
	if draw_pile.is_empty():
		reshuffle_discard_into_draw()

	if draw_pile.is_empty():
		return

	var card: CardInstance = draw_pile.pop_back()
	hand.append(card)
	
func draw_cards(amount: int) -> void:
	for i in amount:
		draw_one_card()

	refresh_ui()
	refresh_hand_ui()
	
func discard_hand() -> void:
	for card in hand:
		discard_pile.append(card)

	hand.clear()
	refresh_ui()
	refresh_hand_ui()
	
func discard_card_from_hand(card: CardInstance) -> void:
	hand.erase(card)
	discard_pile.append(card)
	refresh_ui()
	refresh_hand_ui()
	
func play_card(card: CardInstance) -> void:
	if is_battle_over():
		return

	if not can_afford(card):
		set_message("Not enough energy for %s" % card.get_name())
		return

	spend_energy(card.cost)

	match card.get_type():
		CardData.CardType.ATTACK:
			damage_enemy(card.value)
			if not is_battle_over():
				set_message("%s deals %d damage" % [card.get_name(), card.value])

		CardData.CardType.DEFEND:
			player_block += card.value
			set_message("%s gives %d block" % [card.get_name(), card.value])
			refresh_ui()

		CardData.CardType.STUN:
			enemy_stunned = true
			update_enemy_intent()
			set_message("%s stuns the enemy" % card.get_name())
			refresh_ui()

		_:
			set_message("Unknown card type")
			return

	discard_card_from_hand(card)

func start_player_turn() -> void:
	if is_battle_over():
		return
		
	player_block = 0
	player_energy = PLAYER_MAX_ENERGY
	update_enemy_intent()

	draw_cards(HAND_SIZE - hand.size())
	set_message("Player turn")
	refresh_ui()
	
func end_player_turn() -> void:
	if is_battle_over():
		return
		
	discard_hand()
	enemy_turn()
	
func enemy_turn() -> void:
	if is_battle_over():
		return
	if enemy_stunned:
		set_message("Enemy is stunned and skips its turn")
		enemy_stunned = false
		update_enemy_intent()
		refresh_ui()
		start_player_turn()
		return

	set_message("Enemy attacks for %d" % ENEMY_ATTACK_DAMAGE)
	damage_player(ENEMY_ATTACK_DAMAGE)
	
	if is_battle_over():
		return
		
	start_player_turn()

func refresh_ui() -> void:
	player_hp_label.text = "Player HP: %d" % player_hp
	player_block_label.text = "Block: %d" % player_block

	enemy_hp_label.text = "Enemy HP: %d" % enemy_hp
	enemy_block_label.text = "Block: %d" % enemy_block
	enemy_intent_label.text = "Intent: %s" % enemy_intent

	energy_label.text = "Energy: %d" % player_energy
	draw_pile_label.text = "Draw: %d" % draw_pile.size()
	discard_pile_label.text = "Discard: %d" % discard_pile.size()
	
func refresh_hand_ui() -> void:
	for child in hand_container.get_children():
		child.queue_free()

	for card in hand:
		var card_ui = CARD_UI_SCENE.instantiate()
		hand_container.add_child(card_ui)
		card_ui.setup(card)
		card_ui.disabled = battle_over
		card_ui.card_selected.connect(_on_card_selected)

func set_message(text: String) -> void:
	message_label.text = text
	
func damage_player(amount: int) -> void:
	var remaining_damage := amount

	if player_block > 0:
		var blocked = min(player_block, remaining_damage)
		player_block -= blocked
		remaining_damage -= blocked

	player_hp -= remaining_damage
	if player_hp < 0:
		player_hp = 0

	refresh_ui()
	check_battle_end()
	
func damage_enemy(amount: int) -> void:
	var remaining_damage := amount

	if enemy_block > 0:
		var blocked = min(enemy_block, remaining_damage)
		enemy_block -= blocked
		remaining_damage -= blocked

	enemy_hp -= remaining_damage
	if enemy_hp < 0:
		enemy_hp = 0

	refresh_ui()
	check_battle_end()

func update_enemy_intent() -> void:
	if enemy_stunned:
		enemy_intent = "Stunned"
	else:
		enemy_intent = "Attack %d" % ENEMY_ATTACK_DAMAGE
	
func gain_player_block(amount: int) -> void:
	player_block += amount
	refresh_ui()
	
func spend_energy(amount: int) -> void:
	player_energy -= amount
	if player_energy < 0:
		player_energy = 0
	refresh_ui()
	
func can_afford(card: CardInstance) -> bool:
	return player_energy >= card.cost
	

func _on_end_turn_pressed() -> void:
	if is_battle_over():
		return
	end_player_turn()

func _on_restart_button_pressed() -> void:
	setup_battle()
	start_player_turn()
