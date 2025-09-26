extends Control

func _ready() -> void:
	# Mostra o resultado armazenado no singleton
	$ResultLabel.text = str(Global.result)

	# Configura os textos dos botões
	$PlayAgainButton.text = "Jogar Novamente"
	$BackButton.text = "Voltar ao Menu"

	# Aplica o mesmo estilo dos botões do MainMenu
	setup_enhanced_button($PlayAgainButton, "Jogar Novamente", Color(0.2, 0.9, 0.2), "▶")
	setup_enhanced_button($BackButton, "Voltar ao Menu", Color(0.2, 0.7, 0.9), "⏎")

	# Conecta os sinais
	$PlayAgainButton.pressed.connect(_on_play_again_pressed)
	$BackButton.pressed.connect(_on_back_pressed)

	# Conecta efeitos de hover
	$PlayAgainButton.mouse_entered.connect(_on_button_hover.bind($PlayAgainButton))
	$PlayAgainButton.mouse_exited.connect(_on_button_unhover.bind($PlayAgainButton))
	$BackButton.mouse_entered.connect(_on_button_hover.bind($BackButton))
	$BackButton.mouse_exited.connect(_on_button_unhover.bind($BackButton))


func _on_play_again_pressed() -> void:
	animate_button_press($PlayAgainButton)
	await get_tree().change_scene_to_file("res://Scenes/Game.tscn")


func _on_back_pressed() -> void:
	animate_button_press($BackButton)
	await get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


# Função reaproveitada do MainMenu para aplicar estilo avançado aos botões
func setup_enhanced_button(button: Button, text: String, color: Color, icon: String = "") -> void:
	button.text = icon + " " + text if icon else text
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_font_size_override("font_size", 28)

	button.add_theme_constant_override("outline_size", 3)
	button.add_theme_color_override("font_outline_color", Color.BLACK)

	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_color = Color.WHITE
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	button.add_theme_stylebox_override("normal", style)

	var hover_style = style.duplicate()
	hover_style.bg_color = color.lightened(0.2)
	button.add_theme_stylebox_override("hover", hover_style)

	var pressed_style = style.duplicate()
	pressed_style.bg_color = color.darkened(0.2)
	button.add_theme_stylebox_override("pressed", pressed_style)


# --- EFEITOS DE HOVER ---
func _on_button_hover(button: Button) -> void:
	var tween = create_tween().set_parallel()
	tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "rotation_degrees", 5, 0.3).set_trans(Tween.TRANS_SINE)


func _on_button_unhover(button: Button) -> void:
	var tween = create_tween().set_parallel()
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "rotation_degrees", 0, 0.3).set_trans(Tween.TRANS_SINE)


# --- ANIMAÇÃO DE CLIQUE ---
func animate_button_press(button: Button) -> void:
	var press_tween = create_tween().set_parallel()
	press_tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.1)
	press_tween.tween_callback(func():
		var release_tween = create_tween().set_parallel()
		release_tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)
	)
