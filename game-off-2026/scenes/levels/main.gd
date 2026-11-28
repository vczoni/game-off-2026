extends Node3D


@export var game_state: GameManager.GameState
@export var initial_level_id: int = 1

@onready var player: Player = $Player
@onready var camera_follow: CameraFollow = $CameraFollow
@onready var game_hud: GameHUD = $UI/HUD
@onready var title_screen: CanvasLayer = $UI/TitleScreen
@onready var pause_screen: CanvasLayer = $UI/PauseScreen
@onready var control_screen: CanvasLayer = $UI/Controls
@onready var crashed_screen: CanvasLayer = $UI/CrashedScreen
@onready var landed_screen: CanvasLayer = $UI/LandedScreen
@onready var fade_to_black: ColorRect = $UI/FadeToBlack

const LEVEL_PATHS: Array[String] = [
	"res://scenes/levels/level_01.tscn",
	"res://scenes/levels/level_02.tscn",
]

var current_level_id: int
var current_level: Node3D
var n_levels: int

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
	n_levels = len(LEVEL_PATHS)
	main_level_setup()
	GameManager.init_main()
	GameManager.enter_state(game_state)
	player.landing_sensors.player_landed.connect(GameManager.land_routine)
	player.landing_sensors.player_crashed.connect(GameManager.crash_routine)


func _process(_delta: float) -> void:
	if GameInputs.reset_requested:
		reset_player()
		return

	v_player = player.linear_velocity.length()
	process_distance()
	update_score()
	update_hud()


func main_level_setup() -> void:
	hide_ui()
	set_current_level(initial_level_id)
	reset_level()
	update_hud_best_values()
	print(distance)


func reset_level() -> void:
	_initial_player_position = player.global_position
	GameScores.reset_best_scores(n_levels)
	reset_score_aux_vars()


func hide_ui() -> void:
	game_hud.hide()
	pause_screen.hide()
	control_screen.hide()
	title_screen.hide()
	crashed_screen.hide()
	landed_screen.hide()


func reset_player() -> void:
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
	game_hud.update_best_max_speed(current_level_id)
	game_hud.update_best_distance(current_level_id)
	game_hud.update_best_landing_bonus(current_level_id)
	game_hud.update_best_score(current_level_id)


func set_title_screen() -> void:
	hide_ui()
	title_screen.show()


func start_game() -> void:
	hide_ui()
	game_hud.show()
	camera_follow.set_to_follow()


func pause_game() -> void:
	hide_ui()
	game_hud.show()
	pause_screen.show()
	camera_follow.set_to_orbit()


func show_control() -> void:
	hide_ui()
	control_screen.show()


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
	landed_screen.write_scores(score, GameScores.get_best_score(current_level_id))


func register_best_scores() -> void:
	GameScores.check_and_set_best_distance(current_level_id, distance)
	GameScores.check_and_set_best_topspeed(current_level_id, v_max)
	GameScores.check_and_set_best_landing_bonus(current_level_id, player.landing_sensors.landing_bonus)
	GameScores.check_and_set_best_score(current_level_id, score)
	update_hud_best_values()


# level managemnent

func get_level_path(level_id: int) -> String:
	return LEVEL_PATHS[level_id-1]


func set_current_level(level_id: int) -> void:
	# set level
	current_level_id = level_id
	var level_scene := load(get_level_path(level_id)) as PackedScene
	current_level = level_scene.instantiate()
	add_child(current_level)

	# reposition player
	var spawn := current_level.get_node("PlayerPlaceholder") as PlayerPlaceholder
	player.global_transform = spawn.global_transform
	player.initial_speed = spawn.player_initial_speed
	player.init_player()
	spawn.hide()
	camera_follow.start()


func change_level(level_id: int) -> void:
	GameManager.reset_routine()
	current_level.queue_free()
	set_current_level(level_id)
	reset_level()


func next_level() -> void:
	if current_level_id < n_levels:
		change_level(current_level_id+1)
		camera_follow.set_to_follow()
	else:
		game_over()


func game_over() -> void:
	change_level(1)
	GameManager.restart_soft()
