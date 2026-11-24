class_name CameraFollow
extends Camera3D


@export var target: Node3D
@export var camera_distance_y: float = 3.0
@export var camera_distance_z: float = 5.0
@export var camera_stiffness: float = 10.0
@export var orbit_speed: float = 0.2

enum CameraState {
	FOLLOWING,
	ORBITING,
}

var state: CameraState


func _ready() -> void:
	global_position = get_new_position()
	set_to_orbit()


func _physics_process(delta: float) -> void:
	if state == CameraState.FOLLOWING:
		follow(delta)
	elif state == CameraState.ORBITING:
		orbit(delta)


func set_to_orbit() -> void:
	state = CameraState.ORBITING


func set_to_follow() -> void:
	state = CameraState.FOLLOWING


func follow(delta: float) -> void:
	var lerp_weight := 1.0 - exp(-camera_stiffness * delta)
	global_position = global_position.lerp(get_new_position(), lerp_weight)
	look_at(target.global_position, Vector3.UP)


func orbit(delta: float) -> void:
	var offset := global_position - target.global_position
	offset = offset.rotated(Vector3.UP, orbit_speed * delta)

	global_position = target.global_position + offset
	look_at(target.global_position, Vector3.UP)


func get_new_position() -> Vector3:
	var new_position: Vector3 = target.global_position
	var offset_z: Vector3 = target.global_basis.z * camera_distance_z
	new_position.y += camera_distance_y
	new_position += offset_z
	return new_position
