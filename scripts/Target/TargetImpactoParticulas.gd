extends CPUParticles2D
## Efeito de partículas de impacto do Target.
##
## Por que este script existe (e não fica dentro de Target.gd):
## Target.registrar_acerto() torna o nó inteiro invisível (visible = false)
## na mesma hora em que o acerto acontece, para o alvo sumir da tela.
## Em Godot, quando um nó pai fica invisível, TODOS os filhos somem junto —
## inclusive um CPUParticles2D que tenha acabado de começar a emitir.
## Resultado: sem essa lógica, a explosão de partículas nunca chegaria a
## aparecer, porque o alvo desaparece no mesmo frame em que ela começaria.
##
## Solução: este nó fica como "molde" (nunca emite ele mesmo). A cada
## acerto, ele cria uma CÓPIA de si mesmo, direto na cena principal
## (fora da árvore do Target), toca a explosão nessa cópia e a destrói
## em seguida. Assim a explosão continua visível mesmo com o alvo
## já escondido — e o alvo original continua reutilizável pelo
## TargetSpawner (pool), porque nunca é removido da árvore.
##
## Não depende de nenhuma mudança em Target.gd, TargetSpawner.gd ou
## Disparo.gd — só escuta o sinal público "target_hit" do alvo pai.

func _ready() -> void:
	emitting = false
	var alvo := get_parent()
	if alvo.has_signal("target_hit"):
		alvo.target_hit.connect(_tocar_copia)


func _tocar_copia(_pontos: int) -> void:
	var copia: CPUParticles2D = duplicate()
	copia.set_script(null)  # a cópia só precisa tocar e sumir, não escutar nada
	get_tree().current_scene.add_child(copia)
	copia.global_position = global_position
	copia.emitting = true
	await get_tree().create_timer(1.2).timeout
	copia.queue_free()
