extends Button

@export var levelName : String

func _on_pressed() -> void:
	SubsystemManager.get_level_manager().load_level(levelName)
