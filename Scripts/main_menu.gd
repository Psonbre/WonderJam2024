extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SubsystemManager.get_music_manager()
