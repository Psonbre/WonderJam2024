class_name Door
extends Area2D

func _on_body_entered(body):
	if body is Player :
		SubsystemManager.get_sound_manager().play_sound("res://Assets/Sounds/winJingle.ogg")
		body.win(self)
