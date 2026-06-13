@tool
extends MeshInstance3D

@export var radius: float = 2.0
@export var degrees: float = 120.0
@export var segments: int = 32
@export var refresh: bool = false: set = _set_refresh

func _set_refresh(_val):
	generate_mesh()

func _ready():
	generate_mesh()

func generate_mesh():
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	var verts = PackedVector3Array()
	var normals = PackedVector3Array()

	# Center and Arc Calculation
	verts.append(Vector3.ZERO) # Center
	normals.append(Vector3.UP)
	
	var start_angle = -deg_to_rad(degrees / 2.0)
	var end_angle = deg_to_rad(degrees / 2.0)
	for i in range(segments + 1):
		var angle = lerp(start_angle, end_angle, float(i) / segments)
		verts.append(Vector3(cos(angle) * radius, 0, sin(angle) * radius))
		normals.append(Vector3.UP)

	# Indices and Commitment
	var indices = PackedInt32Array()
	for i in range(segments):
		indices.append(0); indices.append(i + 2); indices.append(i + 1)

	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	var tmp_mesh = ArrayMesh.new()
	tmp_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	self.mesh = tmp_mesh
