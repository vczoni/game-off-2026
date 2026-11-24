class_name CameraFollow
extends Camera3D


@export var target: Node3D
@export var camera_distance_y: float = 3.0
@export var camera_distance_z: float = 5.0
@export var camera_stiffness: float = 10.0


func _ready() -> void:
	global_position = get_new_position()


func _physics_process(delta: float) -> void:
	var lerp_weight := 1.0 - exp(-camera_stiffness * delta)
	global_position = global_position.lerp(get_new_position(), lerp_weight)
	look_at(target.global_position, Vector3.UP)


func get_new_position() -> Vector3:
	var new_position: Vector3 = target.global_position
	var offset_z: Vector3 = target.global_basis.z * camera_distance_z
	new_position.y += camera_distance_y
	new_position += offset_z
	return new_position
