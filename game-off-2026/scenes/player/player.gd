class_name Player
extends RigidBody3D


# variables

@export_group("CoG")
@export var min_cg_z: float = -0.9
@export var max_cg_z: float = 0.7
@export var cg_x_width: float = 1.2
@export var cg_trans_trim: float = -0.08
@export var cg_trans_speed: float = 2.4
@export var cg_trans_trim_speed: float = 0.6
@export var cg_return_speed: float = 4.8


@export_group("Player Velocity")
@export var initial_speed := 20

var initial_transform: Transform3D
var initial_cg: Vector3
var cg_xz_trim: Vector2


@onready var cg_marker: Node3D = $CoG/Mesh
@onready var cg_range: MeshInstance3D = $CoG/RangeMesh
@onready var landing_sensors: Node3D = $LandingSensors


# main functions

func _ready() -> void:
	initial_transform = global_transform
	center_of_mass.z += cg_trans_trim
	initial_cg = center_of_mass
	reset_cg_trim()
	lock_rotation = false
	cg_range.position.y = center_of_mass.y
	var cg_plane := cg_range.mesh as PlaneMesh
	cg_plane.size.y = max_cg_z - min_cg_z
	cg_plane.size.x = cg_x_width
	cg_plane.center_offset.z = (max_cg_z + min_cg_z)/2
	set_initial_velocity()


func _physics_process(delta: float) -> void:
	# cg marker
	if is_instance_valid(cg_marker):
		cg_marker.position = center_of_mass

	# input handling
	if GameInputs.trim_mode:
		trim_cg(delta)
	else:
		shift_cg(delta)

	if GameInputs.trim_reset_activated:
		hard_reset_cg_trim()
		GameInputs.deactivate_trim_reset()


func set_initial_velocity() -> void:
	linear_velocity = initial_transform.basis.z * -initial_speed


func reset_body() -> void:
	set_initial_velocity()
	global_transform = initial_transform
	angular_velocity = Vector3.ZERO
	landing_sensors.reset()
	GameInputs.reset_applied()


# cg control

func shift_cg(delta: float) -> void:
	var input_dir = GameInputs.input_axis
	if input_dir != Vector2.ZERO:
		center_of_mass.x = clamp(
			center_of_mass.x + cg_trans_speed * delta * input_dir.x, -cg_x_width/2, cg_x_width/2
		)
		center_of_mass.z = clamp(
			center_of_mass.z + cg_trans_speed * delta * input_dir.y, min_cg_z, max_cg_z
		)
	else:
		var peso := 1.0 - exp(-cg_return_speed * delta)
		center_of_mass.x = lerp(center_of_mass.x, cg_xz_trim.x, peso)
		center_of_mass.z = lerp(center_of_mass.z, cg_xz_trim.y, peso)


func trim_cg(delta: float) -> void:
	var input_dir = GameInputs.input_axis
	if input_dir != Vector2.ZERO:
		center_of_mass.x = clamp(
			center_of_mass.x + cg_trans_trim_speed * delta * input_dir.x, -0.5, 0.5
		)
		center_of_mass.z = clamp(
			center_of_mass.z + cg_trans_trim_speed * delta * input_dir.y, min_cg_z, max_cg_z
		)
		reset_cg_trim()


func reset_cg_trim() -> void:
	cg_xz_trim = Vector2(center_of_mass.x, center_of_mass.z)


func hard_reset_cg_trim() -> void:
	cg_xz_trim = Vector2(initial_cg.x, initial_cg.z)
