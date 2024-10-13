class_name Door
extends Area2D

func _on_body_entered(body):
	if body is Player && body.is_physics_processing():
		SubsystemManager.get_sound_manager().play_sound("res://Assets/Sounds/winJingle.ogg", -5)
		body.win(self)
