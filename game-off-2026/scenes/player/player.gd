class_name Player
extends RigidBody3D


# variables

@export_group("CoG")
@export var min_cg_z: float = -0.9
@export var max_cg_z: float = 0.7
@export var cd_trans_trim: float = -0.08
@export var cg_trans_speed: float = 2.4
@export var cg_return_speed: float = 4.8


@export_group("Player Velocity")
@export var initial_speed := 20

var initial_transform: Transform3D
var initial_cg: Vector3

@onready var cg_marker: Node3D = $CoG/Mesh
@onready var cg_range: MeshInstance3D = $CoG/RangeMesh

# main functions

func _ready() -> void:
	initial_transform = global_transform
	center_of_mass.z += cd_trans_trim
	initial_cg = center_of_mass
	lock_rotation = false
	cg_range.position.y = center_of_mass.y
	var plane := cg_range.mesh as PlaneMesh
	plane.size.y = max_cg_z - min_cg_z
	plane.center_offset.z = (max_cg_z + min_cg_z)/2
	set_initial_velocity()


func _physics_process(delta: float) -> void:

	if is_instance_valid(cg_marker):
		cg_marker.position = center_of_mass

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back").normalized()
	if input_dir != Vector2.ZERO:
		center_of_mass.x = clamp(
			center_of_mass.x + cg_trans_speed * delta * input_dir.x, -0.5, 0.5
		)
		center_of_mass.z = clamp(
			center_of_mass.z + cg_trans_speed * delta * input_dir.y, min_cg_z, max_cg_z
		)
	else:
		var peso := 1.0 - exp(-cg_return_speed * delta)
		center_of_mass.x = lerp(center_of_mass.x, initial_cg.x, peso)
		center_of_mass.z = lerp(center_of_mass.z, initial_cg.z, peso)


func set_initial_velocity() -> void:
	linear_velocity = global_basis.z * -initial_speed
