extends Button
class_name CardUI

signal card_selected(card_data: CardData)

var card_data: CardData

func setup(data: CardData) -> void:
	card_data = data
	update_text()

func update_text() -> void:
	if card_data == null:
		text = "No Card"
		return

	text = "%s\nCost: %d\n%s" % [
		card_data.name,
		card_data.cost,
		card_data.description
	]

func _pressed() -> void:
	emit_signal("card_selected", card_data)
