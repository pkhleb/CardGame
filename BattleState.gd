class_name BattleState

const HAND_SIZE := 5

var battle_over: bool

var player_hp: int
var player_block: int
var player_energy: int
var player_max_energy: int

var enemy_hp: int
var enemy_block: int
var enemy_intent: String
var enemy_stunned: bool
var enemy_attack_damage: int

var draw_pile: Array[CardInstance] = []
var discard_pile: Array[CardInstance] = []
var hand: Array[CardInstance] = []

var message: String

func setup_battle(player_hp_max: int, player_energy_max: int, enemy_hp_max: int, enemy_atk_dmg: int) -> void:
	battle_over = false
	
	player_max_energy = player_energy_max
	player_hp = player_hp_max
	player_block = 0
	player_energy = 0
	
	enemy_hp = enemy_hp_max
	enemy_block = 0
	enemy_stunned = false
	enemy_attack_damage = enemy_atk_dmg
	update_enemy_intent()
	
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
	message = "Battle started"
	
func make_card(card_data: CardData) -> CardInstance:
	return CardInstance.new(card_data)
	
	
func start_player_turn() -> void:
	if is_battle_over():
		return
		
	player_block = 0
	player_energy = player_max_energy
	update_enemy_intent()

	draw_cards(HAND_SIZE - hand.size())
	message="Player turn"
	
func end_player_turn() -> void:
	if is_battle_over():
		return
		
	discard_hand()
	enemy_turn()
	
func enemy_turn() -> void:
	if is_battle_over():
		return
	if enemy_stunned:
		message = "Enemy is stunned and skips its turn"
		enemy_stunned = false
		update_enemy_intent()
		start_player_turn()
		return

	message = "Enemy attacks for %d" % enemy_attack_damage
	damage_player(enemy_attack_damage)
	
	if is_battle_over():
		return
		
	start_player_turn()
	
func damage_player(amount: int) -> void:
	var remaining_damage := amount

	if player_block > 0:
		var blocked = min(player_block, remaining_damage)
		player_block -= blocked
		remaining_damage -= blocked

	player_hp -= remaining_damage
	if player_hp < 0:
		player_hp = 0

	check_battle_end()
	
func play_card(card: CardInstance) -> void:
	if is_battle_over():
		return

	if not can_afford(card):
		message = "Not enough energy for %s" % card.get_name()
		return

	spend_energy(card.cost)

	match card.get_type():
		CardData.CardType.ATTACK:
			damage_enemy(card.value)
			if not is_battle_over():
				message = "%s deals %d damage" % [card.get_name(), card.value]

		CardData.CardType.DEFEND:
			player_block += card.value
			message = "%s gives %d block" % [card.get_name(), card.value]

		CardData.CardType.STUN:
			enemy_stunned = true
			update_enemy_intent()
			message = "%s stuns the enemy" % card.get_name()

		_:
			message = "Unknown card type"
			return

	discard_card_from_hand(card)

func can_afford(card: CardInstance) -> bool:
	return player_energy >= card.cost
	
func spend_energy(amount: int) -> void:
	player_energy -= amount
	if player_energy < 0:
		player_energy = 0
		
func damage_enemy(amount: int) -> void:
	var remaining_damage := amount

	if enemy_block > 0:
		var blocked = min(enemy_block, remaining_damage)
		enemy_block -= blocked
		remaining_damage -= blocked

	enemy_hp -= remaining_damage
	if enemy_hp < 0:
		enemy_hp = 0

	check_battle_end()

func discard_hand() -> void:
	for card in hand:
		discard_pile.append(card)

	hand.clear()
	
func draw_cards(amount: int) -> void:
	for i in amount:
		draw_one_card()

func draw_one_card() -> void:
	if draw_pile.is_empty():
		reshuffle_discard_into_draw()

	if draw_pile.is_empty():
		return

	var card: CardInstance = draw_pile.pop_back()
	hand.append(card)
	
func discard_card_from_hand(card: CardInstance) -> void:
	hand.erase(card)
	discard_pile.append(card)
		
func reshuffle_discard_into_draw() -> void:
	if discard_pile.is_empty():
		return

	draw_pile = discard_pile.duplicate()
	discard_pile.clear()
	draw_pile.shuffle()

func check_battle_end() -> bool:
	if enemy_hp <= 0:
		battle_over = true
		hand.clear()
		message="You win!"
		return true

	if player_hp <= 0:
		battle_over = true
		hand.clear()
		message = "You lose!"
		return true

	return false

func is_battle_over() -> bool:
	return battle_over

func update_enemy_intent() -> void:
	if enemy_stunned:
		enemy_intent = "Stunned"
	else:
		enemy_intent = "Attack %d" % enemy_attack_damage
