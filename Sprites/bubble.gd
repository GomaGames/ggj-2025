extends RigidBody2D

class_name Bubble

@onready var Player = load("res://Sprites/player.gd")
@onready var screen_size = get_viewport_rect().size

enum Size {
	Small = 1,
	Medium = 2,
	Large = 3
}

const BubbleScene: PackedScene = preload("res://Sprites/Bubble.tscn")

# these are set on instantiation
var size:Size
var bubble_container:Node
var ttl_ms:float
var lifetime_ms:float
var starting_ttl_ms:float

# validate that this has not been instantiated without the constructor
var used_constructor:bool = false

const TTL_MS_SMALL:int = 3500
const TTL_MS_MEDIUM:int = 4200
const TTL_MS_LARGE:int = 5000
const TTL_COLOR_DEFAULT = Color.WHITE
const TTL_COLOR_YELLOW = Color.YELLOW
const TTL_COLOR_ORANGE = Color.ORANGE
const TTL_COLOR_RED = Color.RED

const merge_into_trapped_bubble_ttl:Array[int] = [
	0,		# nothing
	1000,	# small
	2000,	# medium
	3000,	# large
]

var velocity = Vector2(-200, 0)

# constructor
static func new_bubble(size:Size, bubble_container:Node) -> Bubble:
	var b:Bubble = BubbleScene.instantiate()
	b.size = size
	match size:
		Size.Small:
			b.ttl_ms = TTL_MS_SMALL
			b.lifetime_ms = TTL_MS_SMALL
			b.starting_ttl_ms = TTL_MS_SMALL
		Size.Medium:
			b.ttl_ms = TTL_MS_MEDIUM
			b.lifetime_ms = TTL_MS_MEDIUM
			b.starting_ttl_ms = TTL_MS_MEDIUM
			b.get_node("CollisionShape2D").scale = Vector2(2,2)
			b.get_node("Sprite2D").scale = Vector2(2,2)
		Size.Large:
			b.ttl_ms = TTL_MS_LARGE
			b.lifetime_ms = TTL_MS_LARGE
			b.starting_ttl_ms = TTL_MS_LARGE
			b.get_node("CollisionShape2D").scale = Vector2(3,3)
			b.get_node("Sprite2D").scale = Vector2(3,3)
		_:
			assert(false, "Invalid value for 'size' or not yet implemented")
			
	# we keep a reference to the parent here so that we can clean ourselves up after TTL
	assert(bubble_container != null, "bubble_container must not be null")
	bubble_container.add_child(b)
	
	return b

# the bubble that will merge into the other bubble
func merge_into_bubble(b:Bubble):
	# saving some momentum to possibly apply to merged bubble or something
	var last_linear_velocity = Vector2(self.linear_velocity)
	var last_angular_velocity = self.angular_velocity
	# stop motion to prevent other physical side effects
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	
	b.merge(self)
	
	# destroy myself
	self.queue_free()

# the bubble that is being merged into
func merge(b:Bubble):
	# @TODO logic, count? currently just increasing immediately
	match size:
		Size.Small: # become Medium
			$"CollisionShape2D".scale = Vector2(2,2)
			$"Sprite2D".scale = Vector2(2,2)
			$"BubbleOutline".scale = Vector2(2,2) * .5
			size = Size.Medium
			ttl_ms = TTL_MS_MEDIUM
			starting_ttl_ms = TTL_MS_MEDIUM
		Size.Medium: # become Large
			$"CollisionShape2D".scale = Vector2(3,3)
			$"Sprite2D".scale = Vector2(3,3)
			$"BubbleOutline".scale = Vector2(3,3) * .5
			size = Size.Large
			ttl_ms = TTL_MS_LARGE
			starting_ttl_ms = TTL_MS_LARGE
		Size.Large:
			pass
	
	reset_ttl()
	
func reset_ttl():
	lifetime_ms = ttl_ms
	
func pop():
	self.queue_free()

func get_merge_into_trapped_bubble_ttl()->int:
	return merge_into_trapped_bubble_ttl[size]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	lifetime_ms -= delta * 1000
	
	handle_ttl_color()
	
	if lifetime_ms <= 0:
		pop()
	
	handle_screen_wrap()

func _physics_process(delta: float) -> void:
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		if collision_info.get_collider() is StaticBody2D && (collision_info.get_collider() as StaticBody2D).is_in_group("hazard"):
			pop()
		if collision_info.get_collider() is StaticBody2D && (collision_info.get_collider() as StaticBody2D).is_in_group("platforms"):
			velocity = velocity.bounce(collision_info.get_normal())
		if collision_info.get_collider() is Bubble && (collision_info.get_collider() as Bubble).size == Bubble.Size.Large:
			velocity = velocity.bounce(collision_info.get_normal())
		if collision_info.get_collider() is PlayerInBubble:
			(collision_info.get_collider() as PlayerInBubble).bubble_hit(self)
			pop()

func _on_body_entered(body: Node) -> void:
	if body is Bubble:
		# if we're both Large, do nothing
		if size == Size.Large && body.size == Size.Large:
			return
			
		# if the other bubble is large, just reset it's TTL
		if size < Size.Large && body.size == Size.Large:
			body.reset_ttl()
			
		# @TODO @DESIGN only allow merges from same size or smaller
		# prevent both bubbles from getting bigger by only merging in if you are newer
		# 							 v-----------------------------------------------|
		if self.size < body.size || (self.size == body.size && self.lifetime_ms > body.lifetime_ms):
			merge_into_bubble(body)
	
	# handled in _physics_process, though it might be more optimized in this handler
	#if body is PlayerInBubble:
		#body.bubble_hit(self)
		#pop()
	
	if body is Player:
		body.bubble_hit(self)
		pop()

func handle_screen_wrap():
	if position.x > screen_size.x:
		position.x = 0
	if position.x < 0:
		position.x = screen_size.x
	if position.y > screen_size.y:
		position.y = 0
	if position.y < 0:
		position.y = screen_size.y

func handle_ttl_color():
	var time_percentage_left = (lifetime_ms / starting_ttl_ms) * 100
	
	if time_percentage_left >= 75:
		$"Sprite2D".modulate = TTL_COLOR_DEFAULT
	elif time_percentage_left >= 50:
		$"Sprite2D".modulate = TTL_COLOR_YELLOW
	elif time_percentage_left >= 25:
		$"Sprite2D".modulate = TTL_COLOR_ORANGE
	else:
		$"Sprite2D".modulate = TTL_COLOR_RED
