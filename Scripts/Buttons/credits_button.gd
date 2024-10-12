extends Button


func _on_pressed() -> void:
	SubsystemManager.get_level_manager().load_level("res://Scenes/Credits.tscn")
