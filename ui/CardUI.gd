extends Button
class_name CardUI

signal card_selected(card_instance)

var card_instance: CardInstance

func setup(instance: CardInstance) -> void:
	card_instance = instance
	update_text()

func update_text() -> void:
	if card_instance == null:
		text = "No Card"
		return

	text = "%s\nCost: %d\n%s" % [
		card_instance.get_name(),
		card_instance.cost,
		card_instance.get_description()
	]

func _pressed() -> void:
	if card_instance == null:
		push_error("CardUI pressed with null card_instance")
		return

	card_selected.emit(card_instance)
