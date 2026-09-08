extends Node2D
class_name Disparo

@export var ativo: bool = true


func _unhandled_input(event: InputEvent) -> void:
	if not ativo:
		return

	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:
		_disparar()


func _disparar() -> void:
	var espaco := get_world_2d().direct_space_state

	var params := PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	params.collide_with_bodies = false

	var resultados := espaco.intersect_point(params, 32)

	for resultado in resultados:
		var colisor = resultado["collider"]

		if colisor is Target and colisor.is_active:
			colisor.registrar_acerto()
			ScoreSystem.registrar_acerto(colisor.pontos)
			return

	ScoreSystem.registrar_erro()
