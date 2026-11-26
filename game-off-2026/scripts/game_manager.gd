# Autoload "GameManager"
extends Node


# game states

enum GameState {
	SPLASH,
	TITLE_SCREEN,
	PLAYING,
	PAUSED,
	CRASHED,
	LEVEL_COMPLETE,
	CREDITS,
}

var state: GameState
var main: Node


# functions

func change_to_main() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/main.tscn")


func init_main() -> void:
	main = get_tree().current_scene


func start_game() -> void:
	main.start_game()
	enter_state(GameState.PLAYING)


func enter_state(new_state: GameState) -> void:
	if new_state == GameState.TITLE_SCREEN:
		get_tree().paused = true
		main.set_title_screen()
	if new_state == GameState.PLAYING:
		get_tree().paused = false
		main.unpause_game()
	elif new_state == GameState.PAUSED:
		get_tree().paused = true
		main.pause_game()
	elif new_state == GameState.CRASHED:
		get_tree().paused = false
		main.crash_routine()
	elif new_state == GameState.LEVEL_COMPLETE:
		get_tree().paused = false
		main.level_complete_routine()

	state = new_state


func pause_routine() -> void:
	if state == GameState.PLAYING:
		enter_state(GameState.PAUSED)
	elif state == GameState.PAUSED:
		enter_state(GameState.PLAYING)


func land_routine() -> void:
	enter_state(GameState.LEVEL_COMPLETE)


func crash_routine() -> void:
	enter_state(GameState.CRASHED)


func reset_routine() -> void:
	GameInputs.request_reset()
	enter_state(GameState.PLAYING)


# flags

func is_on_titlescreen() -> bool:
	return state == GameState.TITLE_SCREEN

func is_playing() -> bool:
	return state == GameState.PLAYING

func is_paused() -> bool:
	return state == GameState.PAUSED

func is_crashed() -> bool:
	return state == GameState.CRASHED

func is_landed() -> bool:
	return state == GameState.LEVEL_COMPLETE
