extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("skip_intro"):
		SubsystemManager.get_level_manager().load_level("res://Scenes/MainMenu.tscn")

func _on_timer_timeout():
	SubsystemManager.get_level_manager().load_level("res://Scenes/MainMenu.tscn")
