extends Node

@export var aero: Aerodynamics
@export var arrow_scale: float = 0.02

@onready var lift_arrow: MeshInstance3D = $LiftArrow
@onready var drag_arrow: MeshInstance3D = $DragArrow


var lift_mesh := ImmediateMesh.new()
var drag_mesh := ImmediateMesh.new()

var lift_material := StandardMaterial3D.new()
var drag_material := StandardMaterial3D.new()


func _ready() -> void:
	lift_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	lift_material.albedo_color = Color.DODGER_BLUE

	drag_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	drag_material.albedo_color = Color.ORANGE_RED

	lift_arrow.mesh = lift_mesh
	drag_arrow.mesh = drag_mesh


func _physics_process(_delta: float) -> void:
	# Atualize lift_force e drag_force com seu cálculo aerodinâmico antes daqui.
	var lift_vector := aero.forces.y * Vector3.UP
	var drag_vector := aero.forces.z * Vector3.BACK
	desenhar_seta(lift_mesh, lift_vector * arrow_scale, lift_material)
	desenhar_seta(drag_mesh, drag_vector * arrow_scale, drag_material)

func desenhar_seta(mesh: ImmediateMesh, vetor: Vector3, material: Material) -> void:
	mesh.clear_surfaces()

	if vetor.length_squared() < 0.0001:
		return

	var ponta := vetor
	var direcao := vetor.normalized()
	var referencia := Vector3.UP if abs(direcao.dot(Vector3.UP)) < 0.95 else Vector3.RIGHT
	var lateral := direcao.cross(referencia).normalized()
	var tamanho_ponta: float = min(vetor.length() * 0.25, 0.5)
	var base_ponta: Vector3 = ponta - direcao * tamanho_ponta

	mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	mesh.surface_add_vertex(Vector3.ZERO)
	mesh.surface_add_vertex(ponta)

	mesh.surface_add_vertex(ponta)
	mesh.surface_add_vertex(base_ponta + lateral * tamanho_ponta * 0.4)

	mesh.surface_add_vertex(ponta)
	mesh.surface_add_vertex(base_ponta - lateral * tamanho_ponta * 0.4)
	mesh.surface_end()
