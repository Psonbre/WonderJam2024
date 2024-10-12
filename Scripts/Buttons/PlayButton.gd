extends Button

func _ready() -> void:
	SubsystemManager.get_music_manager().play_music("res://Assets/Music1.mp3")

func _on_pressed() -> void:
	SubsystemManager.get_level_manager().load_level("res://game.tscn")
