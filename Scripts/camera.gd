extends Camera2D

var target_position = Vector2.ZERO
var target_zoom = Vector2.ONE

func _process(delta):
	global_position = global_position.move_toward(target_position, 30 * delta)
	zoom = zoom.move_toward(target_zoom, 0.6 * delta)
