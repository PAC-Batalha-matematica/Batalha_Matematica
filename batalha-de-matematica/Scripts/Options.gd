extends Control

func _ready() -> void:
	$VBoxContainer/TitleLabel.text = "Configurações"
	$VBoxContainer/TipsCheckBox.text = "Mostrar dicas durante o jogo"
	$VBoxContainer/TipsCheckBox.button_pressed = Global.show_tips
	$VBoxContainer/TipsCheckBox.toggled.connect(_on_tips_toggled)
	$VBoxContainer/BackButton.text = "Voltar"
	$VBoxContainer/BackButton.pressed.connect(_on_back_pressed)

func _on_tips_toggled(button_pressed: bool) -> void:
	Global.show_tips = button_pressed

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
