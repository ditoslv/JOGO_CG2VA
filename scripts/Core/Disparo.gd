extends Node2D
class_name Disparo

## Sistema de disparo instantâneo (hit-scan pontual), adequado para
## um shooting gallery sem deslocamento do jogador.
##
## Depende do Autoload "ScoreSystem" já registrado no projeto
## (Project Settings > Autoload) — ver ScoreSystem.gd.

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:
		_disparar()


func _disparar() -> void:
	var espaco := get_world_2d().direct_space_state

	var params := PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true   # IMPORTANTE: Target é Area2D
	params.collide_with_bodies = false

	var resultados := espaco.intersect_point(params, 1)

	if resultados.size() > 0:
		var colisor = resultados[0]["collider"]
		if colisor is Target and colisor.is_active:
			colisor.registrar_acerto()
			ScoreSystem.registrar_acerto(colisor.pontos)
			return

	ScoreSystem.registrar_erro()
