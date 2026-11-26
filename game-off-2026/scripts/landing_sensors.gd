extends Node3D


signal player_landed
signal player_crashed


@export var player: Player
@export var min_crash_velocity_kph: float = 30.0
@export var landed_signal_delay: float = 1.6


@onready var approaching_sensor: RayCast3D = $ApproachingSensor
@onready var landing_sensor_l: RayCast3D = $LandingSensorL
@onready var landing_sensor_r: RayCast3D = $LandingSensorR
@onready var safe_landing_sensor: RayCast3D = $SafeLandingSensor
@onready var crash_landing_sensor: RayCast3D = $CrashLandingSensor


enum LandingState {
	FLYING,
	APPROACHING,
	LANDING,
	SAFELY_STOPPING,
	UNSAFELY_STOPPING,
	CRASHING,
	CRASHED,
	LANDED,
}

var state: LandingState
var player_velocity_kph: float
var approaching_height: float = -1.0

var safe_velocity: bool:
	get:
		return player_velocity_kph < min_crash_velocity_kph


# main functions

func _ready() -> void:
	reset()


func _physics_process(_delta: float) -> void:
	# safe velocity check
	player_velocity_kph = player.linear_velocity.length() / 3.6

	# state check
	check_state()


# landing states

func reset() -> void:
	enter_state(LandingState.FLYING)
	approaching_height = -1.0


func check_state() -> void:
	if state == LandingState.FLYING:
		flying_state()
	elif state == LandingState.APPROACHING:
		approaching_state()
	elif state == LandingState.CRASHING:
		crashing_state()
	elif state == LandingState.LANDING:
		landing_state()
	elif state == LandingState.SAFELY_STOPPING:
		safe_stopping_state()
	elif state == LandingState.UNSAFELY_STOPPING:
		unsafe_stopping_state()
	elif state == LandingState.LANDED:
		landed_state()
	elif state == LandingState.CRASHED:
		crashed_state()


func enter_state(new_state: LandingState) -> void:
	if new_state == LandingState.LANDED:
		await get_tree().create_timer(landed_signal_delay).timeout
		player_landed.emit()
	elif new_state == LandingState.CRASHED:
		player_crashed.emit()

	state = new_state


# state functions

func flying_state() -> void:
	if approaching_sensor.is_colliding():
		enter_state(LandingState.APPROACHING)
	elif crash_landing_sensor.is_colliding():
		enter_state(LandingState.CRASHING)


func approaching_state() -> void:
	if landing_sensor_l.is_colliding() or landing_sensor_r.is_colliding():
		enter_state(LandingState.LANDING)
		approaching_height = -1.0
	elif crash_landing_sensor.is_colliding():
		enter_state(LandingState.CRASHING)
		approaching_height = -1.0
	elif not approaching_sensor.is_colliding():
		enter_state(LandingState.FLYING)
		approaching_height = -1.0

	approaching_height = (
		approaching_sensor.global_position - approaching_sensor.get_collision_point()
	).y


func landing_state() -> void:
	if (
		approaching_sensor.is_colliding()
		and not landing_sensor_l.is_colliding()
		and not landing_sensor_r.is_colliding()
	):
		enter_state(LandingState.APPROACHING)
	elif safe_landing_sensor.is_colliding():
		enter_state(LandingState.SAFELY_STOPPING)
	elif crash_landing_sensor.is_colliding():
		enter_state(LandingState.UNSAFELY_STOPPING)
	elif not approaching_sensor.is_colliding():
		enter_state(LandingState.FLYING)


func safe_stopping_state() -> void:
	if (
		not landing_sensor_l.is_colliding() and not landing_sensor_r.is_colliding()
		and not safe_landing_sensor.is_colliding()
	):
		crash()
	elif round(player_velocity_kph) == 0:
		land()


func unsafe_stopping_state() -> void:
	if not safe_velocity:
		crash()
	elif not landing_sensor_l.is_colliding() and not landing_sensor_r.is_colliding():
		crash()
	elif round(player_velocity_kph) == 0:
		land()


func crashing_state() -> void:
	if not safe_velocity:
		crash()
	elif landing_sensor_l.is_colliding() and landing_sensor_r.is_colliding():
		enter_state(LandingState.LANDING)
	else:
		crash()


func land() -> void:
	enter_state(LandingState.LANDED)


func landed_state() -> void:
	pass


func crash() -> void:
	enter_state(LandingState.CRASHED)


func crashed_state() -> void:
	pass
