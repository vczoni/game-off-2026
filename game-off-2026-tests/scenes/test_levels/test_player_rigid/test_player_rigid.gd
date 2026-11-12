extends RigidBody3D


# variables

@export var cg_trans_speed: float = 0.6
@export var initial_speed: float  = 20.0

var initial_transform: Transform3D
var initial_velocity: Vector3
var initial_cg: Vector3
var reset_requested := false

@onready var cg_marker: MeshInstance3D = $CoG/Mesh
@onready var cg_range: MeshInstance3D = $CoG/RangeMesh

# main functions

func _ready() -> void:
	initial_transform = global_transform
	linear_velocity = Vector3(0, 0, -initial_speed)
	initial_velocity = linear_velocity
	initial_cg = center_of_mass
	lock_rotation = false
	cg_range.position.y = center_of_mass.y


func _physics_process(delta: float) -> void:
	if reset_requested:
		reset_transform()

	if is_instance_valid(cg_marker):
		cg_marker.position = center_of_mass

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back").normalized()
	if input_dir != Vector2.ZERO:
		center_of_mass.x = clamp(
			center_of_mass.x + cg_trans_speed * delta * input_dir.x, -0.5, 0.5
		)
		center_of_mass.z = clamp(
			center_of_mass.z + cg_trans_speed * delta * input_dir.y, -0.5, 0.5
		)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reset_postition"):
		reset_requested = true


func reset_transform() -> void:
	global_transform = initial_transform
	linear_velocity = initial_velocity
	center_of_mass = initial_cg
	angular_velocity = Vector3.ZERO
	sleeping = false
	reset_requested = false

# aux functions
