extends Button

func _on_pressed() -> void:
	get_tree().root.get_node("Game").load_level("Level1")
	focus_mode = FocusMode.FOCUS_NONE
