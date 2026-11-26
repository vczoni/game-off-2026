class_name GameHUD
extends CanvasLayer


# values - common
@onready var speed_label = $MarginContainer/VBoxContainer/CommonMetrics/Speed/Value
@onready var altitude_label = $MarginContainer/VBoxContainer/CommonMetrics/Altitude/Value

# values - score
@onready var distance_label = $MarginContainer/VBoxContainer/ScoreMetrics/DistanceValue
@onready var max_speed_label = $MarginContainer/VBoxContainer/ScoreMetrics/TopSpeedValue
@onready var landing_bonus_label = $MarginContainer/VBoxContainer/ScoreMetrics/LandingBonusValue
@onready var score_label = $MarginContainer/VBoxContainer/ScoreMetrics/ScoreValue

# values - best score values
@onready var best_distance_label = $MarginContainer/VBoxContainer/ScoreMetrics/DistanceBestValue
@onready var best_max_speed_label = $MarginContainer/VBoxContainer/ScoreMetrics/TopSpeedBestValue
@onready var best_landing_bonus_label = $MarginContainer/VBoxContainer/ScoreMetrics/LandingBonusBestValue
@onready var best_score_label = $MarginContainer/VBoxContainer/ScoreMetrics/ScoreBestValue


# values

func update_altitude(altitude: int) -> void:
	altitude_label.text = "%d m" % altitude

func update_speed(speed: float) -> void:
	speed_label.text = "%d kph" % int(speed * 3.6)

func update_distance(distance: int) -> void:
	distance_label.text = "%d m" % distance

func update_max_speed(max_speed: float) -> void:
	max_speed_label.text = "%d kph" % int(max_speed * 3.6)

func update_landing_bonus(landing_bonus: float) -> void:
	landing_bonus_label.text = "%.1f" % landing_bonus

func update_score(score: int) -> void:
	score_label.text = str(score)


# best values

func update_best_distance(distance: int) -> void:
	best_distance_label.text = "%d m" % distance

func update_best_max_speed(max_speed: float) -> void:
	best_max_speed_label.text = "%d kph" % int(max_speed * 3.6)

func update_best_landing_bonus(landing_bonus: float) -> void:
	best_landing_bonus_label.text = "%.1f" % landing_bonus

func update_best_score(score: int) -> void:
	best_score_label.text = str(score)
