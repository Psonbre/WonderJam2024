extends Node

func _on_pressed() -> void:
	get_tree().root.get_node("Game").load_main_menu()
