extends Node2D

var start_position

func _ready() -> void:
	start_position = position

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player and body.is_physics_processing():
		SubsystemManager.get_sound_manager().play_sound("res://Assets/Sounds/winJingle.ogg", -5)
		SubsystemManager.get_collectible_manager().add_piece()
		visible = false

func _process(delta):
	position = start_position + Vector2(cos(Time.get_unix_time_from_system() + 1000) * 5, sin((Time.get_unix_time_from_system() + 1000) / 2) * 10)
	pass
