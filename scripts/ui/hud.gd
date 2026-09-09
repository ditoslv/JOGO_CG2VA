extends Control

@onready var painel_pontuacao: NinePatchRect = $Camada/PainelPontuacao
@onready var label_pontuacao = $Camada/PainelPontuacao/VBoxContainer/LabelPontuacao
@onready var label_acertos = $Camada/PainelPontuacao/VBoxContainer/LabelAcertos
@onready var label_erros = $Camada/PainelPontuacao/VBoxContainer/LabelErros
@onready var label_precisao = $Camada/PainelPontuacao/VBoxContainer/LabelPrecisao
@onready var label_cronometro: Label = $Camada/PainelPontuacao/VBoxContainer/LabelCronometro
@onready var label_notificacao_fase: Label = $Camada/LabelNotificacaoFase
@onready var timer_notificacao_fase: Timer = $Camada/TimerNotificacaoFase

## Margem (em pixels) entre o painel e a borda direita/superior da tela.
@export var margem_borda: float = 20.0


func _ready() -> void:
	_posicionar_painel_no_canto_superior_direito()
	ScoreSystem.score_updated.connect(_atualizar_hud)
	_atualizar_hud(ScoreSystem.obter_resultado_final())

	label_notificacao_fase.visible = false
	timer_notificacao_fase.timeout.connect(_ocultar_notificacao_fase)

	# Antes ficava escondido (visible = false) e nunca era atualizado —
	# por isso "o cronômetro não contava". Como o ScoreSystem agora
	# mantém o tempo decorrido da rodada, o label pode ficar visível e
	# ser atualizado a cada frame em _process().
	label_cronometro.visible = true
	_atualizar_cronometro()


## Atualiza a cada frame, e não só quando o placar muda (score_updated),
## porque o tempo passa mesmo quando ninguém acerta ou erra nada.
func _process(_delta: float) -> void:
	_atualizar_cronometro()


func _atualizar_cronometro() -> void:
	label_cronometro.text = "Tempo: %.1fs" % ScoreSystem.obter_tempo_decorrido()

## Usada pelo SoloMode/GameBase pra saber onde NÃO nascer alvos.
## Retângulo em coordenadas globais, com a mesma margem usada pra
## posicionar o painel — assim ele não fica colado na borda do painel.
func obter_area_ocupada() -> Rect2:
	return Rect2(
		painel_pontuacao.position - Vector2(margem_borda, margem_borda),
		painel_pontuacao.size + Vector2(margem_borda, margem_borda) * 2.0
	)

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


## Chamada pelo SoloMode sempre que uma fase termina e outra começa.
## Mostra o texto no canto superior esquerdo por 3 segundos (sem
## contagem de tempo visível) e depois esconde sozinha.
## Se o texto vier vazio, não mostra nada (ex.: fase sem mensagem).
func mostrar_notificacao_fase(texto: String) -> void:
	if texto.is_empty():
		return

	label_notificacao_fase.text = texto
	label_notificacao_fase.visible = true
	timer_notificacao_fase.start()


func _ocultar_notificacao_fase() -> void:
	label_notificacao_fase.visible = false


func _atualizar_hud(dados: Dictionary) -> void:
	label_pontuacao.text = "Pontos: %d" % dados["pontuacao"]
	label_acertos.text = "Acertos: %d" % dados["acertos"]
	label_erros.text = "Erros: %d" % dados["erros"]
	label_precisao.text = "Precisão: %.0f%%" % (dados["precisao"] * 100)
