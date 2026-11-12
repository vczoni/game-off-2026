extends CanvasLayer

@export var player: RigidBody3D
@onready var speed_label: Label = $PanelContainer/VBoxContainer/Speed
@onready var forces_label: Label = $PanelContainer/VBoxContainer/Forces
@onready var torque_label: Label = $PanelContainer/VBoxContainer/Torque
@onready var weight_label: Label = $PanelContainer/VBoxContainer/Weight
@onready var cg_label: Label = $PanelContainer/VBoxContainer/CG

var aero: Aerodynamics

func _ready() -> void:
	aero = player.get_node("Aerodynamics")


func _process(_delta: float) -> void:
	speed_label.text = "V: %.2f m/s" % player.linear_velocity.length()
	forces_label.text = "Forças (_, L, D): %s N" % vetor_texto(aero.forces)
	torque_label.text = "Torque (M, _, _): %s N.m" % vetor_texto(aero.torque)
	var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
	var weight: float = player.mass * gravity * player.gravity_scale
	weight_label.text = "Peso: %.2f N (massa: %.2f kg)" % [weight, player.mass]
	cg_label.text = "CG: %s m" % vetor_texto(player.center_of_mass)


func vetor_texto(v: Vector3) -> String:
	return "(%.2f, %.2f, %.2f)" % [v.x, v.y, v.z]
