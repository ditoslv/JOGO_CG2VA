extends Node2D

## ============================================================
## Cena de teste isolada — valida a ResultScreen no modo 1v1 sem
## precisar do VersusMode existir de verdade.
##
## Rode esta cena direto (F6 no Godot com ela aberta) e confira:
## - os dois painéis (Jogador 1 e Jogador 2) aparecem preenchidos
## - o Label de vencedor mostra o jogador com mais pontos
## - o botão "Voltar ao Menu" funciona
##
## Troque os valores abaixo pra testar também o caso de empate.
## ============================================================

const RESULT_SCREEN_SCENE := preload("res://scenes/ui/result_screen.tscn")


func _ready() -> void:
	var tela: Control = RESULT_SCREEN_SCENE.instantiate()
	add_child(tela)

	var dados_jogador1 := {
		"pontuacao": 80,
		"acertos": 8,
		"erros": 2,
		"tentativas": 10,
		"precisao": 0.8,
		"tempo": 42.3,
	}
	var dados_jogador2 := {
		"pontuacao": 95,
		"acertos": 9,
		"erros": 1,
		"tentativas": 10,
		"precisao": 0.9,
		"tempo": 38.7,
	}

	# Pra testar empate, comente a linha acima e use:
	# var dados_jogador2 := dados_jogador1.duplicate()

	tela.exibir_resultado_1v1(dados_jogador1, dados_jogador2)
