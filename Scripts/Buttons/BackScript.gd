extends Node



func _on_pressed() -> void:
	SubsystemManager.get_level_manager().load_level("res://Scenes/MainMenu.tscn")
