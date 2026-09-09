extends Node2D

@export var fases: Array[FaseConfig] = []
var fase_atual_index: int = 0
var jogador_atual: int = 1

var resultados_p1: Dictionary = {}
var resultados_p2: Dictionary = {}

@onready var game_base = $GameBase
var spawner: Node

# Variáveis para a UI gerada via código
var transicao_ui: CanvasLayer
var transicao_label: Label
var transicao_btn: Button

func _ready() -> void:
	# Busca inteligente pelo Spawner
	spawner = _encontrar_spawner(self)
	
	if spawner == null:
		push_error("ERRO: Nenhum nó com a função 'iniciar_fase' foi encontrado!")
	
	_criar_ui_transicao()
	
	# Carrega as 6 fases oficiais da sua pasta
	if fases.is_empty():
		fases.append(load("res://Resources/Fases/fase_01_estatico.tres"))
		fases.append(load("res://Resources/Fases/fase_02_translacao.tres"))
		fases.append(load("res://Resources/Fases/fase_03_translacao_rapida.tres"))
		fases.append(load("res://Resources/Fases/fase_04_rotacao.tres"))
		fases.append(load("res://Resources/Fases/fase_05_escala.tres"))
		fases.append(load("res://Resources/Fases/fase_06_combinado.tres"))

	# Conecta o sinal de quando a fase acaba
	if spawner != null:
		spawner.fase_concluida.connect(_on_fase_concluida)
	
	# Oculta a ResultScreen padrão para usarmos o painel de Duelo
	if has_node("ResultScreen"):
		$ResultScreen.hide()

	# Pausa a árvore para o jogador ler a tela antes de começar
	get_tree().paused = true
	_mostrar_tela_transicao("MODO DUELO 1V1\n\nJogador 1, prepare-se!", "Iniciar Jogador 1")

# ==========================================
# O RADAR À PROVA DE FALHAS
# ==========================================
func _encontrar_spawner(no: Node) -> Node:
	if no.has_method("iniciar_fase"):
		return no
	for filho in no.get_children():
		var resultado = _encontrar_spawner(filho)
		if resultado != null:
			return resultado
	return null

func _iniciar_turno() -> void:
	transicao_ui.hide()
	get_tree().paused = false # Despausa o jogo
	fase_atual_index = 0
	
	ScoreSystem.resetar() 
	if spawner != null:
		spawner.iniciar_fase(fases[fase_atual_index])

func _on_fase_concluida() -> void:
	fase_atual_index += 1
	if fase_atual_index < fases.size():
		spawner.iniciar_fase(fases[fase_atual_index])
	else:
		_encerrar_turno()

func _encerrar_turno() -> void:
	# Pausa o jogo ao fim do turno
	get_tree().paused = true 
	var resultados_atuais = ScoreSystem.obter_resultado_final()

	if jogador_atual == 1:
		resultados_p1 = resultados_atuais
		jogador_atual = 2
		# CORREÇÃO: Puxando a chave exata "pontuacao" do ScoreSystem
		var msg = "Fim do Turno do Jogador 1!\nPontos feitos: %d\n\nJogador 2, prepare-se!" % resultados_p1["pontuacao"]
		_mostrar_tela_transicao(msg, "Iniciar Jogador 2")
	else:
		resultados_p2 = resultados_atuais
		_mostrar_resultado_final()

func _mostrar_resultado_final() -> void:
	var vencedor = ""
	# CORREÇÃO: Puxando a chave exata "pontuacao" do ScoreSystem
	var p1_pts = resultados_p1["pontuacao"]
	var p2_pts = resultados_p2["pontuacao"]
	
	if p1_pts > p2_pts:
		vencedor = "👑 JOGADOR 1 VENCEU! 👑"
	elif p2_pts > p1_pts:
		vencedor = "👑 JOGADOR 2 VENCEU! 👑"
	else:
		vencedor = "⚔️ EMPATE! ⚔️"

	var texto_final = "%s\n\nPlacar Final:\nJogador 1: %d pontos\nJogador 2: %d pontos" % [vencedor, p1_pts, p2_pts]

	_mostrar_tela_transicao(texto_final, "Voltar ao Menu")
	
	# Troca a função do botão para ele voltar ao menu em vez de iniciar turno
	transicao_btn.pressed.disconnect(_iniciar_turno) 
	transicao_btn.pressed.connect(_voltar_ao_menu)

func _voltar_ao_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main.tscn")

# ==========================================
# CRIAÇÃO DA INTERFACE DO 1V1 VIA CÓDIGO (COM LAYOUT CORRIGIDO)
# ==========================================
func _criar_ui_transicao() -> void:
	transicao_ui = CanvasLayer.new()
	transicao_ui.layer = 100 
	transicao_ui.process_mode = Node.PROCESS_MODE_ALWAYS 
	add_child(transicao_ui)

	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.1, 0.95) 
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	transicao_ui.add_child(bg)

	# SOLUÇÃO DE LAYOUT: CenterContainer garante que tudo fique centralizado
	var center_container = CenterContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.add_child(center_container)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 40)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center_container.add_child(vbox)

	transicao_label = Label.new()
	transicao_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	transicao_label.add_theme_font_size_override("font_size", 48)
	vbox.add_child(transicao_label)

	transicao_btn = Button.new()
	transicao_btn.add_theme_font_size_override("font_size", 32)
	transicao_btn.custom_minimum_size = Vector2(400, 80)
	vbox.add_child(transicao_btn)

func _mostrar_tela_transicao(texto: String, texto_botao: String) -> void:
	transicao_label.text = texto
	transicao_btn.text = texto_botao
	transicao_ui.show()

	if not transicao_btn.pressed.is_connected(_iniciar_turno) and jogador_atual <= 2:
		transicao_btn.pressed.connect(_iniciar_turno)
