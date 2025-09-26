# Card.gd
extends Control

# O sinal agora emitirá um Dicionário (os dados da carta)
signal card_pressed(card_data)

@onready var card_back: TextureRect = $CardBack
@onready var art_texture: TextureRect = $ArtTexture

var card_data: Dictionary

func setup(data: Dictionary):
	self.card_data = data
	if data.has("texture"):
		art_texture.texture = data.texture
	card_back.visible = false
	art_texture.visible = true

func _ready():
	gui_input.connect(_on_gui_input)

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		# --- MUDANÇA CRÍTICA ---
		# Emite os DADOS da carta, não a instância do nó.
		emit_signal("card_pressed", card_data)

func hide_card():
	card_back.visible = true
	art_texture.visible = false

func reveal():
	if not card_back.visible: return
	var tween = create_tween()
	tween.tween_property(self, "scale:x", 0, 0.2).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		card_back.visible = false
		art_texture.visible = true
	)
	tween.chain().tween_property(self, "scale:x", 1, 0.2).set_trans(Tween.TRANS_SINE)

func disable_input():
	set_mouse_filter(MOUSE_FILTER_IGNORE)

func enable_input():
	set_mouse_filter(MOUSE_FILTER_PASS)
