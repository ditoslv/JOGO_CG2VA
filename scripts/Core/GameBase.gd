extends Node2D
class_name GameBase

## Cena-núcleo compartilhada pelos três modos (Solo, 1v1 via Solo,
## Ordem do Alvo). Reúne mira, disparo, spawner e cronômetro.
##
## Quem orquestra fases e rodadas (SoloMode.gd, e depois VersusMode/
## OrderMode) deve chamar os métodos abaixo, em vez de acessar
## $Spawner ou $Cronometro diretamente — isso mantém a GameBase como
## o único ponto de contato entre "o que orquestra a partida" e
## "os sistemas do Core".

signal fase_concluida()

@onready var spawner: TargetSpawner = $Spawner
@onready var cronometro: Timer = $Cronometro


func _ready() -> void:
	spawner.fase_concluida.connect(func(): fase_concluida.emit())


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
