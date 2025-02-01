extends Node2D

@onready var maps:Array[Node2D] = [
	$"Maps/Map1",
	$"Maps/Map2",
	$"Maps/Map3",
	$"Maps/Map4",
]

@onready var change_timer:Timer = $"ChangeTimer"
var change_map_delay_done = true

var _selected_map:int = 0
var selected_map:int:
	set(value):
		_selected_map = value
		for m in maps.size():
			if m == _selected_map:
				maps[m].show()
			else:
				maps[m].hide()
	get():
		return _selected_map

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selected_map = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event.is_action_released(&"any_start"):
		get_tree().change_scene_to_file(&"res://Maps/Map%s.tscn" % (selected_map+1))
		return

	if event.is_action_released(&"p1_select"):
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	if change_map_delay_done:
		var direction := Input.get_axis(&"p1_left", &"p1_right")
		if direction > .2:
			selected_map = (maps.size() + selected_map + 1) % maps.size()
			change_timer.start()
			change_map_delay_done = false
		elif direction < -.1:
			selected_map = (maps.size() + selected_map - 1) % maps.size()
			change_timer.start()
			change_map_delay_done = false
		
	if event.is_action_released(&"quit_game"):
		get_tree().quit()


func _on_change_timer_timeout() -> void:
	change_map_delay_done = true
