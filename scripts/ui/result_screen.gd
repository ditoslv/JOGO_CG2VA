extends Control

@onready var painel_1: VBoxContainer = $PainelJogador1
@onready var painel_2: VBoxContainer = $PainelJogador2
@onready var label_vencedor: Label = $LabelVencedor
@onready var botao_voltar: Button = $Button


func _ready() -> void:
	botao_voltar.pressed.connect(_on_voltar_pressed)
	_exibir_resultado(GameManager.resultado_jogador_1, GameManager.resultado_jogador_2)


func _exibir_resultado(resultado_1: Dictionary, resultado_2: Dictionary) -> void:
	_preencher_painel(painel_1, resultado_1)

	if resultado_2.is_empty():
		# Modo Solo ou Ordem do Alvo: só um resultado, sem comparação.
		painel_2.visible = false
		label_vencedor.visible = false
	else:
		# Modo 1v1: mostra os dois painéis e aponta o vencedor.
		painel_2.visible = true
		_preencher_painel(painel_2, resultado_2)
		_exibir_vencedor(resultado_1, resultado_2)


func _preencher_painel(painel: VBoxContainer, resultado: Dictionary) -> void:
	if resultado.is_empty():
		return

	painel.get_node("LabelPontuaçãoFinal").text = "Pontuação: %d" % resultado.get("pontuacao", 0)
	painel.get_node("LabelAcertosFinal").text = "Acertos: %d" % resultado.get("acertos", 0)
	painel.get_node("LabelErrosFinal").text = "Erros: %d" % resultado.get("erros", 0)
	painel.get_node("LabelPrecisaoFinal").text = "Precisão: %.0f%%" % (resultado.get("precisao", 0.0) * 100.0)
	painel.get_node("LabelTempoFinal").text = "Tempo: %.1fs" % resultado.get("tempo", 0.0)


func _exibir_vencedor(resultado_1: Dictionary, resultado_2: Dictionary) -> void:
	label_vencedor.visible = true

	var pontos_1: int = resultado_1.get("pontuacao", 0)
	var pontos_2: int = resultado_2.get("pontuacao", 0)

	if pontos_1 > pontos_2:
		label_vencedor.text = "Vencedor: Jogador 1!"
	elif pontos_2 > pontos_1:
		label_vencedor.text = "Vencedor: Jogador 2!"
	else:
		label_vencedor.text = "Empate!"


func _on_voltar_pressed() -> void:
	GameManager.voltar_ao_menu()
