extends Control
class_name ResultScreen

## ============================================================
## CONTRATO PÚBLICO DESTA CENA — combinado com a equipe.
## Quem orquestra o fim de uma rodada (SoloMode ou VersusMode) deve chamar
## UMA das funções abaixo para exibir o
## resultado. Nenhum outro script deve acessar os Labels
## diretamente.
##
## - mostrar_resultado(dados)                  -> usada pelo SoloMode (A)
## - exibir_resultado_solo(dados)              -> resultado de 1 jogador
##   (as duas fazem a mesma coisa; "mostrar_resultado" existe só
##   pra bater com o nome que o SoloMode já usa)
## - exibir_resultado_1v1(dados_p1, dados_p2)   -> 1v1
##
## "dados" é o Dictionary retornado por
## ScoreSystem.obter_resultado_final(): {pontuacao, acertos, erros,
## tentativas, precisao}. Uma chave opcional "tempo" (float, em
## segundos) pode ser incluída se quem chamar tiver essa informação.
## ============================================================

signal voltar_ao_menu_solicitado()

@onready var painel_jogador1: VBoxContainer = $Camada/CenterContainer/VBoxPrincipal/HBoxJogadores/PainelJogador1
@onready var painel_jogador2: VBoxContainer = $Camada/CenterContainer/VBoxPrincipal/HBoxJogadores/PainelJogador2
@onready var label_vencedor: Label = $Camada/CenterContainer/VBoxPrincipal/LabelVencedor
@onready var botao_voltar: Button = $Camada/CenterContainer/VBoxPrincipal/Button
@onready var botao_jogar_de_novo: Button = $Camada/CenterContainer/VBoxPrincipal/BotaoJogarDeNovo


func _ready() -> void:
	botao_voltar.pressed.connect(_on_botao_voltar_pressed)
	botao_jogar_de_novo.pressed.connect(_on_botao_jogar_de_novo_pressed)

	if GameManager.modo_atual == "solo":
		exibir_resultado_solo(GameManager.resultado_jogador_1)

	elif GameManager.modo_atual == "1v1":
		exibir_resultado_1v1(
			GameManager.resultado_jogador_1,
			GameManager.resultado_jogador_2
		)


## Chamada para exibir o resultado de uma rodada de um jogador.
func exibir_resultado_solo(dados: Dictionary) -> void:
	painel_jogador2.visible = false
	label_vencedor.visible = false
	_preencher_painel(painel_jogador1, dados)


## Apelido de exibir_resultado_solo(), só pra bater com o nome que
## o solo_mode.gd (Integrante A) já chama. Mantido junto da função
## acima pra não terem duas implementações divergindo.
func mostrar_resultado(dados: Dictionary) -> void:
	exibir_resultado_solo(dados)


## Chamada pelo VersusMode (1v1) depois que os dois jogadores jogaram.
func exibir_resultado_1v1(dados_jogador1: Dictionary, dados_jogador2: Dictionary) -> void:
	painel_jogador2.visible = true
	_preencher_painel(painel_jogador1, dados_jogador1)
	_preencher_painel(painel_jogador2, dados_jogador2)
	_definir_vencedor(dados_jogador1, dados_jogador2)


## Preenche os labels de um painel (Jogador 1 ou Jogador 2) a partir
## do Dictionary de resultado. Reaproveitada pelos dois painéis, já
## que ambos têm a mesma estrutura de filhos.
func _preencher_painel(painel: VBoxContainer, dados: Dictionary) -> void:
	var lbl_pontuacao: Label = painel.get_node("LabelPontuaçãoFinal")
	var lbl_acertos: Label = painel.get_node("LabelAcertosFinal")
	var lbl_erros: Label = painel.get_node("LabelErrosFinal")
	var lbl_precisao: Label = painel.get_node("LabelPrecisaoFinal")
	var lbl_tempo: Label = painel.get_node("LabelTempoFinal")

	lbl_pontuacao.text = "Pontuação: %d" % dados.get("pontuacao", 0)
	lbl_acertos.text = "Acertos: %d" % dados.get("acertos", 0)
	lbl_erros.text = "Erros: %d" % dados.get("erros", 0)
	lbl_precisao.text = "Precisão: %.0f%%" % (dados.get("precisao", 0.0) * 100.0)
	lbl_tempo.text = "Tempo: %.1fs" % dados.get("tempo", 0.0)


func _definir_vencedor(dados_jogador1: Dictionary, dados_jogador2: Dictionary) -> void:
	label_vencedor.visible = true

	var pontos_p1: int = dados_jogador1.get("pontuacao", 0)
	var pontos_p2: int = dados_jogador2.get("pontuacao", 0)

	if pontos_p1 > pontos_p2:
		label_vencedor.text = "Vencedor: Jogador 1!"
	elif pontos_p2 > pontos_p1:
		label_vencedor.text = "Vencedor: Jogador 2!"
	else:
		label_vencedor.text = "Empate!"


func _on_botao_voltar_pressed() -> void:
	voltar_ao_menu_solicitado.emit()
	GameManager.voltar_ao_menu()


## Volta pro MESMO modo que acabou de terminar, do zero — não dá pra usar
## reload_current_scene() aqui porque a cena atual é a ResultScreen (uma
## cena própria, trocada via GameManager.ir_para_resultado()), não o modo
## em si. GameManager.modo_atual guarda qual foi jogado por último.
func _on_botao_jogar_de_novo_pressed() -> void:
	match GameManager.modo_atual:
		"solo":
			get_tree().change_scene_to_file("res://scenes/modes/solo_mode.tscn")
		_:
			push_warning("ResultScreen: 'Jogar de novo' sem modo 1v1 implementado ainda; voltando ao menu.")
			get_tree().change_scene_to_file("res://scenes/menu/Menu.tscn")
