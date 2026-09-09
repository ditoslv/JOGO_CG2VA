extends Node2D
class_name SoloMode

## Modo Solo:
## controla a sequência das fases, mas reutiliza toda a lógica
## de mira, disparo, alvos e pontuação da GameBase.

@export var fases: Array[FaseConfig] = []

@onready var _game_base: GameBase = $GameBase
@onready var _hud: Control = $HUD

var _indice_fase: int = 0



func _ready() -> void:
	_game_base.definir_area_excluida(_obter_area_do_hud())
	_game_base.fase_concluida.connect(_on_fase_concluida)
	iniciar_rodada()


## Repassa a área do painel de estatísticas pro Spawner evitar nascer
## alvos ali. Se a Pessoa 2 ainda não tiver adicionado
## obter_area_ocupada() no hud.gd, cai num retângulo aproximado no
## canto superior direito, do tamanho que o painel tem hoje — só pra
## não deixar de funcionar até ela atualizar o arquivo dela.
func _obter_area_do_hud() -> Rect2:
	if _hud.has_method("obter_area_ocupada"):
		return _hud.obter_area_ocupada()

	push_warning("SoloMode: hud.gd ainda não tem obter_area_ocupada(); usando um retângulo aproximado.")
	var tamanho := get_viewport_rect().size
	return Rect2(Vector2(tamanho.x - 260.0, 0.0), Vector2(260.0, 160.0))

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

	var fase: FaseConfig = fases[_indice_fase]
	_game_base.iniciar_fase(fase)
	_notificar_troca_de_fase(fase)


## Mostra por 3s, no canto superior esquerdo, a mensagem configurada na
## fase (fase.mensagem_notificacao) — tanto ao iniciar a fase 1 quanto
## nas trocas seguintes. Defensivo com has_method() pelo mesmo motivo
## de _obter_area_do_hud(): não quebra se o hud.gd ainda não tiver o
## método (ex.: versão desatualizada do arquivo da Pessoa 2).
func _notificar_troca_de_fase(fase: FaseConfig) -> void:
	if _hud.has_method("mostrar_notificacao_fase"):
		_hud.mostrar_notificacao_fase(fase.mensagem_notificacao)


func _on_fase_concluida() -> void:
	_indice_fase += 1
	_iniciar_fase_atual()


func _finalizar_rodada() -> void:
	var resultado: Dictionary = ScoreSystem.obter_resultado_final()

	GameManager.registrar_resultado_solo(resultado)
	GameManager.ir_para_resultado()
