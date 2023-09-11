extends CharacterBody3D
@export var score = 0
@export var charging = false

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var mouse_sens = 0.3
var camera_anglev = 0
var charge_speed = 1
var tracking_mouse = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func change_mouse_visibility():
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		tracking_mouse = false
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		tracking_mouse = true


func _physics_process(delta):
	if Input.is_action_just_pressed("charge"):
		charging = true
	if Input.is_action_just_released("charge"):
		charging = false
	if not charging:
		$ChargingMI3D.visible = false
		$ChargingCS3D.disabled = true
		$NormalMI3D.visible = true
		$NormalCS3D.disabled = false
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta

		# Handle Jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("left", "right", "forward", "backward")
		var direction = (transform.basis)
		if charge_speed <= 1:
			direction = ((transform.basis * Vector3(input_dir.x, 0, input_dir.y))).normalized()
			if direction:
				velocity.x = direction.x * SPEED
				velocity.z = direction.z * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				velocity.z = move_toward(velocity.z, 0, SPEED)
				charge_speed = 1
		else:
			velocity = -(transform.basis.x*charge_speed)
			velocity = -(transform.basis.z*charge_speed)
		if charge_speed > 1:
			charge_speed = 1
	else:
		$ChargingMI3D.visible = true
		$ChargingCS3D.disabled = false
		$NormalMI3D.visible = false
		$NormalCS3D.disabled = true
		if charge_speed <= 500:
			charge_speed *= 2.5
		
	move_and_slide()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		change_mouse_visibility()
	if event is InputEventMouseMotion and tracking_mouse:
		rotate_y(deg_to_rad(-event.relative.x*mouse_sens))
		var changev=-event.relative.y*mouse_sens
		if camera_anglev+changev>-50 and camera_anglev+changev<50:
			camera_anglev+=changev
			$Camera3D.rotate_x(deg_to_rad(changev))

func _on_area_3d_body_entered(body):
	if "Ring" in body.name:
		score += 1
		body.queue_free()
