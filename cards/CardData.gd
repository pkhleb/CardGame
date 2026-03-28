extends Resource
class_name CardData

enum CardType {
	ATTACK,
	DEFEND,
	STUN
}

@export var name: String = ""
@export var cost: int = 1
@export var card_type: CardType = CardType.ATTACK
@export var value: int = 0
@export var description: String = ""

func get_type_name() -> String:
	match card_type:
		CardType.ATTACK:
			return "Attack"
		CardType.DEFEND:
			return "Defend"
		CardType.STUN:
			return "Stun"
		_:
			return "Unknown"
