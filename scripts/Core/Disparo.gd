extends Node2D
class_name Disparo

## Sistema de disparo instantâneo (hit-scan pontual), adequado para
## um shooting gallery sem deslocamento do jogador.
##
## Depende do Autoload "ScoreSystem" já registrado no projeto
## (Project Settings > Autoload) — ver ScoreSystem.gd.

@export var ativo: bool = true

## Quando true (padrão — usado pelo Solo/1v1/GameBase): qualquer alvo
## ativo atingido já vira pontuação automaticamente aqui.
## Quando false (usado pelo Modo Ordem do Alvo): este script continua
## detectando o clique e chamando colisor.registrar_acerto() — o que
## dispara o sinal público "target_hit" — mas NÃO chama ScoreSystem
## sozinho. Quem decide se foi acerto ou erro nesse caso é o próprio
## modo, escutando "target_hit" (ver order_mode.gd -> validar_acerto()).
## Isso evita pontuar duas vezes o mesmo clique (uma vez aqui, outra
## vez na validação de sequência do modo).
@export var pontuar_automaticamente: bool = true


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
	params.collide_with_areas = true   # IMPORTANTE: Target é Area2D
	params.collide_with_bodies = false

	var resultados := espaco.intersect_point(params, 32)

	for resultado in resultados:
		var colisor = resultado["collider"]

		if colisor is Target and colisor.is_active:
			colisor.registrar_acerto()
			if pontuar_automaticamente:
				ScoreSystem.registrar_acerto(colisor.pontos)
			return

	ScoreSystem.registrar_erro()
