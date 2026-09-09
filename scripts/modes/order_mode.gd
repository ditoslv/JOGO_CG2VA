extends Node2D
@export var iniciar_automaticamente: bool = true
@onready var label_sequencia = $LabelSequencia
@onready var timer_exibicao = $TimerExibicaoSequencia
@onready var hud = $HUD

const TARGET_SCENE := preload("res://scenes/Targets/Target.tscn")
const PAUSE_MENU_SCENE := preload("res://scenes/ui/pause_menu.tscn")

# Área onde os alvos podem aparecer. Calculada em runtime a partir do
# tamanho real da janela (mesmo padrão que o GameBase.gd e o hud.gd já
# usam), com uma margem pra não spawnar colado na borda. Antes eu tinha
# um Rect2 fixo centrado em (0,0) — mas esse projeto trata (0,0) como o
# canto superior esquerdo da tela, então metade da área ficava com
# coordenadas negativas (fora da tela). Corrigido calculando aqui.
@export var margem_spawn: float = 80.0
var area_spawn: Rect2

## ------------------------------------------------------------
## Progressão de dificuldade (Seção D.3 do planejamento):
## 3 estáticos -> 4-5 estáticos -> movimento -> rotação/escala.
## Cada Dictionary é passado direto pro Target.ativar() (mais a
## chave "quantidade", lida só aqui). Chaves ausentes = padrão do
## Target (estático).
## ------------------------------------------------------------
var configuracoes_rodadas: Array[Dictionary] = [
	{"quantidade": 3},
	{"quantidade": 4},
	{"quantidade": 5},
	{"quantidade": 4, "velocidade": 80.0, "direcao": Vector2(1, 0)},
	{"quantidade": 4, "velocidade_angular": 2.0},
	{"quantidade": 4, "velocidade": 80.0, "direcao": Vector2(1, 0),
		"velocidade_angular": 2.0, "escala_min": 0.7, "escala_max": 1.3},
]

var rodada_atual: int = 0
var sequencia_correta: Array = []
var indice_atual: int = 0
var tempo_exibicao_sequencia: float = 3.0
var alvos_ativos: Array = []           # instâncias de Target nesta rodada


func _ready() -> void:
	var tamanho_tela := get_viewport_rect().size
	area_spawn = Rect2(
		Vector2(margem_spawn, margem_spawn),
		tamanho_tela - Vector2(margem_spawn, margem_spawn) * 2
	)

	# Mantém o Disparo LIGADO (senão nenhum clique é detectado e o modo
	# fica mudo/sem reação) mas desliga a pontuação automática dele —
	# quem decide acerto/erro aqui é validar_acerto(), reagindo ao
	# sinal "target_hit" que colisor.registrar_acerto() já dispara.
	$Disparo.pontuar_automaticamente = false


	# PauseMenu cuida de si mesmo (escuta ESC internamente) — só
	# precisa ser instanciado como filha do modo.
	add_child(PAUSE_MENU_SCENE.instantiate())

	if not iniciar_automaticamente:
		return
	timer_exibicao.wait_time = tempo_exibicao_sequencia
	timer_exibicao.one_shot = true
	timer_exibicao.timeout.connect(_esconder_numeros)
	ScoreSystem.resetar()
	iniciar_rodada()


func iniciar_rodada() -> void:
	_limpar_alvos_antigos()
	indice_atual = 0
	var quantidade: int = configuracoes_rodadas[rodada_atual].get("quantidade", 3)
	sequencia_correta = gerar_sequencia(quantidade)
	spawnar_alvos_numerados()
	exibir_sequencia()


func gerar_sequencia(qtd: int) -> Array:
	var numeros = range(1, qtd + 1)
	numeros.shuffle()
	return numeros


func spawnar_alvos_numerados() -> void:
	var config_rodada: Dictionary = configuracoes_rodadas[rodada_atual]

	for numero in sequencia_correta:
		var t: Target = TARGET_SCENE.instantiate()
		add_child(t)

		# Guarda o número desse alvo sem alterar o Target.gd
		t.set_meta("numero_ordem", numero)

		# Conecta os sinais já existentes no contrato, passando a referência do alvo
		t.target_hit.connect(_on_target_hit.bind(t))
		t.target_expired.connect(_on_target_expired.bind(t))

		# Config do alvo = parâmetros de movimento/rotação/escala da rodada atual
		# + posição sorteada + tempo de vida infinito (esse modo não expira alvo por tempo).
		var config := config_rodada.duplicate()
		config.erase("quantidade")
		config["posicao"] = _posicao_aleatoria()
		config["tempo_de_vida"] = 999.0
		t.ativar(config)

		_criar_label_numero(t, numero)
		alvos_ativos.append(t)


func _posicao_aleatoria() -> Vector2:
	return Vector2(
		randf_range(area_spawn.position.x, area_spawn.end.x),
		randf_range(area_spawn.position.y, area_spawn.end.y)
	)


## Cria um Label temporário em cima do alvo, mostrando o número da sequência.
func _criar_label_numero(alvo: Node2D, numero: int) -> void:
	var lbl := Label.new()
	lbl.text = str(numero)
	lbl.name = "LabelNumero"
	lbl.position = Vector2(-8, -40)  # ajuste conforme o tamanho do sprite do alvo
	alvo.add_child(lbl)


func exibir_sequencia() -> void:
	label_sequencia.text = " → ".join(sequencia_correta.map(func(n): return str(n)))
	label_sequencia.visible = true
	timer_exibicao.start()


func _esconder_numeros() -> void:
	label_sequencia.visible = false
	for alvo in alvos_ativos:
		if is_instance_valid(alvo) and alvo.has_node("LabelNumero"):
			alvo.get_node("LabelNumero").queue_free()


func _on_target_hit(pontos: int, alvo: Node) -> void:
	var numero_do_alvo = alvo.get_meta("numero_ordem")
	validar_acerto(numero_do_alvo)


func _on_target_expired(_alvo: Node) -> void:
	# Não deveria acontecer (tempo_de_vida = 999), mas fica registrado por segurança.
	pass


func validar_acerto(numero_do_alvo: int) -> void:
	var esperado = sequencia_correta[indice_atual]

	if numero_do_alvo == esperado:
		indice_atual += 1
		ScoreSystem.registrar_acerto(10)
		#ajustar o valor de pontos se quiser diferente por alvo

		if indice_atual >= sequencia_correta.size():
			rodada_concluida()
	else:
		ScoreSystem.registrar_erro()
		aplicar_penalidade()


## Regra escolhida (Seção D.3 do planejamento deixava em aberto: "reiniciar
## sequência, perder pontos ou consumir tentativa"): errar a ordem reinicia
## a rodada ATUAL com alvos novos. Não dá pra só zerar indice_atual sem
## respawnar nada — os alvos já clicados nesta tentativa (certos ou errados)
## já foram desativados permanentemente por Target.registrar_acerto(), então
## o alvo nº1 da sequência não existe mais pra ser clicado de novo. O erro
## já foi contado em ScoreSystem antes desta chamada. Se a equipe preferir
## outra regra (só descontar pontos, ou consumir "vidas" antes de reiniciar),
## troque só o corpo desta função — o resto do fluxo não muda.
func aplicar_penalidade() -> void:
	indice_atual = 0
	print("Ordem errada! Reiniciando a rodada com alvos novos.")
	iniciar_rodada()


func rodada_concluida() -> void:
	print("Sequência completa!")
	rodada_atual += 1

	if rodada_atual >= configuracoes_rodadas.size():
		_finalizar_partida()
	else:
		iniciar_rodada()


## Chamada quando todas as rodadas da progressão terminam. Mostra a
## tela de resultados por cima do jogo com o total acumulado da partida.
func _finalizar_partida() -> void:
	_limpar_alvos_antigos()
	label_sequencia.visible = false
	
	var resultado: Dictionary = ScoreSystem.obter_resultado_final()
	GameManager.registrar_resultado_ordem(resultado)
	GameManager.ir_para_resultado()


func _limpar_alvos_antigos() -> void:
	for alvo in alvos_ativos:
		if is_instance_valid(alvo):
			alvo.queue_free()
	alvos_ativos.clear()
