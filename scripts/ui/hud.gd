extends Control

@onready var painel_pontuacao: NinePatchRect = $Camada/PainelPontuacao
@onready var label_pontuacao = $Camada/PainelPontuacao/VBoxContainer/LabelPontuacao
@onready var label_acertos = $Camada/PainelPontuacao/VBoxContainer/LabelAcertos
@onready var label_erros = $Camada/PainelPontuacao/VBoxContainer/LabelErros
@onready var label_precisao = $Camada/PainelPontuacao/VBoxContainer/LabelPrecisao

## Margem (em pixels) entre o painel e a borda direita/superior da tela.
@export var margem_borda: float = 20.0


func _ready() -> void:
	_posicionar_painel_no_canto_superior_direito()
	ScoreSystem.score_updated.connect(_atualizar_hud)
	_atualizar_hud(ScoreSystem.obter_resultado_final())


## Calculado em runtime (como o GameBase.gd já faz com a área de
## spawn) em vez de fixo no .tscn, porque o HUD não é esticado pra
## tela cheia — só assim o painel encosta na borda direita real,
## e não num ponto fixo que dependeria da resolução da janela.
func _posicionar_painel_no_canto_superior_direito() -> void:
	var tamanho_tela := get_viewport_rect().size
	painel_pontuacao.position = Vector2(
		tamanho_tela.x - painel_pontuacao.size.x - margem_borda,
		margem_borda
	)


func _atualizar_hud(dados: Dictionary) -> void:
	label_pontuacao.text = "Pontos: %d" % dados["pontuacao"]
	label_acertos.text = "Acertos: %d" % dados["acertos"]
	label_erros.text = "Erros: %d" % dados["erros"]
	label_precisao.text = "Precisão: %.0f%%" % (dados["precisao"] * 100)
