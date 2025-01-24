extends RigidBody2D

class_name Bubble

@onready var Player = load("res://Sprites/player.gd")

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

# validate that this has not been instantiated without the constructor
var used_constructor:bool = false

const TTL_MS_SMALL:int = 2200
const TTL_MS_MEDIUM:int = 3100
const TTL_MS_LARGE:int = 4000

# constructor
static func new_bubble(size:Size, bubble_container:Node) -> Bubble:
	var b:Bubble = BubbleScene.instantiate()
	b.size = size
	match size:
		Size.Small:
			b.ttl_ms = TTL_MS_SMALL
			b.lifetime_ms = TTL_MS_SMALL
		Size.Medium:
			b.ttl_ms = TTL_MS_MEDIUM
			b.lifetime_ms = TTL_MS_MEDIUM
			b.get_node("CollisionShape2D").scale = Vector2(2,2)
			b.get_node("Polygon2D").scale = Vector2(2,2)
		Size.Large:
			b.ttl_ms = TTL_MS_LARGE
			b.lifetime_ms = TTL_MS_LARGE
			b.get_node("CollisionShape2D").scale = Vector2(3,3)
			b.get_node("Polygon2D").scale = Vector2(3,3)
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
			$"Polygon2D".scale = Vector2(2,2)
			size = Size.Medium
		Size.Medium: # become Large
			$"CollisionShape2D".scale = Vector2(3,3)
			$"Polygon2D".scale = Vector2(3,3)
			size = Size.Large
		Size.Large:
			pass
	
	reset_ttl()
	
func reset_ttl():
	lifetime_ms = ttl_ms
	
func pop():
	self.queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	lifetime_ms -= delta * 1000
	
	if lifetime_ms <= 0:
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
	
	if body is Player && !(body as Player).trapped_in_bubble:
		body.bubble_hit(self)
		queue_free()
