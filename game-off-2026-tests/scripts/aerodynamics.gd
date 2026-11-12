class_name Aerodynamics
extends Node


@export var air_density: float = 1.2
@export var object: RigidBody3D
@export var wing_area: float
@export var chord: float
@export var aerodynamic_center: Marker3D

var forces: Vector3
var torque: Vector3


func _physics_process(_delta: float) -> void:
	get_aerodynamic_forces()
	object.apply_force(forces, aerodynamic_center.position)
	object.apply_torque(torque)


func get_dynamic_pressure() -> float:
	return air_density/2.0 * object.linear_velocity.length() ** 2


func get_aoa() -> float:
	return 0.0


func get_CL() -> float:
	return 0.3


func get_CD() -> float:
	return 0.1


func get_CM() -> float:
	return 0.07


func get_aerodynamic_forces() -> void:
	var qS: float = get_dynamic_pressure() * wing_area
	
	# linear forces
	var L: float = qS * get_CL()
	var D: float = qS * get_CD()
	forces = Vector3(0, L, D)
	
	# torque
	var M: float = qS * get_CM() * chord
	torque = Vector3(-M, 0, 0)
