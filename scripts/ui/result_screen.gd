extends Control

@onready var painel_jogador1: VBoxContainer = $PainelJogador1
@onready var painel_jogador2: VBoxContainer = $PainelJogador2
@onready var label_vencedor: Label = $LabelVencedor
@onready var botao_voltar: Button = $Button


func _ready() -> void:
	botao_voltar.pressed.connect(_on_voltar_pressed)

	# Comportamento padrão (Solo / Ordem do Alvo): mostra o resultado atual do ScoreSystem
	painel_jogador2.visible = false
	label_vencedor.visible = false
	exibir_resultado_single(ScoreSystem.obter_resultado_final())


## dados: Dictionary no formato de ScoreSystem.obter_resultado_final()
## tempo: tempo da rodada em segundos (opcional, -1.0 = não informado)
func exibir_resultado_single(dados: Dictionary, tempo: float = -1.0) -> void:
	_preencher_painel(painel_jogador1, dados, tempo)


## Usada pelo Modo 1v1 (Integrante A): recebe o resultado de cada jogador,
## mostra os dois painéis e aponta o vencedor por pontuação.
func exibir_resultado_versus(dados_jogador1: Dictionary, dados_jogador2: Dictionary,
		tempo1: float = -1.0, tempo2: float = -1.0) -> void:
	painel_jogador2.visible = true
	label_vencedor.visible = true

	_preencher_painel(painel_jogador1, dados_jogador1, tempo1)
	_preencher_painel(painel_jogador2, dados_jogador2, tempo2)

	if dados_jogador1["pontuacao"] > dados_jogador2["pontuacao"]:
		label_vencedor.text = "Vencedor: Jogador 1!"
	elif dados_jogador2["pontuacao"] > dados_jogador1["pontuacao"]:
		label_vencedor.text = "Vencedor: Jogador 2!"
	else:
		label_vencedor.text = "Empate!"


func _preencher_painel(painel: VBoxContainer, dados: Dictionary, tempo: float) -> void:
	painel.get_node("LabelPontuaçãoFinal").text = "Pontuação: %d" % dados["pontuacao"]
	painel.get_node("LabelAcertosFinal").text = "Acertos: %d" % dados["acertos"]
	painel.get_node("LabelErrosFinal").text = "Erros: %d" % dados["erros"]
	painel.get_node("LabelPrecisaoFinal").text = "Precisão: %.0f%%" % (dados["precisao"] * 100)
	if tempo >= 0.0:
		painel.get_node("LabelTempoFinal").text = "Tempo: %.1fs" % tempo
	else:
		painel.get_node("LabelTempoFinal").text = "Tempo: —"


func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/Menu.tscn")
