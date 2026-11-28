extends Node3D


signal player_landed
signal player_crashed


@export var player: Player
@export var min_crash_velocity_kph: float = 30.0


@onready var approaching_sensor: RayCast3D = $ApproachingSensor
@onready var landing_sensor_l: RayCast3D = $LandingSensorL
@onready var landing_sensor_r: RayCast3D = $LandingSensorR
@onready var safe_landing_sensor: RayCast3D = $SafeLandingSensor
@onready var crash_landing_sensor: RayCast3D = $CrashLandingSensor
@onready var bonus_label: Label3D = $BonusLabel


enum LandingState {
	START,
	FLYING,
	APPROACHING,
	LANDING,
	SAFELY_STOPPING,
	UNSAFELY_STOPPING,
	CRASHING,
	CRASHED,
	LANDED,
}

const BONUS_STATES: Array[LandingState] = [
	LandingState.APPROACHING,
	LandingState.LANDING,
	LandingState.UNSAFELY_STOPPING,
	LandingState.SAFELY_STOPPING,
]

var state: LandingState
var player_velocity_kph: float
var approaching_height: float = -1.0
var _landing_bonus: float = 1.0
var landing_bonus: float = 1.0

var safe_velocity: bool:
	get:
		return player_velocity_kph < min_crash_velocity_kph


# main functions

func _ready() -> void:
	reset()


func _physics_process(delta: float) -> void:
	# safe velocity check
	player_velocity_kph = player.linear_velocity.length() / 3.6

	# state check
	check_state(delta)


# landing states

func reset() -> void:
	approaching_height = -1.0
	kill_landing_bonus()
	landing_bonus = 1.0
	state = LandingState.START


func check_state(delta: float) -> void:
	if state == LandingState.START:
		start_state()
	if state == LandingState.FLYING:
		flying_state()
	elif state == LandingState.APPROACHING:
		approaching_state(delta)
	elif state == LandingState.CRASHING:
		crashing_state()
	elif state == LandingState.LANDING:
		landing_state()
	elif state == LandingState.SAFELY_STOPPING:
		safe_stopping_state(delta)
	elif state == LandingState.UNSAFELY_STOPPING:
		unsafe_stopping_state(delta)
	elif state == LandingState.LANDED:
		landed_state()
	elif state == LandingState.CRASHED:
		crashed_state()


func enter_state(new_state: LandingState) -> void:
	# landing signaling
	if new_state == LandingState.LANDED:
		register_landing_bonus()
	elif new_state == LandingState.CRASHED:
		player_crashed.emit()

	# landing bonus
	if state == LandingState.FLYING and new_state in BONUS_STATES:
		fadein_bonus_label()
	elif state in BONUS_STATES and new_state == LandingState.FLYING:
		fadeout_bonus_label()

	# set new state
	prints("old:", LandingState.find_key(state), "\tnew:", LandingState.find_key(new_state))
	state = new_state


# state functions

func start_state() -> void:
	if not approaching_sensor.is_colliding():
		enter_state(LandingState.FLYING)


func flying_state() -> void:
	if approaching_sensor.is_colliding():
		enter_state(LandingState.APPROACHING)
	elif crash_landing_sensor.is_colliding():
		enter_state(LandingState.CRASHING)


func approaching_state(delta: float) -> void:
	if landing_sensor_l.is_colliding() or landing_sensor_r.is_colliding():
		enter_state(LandingState.LANDING)
		approaching_height = -1.0
	elif crash_landing_sensor.is_colliding():
		enter_state(LandingState.CRASHING)
		approaching_height = -1.0
	elif not approaching_sensor.is_colliding():
		enter_state(LandingState.FLYING)
		approaching_height = -1.0
		fadeout_bonus_label()

	approaching_height = (
		approaching_sensor.global_position - approaching_sensor.get_collision_point()
	).y
	add_approach_bonus(delta)


func landing_state() -> void:
	if safe_landing_sensor.is_colliding():
		enter_state(LandingState.SAFELY_STOPPING)
	elif (
		approaching_sensor.is_colliding()
		and not landing_sensor_l.is_colliding()
		and not landing_sensor_r.is_colliding()
	):
		enter_state(LandingState.APPROACHING)
	elif crash_landing_sensor.is_colliding():
		enter_state(LandingState.UNSAFELY_STOPPING)
	elif not approaching_sensor.is_colliding():
		enter_state(LandingState.FLYING)
		fadeout_bonus_label()


func safe_stopping_state(delta: float) -> void:
	if (
		not landing_sensor_l.is_colliding() and not landing_sensor_r.is_colliding()
		and not safe_landing_sensor.is_colliding()
	):
		enter_state(LandingState.APPROACHING)
	elif crash_landing_sensor.is_colliding():
		enter_state(LandingState.UNSAFELY_STOPPING)
	elif round(player_velocity_kph) == 0:
		land()
	add_stopping_bonus(delta)


func unsafe_stopping_state(delta: float) -> void:
	if not safe_velocity:
		crash()
	elif not landing_sensor_l.is_colliding() and not landing_sensor_r.is_colliding():
		crash()
	elif round(player_velocity_kph) == 0:
		land()
	add_unsafe_stopping_bonus(delta)


func crashing_state() -> void:
	if not safe_velocity:
		crash()
	elif landing_sensor_l.is_colliding() and landing_sensor_r.is_colliding():
		enter_state(LandingState.LANDING)
	else:
		crash()


func land() -> void:
	enter_state(LandingState.LANDED)
	player_landed.emit()
	fadeout_bonus_label()


func landed_state() -> void:
	pass


func crash() -> void:
	enter_state(LandingState.CRASHED)


func crashed_state() -> void:
	pass


# landing bonus

func register_landing_bonus() -> void:
	landing_bonus = _landing_bonus


func kill_landing_bonus() -> void:
	bonus_label.hide()
	_landing_bonus = 1.0


func add_approach_bonus(delta: float) -> void:
	_landing_bonus += (approaching_height**-0.7*player_velocity_kph**-1.3) * delta
	bonus_label.text = "x%.3f" % _landing_bonus


func add_stopping_bonus(delta: float) -> void:
	_landing_bonus *= 1 + (1/max(0.4, (player_velocity_kph + 0.2))**1.4)/10 * delta
	bonus_label.text = "x%.3f" % _landing_bonus


func add_unsafe_stopping_bonus(delta: float) -> void:
	_landing_bonus -= delta / 3
	bonus_label.text = "x%.3f" % _landing_bonus


func fadein_bonus_label(tween_time: float = 0.3) -> void:
	bonus_label.modulate.a = 0
	bonus_label.show()
	var tween := create_tween()
	tween.tween_property(bonus_label, "modulate:a", 1, tween_time)
	tween.parallel().tween_property(bonus_label, "outline_modulate:a", 1, tween_time/2)
	await tween.finished


func fadeout_bonus_label(tween_time: float = 1.0, after: float = 0) -> void:
	if after > 0:
		await get_tree().create_timer(after).timeout

	var tween := create_tween()
	tween.tween_property(bonus_label, "modulate:a", 0, tween_time)
	tween.parallel().tween_property(bonus_label, "outline_modulate:a", 0, tween_time/2)
	await tween.finished
	kill_landing_bonus()
