extends Node3D

@export var stone_block_scene: PackedScene

func _ready():
	for x in range(-5, 400):
		var max_height := sin(x / 10.0) * 10
		for y in range(-15, int(max_height)):
			for z in range(0, 5):
				var stone_block := stone_block_scene.instantiate()
				stone_block.position = Vector3(x + 0.5, y + .5, z + 0.5)
				add_child(stone_block)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
