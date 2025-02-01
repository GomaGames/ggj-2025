extends Area2D

func _ready() -> void:
	if has_node("AnimatedSprite2D"):
		var animated_sprite:AnimatedSprite2D = $AnimatedSprite2D
		if animated_sprite != null:
			# play the animation with a random frame
			var start_frame = randi_range(0, animated_sprite.sprite_frames.get_frame_count(&"default"))
			animated_sprite.set_frame_and_progress(start_frame, 0)
			animated_sprite.play()
	
func _on_body_entered(body: Node2D) -> void:
	if body is PlayerInBubble:
		body.pop()
		body.player.knocked_out()
	if body is Bubble:
		body.pop()
