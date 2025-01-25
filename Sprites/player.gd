extends CharacterBody2D

class_name Player

@onready var Bubble = load("res://Sprites/bubble.gd")

@export var GRAVITY:float = 200.0
@export var WALK_FORCE:float = 600.0
@export var WALK_MAX_SPEED:float = 200
@export var STOP_FORCE:float = 1300
@export var JUMP_SPEED:float = 200
@export var FIRE_FORCE:float = 500
@export var STUCK_BUBBLE_TTL:float = 750 # ms per bubble, new bubbles reset ttl
@export var STUCK_BUBBLE_MASS:float = 0.1 # kg, default is 1kg
@export var STUCK_BUBBLE_GRAVITY:float = -10
@export var TRAPPED_BUBBLE_TTL:float = 1500 # ms
@export var FIST_VISIBLE_DURATION:int = 200 # ms
@export var PUNCH_FORCE:float = 450.0

@export var player_num:int = 0 # must be 1-4
@export var physics_enabled:bool = true

@export var color:Color:
	set(value):
		(get_node("Polygon2D") as Polygon2D).color = value

@export var bubbles_container:Node
@export var map_oneshot_anims_container:Node

@onready var facing:Node2D = $"Facing"
@onready var fireOriginPoint:Marker2D = $"Facing/FireOriginPoint"
@onready var fist:Area2D = $"Facing/Fist"
@onready var in_bubble_area:PlayerInBubble = $"InBubble"

@onready var screen_size = get_viewport_rect().size

var _stuck_bubble_count:int = 0
var stuck_bubble_count:int:
	set(value):
		match value:
			1:
				$"Bubble1".show()
				$"Bubble2".hide()
				$"Bubble3".hide()
			2:
				$"Bubble1".show()
				$"Bubble2".show()
				$"Bubble3".hide()
			3:
				$"Bubble1".show()
				$"Bubble2".show()
				$"Bubble3".show()
			_:
				$"Bubble1".hide()
				$"Bubble2".hide()
				$"Bubble3".hide()
		_stuck_bubble_count = value
	get():
		return _stuck_bubble_count

var _trapped_in_bubble:bool = false
var trapped_in_bubble:bool:
	set(value):
		_trapped_in_bubble = value
		
		if value:
			$"InBubble".show()
			$"Polygon2D".hide()
			$"Facing".hide()
		else:
			$"InBubble".hide()
			$"Polygon2D".show()
			$"Facing".show()
	get():
		return _trapped_in_bubble

var stuck_bubble_lifetime_ms:int = 0
var trapped_in_bubble_lifetime_ms:int = 0
var fist_visible_lifetime_ms:int = 0

var other_players: Array[Player] = []

var dead: bool = false

func bubble_hit(b:Bubble):
	stuck_bubble_count += b.size
	if stuck_bubble_count >= 4:
		become_trapped_in_bubble()
	else:
		stuck_bubble_lifetime_ms = stuck_bubble_count * STUCK_BUBBLE_TTL

func become_trapped_in_bubble():
	trapped_in_bubble = true
	trapped_in_bubble_lifetime_ms = TRAPPED_BUBBLE_TTL

func knocked_out():
	hide()
	dead = true
	play_oneshot_animation_in_map($"OneShotAnimations/PopGPUParticles2D")
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(player_num > 0 && player_num < 5, "player_num must be set to: 1, 2, 3 or 4")
	
	for p in get_parent().get_children():
		if p is Player && p != self:
			other_players.append(p)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float):
	if !physics_enabled:
		return
	
	if dead:
		return
		
	if trapped_in_bubble:
		trapped_in_bubble_lifetime_ms -= delta * 1000
		if trapped_in_bubble_lifetime_ms <= 0:
			stuck_bubble_count = 0
			trapped_in_bubble = false
			trapped_in_bubble_lifetime_ms = 0
		else:
			handle_floating(delta)
			return

	if stuck_bubble_lifetime_ms > 0:
		stuck_bubble_lifetime_ms -= delta * 1000
		stuck_bubble_count = ceil(stuck_bubble_lifetime_ms / STUCK_BUBBLE_TTL)
		
	handle_movement(delta)
	handle_fire()
	handle_bash(delta)

func handle_floating(delta:float):
	velocity.y += delta * STUCK_BUBBLE_GRAVITY
	move_and_slide()
	
func handle_movement(delta:float):
	# keyboard input
	var walk := WALK_FORCE * (Input.get_axis(&"p%s_left" % player_num, &"p%s_right" % player_num))

	# gamepad input
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

	# flip facing direction
	if velocity.x < 0:
		facing.scale = Vector2(-1, 1)
	elif velocity.x > 0:
		facing.scale = Vector2(1, 1)

	# apply gravity
	velocity.y += delta * GRAVITY

	move_and_slide()

	# Check for jumping. is_on_floor() must be called after movement code.
	if is_on_floor() and Input.is_action_just_pressed(&"p%s_jump" % player_num):
		velocity.y = -JUMP_SPEED

	handle_screen_wrap()

func handle_fire():
	if bubbles_container == null:
		return

	if Input.is_action_just_released(&"p%s_fire" % player_num):
		var sm_bubble:Bubble = Bubble.new_bubble(Bubble.Size.Small, bubbles_container)
		sm_bubble.global_position = fireOriginPoint.global_position
		sm_bubble.linear_velocity = Vector2(facing.scale.x * FIRE_FORCE, 0)
	
		# hide fist if in case it's still visible
		fist.hide()

func handle_bash(delta:float):
	if bubbles_container == null:
		return
	
	if fist_visible_lifetime_ms > 0:
		fist_visible_lifetime_ms -= delta * 1000
	
	if fist_visible_lifetime_ms <= 0:
		fist_visible_lifetime_ms = 0
		fist.hide()

	if Input.is_action_just_released(&"p%s_bash" % player_num):
		fist.show()
		fist_visible_lifetime_ms = FIST_VISIBLE_DURATION
		
		# extra check for collision since fist may overlap with another body or area
		# and the _on_fist_area_entered signal won't trigger
		for p in other_players:
			if fist.overlaps_area(p.in_bubble_area):
				p.bashed(fist, PUNCH_FORCE)

func play_oneshot_animation_in_map(node:Node2D):
	assert(map_oneshot_anims_container != null)
	
	var clone = node.duplicate()
	map_oneshot_anims_container.add_child(clone)
	clone.global_position = Vector2(global_position)
	
	if clone is GPUParticles2D:
		clone.restart()

func bashed(f:Area2D, force:float):
	var direction = (global_position - f.global_position).normalized()
	var bounce_force = direction * force
	velocity = bounce_force

func handle_screen_wrap():
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)

func _on_fist_body_entered(body: Node2D) -> void:
	if !fist.visible:
		return
	
	if body is Bubble:
		var direction = (body.global_position - fist.global_position).normalized()
		var bounce_force = direction * PUNCH_FORCE
		body.apply_impulse(bounce_force)

# check if we touch any hazards
# @TODO may want to handle this in other cases too, such as when not trapped
func _on_in_bubble_body_entered(body: Node2D) -> void:
	if !trapped_in_bubble:
		return
		
	if body.is_in_group(&"hazard"):
		knocked_out()
