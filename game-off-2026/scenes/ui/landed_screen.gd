extends CanvasLayer


@onready var score_label = \
	$MarginContainer/VBoxContainer/ButtonContainer/MarginContainer/GridContainer/ScoreValue
@onready var best_score_label = \
	$MarginContainer/VBoxContainer/ButtonContainer/MarginContainer/GridContainer/BestScoreValue


func write_scores(score: int, best_score: int) -> void:
	score_label.text = str(score)
	best_score_label.text = str(best_score)
