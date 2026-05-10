extends MeshInstance3D

"""
Take in cube positions then build single mesh instance for those cubes, hiding invisible faces
"""

@export var mat: Material

var surface_array: Array = []
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
enum Face {BOTTOM, FRONT, RIGHT, TOP, LEFT, BACK}
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

func create_surface_with_invisible_faces_hidden(cube_positions: Dictionary[Vector3i, int]):
	_create_surface(cube_positions)

func _create_surface(cube_positions: Dictionary[Vector3i, int]):
	for pos in cube_positions:
		_add_face(Face.FRONT, pos, cube_positions)
		_add_face(Face.BACK, pos, cube_positions)
		_add_face(Face.LEFT, pos, cube_positions)
		_add_face(Face.RIGHT, pos, cube_positions)
		_add_face(Face.TOP, pos, cube_positions)
		_add_face(Face.BOTTOM, pos, cube_positions)
	_commit_mesh()

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

func _commit_mesh():
	surface_array.resize(Mesh.ARRAY_MAX)

	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_COLOR] = colors

	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	array_mesh.surface_set_material(0, mat)
	self.mesh = array_mesh
