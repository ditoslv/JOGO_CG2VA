extends Control

@onready var label_pontuacao = $VBoxContainer/LabelPontuacao
@onready var label_acertos = $VBoxContainer/LabelAcertos
@onready var label_erros = $VBoxContainer/LabelErros
@onready var label_precisao = $VBoxContainer/LabelPrecisao

func _ready() -> void:
	ScoreSystem.score_updated.connect(_atualizar_hud)
	_atualizar_hud(ScoreSystem.obter_resultado_final())


func _atualizar_hud(dados: Dictionary) -> void:
	label_pontuacao.text = "Pontos: %d" % dados["pontuacao"]
	label_acertos.text = "Acertos: %d" % dados["acertos"]
	label_erros.text = "Erros: %d" % dados["erros"]
	label_precisao.text = "Precisão: %.0f%%" % (dados["precisao"] * 100)
