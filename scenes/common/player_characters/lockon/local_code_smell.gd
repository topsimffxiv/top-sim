extends MeshInstance3D
class_name LocalCodeSmell

@export var turns: float = 3.0
@export var radius: float = 0.3
@export var segments_per_turn: int = 32
@export var strand_thickness: float = 0.05

var material: ShaderMaterial

@onready var target: Node3D
@onready var source: Node3D

var immediate_mesh: ImmediateMesh
var material1: StandardMaterial3D
var material2: StandardMaterial3D
var color1: Color = Color.PALE_VIOLET_RED
var color2: Color = Color.LIME_GREEN
var height: Vector3 = Vector3(0, 2.0, 0)
var active: bool
var frame_counter = 0

func _ready():
	material = ShaderMaterial.new()
	material.shader = load("res://assets/common/shaders/patch_tether.gdshader") # Create this shader below
	self.material_override = material
	material.set_shader_parameter("alpha", 0.25)
	
	if not source or not target:
		push_warning("Source or Target do not exist - Local Code Smell")
	
func _process(_delta):
	frame_counter += 1
	if source and target and frame_counter % 3 == 0:
		frame_counter = 0
		generate_helix()
		material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)

	
func generate_helix():
	
	var arr_mesh = ArrayMesh.new()
	
	var start_pos = self.global_transform.affine_inverse() * source.global_position + height
	var end_pos = self.global_transform.affine_inverse() * target.global_position + height
	var dir = (end_pos - start_pos).normalized()
	
	
	var orth = Vector3.UP.cross(dir).normalized()
	if orth.length() < 0.1:
		orth = Vector3.RIGHT.cross(dir).normalized()
	var orth2 = dir.cross(orth).normalized()
	
	var time_offset = Time.get_ticks_msec() / 1000.0 * 2.0
	var tube_sides = 6
	
	for strand in range(2):
		var centers = []
		var rings = []
		
		var surface_tool = SurfaceTool.new()
		surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		surface_tool.set_material(material)
		
		var total_segments = int(turns * segments_per_turn)
		
		# Precompute all center points and rings
		
		for i in range(total_segments + 1):
			var t = float(i) / total_segments
			var pos = start_pos.lerp(end_pos, t)
			var angle = t * turns * PI * 2.0 + (strand * PI) + time_offset
			var center = pos + (cos(angle) * orth + sin(angle) * orth2) * radius
			centers.append(center)
		
		# Build rings using consistent orientation
		for i in range(total_segments + 1):
			var center = centers[i]
			
			# Get direction for this segment
			var tube_dir: Vector3
			if i < total_segments:
				tube_dir = (centers[i + 1] - center).normalized()
			else:
				tube_dir = (center - centers[i - 1]).normalized()
			
			# Use a consistent reference vector
			var tube_orth1 = tube_dir.cross(orth).normalized()
			if tube_orth1.length() < 0.1:
				tube_orth1 = tube_dir.cross(orth2).normalized()
			var tube_orth2 = tube_dir.cross(tube_orth1).normalized()
			
			var ring = []
			for j in range(tube_sides):
				var a = float(j) / tube_sides * PI * 2.0
				var offset = (cos(a) * tube_orth1 + sin(a) * tube_orth2) * strand_thickness
				ring.append(center + offset)
			rings.append(ring)
		
		# Connect rings with triangles
		for i in range(total_segments):
			var ring0 = rings[i]
			var ring1 = rings[i + 1]
			
			for j in range(tube_sides):
				var j_next = (j + 1) % tube_sides
				
				var v0 = ring0[j]
				var v1 = ring0[j_next]
				var v2 = ring1[j]
				var v3 = ring1[j_next]
				
				surface_tool.set_color(color1 if strand == 0 else color2)
				
				surface_tool.add_vertex(v0)
				surface_tool.add_vertex(v1)
				surface_tool.add_vertex(v2)
				
				surface_tool.add_vertex(v1)
				surface_tool.add_vertex(v3)
				surface_tool.add_vertex(v2)
		
		surface_tool.generate_normals()
		surface_tool.commit(arr_mesh)
	
	self.mesh = arr_mesh

func set_variables(new_source: Node3D, new_target: Node3D):
	source = new_source
	target = new_target
	active = false
	
