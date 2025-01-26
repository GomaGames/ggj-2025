extends RigidBody2D

class_name PlayerInBubble

const PlayerInBubbleScene: PackedScene = preload("res://Sprites/PlayerInBubble.tscn")

const TTL_MS_SMALL:int = 2200
const TTL_MS_MEDIUM:int = 3100

@export var TRAPPED_BUBBLE_TTL:float = 3500 # ms
var trapped_in_bubble_lifetime_ms:int = 0

var player:Player
var players_container:Node

# constructor
static func new_pib(p:Player) -> PlayerInBubble:
	var pib:PlayerInBubble = PlayerInBubbleScene.instantiate()
	pib.player = p
	pib.players_container = p.get_parent()
	return pib

func bubble_hit(b:Bubble):
	trapped_in_bubble_lifetime_ms = clamp(trapped_in_bubble_lifetime_ms+b.get_merge_into_trapped_bubble_ttl(),0,TRAPPED_BUBBLE_TTL)

func bashed(bashing_player_team_id:int, bash_velocity:Vector2):
	linear_velocity = bash_velocity
	if bashing_player_team_id == player.team_id:
		trapped_in_bubble_lifetime_ms -= 500 # 500ms for ally
	else:
		trapped_in_bubble_lifetime_ms -= 300 # 300 for enemy

func handle_ttl_color():
	var time_percentage_left = (trapped_in_bubble_lifetime_ms / TRAPPED_BUBBLE_TTL) * 100

	if time_percentage_left >= 75:
		modulate = Bubble.TTL_COLOR_DEFAULT
	elif time_percentage_left >= 50:
		modulate = Bubble.TTL_COLOR_YELLOW
	elif time_percentage_left >= 25:
		modulate = Bubble.TTL_COLOR_ORANGE
	else:
		modulate = Bubble.TTL_COLOR_RED

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = player.global_position
	linear_velocity = player.velocity
	trapped_in_bubble_lifetime_ms = TRAPPED_BUBBLE_TTL
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	trapped_in_bubble_lifetime_ms -= delta * 1000
	if trapped_in_bubble_lifetime_ms <= 0:
		pop()
	handle_ttl_color()

func _physics_process(delta: float) -> void:
	pass

func pop():
	player.velocity = linear_velocity
	player.global_position = global_position
	players_container.call_deferred("add_child",player)
	queue_free()
