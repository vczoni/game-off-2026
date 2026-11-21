class_name RigidTests
extends Node3D


@export var object: RigidBody3D
@export var cg_ball: Node3D


var initial_transform: Transform3D
var initial_velocity: Vector3
var initial_angular_velocity: Vector3


func _ready() -> void:
	object.gravity_scale = 0
	initial_transform = object.transform
	initial_velocity = object.linear_velocity
	initial_angular_velocity = object.angular_velocity
	cg_ball.position = object.center_of_mass


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset_postition"):
		reset()
		return

	var command: float = Input.get_axis("move_left", "move_right")
	if command != 0:
		var m: Vector3 = Vector3(0, 0, -50*command) * global_basis.orthonormalized().inverse()
		object.apply_torque(m)
	else:
		var theta: float = object.angular_velocity.length()
		if theta > 0:
			#object.apply_torque(object.angular_velocity*-50)
			var s: float = sign(object.angular_velocity.z)
			var m: Vector3 = Vector3(0, 0, -s*100) * global_basis.orthonormalized().inverse()
			object.apply_torque(m)

	#var ycommand: float = Input.get_axis("move_back", "move_forward")


func reset() -> void:
	object.transform = initial_transform
	object.linear_velocity = initial_velocity
	object.angular_velocity = initial_angular_velocity
