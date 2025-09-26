extends Node2D

# Menu final - versão simples e sem erros
# Evita problemas com funções lambda aninhadas

# Variáveis para controle do gradiente
var gradient_colors: Array = []
var current_gradient_index: int = 0
var background_rect: ColorRect

# Chamado quando a cena é carregada
func _ready() -> void:
	# Verificar se os nós existem
	if not $TitleLabel or not $PlayButton or not $OptionsButton or not $QuitButton:
		print("Erro: Alguns nós não foram encontrados!")
		return
	
	setup_background()
	setup_ui()
	setup_animations()
	setup_connections()
	setup_hover_effects()

# Configurar background com gradiente
func setup_background() -> void:
	# Criar um ColorRect para o background se não existir
	background_rect = $Background
	if not background_rect:
		background_rect = ColorRect.new()
		background_rect.name = "Background"
		background_rect.anchors_preset = Control.PRESET_FULL_RECT
		add_child(background_rect)
		move_child(background_rect, 0)  # Mover para o fundo
	
	# Configurar cores do gradiente
	gradient_colors = [
		Color(0.1, 0.1, 0.3),  # Azul escuro
		Color(0.2, 0.1, 0.4),  # Roxo escuro
		Color(0.1, 0.2, 0.4),  # Azul médio
		Color(0.2, 0.2, 0.5),  # Roxo médio
		Color(0.1, 0.3, 0.5),  # Azul claro
		Color(0.2, 0.3, 0.6)   # Roxo claro
	]
	
	# Iniciar com a primeira cor
	background_rect.color = gradient_colors[0]
	
	# Iniciar timer para mudança de cor
	start_gradient_timer()

# Iniciar timer para gradiente
func start_gradient_timer() -> void:
	var timer = Timer.new()
	timer.name = "GradientTimer"
	timer.wait_time = 4.0
	timer.timeout.connect(_on_gradient_timer_timeout)
	timer.autostart = true
	add_child(timer)

# Quando o timer do gradiente expira
func _on_gradient_timer_timeout() -> void:
	if not background_rect or not is_inside_tree():
		return
	
	# Próxima cor
	current_gradient_index = (current_gradient_index + 1) % gradient_colors.size()
	var next_color = gradient_colors[current_gradient_index]
	
	# Animar transição
	var tween = create_tween()
	tween.tween_property(background_rect, "color", next_color, 2.0)

# Configurar a interface com estilo melhorado
func setup_ui() -> void:
	# Configurar título com efeito especial
	$TitleLabel.text = "BATALHA MATEMÁTICA"
	$TitleLabel.add_theme_color_override("font_color", Color(0, 0, 0)) # Preto
	$TitleLabel.add_theme_font_size_override("font_size", 64)
	$TitleLabel.add_theme_constant_override("outline_size", 6)
	$TitleLabel.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	
	# Centralizar o título horizontalmente
	$TitleLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$TitleLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Configurar botões com estilo aprimorado
	setup_enhanced_button($PlayButton, "JOGAR", Color(0.2, 0.9, 0.2), "▶")
	setup_enhanced_button($OptionsButton, "CONFIGURAÇÕES", Color(0.2, 0.7, 0.9), "⚙")
	setup_enhanced_button($QuitButton, "SAIR", Color(0.9, 0.2, 0.2), "✕")

# Configurar botão com estilo aprimorado
func setup_enhanced_button(button: Button, text: String, color: Color, icon: String = "") -> void:
	button.text = icon + " " + text if icon else text
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_font_size_override("font_size", 28)
	
	# Estilo do botão com bordas
	button.add_theme_constant_override("outline_size", 3)
	button.add_theme_color_override("font_outline_color", Color.BLACK)
	
	# Cores de fundo com gradiente visual
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = Color.WHITE
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_right = 5
	style.corner_radius_bottom_left = 5
	button.add_theme_stylebox_override("normal", style)

	var hover_style = style.duplicate()
	hover_style.bg_color = color.lightened(0.2)
	button.add_theme_stylebox_override("hover", hover_style)

	var pressed_style = style.duplicate()
	pressed_style.bg_color = color.darkened(0.2)
	button.add_theme_stylebox_override("pressed", pressed_style)

# Configurar animações dramáticas
func setup_animations() -> void:
	# Centralizar o título na tela
	var screen_center_x = get_viewport().size.x / 2
	$TitleLabel.position.x = screen_center_x - ($TitleLabel.size.x / 2)
	
	# Iniciar elementos fora da tela
	$TitleLabel.position.y = -300
	$TitleLabel.modulate.a = 0.0
	$PlayButton.position.y = 1200
	$OptionsButton.position.y = 1200
	$QuitButton.position.y = 1200
	$PlayButton.modulate.a = 0.0
	$OptionsButton.modulate.a = 0.0
	$QuitButton.modulate.a = 0.0
	
	# Animar entrada
	animate_entrance()

# Animar entrada dos elementos com efeitos especiais
func animate_entrance() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Centralizar o título na posição final
	var screen_center_x = get_viewport().size.x / 2
	var final_x = screen_center_x - ($TitleLabel.size.x / 2)
	
	# Título desce com efeito de bounce
	tween.tween_property($TitleLabel, "position:y", 80, 1.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property($TitleLabel, "position:x", final_x, 1.5)
	tween.tween_property($TitleLabel, "modulate:a", 1.0, 1.0)
	
	# Botões sobem sequencialmente
	tween.tween_property($PlayButton, "position:y", 250, 1.0).set_delay(0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property($PlayButton, "modulate:a", 1.0, 0.5).set_delay(0.5)
	
	tween.tween_property($OptionsButton, "position:y", 330, 1.0).set_delay(0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property($OptionsButton, "modulate:a", 1.0, 0.5).set_delay(0.7)
	
	tween.tween_property($QuitButton, "position:y", 410, 1.0).set_delay(0.9).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property($QuitButton, "modulate:a", 1.0, 0.5).set_delay(0.9)

# Configurar conexões dos botões
func setup_connections() -> void:
	$PlayButton.pressed.connect(_on_play_pressed)
	$OptionsButton.pressed.connect(_on_options_pressed)
	$QuitButton.pressed.connect(_on_quit_pressed)

# Configurar efeitos de hover aprimorados
func setup_hover_effects() -> void:
	$PlayButton.mouse_entered.connect(_on_button_hover.bind($PlayButton))
	$PlayButton.mouse_exited.connect(_on_button_unhover.bind($PlayButton))
	
	$OptionsButton.mouse_entered.connect(_on_button_hover.bind($OptionsButton))
	$OptionsButton.mouse_exited.connect(_on_button_unhover.bind($OptionsButton))
	
	$QuitButton.mouse_entered.connect(_on_button_hover.bind($QuitButton))
	$QuitButton.mouse_exited.connect(_on_button_unhover.bind($QuitButton))

# Efeito de hover nos botões
func _on_button_hover(button: Button) -> void:
	var tween = create_tween().set_parallel()
	tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "rotation_degrees", 5, 0.3).set_trans(Tween.TRANS_SINE)

# Efeito de saída do hover
func _on_button_unhover(button: Button) -> void:
	var tween = create_tween().set_parallel()
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "rotation_degrees", 0, 0.3).set_trans(Tween.TRANS_SINE)

# --- FUNÇÃO CORRIGIDA ---
# Animação de clique no botão
func animate_button_press(button: Button) -> void:
	# Primeiro tween: animação de pressionar
	var press_tween = create_tween().set_parallel()
	press_tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.1)
	
	# Ao terminar, chama o callback para criar o segundo tween
	press_tween.tween_callback(func():
		# Segundo tween: animação de soltar (retorno ao normal)
		var release_tween = create_tween().set_parallel()
		release_tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)
	)

# Quando clicar em "Jogar"
func _on_play_pressed() -> void:
	animate_button_press($PlayButton)
	
	# Efeito de transição dramática
	var tween = create_tween().set_parallel()
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.8)
	
	# Espera a animação terminar antes de mudar de cena
	await tween.finished
	
	if FileAccess.file_exists("res://Scenes/Game.tscn"):
		get_tree().change_scene_to_file("res://Scenes/Game.tscn")
	else:
		print("Arquivo Game.tscn não encontrado!")
		modulate.a = 1.0
		scale = Vector2.ONE

# Quando clicar em "Configurações"
func _on_options_pressed() -> void:
	animate_button_press($OptionsButton)
	print("Abrindo Configurações...")
	# Aqui você pode adicionar a lógica para abrir a cena de opções
	# Ex: get_tree().change_scene_to_file("res://Options.tscn")

# Quando clicar em "Sair"
func _on_quit_pressed() -> void:
	animate_button_press($QuitButton)
	
	# Efeito de transição antes de sair
	var tween = create_tween().set_parallel()
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.8)
	
	# Espera a animação terminar antes de fechar o jogo
	await tween.finished
	get_tree().quit()

# Efeitos contínuos
func _process(_delta: float) -> void:
	# Efeito sutil de pulsação no título
	if $TitleLabel:
		var time = Time.get_ticks_msec() / 1000.0
		var pulse = sin(time * 2.0) * 0.02 + 1.0
		$TitleLabel.scale = Vector2(pulse, pulse)
