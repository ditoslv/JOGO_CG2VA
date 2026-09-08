extends Node
## Autoload (Project Settings > Autoload > AudioManager).
## Ponto único de áudio do jogo: SFX de acerto/erro, música de fundo e
## (futuramente) falas aleatórias.
##
## IMPORTANTE — por que este script NÃO precisa de nenhuma linha em
## Disparo.gd nem em Target.gd (arquivos da Pessoa 1):
## ScoreSystem já é Autoload e já emite o sinal público "score_updated"
## a cada acerto ou erro (pensado, segundo o próprio comentário do
## script, pra "qualquer script do jogo" consumir sem referência
## explícita — é assim que a Pessoa 2 vai ler pro HUD). Este script só
## assina esse mesmo sinal e compara os totais anteriores de acertos/
## erros pra saber qual som tocar. Nenhum arquivo de outra pessoa
## precisa ser alterado para o áudio funcionar.
##
## IMPORTANTE 2: os nós AudioStreamPlayer abaixo ainda precisam receber
## um arquivo de áudio (stream) no Inspector do Godot — este script só
## organiza QUANDO cada som toca, não substitui a necessidade de
## arrastar os arquivos .wav/.ogg pra cada player na cena AudioManager.tscn.

@onready var _sfx_acerto: AudioStreamPlayer = $SFX_Acerto
@onready var _sfx_erro: AudioStreamPlayer = $SFX_Erro
@onready var _musica: AudioStreamPlayer = $Musica

var _acertos_anteriores: int = 0
var _erros_anteriores: int = 0

var volume_geral_db: float = 0.0:
	set(v):
		volume_geral_db = v
		_sfx_acerto.volume_db = v
		_sfx_erro.volume_db = v
		_musica.volume_db = v


func _ready() -> void:
	# ScoreSystem é registrado como Autoload antes de AudioManager em
	# project.godot, então já existe e está pronto neste momento.
	ScoreSystem.score_updated.connect(_on_score_updated)


func _on_score_updated(dados: Dictionary) -> void:
	if dados["acertos"] > _acertos_anteriores:
		tocar_acerto()
	elif dados["erros"] > _erros_anteriores:
		tocar_erro()
	_acertos_anteriores = dados["acertos"]
	_erros_anteriores = dados["erros"]


func tocar_acerto() -> void:
	_sfx_acerto.play()


func tocar_erro() -> void:
	_sfx_erro.play()


## Toca a música de fundo em loop. Chame uma vez ao entrar em qualquer
## modo (Solo, 1v1, Ordem do Alvo) — todos reaproveitam a mesma trilha.
func tocar_musica_fundo() -> void:
	if not _musica.playing:
		_musica.play()


func parar_musica_fundo() -> void:
	_musica.stop()


## Pontos de extensão futuros (fora do escopo do MVP):
## - tocar_fala_aleatoria(): escolher e tocar uma fala aleatória entre
##   várias, quando houver os arquivos de voz gravados.
