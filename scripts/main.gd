extends Node2D

var pontos = 0

func _on_alvo_acertou():
	pontos += 1
	$Pontuacao.text = "Pontos: " + str(pontos)
