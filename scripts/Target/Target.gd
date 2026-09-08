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

# Estado interno só do movimento circular (fase de "rotação pura",
# ver _aplicar_movimento_circular() abaixo).
const RAIO_ORBITAL: float = 70.0
var _centro_orbital: Vector2 = Vector2.ZERO
var _angulo_orbital: float = 0.0

# --- Sinais ---
signal target_hit(pontos: int)      # emitido ao ser acertado
signal target_expired()             # emitido ao expirar sem ser acertado
signal target_resolved(target: Node) # emitido nos dois casos acima -> usado pelo TargetSpawner

@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _sprite: Sprite2D = $Sprite2D


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
	if velocidade_angular != 0.0 and velocidade == 0.0:
		# Fase de "só rotação" (ex.: Fase 4): em vez de só girar parado
		# no lugar, o alvo agora descreve um círculo — ver
		# _aplicar_movimento_circular() logo abaixo.
		_aplicar_movimento_circular(delta)
	else:
		if velocidade > 0.0 and direcao != Vector2.ZERO:
			position += direcao.normalized() * velocidade * delta
		if velocidade_angular != 0.0:
			rotation += velocidade_angular * delta

	if escala_max != escala_min:
		_tempo_escala += delta
		var t: float = (sin(_tempo_escala) + 1.0) / 2.0  # oscila 0..1
		var s: float = lerp(escala_min, escala_max, t)
		scale = Vector2(s, s)


## Movimento circular: em vez de só rotacionar em torno do próprio eixo,
## o alvo passa a transladar ao redor de um centro fixo (o ponto onde
## nasceu), aplicando a matriz de rotação R(θ) sobre um vetor de raio
## fixo a cada frame — P(t) = centro + R(θ(t)) * raio. O nó também
## continua girando (rotation), então o conceito de rotação segue
## visível tanto na trajetória quanto na orientação do alvo.
func _aplicar_movimento_circular(delta: float) -> void:
	_angulo_orbital += velocidade_angular * delta
	var offset := Vector2(RAIO_ORBITAL, 0.0).rotated(_angulo_orbital)
	position = _centro_orbital + offset
	rotation += velocidade_angular * delta


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
	_centro_orbital = global_position  # ponto de partida do círculo, se este alvo entrar em movimento orbital
	_angulo_orbital = 0.0
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
