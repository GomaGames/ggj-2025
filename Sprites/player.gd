extends CharacterBody2D

@export var GRAVITY:float = 200.0
@export var WALK_FORCE:float = 600.0
@export var WALK_MAX_SPEED:float = 200
@export var STOP_FORCE:float = 1300
@export var JUMP_SPEED = 200

@export var player_num:int = 0 # must be 1-4

@export var color:Color:
	set(value):
		(get_node("Polygon2D") as Polygon2D).color = value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(player_num > 0 && player_num < 5, "player_num must be set to: 1, 2, 3 or 4")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta):
	
	var walk := WALK_FORCE * (Input.get_axis(&"p%s_left" % player_num, &"p%s_right" % player_num))
	
	if walk == 0:
		walk = WALK_FORCE * Input.get_joy_axis(player_num-1,JOY_AXIS_LEFT_X)
	
	# Slow down the player if they're not trying to move.
	if abs(walk) < WALK_FORCE * 0.2:
		# The velocity, slowed down a bit, and then reassigned.
		velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
	else:
		velocity.x += walk * delta
	
	# Clamp to the maximum horizontal movement speed.
	velocity.x = clamp(velocity.x, -WALK_MAX_SPEED, WALK_MAX_SPEED)

	# apply gravity
	velocity.y += delta * GRAVITY

	move_and_slide()

	# Check for jumping. is_on_floor() must be called after movement code.
	if is_on_floor() and Input.is_action_just_pressed(&"p%s_jump" % player_num):
		velocity.y = -JUMP_SPEED
