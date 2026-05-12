extends CharacterBody3D

const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003

@onready var camera: Camera3D = $Camera3D

var is_flying := true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -deg_to_rad(70), deg_to_rad(70))

func _physics_process(delta: float) -> void:
	var speed := 5.0
	if Input.is_action_just_pressed("f"):
		is_flying = false

	if not is_on_floor() and not is_flying:
		if velocity.y > 10:
			velocity.y = 0

		velocity += get_gravity() * delta

	if Input.is_action_pressed("shift"):
		speed = 100.0

	if Input.is_action_pressed("ui_accept"):
		velocity.y = speed
	elif Input.is_action_pressed("ctrl"):
		velocity.y = - speed
	elif is_flying:
		velocity.y = 0

	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif Input.is_action_just_pressed("ui_text_delete"):
		get_tree().quit()

	var input_dir := Input.get_vector("a", "d", "w", "s")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
