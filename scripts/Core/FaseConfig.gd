extends Resource
class_name FaseConfig
## Cada fase do Modo Solo,
## reaproveitando esta mesma classe) é um arquivo .tres desta classe,
## criado pelo editor: botão direito em resources/fases/ > New Resource
## > FaseConfig.

@export var nome_fase: String = "Fase 1"

## Texto mostrado por 3 segundos no canto superior esquerdo quando esta
## fase começa (usado pelo Modo Solo). Deixar em branco = não mostra nada.
@export var mensagem_notificacao: String = ""
@export var quantidade_alvos_simultaneos: int = 3
@export var total_de_alvos: int = 10
@export var intervalo_spawn: float = 1.0

@export var velocidade_base: float = 0.0
@export var direcao_padrao: Vector2 = Vector2.ZERO
@export var velocidade_angular_padrao: float = 0.0
@export var escala_min_padrao: float = 1.0
@export var escala_max_padrao: float = 1.0
@export var tempo_de_vida_padrao: float = 3.0
@export var raio_orbita_padrao: float = 0.0


## Converte esta fase no Dictionary que Target.ativar() espera.
## Centralizar essa conversão aqui evita duplicar esse mapeamento
## em vários lugares (TargetSpawner, testes, etc.).
func para_config_alvo() -> Dictionary:
	return {
		"velocidade": velocidade_base,
		"direcao": direcao_padrao,
		"velocidade_angular": velocidade_angular_padrao,
		"escala_min": escala_min_padrao,
		"escala_max": escala_max_padrao,
		"tempo_de_vida": tempo_de_vida_padrao,
		"raio_orbita": raio_orbita_padrao,
	}
