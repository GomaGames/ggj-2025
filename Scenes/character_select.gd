extends Node2D

var players_ready: Dictionary = {
	1: false,
	2: false,
	3: false,
	4: false,
}

var all_players_ready:bool :
	get:
		# @TODO @DEV remove this when we require all 4 players to be ready
		return players_ready[1]
		
		# @PLACEHOLDER real code below
		#for player_num in players_ready:
			#if ! players_ready[player_num]:
				#return false
		#return true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func player_ready(player_num:int) -> void:
	players_ready[player_num] = true
	(get_node("Player Text %s" % player_num) as Label).hide()
	(get_node("Player %s" % player_num) as CharacterBody2D).show()
	(((get_node("Player %s" % player_num)).find_child("Player %s Sprite" % player_num)) as AnimatedSprite2D).play()
	
	if all_players_ready:
		(get_node("Start Game") as Label).show()
	
func _input(event: InputEvent) -> void:
	if all_players_ready and event.is_action_released(&"p1_start"):
		get_tree().change_scene_to_file("res://Scenes/map_select.tscn")
		return
		
	if event.is_action_released(&"p1_start"):
		player_ready(1)
		
	if event.is_action_released(&"p2_start"):
		player_ready(2)
		
	if event.is_action_released(&"p3_start"):
		player_ready(3)
		
	if event.is_action_released(&"p4_start"):
		player_ready(4)
	
	if event.is_action_released(&"p1_select"):
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	if event.is_action_released(&"quit_game"):
		get_tree().quit()
