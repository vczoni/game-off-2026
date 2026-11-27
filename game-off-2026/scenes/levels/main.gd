extends Node3D


@export var game_state: GameManager.GameState

@onready var player: Player = $Level01/Player
@onready var camera_follow: CameraFollow = $Level01/CameraFollow
@onready var game_hud: GameHUD = $UI/HUD
@onready var title_screen: CanvasLayer = $UI/TitleScreen
@onready var pause_screen: CanvasLayer = $UI/PauseScreen
@onready var crashed_screen: CanvasLayer = $UI/CrashedScreen
@onready var landed_screen: CanvasLayer = $UI/LandedScreen
@onready var fade_to_black: ColorRect = $UI/FadeToBlack

var current_level: int
var n_levels: int = 1
var _initial_player_position: Vector3
var _last_player_position: Vector3
var v_player: float
var v_max: float
var distance: float

var altitude: float:
	get:
		return player.global_position.y

var score: int:
	get:
		return int(distance * v_max * player.landing_sensors.landing_bonus)


# functions

func _ready() -> void:
	main_level_setup()
	GameManager.init_main()
	GameManager.enter_state(game_state)
	player.landing_sensors.player_landed.connect(GameManager.land_routine)
	player.landing_sensors.player_crashed.connect(GameManager.crash_routine)


func _process(_delta: float) -> void:
	if GameInputs.reset_requested:
		reset_level()
		return

	v_player = player.linear_velocity.length()
	process_distance()
	update_score()
	update_hud()


func main_level_setup() -> void:
	hide_ui()
	_initial_player_position = player.global_position
	GameScores.reset_best_scores(n_levels)
	reset_score_aux_vars()
	set_current_level(1)
	update_hud_best_values()


func hide_ui() -> void:
	game_hud.hide()
	pause_screen.hide()
	title_screen.hide()
	crashed_screen.hide()
	landed_screen.hide()


func reset_level() -> void:
	player.reset_body()
	camera_follow.reset_position()
	reset_score_aux_vars()


func reset_score_aux_vars() -> void:
	_last_player_position = _initial_player_position
	v_max = 0
	v_player = 0
	distance = 0


func process_distance() -> void:
	var d: float = (player.global_position - _last_player_position).length()
	if d >= 1.0:
		distance += d
		_last_player_position = player.global_position


func update_score() -> void:
	if v_max < v_player:
		v_max = v_player


func update_hud() -> void:
	game_hud.update_altitude(int(altitude))
	game_hud.update_distance(int(distance))
	game_hud.update_speed(v_player)
	game_hud.update_max_speed(v_max)
	game_hud.update_score(score)


func update_hud_best_values() -> void:
	game_hud.update_best_max_speed(current_level)
	game_hud.update_best_distance(current_level)
	game_hud.update_best_landing_bonus(current_level)
	game_hud.update_best_score(current_level)


func set_title_screen() -> void:
	title_screen.show()
	camera_follow.set_to_orbit()
	get_tree().paused = true


func start_game() -> void:
	hide_ui()
	game_hud.show()
	camera_follow.set_to_follow()


func pause_game() -> void:
	hide_ui()
	game_hud.show()
	pause_screen.show()
	camera_follow.set_to_orbit()


func unpause_game() -> void:
	hide_ui()
	game_hud.show()
	camera_follow.set_to_follow()


func crash_routine() -> void:
	hide_ui()
	crashed_screen.show()
	camera_follow.set_to_crashed()


func level_complete_routine() -> void:
	hide_ui()
	landed_screen.show()
	camera_follow.set_to_orbit()
	register_best_scores()
	landed_screen.write_scores(score, GameScores.get_best_score(current_level))


func register_best_scores() -> void:
	GameScores.check_and_set_best_distance(current_level, distance)
	GameScores.check_and_set_best_topspeed(current_level, v_max)
	GameScores.check_and_set_best_landing_bonus(current_level, player.landing_sensors.landing_bonus)
	GameScores.check_and_set_best_score(current_level, score)
	update_hud_best_values()


# level managemnent

func set_current_level(level_id: int) -> void:
	current_level = level_id


func next_level() -> void:
	pass
