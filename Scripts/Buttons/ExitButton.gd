extends Button

func _on_pressed() -> void:
	get_tree().quit()
	focus_mode = FocusMode.FOCUS_NONE
