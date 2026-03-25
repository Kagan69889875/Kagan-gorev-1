extends Area2D

func _process(delta: float) -> void:
	if Global.is_game_over:
		return
	position.x -= Global.game_speed * delta
	if position.x < -200.0:
		queue_free()
