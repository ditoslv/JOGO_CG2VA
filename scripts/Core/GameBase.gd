extends Node2D
class_name GameBase

## Cena-núcleo compartilhada pelos três modos (Solo, 1v1 via Solo,
## 1v1). Reúne mira, disparo, spawner e cronômetro.
##
## Quem orquestra fases e rodadas (SoloMode.gd, e depois VersusMode/
## VersusMode) deve chamar os métodos abaixo, em vez de acessar
## $Spawner ou $Cronometro diretamente — isso mantém a GameBase como
## o único ponto de contato entre "o que orquestra a partida" e
## "os sistemas do Core".

signal fase_concluida()

@export var margem_spawn: float = 60.0

@onready var spawner: TargetSpawner = $Spawner
@onready var cronometro: Timer = $Cronometro
@onready var disparo: Disparo = $Disparo


func _ready() -> void:
	_ajustar_area_de_spawn()
	spawner.fase_concluida.connect(func(): fase_concluida.emit())


## Chamada por quem orquestra o modo (SoloMode) assim que souber onde
## fica a área ocupada pelo HUD de estatísticas — nenhum alvo nasce ali.
func definir_area_excluida(rect: Rect2) -> void:
	spawner.area_excluida = rect


## Para tudo (disparo e cronômetro) sem destruir nada — usado quando a
## rodada termina e a tela de resultados assume a tela inteira.
func encerrar() -> void:
	disparo.ativo = false
	cronometro.stop()


## Limita onde os alvos podem nascer ao tamanho real da janela (com uma
## margem), em vez do Rect2 fixo e centrado em (0,0) que o TargetSpawner
## usa por padrão — esse default sozinho deixa metade da área fora da tela.
func _ajustar_area_de_spawn() -> void:
	var tamanho := get_viewport_rect().size
	spawner.area_spawn = Rect2(
		Vector2(margem_spawn, margem_spawn),
		Vector2(tamanho.x - margem_spawn * 2.0, tamanho.y - margem_spawn * 2.0)
	)


## Chamar UMA VEZ no início de uma rodada inteira (não a cada fase!).
## No Solo: uma vez, antes da fase 1. No 1v1: uma vez para CADA uma
## das duas execuções (jogador 1 e jogador 2), para o placar de cada
## um começar do zero.
func resetar_rodada() -> void:
	ScoreSystem.resetar()
	cronometro.stop()


## Chamar a cada fase/nível dentro da rodada.
## duracao_segundos é opcional: só usar cronômetro se o critério de
## fim de fase for por tempo (em vez de "todos os alvos resolvidos",
## que o TargetSpawner já cobre via fase_concluida).
func iniciar_fase(fase: FaseConfig, duracao_segundos: float = 0.0) -> void:
	spawner.iniciar_fase(fase)
	if duracao_segundos > 0.0:
		cronometro.start(duracao_segundos)


func parar_fase() -> void:
	cronometro.stop()
