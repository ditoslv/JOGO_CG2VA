extends Control


@onready var label_pontuacao = $VBoxContainer/LabelPontuacao
@onready var label_acertos = $VBoxContainer/LabelAcertos
@onready var label_erros = $VBoxContainer/LabelErros
@onready var label_precisao = $VBoxContainer/LabelPrecisao
@onready var label_cronometro = $VBoxContainer/LabelCronometro


var tempo_decorrido: float = 0.0
var cronometro_ativo: bool = true


func _ready() -> void:
	ScoreSystem.score_updated.connect(_atualizar_hud)
	_atualizar_hud(ScoreSystem.obter_resultado_final())

	label_cronometro.text = "Tempo: 0.0s"


func _process(delta: float) -> void:
	if cronometro_ativo:
		tempo_decorrido += delta
		label_cronometro.text = "Tempo: %.1fs" % tempo_decorrido


func _atualizar_hud(dados: Dictionary) -> void:
	label_pontuacao.text = "Pontos: %d" % dados["pontuacao"]
	label_acertos.text = "Acertos: %d" % dados["acertos"]
	label_erros.text = "Erros: %d" % dados["erros"]
	label_precisao.text = "Precisão: %.0f%%" % (dados["precisao"] * 100)


func iniciar_cronometro() -> void:
	tempo_decorrido = 0.0
	cronometro_ativo = true


func parar_cronometro() -> void:
	cronometro_ativo = false


func obter_tempo() -> float:
	return tempo_decorrido
