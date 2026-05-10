extends Node3D

@export var stone_block_scene: PackedScene

@onready var mesh_instance := $MeshInstance3D

var data: Array[Vector3] = []

func _ready():
	_generate_random_world(Vector3(60, 16, 60))
	#_generate_16x16x16(Vector2(0, 0))
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _generate_random_world(world_size: Vector3):
	var rng := FastNoiseLite.new()
	rng.seed = randi()

	for x in range(world_size.x):
		for y in range(world_size.y):
			for z in range(world_size.z):
				if rng.get_noise_3d(x, y, z) > 0:
					data.append(Vector3(x, y, z))

	mesh_instance.generate_mesh(data)

func _generate_rolling_hills():
	for x in range(-5, 400):
		var max_height := sin(x / 10.0) * 10
		for y in range(-15, int(max_height)):
			for z in range(0, 5):
				var stone_block := stone_block_scene.instantiate()
				stone_block.position = Vector3(x + 0.5, y + .5, z + 0.5)
				add_child(stone_block)

func _generate_16x16x16(xz_pos: Vector2):
	for x in range(xz_pos[0], xz_pos[0] + 16):
		for y in range(-16, 0):
			for z in range(xz_pos[1], xz_pos[1] + 16):
				var stone_block := stone_block_scene.instantiate()
				stone_block.position = Vector3(x + 0.5, y + .5, z + 0.5)
				add_child(stone_block)
