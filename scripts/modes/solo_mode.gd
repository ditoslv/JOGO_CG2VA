extends Node2D
class_name SoloMode

## Orquestra as fases do Modo Solo em cima da GameBase compartilhada.
## Não reimplementa mira, disparo, alvo nem pontuação — só decide
## QUANDO avançar de fase e QUANDO a rodada termina.
##
## O 1v1 (VersusMode, futuro) vai reaproveitar exatamente essa mesma
## cena/lógica duas vezes, com a mesma lista de fases, em vez de
## duplicar isso aqui.

## Arraste os .tres de Resources/Fases/, NA ORDEM, no Inspector.
## Fica de fora do .tscn de propósito: hoje existem fases 3 e 6
## duplicadas no projeto (fase_03_rapidos_menores vs
## fase_03_translacao_rapida, fase_06_combinado vs fase_06_combinacao)
## — escolha uma versão de cada com a equipe antes de preencher isto.
@export var fases: Array[FaseConfig] = []

@onready var _game_base: GameBase = $GameBase
@onready var _result_screen: Control = $ResultScreen

var _indice_fase: int = 0


func _ready() -> void:
	_result_screen.visible = false
	_game_base.fase_concluida.connect(_on_fase_concluida)
	iniciar_rodada()


## Ponto de entrada público. O VersusMode (1v1) também pode chamar
## isto duas vezes, uma por jogador, desde que troque a lista de
## `fases` (mesma configuração) entre as duas chamadas.
func iniciar_rodada() -> void:
	if fases.is_empty():
		push_warning("SoloMode: nenhuma fase configurada no Inspector.")
		return

	_indice_fase = 0
	_result_screen.visible = false
	_game_base.resetar_rodada()
	_iniciar_fase_atual()


func _iniciar_fase_atual() -> void:
	if _indice_fase >= fases.size():
		_finalizar_rodada()
		return
	_game_base.iniciar_fase(fases[_indice_fase])


func _on_fase_concluida() -> void:
	_indice_fase += 1
	_iniciar_fase_atual()


func _finalizar_rodada() -> void:
	var resultado := ScoreSystem.obter_resultado_final()
	_result_screen.visible = true

	# Chamada defensiva: result_screen.gd ainda não tem esse método
	# (a Pessoa 2 vai adicionar). Sem essa checagem, o Solo quebraria
	# até lá. Assim que ela implementar mostrar_resultado(dados), o
	# Solo passa a alimentar a tela automaticamente, sem eu tocar
	# neste arquivo de novo.
	if _result_screen.has_method("mostrar_resultado"):
		_result_screen.mostrar_resultado(resultado)
	else:
		push_warning("SoloMode: ResultScreen ainda não implementa mostrar_resultado(dados).")
