extends Node
## Autoload. Registrar em: Project Settings > Autoload
##   Path: res://scripts/Managers/GameManager.gd
##   Node Name: GameManager
##
## Guarda o resultado da rodada que acabou de terminar (Solo ou 1v1) para que
## a ResultScreen consiga ler os dados depois da troca de
## cena — o ScoreSystem sozinho não é suficiente pra isso porque ele é
## resetado a cada nova rodada.

var modo_atual: String = ""
var resultado_jogador_1: Dictionary = {}
var resultado_jogador_2: Dictionary = {}


## Chamar ao final do Modo Solo (ou de qualquer modo de 1 jogador).
func registrar_resultado_solo(resultado: Dictionary) -> void:
	modo_atual = "solo"
	resultado_jogador_1 = resultado
	resultado_jogador_2 = {}


## Chamar ao final do Modo 1v1, depois das duas execuções do Solo.
func registrar_resultado_versus(resultado_p1: Dictionary, resultado_p2: Dictionary) -> void:
	modo_atual = "1v1"
	resultado_jogador_1 = resultado_p1
	resultado_jogador_2 = resultado_p2


func ir_para_resultado() -> void:
	print("GameManager: tentando trocar de cena para result_screen.tscn")
	var erro = get_tree().change_scene_to_file("res://scenes/ui/result_screen.tscn")
	print("GameManager: change_scene_to_file retornou erro código ", erro)


func voltar_ao_menu() -> void:
	modo_atual = ""
	resultado_jogador_1 = {}
	resultado_jogador_2 = {}
	get_tree().change_scene_to_file("res://main.tscn")
