extends Node2D
class_name TargetSpawner

## Reutilizado por Solo, 1v1 (via Solo) e Ordem do Alvo.
## Nenhuma lógica de "qual modo está rodando" deve entrar aqui —
## tudo que muda o comportamento vem de FaseConfig.

@export var target_scene: PackedScene  # arrastar Target.tscn no Inspector
@export var area_spawn: Rect2 = Rect2(Vector2(-300, -200), Vector2(600, 400))

var _fase_atual: FaseConfig
var _pool: Array[Target] = []
var _alvos_restantes: int = 0
var _timer_spawn: float = 0.0

signal fase_concluida()


## Chamada pelo SoloMode (ou OrderMode) ao iniciar cada fase/nível.
func iniciar_fase(fase: FaseConfig) -> void:
	_fase_atual = fase
	_alvos_restantes = fase.total_de_alvos
	_timer_spawn = 0.0
	_garantir_pool(fase.quantidade_alvos_simultaneos)


func _process(delta: float) -> void:
	if _fase_atual == null or _alvos_restantes <= 0:
		return

	_timer_spawn -= delta
	if _timer_spawn <= 0.0 and _existe_alvo_livre():
		_spawnar_um()
		_timer_spawn = _fase_atual.intervalo_spawn


## Cria (uma única vez) as instâncias de Target que serão reaproveitadas
## durante toda a fase, em vez de instanciar/destruir a cada spawn.
func _garantir_pool(tamanho: int) -> void:
	while _pool.size() < tamanho:
		var t: Target = target_scene.instantiate()
		add_child(t)
		t.target_resolved.connect(_on_target_resolved)
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
	return Vector2(
		randf_range(area_spawn.position.x, area_spawn.end.x),
		randf_range(area_spawn.position.y, area_spawn.end.y)
	)


func _on_target_resolved(_target: Node) -> void:
	_alvos_restantes -= 1
	if _alvos_restantes <= 0:
		fase_concluida.emit()
