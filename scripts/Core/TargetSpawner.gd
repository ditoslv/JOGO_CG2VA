extends Node2D
class_name TargetSpawner

## Reutilizado por Solo, 1v1 (via Solo) e Ordem do Alvo.
## Nenhuma lógica de "qual modo está rodando" deve entrar aqui —
## tudo que muda o comportamento vem de FaseConfig.

@export var target_scene: PackedScene  # arrastar Target.tscn no Inspector
@export var area_spawn: Rect2 = Rect2(Vector2(-300, -200), Vector2(600, 400))

## Retângulo (em coordenadas globais) onde nenhum alvo pode nascer —
## normalmente a área ocupada pelo painel de estatísticas do HUD.
## GameBase.definir_area_excluida() é o jeito certo de preencher isto.
@export var area_excluida: Rect2 = Rect2()

var _fase_atual: FaseConfig
var _pool: Array[Target] = []
var _alvos_restantes: int = 0    # ainda não RESOLVIDOS nesta fase (ativos + a nascer)
var _alvos_a_spawnar: int = 0    # ainda não NASCERAM nesta fase
var _timer_spawn: float = 0.0

signal fase_concluida()


## Chamada pelo SoloMode (ou OrderMode) ao iniciar cada fase/nível.
## SoloMode só chama isto depois que fase_concluida for emitido pela fase
## anterior — e fase_concluida só é emitido quando _alvos_restantes chega a
## zero, ou seja, quando não sobra nenhum alvo (ativo ou por nascer) da fase
## anterior. Então uma fase nova só começa de fato quando a anterior já
## esvaziou a tela por completo.
func iniciar_fase(fase: FaseConfig) -> void:
	_fase_atual = fase
	_alvos_restantes = fase.total_de_alvos
	_alvos_a_spawnar = fase.total_de_alvos
	_timer_spawn = 0.0
	_garantir_pool(fase.quantidade_alvos_simultaneos)

	# Garante que a fase já comece com pelo menos um alvo em tela, em vez
	# de esperar o primeiro _process() rodar pra nascer o primeiro.
	_spawnar_se_possivel()


func _process(delta: float) -> void:
	if _fase_atual == null or _alvos_restantes <= 0:
		return

	_timer_spawn -= delta
	if _timer_spawn <= 0.0:
		_spawnar_se_possivel()


## Quantos alvos do pool estão ativos (em tela) agora.
func _quantidade_ativa() -> int:
	var ativos := 0
	for t in _pool:
		if t.is_active:
			ativos += 1
	return ativos


## Tenta nascer um alvo agora mesmo, respeitando o total da fase e o limite
## de alvos simultâneos. Retorna true se um alvo nasceu.
##
## Chamada tanto pelo cronômetro de spawn (_process, a cada intervalo_spawn)
## quanto direto por _on_target_resolved() assim que um alvo é resolvido
## (morto ou expirado) — é essa segunda chamada que garante que sempre
## exista pelo menos um alvo em tela: se o jogador mata um alvo antes do
## intervalo normal terminar, outro nasce na hora, sem esperar o resto do
## intervalo. Isso também reinicia a contagem do intervalo (_timer_spawn),
## então o intervalo passa a valer como o tempo MÁXIMO entre spawns, não
## um tempo fixo — o cronômetro só marca o ritmo quando ninguém morre antes
## dele completar.
func _spawnar_se_possivel() -> bool:
	if _fase_atual == null or _alvos_a_spawnar <= 0:
		return false
	if _quantidade_ativa() >= _fase_atual.quantidade_alvos_simultaneos:
		return false
	if not _existe_alvo_livre():
		return false

	_spawnar_um()
	_alvos_a_spawnar -= 1
	_timer_spawn = _fase_atual.intervalo_spawn
	return true


## Cria (uma única vez) as instâncias de Target que serão reaproveitadas
## durante toda a fase, em vez de instanciar/destruir a cada spawn.
func _garantir_pool(tamanho: int) -> void:
	while _pool.size() < tamanho:
		var t: Target = target_scene.instantiate()
		add_child(t)
		t.target_resolved.connect(_on_target_resolved)
		t.target_expired.connect(_on_target_expired)
		_pool.append(t)


func _existe_alvo_livre() -> bool:
	for t in _pool:
		if not t.is_active:
			return true
	return false


func _spawnar_um() -> void:
	for t in _pool:
		if not t.is_active:
			var config := _fase_atual.para_config_alvo()
			config["posicao"] = _posicao_aleatoria()
			t.ativar(config)
			return


func _posicao_aleatoria() -> Vector2:
	var x_min := area_spawn.position.x
	var x_max := area_spawn.end.x

	# Alvos que se deslocam da direita pra esquerda (direcao.x negativo)
	# só podem nascer no primeiro terço da tela, medindo da esquerda pra
	# direita — senão nasceriam perto da borda esquerda e sairiam de tela
	# quase instantaneamente.
	if _fase_atual and _fase_atual.direcao_padrao.x < 0.0:
		x_max = x_min + area_spawn.size.x / 3.0

	var posicao: Vector2
	var tentativas := 0
	while true:
		posicao = Vector2(
			randf_range(x_min, x_max),
			randf_range(area_spawn.position.y, area_spawn.end.y)
		)
		tentativas += 1
		if not area_excluida.has_point(posicao) or tentativas >= 20:
			break
	return posicao


func _on_target_resolved(_target: Node) -> void:
	_alvos_restantes -= 1
	if _alvos_restantes <= 0:
		fase_concluida.emit()
		return

	# Acabou de abrir uma vaga (o alvo resolvido liberou o slot no pool):
	# tenta preencher na hora, sem esperar o intervalo normal do cronômetro.
	_spawnar_se_possivel()


## Alvo não clicado a tempo também é um erro — distinto de um clique
## que não acerta nada (esse já é contado direto no Disparo.gd).
func _on_target_expired() -> void:
	ScoreSystem.registrar_erro()
