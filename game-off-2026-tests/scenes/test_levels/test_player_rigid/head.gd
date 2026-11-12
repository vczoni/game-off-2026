extends Node3D

@export var mouse_sensitivity := 0.002

var pitch := 0.0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(_delta: float) -> void:
	global_rotation.z = 0


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		pitch = clamp(
			pitch - event.relative.y * mouse_sensitivity,
			deg_to_rad(-80.0), deg_to_rad(80.0)
		)
	rotation.x = pitch

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
