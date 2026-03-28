extends RefCounted
class_name CardInstance

var data: CardData
var cost: int
var value: int

func _init(card_data: CardData) -> void:
	data = card_data
	cost = card_data.cost
	value = card_data.value

func get_name() -> String:
	return data.name

func get_description() -> String:
	return data.description

func get_type() -> CardData.CardType:
	return data.card_type
	
