@tool
extends Area2D
signal acertou

func _draw():
	draw_circle(Vector2.ZERO, 60, Color.WHITE)
	draw_circle(Vector2.ZERO, 45, Color.BLACK)
	draw_circle(Vector2.ZERO, 30, Color.RED)
	draw_circle(Vector2.ZERO, 15, Color.BLACK)
	
func nova_posicao():
	position = Vector2(
		randf_range(100, 700),
		randf_range(100, 500)
	)
	
@warning_ignore("unused_parameter")
func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			acertou.emit()
			nova_posicao()
