# Autoload "GameInputs"
extends Node


const DOUBLE_PRESS_MS := 300
var input_axis: Vector2
var _last_press_ms: int = -1

# flags
var reset_requested: bool = false
var trim_mode: bool = false
var trim_reset_activated: bool = false


# functions

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _physics_process(_delta: float) -> void:
	# WASD
	input_axis = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	# trim
	trim_mode = Input.is_action_pressed("set_trim")


func _unhandled_input(event: InputEvent) -> void:
	# pause
	if event.is_action_pressed("pause"):
		GameManager.pause_routine()

	# reset
	if event.is_action_pressed("reset") and GameManager.is_playing():
		request_reset()

	# trim
	if event.is_action_pressed("set_trim") and GameManager.is_playing():
		var now: int = Time.get_ticks_msec()
		var dt: int = now - _last_press_ms
		if _last_press_ms >= 0 and dt <= DOUBLE_PRESS_MS:
			_last_press_ms = -1
			activate_trim_reset()
		else:
			_last_press_ms = now


func request_reset() -> void:
	reset_requested = true


func reset_applied() -> void:
	reset_requested = false


func activate_trim_reset() -> void:
	trim_reset_activated = true


func deactivate_trim_reset() -> void:
	trim_reset_activated = false
