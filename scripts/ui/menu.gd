extends Control


func _ready() -> void:
	# Garante que o menu esteja pronto para receber os cliques.
	pass


# Botão Modo Solo
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/modes/solo_mode.tscn")


# Botão Modo 1v1
func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/modes/versus_mode.tscn")


# Botão Modo Ordem do Alvo
func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/modes/order_mode.tscn")
