extends Node2D

class_name Map

signal match_resolved

var is_match_resolved:bool = false

var _team_life_1:int = 3 # must match the number of $"LifeN" in TeamLifeSupply
var team_life_1:int:
	get():
		return _team_life_1
	set(value):
		_team_life_1 = value
		match value:
			3:
				$"UI/TeamLifeSupply1/Life1".show()
				$"UI/TeamLifeSupply1/Life2".show()
				$"UI/TeamLifeSupply1/Life3".show()
			2:
				$"UI/TeamLifeSupply1/Life1".show()
				$"UI/TeamLifeSupply1/Life2".show()
				$"UI/TeamLifeSupply1/Life3".hide()
			1:
				$"UI/TeamLifeSupply1/Life1".show()
				$"UI/TeamLifeSupply1/Life2".hide()
				$"UI/TeamLifeSupply1/Life3".hide()
			0:
				$"UI/TeamLifeSupply1/Life1".hide()
				$"UI/TeamLifeSupply1/Life2".hide()
				$"UI/TeamLifeSupply1/Life3".hide()
			_:
				assert(false, "OOB error. number of lives set is not supported")

var _team_life_2:int = 3 # must match the number of $"LifeN" in TeamLifeSupply
var team_life_2:int:
	get():
		return _team_life_2
	set(value):
		_team_life_2 = value
		match value:
			3:
				$"UI/TeamLifeSupply2/Life1".show()
				$"UI/TeamLifeSupply2/Life2".show()
				$"UI/TeamLifeSupply2/Life3".show()
			2:
				$"UI/TeamLifeSupply2/Life1".show()
				$"UI/TeamLifeSupply2/Life2".show()
				$"UI/TeamLifeSupply2/Life3".hide()
			1:
				$"UI/TeamLifeSupply2/Life1".show()
				$"UI/TeamLifeSupply2/Life2".hide()
				$"UI/TeamLifeSupply2/Life3".hide()
			0:
				$"UI/TeamLifeSupply2/Life1".hide()
				$"UI/TeamLifeSupply2/Life2".hide()
				$"UI/TeamLifeSupply2/Life3".hide()
			_:
				assert(false, "OOB error. number of lives set is not supported")

func _on_player_kod(team_id:int):
	assert(team_id > 0 && team_id < 3)
	if team_id == 1:
		team_life_1 -= 1
	else:
		team_life_2 -= 1
	
	if team_life_1 == 0:
		$"UI/Team2Victory".show()
		match_resolved.emit()
	elif team_life_2 == 0:
		$"UI/Team1Victory".show()
		match_resolved.emit()

func _on_match_resolved():
	is_match_resolved = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match_resolved.connect(_on_match_resolved)
	$"Players/Player 1".kod.connect(_on_player_kod)
	$"Players/Player 2".kod.connect(_on_player_kod)
	$"Players/Player 3".kod.connect(_on_player_kod)
	$"Players/Player 4".kod.connect(_on_player_kod)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_match_resolved && Input.is_action_just_pressed(&"any_start"):
		get_tree().reload_current_scene()
		
	if Input.is_action_just_released(&"p1_select"):
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	if Input.is_action_just_released(&"quit_game"):
		get_tree().quit()
