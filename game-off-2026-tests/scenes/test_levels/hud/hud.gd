extends CanvasLayer

@export var player: RigidBody3D
@onready var distance_label: Label = $PanelContainer/VBoxContainer/VBoxContainer/Distance
@onready var speed_label: Label = $PanelContainer/VBoxContainer/VBoxContainer/Speed
@onready var weight_label: Label = $PanelContainer/VBoxContainer/VBoxContainer/Weight
@onready var cg_label: Label = $PanelContainer/VBoxContainer/VBoxContainer/CG

@onready var ar_label: Label = $PanelContainer/VBoxContainer/VBoxContainer2/AR
@onready var incidence_label: Label = $PanelContainer/VBoxContainer/VBoxContainer2/Incidence
@onready var aoa_label: Label = $PanelContainer/VBoxContainer/VBoxContainer2/AoA

@onready var cla_label: Label = $PanelContainer/VBoxContainer/VBoxContainer3/Cla
@onready var coeffs_label: Label = $PanelContainer/VBoxContainer/VBoxContainer3/Coeffs
@onready var cd_label: Label = $PanelContainer/VBoxContainer/VBoxContainer3/Cd
@onready var ld_label: Label = $PanelContainer/VBoxContainer/VBoxContainer3/LD
@onready var forces_label: Label = $PanelContainer/VBoxContainer/VBoxContainer3/Forces
@onready var torque_label: Label = $PanelContainer/VBoxContainer/VBoxContainer3/Torque

var aero: Aerodynamics
var initial_xz: Vector2

func _ready() -> void:
	aero = player.get_node("Aerodynamics")
	initial_xz = Vector2(player.position.x, player.position.z)


func _process(_delta: float) -> void:
	# container 1
	var distance_vector := Vector2(player.position.x, player.position.z) - initial_xz
	distance_label.text = "distance: %.2f m" % distance_vector.length()
	speed_label.text = "V: %.2f m/s" % player.linear_velocity.length()
	var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
	var weight: float = player.mass * gravity * player.gravity_scale
	weight_label.text = "Peso: %.2f N (massa: %.2f kg)" % [weight, player.mass]
	cg_label.text = "CG: %s m" % vetor_texto(player.center_of_mass)

	# container 2
	ar_label.text = "AR: %.2f" % aero.AR
	incidence_label.text = "θ: %.2fº" % aero.incidence
	aoa_label.text = "α: %.2fº (+%.1fº)" % [aero.aoa, aero.wing_incidence]

	# container 3
	cla_label.text = "cla %.3f" % aero.cla
	coeffs_label.text = "cL, cD, cM: %s" % vetor_texto(Vector3(aero.CL, aero.CD, aero.CM))
	cd_label.text = "CD0: %.3f | CDi: %.3f" % [aero.cd, aero.CDi]
	ld_label.text = "L/D: %.1f" % (aero.CL/aero.CD)
	forces_label.text = "Forças (L, D): %s N" % ("(%.2f, %.2f)" % [aero.L, aero.D])
	torque_label.text = "Momento %.2f N.m" % aero.M

func vetor_texto(v: Vector3) -> String:
	return "(%.2f, %.2f, %.2f)" % [v.x, v.y, v.z]
