extends Node2D

## Cena de teste isolada — valida Mira + Disparo + Target + TargetSpawner
## + ScoreSystem juntos, sem depender do Modo Solo, do HUD ou de
## qualquer código da Pessoa 2/Pessoa 3.

@export var fase_teste: FaseConfig
@export var margem: float = 60.0

@onready var _spawner: TargetSpawner = $Spawner
@onready var _label: Label = $CanvasLayer/Label


func _ready() -> void:
	# Define a área de spawn com base no tamanho real da janela,
	# para o teste funcionar em qualquer resolução configurada no projeto.
	var tamanho := get_viewport_rect().size
	_spawner.area_spawn = Rect2(
		Vector2(margem, margem),
		Vector2(tamanho.x - margem * 2.0, tamanho.y - margem * 2.0)
	)
	queue_redraw()

	ScoreSystem.resetar()
	ScoreSystem.score_updated.connect(_on_score_updated)
	_spawner.fase_concluida.connect(_on_fase_concluida)

	var fase := fase_teste
	if fase == null:
		fase = load("res://Resources/Fases/fase_01_estatico.tres")
	_spawner.iniciar_fase(fase)

	_on_score_updated(ScoreSystem.obter_resultado_final())


## Desenha a borda da área de spawn, só para orientação visual durante o teste.
func _draw() -> void:
	if _spawner:
		draw_rect(_spawner.area_spawn, Color.YELLOW, false, 2.0)


func _on_score_updated(dados: Dictionary) -> void:
	_label.text = "Pontuação: %d\nAcertos: %d\nErros: %d\nTentativas: %d\nPrecisão: %.0f%%" % [
		dados["pontuacao"],
		dados["acertos"],
		dados["erros"],
		dados["tentativas"],
		dados["precisao"] * 100.0,
	]


func _on_fase_concluida() -> void:
	print("Fase de teste concluída — todos os alvos foram resolvidos.")
