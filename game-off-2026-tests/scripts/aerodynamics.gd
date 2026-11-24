class_name Aerodynamics
extends Node3D

@export_category("Wing")
@export var object: RigidBody3D
@export var wing_area: float
@export var wing_incidence: float = 5
@export var aerodynamic_center: Marker3D
@export var chord: float

@export_category("Surface Control")
@export var yaw_intensity: float = 500.0
@export var pitch_back_intensity: float = 200.0
@export var pitch_forward_intensity: float = 10.0

@export_category("Coefficients")
@export var cl0: float = 0.15
@export var clmax: float = 1.2
@export var amax: float = 30
@export var cd: float = 0.02
@export var cm: float = -0.03

@export_category("Atmosphere")
@export var air_density: float = 1.2

var cla: float
var cl0_f3: float
var k0: float
var k1: float
var k2: float
var h: float = 0.8 # a_lim = h * a_max

var CL: float
var CD: float
var CDi: float
var CM: float

var L: float
var D: float
var M: float
var aoa: float
var AR: float

var vinf: Vector3
var Lvector: Vector3
var Dvector: Vector3
var Mvector: Vector3


var amin: float:
	get:
		return -amax

var vinf_local: Vector3:
	get:
		var v: Vector3 = global_basis.inverse() * object.linear_velocity
		return Vector3(0, v.y, v.z)

var incidence: float:
	get:
		return rad_to_deg(object.rotation.x)


# methods

func _ready() -> void:
	AR = wing_area/chord/chord
	cla = (clmax - cl0)/amax * 2/(h + 1)
	k0 = (clmax*(h**2) - cl0)/(h**2 - 1)
	k1 = (clmax - cl0)/amax * -2/(h**2 - 1)
	k2 = (clmax - cl0)/(amax**2)/(h**2 - 1)
	cl0_f3 = 2*_f1(amin) - cl0


func _physics_process(_delta: float) -> void:
	calc_coeffs()
	calc_aerodynamic_forces()
	apply_flight_forces()
	apply_control_forces()


# apply forces

func apply_flight_forces() -> void:
	object.apply_force(Lvector + Dvector, object.global_basis * aerodynamic_center.position)
	object.apply_torque(Mvector)


func apply_control_forces() -> void:
	var input_axis: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back"
	)
	object.apply_torque(-global_basis.y * input_axis.x * yaw_intensity)
	var pitch_intensity: float
	if input_axis.y < 0:
		pitch_intensity = pitch_forward_intensity
	else:
		pitch_intensity = pitch_back_intensity
	object.apply_torque(global_basis.x * input_axis.y * pitch_intensity)


# coefficient calculation

func calc_coeffs() -> void:
	# aerodynamic velocity
	vinf = global_basis * vinf_local
	# angle of attack
	var vel = object.linear_velocity.normalized()
	var forward = (global_basis * Vector3.FORWARD).normalized()
	var angulo_rad = atan2(
		Vector3.RIGHT.dot(forward.cross(vel)),
		forward.dot(vel)
	)
	aoa = -rad_to_deg(angulo_rad) + wing_incidence
	# coeffs
	if aoa < -90 or aoa > 90:
		CL = 0.1
		CDi = 0
		CD = 0.3
		CM = -0.2
	else:
		# CL
		calculate_cl()
		# CD
		CDi = CL**2/PI/AR
		CD = cd + CDi
		# CM
		CM = cm


func calculate_cl() -> void:
	if aoa < amin:
		CL = _f3(aoa)
	elif aoa < (h * amax):
		CL = _f1(aoa)
	elif aoa < 100:
		CL = max(_f2(aoa), cl0*2)
	else:
		CL = 0


func _f1(a: float) -> float:
	return cl0 + cla*a


func _f2(a: float) -> float:
	return k0 + k1*a + k2*(a**2)


func _f3(a: float) -> float:
	return cl0_f3 - cla*a


func get_dynamic_pressure() -> float:
	return air_density/2.0 * vinf.length() ** 2


func calc_aerodynamic_forces() -> void:
	var qS: float = get_dynamic_pressure() * wing_area
	L = qS * CL
	D = qS * CD
	M = qS * CM * chord
	
	Dvector = D * -vinf.normalized()
	var Dvector_local = global_basis.inverse() * Dvector
	var Lvector_local = Dvector_local.rotated(Vector3.RIGHT, -PI/2.0)
	Lvector = L * (global_basis * Lvector_local).normalized()
	Mvector = global_basis.x * M
