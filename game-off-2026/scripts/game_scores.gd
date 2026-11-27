extends Node


var level_best_distance: Array[float]
var level_best_topspeed: Array[float]
var level_best_landing_bonus: Array[float]
var level_best_score: Array[int]


func reset_best_scores(n_levels: int) -> void:
	for i in range(n_levels):
		level_best_distance.append(0.0)
		level_best_topspeed.append(0.0)
		level_best_landing_bonus.append(1.0)
		level_best_score.append(0)

# getters
func get_best_distance(level_id: int) -> float:
	return level_best_distance[level_id-1]

func get_best_topspeed(level_id: int) -> float:
	return level_best_topspeed[level_id-1]

func get_best_landing_bonus(level_id: int) -> float:
	return level_best_landing_bonus[level_id-1]

func get_best_score(level_id: int) -> int:
	return level_best_score[level_id-1]

# setters
func check_and_set_best_distance(level_id: int, value: float) -> void:
	if level_best_distance[level_id-1] < value:
		level_best_distance[level_id-1] = value

func check_and_set_best_topspeed(level_id: int, value: float) -> void:
	if level_best_topspeed[level_id-1] < value:
		level_best_topspeed[level_id-1] = value

func check_and_set_best_landing_bonus(level_id: int, value: float) -> void:
	if level_best_landing_bonus[level_id-1] < value:
		level_best_landing_bonus[level_id-1] = value

func check_and_set_best_score(level_id: int, value: int) -> void:
	if level_best_score[level_id-1] < value:
		level_best_score[level_id-1] = value
