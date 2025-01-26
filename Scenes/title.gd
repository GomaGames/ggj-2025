extends Node2D

@onready var title:Sprite2D = $"Title"
@onready var bg:Sprite2D = $"Background6"
@onready var start:Sprite2D = $"PressStart"

var original_title_pos:Vector2
var original_title_mod:Color

var original_start_pos:Vector2
var original_start_mod:Color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_title_pos = title.position
	original_title_mod = title.modulate
	title.position.y += 20
	title.modulate.a = 0.0
	
	original_start_pos = start.position
	original_start_mod = start.modulate
	start.position.y += 20
	start.modulate.a = 0.0
	
	var original_bg_pos = Vector2(bg.position)
	bg.position.y += 20
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(bg, "position", Vector2(original_bg_pos), 2)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_released(&"any_start"):
		get_tree().change_scene_to_file("res://Scenes/character_select.tscn")

func _on_title_timer_timeout() -> void:
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(title, "position", Vector2(original_title_pos), 1.25)
	tween.parallel().tween_property(title, "modulate", original_title_mod, 2)

func _on_press_start_timer_timeout() -> void:
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(start, "position", Vector2(original_start_pos), .75)
	tween.parallel().tween_property(start, "modulate", original_start_mod, 2)
