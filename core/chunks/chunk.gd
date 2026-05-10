extends StaticBody3D

"""
Take in cube positions then build single mesh instance for those cubes, hiding invisible faces
"""

const CHUNK_SIZE := Vector3i(32, 16, 32)

enum Face {BOTTOM, FRONT, RIGHT, TOP, LEFT, BACK}

var vertices := PackedVector3Array()
var normals := PackedVector3Array()
var colors := PackedColorArray()
var cube_vertices: Array[Vector3i] = [
	Vector3(0, 0, 1),
	Vector3(1, 0, 1),
	Vector3(1, 0, 0),
	Vector3(0, 0, 0),
	Vector3(0, 1, 1),
	Vector3(1, 1, 1),
	Vector3(1, 1, 0),
	Vector3(0, 1, 0)
]
var face_indices: Dictionary[Face, Array] = {
	Face.FRONT: [[0, 4, 5], [0, 5, 1]],
	Face.BACK: [[2, 7, 3], [2, 6, 7]],
	Face.LEFT: [[3, 7, 4], [3, 4, 0]],
	Face.RIGHT: [[1, 5, 6], [1, 6, 2]],
	Face.BOTTOM: [[0, 1, 2], [0, 2, 3]],
	Face.TOP: [[4, 7, 6], [4, 6, 5]]
}
var face_normals: Dictionary[Face, Vector3i] = {
	Face.FRONT: Vector3(0, 0, 1),
	Face.BACK: Vector3(0, 0, -1),
	Face.LEFT: Vector3(-1, 0, 0),
	Face.RIGHT: Vector3(1, 0, 0),
	Face.BOTTOM: Vector3(0, -1, 0),
	Face.TOP: Vector3(0, 1, 0)
}
var face_colors: Dictionary[Face, Color] = {
	Face.BOTTOM: Color.RED,
	Face.FRONT: Color.ORANGE,
	Face.RIGHT: Color.YELLOW,
	Face.TOP: Color.GREEN,
	Face.LEFT: Color.BLUE,
	Face.BACK: Color.PURPLE
}

func create_chunk(pos: Vector3i, perlin_noise_generator: FastNoiseLite):
	# Clear chunk in case called twice for memory and rendering savings
	vertices.clear()
	normals.clear()
	colors.clear()

	var cube_positions: Dictionary[Vector3i, int] = {}

	for x in range(pos.x, pos.x + CHUNK_SIZE.x):
		for z in range(pos.z, pos.z + CHUNK_SIZE.z):
			var height := int(perlin_noise_generator.get_noise_2d(x, z) * 50.0)
			for y in range(-CHUNK_SIZE.y, height):
				cube_positions[Vector3i(x, y, z)] = 1

	var surface_array := _create_surface_array(cube_positions)
	_add_mesh_and_collision_to_chunk(surface_array)

func _create_surface_array(cube_positions: Dictionary[Vector3i, int]) -> Array:
	for pos in cube_positions:
		_add_face(Face.FRONT, pos, cube_positions)
		_add_face(Face.BACK, pos, cube_positions)
		_add_face(Face.LEFT, pos, cube_positions)
		_add_face(Face.RIGHT, pos, cube_positions)
		_add_face(Face.TOP, pos, cube_positions)
		_add_face(Face.BOTTOM, pos, cube_positions)

	var surface_array := []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_COLOR] = colors

	return surface_array

func _add_mesh_and_collision_to_chunk(surface_array: Array):
	var mesh_instance := MeshInstance3D.new()
	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	mesh_instance.mesh = array_mesh
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	mesh_instance.material_override = material

	var collision := CollisionShape3D.new()
	collision.shape = array_mesh.create_trimesh_shape()
	
	self.add_child(collision)
	self.add_child(mesh_instance)

# Here we duplicate vertex data but thats needed as each vertex has different normal and color 
# depending on the face
func _add_face(face: Face, pos: Vector3i, cube_positions: Dictionary[Vector3i, int]):
	# We only want to add the face if it has no neighbors, pos + normal is pos of neighbor cube
	var neighbor_pos := pos + face_normals[face]
	if neighbor_pos in cube_positions:
		return

	var indices := face_indices[face]
	for triangle in indices:
		for index in triangle:
			vertices.append(cube_vertices[index] + pos)
			normals.append(face_normals[face])
			colors.append(face_colors[face])
