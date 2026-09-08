extends Area2D
class_name Target

## ============================================================
## CONTRATO PÚBLICO DO Target.gd — combinado com a equipe.
## Propriedades, sinais e funções abaixo NÃO podem ser renomeados
## sem avisar a Pessoa 2 e a Pessoa 3, que dependem deles.
## ============================================================

# --- Propriedades configuráveis (lidas pela Pessoa 3 e pelo TargetSpawner) ---
@export var pontos: int = 10
@export var velocidade: float = 0.0
@export var direcao: Vector2 = Vector2.ZERO
@export var velocidade_angular: float = 0.0
@export var escala_min: float = 1.0
@export var escala_max: float = 1.0
@export var tempo_de_vida: float = 3.0

# --- Estado interno ---
var is_active: bool = false
var _tempo_restante: float = 0.0
var _tempo_escala: float = 0.0

# --- Sinais ---
signal target_hit(pontos: int)      # emitido ao ser acertado
signal target_expired()             # emitido ao expirar sem ser acertado
signal target_resolved(target: Node) # emitido nos dois casos acima -> usado pelo TargetSpawner

@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _particulas: CPUParticles2D = $Particulas


func _ready() -> void:
	desativar() # todo alvo começa inativo até o spawner chamar ativar()


func _process(delta: float) -> void:
	if not is_active:
		return

	_aplicar_movimento(delta)

	_tempo_restante -= delta
	if _tempo_restante <= 0.0:
		_expirar()


## ------------------------------------------------------------
## PONTO DE EXTENSÃO DA PESSOA 3.
## Toda a lógica visual de movimento (translação, rotação, escala,
## combinações) deve viver aqui, lendo as propriedades exportadas
## acima. Nenhuma outra função deste script deve ser alterada.
## ------------------------------------------------------------
func _aplicar_movimento(delta: float) -> void:
	if velocidade > 0.0 and direcao != Vector2.ZERO:
		position += direcao.normalized() * velocidade * delta
	if velocidade_angular != 0.0:
		rotation += velocidade_angular * delta
	if escala_max != escala_min:
		_tempo_escala += delta
		var t: float = (sin(_tempo_escala) + 1.0) / 2.0  # oscila 0..1
		var s: float = lerp(escala_min, escala_max, t)
		scale = Vector2(s, s)


## Chamada pelo TargetSpawner para (re)ativar este alvo com nova configuração.
## config é um Dictionary; chaves ausentes mantêm o valor atual.
func ativar(config: Dictionary = {}) -> void:
	pontos = config.get("pontos", pontos)
	velocidade = config.get("velocidade", velocidade)
	direcao = config.get("direcao", direcao)
	velocidade_angular = config.get("velocidade_angular", velocidade_angular)
	escala_min = config.get("escala_min", escala_min)
	escala_max = config.get("escala_max", escala_max)
	tempo_de_vida = config.get("tempo_de_vida", tempo_de_vida)

	if config.has("posicao"):
		global_position = config["posicao"]

	_tempo_restante = tempo_de_vida
	_tempo_escala = 0.0
	is_active = true
	_sprite.visible = true
	_collision.disabled = false
	scale = Vector2.ONE
	rotation = 0.0


## Chamada pelo sistema de disparo (Disparo.gd) quando este alvo é atingido.
func registrar_acerto() -> void:
	if not is_active:
		return
	is_active = false
	_collision.disabled = true
	_sprite.visible = false
	if _particulas:
		_particulas.restart()
	target_hit.emit(pontos)
	target_resolved.emit(self)


## Usada tanto pelo acerto quanto pela expiração por tempo.
func desativar() -> void:
	is_active = false
	if _sprite:
		_sprite.visible = false
	if _collision:
		_collision.disabled = true


func _expirar() -> void:
	if not is_active:
		return
	desativar()
	target_expired.emit()
	target_resolved.emit(self)
