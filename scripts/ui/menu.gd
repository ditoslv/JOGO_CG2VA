extends Control

## ============================================================
## Menu principal — seleção de modo.
## Os caminhos de Solo e 1v1 apontam para as cenas que o
## Integrante A ainda vai criar (SoloMode.tscn / VersusMode.tscn,
## conforme a Seção G.2 do planejamento). Combine com ele o nome
## e o caminho exatos antes de testar esses dois botões — se os
## arquivos ainda não existirem, o Godot vai acusar erro ao trocar
## de cena, o que é esperado até lá.
## ============================================================

const CENA_SOLO := "res://scenes/modes/SoloMode.tscn"
const CENA_1V1 := "res://scenes/modes/VersusMode.tscn"
const CENA_ORDEM_DO_ALVO := "res://scenes/modes/order_mode.tscn"


func _ready() -> void:
	pass


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(CENA_SOLO)


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file(CENA_1V1)


func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file(CENA_ORDEM_DO_ALVO)
