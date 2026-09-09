extends CanvasLayer

## ============================================================
## Painel de pausa — "Pausa e retomada" (cena PauseMenu, Seção
## G.2 do planejamento).
##
## Qualquer modo (Solo ou 1v1) pode instanciar esta
## cena como filha e não precisa fazer mais nada: ela mesma
## escuta o ESC, pausa a árvore (get_tree().paused) e cuida da
## navegação de volta ao menu.
##
## É um CanvasLayer (não mais um Control puro) com "layer" alto de
## propósito: antes disso, o painel de pausa nascia na mesma camada
## de canvas que o jogo (Mira, alvos) e do HUD (que já usa seu
## próprio CanvasLayer). Resultado: mesmo com visible = true e o
## jogo de fato pausado, o conteúdo do jogo continuava desenhado por
## cima da tela de pausa em vez de ficar coberto por ela. Um
## CanvasLayer com layer maior que o do HUD garante que a pausa
## sempre desenhe por cima de tudo.
## ============================================================

signal retomar_solicitado()
signal voltar_ao_menu_solicitado()

@onready var botao_continuar: Button = $PainelCentral/BotaoContinuar
@onready var botao_menu: Button = $PainelCentral/BotaoVoltarMenu


func _ready() -> void:
	# Precisa continuar recebendo input mesmo com o jogo pausado,
	# senão o próprio botão "Continuar" fica inacessível.
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	botao_continuar.pressed.connect(_on_botao_continuar_pressed)
	botao_menu.pressed.connect(_on_botao_menu_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # ESC, por padrão no Godot
		if visible:
			fechar()
		else:
			abrir()


func abrir() -> void:
	visible = true
	get_tree().paused = true


func fechar() -> void:
	visible = false
	get_tree().paused = false


func _on_botao_continuar_pressed() -> void:
	fechar()
	retomar_solicitado.emit()


func _on_botao_menu_pressed() -> void:
	get_tree().paused = false
	voltar_ao_menu_solicitado.emit()
	get_tree().change_scene_to_file("res://scenes/menu/Menu.tscn")
