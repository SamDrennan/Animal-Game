extends Marker3D

func _physics_process(delta):
	
	if Input.is_action_pressed("move_left"):
		position.x -= 0.5
		position.z += 0.5
	if Input.is_action_pressed("move_right"):
		position.x += 0.5
		position.z -= 0.5
	if Input.is_action_pressed("move_forward"):
		position.x -= 0.5
		position.z -= 0.5
	if Input.is_action_pressed("move_backward"):
		position.x += 0.5
		position.z += 0.5
