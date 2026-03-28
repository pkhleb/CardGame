extends Button
class_name CardUI

signal card_selected(card_instance)

var card_instance: CardInstance
var hover_tween: Tween

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup(instance: CardInstance) -> void:
	card_instance = instance
	update_text()
	update_style()
	await get_tree().process_frame
	pivot_offset = size / 2

func update_text() -> void:
	if card_instance == null:
		text = "No Card"
		return

	text = "%s\nCost: %d\n%s" % [
		card_instance.get_name(),
		card_instance.cost,
		card_instance.get_description()
	]

func update_style() -> void:
	if card_instance == null:
		return

	match card_instance.get_type():
		CardData.CardType.ATTACK:
			modulate = Color(1.0, 0.9, 0.9)
		CardData.CardType.DEFEND:
			modulate = Color(0.9, 0.95, 1.0)
		CardData.CardType.STUN:
			modulate = Color(0.95, 0.9, 1.0)
		_:
			modulate = Color(1, 1, 1)

func _pressed() -> void:
	if card_instance == null:
		push_error("CardUI pressed with null card_instance")
		return

	card_selected.emit(card_instance)

func _on_mouse_entered() -> void:
	z_index = 10
	animate_scale(Vector2(1.08, 1.08))

func _on_mouse_exited() -> void:
	z_index = 10
	animate_scale(Vector2(1.0, 1.0))

func animate_scale(target_scale: Vector2) -> void:
	if hover_tween != null:
		hover_tween.kill()

	hover_tween = create_tween()
	hover_tween.tween_property(self, "scale", target_scale, 0.12)
