extends CharacterBody3D


# variables

@export var speed := 5.0
@export var jump_velocity := 5.5
@export var mouse_sensitivity := 0.002

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var pitch := 0.0

@onready var head: Node3D = $Head


# main functions

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	self.move(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		pitch = clamp(
			pitch - event.relative.y * mouse_sensitivity,
			deg_to_rad(-80.0), deg_to_rad(80.0)
		)
	head.rotation.x = pitch

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# aux functions

func move(delta) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	self.velocity.x = direction.x * self.speed
	self.velocity.z = direction.z * self.speed
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
	move_and_slide()
