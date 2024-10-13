extends Button

func _on_pressed() -> void:
	get_tree().root.get_node("Game").load_credits()
	focus_mode = FocusMode.FOCUS_NONE
