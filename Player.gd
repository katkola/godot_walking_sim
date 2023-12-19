class_name PlayerController
extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
@export_group("Movement")
@export var max_speed:float = 4.0
@export var acceleration:float = 20.0
@export var braking:float = 20.0
@export var air_acceleration:float = 4.0
@export var jump_force:float = 5.0
@export var gravity_modifier: float = 1.5
@export var max_run_speed: float = 6.0
var is_running: bool = false

@export_group ("Camera")
@export var look_sensitivity: float = 0.005
var camera_look_input:Vector2

@onready var camera:Camera3D = get_node("Camera3D")
@onready var gravity:float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
func _physics_process(delta):
	# YOU CANNOT FLYs
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
		
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#zoom
	is_running = Input.is_action_pressed('sprint')
	
	var target_speed = max_speed
	
	if is_running:
		target_speed = max_run_speed
		var run_dot = -direction.dot(transform.basis.x)
		run_dot = clamp(run_dot, 0.0, 1.0)
		direction *= run_dot
	
	var current_smoothing = acceleration
	
	if not is_on_floor():
		current_smoothing = air_acceleration
	elif not direction: 
		current_smoothing = braking
	
	var target_vel = direction * target_speed

	velocity.x = lerp(velocity.x, target_vel.x, current_smoothing*delta)
	velocity.z =  lerp(velocity.z, target_vel.z, current_smoothing*delta)
	
	move_and_slide()
	
	#Camera Look
	rotate_y(-camera_look_input.x * look_sensitivity)
	camera.rotate_x(-camera_look_input.y * look_sensitivity)
	camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)
	camera_look_input = Vector2.ZERO
	
	#Mouse
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		camera_look_input = event.relative
