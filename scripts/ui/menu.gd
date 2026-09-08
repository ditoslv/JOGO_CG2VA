extends Control


func _ready() -> void:
	pass


func _on_button_pressed() -> void:
	# TODO: trocar para o Modo Solo quando a cena SoloMode.tscn
	# (Integrante A) estiver pronta:
	# get_tree().change_scene_to_file("res://scenes/modes/solo_mode.tscn")
	print("Modo Solo ainda não está disponível.")


func _on_button_2_pressed() -> void:
	# TODO: trocar para o Modo 1v1 quando a cena VersusMode.tscn
	# (Integrante A, apoio B) estiver pronta:
	# get_tree().change_scene_to_file("res://scenes/modes/versus_mode.tscn")
	print("Modo 1v1 ainda não está disponível.")


func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/modes/order_mode.tscn")
