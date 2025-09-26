# Game.gd
extends Node2D

const CardScene = preload("res://Scenes/Card.tscn")

var card_textures = {}
var player_cards: Array = []
var bot_cards: Array = []
var player_score: int = 0
var bot_score: int = 0
var round_number: int = 1
const MAX_WINS := 5

@onready var player_card_container = $Control/PlayerHand
@onready var bot_card_container = $Control/BotHand
@onready var round_label = $Control/RoundLabel
@onready var back_button = $Control/BackButton
@onready var player_play_pos = $PlayerPlayPosition
@onready var bot_play_pos = $BotPlayPosition

func _ready() -> void:
	await ready
	load_card_textures()
	randomize()
	start_game()
	back_button.pressed.connect(_on_back_pressed)

func load_card_textures():
	for i in range(1, 51):
		var path_pos = "res://Assets/Cards/Numbers/numero_%d.png" % i
		var path_neg = "res://Assets/Cards/Numbers/numero_neg_%d.png" % i
		if FileAccess.file_exists(path_pos): card_textures[i] = load(path_pos)
		if FileAccess.file_exists(path_neg): card_textures[-i] = load(path_neg)
	var special_multiply_path = "res://Assets/Cards/Specials/multiply_2.png"
	var special_divide_path = "res://Assets/Cards/Specials/divide_2.png"
	if FileAccess.file_exists(special_multiply_path): card_textures["multiply_2"] = load(special_multiply_path)
	if FileAccess.file_exists(special_divide_path): card_textures["divide_2"] = load(special_divide_path)

func start_game():
	player_score = 0
	bot_score = 0
	round_number = 1
	deal_cards()
	update_ui()

func deal_cards():
	var all_cards = []
	for i in range(-50, 51):
		if i != 0 and card_textures.has(i):
			all_cards.append({"value": i, "type": "number", "is_special": false, "texture": card_textures[i]})
	if card_textures.has("multiply_2"):
		all_cards.append({"value": 2, "type": "multiply", "is_special": true, "display_text": "x2", "texture": card_textures["multiply_2"]})
	if card_textures.has("divide_2"):
		all_cards.append({"value": 2, "type": "divide", "is_special": true, "display_text": "÷2", "texture": card_textures["divide_2"]})
	all_cards.shuffle()
	var num_cards_per_player = 7
	player_cards = all_cards.slice(0, num_cards_per_player)
	bot_cards = all_cards.slice(num_cards_per_player, num_cards_per_player * 2)

func update_ui():
	player_card_container.visible = true
	bot_card_container.visible = true
	round_label.text = "Rodada %d | Jogador: %d vs Bot: %d" % [round_number, player_score, bot_score]
	clear_children(player_card_container)
	clear_children(bot_card_container)
	for card_data in player_cards:
		var card = CardScene.instantiate()
		player_card_container.add_child(card)
		card.setup(card_data)
		card.card_pressed.connect(_on_player_card_selected)
	for card_data in bot_cards:
		var card = CardScene.instantiate()
		bot_card_container.add_child(card)
		card.setup(card_data)
		card.hide_card()

# --- FUNÇÃO _on_player_card_selected TOTALMENTE REFEITA ---
func _on_player_card_selected(player_card_data: Dictionary) -> void:
	# Encontra a INSTÂNCIA da carta na tela que corresponde aos DADOS recebidos
	var player_card_instance: Control
	for card in player_card_container.get_children():
		if card.card_data == player_card_data:
			player_card_instance = card
			break

	# Se, por algum motivo, a carta não for encontrada, interrompe a função
	if not is_instance_valid(player_card_instance):
		print("ERRO: Instância da carta do jogador não encontrada!")
		return

	player_card_container.visible = false
	bot_card_container.visible = false

	var bot_hand = bot_card_container.get_children()
	var random_index = randi() % bot_hand.size()
	var bot_card_instance = bot_hand[random_index]
	var bot_card_data = bot_card_instance.card_data
	
	player_card_container.remove_child(player_card_instance)
	bot_card_container.remove_child(bot_card_instance)
	add_child(player_card_instance)
	add_child(bot_card_instance)
	
	var tween = create_tween().set_parallel()
	tween.tween_property(player_card_instance, "global_position", player_play_pos.global_position, 0.4).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(bot_card_instance, "global_position", bot_play_pos.global_position, 0.4).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	
	bot_card_instance.reveal()
	await get_tree().create_timer(0.5).timeout

	var player_final_value: float
	var bot_final_value: float
	
	if player_card_data.type == "number" and bot_card_data.type == "number":
		player_final_value = player_card_data.value
		bot_final_value = bot_card_data.value
	else:
		var p_val = player_card_data.value if player_card_data.type == "number" else 0
		var b_val = bot_card_data.value if bot_card_data.type == "number" else 0
		if player_card_data.type == "multiply": b_val *= player_card_data.value
		elif player_card_data.type == "divide": b_val /= float(player_card_data.value)
		if bot_card_data.type == "multiply": p_val *= bot_card_data.value
		elif bot_card_data.type == "divide": p_val /= float(bot_card_data.value)
		player_final_value = p_val
		bot_final_value = b_val

	var winner_text: String
	if player_final_value > bot_final_value:
		player_score += 1
		winner_text = "Jogador venceu a rodada!"
	elif bot_final_value > player_final_value:
		bot_score += 1
		winner_text = "Bot venceu a rodada!"
	else:
		winner_text = "Empate na rodada!"

	round_label.text = "Você: %.1f vs Bot: %.1f | %s" % [player_final_value, bot_final_value, winner_text]
	await get_tree().create_timer(2.5).timeout

	player_card_instance.queue_free()
	bot_card_instance.queue_free()
	player_cards.erase(player_card_data)
	bot_cards.erase(bot_card_data)

	if player_score >= MAX_WINS or bot_score >= MAX_WINS or player_cards.is_empty():
		end_game()
	else:
		round_number += 1
		update_ui()

func end_game():
	get_tree().change_scene_to_file("res://Scenes/Results.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func clear_children(node: Node):
	if is_instance_valid(node):
		for child in node.get_children():
			child.queue_free()
