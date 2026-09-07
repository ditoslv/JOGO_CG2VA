extends Node2D

@export var tipo_movimento: int = 1 

var vetor_velocidade = Vector2(150, 0) 
var velocidade_angular = 2.0           
var tempo_decorrido = 0.0              

func _process(delta: float) -> void:
	
	# Translação: P' = P + T
	if tipo_movimento == 1 or tipo_movimento == 4:
		position += vetor_velocidade * delta
		if position.x > 1200:
			position.x = -100

	# Rotação: R(θ)
	if tipo_movimento == 2 or tipo_movimento == 4:
		rotation += velocidade_angular * delta

	# Escala e Interpolação (Pulso)
	if tipo_movimento == 3 or tipo_movimento == 4:
		tempo_decorrido += delta
		var fator_escala = 1.0 + (sin(tempo_decorrido * 5.0) * 0.3)
		scale = Vector2(fator_escala, fator_escala)
