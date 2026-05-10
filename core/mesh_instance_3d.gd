extends MeshInstance3D

@export var mat: Material

var surface_array: Array = []
var vertices := PackedVector3Array()
var normals := PackedVector3Array()
var colors := PackedColorArray()

var cube_vertices: Array[Vector3] = [
	Vector3(-0.5, -0.5, 0.5),
	Vector3(0.5, -0.5, 0.5),
	Vector3(0.5, -0.5, -0.5),
	Vector3(-0.5, -0.5, -0.5),
	Vector3(-0.5, 0.5, 0.5),
	Vector3(0.5, 0.5, 0.5),
	Vector3(0.5, 0.5, -0.5),
	Vector3(-0.5, 0.5, -0.5)
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

var face_normals: Dictionary[Face, Vector3] = {
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _ready() -> void:
	surface_array.resize(Mesh.ARRAY_MAX)

func generate_mesh(data: Array[Vector3]) -> void:
	for pos in data:
		_add_face(Face.FRONT, pos)
		_add_face(Face.BACK, pos)
		_add_face(Face.LEFT, pos)
		_add_face(Face.RIGHT, pos)
		_add_face(Face.TOP, pos)
		_add_face(Face.BOTTOM, pos)
	_commit_mesh()

func _add_face(face: Face, pos: Vector3):
	var indices := face_indices[face]
	for triangle in indices:
		for index in triangle:
			vertices.append(cube_vertices[index] + pos)
			normals.append(face_normals[face])
			colors.append(face_colors[face])

func _commit_mesh():
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_COLOR] = colors

	self.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	self.mesh.surface_set_material(0, mat)
