extends Control

signal tempo_esgotado

@onready var label_pontuacao: Label = $VBoxContainer/LabelPontuacao
@onready var label_acertos: Label = $VBoxContainer/LabelAcertos
@onready var label_erros: Label = $VBoxContainer/LabelErros
@onready var label_precisao: Label = $VBoxContainer/LabelPrecisao
@onready var label_cronometro: Label = $VBoxContainer/LabelCronometro

var _tempo_restante: float = 0.0
var _cronometro_ativo: bool = false


func _ready() -> void:
	ScoreSystem.score_updated.connect(_atualizar_hud)
	_atualizar_hud(ScoreSystem.obter_resultado_final())
	_atualizar_label_cronometro()


func _process(delta: float) -> void:
	if not _cronometro_ativo:
		return

	_tempo_restante = max(0.0, _tempo_restante - delta)
	_atualizar_label_cronometro()

	if _tempo_restante <= 0.0:
		_cronometro_ativo = false
		tempo_esgotado.emit()


## Chamar a partir do modo de jogo (Solo, 1v1 ou Ordem do Alvo) para iniciar
## uma contagem regressiva. Ex.: hud.iniciar_cronometro(60.0)
func iniciar_cronometro(segundos: float) -> void:
	_tempo_restante = segundos
	_cronometro_ativo = true
	_atualizar_label_cronometro()


func parar_cronometro() -> void:
	_cronometro_ativo = false


func tempo_restante() -> float:
	return _tempo_restante


func _atualizar_label_cronometro() -> void:
	if label_cronometro:
		label_cronometro.text = "Tempo: %d s" % ceil(_tempo_restante)


func _atualizar_hud(dados: Dictionary) -> void:
	label_pontuacao.text = "Pontos: %d" % dados["pontuacao"]
	label_acertos.text = "Acertos: %d" % dados["acertos"]
	label_erros.text = "Erros: %d" % dados["erros"]
	label_precisao.text = "Precisão: %.0f%%" % (dados["precisao"] * 100)
