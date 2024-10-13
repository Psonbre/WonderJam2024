extends Button

@export var levelName : String

func _on_pressed() -> void:
	SubsystemManager.get_sound_manager().play_sound("res://Assets/Sounds/button_click.ogg", 0, 1)
	SubsystemManager.get_level_manager().load_level(levelName)
