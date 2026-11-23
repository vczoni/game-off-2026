extends Node3D


@export var aero: Aerodynamics
@export var object: RigidBody3D
@export var arrow_scale: float = 0.005

@onready var lift_arrow: MeshInstance3D = $LiftArrow
@onready var drag_arrow: MeshInstance3D = $DragArrow
@onready var resultant_arrow: MeshInstance3D = $ResultantArrow
@onready var moment_arrow: MeshInstance3D = $MomentArrow
@onready var velocity_arrow: MeshInstance3D = $VelocityArrow
@onready var vinf_arrow: MeshInstance3D = $VinfArrow

var lift_mesh := ImmediateMesh.new()
var drag_mesh := ImmediateMesh.new()
var resultant_mesh := ImmediateMesh.new()
var moment_mesh := ImmediateMesh.new()
var velocity_mesh := ImmediateMesh.new()
var vinf_mesh := ImmediateMesh.new()

var lift_material := StandardMaterial3D.new()
var drag_material := StandardMaterial3D.new()
var resultant_material := StandardMaterial3D.new()
var moment_material := StandardMaterial3D.new()
var velocity_material := StandardMaterial3D.new()
var vinf_material := StandardMaterial3D.new()


func _ready() -> void:
	# setup materials
	lift_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	lift_material.albedo_color = Color.DODGER_BLUE
	drag_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	drag_material.albedo_color = Color.ORANGE_RED
	resultant_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	resultant_material.albedo_color = Color.BEIGE
	moment_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	moment_material.albedo_color = Color.CORAL
	velocity_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	velocity_material.albedo_color = Color.CORNFLOWER_BLUE
	vinf_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	vinf_material.albedo_color = Color.AQUA

	# setup meshes
	lift_arrow.mesh = lift_mesh
	drag_arrow.mesh = drag_mesh
	resultant_arrow.mesh = resultant_mesh
	moment_arrow.mesh = moment_mesh
	velocity_arrow.mesh = velocity_mesh
	vinf_arrow.mesh = vinf_mesh


func _physics_process(_delta: float) -> void:
	draw_arrow(aero.Lvector, lift_mesh, lift_material)
	draw_arrow(aero.Dvector, drag_mesh, drag_material)
	draw_arrow(aero.Dvector + aero.Lvector, resultant_mesh, resultant_material)
	draw_arrow(aero.Mvector*3, moment_mesh, moment_material)
	draw_arrow(object.linear_velocity*15, velocity_mesh, velocity_material)
	draw_arrow(aero.vinf*15, vinf_mesh, vinf_material)


func draw_arrow(vector: Vector3, mesh: ImmediateMesh, material: StandardMaterial3D) -> void:
	mesh.clear_surfaces()

	if vector.length_squared() < 0.0001:
		return

	var arrow_tip: Vector3 = global_basis.inverse() * vector * arrow_scale

	mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	mesh.surface_add_vertex(Vector3.ZERO)
	mesh.surface_add_vertex(arrow_tip)
	mesh.surface_end()
