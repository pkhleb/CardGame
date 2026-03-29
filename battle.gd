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

var state: BattleState

const PLAYER_MAX_HP := 40
const PLAYER_MAX_ENERGY := 3
const ENEMY_MAX_HP := 30
const ENEMY_ATTACK_DAMAGE := 6
const HAND_SIZE := 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	restart_button.pressed.connect(_on_restart_button_pressed)
	end_turn_button.pressed.connect(_on_end_turn_pressed)

	state = BattleState.new()
	setup_battle()
	state.start_player_turn()
	refresh_all()
	
func _on_card_selected(card: CardInstance) -> void:
	state.play_card(card)
	refresh_all()

func setup_battle() -> void:
	state.setup_battle(PLAYER_MAX_HP, PLAYER_MAX_ENERGY, ENEMY_MAX_HP, ENEMY_ATTACK_DAMAGE)
	refresh_all()

func refresh_ui() -> void:
	end_turn_button.disabled = state.is_battle_over()
	player_hp_label.text = "Player HP: %d" % state.player_hp
	player_block_label.text = "Block: %d" % state.player_block

	enemy_hp_label.text = "Enemy HP: %d" % state.enemy_hp
	enemy_block_label.text = "Block: %d" % state.enemy_block
	enemy_intent_label.text = "Intent: %s" % state.enemy_intent

	energy_label.text = "Energy: %d" % state.player_energy
	draw_pile_label.text = "Draw: %d" % state.draw_pile.size()
	discard_pile_label.text = "Discard: %d" % state.discard_pile.size()
	
	message_label.text = state.message
	
func refresh_hand_ui() -> void:
	for child in hand_container.get_children():
		child.queue_free()

	for card in state.hand:
		var card_ui = CARD_UI_SCENE.instantiate()
		hand_container.add_child(card_ui)
		card_ui.setup(card)
		card_ui.disabled = state.battle_over
		card_ui.card_selected.connect(_on_card_selected)
		
func refresh_all() -> void:
	refresh_ui()
	refresh_hand_ui()

func _on_end_turn_pressed() -> void:
	if state.is_battle_over():
		return
	state.end_player_turn()
	refresh_all()

func _on_restart_button_pressed() -> void:
	setup_battle()
	state.start_player_turn()
	refresh_all()
