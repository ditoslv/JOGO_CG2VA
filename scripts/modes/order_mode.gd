extends Node2D
@export var iniciar_automaticamente: bool = true
@onready var label_sequencia = $LabelSequencia
@onready var timer_exibicao = $TimerExibicaoSequencia
@onready var hud = $HUD

const TARGET_SCENE := preload("res://scenes/Targets/Target.tscn")

# Área onde os alvos podem aparecer (ajuste conforme o tamanho da sua cena)
var area_spawn: Rect2 = Rect2(Vector2(-300, -200), Vector2(600, 400))

var quantidade_alvos: int = 3          # progressão: 3 -> 4-5 -> movimento -> rotação/escala
var sequencia_correta: Array = []
var indice_atual: int = 0
var tempo_exibicao_sequencia: float = 3.0
var alvos_ativos: Array = []           # instâncias de Target nesta rodada


func _ready() -> void:
	$Disparo.ativo = true
	$Disparo.ativo = false
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
	sequencia_correta = gerar_sequencia(quantidade_alvos)
	spawnar_alvos_numerados()
	exibir_sequencia()


func gerar_sequencia(qtd: int) -> Array:
	var numeros = range(1, qtd + 1)
	numeros.shuffle()
	return numeros


func spawnar_alvos_numerados() -> void:
	for numero in sequencia_correta:
		var t: Target = TARGET_SCENE.instantiate()
		add_child(t)

		# Guarda o número desse alvo sem alterar o Target.gd
		t.set_meta("numero_ordem", numero)

		# Conecta os sinais já existentes no contrato, passando a referência do alvo
		t.target_hit.connect(_on_target_hit.bind(t))
		t.target_expired.connect(_on_target_expired.bind(t))

		var config := {
			"posicao": _posicao_aleatoria(),
			"tempo_de_vida": 999.0,  # nesta fase, o alvo não deve expirar sozinho
		}
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


func aplicar_penalidade() -> void:
	# Regra a definir em playtest (seção D.3 do planejamento):
	# reiniciar sequência, perder pontos ou consumir tentativa.
	indice_atual = 0
	print("Ordem errada! Reiniciando sequência.")


func rodada_concluida() -> void:
	print("Sequência completa!")
	quantidade_alvos += 1  # progressão de dificuldade
	# AJUSTAR: aqui entra a chamada pra ResultScreen quando a rodada acabar de vez
	iniciar_rodada()


func _limpar_alvos_antigos() -> void:
	for alvo in alvos_ativos:
		if is_instance_valid(alvo):
			alvo.queue_free()
	alvos_ativos.clear()
