extends Control

signal reward_selected(card_data: CardData)
signal reward_skipped

const CARD_UI_SCENE := preload("res://ui/CardUI.tscn")

@onready var reward_container: HBoxContainer = $MarginContainer/VBoxContainer/RewardContainer
@onready var skip_button: Button = $MarginContainer/VBoxContainer/SkipButton

var reward_cards: Array[CardData] = []

func _ready() -> void:
	skip_button.pressed.connect(_on_skip_button_pressed)
	
func setup_rewards(cards: Array[CardData]) -> void:
	reward_cards = cards.duplicate()
	refresh_rewards()
	
func refresh_rewards() -> void:
	for child in reward_container.get_children():
		child.queue_free()
		
	for card_data in reward_cards:
		var card_ui = CARD_UI_SCENE.instantiate()
		reward_container.add_child(card_ui)
		
		var temp_instance = CardInstance.new(card_data)
		card_ui.setup(temp_instance)
		card_ui.card_selected.connect(_on_card_selected.bind(card_data))
		
func _on_card_selected(_instance: CardInstance, card_data: CardData) -> void:
	reward_selected.emit(card_data)
	
func _on_skip_button_pressed() -> void:
	reward_skipped.emit()
