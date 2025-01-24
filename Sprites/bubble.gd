extends RigidBody2D

class_name Bubble

enum Size {
	Small,
	Medium,
	Large
}

const SmallBubbleScene: PackedScene = preload("res://Sprites/SmallBubble.tscn")
const MediumBubbleScene: PackedScene = preload("res://Sprites/MediumBubble.tscn")
const LargeBubbleScene: PackedScene = preload("res://Sprites/LargeBubble.tscn")

# these are set on instantiation
var size:Size
var bubble_container:Node
var ttl_ms:int
var lifetime_ms:int

# validate that this has not been instantiated without the constructor
var used_constructor:bool = false

const TTL_MS_SMALL:int = 2200
const TTL_MS_MEDIUM:int = 3100
const TTL_MS_LARGE:int = 4000

# constructor
static func new_bubble(size:Size, bubble_container:Node) -> Bubble:
	var b:Bubble
	match size:
		Size.Small:
			b = SmallBubbleScene.instantiate()
			b.ttl_ms = TTL_MS_SMALL
			b.lifetime_ms = TTL_MS_SMALL
		Size.Medium:
			b = MediumBubbleScene.instantiate()
			b.ttl_ms = TTL_MS_MEDIUM
			b.lifetime_ms = TTL_MS_MEDIUM
		Size.Large:
			b = LargeBubbleScene.instantiate()
			b.ttl_ms = TTL_MS_LARGE
			b.lifetime_ms = TTL_MS_LARGE
		_:
			assert(false, "Invalid value for 'size' or not yet implemented")
			
	# we keep a reference to the parent here so that we can clean ourselves up after TTL
	assert(bubble_container != null, "bubble_container must not be null")
	bubble_container.add_child(b)
	
	return b

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
