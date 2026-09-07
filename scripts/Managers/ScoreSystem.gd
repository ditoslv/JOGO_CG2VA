extends Node

## Autoload. Registrar em: Project Settings > Autoload
##   Path: res://scripts/Managers/ScoreSystem.gd
##   Node Name: ScoreSystem
## A partir daí, "ScoreSystem" fica acessível globalmente por qualquer
## script do projeto (Disparo.gd, HUD da Pessoa 2, telas de resultado, etc.)
## sem precisar de referência explícita.

signal score_updated(dados: Dictionary)

var _pontuacao: int = 0
var _acertos: int = 0
var _erros: int = 0
var _tentativas: int = 0


## Chamada no início de cada rodada (Solo, e em cada uma das duas
## execuções do 1v1).
func resetar() -> void:
	_pontuacao = 0
	_acertos = 0
	_erros = 0
	_tentativas = 0
	_emitir_atualizacao()


## Chamada pelo Disparo.gd quando o clique acerta um Target ativo.
func registrar_acerto(pontos: int) -> void:
	_pontuacao += pontos
	_acertos += 1
	_tentativas += 1
	_emitir_atualizacao()


## Chamada pelo Disparo.gd quando o clique não acerta nenhum Target.
func registrar_erro() -> void:
	_erros += 1
	_tentativas += 1
	_emitir_atualizacao()


func obter_precisao() -> float:
	if _tentativas == 0:
		return 0.0
	return float(_acertos) / float(_tentativas)


## Usada pela tela de resultados (Pessoa 2) e pelo VersusMode (1v1).
func obter_resultado_final() -> Dictionary:
	return {
		"pontuacao": _pontuacao,
		"acertos": _acertos,
		"erros": _erros,
		"tentativas": _tentativas,
		"precisao": obter_precisao(),
	}


func _emitir_atualizacao() -> void:
	score_updated.emit(obter_resultado_final())
