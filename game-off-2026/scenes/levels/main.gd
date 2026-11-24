extends Node3D


@export var game_state: GameManager.GameState

@onready var player: Player = $Level01/Player
@onready var camera_follow: CameraFollow = $Level01/CameraFollow
@onready var title_screen: CanvasLayer = $UI/TitleScreen
@onready var fade_to_black: ColorRect = $UI/FadeToBlack


func _ready() -> void:
	GameManager.state = game_state
	if GameManager.state == GameManager.GameState.TITLE_SCREEN:
		title_screen.show()
		camera_follow.set_to_orbit()
		get_tree().paused = true


func start_game() -> void:
	title_screen.hide()
	get_tree().paused = false
	camera_follow.set_to_follow()
