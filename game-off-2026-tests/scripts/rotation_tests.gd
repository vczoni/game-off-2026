class_name RotationTester
extends Node3D


@export var object: Node3D
@export var label_normal_mode: Label
@export var label_x: Label
@export var label_y: Label
@export var label_z: Label
@export var label_rot: Label
@export var label_basis: Label

var normal_mode: bool = true
var rx: bool = false
var ry: bool = false
var rz: bool = false



func _process(_delta: float) -> void:
	if Input.is_action_just_released("reset_postition"):
		normal_mode = !normal_mode
	if Input.is_action_just_released("move_left"):
		if normal_mode:
			var rsign: int = 1 - int(rx)
			create_tween().tween_property(object, "rotation:x", deg_to_rad(90*rsign), 1)
		else:
			var rsign: int = 1 - 2*int(rx)
			var new_basis := object.basis * Basis(Vector3.RIGHT, deg_to_rad(90*rsign))
			create_tween().tween_property(object, "basis", new_basis, 1)
		rx = !rx
	if Input.is_action_just_released("move_forward"):
		if normal_mode:
			var rsign: int = 1 - int(ry)
			create_tween().tween_property(object, "rotation:y", deg_to_rad(90*rsign), 1)
		else:
			var rsign: int = 1 - 2*int(rx)
			var new_basis := object.basis * Basis(Vector3.UP, deg_to_rad(90*rsign))
			create_tween().tween_property(object, "basis", new_basis, 1)
		ry = !ry
	if Input.is_action_just_released("move_right"):
		if normal_mode:
			var rsign: int = 1 - int(rz)
			create_tween().tween_property(object, "rotation:z", deg_to_rad(90*rsign), 1)
		else:
			var rsign: int = 1 - 2*int(rx)
			var new_basis := object.basis * Basis(Vector3.FORWARD, deg_to_rad(90*rsign))
			create_tween().tween_property(object, "basis", new_basis, 1)
		rz = !rz

	if label_normal_mode:
		label_normal_mode.text = "mode normal: %s" % normal_mode
	if label_x:
		label_x.text = "rX: %d" % int(rx)
	if label_y:
		label_y.text = "rY: %d" % int(ry)
	if label_z:
		label_z.text = "rZ: %d" % int(rz)
	if label_rot:
		label_rot.text = "\nRotation: %d, %d, %d\n" % [
			rad_to_deg(object.rotation.x),
			rad_to_deg(object.rotation.y),
			rad_to_deg(object.rotation.z)
		]
	if label_basis:
		label_basis.text = "Basis: %s" % str(object.global_basis)
