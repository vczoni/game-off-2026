# GameManager.gd — configurado como Autoload "GameManager"
extends Node


# game states

enum GameState {
	SPLASH,
	TITLE_SCREEN,
	PLAYING,
	PAUSED,
	GAME_OVER,
}

var state: GameState


# functions

func show_title() -> void:
	state = GameState.TITLE_SCREEN
	get_tree().change_scene_to_file("res://scenes/levels/main.tscn")


func start_game() -> void:
	var main := get_tree().current_scene
	main.start_game()
