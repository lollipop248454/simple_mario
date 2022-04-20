extends KinematicBody2D

const N = 1.5
const WALK_FORCE = 600*N
const WALK_MAX_SPEED = 200*N
const STOP_FORCE = 1300*N
const JUMP_SPEED = 500
const JUMP_CNT = 2
const LEFT = -1
const RIGHT = 1

var velocity = Vector2()

onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")*10

var projectResolution=Vector2(ProjectSettings.get_setting("display/window/size/width"),ProjectSettings.get_setting("display/window/size/height"))

var jump_cnt = 0

var init_position = get_global_position()

var dir = RIGHT

func start():
	dir = RIGHT
	set_position(init_position)
	jump_cnt = 0
	velocity = Vector2.ZERO
	
func die():
	position = get_position()
	return position.y >= projectResolution.y
	#print(position)
	

func _physics_process(delta):
	# Horizontal movement code. First, get the player's input.
	var walk = WALK_FORCE * (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"))
	#walk = 0
	if walk > 0:
		dir = RIGHT
	if walk < 0:
		dir = LEFT 
	# Slow down the player if they're not trying to move.
	if abs(walk) < WALK_FORCE * 0.2:
		# The velocity, slowed down a bit, and then reassigned.
		velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
	else:
		velocity.x += walk * delta
	# Clamp to the maximum horizontal movement speed.
	velocity.x = clamp(velocity.x, -WALK_MAX_SPEED, WALK_MAX_SPEED)

	# Vertical movement code. Apply gravity.
	velocity.y += gravity * delta

	# Move based on the velocity and snap to the ground.
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	#print(velocity)
	
	if is_on_floor():
		jump_cnt = 0
	else:
		# default use one time
		jump_cnt = max(jump_cnt,1)

	# Check for jumping. is_on_floor() must be called after movement code.
	if jump_cnt < JUMP_CNT and Input.is_action_just_pressed("ui_up"):
		velocity.y = -JUMP_SPEED
		jump_cnt += 1
		
	
	if velocity.length() > 0:
		$AnimatedSprite.play()
	else: 
		$AnimatedSprite.stop()
		
	$AnimatedSprite.flip_h = dir < 0
	
	if die():
		#print(get_position(),projectResolution)
		start()
	
	

