extends Node2D
class_name SoloMode

## Modo Solo:
## controla a sequência das fases, mas reutiliza toda a lógica
## de mira, disparo, alvos e pontuação da GameBase.

@export var fases: Array[FaseConfig] = []

@onready var _game_base: GameBase = $GameBase

var _indice_fase: int = 0


func _ready() -> void:
	_game_base.fase_concluida.connect(_on_fase_concluida)
	iniciar_rodada()


func iniciar_rodada() -> void:
	if fases.is_empty():
		push_warning("SoloMode: nenhuma fase configurada no Inspector.")
		return

	_indice_fase = 0
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
	var resultado: Dictionary = ScoreSystem.obter_resultado_final()

	GameManager.registrar_resultado_solo(resultado)
	GameManager.ir_para_resultado()
