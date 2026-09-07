extends Node2D
class_name Mira

## Node2D simples que acompanha o mouse. Não conhece Target,
## ScoreSystem nem Disparo — só expõe sua própria posição via
## global_position, que já vem de herança de Node2D.

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
